# Census three-tier architecture decision (proposed baseline)

## Tier boundaries
1. Presentation: Limen WASM + Forma, public static assets and accessible HTML loading shell. Browser has no database credentials, provider access tokens, or privileged AWS access. Authentication uses server-validated session and same-origin BFF API.
2. Application: F#/.NET modular monolith API and background ingestion worker. Fides identity adapter, authorization, Plaid provider adapter, posting/reconciliation, analysis and reports. API is the only browser-accessible data boundary.
3. Data: private RDS PostgreSQL; Strata migrations where verified; Arca persistence where verified. No browser SQL, PostgREST, direct database access, or DB port exposed publicly.

## Deployment
CloudFront + S3 for immutable UI assets; /api/* routed to API origin with TLS, secure HttpOnly SameSite cookies, CSRF protections, strict origin checks, CORS same-origin. Backend compute in private networking where possible, public entry only through load balancer/API gateway. DB private subnet, no public IP. Plaid webhooks hit narrowly scoped public API endpoint and are verified before enqueue. Separate worker drains queue. GitHub Actions OIDC assumes narrowly scoped AWS roles; AWS Secrets Manager stores runtime secrets. Public source is permitted; secret scanning and build-artifact scanning mandatory.

## Authorization
Fides or an external OIDC identity provider establishes identity; Census enforces all per-entity permissions on every operation. Roles: owner, administrator, accountant, viewer. Permission policy: viewer read-only reports/accounts; accountant classify/reconcile/post subject to period controls; administrator manage connections and members; owner all including ownership changes. Never trust role/entity identifiers sent by client without membership lookup.

## API v1
All responses JSON; UTC ISO-8601 timestamps, integer minor-unit money plus ISO currency, opaque UUIDs, cursor pagination, RFC7807 problem responses, correlation ID, idempotency key on mutating financial operations.
- GET /api/v1/session -> identity and entity memberships
- GET /api/v1/entities -> authorized entities
- GET /api/v1/entities/{entityId}/accounts
- GET /api/v1/entities/{entityId}/transactions?cursor=&limit=&from=&to=&status=
- GET /api/v1/entities/{entityId}/journal?cursor=&limit=
- POST /api/v1/entities/{entityId}/journal -> draft; POST .../journal/{entryId}/post -> atomic balanced posting
- POST /api/v1/entities/{entityId}/journal/{entryId}/reverse -> compensating entry
- GET /api/v1/entities/{entityId}/reconciliations; POST .../reconciliations/{id}/close
- GET /api/v1/entities/{entityId}/exceptions; PATCH .../exceptions/{id} -> review decision
- GET /api/v1/entities/{entityId}/reports/{kind}?asOf=
- POST /api/v1/entities/{entityId}/connections/plaid/link-token
- POST /api/v1/entities/{entityId}/connections/plaid/exchange
- POST /api/v1/webhooks/plaid (provider-authenticated, no user session)
- GET /api/v1/health/live; GET /api/v1/health/ready (minimal information)
All entity endpoints enforce entity membership and operation permissions. Sensitive API responses Cache-Control: no-store.

## Transaction model
An external transaction is an observation; classification produces a proposal; approval/auto-posting under explicit rules produces an immutable journal entry. API never accepts client-supplied ledger balance as authority. Optimistic concurrency for review states; all postings in database transactions.

## Release gates
Open source permitted, but secret scans, SBOM, signed artifacts, branch protections, reviewed CI, restricted GitHub environments, no credentials in logs, least privilege, tested backups, dependency review, Fides trust verification and Strata compatibility are mandatory.
