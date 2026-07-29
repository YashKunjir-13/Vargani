import { BadRequestException } from "@nestjs/common";

export const VALID_FIELD_KEYS = [
  "donorName",
  "amount",
  "date",
  "receiptNumber",
  "mandalName",
] as const;

export type TemplateFieldKey = (typeof VALID_FIELD_KEYS)[number];

export interface FieldMapEntry {
  fieldKey: TemplateFieldKey;
  page: number;
  x: number;
  y: number;
  fontSize: number;
  detectionConfidence: number | null;
}

function isUnitInterval(value: unknown): value is number {
  return typeof value === "number" && Number.isFinite(value) && value >= 0 && value <= 1;
}

/**
 * Validates and normalizes a raw fieldMap payload -- from either the
 * upload/PATCH request body or a (possibly untrusted/stubbed) field
 * detection engine's output. Rejects any entry with an unrecognized
 * fieldKey or missing/out-of-range x/y, and fills in the schema's
 * defaults (page: 1, fontSize: 12, detectionConfidence: null) so callers
 * always get a fully-shaped FieldMapEntry[] back.
 */
export function validateFieldMap(entries: unknown): FieldMapEntry[] {
  if (!Array.isArray(entries)) {
    throw new BadRequestException("fieldMap must be an array");
  }

  return entries.map((raw, index) => {
    const entry = raw as Record<string, unknown>;
    if (!entry || typeof entry !== "object") {
      throw new BadRequestException(`fieldMap[${index}] must be an object`);
    }

    if (!VALID_FIELD_KEYS.includes(entry.fieldKey as TemplateFieldKey)) {
      throw new BadRequestException(
        `fieldMap[${index}] has an unrecognized fieldKey: ${String(entry.fieldKey)}`,
      );
    }

    if (!isUnitInterval(entry.x)) {
      throw new BadRequestException(
        `fieldMap[${index}] (${entry.fieldKey}) requires a normalized x between 0 and 1`,
      );
    }

    if (!isUnitInterval(entry.y)) {
      throw new BadRequestException(
        `fieldMap[${index}] (${entry.fieldKey}) requires a normalized y between 0 and 1`,
      );
    }

    if (entry.detectionConfidence !== undefined && entry.detectionConfidence !== null) {
      if (!isUnitInterval(entry.detectionConfidence)) {
        throw new BadRequestException(
          `fieldMap[${index}] (${entry.fieldKey}) detectionConfidence must be between 0 and 1`,
        );
      }
    }

    return {
      fieldKey: entry.fieldKey as TemplateFieldKey,
      page: typeof entry.page === "number" ? entry.page : 1,
      x: entry.x as number,
      y: entry.y as number,
      fontSize: typeof entry.fontSize === "number" ? entry.fontSize : 12,
      detectionConfidence:
        entry.detectionConfidence === undefined ? null : (entry.detectionConfidence as number | null),
    };
  });
}
