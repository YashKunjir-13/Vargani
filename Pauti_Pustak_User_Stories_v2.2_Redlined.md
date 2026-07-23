# Pauti Pustak — Refined User Stories (v2.3, redlined against Backend Spec v2.1)

## Change log — what was corrected and why

### v2.1 draft → v2.2: spec-alignment pass

This revision aligns the original 44-story draft with `Pauti_Pustak_Backend_System_Architecture_Module_Requirements_Enterprise_v2.1_Revised.pdf`. Nothing was removed; the following was added or tightened:

1. **Event lifecycle** was missing 2 of 5 states. Added *Complete Event* and *Archive Event* (spec: `DRAFT → ACTIVE → COMPLETED → FINANCIALLY_CLOSED → ARCHIVED`, direct jumps rejected).
2. **New Epic: Receipt Book Management** — a whole module referenced by Volunteer, Bill, and Collection stories but previously uncovered.
3. **Contributor Account is event-scoped**, not org-wide reusable — corrected US "Create Contributor Account" and noted the same donor may hold multiple event-specific accounts.
4. **Bill lifecycle** gained the missing `GENERATED` preview step and an explicit status-tracking story (`ISSUED → PARTIALLY_PAID → PAID`, plus `OVERDUE`).
5. **New Epic 10 additions: Vendor Management and Expense Approval Policy** — expenses cannot exist without these in the spec (every expense requires a vendor and a versioned approval-threshold policy), but neither had a story.
6. Tightened acceptance criteria that were correct in direction but dropped a spec-stated rule: volunteer reactivation reason, waiver approval step, bill/receipt replacement reason and scope, expense separation-of-duties, paid-expense immutability, public-summary snapshot versioning.
7. Softened one recurring overreach: "collector can view only assigned contributors" is a product decision, not a spec requirement — the spec only restricts *collection authority*, not read access.

### v2.2 → v2.3: editorial decisions (standard industry practice applied)

Four judgment calls from the v2.2 review were resolved using standard practice rather than left open:

1. **Complete Event kept as its own story.** Standard ERP/financial-system pattern: operational completion and financial closure are owned by different actors on different timelines (Event Coordinator winds down the ground event; Treasurer/Owner closes the books later, after final bills settle). Collapsing them would hide a state the spec enforces as a distinct, gated transition.
2. **Receipt Book Management kept and elevated, not cut.** "Pauti Pustak" is Marathi/Hindi for "receipt book" — this is the product's namesake domain object. Per standard domain-driven design practice, the digital model should mirror the ubiquitous language the business already uses; hiding it as an internal-only concept would contradict the product's own naming.
3. **Preview Generated Bill folded into Create Personalized Bill, standalone story dropped.** By the INVEST checklist for story quality, a story needs independent business value. "Preview before issuing" is a workflow detail of billing, not a distinct user goal, so it is now an acceptance criterion on US-018 instead of its own story. This removes one story; everything after it in Epic 6 onward is renumbered down by one (new range is US-001–US-052).
4. **Collector view-scope hardened into an enforced access-control rule, not a UI nicety.** This is OWASP Top-10 territory (Broken Access Control is #1) — any access restriction implied by a role must be enforced server-side. US-011 and US-015 now state this as a backend authorization requirement rather than a soft "product configuration," and it's flagged as a gap to raise with the backend team since the v2.1 spec only defines *collection authority*, not *read* scoping.

All story IDs below are renumbered sequentially (US-001 to US-052); the original ID from the first (44-story) draft is noted in parentheses where a story carried over unchanged or nearly unchanged.

---

## Epic 1: Organization and Access

### US-001 (was US-001) — Register Organization

**As an organization owner, I want to register my organization, so that I can manage events and financial activities in Pauti Pustak.**

**Acceptance criteria**

* The owner can enter organization and contact details.
* A unique organization code is generated and becomes immutable after the first receipt is issued.
* The first registered user becomes the organization owner.
* Duplicate registration requests do not create duplicate organizations.

---

### US-002 (was US-002) — Sign In

**As a registered user, I want to sign in securely, so that I can access my assigned organization and features.**

**Acceptance criteria**

* Valid credentials allow access.
* Invalid or expired credentials are rejected.
* The user can access only organizations where they have an active membership, and only one active organization membership is enforced per user across the platform.
* Repeated failed attempts are limited.

---

### US-003 (was US-003) — Manage Roles

**As an organization owner, I want to assign roles to members, so that each member has the correct level of access.**

**Acceptance criteria**

* The owner can assign a predefined or custom role.
* Users can perform only actions allowed by their role.
* The Owner role cannot be removed or disabled.
* Role changes are recorded in the audit history.

---

## Epic 2: Event Management

### US-004 (was US-004) — Create Event

**As an organization owner, I want to create an event, so that its contributions, expenses, volunteers, and reports can be managed separately.**

**Acceptance criteria**

* The owner can enter the event name, dates, location, financial year, and target amount.
* Each event receives a unique event code that becomes immutable once the first receipt is allocated against it.
* A newly created event starts in Draft status.
* Events belonging to other organizations are not accessible.

---

### US-005 (was US-005) — Activate Event

**As an organization owner, I want to activate a draft event, so that billing and contribution collection can begin.**

**Acceptance criteria**

* Only a valid Draft event can be activated.
* Only an authorized user (Owner) can activate the event.
* The activation date and user are recorded.
* An activated event becomes available for billing and collection.

---

### US-006 (NEW) — Complete Event

**As an organization owner, I want to mark an active event as complete, so that day-to-day operations can wind down while final financial activity is still recorded.**

**Acceptance criteria**

* Only an Active event can be marked Complete; direct jumps from any other status are rejected.
* Only an authorized user (Owner) can complete the event.
* Bills and contributions may still be recorded and collected while the event is Completed but not yet financially closed.
* The completion date and user are recorded.

---

### US-007 (was US-006) — Close Event (Financial Closure)

**As an organization owner, I want to financially close an event, so that no new financial activity can be recorded after completion.**

**Acceptance criteria**

* New bills, contributions, and expenses are blocked after financial closure.
* Existing approved expenses may still be paid according to policy; the event may close with outstanding liabilities, and available balance and projected balance are reported separately.
* A financially closed event can be reopened to Active only with a documented reason and audit record; no override token bypasses this.
* Historical records remain available.

---

### US-008 (NEW) — Archive Event

**As an organization owner, I want to archive a financially closed event, so that it is preserved as a permanent, read-only record.**

**Acceptance criteria**

* Only a Financially Closed event can be archived; direct jumps from any other status are rejected.
* Only an authorized user (Owner) can archive the event.
* An archived event is terminal and read-only — no further status changes or edits are possible.
* All historical bills, contributions, expenses, and reports for the event remain viewable.

---

## Epic 3: Volunteer Management

### US-009 (was US-007) — Register Volunteer

**As a volunteer coordinator, I want to register a volunteer, so that the volunteer can participate in event activities.**

**Acceptance criteria**

* The coordinator can enter the volunteer's full name, mobile, email, address, emergency contact, joining date, preferred language, and type (General, Donation Collector, Event Coordinator, Finance Volunteer, Decoration, Food Distribution, Crowd Management, or Custom).
* A volunteer can be created without a login account, and may optionally be linked to one verified user identity later without altering historical volunteer snapshots.
* Each volunteer receives a unique volunteer code.
* The system flags likely duplicate volunteers by matching normalized mobile number and name.

---

### US-010 (was US-008) — Assign Volunteer

**As a volunteer coordinator, I want to assign a volunteer to an event or area, so that the volunteer has clear responsibilities.**

**Acceptance criteria**

* The volunteer can be assigned to an event, area, route, society, village, ward, contributor portfolio, receipt book, or collection campaign.
* The assignment includes a role and effective period (start date, optional end date).
* One volunteer can have different roles in different events, and overlapping assignments are resolved by deterministic, configurable rules per scope type.
* Assignment history (including ended/cancelled assignments) is preserved.

---

### US-011 (was US-009) — Assign Collection Responsibility

**As a volunteer coordinator, I want to assign contributors or receipt books to a collector, so that collection work is properly distributed.**

**Acceptance criteria**

* Only an active volunteer with a current event assignment and the required permission can act as a collector — volunteer type alone does not grant collection authority.
* The backend enforces that a collector can retrieve and act only on their assigned contributors and receipt books; this is a server-side authorization rule, not a client-side filter. *(Flag: the v2.1 spec defines collection-authority scoping but does not yet explicitly define read/view scoping — this should be confirmed with the backend team as a formal requirement, not left as UI-only behavior.)*
* Reassignment affects future work only.
* Previous bills and collections retain the original collector information as a frozen snapshot, unaffected by later reassignment.

---

### US-012 (was US-010) — Suspend Volunteer

**As an authorized coordinator, I want to suspend a volunteer, so that the volunteer cannot perform new activities.**

**Acceptance criteria**

* A suspension reason is required.
* A suspended (or inactive) volunteer cannot record new collections; historical records remain queryable.
* Existing assignments and collection history remain available.
* Reactivation requires both authorization and a documented reason, recorded in the audit history.

---

## Epic 4: Contributor Management

### US-013 (was US-011) — Create Contributor Account

**As a committee member, I want to register a contributor for an event, so that bills and contributions can be linked to the correct person or organization.**

**Acceptance criteria**

* The user can register an individual, family/household, shop/business, housing society, institution, sponsor, government body, or other contributor type.
* Contact, billing address, area/route/ward, language, contribution category, and billing preference (fixed, suggested, open-amount, or no-bill) can be recorded.
* Every contributor account receives a unique account code and is scoped to a specific event; the same underlying donor may hold separate contributor accounts in different events when address, category, or contact differs.
* Anonymous billing accounts are not allowed — every contributor account must reference an identified donor or organization identity.

---

### US-014 (was US-012) — Import Contributors

**As a committee member, I want to import contributors from a file, so that existing contributor records can be added quickly.**

**Acceptance criteria**

* CSV and Excel files are supported.
* The system shows valid, invalid, and duplicate rows before import.
* Invalid rows include clear error messages.
* Repeating the same import does not create duplicates (idempotent commit).

---

### US-015 (was US-013) — Assign Contributor to Collector

**As a volunteer coordinator, I want to assign contributors to a collector, so that collection responsibility is clearly defined.**

**Acceptance criteria**

* A contributor can be assigned to an active collector.
* Contributors can be assigned individually or by area.
* The backend enforces that a collector can retrieve and act only on their assigned contributor records; this is a server-side authorization rule, not a client-side filter. *(Same flag as US-011 — confirm this as a formal backend requirement.)*
* Reassignment is prospective only — it never rewrites bills already issued or collections already confirmed under the previous collector, unless an explicit unissued-bill reassignment is requested.

---

## Epic 5: Receipt Book Management

*"Pauti Pustak" literally means "receipt book" — this module models the product's core, namesake domain object and must remain a user-visible concept, not an internal implementation detail.*

### US-016 (NEW) — Create Receipt Book

**As a finance member, I want to open one or more receipt books for an event, so that receipt numbering can be organized by book and, where needed, dedicated to a specific collector.**

**Acceptance criteria**

* Multiple receipt books can be open for the same event at the same time.
* A book may optionally be assigned to a single collector or left shared.
* All books for the same event and calendar year share one atomic numbering sequence — numbers are never duplicated across books.
* Only the Owner or a user with receipt-book management permission can create or assign a book.

---

### US-017 (NEW) — Close Receipt Book

**As a finance member, I want to permanently close a receipt book, so that it can no longer be used once retired.**

**Acceptance criteria**

* Only the Owner or a user with receipt-book management permission can close a book.
* A closed book cannot allocate further numbers and cannot be reopened.
* Numbers already allocated from the book, including cancelled ones, remain permanently consumed and are never reused.
* The allocated range and usage history of the book remain viewable after closure.

---

## Epic 6: Personalized Contribution Bills

### US-018 (was US-014) — Create Personalized Bill

**As a finance member, I want to create a personalized bill for a contributor, so that the contributor receives a clear contribution request.**

**Acceptance criteria**

* The bill is linked to an event and contributor account.
* The bill can contain one or more contribution items (contribution, sponsorship, advertisement, membership, grant, or other configured category).
* The bill may have a fixed or open amount.
* A draft bill can be edited before it is issued, and can be moved to a preview state that renders a PDF preview without allocating an official bill number or creating any ledger/contribution entry — the bill only becomes financially binding once issued (see US-020).

---

### US-019 (was US-015) — Generate Bills in Bulk

**As a finance member, I want to generate bills for multiple contributors, so that large contributor groups can be billed efficiently.**

**Acceptance criteria**

* Contributors can be selected by area, route, category, collector assignment, or a validated import selection.
* The system shows the number of bills to be generated before committing, and produces a manifest of generated, skipped, and failed records afterward.
* Failed records do not stop successful bill generation.
* Repeating the same batch job (same idempotency key) does not create duplicate bills, PDFs, or deliveries.

---

### US-020 (was US-016) — Issue Bill

**As a finance member, I want to issue a bill, so that it receives an official number and can be shared with the contributor.**

**Acceptance criteria**

* A unique bill number is allocated atomically at issue time, in a format that includes organization code, event code, calendar/financial year, and sequence.
* Contributor, event, collector, template, and amount details are saved as an issue-time snapshot.
* An issued bill's financial and identity fields are immutable; cancelled bill numbers are never reused.
* Issuing a bill does not by itself create income or a ledger entry — only a confirmed payment against the bill does.

---

### US-021 (was US-017) — Share Bill

**As a committee member, I want to share a bill through WhatsApp, email, PDF, or print, so that the contributor can receive it conveniently.**

**Acceptance criteria**

* The bill can be generated in English, Marathi, Hindi, or a configured trilingual format.
* The shared bill contains a QR code or payment link that exposes no internal IDs.
* Delivery status (channel, provider message ID, actor, timestamp) is recorded.
* Failed PDF generation does not cancel the bill and can be retried.

---

### US-022 (was US-018) — Apply Bill Waiver

**As an authorized finance member, I want to apply a waiver to a bill, so that an approved reduction can be recorded properly.**

**Acceptance criteria**

* A waiver reason is required.
* Only a user with waiver permission can apply it, following the organization's configured approval requirement for waivers.
* The payable amount cannot become lower than the amount already confirmed as paid.
* The waiver is recorded in the audit history.

---

### US-023 (was US-019) — Replace Incorrect Bill

**As an authorized finance member, I want to replace a paid or partially paid bill that turns out to be incorrect, so that the correction is made without deleting the original record.**

**Acceptance criteria**

* A paid or partially paid bill cannot simply be cancelled — replacement (or closure) is the compensating workflow for this case; an unpaid issued bill is corrected via cancellation instead.
* A replacement reason is required and recorded in the audit history.
* A new bill number is generated for the replacement.
* The original bill remains visible (marked Replaced) and the original and replacement bills reference each other.

---

### US-024 (NEW) — Track Bill Payment Status

**As a finance member, I want a bill's status to update automatically as payments are confirmed, so that I always know its true payment position without manual tracking.**

**Acceptance criteria**

* An issued bill automatically moves through Partially Paid and Paid as confirmed collections are allocated against it.
* A bill becomes Overdue automatically when it passes its due date without being fully paid.
* Outstanding amount is always derived from confirmed allocations only, never from a manually entered total.
* Waived, cancelled, and replaced bills are excluded from the Overdue calculation.

---

## Epic 7: Payment Collection

### US-025 (was US-020) — Record Bill Payment

**As a collector, I want to record a payment against a bill, so that the contributor's payment can be verified.**

**Acceptance criteria**

* The payment is linked to the contributor, event, and bill.
* Cash, UPI, bank transfer, cheque, Razorpay, card, and other modes are supported.
* The collector can enter the amount, date, reference, and notes.
* The payment cannot exceed the outstanding bill amount (open-amount bills accept any positive configured amount).

---

### US-026 (was US-021) — Record Direct Contribution

**As a collector, I want to record a contribution without a bill, so that voluntary contributions can also be managed.**

**Acceptance criteria**

* The contribution is linked to an identified contributor and event.
* A bill is not required.
* The payment mode and amount are recorded.
* The contribution remains pending until verified when required by the payment mode.

---

### US-027 (was US-022) — Verify Manual Payment

**As a treasurer, I want to verify a manually recorded payment, so that only valid collections affect financial records.**

**Acceptance criteria**

* The treasurer can confirm or reject a pending payment (unless organization policy permits trusted-collector auto-confirmation below a configured threshold).
* Rejection requires a reason.
* A confirmed payment updates the bill balance.
* A confirmed payment generates exactly one contribution allocation and exactly one receipt, keyed to the collection record so retries cannot duplicate either.

---

### US-028 (was US-023) — Process Cheque Payment

**As a treasurer, I want cheque payments to remain pending until they clear, so that uncleared funds are not treated as income.**

**Acceptance criteria**

* A cheque payment enters Pending Clearance status.
* No receipt or positive ledger entry is generated before clearance.
* The cheque can be marked as cleared or bounced; a bounce preserves the original evidence and updates status.
* A bounced cheque does not increase confirmed contribution totals.

---

### US-029 (was US-024) — Accept Online Payment

**As a contributor, I want to pay a bill online, so that I can complete my contribution conveniently.**

**Acceptance criteria**

* The contributor can open a secure payment page.
* The payment amount is linked to the correct bill.
* The bill is updated only after signed server-side verification or a verified webhook — a frontend success message alone never confirms a collection.
* Duplicate payment confirmations (retries or webhook replay) do not create duplicate records.

---

### US-030 (was US-025) — Make Partial Payment

**As a contributor, I want to pay a bill in installments, so that I can complete the contribution over time.**

**Acceptance criteria**

* Partial payments are allowed unless disabled by bill policy.
* Each confirmed payment reduces the outstanding amount, which is derived from confirmed allocations only.
* Each confirmed payment generates a separate receipt.
* The outstanding balance cannot become negative; overpayment is rejected by default unless the contributor explicitly confirms a separate direct contribution for the excess.

---

### US-031 (was US-026) — Settle Collector Cash

**As a collector, I want to submit my collected cash to the treasurer, so that my daily collections can be reconciled.**

**Acceptance criteria**

* The system calculates the expected cash amount from confirmed cash collections, less approved refunds and prior handovers.
* The collector enters the amount handed over.
* The system calculates any difference.
* A difference requires a reason and approval; settlement transfers custody between accounts and never duplicates ledger income.

---

## Epic 8: Contributions

### US-032 (was US-027) — Maintain Contribution Record

**As a treasurer, I want every confirmed payment stored as a contribution record, so that all event income can be tracked consistently.**

**Acceptance criteria**

* Bill-linked collections, direct contributions, sponsorships, advertisements, memberships, and grants are all supported source types.
* Confirmed totals are calculated by the system as the sum of confirmed, non-cancelled allocations less successful refunds — no client-submitted total is accepted.
* One confirmed collection allocation belongs to exactly one contribution record and increments its confirmed amount exactly once.
* Contributor privacy settings are respected in any downstream display.

---

### US-033 (was US-028) — Cancel Unconfirmed Contribution

**As an authorized finance member, I want to cancel an unconfirmed contribution, so that incorrect pending records do not remain active.**

**Acceptance criteria**

* Only an unconfirmed contribution can be cancelled directly; confirmed financial movements are corrected only with compensating entries, never by mutating the original.
* A cancellation reason is required.
* The original record remains available.
* Cancellation does not create a receipt or a ledger income entry.

---

### US-034 (was US-029) — Refund Eligible Payment

**As an authorized finance member, I want to refund an eligible online payment, so that duplicate or incorrect payments can be corrected.**

**Acceptance criteria**

* Manual (cash/UPI/cheque/bank/card-in-person) confirmed collections are non-refundable by default; only eligible online payments follow the refund workflow.
* The refund cannot exceed the confirmed payment amount, and the original payment record remains unchanged.
* The refund is linked to the original contribution.
* Receipt status updates to Partially Refunded or Refunded, and financial status is updated accordingly.

---

## Epic 9: Contribution Receipts

### US-035 (was US-030) — Generate Receipt

**As a contributor, I want a receipt for every confirmed payment, so that I have proof of my contribution.**

**Acceptance criteria**

* One receipt is generated for each confirmed collection allocation (partial payments generate separate receipt numbers).
* Each receipt has a unique number, allocated atomically within the event-year sequence.
* The receipt shows the current payment amount, cumulative confirmed amount, and remaining bill balance at issue time.
* Receipt information cannot be edited after issue.

---

### US-036 (was US-031) — Download Receipt

**As a contributor, I want to download my receipt, so that I can keep a copy for my records.**

**Acceptance criteria**

* The contributor can access the correct receipt.
* The receipt is available as a PDF.
* The download link expires after a configured period.
* Private information from other contributors is not visible.

---

### US-037 (was US-032) — Share Receipt

**As a contributor or committee member, I want to share a receipt through WhatsApp or email, so that it can be delivered conveniently.**

**Acceptance criteria**

* The receipt can be shared using an approved channel.
* Delivery status is recorded and audited.
* The shared document matches the issued receipt exactly (immutable PDF or short-lived signed URL).
* Sharing failure does not affect the confirmed payment.

---

### US-038 (was US-033) — Verify Receipt

**As a contributor or auditor, I want to verify a receipt using its QR code, so that I can confirm that it is genuine.**

**Acceptance criteria**

* The QR code opens a verification page.
* The page displays only safe receipt information.
* Invalid, cancelled, partially refunded, or refunded receipts show the correct status.
* Private contact details are never displayed.

---

### US-039 (was US-034) — Replace Receipt

**As an authorized finance member, I want to replace an incorrect receipt, so that the correction remains fully traceable.**

**Acceptance criteria**

* A replacement reason is required, in addition to the separate approval and reason already required for the underlying cancellation.
* The original receipt is not deleted and remains accessible with its original PDF.
* A new receipt number is generated for the replacement.
* Both receipts reference each other.

---

## Epic 10: Vendors, Expense Policy, and Expenses

### US-040 (NEW) — Register Vendor

**As a finance member, I want to register a vendor, so that expenses can be correctly attributed and paid.**

**Acceptance criteria**

* The user can enter vendor name, contact, address, and optional tax and bank details.
* Every expense must reference an active vendor — vendor-less expenses are rejected.
* Duplicate vendors are detected by normalized name, mobile, tax ID, and bank fingerprint within the organization.
* Bank and tax identifiers are encrypted and shown only in masked form, including to platform-level administrators.

---

### US-041 (NEW) — Deactivate Vendor

**As a finance member, I want to deactivate a vendor instead of deleting it, so that historical expenses remain intact.**

**Acceptance criteria**

* A referenced vendor is soft-deactivated, never deleted.
* Approved expenses keep a frozen vendor snapshot that is unaffected by later vendor edits or deactivation.
* A deactivated vendor cannot be selected for new expenses.
* A deactivated vendor can be reactivated by an authorized user.

---

### US-042 (NEW) — Configure Expense Approval Policy

**As an organization owner, I want to configure expense approval thresholds, so that higher-value expenses always receive the right level of scrutiny.**

**Acceptance criteria**

* The owner can define amount bands with a required number of distinct approvals per band (default: up to ₹5,000 needs one approval; ₹5,001–₹25,000 needs two distinct approvals; above ₹25,000 needs two distinct approvals including the Owner or Treasurer).
* Only the Owner can create or activate a policy version; once activated, that version is immutable — changes create a new version with its own effective period.
* An expense submission freezes the currently active policy's band and required approvals as a permanent snapshot; later policy changes never alter an already-submitted expense.
* There is no emergency override or bypass of the configured approval requirement.

---

### US-043 (was US-035) — Record Expense

**As a finance member, I want to record an event expense, so that event spending can be tracked.**

**Acceptance criteria**

* The expense includes vendor, category, date, description, base amount, and tax amount.
* A bill or signed internal voucher is attached.
* The expense is linked to an event.
* A draft expense can be edited before submission; submission freezes its business fields and the applicable approval-policy snapshot.

---

### US-044 (was US-036) — Approve Expense

**As an expense approver, I want to approve or reject a submitted expense, so that only valid expenses are paid.**

**Acceptance criteria**

* Only authorized users can approve or reject, following the number and sequence of approvals frozen at submission time; later approval steps cannot be completed before earlier ones.
* The submitter cannot approve their own expense, and no single user can satisfy more than one required approval level — including the Owner, who cannot bypass this.
* Rejection requires a reason.
* A submitted expense's business fields cannot be silently changed.

---

### US-045 (was US-037) — Pay Expense

**As a treasurer, I want to record full or partial expense payments, so that outstanding liabilities remain accurate.**

**Acceptance criteria**

* Payment cannot exceed the approved outstanding amount, and cumulative payments cannot exceed the approved amount.
* Partial payments are supported.
* The outstanding amount is updated after each payment.
* Once fully paid, an expense cannot be edited or reversed — any correction is made through a linked compensating credit/adjustment, not by mutating the paid expense.

---

## Epic 11: Reports and Transparency

### US-046 (was US-038) — View Financial Dashboard

**As an organization owner, I want to view an event financial dashboard, so that I can understand the event's financial position.**

**Acceptance criteria**

* The dashboard shows confirmed contributions.
* It shows paid and outstanding bills.
* It shows expenses and outstanding liabilities.
* Available balance and projected balance are displayed separately.

---

### US-047 (was US-039) — View Collector Performance

**As a volunteer coordinator, I want to view collector performance, so that collection progress can be monitored.**

**Acceptance criteria**

* The report shows assigned contributors and bills.
* It shows confirmed collections and pending verification.
* It shows settled cash and differences.
* Performance totals are calculated only from confirmed collections and reconciled settlements — manually entered performance totals are not permitted.

---

### US-048 (was US-040) — Export Reports

**As an owner, treasurer, or auditor, I want to export financial reports, so that records can be reviewed or shared outside the system.**

**Acceptance criteria**

* Reports can be exported as PDF, Excel, or CSV.
* Users can apply event and date filters.
* Large reports are processed in the background.
* Unauthorized personal information is excluded.

---

### US-049 (was US-041) — Publish Public Summary

**As an organization owner, I want to publish an approved event summary, so that the public can see transparent financial information.**

**Acceptance criteria**

* Public sharing must be enabled and published by an authorized user; after financial closure, publishing the final snapshot additionally requires admin approval.
* Only approved information is displayed, as an immutable, versioned snapshot — a published snapshot can never be edited or deleted, only superseded by a new version.
* Contributor privacy preferences are respected — a contributor's Private selection cannot be overridden by the organization.
* Private contact and payment details, internal IDs, and original (non-redacted) vouchers are always hidden.

---

## Epic 12: Audit and Security

### US-050 (was US-042) — View Audit History

**As an auditor, I want to view the history of important actions, so that changes and financial activities can be reviewed.**

**Acceptance criteria**

* The history shows the user, action, date, and affected record.
* Reasons are shown for approvals, rejection, suspension, cancellation, waiver, and replacement.
* Audit records cannot be edited or deleted.
* Access is limited to authorized users (Owner, Auditor).

---

### US-051 (was US-043) — Protect Organization Data

**As an organization owner, I want my organization's information kept separate from other organizations, so that unauthorized users cannot access it.**

**Acceptance criteria**

* Users can access only their active organization.
* Records from another organization are not returned, including on direct ID lookup (no existence leakage via 403/404 responses).
* Files and reports are organization-specific.
* Cross-organization access attempts are rejected.

---

### US-052 (was US-044) — Prevent Duplicate Transactions

**As a treasurer, I want repeated requests to be handled safely, so that payments, contributions, and receipts are not duplicated.**

**Acceptance criteria**

* Repeating the same payment request creates only one payment record.
* Repeated online payment notifications (webhook replay) do not create duplicate receipts.
* Retried background jobs do not generate duplicate documents.
* Financial totals remain unchanged after duplicate requests.

---

## Story-writing standard for the project

Every future Pauti Pustak story should follow this structure:

> **As a [user], I want [need], so that [value].**

Each story should:

* Describe one user need.
* Remain independent wherever practical.
* Avoid database, API, framework, queue, or architecture details.
* Include clear and measurable acceptance criteria.
* Use business language understood by clients, developers, and testers.
* Be small enough to complete within one sprint or be split further.
