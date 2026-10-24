# Census requirements adversarial consistency and completeness audit
Date: 2026-10-24
Method: reviewed all 13 source requirement/implementation documents; checked CEN-001..059 identifiers, Praxis source documentation and key architecture/security conflicts. This is a document review, not code or executable acceptance testing.

## Result
59/59 IDs referenced across the reviewed source set. 13/13 source documents staged as separate pending files in .praxis/inbox/documents/. NOT CLAIMED OR DERIVED: Census has no observed installed Praxis configuration (ros.json, .echelon/ros.json or AGENTS.md) and no executable Praxis session was run. Pending inbox documents are NOT canonical work items. Do not report successful ingestion.

## Blockers and contradictions
AUD-01 CRITICAL: requirements/README.md incorrectly claims each requirement has verifiable acceptance criteria. CEN-021..026 are phases, and multiple requirements contain unspecified decisions. Correct to 'draft coverage, acceptance gaps open'.
AUD-02 CRITICAL: requirements/README.md says CEN-010 depends on CEN-009 (auth depends on Plaid). Authentication must precede protected Plaid; remove that edge. CEN-013 depends on CEN-006 despite public loading shell requiring neither observations nor authentication. Dependency graph must be corrected.
AUD-03 CRITICAL: CEN-030/051 runtime 'routine-only' DB access requires concrete callable API, PostgreSQL privileges, SECURITY DEFINER review and non-spoofable tenant identity; no executable proof yet. Do not allow financial API exposure.
AUD-04 HIGH: CEN-031 suggests session TTL defaults but no risk-approved session, MFA or account-recovery configuration. Mark decision unresolved.
AUD-05 HIGH: Strata grant comparison only covers declared grantees; cannot certify no stray effective grants. Independent pg_catalog audit mandatory. Routine signature differences may be missed when body unchanged.
AUD-06 HIGH: Plaid webhook verification must use current provider contract, not presumed mechanism. Privacy/retention durations unspecified.
AUD-07 HIGH: CEN-028 requires annotated wireframes but none approved; UI-01..12 are inventory, not detailed screen implementation contracts.
AUD-08 HIGH: CEN-021..026 have no individual requirement records or tests; expand into discrete acceptance criteria and verify.
AUD-09 HIGH: Unresolved deployment settings: AWS tenancy/account, domain, RPO/RTO, backups, key rotation and retention periods. No production gate can pass without decisions.
AUD-10 HIGH: Source requirements duplicate or overlap (CEN-030/033/034/051; CEN-011/029/050; CEN-009/043..045; CEN-003/038). Define normative ownership and cross-reference instead of implementing conflicting copies.
AUD-11 MEDIUM: 'Only functions' vs 'functions/procedures' language is inconsistent; choose allowlisted PostgreSQL routines, with functions preferred, explicit exception review for procedures.
AUD-12 MEDIUM: Need exact OpenAPI schema, SQL routine signatures, accounting worked examples, report formula fixtures, screen-field mapping and test matrix before agent implementation.
AUD-13 MEDIUM: Praxis input files are copies of sources; when source requirements change, pending copies become stale. Track source commit/digest and restage before claim. Do not silently edit claimed documents.
AUD-14 MEDIUM: Security evidence is prose only; no running tests, migrations, authorization proof, or release-ready evidence exists.

## Required disposition
1. Keep public source policy; never store real bank data or credentials in repo.
2. Install/pin Praxis in Census using documented native CLI; run status/verify; inspect actual inbox list.
3. Claim pending inputs one by one; derive canonical requirement records with CEN identifiers preserved as source IDs and valid Praxis RQ identifiers as required; record provenance; commit and push; complete claims only after derivations are committed. No GitHub Issues.
4. Produce exact DB role/GRANT inventory, function signatures and PG16 executable privilege-negative tests before exposing financial APIs.
5. Define exact OpenAPI and screen maps; approve Forma baseline and wireframes.
6. Add automated requirement-ID, dependency DAG, normative ownership and acceptance-evidence checks; record failures as blocked.
7. Freeze operational choices and run threat-driven security review before production.

## Evidence boundary
GitHub file writes confirm pending inbox staging only. No Praxis CLI execution, work-item creation, schema deployment, UI build, or test execution was performed in this review.
