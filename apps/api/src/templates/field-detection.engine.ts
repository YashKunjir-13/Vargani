import { Injectable } from "@nestjs/common";

export interface DetectedField {
  fieldKey: string;
  page?: number;
  x: number;
  y: number;
  confidence: number;
}

export interface FieldDetectionResult {
  status: "AutoDetected" | "Failed";
  fields: DetectedField[];
}

export interface FieldDetectionEngine {
  detect(input: { fileUrl: string }): Promise<FieldDetectionResult>;
}

export const FIELD_DETECTION_ENGINE = Symbol("FIELD_DETECTION_ENGINE");

/**
 * Placeholder OCR/layout-analysis engine. Every consumer depends only on
 * the FieldDetectionEngine interface (via FIELD_DETECTION_ENGINE), so a
 * real OCR/layout-analysis integration can be swapped in later by rebinding
 * this token -- no caller code needs to change.
 */
@Injectable()
export class StubFieldDetectionEngine implements FieldDetectionEngine {
  async detect(): Promise<FieldDetectionResult> {
    return {
      status: "AutoDetected",
      fields: [
        { fieldKey: "mandalName", page: 1, x: 0.4, y: 0.05, confidence: 0.6 },
        { fieldKey: "receiptNumber", page: 1, x: 0.15, y: 0.1, confidence: 0.6 },
        { fieldKey: "date", page: 1, x: 0.75, y: 0.1, confidence: 0.6 },
        { fieldKey: "donorName", page: 1, x: 0.15, y: 0.25, confidence: 0.6 },
        { fieldKey: "amount", page: 1, x: 0.75, y: 0.25, confidence: 0.6 },
      ],
    };
  }
}
