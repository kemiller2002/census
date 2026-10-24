# CEN-060: Mandatory function-only PostgreSQL access boundary

**Status:** normative P0 requirements. No implementation, ingestion or testing is claimed.
**Decision:** Census has **zero direct table access** from any application runtime identity, including API, background workers, reporting, export, maintenance jobs, and local-development runtime services. All runtime data operations must use individually allowlisted PostgreSQL functions. No exception for read-only queries, materialized views, direct ORM access, or ad hoc SQL.

## 1. Database architecture and trust
- All application base tables, partitions, sequences and private views reside in `census_private`; private authorization helpers reside in `census_security`. The sole runtime callable surface is reviewed functions in `census_api`.
- `census_owner` is NOLOGIN and owns objects; a separate tightly controlled migration identity may perform schema changes only during a privileged deployment step. Runtime identities are distinct for API and worker; neither is a member of owner/migration roles or can SET ROLE to them.
- Runtime identities receive only CONNECT on the Census database, USAGE on `census_api`, and EXECUTE on an explicit per-signature function allowlist. No runtime privileges on tables, partitions, sequences, views, materialized views, foreign tables, private schemas, public schema CREATE, or unapproved routines. This includes SELECT. Database catalog/system introspection allowed by PostgreSQL must not expose protected financial data.
- No runtime superuser, BYPASSRLS, CREATEDB, CREATEROLE, REPLICATION, ownership, SECURITY DEFINER creation, arbitrary schema CREATE, or extension installation. Migration credentials are never available to the running API or worker.
- Database permissions, not application coding conventions, enforce this boundary. An API/worker credential used with a generic SQL client must still be unable to access private data directly.

## 2. Functions are the complete application data API
- Each public function has a versioned contract: schema, name, argument names/types, return type, authorized caller role, principal/tenant authorization source, allowed state transitions, max rows, sort/pagination, idempotency, concurrency, audit, errors, and side effects.
- Functions must not accept arbitrary SQL, table/column names, untrusted SQL fragments, caller-selected schema names or unrestricted JSON predicates. No generic `execute_sql`, `query_table`, `run_report_sql`, or dynamic database gateway.
- Read functions return only explicit, minimal columns. Never `SELECT *` into public return contracts. Every list operation has bounded pagination, stable ordering and entity scoping; export uses separately approved bounded routines.
- Write functions enforce database invariants atomically. Ledger posting, reversals, closed-period protections, reconciliation close and Plaid cursor advancement must not be split across separately committed client calls.
- Each function's EXECUTE grant is explicit for the exact signature and exact runtime role. Revocation is the default for PUBLIC and all other roles. Adding a new function does not implicitly expose it.

## 3. Security-definer rules
- Use SECURITY DEFINER only where required to cross the private-table privilege boundary. Functions are owned by a dedicated NOLOGIN owner with the narrowest privileges practical. Where ownership would bypass RLS, explicitly enforce tenant membership in function logic and/or use an independently proven RLS design; never claim RLS protects a table-owner function by default.
- Pin safe search_path in each SECURITY DEFINER function, use schema-qualified references and trusted extensions only, reject caller-controlled object resolution, and avoid unsafe dynamic SQL.
- Revoke default PUBLIC EXECUTE globally for every role that creates functions, not only schema-scoped defaults. Independently enumerate effective ACLs, inherited privileges, routine owners and default privileges.
- No runtime identity can CREATE OR REPLACE, ALTER, DROP, grant privileges on, or take ownership of callable functions.

## 4. Identity and tenant proof
- Fides establishes an authenticated principal; API checks membership and permission for each operation. Database routines independently verify entity/resource scope using a concrete trusted design approved before implementation.
- Caller-controlled `app.principal_id`, `SET LOCAL` custom GUC, request headers, tenant IDs, session variables and client-provided role claims are not authoritative identity proof. A compromised runtime credential must not gain another tenant's records merely by changing any of them.
- Choose and document a tamper-resistant authorization design, e.g. distinct restricted per-tenant database principals, or a DB-verifiable signed short-lived assertion bound to principal, entity, function, operation and expiration, with independently protected signing key and replay protections. Evaluate the actual threat model and operational complexity before selecting; until selected, tenant isolation is **BLOCKED**.
- Every function checks all nested resource IDs against the authorized entity and denies ambiguous ownership, revoked membership, invalid state and mismatched entity context. Worker service identities have separate limited capabilities and cannot impersonate end users.

## 5. Connection pool, errors and logs
- Pools must not carry authentication, role, search_path or tenant context across requests. No connection is returned to the pool after a failed transaction until reset/rollback.
- Avoid leakage through errors, function volatility, timing-sensitive search paths, log statements, EXPLAIN, debug endpoints, temporary tables, generated exports or provider payloads. Secrets and sensitive data must never appear in logs, traces, CI artifacts or public bundles.
- Production DB is private network-only; public network access, broad security-group ingress and unrestricted database admin endpoints are prohibited.

## 6. Required function catalog before development
Create `docs/database-function-contracts.md` with a row for each function and its exact PostgreSQL signature. Minimum families:
- Identity/entity: get_current_principal, list_authorized_entities, list_members, invite_member, change_member_role, revoke_member.
- Chart/period: list_accounts, create_account, update_account, list_periods, close_period, reopen_period.
- Journal: list_entries, get_entry, create_draft, replace_draft_lines, post_entry, reverse_entry.
- Provider: create_connection, list_connections, list_external_accounts, stage_sync_batch, finalize_sync_cursor, disconnect_connection.
- Classification: list_observations, get_observation, list_rules, save_rule, classify_observation.
- Reconciliation: list_reconciliations, propose_match, confirm_match, close_reconciliation, reopen_reconciliation.
- Reporting/audit: balance_sheet, income_statement, cash_flow, spend_summary, export_snapshot, list_audit_events.
Function names are provisional until exact signatures and role matrix are documented. No function may be granted merely because it belongs to one of these families.

## 7. Nonnegotiable acceptance criteria
- **DB-01** Runtime API role cannot SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES or TRIGGER any private relation, including through inherited roles, PUBLIC, views or sequences.
- **DB-02** Runtime worker role meets the same restrictions, with only its distinct approved function grants.
- **DB-03** Neither role can CREATE, ALTER, DROP, GRANT, SET ROLE into elevated identity, bypass RLS or modify function definitions.
- **DB-04** PUBLIC and anonymous/unapproved database principals cannot execute Census functions; defaults remain restrictive for newly created routines.
- **DB-05** Approved functions work only for their exact granted signatures; an added overload is inaccessible by default.
- **DB-06** Every function denies cross-entity root IDs and nested IDs, revoked members, unauthorized roles and stale sessions.
- **DB-07** Forged principal/session GUC, malicious search_path, injected identifiers and arbitrary SQL parameters do not widen access.
- **DB-08** Concurrent posting, reversal, period closing, matching and cursor updates preserve invariants and idempotency.
- **DB-09** Production runtime cannot connect using owner/migration credentials; rotation and revocation are demonstrated.
- **DB-10** Independent PostgreSQL catalog inspection validates effective privileges, PUBLIC/default grants, routine signatures, owners, RLS settings and role membership, including unmanaged drift that Strata may not compare.
- **DB-11** Fresh install and upgrade have identical effective runtime grants; a new unreviewed function is not callable.
- **DB-12** A generic SQL client authenticated as either runtime role can execute only approved Census API routines, never retrieve or mutate private data by direct relation access.
- Any failure, skipped test, unsupported Strata comparison or unresolved tenant-identity design blocks release. Requirements drafting does not imply any test has passed.

## 8. Explicit scope boundary
- This rule governs **application runtime identities**. The migration/owner authority must retain controlled DDL capabilities to build and maintain the schema; such authority is isolated from application execution and audited.
- Existing CEN-030, 033, 034, 051 and 055 remain applicable; where ambiguous, this P0 requirement is stricter and takes precedence.
