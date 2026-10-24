# CEN-061: Census PostgreSQL function contract catalog v1

**Status:** normative requirements only. No functions, tests, or Praxis records are claimed implemented.
**Authority:** CEN-060 function-only access; CEN-030/031–036 identity; CEN-037–047 finance and provider; CEN-048–059 UI, API and delivery.
**Scope:** public callable functions in `census_api`. No application runtime receives direct SELECT or DML on `census_private` or access to `census_security`.

## 1. Decisions and conventions

**Runtime principals.** `census_api_runtime` executes end-user functions. `census_worker_runtime` executes only worker functions. The database owner and migration principals are never application credentials. No EXECUTE is granted to PUBLIC, and a new overload is inaccessible until explicitly allowlisted. The grants matrix below is normative.

**Trusted identity is an unresolved security design gate.** Every end-user function takes `p_auth_context uuid`, a reference to a short-lived, one-use-or-replay-bounded **server-verifiable** authorization context; it is not an arbitrary principal ID, tenant ID, client-supplied token, or custom PostgreSQL GUC. A context must bind Fides-authenticated issuer+subject, entity, permission, expiry, nonce/session and revocation epoch, and be validated independently of untrusted SQL parameters. The exact mechanism and its compromise model (including compromised API DB credential) require a dedicated ADR before implementation. A UUID reference alone provides no security. Until proven, **all entity-scoped functions are blocked for release**. Worker functions instead take `p_job_context uuid`, independently validated for entity, capability, job identity, expiry and replay. Never implement these as arbitrary UUID lookups without unforgeable issuance and lifecycle.

**Typed contracts.** Monetary values are `bigint` minor units; currency is ISO 4217 `char(3)`. Identifiers are `uuid`, timestamps are `timestamptz`, dates are `date`. `jsonb` appears only for validated, versioned DTOs or bounded projections, never SQL fragments. API clients do not supply audit actor, final posting totals, or provider cursors without verification. All mutation functions return an immutable operation receipt.

**Types (proposed schema-owned composite types):**
- `census_api.operation_receipt_v1`: `operation_id uuid, resource_id uuid, version bigint, outcome text, occurred_at timestamptz`; `outcome` one of created/updated/already_applied/transitioned.
- `census_api.page_v1`: `items jsonb, next_cursor text, as_of timestamptz, coverage text`. Each function has a named, versioned JSON item schema and hard maximum page size 100, default 50; cursor is opaque, scoped to context and filter hash, with expiry.
- `census_api.entity_v1`, `member_v1`, `account_v1`, `period_v1`, `entry_v1`, `observation_v1`, `reconciliation_v1`, `connection_v1`, `report_v1`: immutable named projections with documented fields below. Implementations may use composite SQL types rather than JSON where stable; public signature changes require new function version, not silent replacement.
- `p_request_key uuid` on mutations: unique within actor+entity+function+payload hash, recorded atomically, minimum 24-hour replay window (longer for financial posting/provider operations); same key+different payload => conflict. Client-generated key is not authorization.

**Common errors:** `CEN_AUTH_REQUIRED`, `CEN_FORBIDDEN`, `CEN_NOT_FOUND` (also for unauthorized resource existence), `CEN_CONFLICT`, `CEN_INVALID_STATE`, `CEN_VALIDATION`, `CEN_LIMIT`, `CEN_RETRYABLE`, `CEN_PROVIDER_UNAVAILABLE`. Safe SQLSTATE mapping to versioned API problem codes is mandatory; no raw SQL errors or existence disclosure.

**Common guarantees:** all entity-scoped calls validate actor/worker authority, entity, nested IDs, membership revocation, record state and row caps; all writes are atomic and audited; stable sorting, bounded query time, no arbitrary SQL; outputs are redacted for role. Security-definer functions have fixed safe search_path and explicit qualified relations.

## 2. Authorization roles

Role codes in catalog: **O** owner; **A** administrator; **C** accountant; **V** viewer; **W** worker capability. All end-user functions require authenticated entity membership and matching function permission, not just role name. O/A/C/V map to `census_api_runtime` DB login; W maps to `census_worker_runtime`. Owner-only role transfers, exports and bank reconnections require step-up. A cannot self-elevate. V is strictly read-only. C can draft, post and reconcile within policy. W cannot impersonate a user. Function-level and row-level enforcement are both required.

## 3. Identity and entity functions

| ID | Exact proposed PostgreSQL signature | Return | Roles | Preconditions and effects |
|---|---|---|---|---|
| FN-001 | `census_api.list_authorized_entities_v1(p_auth_context uuid, p_limit integer, p_cursor text)` | page_v1 of entity_v1 | O/A/C/V | Only memberships bound to verified principal; cursor scoped to principal; no arbitrary entity enumeration. |
| FN-002 | `census_api.get_current_principal_v1(p_auth_context uuid)` | jsonb principal projection | O/A/C/V | Verified identity; return opaque ID and display profile only, never provider claims/tokens. |
| FN-003 | `census_api.list_members_v1(p_auth_context uuid, p_entity_id uuid, p_limit integer, p_cursor text)` | page_v1 of member_v1 | O/A | Hide member emails/identifiers unless permitted. |
| FN-004 | `census_api.invite_member_v1(p_auth_context uuid, p_entity_id uuid, p_invitee_ref text, p_role text, p_request_key uuid)` | operation_receipt_v1 | O/A | Role in approved set; A cannot grant O; invitation expiry, rate limit and audit. |
| FN-005 | `census_api.change_member_role_v1(p_auth_context uuid, p_entity_id uuid, p_member_id uuid, p_role text, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A | Prevent last-owner removal, self-escalation and stale versions; revoke prior grants/sessions. |
| FN-006 | `census_api.revoke_member_v1(p_auth_context uuid, p_entity_id uuid, p_member_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A | Immediate revocation epoch; deny last-owner revocation. |
| FN-007 | `census_api.create_entity_v1(p_auth_context uuid, p_name text, p_kind text, p_currency char(3), p_request_key uuid)` | operation_receipt_v1 | authenticated principal | Requires special create-entity capability independent of entity membership; establishes first owner atomically. |

## 4. Chart of accounts and periods

| ID | Signature | Return | Roles | Invariants |
|---|---|---|---|---|
| FN-008 | `census_api.list_accounts_v1(p_auth_context uuid, p_entity_id uuid, p_limit integer, p_cursor text, p_include_inactive boolean)` | page_v1 of account_v1 | O/A/C/V | Stable code order; only authorized entity. |
| FN-009 | `census_api.create_account_v1(p_auth_context uuid, p_entity_id uuid, p_code text, p_name text, p_kind text, p_currency char(3), p_parent_id uuid, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Unique entity code, valid kind, same-entity parent, no cycles. |
| FN-010 | `census_api.update_account_v1(p_auth_context uuid, p_entity_id uuid, p_account_id uuid, p_name text, p_parent_id uuid, p_active boolean, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | No historical account identity/currency change; reject archive if prohibited by open balances. |
| FN-011 | `census_api.list_periods_v1(p_auth_context uuid, p_entity_id uuid, p_limit integer, p_cursor text)` | page_v1 of period_v1 | O/A/C/V | Nonoverlapping, entity-scoped periods. |
| FN-012 | `census_api.create_period_v1(p_auth_context uuid, p_entity_id uuid, p_start date, p_end date, p_request_key uuid)` | operation_receipt_v1 | O/A | Inclusive start/exclusive end; no overlap; explicit book timezone policy. |
| FN-013 | `census_api.close_period_v1(p_auth_context uuid, p_entity_id uuid, p_period_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A | All required reconciliations closed, no unresolved blocking exceptions; atomic close. |
| FN-014 | `census_api.reopen_period_v1(p_auth_context uuid, p_entity_id uuid, p_period_id uuid, p_reason text, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O | Mandatory reason and audit; reopening does not mutate existing posted entries. |

## 5. Journals

| ID | Signature | Return | Roles | Invariants |
|---|---|---|---|---|
| FN-015 | `census_api.list_entries_v1(p_auth_context uuid, p_entity_id uuid, p_from date, p_to date, p_status text, p_limit integer, p_cursor text)` | page_v1 of entry_v1 | O/A/C/V | Stable effective date+ID; bounded period; redacted details. |
| FN-016 | `census_api.get_entry_v1(p_auth_context uuid, p_entity_id uuid, p_entry_id uuid)` | jsonb entry_v1 with lines | O/A/C/V | Same-entity lines only; no cross-entity existence leak. |
| FN-017 | `census_api.create_draft_v1(p_auth_context uuid, p_entity_id uuid, p_effective_at timestamptz, p_description text, p_source_kind text, p_source_id uuid, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Valid open period; source ID belongs to entity; no auto-posting. |
| FN-018 | `census_api.replace_draft_lines_v1(p_auth_context uuid, p_entity_id uuid, p_entry_id uuid, p_lines jsonb, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Versioned line DTO: account_id, currency, debit_minor, credit_minor, line_order; max 500; only drafts; atomic replace; entity FKs. |
| FN-019 | `census_api.post_entry_v1(p_auth_context uuid, p_entity_id uuid, p_entry_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | >=2 lines, one positive side each, equal debit/credit sums per currency, open period, valid account, serialized posting; posted lines immutable. |
| FN-020 | `census_api.reverse_entry_v1(p_auth_context uuid, p_entity_id uuid, p_entry_id uuid, p_effective_at timestamptz, p_reason text, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Posted original only, no double reversal, new balanced reversing journal, open reversal period, audit. |

## 6. Plaid and synchronization

| ID | Signature | Return | Roles | Invariants |
|---|---|---|---|---|
| FN-021 | `census_api.list_connections_v1(p_auth_context uuid, p_entity_id uuid, p_limit integer, p_cursor text)` | page_v1 of connection_v1 | O/A/C/V | No provider access token or secret_ref in output. |
| FN-022 | `census_api.create_connection_v1(p_auth_context uuid, p_entity_id uuid, p_institution_id uuid, p_provider_ref text, p_request_key uuid)` | operation_receipt_v1 | O/A | Backend-only provider exchange; provider_ref is opaque validated backend artifact, not client-supplied Plaid token; consent and step-up. |
| FN-023 | `census_api.list_external_accounts_v1(p_auth_context uuid, p_entity_id uuid, p_connection_id uuid, p_limit integer, p_cursor text)` | page_v1 of account projection | O/A/C/V | Connection scoped to entity; masked identifiers only. |
| FN-024 | `census_api.map_external_account_v1(p_auth_context uuid, p_entity_id uuid, p_external_account_id uuid, p_ledger_account_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Same entity, currency/type compatibility, mapping history and audit. |
| FN-025 | `census_api.disconnect_connection_v1(p_auth_context uuid, p_entity_id uuid, p_connection_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A | Step-up, stop future sync, preserve posted history; provider revocation is separate idempotent external side effect. |
| FN-026 | `census_api.stage_sync_batch_v1(p_job_context uuid, p_entity_id uuid, p_connection_id uuid, p_run_id uuid, p_batch jsonb, p_request_key uuid)` | operation_receipt_v1 | W | Validate bounded provider observations and revisions; no arbitrary cursor advance; idempotent. |
| FN-027 | `census_api.finalize_sync_cursor_v1(p_job_context uuid, p_entity_id uuid, p_connection_id uuid, p_run_id uuid, p_expected_cursor_ref text, p_next_cursor_ref text, p_request_key uuid)` | operation_receipt_v1 | W | Atomic completeness check of all pages, durable cursor CAS and observation commits; reject partial pages or concurrent run. |
| FN-028 | `census_api.mark_connection_health_v1(p_job_context uuid, p_entity_id uuid, p_connection_id uuid, p_health text, p_reason_code text, p_request_key uuid)` | operation_receipt_v1 | W | Valid state transition, bounded reason codes, audit, no credential material. |

**Provider atomicity note:** FN-026 stages a sync run privately; FN-027 is the *only* function making a completed run visible and advancing its cursor in one database transaction. If this cannot be guaranteed with the actual schema, the two must be consolidated into one atomic function before implementation. No intermediate batch may affect financial reporting.

## 7. Observations and classification

| ID | Signature | Return | Roles | Invariants |
|---|---|---|---|---|
| FN-029 | `census_api.list_observations_v1(p_auth_context uuid, p_entity_id uuid, p_external_account_id uuid, p_from date, p_to date, p_limit integer, p_cursor text)` | page_v1 of observation_v1 | O/A/C/V | Coverage/freshness returned; pending and removed states explicit. |
| FN-030 | `census_api.get_observation_v1(p_auth_context uuid, p_entity_id uuid, p_observation_id uuid)` | jsonb observation_v1 | O/A/C/V | Revision provenance, redacted provider fields. |
| FN-031 | `census_api.list_rules_v1(p_auth_context uuid, p_entity_id uuid, p_limit integer, p_cursor text)` | page_v1 of rule projection | O/A/C/V | Rules displayed as safe typed predicates, not executable SQL. |
| FN-032 | `census_api.save_rule_v1(p_auth_context uuid, p_entity_id uuid, p_rule_id uuid, p_priority integer, p_predicate jsonb, p_action jsonb, p_enabled boolean, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Validated bounded predicate AST; no raw SQL, unsafe regex or arbitrary code. NULL rule ID means create. |
| FN-033 | `census_api.classify_observation_v1(p_auth_context uuid, p_entity_id uuid, p_observation_id uuid, p_category_id uuid, p_reason text, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Same-entity category, immutable provenance, manual override survives sync. |
| FN-034 | `census_api.list_exceptions_v1(p_auth_context uuid, p_entity_id uuid, p_state text, p_limit integer, p_cursor text)` | page_v1 of exception projection | O/A/C/V | Include evidence freshness and confidence; never claim missing data equals zero. |
| FN-035 | `census_api.review_exception_v1(p_auth_context uuid, p_entity_id uuid, p_exception_id uuid, p_disposition text, p_reason text, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Approved disposition state machine and audit. |

## 8. Reconciliation

| ID | Signature | Return | Roles | Invariants |
|---|---|---|---|---|
| FN-036 | `census_api.list_reconciliations_v1(p_auth_context uuid, p_entity_id uuid, p_account_id uuid, p_limit integer, p_cursor text)` | page_v1 of reconciliation_v1 | O/A/C/V | Stable period ordering. |
| FN-037 | `census_api.create_reconciliation_v1(p_auth_context uuid, p_entity_id uuid, p_account_id uuid, p_period_end date, p_external_balance_minor bigint, p_evidence_ref text, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Currency/account validity, unique active period snapshot, evidence provenance. |
| FN-038 | `census_api.propose_match_v1(p_auth_context uuid, p_entity_id uuid, p_reconciliation_id uuid, p_observation_ids uuid[], p_entry_ids uuid[], p_request_key uuid)` | operation_receipt_v1 | O/A/C | Bounded arrays, same entity/account, no conflicting closed matches; proposal not final. |
| FN-039 | `census_api.confirm_match_v1(p_auth_context uuid, p_entity_id uuid, p_match_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Validate sum, currency, evidence, reviewer policy, concurrency. |
| FN-040 | `census_api.close_reconciliation_v1(p_auth_context uuid, p_entity_id uuid, p_reconciliation_id uuid, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A/C | Zero policy-adjusted difference, no blocking exceptions, atomic snapshot, no duplicate consumption. |
| FN-041 | `census_api.reopen_reconciliation_v1(p_auth_context uuid, p_entity_id uuid, p_reconciliation_id uuid, p_reason text, p_expected_version bigint, p_request_key uuid)` | operation_receipt_v1 | O/A | Explicit reason, audit and invalidation of dependent close eligibility. |

## 9. Reporting, exports and audit

| ID | Signature | Return | Roles | Invariants |
|---|---|---|---|---|
| FN-042 | `census_api.balance_sheet_v1(p_auth_context uuid, p_entity_id uuid, p_as_of date, p_currency char(3))` | jsonb report_v1 | O/A/C/V | Posted journal only, assets=liabilities+equity, coverage and period flags, bounded response. |
| FN-043 | `census_api.income_statement_v1(p_auth_context uuid, p_entity_id uuid, p_from date, p_to date, p_currency char(3))` | jsonb report_v1 | O/A/C/V | Revenue/expenses from posted entries only, explicit date basis, stable rounding. |
| FN-044 | `census_api.cash_flow_v1(p_auth_context uuid, p_entity_id uuid, p_from date, p_to date, p_currency char(3))` | jsonb report_v1 | O/A/C/V | Exclude internal transfers; reconcile opening/closing cash and unclassified flows. |
| FN-045 | `census_api.spend_summary_v1(p_auth_context uuid, p_entity_id uuid, p_from date, p_to date, p_limit integer, p_cursor text)` | page_v1 of spend projection | O/A/C/V | Explicit pending/posted choice, coverage warnings, currency isolation. |
| FN-046 | `census_api.export_snapshot_v1(p_auth_context uuid, p_entity_id uuid, p_report_kind text, p_filters jsonb, p_request_key uuid)` | operation_receipt_v1 | O/A plus explicit export grant | Step-up, validated filter schema, size cap; result is authorized export job ID, never raw file or URL. |
| FN-047 | `census_api.list_audit_events_v1(p_auth_context uuid, p_entity_id uuid, p_from timestamptz, p_to timestamptz, p_limit integer, p_cursor text)` | page_v1 of audit projection | O only, or separately approved auditor | Redacted immutable events, no secret-bearing metadata. |
| FN-048 | `census_api.read_export_batch_v1(p_job_context uuid, p_entity_id uuid, p_export_id uuid, p_limit integer, p_cursor text)` | page_v1 of export projection | W export-only capability | Strict job scope and row bounds, no public CDN caching, formula injection mitigation downstream. |

## 10. Field-level public projection minimums

- `entity_v1`: entity_id, display_name, kind, functional_currency, membership_role.
- `member_v1`: member_id, role, status, invited_at, joined_at, version; contact identifier only if role permits.
- `account_v1`: account_id, code, name, kind, currency, parent_id, active, version.
- `period_v1`: period_id, start_date, end_date_exclusive, state, version, closed_at.
- `entry_v1`: entry_id, effective_at, status, description, source_kind, reversal_of, version; details add line_id, account_id, currency, debit_minor, credit_minor, line_order.
- `connection_v1`: connection_id, institution_display_name, state, last_synced_at, coverage_state, version; no token/secret_ref.
- `observation_v1`: observation_id, external_account_id, provider_revision, amount_minor, currency, merchant_display, authorized_at, posted_at, pending, removed, category_id, source_freshness.
- `reconciliation_v1`: reconciliation_id, account_id, period_end, currency, external_balance_minor, ledger_balance_minor, difference_minor, state, version.
- `report_v1`: report_kind, entity_id, currency, period, lines, totals, coverage_state, generated_at, source_revision, warnings.

## 11. Required contract validation before implementation

- Every FN-001..048 must have a function-owner/EXECUTE grant manifest, request/response DTO schema, role+entity matrix, positive test, unauthorized role test, cross-entity nested-ID test, stale/invalid context test and concurrency/idempotency test where applicable.
- Database runtime credentials must fail direct table SELECT/DML and unlisted function calls. No generic SQL gateway or read-only exception.
- SQL catalog inspection must detect unexpected effective grants, PUBLIC defaults, owner/role inheritance, overloads, search_path vulnerabilities and unverified Strata object drift.
- No P0 functions are implemented until trusted identity design is approved. Report unknown behavior as blocked, never guessed.
- Breaking signatures create `_v2` functions with explicit deprecation and migration plan. Function implementations cannot silently add returned fields that expose sensitive data.

## 12. Open design decisions (must resolve before build)

1. Exact trusted auth-context issuance, DB-side verification, revocation, replay and compromised-runtime threat model; no GUC-only solution.
2. Whether first entity creation uses a distinct bootstrap identity capability and how invitation acceptance works; FN-004 is invite creation, not acceptance.
3. Exact Fides contract and MFA/step-up mechanism.
4. Provider-side sync batch storage, pagination and visibility semantics; FN-026/027 must be transactionally safe.
5. Accounting period timezone, fiscal rules, supported currencies/FX, reconciliation thresholds and policy.
6. Exact API transport DTO JSON Schemas, field limits, error SQLSTATE mapping and retention settings.
7. Worker export delivery storage and user download authorization.

**Definition of done for this document:** catalog completeness and consistency review, approval of open design decisions, and traceability to CEN-001..060. No tests or ingestion are required during the requirements phase.
