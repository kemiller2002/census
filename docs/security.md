# Security gates

1. Public source is permitted; protect secrets, production data, deployment identities and build artifacts. Do not rely on code secrecy.
2. Verify Fides trust model, identity provider and MFA; fail closed.
3. Verify Strata/PostgreSQL migration behavior and Arca compatibility.
4. Implement entity-scoped authorization in database queries and API.
5. Encrypt all provider tokens using AWS-managed secrets, never log them.
6. Authenticate Plaid webhooks, deduplicate and replay safely.
7. Use PostgreSQL constraints plus transactional posting for ledger invariants.
8. Enforce TLS, restrictive CORS/CSP, CSRF defenses and secure cookies.
9. Validate backups by restoring to isolated infrastructure.
10. Block production release until threat model, audit evidence and privacy review pass.
