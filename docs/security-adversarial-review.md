# Census adversarial requirements security review
Date: 2026-10-23
Scope: committed Census requirements and architecture documents, not source-code penetration testing.
Verdict: NOT READY FOR PRODUCTION. Requirements-only threat assessment; exploitability unverified.

## Critical
SEC-01 Cross-entity authorization: entity_id in route is untrusted. Every query, join, background job, export, audit, websocket (if introduced) and object-store reference must be scoped by authenticated principal's membership and operation permission; use entity-aware composite FKs and negative tests. Test guessing IDs and swapping nested account IDs.
SEC-02 Ledger integrity: DB role with direct UPDATE/DELETE on posted journal defeats application immutability. Posting must be DB-enforced atomic and serializable/locked, with deferrable balance checks or trusted posting routine, least-privileged roles, closed period enforcement and reversal-only correction. Test races, privilege bypass, cross-entity lines, overflow, and negative money.
SEC-03 Auth/session boundary: Fides GitHub login does not itself grant Census access. Define issuer/audience/nonce/state/PKCE where applicable, callback allowlist, session rotation, revocation, idle/absolute expiry, CSRF, MFA policy, role-change invalidation, and account recovery. No silent fallback to dev auth.
SEC-04 CI/CD trust: untrusted PRs must never receive OIDC deploy permission or secrets. Pin third-party actions to immutable SHAs, restrict workflow permissions, protect environments with approvals, constrain OIDC trust to repo/ref/environment, prevent workflow artifact poisoning and release substitution, verify provenance and package hashes.

## High
SEC-05 Plaid webhook verification: require exact documented provider verification including raw body/signature/JWT and key rotation as appropriate, bounded freshness, event replay dedup, rate limits, body limits, and queued processing. Do not rely on webhook alone as ledger authority.
SEC-06 Plaid sync cursor atomicity: pagination, modifications, removals, pending-to-posted and crash recovery must be transactionally correct; no cursor advancement before durable observations; idempotent retries and concurrency locking; never auto-post ambiguous events.
SEC-07 Sensitive data: define field-level classification, encryption/key management, token isolation, redaction for error/telemetry/audit/exports, retention, backups, and deletion policy. Merchant descriptions can reveal sensitive personal information. No client storage/service-worker caching of financial payloads.
SEC-08 Public frontend boundary: same-origin routing must not allow cache poisoning or CDN caching of private API responses. Define Cache-Control no-store, CDN bypass for /api, CSP, HSTS, content-type hardening, no secrets in JS/WASM/source maps, strict redirect allowlist.
SEC-09 Database network and roles: private PostgreSQL, TLS certificate verification, runtime DB role without DDL/bypassrls/superuser, migration role isolated, per-entity enforcement and tested pool context reset if RLS is used. No publicly reachable DB.
SEC-10 Local dev guard: development Fides substitute and fake Plaid must be impossible in production through build-time + runtime checks; local Docker credentials localhost-only, synthetic seed only, no real data in fixtures, no destructive clean by default.
SEC-11 Supply chain: verify Echelon release compatibility, signatures/checksums, licensing and immutable pins; Strata pilot's not-compared/unverifiable statuses block unattended deploy, migration dry runs must not be interpreted as complete security verification.
SEC-12 Exports and reports: every download is entity-scoped, reauthorized, audited, non-cacheable; protect against CSV formula injection and unsafe document rendering; exports have bounded size and expiry.

## Medium
SEC-13 Brute force, resource exhaustion and abuse: rate limits by actor/entity/provider/IP, pagination limits, queue backpressure, webhook flooding and circuit breakers.
SEC-14 Financial rule manipulation: classification predicates/actions are typed validated data, not arbitrary executable SQL or expressions; approval for material auto-post rules and audit rule changes.
SEC-15 Security observability: tamper-evident audit export, alert on privilege/role/connection changes, suspicious access and large exports; minimize logged personal financial data.
SEC-16 Recovery: tested point-in-time restore and ledger reconciliation, incident key rotation, revocation, and evidence preservation; restore must not replay Plaid effects or send alerts to users unintentionally.
SEC-17 Threat-driven UI: require reauthentication or step-up for sensitive actions (new connection, export, role changes), confirm account scope, clear entity-specific in-memory state on switch, prevent clickjacking and XSS.
SEC-18 Privacy and consent: clarify data ownership, institution connection consent, third-party processors, per-entity data retention and account disconnect semantics.

## Contradictions to resolve
- requirements/infrastructure-security.md CEN-014 and docs/security.md mandate private source, while docs/three-tier-contract.md permits public source. Correct policy: public source allowed, no secrets or real financial data in repository or artifacts.
- docs/database-schema.md describes append-only ledger but does not define executable role/trigger enforcement.
- Fides deployment not established; do not equate integration requirement with a running identity service.
- Strata is pilot; schema convergence cannot imply security verification when objects are unmodelled or unverified.

## Mandatory adversarial acceptance suite
A01 anonymous requests denied; A02 entity-ID substitution on every endpoint; A03 nested foreign entity ID; A04 revoked/expired session; A05 role downgrade during active session; A06 forged/replayed Plaid webhook; A07 sync interruption between pages and cursor commit; A08 duplicate concurrent posting; A09 direct SQL mutation of posted journal by runtime role denied; A10 unbalanced/mixed-entity/mixed-currency posting denied; A11 dev-auth configuration rejected in production; A12 untrusted PR cannot assume AWS deploy role; A13 financial response never cached by CDN/browser SW; A14 XSS and CSRF attempts; A15 report export formula injection; A16 backup restore and integrity reconciliation; A17 secret leak scan of built WASM/assets/logs; A18 Strata unknown/uncompared migration fails release gate.

## Gate
Block production until each critical/high issue is expressed as executable acceptance criteria, reviewed and supported by passing tests. Mark untested controls BLOCKED/NOT VERIFIED, never PASS.
