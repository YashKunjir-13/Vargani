# Initial Domain Event Catalogue

- OrganizationRegistered
- MembershipChanged
- EventActivated
- EventClosed
- VolunteerAssigned
- ContributorCreated
- ContributionBillIssued
- CollectionRecorded
- CollectionConfirmed
- ChequeCleared
- ContributionConfirmed
- ReceiptAllocated
- ReceiptGenerated
- ExpenseApproved
- ExpensePaid
- LedgerEntryPosted
- CollectorSettlementSubmitted
- CollectorSettlementApproved
- DocumentGenerated
- NotificationDeliveryUpdated

Each event requires an owner, schema version, idempotency key, tenant context, timestamp, correlation/causation IDs, retention policy, and consumer list.
