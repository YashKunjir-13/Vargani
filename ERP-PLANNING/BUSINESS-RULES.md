# Business Rules Catalogue

## Organization and events

- An organization owns its members, events, contributors, volunteers, bills, collections, expenses, accounts, reports, files, and settings.
- A financially closed event blocks new bills, collections, contributions, and expenses unless an authorized reopening is recorded with a reason.

## Volunteers and collectors

- A volunteer does not require a login account.
- Only active volunteers may receive new assignments.
- Reassignment affects future work and never rewrites historical collector snapshots.
- Collector cash settlement compares expected cash with handed-over cash and requires a reason for variance.

## Contributors

- Bills require an identified contributor account.
- Direct contributions may follow the approved identity/privacy policy.
- Duplicate detection uses normalized mobile, email, address, area, and configured matching rules.
- Merging changes identity references only; it never combines or rewrites monetary values.

## Bills

- Draft bills may be edited.
- Issued bills receive an immutable number and issue-time snapshot.
- Paid amount plus waiver may not exceed the bill amount.
- Cancelled numbers are never reused.
- Corrections use replacement records linked to the original.

## Collections and payments

- Manual collections remain pending until verification when policy requires it.
- Cheques remain pending until cleared.
- Online payments become confirmed only after backend signature/webhook verification.
- Partial payments are allowed only when enabled.
- The outstanding amount cannot become negative.
- Every accepted command and webhook is idempotent.

## Contributions and receipts

- A confirmed payment produces one canonical contribution effect.
- Each confirmed payment produces one receipt unless a documented business exception applies.
- Receipt numbers are immutable and never reused.
- Cancellation and replacement preserve the original receipt.
- Public verification exposes only safe information.

## Expenses and ledger

- Submitted expenses cannot be silently changed.
- Approval follows configured policy and separation of duties.
- Payments cannot exceed approved outstanding expense amounts.
- Ledger postings are append-only and balanced.
- Corrections use reversal entries.
