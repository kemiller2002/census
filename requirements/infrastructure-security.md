# Infrastructure, operations and security

## CEN-014 Security and release gate
Repository PRIVATE before any real data or deployment. AWS least-privilege IAM with GitHub Actions OIDC; no static AWS keys. RDS PostgreSQL private subnets, encryption at rest/in transit, restrictive security groups, no public DB endpoint, automated PITR backups (target 30 days where supported), encrypted archival, tested restore, secrets rotation plan, structured audit logs without PII/token leakage, dependency/SBOM and secret scans, branch protection, reviewed changes, threat model and incident runbook. Acceptance: infrastructure policy checks, penetration/security review, restore drill, authz negative tests, webhook forgery tests, and no real data in Git.

## CEN-016 Strata database evolution
Evaluate Strata's actual PostgreSQL support, SQL diff and migration semantics. Use versioned, reviewed migrations with forward/backward compatibility strategy, advisory locks or safe migration serialization, schema drift detection, dry run, migration history, rollback/recovery plan and migration tests against ephemeral PostgreSQL. Acceptance: fresh install, repeated migration, and upgrade from previous schema all pass; no destructive changes without explicit approval.

## CEN-017 AWS deployment
IaC for network, private RDS, compute (choose Lambda/container after WASM/backend constraints review), Secrets Manager, KMS, CloudWatch, S3 backups/artifacts, DNS/TLS and alarms. Separate dev/staging/prod accounts or appropriately isolated environments. Cost budget and anomaly alert required. Acceptance: reproducible deployment, teardown of dev resources, observability and documented cost envelope.

## CEN-018 Echelon component compatibility audit
Assess Fides (identity), Strata (Postgres schema), Arca (persistence), Limen (WASM), Forma (UI), Folio (reports), Summa (ledger), Praxis (requirements), Dokimos (quality), Aegis (errors), Vigila (follow-ups), and Conditor (installer) against released versions, licensing, capabilities and security boundaries. Integrate only verified compatible components; document gaps and alternatives. Acceptance: compatibility matrix with version, API contract, smoke test and ownership.

## CEN-019 Data protection and retention
Explicit consent, connection removal, retention schedules, deletion requests, audit retention policy, export, financial-data minimization, and threat modeling of aggregator compromise. No customer secrets, bank tokens, statements, transaction exports or production Terraform state in Git. Acceptance: data lifecycle tests and documented deletion behavior.

## CEN-020 Operational reliability
Webhook queue with deduplication, idempotent sync, retries, dead-letter handling, scheduled catch-up, institution outage detection, alerting, and runbooks. Capture sync_run(run_id UUID, connection_id UUID, started_at timestamptz, finished_at timestamptz nullable, state text, added_count integer, modified_count integer, removed_count integer, error_code text nullable). Acceptance: replay, partial failure and concurrent sync tests show no double-posting.
