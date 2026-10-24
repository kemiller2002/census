# Census requirements

The source-of-truth draft is indexed in [MASTER-INDEX.md](MASTER-INDEX.md). All identifiers CEN-001 through CEN-059 are represented, but not every item has fully executable acceptance criteria. Open decisions and contradictions are recorded in [the adversarial audit](../docs/requirements-adversarial-audit-2026-10-24.md).

## Praxis staging
The verified Praxis inbox convention is `.praxis/inbox/documents/`. Source copies are staged there as **pending inputs**. They have not been claimed, derived into canonical Praxis records, or validated by the CLI. Do not equate staging with ingestion. The canonical source files here remain authoritative until claims are processed; compare source revisions before deriving.

## Dependencies (partial, subject to DAG validation)
CEN-001 -> CEN-002 -> CEN-003 -> CEN-004 -> CEN-005.
CEN-006 depends on CEN-002; CEN-007 depends on CEN-003 and CEN-006; CEN-008 depends on CEN-007.
CEN-009 depends on CEN-002 and CEN-010 (authenticated, authorized connection management); CEN-010 does **not** depend on Plaid.
CEN-013 (public loading shell) can be built independently; protected data loading requires CEN-010.
CEN-014, CEN-030..036 and CEN-051/055 are production release gates, not optional post-launch tasks.

See [the master index](MASTER-INDEX.md) for the remaining requirements, release gates and unresolved decisions.
