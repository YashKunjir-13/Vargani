# Official Document Boundaries

## Backend-owned

- Bill and receipt number allocation
- Immutable issue-time snapshots
- Official PDF rendering
- Verification QR tokens
- Authorized signatures or seals
- Private storage metadata and signed URL issuance

## Client-owned

- Preview, download, print, and share
- Temporary caching under policy
- Optional unofficial offline draft clearly watermarked

## Security

No S3 secret is ever embedded in Flutter. Signed URLs are short-lived and not treated as permanent identifiers.
