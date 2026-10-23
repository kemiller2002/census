# Census

Census is a privacy-first financial intelligence application for personal and multi-entity business finances.

> SECURITY GATE: Repository visibility must be PRIVATE before deployment, linking financial institutions, storing secrets, or importing financial data. No real financial data belongs in Git.

## Proposed architecture
- F#/.NET backend and PostgreSQL on AWS
- Plaid Link and incremental transaction sync behind provider-neutral interfaces
- Double-entry general ledger with immutable journals and reconciliation
- Fides authentication integration (verify actual capabilities before binding)
- Strata PostgreSQL schema migrations (verify implementation compatibility)
- Limen WebAssembly application with Forma UI and Folio reporting
- Praxis-driven requirements intake and evidence; no GitHub Issues

See [requirements](requirements/README.md), [architecture](docs/architecture.md), and [security](docs/security.md).

## Delivery status
Requirements and architecture only. No dependency installation, deployed infrastructure, Fides integration, Plaid connection, or security certification is claimed. Verify Praxis's canonical input directory before ingesting the staged requirements.
