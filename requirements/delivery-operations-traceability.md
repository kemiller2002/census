# CEN-053..059 Deployment, developer experience, verification and traceability
Status: normative; not implemented.

## CEN-053 Local bootstrap
- `make dev` brings up PG16 in Docker with localhost-only binding, verified Strata schema, synthetic seed, F# API and worker, static WASM loading shell, fake Plaid and guarded local identity; idempotent restart. `make setup/build/test/verify/stop/clean` with safe clean confirmation, Windows/WSL2 instructions and pinned toolchain.
- CI executes same targets in isolated environment and fails if tests are skipped unexpectedly. No production secret required locally.

## CEN-054 AWS deployment
- Infrastructure as code for isolated environments, TLS edge, CloudFront/S3 public immutable UI, private API origin and private PG16 RDS, private networking, KMS, Secrets Manager, logging/metrics, budget alerts and restore/PITR. Production DB must have no public route or broad security group ingress.
- GitHub OIDC short-lived deploy credentials with environment approval; separate migration and runtime identities. No static AWS credentials. Document domain/DNS, certificate renewal, resource sizing, cost estimates and teardown for nonprod.

## CEN-055 Database migration and privilege gates
- Pin Strata release and schema manifest; run plan/diff against ephemeral PG16 and staging before production. For security-critical objects require independent catalog comparison of grants, roles, default privileges, routine signatures/body/security settings, triggers and RLS; Strata unverified/not-compared cannot be a green release.
- Destructive migrations require explicit approval, backup/restore evidence, forward/backward compatibility window and rollout/rollback strategy. Test clean install, repeat apply, prior-version upgrade, migration concurrency and permission regression.

## CEN-056 Observability and recovery
- Structured metrics for API latency/errors, worker queue lag, provider sync freshness, failed webhook verification, authorization denial rates, journal/reconciliation invariants, DB connection saturation and backup freshness. Avoid PII/tokens in metrics labels or logs.
- Alert ownership, severity, thresholds, runbooks, on-call route, incident revocation/rotation, RPO/RTO targets to be approved before launch, restore exercises and financial consistency checks. No production release with unspecified RPO/RTO.

## CEN-057 Quality gates
- Unit, property-based, integration PG16, API contract, Plaid fake/sandbox, browser accessibility/visual, concurrency, authorization-negative, permission-catalog, supply chain, disaster recovery tests. Every test records run command, environment, version and pass/fail/blocked; no fabricated evidence. Penetration review and privacy review before production.
- A production release requires zero open critical/high security failures; blocking skipped tests must be reported as blocked, not pass.

## CEN-058 Praxis requirements intake
- Read actual pinned Praxis documentation and determine canonical input directory and file schema; do not assume `requirements/` is intake. Ingest CEN-001..059 and link source docs to durable Praxis work items; do not create GitHub Issues. Preserve identifiers and dependency graph. Report un-ingested requirements as blocked.

## CEN-059 Master traceability
- Maintain matrix: requirement ID -> design/ADR -> source file -> DB object/API operation/UI screen -> automated test -> evidence -> release gate. A requirement cannot be called implemented without observed passing tests. Mark unknown or unverified explicitly.
- Freeze versioned release scope and list explicit non-goals. Acceptance: no orphaned requirement, endpoint, database privilege or enabled UI action; generate coverage report in `make verify`.
