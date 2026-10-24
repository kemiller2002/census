# CEN-027: One-command local development environment

Priority: P0. Status: requirement, not implemented.

## User story
A developer clones the Census repository, runs one documented Make or FAKE command, and obtains a complete working local environment without manually installing or starting individual Census services. PostgreSQL runs in a local Docker container. No AWS account, production Plaid credentials, deployed Fides service or real financial data is required for the default local path.

## Developer contract
- `make dev` is the canonical entrypoint; `dotnet fake run build.fsx --target Dev` may be the underlying orchestrator. On Windows provide an equivalent documented PowerShell/FAKE command if make is absent.
- `make setup` installs/restores pinned toolchain dependencies, validates prerequisites, and prepares local configuration; `make build`, `make test`, `make verify`, `make stop`, `make clean` are required.
- `make dev` must bootstrap an isolated PostgreSQL 16 Docker Compose service with a named persistent volume, health check, nonproduction credentials, and localhost-only port exposure. Container naming and ports must avoid collisions or provide configurable overrides.
- Wait for PostgreSQL readiness, apply verified Strata schema deployment, seed deterministic **synthetic** entities/accounts/journal entries, start the F# API and ingestion worker in local/sandbox mode, serve the Forma/Limen WASM UI, and print URLs and diagnostic locations.
- Default local authentication uses a documented Fides-compatible local test identity adapter or a local Fides deployment if verified practical. It must preserve the production authorization boundary, never silently disable authorization, and clearly identify development-only sessions. The local adapter must be impossible to enable in production builds/configuration.
- Plaid defaults to a deterministic fake provider with synthetic data; allow opt-in Plaid sandbox using developer-supplied secrets outside Git. No live Plaid connection required for `make dev`.
- Run all required build steps from a clean clone, using pinned released Echelon components where available; report precise missing prerequisites and remedial commands. Never silently fall back to unverified versions.
- Idempotent: running `make dev` twice does not duplicate data, recreate posted journals, or corrupt schema. `make stop` stops services without deleting the volume; `make clean` requires explicit opt-in before destroying local DB data.
- Docker Compose is limited to local infrastructure and optional service containers. Production remains AWS-managed.
- Ensure `.env.local`, DB dumps, credentials, local logs, generated assets and state are gitignored. Commit only safe `.env.example` with placeholders and synthetic values.
- Default browser flow includes the accessible WebAssembly loading shell and all main navigation areas, with fixture data where implementation is incomplete; clearly label stub functionality.

## Acceptance tests
1. On a supported fresh developer machine with documented prerequisites, clone + `make dev` yields working UI, API, PostgreSQL and local auth without manual service startup.
2. `make verify` tests API health, DB connectivity, schema version, entity isolation, journal balance invariants, WASM asset availability and loading shell.
3. A second `make dev` is idempotent; `make stop` then `make dev` restores persistent synthetic data.
4. `make test` executes unit, contract, integration and browser smoke tests with clear pass/fail/blocked reporting.
5. CI executes the same `make build`, `make test`, and `make verify` targets with isolated test infrastructure, no real secrets.
6. No local-dev bypass is reachable in production; tests assert the environment guard fails closed.
7. Documentation covers macOS, Linux and Windows/WSL2, Docker prerequisites, .NET SDK, troubleshooting and port overrides.

## Dependencies
CEN-021 component audit, CEN-022 Praxis intake, CEN-023 database schema, CEN-024 API contracts, CEN-025 application bootstrap, CEN-010 auth, CEN-013 loading shell. Implement early as a vertical slice; extend as modules arrive.
