const createMock = jest.fn();

jest.mock("razorpay", () => {
  return jest.fn().mockImplementation(() => ({
    orders: { create: createMock },
  }));
});

import { RazorpayOrdersClient } from "./razorpay-orders.client";

describe("RazorpayOrdersClient", () => {
  const originalEnv = process.env;

  beforeEach(() => {
    jest.clearAllMocks();
    process.env = { ...originalEnv, RAZORPAY_KEY_ID: "rzp_test_key", RAZORPAY_KEY_SECRET: "test_secret" };
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it("converts rupees to paise and forwards receipt/notes to the Razorpay SDK", async () => {
    createMock.mockResolvedValueOnce({ id: "order_abc123", amount: "50100", currency: "INR" });
    const client = new RazorpayOrdersClient();

    const order = await client.createOrder({
      amountRupees: 501,
      receipt: "payment-1",
      notes: { organizationId: "org-1" },
    });

    expect(createMock).toHaveBeenCalledWith({
      amount: 50100,
      currency: "INR",
      receipt: "payment-1",
      notes: { organizationId: "org-1" },
    });
    expect(order).toEqual({ id: "order_abc123", amount: 50100, currency: "INR" });
  });

  it("rounds fractional-paise amounts rather than truncating or throwing", async () => {
    createMock.mockResolvedValueOnce({ id: "order_xyz", amount: "10035", currency: "INR" });
    const client = new RazorpayOrdersClient();

    await client.createOrder({ amountRupees: 100.349, receipt: "payment-2" });

    expect(createMock).toHaveBeenCalledWith(expect.objectContaining({ amount: 10035 }));
  });

  it("propagates Razorpay API failures to the caller", async () => {
    createMock.mockRejectedValueOnce(new Error("network error"));
    const client = new RazorpayOrdersClient();

    await expect(client.createOrder({ amountRupees: 100, receipt: "payment-3" })).rejects.toThrow("network error");
  });
});
