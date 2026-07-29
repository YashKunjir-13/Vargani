import { WhatsAppDeliveryStatus } from "@pauti-pustak/backend-database";
import { WhatsAppDeliveryService } from "./whatsapp-delivery.service";

function buildPrismaMock() {
  const records = new Map<string, any>();
  let nextId = 1;

  return {
    whatsAppDeliveryRecord: {
      create: jest.fn(({ data }: any) => {
        const record = { id: `delivery-${nextId++}`, retryCount: 0, ...data };
        records.set(record.id, record);
        return Promise.resolve(record);
      }),
      update: jest.fn(({ where, data }: any) => {
        const existing = records.get(where.id);
        const merged = {
          ...existing,
          ...data,
          retryCount:
            data.retryCount && typeof data.retryCount === "object"
              ? existing.retryCount + data.retryCount.increment
              : (data.retryCount ?? existing.retryCount),
        };
        records.set(where.id, merged);
        return Promise.resolve(merged);
      }),
      findUnique: jest.fn(({ where }: any) => Promise.resolve(records.get(where.id) ?? null)),
    },
    __records: records,
  };
}

describe("WhatsAppDeliveryService", () => {
  it("never throws when the provider client fails, and records the failure with an incremented retry counter", async () => {
    const prisma = buildPrismaMock();
    const providerClient = {
      sendMediaMessage: jest.fn().mockRejectedValue(new Error("provider unreachable")),
    };
    const service = new WhatsAppDeliveryService(prisma as any, providerClient);

    await expect(
      service.sendDocument({
        organizationId: "org-1",
        recipientPhone: "+919999999999",
        mediaUrl: "https://cdn.example.com/receipt.pdf",
      }),
    ).resolves.toEqual({ deliveryId: expect.any(String) });

    const [[, record]] = prisma.__records; // Map iterates [key, value] pairs
    expect(record.status).toBe(WhatsAppDeliveryStatus.FAILED);
    expect(record.retryCount).toBe(1);
    expect(record.lastError).toContain("provider unreachable");
  });

  it("marks the delivery SENT and stores the provider message id on success", async () => {
    const prisma = buildPrismaMock();
    const providerClient = {
      sendMediaMessage: jest.fn().mockResolvedValue({ providerMessageId: "wamid.abc123" }),
    };
    const service = new WhatsAppDeliveryService(prisma as any, providerClient);

    const { deliveryId } = await service.sendDocument({
      organizationId: "org-1",
      recipientPhone: "+919999999999",
      mediaUrl: "https://cdn.example.com/receipt.pdf",
    });

    const record = await prisma.whatsAppDeliveryRecord.findUnique({ where: { id: deliveryId } });
    expect(record.status).toBe(WhatsAppDeliveryStatus.SENT);
    expect(record.providerMessageId).toBe("wamid.abc123");
  });

  it("does not throw even if persisting the failure itself also fails", async () => {
    const prisma = buildPrismaMock();
    prisma.whatsAppDeliveryRecord.update = jest.fn().mockRejectedValue(new Error("db unavailable"));
    const providerClient = {
      sendMediaMessage: jest.fn().mockRejectedValue(new Error("provider unreachable")),
    };
    const service = new WhatsAppDeliveryService(prisma as any, providerClient);

    await expect(
      service.sendDocument({
        organizationId: "org-1",
        recipientPhone: "+919999999999",
        mediaUrl: "https://cdn.example.com/receipt.pdf",
      }),
    ).resolves.toEqual({ deliveryId: expect.any(String) });
  });

  it("stops retrying once MAX_RETRY_COUNT is reached", async () => {
    const prisma = buildPrismaMock();
    const providerClient = {
      sendMediaMessage: jest.fn().mockRejectedValue(new Error("still down")),
    };
    const service = new WhatsAppDeliveryService(prisma as any, providerClient);

    const { deliveryId } = await service.sendDocument({
      organizationId: "org-1",
      recipientPhone: "+919999999999",
      mediaUrl: "https://cdn.example.com/receipt.pdf",
    });

    await service.retryDelivery(deliveryId);
    await service.retryDelivery(deliveryId);
    await service.retryDelivery(deliveryId); // should be a no-op: retryCount already at 3

    expect(providerClient.sendMediaMessage).toHaveBeenCalledTimes(3); // 1 initial + 2 retries, 3rd retry skipped
  });
});
