# CEN-043..047 Plaid synchronization, privacy and lifecycle
Status: normative; provider contract verification required before implementation.

## CEN-043 Connection lifecycle
- States initiated -> authorized -> active -> reauth-required/suspended -> disconnected; explicit invalid transitions and compensating actions. Link tokens created server-side for authorized entity, public-token exchange only on backend, provider tokens held in Secrets Manager/encrypted references. Connection account ownership must be reviewed and mapping approved before posting.
- Disconnection revokes provider access where supported, halts jobs, preserves required immutable accounting history and schedules deletion of eligible raw observations under policy; never silently delete posted journals.

## CEN-044 Webhook and ingestion trust
- Verify Plaid's current documented signature/JWT mechanism, key rotation and replay/freshness semantics against provider docs during implementation. Preserve raw request bytes for verification without logging sensitive payloads; reject invalid/oversized requests and queue only authenticated events.
- Webhook is a signal to synchronize, not a trusted financial posting command. Deduplicate event deliveries; limit per-connection concurrency; implement bounded retries, exponential backoff, dead-letter queue and operator replay.

## CEN-045 Cursor and observation consistency
- Fetch complete paginated changes and apply additions/modifications/removals atomically with durable cursor checkpoint. If a provider invalidates pagination, restart from prior stable cursor per provider contract. Never commit cursor ahead of observations.
- Immutable observation revisions keyed by provider connection, account, transaction ID and revision; link pending -> posted; preserve removed/replaced history. Do not infer uniqueness from description/amount/date alone. Manual classifications survive resync with explicit conflict resolution.
- Test crash after page 1, redelivery, reordering, cursor invalidation, concurrent worker, account reconnect, removal, pending-posted and partial outage. Reconcile coverage and freshness before financial claims.

## CEN-046 Data classification and retention
- Classify tokens, account identifiers, merchant narratives, transaction records, reports and audit metadata. Encrypt at rest and in transit; limit decrypted exposure and secrets access. Define per-category retention windows before production, including audit, immutable ledger, raw payloads, backups and export artifacts; distinguish legal preservation from deletion eligibility.
- Explicit consent for bank linking and disclosures of third-party processors; provide entity-scoped export, disconnect and deletion workflows. Purge temporary exports and caches; backup deletion limitations must be disclosed. Never put financial payloads in telemetry, browser localStorage, IndexedDB, service worker or static artifacts by default.

## CEN-047 Operational recovery
- Scheduled catch-up independent of webhooks, sync gap alarms, account health, alert deduplication and dead-letter recovery. Restore drill includes journal totals, tenant isolation and prevention of duplicate external side effects after restore. Record runbook and incident severity.
- Acceptance: deterministic fake provider, sandbox contract suite, fault injection and privacy scanning of artifacts/logs.
