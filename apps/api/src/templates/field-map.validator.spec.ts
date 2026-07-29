import { BadRequestException } from "@nestjs/common";
import { validateFieldMap } from "./field-map.validator";

describe("validateFieldMap", () => {
  it("accepts a well-formed fieldMap entry and fills in schema defaults", () => {
    const result = validateFieldMap([{ fieldKey: "amount", x: 0.5, y: 0.5 }]);

    expect(result).toEqual([
      { fieldKey: "amount", page: 1, x: 0.5, y: 0.5, fontSize: 12, detectionConfidence: null },
    ]);
  });

  it("preserves an explicit page/fontSize/detectionConfidence", () => {
    const result = validateFieldMap([
      { fieldKey: "receiptNumber", page: 2, x: 0.1, y: 0.2, fontSize: 14, detectionConfidence: 0.83 },
    ]);

    expect(result).toEqual([
      { fieldKey: "receiptNumber", page: 2, x: 0.1, y: 0.2, fontSize: 14, detectionConfidence: 0.83 },
    ]);
  });

  it("rejects an entry missing x", () => {
    expect(() => validateFieldMap([{ fieldKey: "amount", y: 0.5 }])).toThrow(BadRequestException);
  });

  it("rejects an entry missing y", () => {
    expect(() => validateFieldMap([{ fieldKey: "amount", x: 0.5 }])).toThrow(BadRequestException);
  });

  it("rejects an entry with an unrecognized fieldKey", () => {
    expect(() => validateFieldMap([{ fieldKey: "signature", x: 0.1, y: 0.1 }])).toThrow(BadRequestException);
  });

  it("rejects x outside the normalized 0-1 range", () => {
    expect(() => validateFieldMap([{ fieldKey: "amount", x: 1.5, y: 0.5 }])).toThrow(BadRequestException);
  });

  it("rejects y outside the normalized 0-1 range", () => {
    expect(() => validateFieldMap([{ fieldKey: "amount", x: 0.5, y: -0.1 }])).toThrow(BadRequestException);
  });

  it("rejects a non-array payload", () => {
    expect(() => validateFieldMap({ fieldKey: "amount", x: 0.5, y: 0.5 })).toThrow(BadRequestException);
  });

  it("rejects a detectionConfidence outside 0-1 when provided", () => {
    expect(() =>
      validateFieldMap([{ fieldKey: "amount", x: 0.5, y: 0.5, detectionConfidence: 1.2 }]),
    ).toThrow(BadRequestException);
  });
});
