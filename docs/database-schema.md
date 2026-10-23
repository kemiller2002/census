# Census PostgreSQL logical schema v1

**Status:** logical schema contract; executable Strata migrations still to be generated and verified. UUID primary keys, timestamptz audit times, integer minor units for money. Currency char(3), ISO-4217. All tenant-owned rows include entity_id and use composite entity-aware foreign keys where appropriate. Indexes on entity_id and primary query predicates. Unique constraints as specified. Avoid storing sensitive full bank account numbers.

## Identity / tenancy
- entity(entity_id uuid PK, display_name text not null, kind text not null, functional_currency char(3) not null, created_at timestamptz not null)
- principal(principal_id uuid PK, issuer text not null, subject text not null, created_at timestamptz not null, unique(issuer,subject))
- entity_membership(entity_id uuid FK, principal_id uuid FK, role text not null, status text not null, primary key(entity_id,principal_id))
- audit_event(event_id uuid PK, entity_id uuid nullable, principal_id uuid nullable, action text, target_kind text, target_id uuid nullable, occurred_at timestamptz, metadata jsonb redacted)

## Accounting
- ledger_account(account_id uuid PK, entity_id uuid FK, code text, name text, kind text, currency char(3), parent_id uuid nullable, active boolean, unique(entity_id,code))
- accounting_period(period_id uuid PK, entity_id uuid FK, start_date date, end_date date, state text, closed_at timestamptz nullable)
- journal_entry(entry_id uuid PK, entity_id uuid FK, effective_at timestamptz, posted_at timestamptz nullable, status text, description text, source_kind text nullable, source_id uuid nullable, reversal_of uuid nullable, created_by uuid, idempotency_key text nullable, unique(entity_id,idempotency_key))
- journal_line(line_id uuid PK, entry_id uuid FK, entity_id uuid FK, account_id uuid FK, debit_minor bigint not null default 0, credit_minor bigint not null default 0, currency char(3) not null, line_order integer not null, unique(entry_id,line_order))
- reconciliation(reconciliation_id uuid PK, entity_id uuid FK, account_id uuid FK, period_end date, external_balance_minor bigint, ledger_balance_minor bigint, difference_minor bigint, state text, evidence_ref text nullable)
- reconciliation_match(match_id uuid PK, entity_id uuid FK, reconciliation_id uuid FK, observation_id uuid FK, entry_id uuid FK, state text)

## Provider / observation
- institution(institution_id uuid PK, provider text, provider_institution_id text, name text)
- connection(connection_id uuid PK, entity_id uuid FK, institution_id uuid FK, secret_ref text, state text, sync_cursor text nullable encrypted, last_synced_at timestamptz nullable)
- external_account(external_account_id uuid PK, entity_id uuid FK, connection_id uuid FK, provider_account_id text, display_name text, mask text nullable, account_kind text, currency char(3), ledger_account_id uuid nullable, unique(connection_id,provider_account_id))
- transaction_observation(observation_id uuid PK, entity_id uuid FK, external_account_id uuid FK, provider_transaction_id text, provider_revision integer, amount_minor bigint, currency char(3), description_raw text, merchant_raw text nullable, authorized_at timestamptz nullable, posted_at timestamptz nullable, pending boolean, removed boolean, pending_provider_transaction_id text nullable, observed_at timestamptz, payload_ref text nullable, unique(external_account_id,provider_transaction_id,provider_revision))
- sync_run(sync_run_id uuid PK, entity_id uuid FK, connection_id uuid FK, started_at timestamptz, finished_at timestamptz nullable, state text, added_count integer, modified_count integer, removed_count integer, error_code text nullable)

## Intelligence
- merchant(merchant_id uuid PK, canonical_name text)
- category(category_id uuid PK, entity_id uuid FK, name text, parent_id uuid nullable)
- classification_rule(rule_id uuid PK, entity_id uuid FK, priority integer, predicate_json jsonb, action_json jsonb, enabled boolean)
- classification_decision(decision_id uuid PK, entity_id uuid FK, observation_id uuid FK, rule_id uuid nullable, confidence numeric(5,4), explanation text, reviewed_by uuid nullable)
- exception(exception_id uuid PK, entity_id uuid FK, kind text, severity text, evidence_json jsonb, detected_at timestamptz, state text, reviewed_at timestamptz nullable)

## Database enforcement
- journal lines require debit_minor >= 0 and credit_minor >= 0 and exactly one positive side.
- enforce at least two lines and SUM(debit_minor)=SUM(credit_minor) per currency at posting, inside transaction/serialized posting procedure, not just API code.
- posted entries and lines are immutable via DB permissions and trigger/policy; reversals create new entries.
- prevent cross-entity FK references via composite keys/constraints.
- prevent overlapping accounting periods per entity with exclusion constraints or equivalent locking.
- uniqueness and transactional cursor advancement protect against webhook replay.
- restrict app role to runtime DML, migrations to separate deployment role; no app superuser.
- enable row-level security as defense in depth only if integration and connection-pooling safety are proven.
- explicit indexes for entity+date on journal/observation, entity+status on exceptions, connection+sync on observations.
- create migration tests for concurrency, reversal, deduplication, tenant isolation, currency mismatch, overflow and restore.
