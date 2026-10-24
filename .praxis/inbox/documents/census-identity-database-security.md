# CEN-031..036 Identity, authorization, and database security
Status: normative requirements, implementation unverified. P0.

## CEN-031 Identity and sessions
- Verify Fides capabilities before relying on them. Only configured issuer/audience and signed tokens; reject unsigned/expired/not-yet-valid tokens, wrong algorithms, invalid nonce/state/PKCE and unregistered redirect URIs. Maintain explicit issuer+subject mapping to principal. Authentication never implies entity membership.
- Use server-managed opaque sessions with Secure, HttpOnly, SameSite cookies, CSRF defenses for every state-changing browser operation, rotation at login and privilege elevation, idle/absolute expiry, logout/revocation and invalidation on membership change. Define configurable defaults (15-minute idle, 12-hour absolute) pending risk approval; record actual values in configuration.
- Require MFA/step-up for owner changes, bank connection changes, bulk exports and role grants, or block such actions until identity provider supports it. No open redirect, token in URL, or token in browser storage.
- Test token substitution, fixation, expired/revoked sessions, replayed callback, CSRF, role downgrade, session cross-entity switch, and concurrent logout.

## CEN-032 Permission matrix
- Roles: owner, administrator, accountant, viewer; permissions are operation-specific, default deny. Owner controls ownership and entity deletion; administrator manages memberships and connections but cannot self-elevate to owner; accountant may classify, draft, post and reconcile subject to segregation policy; viewer reads permitted data only. Bulk export is separately granted and audited. No role can bypass accounting period rules.
- Authorization requires principal membership + entity scope + action permission + resource state. Check nested IDs within same entity, not merely URL entity ID. Background workers use narrowly scoped service principals and explicit entity context.
- Membership removal/revocation must take effect on next privileged request, including active sessions. Never trust roles or entity ID from client state alone.

## CEN-033 PostgreSQL roles and privileges
- Distinct NOLOGIN object owner, migration LOGIN, API LOGIN, worker LOGIN and read-only monitoring LOGIN. Runtime roles have no BYPASSRLS, SUPERUSER, CREATEDB, CREATEROLE, schema CREATE, role inheritance to owner or migration, or direct privileges on private tables/sequences.
- All base tables in census_private, callable allowlisted routines in census_api, internal security routines in census_security. REVOKE PUBLIC schema/function access and alter default privileges for every object-creating role. Explicit per-routine EXECUTE grants only. PostgreSQL catalog tests must enumerate effective privileges, PUBLIC, role membership and default grants; Strata's declared-grantee drift alone is insufficient.
- SECURITY DEFINER routines owned by NOLOGIN owner; fixed safe search_path, fully qualified objects, no untrusted dynamic SQL; validate arguments, scope, row limits and errors. Audit routine grants and ownership on every deployment. A compromised API DB login must not be able to call arbitrary owner routines.
- The runtime role's ability to spoof arbitrary custom GUCs must be threat-modelled; a session variable alone is not an identity proof. No SECURITY DEFINER function may trust caller-supplied principal without a server-verifiable authorization context.

## CEN-034 Data isolation and RLS
- Entity-aware composite FKs for all nested resources; scope every read/write/report/export/queue event. RLS as additional defense where safely implemented, never sole authorization. Connection pool must reset tenant state and session settings before reuse; test leakage under concurrent requests.
- Database tests must attempt direct SQL DML, DDL, EXECUTE of unlisted routines, malicious search_path, role escalation, forged tenant context and foreign nested IDs, using actual API/worker credentials. All fail.

## CEN-035 Supply chain and deployment
- Public repository permitted; no production data or secrets in source, fixtures, logs, artifacts or WASM. Pin CI actions to immutable commits; least-privilege workflow permissions; no secrets or AWS OIDC role for untrusted pull requests; restrict OIDC trust by repository, ref and environment. Separate deploy approval and DB migration principal.
- Signed/version-pinned Echelon components; verify checksums and provenance. Security scanners and dependency inventory gate release. Any Strata not-compared/not-modelled/unverifiable security object blocks automatic production deploy. Independently compare pg_catalog privileges, policies, owners and routine definitions/signatures.

## CEN-036 Audit and abuse
- Record actor, entity, action, resource, outcome, timestamp and correlation ID for security-sensitive changes without secrets, bank descriptions or payloads. Tamper-resistant retention, bounded access, monitoring on grants, connection changes, exports, failed auth, unusual data access.
- Rate limit login/session, Plaid Link creation, exports, searches and costly reports. Request body limits, pagination ceilings, query timeouts and worker backpressure.
- Acceptance: negative authorization matrix for every API and routine; production config rejects dev identity; untrusted PR cannot deploy; all privilege introspection assertions pass in fresh and upgraded PG16.
