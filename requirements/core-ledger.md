# Core financial domain requirements

## CEN-001 Entity and tenant isolation
Represent legal entities and personal books separately. Fields: entity_id UUID PK, display_name text, entity_type enum(personal,llc,corporation,other), functional_currency char(3), created_at timestamptz. Every account, observation, journal, and report is entity-scoped. Cross-entity access denied by default. Acceptance: tests demonstrate no cross-entity read/write access.

## CEN-002 Financial account registry
Fields: account_id UUID PK, entity_id UUID FK, institution_id UUID nullable FK, provider_account_id text nullable, account_type enum(asset,liability,equity,income,expense), account_subtype text, currency char(3), active boolean, created_at timestamptz. External institution accounts must be mapped to general-ledger accounts explicitly. Acceptance: one external account can be reconnected without duplicating ledger identity.

## CEN-003 Double-entry journal
journal_entry(entry_id UUID PK, entity_id UUID FK, effective_at timestamptz, posted_at timestamptz, description text, source_kind text, source_id UUID nullable, reversal_of UUID nullable, status enum(draft,posted,reversed)); journal_line(line_id UUID PK, entry_id UUID FK, account_id UUID FK, debit_minor bigint, credit_minor bigint, currency char(3)). Enforce nonnegative values, at most one nonzero side per line, minimum two lines, balanced totals per currency at posting, same entity across lines, atomic posting. Do not permit mixed-currency balancing without explicit FX clearing entries. Acceptance: property-based tests reject unbalanced postings, overflows, entity mixing, and duplicate source posting.

## CEN-004 Immutable corrections and period controls
Posted entries are append-only; corrections use compensating reversals and replacements. Support close periods with authorized reopening and auditable reason. Fields: accounting_period(period_id UUID, entity_id UUID, start_date date, end_date date, state enum(open,closed), closed_at timestamptz nullable). Acceptance: no mutation of posted lines; closed-period posting rejected.

## CEN-005 Reconciliation
Bank observations and posted journal entries are separate. Reconciliation records external balance snapshots, statement periods, matching evidence, discrepancies and review decisions. Fields: reconciliation_id UUID, account_id UUID, period_end date, external_balance_minor bigint, ledger_balance_minor bigint, difference_minor bigint, state enum(open,reviewed,closed), evidence_ref text. Acceptance: credit-card payments and transfers do not count as expenses; reconciliation detects missing, duplicate, and mismatched transactions.

## CEN-006 Observation provenance
institution(institution_id UUID, provider text, provider_institution_id text, display_name text); connection(connection_id UUID, entity_id UUID, institution_id UUID, secret_ref text, state text, sync_cursor_ref text nullable, last_synced_at timestamptz nullable); transaction_observation(observation_id UUID, connection_id UUID, provider_transaction_id text, provider_account_id text, amount_minor bigint, currency char(3), authorized_at timestamptz nullable, posted_at timestamptz nullable, merchant_raw text nullable, description_raw text, pending boolean, removed boolean, payload_ref text, observed_at timestamptz). Unique(provider connection, provider transaction ID, observation revision); preserve provider corrections and pending-to-posted relationships. Acceptance: replays are idempotent and source payloads traceable without placing sensitive data in logs.

## CEN-007 Classification and transfer matching
merchant(merchant_id UUID, canonical_name text), category(category_id UUID, entity_id UUID, name text, parent_id UUID nullable), classification_rule(rule_id UUID, entity_id UUID, priority integer, predicate_json jsonb, action_json jsonb, enabled boolean), classification_decision(decision_id UUID, observation_id UUID, rule_id UUID nullable, confidence numeric(5,4), explanation text, reviewer_id text nullable). Never automatically post ambiguous transfers or owner draws as expenses. Acceptance: deterministic rules are reproducible, manual overrides survive resync, cross-account transfers are matched.

## CEN-008 Financial intelligence
Recurring merchant and subscription detection, duplicate charges, unusual amount changes, missing expected deposits, spend trends, category variance, and institution sync gaps. Exception fields: exception_id UUID, entity_id UUID, kind text, severity text, evidence_json jsonb, detected_at timestamptz, status text, reviewed_at timestamptz nullable. Acceptance: every alert has explainable evidence, suppression rules, and explicit coverage limitations.

## CEN-012 Summa reuse audit
Before coding the ledger, locate the actual Summa financial requirements and source (the currently observed kemiller2002/summa README describes a Praxis administration hub). Produce a traceability matrix: requirement, source, reusable implementation, gap, compatibility, decision. No assumed reuse. Acceptance: architectural decision record signed off before duplicating a ledger.
