# Webhook Standards

- Verify provider signatures before parsing trusted business meaning.
- Persist receipt of the webhook before asynchronous processing where necessary.
- Deduplicate by provider event ID and business idempotency key.
- Return provider-appropriate acknowledgement quickly.
- Reconcile provider truth independently of webhook delivery.
- Redact signatures and sensitive payloads from logs.
- Support replay testing and dead-letter recovery.
