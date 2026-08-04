import { Injectable } from "@nestjs/common";
import { PrismaService } from "@pauti-pustak/backend-database";
import { createHash } from "crypto";

export interface LogAuditParams {
  actorId?: string;
  action: string;
  targetTable?: string;
  targetId?: string;
  reason?: string;
  organizationId?: string;
  eventId?: string;
  ipAddress?: string;
  userAgent?: string;
  metadata?: Record<string, any>;
  outcome?: "SUCCESS" | "FAILURE";
  sessionId?: string;
}

const NIL_UUID = "00000000-0000-0000-0000-000000000000";

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async log(params: LogAuditParams) {
    try {
      const actorId = params.actorId || NIL_UUID;
      const targetId = params.targetId || NIL_UUID;
      const targetType = params.targetTable || "auth";
      const requestId = params.sessionId || "system";
      const recordHash = createHash("sha256")
        .update(`${actorId}:${params.action}:${Date.now()}:${Math.random()}`)
        .digest("hex");

      const ipAddressHash = params.ipAddress
        ? createHash("sha256").update(params.ipAddress).digest("hex")
        : null;

      const snapshot = {
        outcome: params.outcome ?? "SUCCESS",
        ...(params.metadata ?? {}),
      };

      return await (this.prisma as any).auditLog.create({
        data: {
          scope: params.organizationId ? "TENANT" : "SYSTEM",
          organizationId: params.organizationId ?? null,
          eventId: params.eventId ?? null,
          actionType: params.action,
          performedByUserId: actorId,
          reason: params.reason ?? null,
          targetType,
          targetId,
          requestId,
          ipAddressHash,
          userAgent: params.userAgent ?? null,
          afterSnapshot: snapshot,
          recordHash,
        },
      });
    } catch {
      // Fallback log attempt if auditLog creation fails
      return null;
    }
  }
}

