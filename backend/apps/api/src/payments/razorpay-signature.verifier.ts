import { createHmac, timingSafeEqual } from "node:crypto";
import { Injectable } from "@nestjs/common";

export interface RazorpaySignatureVerifier {
  /** rawBody must be the exact, unparsed request bytes Razorpay signed. */
  verify(rawBody: Buffer, signatureHeader: string | undefined): boolean;
}

export const RAZORPAY_SIGNATURE_VERIFIER = Symbol("RAZORPAY_SIGNATURE_VERIFIER");

/**
 * HMAC-SHA256 verification per Razorpay's webhook signing scheme:
 * signature = hex(hmac_sha256(rawBody, webhookSecret)).
 */
@Injectable()
export class HmacRazorpaySignatureVerifier implements RazorpaySignatureVerifier {
  verify(rawBody: Buffer, signatureHeader: string | undefined): boolean {
    if (!signatureHeader) {
      return false;
    }

    const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
    if (!secret) {
      return false;
    }

    const expected = createHmac("sha256", secret).update(rawBody).digest("hex");
    const expectedBuffer = Buffer.from(expected, "hex");
    const providedBuffer = Buffer.from(signatureHeader, "hex");

    if (expectedBuffer.length !== providedBuffer.length) {
      return false;
    }

    return timingSafeEqual(expectedBuffer, providedBuffer);
  }
}
