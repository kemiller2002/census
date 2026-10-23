# Census implementation bootstrap: ordered execution plan

Status: planned, not executed. Do not claim installation, schema deployment, tests or Praxis ingestion until commands produce evidence.

## Phase A: baseline and dependency verification (CEN-021)
1. Clone Census and current Echelon sources: praxis, fides, strata, limen, forma, arca, summa. Inspect AGENTS.md, BOOTSTRAP.md, releases, lockfiles and actual CLI contracts. Use released artifacts rather than default-branch source where supported.
2. Run `echelon doctor --json`, `echelon inventory` and each component's verify command; record exact version, checksum, capabilities, limitations and install mechanism.
3. Confirm Fides service deployment requirement, GitHub App configuration and session model. Confirm Strata PostgreSQL 16 compatibility and SQL object coverage. Do not use Arca GitHub as financial datastore.
4. Write compatibility matrix and evidence under docs/evidence. Block incompatible dependencies; don't invent substitute APIs.

## Phase B: Praxis intake (CEN-022)
1. Read Census's pinned Praxis package or install from verified native release. Read the exact input convention from that version and its AGENTS.md.
2. Move/copy each requirements file into the verified Praxis input path; preserve requirement IDs and traceability. Never create GitHub Issues.
3. Run Praxis ingestion/validation/status/ready commands as documented. Save output and resulting work IDs. A markdown requirements directory alone is NOT ingestion.
4. Reconcile older requirement wording that demands private source; public code is allowed, production secrets and financial data in Git are not.

## Phase C: schema and API (CEN-023 and CEN-024, parallel after A/B)
Schema:
- Produce Strata declarative SQL for every table in docs/database-schema.md; use PG16. Ensure composite entity-scoped FKs, unique indexes, period exclusion, posting invariants, and DB immutability triggers/permissions.
- Test create, diff, deploy, repeat no-op, upgrade, and unsupported-object reporting on disposable PG16. Any 'not-compared'/'unverifiable' is a blocking review, not clean.
API:
- Define OpenAPI 3.1 for each endpoint in docs/three-tier-contract.md, concrete request/response JSON schemas, auth/error responses, idempotency, pagination, financial amounts, and concurrency.
- Generate/compile typed F# DTOs or implement validated equivalents. Consumer-driven tests must cover invalid and unauthorized requests.

## Phase D: application bootstrap (CEN-025)
- F# .NET 10 solution: Domain, Application, Persistence.Postgres, Providers.Plaid, Api, Worker, Contracts, Tests.
- Install pinned verified Praxis, Strata, Limen, Forma, Aegis and Fides integration where available. Use Conditor/Registry where documented.
- Build static HTML/CSS Census WASM loading shell with accessible status, error, retry, offline and reduced-motion behavior.
- Implement authenticated same-origin API, entity membership authorization, first database migration and a minimal read-only account endpoint.
- GitHub Actions CI: formatting, build, tests, SQL migration checks, dependency/secret scanning. OIDC AWS deployment only after AWS environment is configured.

## Phase E: security and end-to-end tests (CEN-026)
- Deny anonymous API calls and cross-entity requests; validate roles and expired/revoked sessions.
- Reject unbalanced/duplicate journal entries, closed-period edits and mutation of posted entries; test concurrent posting.
- Verify Plaid webhook authenticity, replay, cursor atomicity and missing data coverage.
- Verify secure cookie/CSRF, no secrets in browser bundles/logs, no sensitive financial data in Git.
- Browser smoke: shell first paint on slow connection, WASM fail/retry, authenticated API, no direct DB connection.
- Restore a PostgreSQL backup into isolated environment and verify ledger invariants.
- Report tests pass/fail/blocked with artifact links; do not infer green from tests not run.

## Release gates
A: component compatibility verified
B: Praxis has actually ingested requirements
C: schema migration + OpenAPI contracts verified
D: authenticated browser-to-API-to-PostgreSQL smoke test passes
E: security/integration suite and restore test pass

## Execution policy
No real banking credentials or production data until gates A-D. Never commit secrets. Public repository is acceptable. Minimize token use by grouping documentation discovery, parallelizing independent schema/API work, running focused tests during slices and comprehensive suites at release gates.