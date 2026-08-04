export class ContributionReceiptNumberFormatter {
  static format(festivalYear: number, sequenceValue: number): string {
    const padded = String(sequenceValue).padStart(6, "0");
    return `CRECEPT-${festivalYear}-${padded}`;
  }
}
