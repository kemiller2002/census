# CEN-030: Critical database privilege and boundary enforcement

Priority P0, BLOCKS any production deployment. Status: requirements specified, not implemented or tested. Source: adversarial review SEC-01..SEC-04 and verified Strata README PostgreSQL 16 coverage.

## Architecture
Schemas: `census_private` (all base tables), `census_api` (approved routines), `census_security` (internal authorization helpers), and `census_migration` as appropriate. Runtime API and worker connect with distinct LOGIN roles, neither owns tables, can CREATE, has BYPASSRLS, is SUPERUSER or can SET ROLE to migration/owner. Browser never connects to DB. Runtime has no USAGE on private schema, no SELECT/INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER on base tables, no CREATE on public or api schema. Grant only USAGE on api schema and EXECUTE on a named allowlist of routines, never blanket EXECUTE ON ALL FUNCTIONS. REVOKE PUBLIC EXECUTE on all sensitive functions and ALTER DEFAULT PRIVILEGES for each owning role; remove PUBLIC CREATE on public schema. Isolate DB owners, migration and backup roles.

## Stored routine rules
Only vetted SECURITY DEFINER functions/procedures, owned by a NOLOGIN owner distinct from runtime, can access private tables. Every SECURITY DEFINER routine SET search_path = pg_catalog, pg_temp (or trusted schema with fully qualified references), qualify all objects and operators where needed, prohibit unsafe dynamic SQL, validate argument sizes/types, enforce authorization and rate/complexity bounds. Security helpers and owner routines must not be executable by PUBLIC. Review role inheritance and default privileges. Test SECURITY DEFINER search_path/object-shadowing attacks. Consider `security_invoker` where suitable; no direct table grants to runtime.

## Identity and tenant scope
The API must establish verified session principal on the server, never trust caller-supplied principal or entity claims. Routines must not accept a user-selected principal as authority. Database connection-pool principal propagation requires a tamper-resistant mechanism: preferred per-request transaction with server-controlled context and DB privileges that prevent caller spoofing; if that cannot be proven, use separate trusted backend authorization combined with narrow routines and explicit RLS defense in depth, and document residual risk. Do not assume `SET LOCAL app.principal_id` alone is secure against a compromised runtime connection; arbitrary custom GUCs can be set by the connected role. Every entity and nested object lookup must enforce membership/role and entity-aware FK, including worker jobs and exports. Membership revocation applies immediately on next operation.

## Ledger
Post, reverse, close-period and account mapping only through authorized routines with explicit transaction boundaries and locking; database enforces balanced multi-line journal per currency, >=2 lines, same entity, immutability of posted rows, period status and idempotency under concurrency. Reject overflow, duplicate source events, stale revisions, and direct runtime table mutations. Audit permission changes and privileged operations.

## Strata ownership
Strata deploys/reconciles SQL objects; PostgreSQL enforces GRANT/REVOKE/RLS and routines. Strata README documents create/compare for functions/procedures, triggers, grants and RLS policies on PG16, BUT grant comparison only covers declared grantees; undeclared grants are untouched. Therefore Strata clean plan is insufficient: separately inspect pg_catalog for effective privileges, role memberships, default privileges, PUBLIC grants, RLS state, routine SECURITY DEFINER/search_path and owners. Treat not-compared/not-modelled/unverifiable as security gate failures on critical objects. Routine signature/return changes with identical body may escape drift comparison; compare pg_proc signatures explicitly.

## CI acceptance (required executable PostgreSQL 16 tests)
DB-01 runtime role SELECT/INSERT/UPDATE/DELETE/TRUNCATE on every private table denied.
DB-02 runtime CREATE schema/table/function and ALTER/DROP denied.
DB-03 runtime EXECUTE on non-allowlisted private/security functions denied; PUBLIC execution denied.
DB-04 approved API function works with valid authenticated scope; cross-entity and nested-ID substitution denied.
DB-05 role downgrade, membership revoke and expired session deny subsequent actions.
DB-06 concurrent duplicate/unbalanced posting and direct posted-row mutation denied; period close races denied.
DB-07 SET search_path, temp object shadowing, malicious GUC/principal substitution cannot cross entities.
DB-08 undeclared grantee, role inheritance, PUBLIC default privilege and default function EXECUTE detected.
DB-09 migrations use separate principal; runtime cannot obtain migration credentials; untrusted PR cannot assume deploy role.
DB-10 test privilege introspection against fresh install AND upgrade; no false green if Strata reports unknown objects.
DB-11 local development adapter rejected in production configuration; no production secrets in Docker fixtures.
DB-12 application API denies unauthorized access independent of DB protections; audit does not leak financial details.

## Four critical gates
C1 tenant isolation: endpoint + routine + DB scope and foreign keys.
C2 ledger immutability and concurrency: DB-enforced invariants.
C3 Fides trust/session: identity validated server-side; Census membership/permissions separately.
C4 CI supply-chain/deploy: pinned actions, OIDC subject/ref/environment restriction, PR isolation and signed artifacts.

## Release rule
Block production until all DB tests pass on actual deployed SQL using runtime credentials, negative privilege matrix is checked from pg_catalog, and threat review signs off. Never mark requirements as tested.
