# Census requirements master index

Status: requirements baseline drafted; implementation, Praxis ingestion and validation not verified. Last updated 2026-10-24.

## Scope
- CEN-001..020: foundational accounting, integrations, architecture, security and operations in requirements/core-ledger.md, requirements/integrations-ui.md and requirements/infrastructure-security.md.
- CEN-021..026: implementation bootstrap milestones described in docs/implementation-bootstrap.md; not yet migrated into canonical Praxis intake.
- CEN-027: requirements/local-development.md.
- CEN-028: requirements/ui-screen-design.md.
- CEN-029: requirements/forma-conformance.md.
- CEN-030: requirements/database-security-boundary.md.
- CEN-031..036: requirements/identity-database-security.md.
- CEN-037..042: requirements/accounting-reconciliation.md.
- CEN-043..047: requirements/plaid-data-lifecycle.md.
- CEN-048..052: requirements/ui-api-operations.md.
- CEN-053..059: requirements/delivery-operations-traceability.md.

## Priority and dependencies
P0 security: CEN-010, 014, 030..036, 051, 055. Before financial API exposure: PostgreSQL runtime privilege negative tests, authorization, signed identity, audit and CI/OIDC restrictions.
P0 accounting: CEN-001..007, 023, 037..040. Before any real financial records: DB-enforced journal constraints and tenant isolation.
P0 connectivity: CEN-009, 020, 043..047. Before Plaid production: authenticated webhooks, cursor atomicity and privacy controls.
P0 delivery: CEN-021..027, 053, 057..059. Before release: actual Praxis intake and verifiable test evidence.
UX: CEN-011, 013, 028, 029, 048..050, 052. Before UI implementation: approved Forma component mapping and exact API contracts.
Analytics: CEN-008, 015, 041, 042. Before claims of financial completeness: coverage/freshness reporting and reconciled source totals.

## Known outstanding decisions, not silently resolved
- Exact released Fides, Forma, Limen and Strata versions and licensing compatibility.
- Verified Praxis canonical input folder and ingestion format.
- Specific PostgreSQL stored function signatures and executable SQL.
- Plaid production webhook authentication details, provider data retention obligations and compliance/privacy review.
- Final UX wireframes, branding, UI fields and approved workflows.
- AWS account/domain/cost limits, approved RPO/RTO, retention durations, step-up MFA implementation and reconciliation materiality thresholds.

## Definition of complete
This index means coverage has been drafted, not that requirements are approved, complete in every detail, implemented, tested or ingested into Praxis. A requirement is complete only when its decisions are resolved, traceability exists, and executable acceptance tests pass. Do not report production readiness on the strength of prose.
