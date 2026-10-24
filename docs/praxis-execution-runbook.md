# Census Praxis intake execution runbook
Status: pending execution. The 13 documents under .praxis/inbox/documents/ were staged via GitHub API, not claimed or derived.

## Setup
Use a local checkout or a trusted executor with access to git and the verified native Praxis release. Install and pin a version using Praxis's documented native installer and repo configuration. Run:
```sh
praxis init --dry-run --json
praxis init
./praxis verify --strict
./praxis inbox list --json
```
If installed release disagrees with the reviewed docs, inspect its own `./praxis inbox --help` and stop for compatibility review. Never manually fabricate .ros state.

## Intake
For each pending document:
```sh
./praxis inbox claim .praxis/inbox/documents/<file>
 git add -A .praxis && git commit -m "praxis: claim <file>" && git push
```
Read returned claim ID. Derive distinct canonical requirement records with valid IDs for the installed Praxis version; retain original CEN-NNN in source metadata. For each derivation record provenance `--derived-from INPUT-...`, then `inbox derive` with actual requirement ID and summary, commit and push. Only then `inbox complete`. Use actual CLI syntax and generated paths. Do not create GitHub Issues. Reject duplicate derivations; record blocked decisions as questions, not invented requirements.

## Verification
```sh
./praxis inbox list --json
./praxis validate --json
./praxis verify --strict
./praxis status --json
```
Require no pending claims and traceability of all 59 source IDs before declaring ingestion complete. Preserve machine output as evidence. No production bank credentials during this phase.

## Priorities
P0 database privilege/tenant auth; P0 ledger atomicity; P0 Plaid sync; API contract; Forma wireframes; delivery. Do not mark acceptance tests as passed unless executed.
