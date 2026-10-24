# CEN-037..042 Accounting, ledger, reconciliation and reporting
Status: normative; executable implementation unverified. P0 accounting integrity.

## CEN-037 Chart of accounts and periods
- Per-entity chart with unique codes, parent hierarchy without cycles, active/archived state, account kind and currency; explicit external-to-ledger mapping. Immutable account identity; changing mapping must preserve historical evidence.
- Accounting periods are non-overlapping per entity, have explicit time zone/date convention, and close/reopen with permission, reason, timestamp and audit. Closing requires configured reconciliation policy; late observations do not silently reopen or modify closed journals.

## CEN-038 Journal lifecycle
- States draft -> posted; corrections via separate reversal entry, never mutation of posted entry or lines. Posting requires >=2 lines, one positive debit OR credit per line, sums equal by currency, same entity across lines, valid accounts, open period, authorized actor and source uniqueness.
- Atomic database enforcement under concurrent transactions. Validate bigint overflow, negative/zero line, duplicate idempotency key, stale draft, invalid reversal target, double reversal and time-zone boundaries. Posting API accepts server-calculated balances only. Record who created, reviewed, posted and reversed; provide optional separation-of-duties policy for material entries.
- No automatic posting from ambiguous observations. Any automatic posting rule is explicitly enabled, scoped, audited, versioned, thresholded and reversible.

## CEN-039 Transfers, credit and currency
- Transfers between owned accounts must produce offsetting asset/liability movements, not income/expense. Credit-card charges, payments, refunds, fees, interest, cash advances and chargebacks have distinct classifications and examples.
- Define signed external observation normalization by provider/account kind; test both debit and credit signs. For multicurrency, do not net unlike currencies; use explicitly recorded FX rates, rate source/time, conversion and clearing accounts. If FX is not implemented, block multicurrency posting rather than guess.

## CEN-040 Reconciliation
- Reconciliation state open -> reviewed -> closed; define snapshot of statement closing balance, currency, period and external evidence; support one-to-one and explicitly reviewed many-to-many matches with stable IDs and provenance.
- Suggested matches are not authoritative. Prevent reuse of observation/journal lines in conflicting closed matches. Close only if policy-defined outstanding difference is zero and required exceptions are resolved; closing is atomic and idempotent. Corrections after close require explicit reopen or adjustment workflow, audit and re-review.
- Test duplicate observations, partial deposits, transfers, pending/posting transitions, reversed journals, out-of-order feeds, provider outages and concurrency.

## CEN-041 Financial analytics
- Deterministic versioned classification rules: typed safe predicate grammar, no executable SQL/script injection, explicit precedence, conflict handling, reviewer overrides and historical provenance. Alerts include evidence, coverage, confidence, source freshness and suppression reason; never equate missing bank coverage with zero activity.
- Specify measurable detectors for duplicate charges, recurring charges, unusual amounts, missed expected deposits and sync gaps. Each detector needs synthetic positive/negative examples, false-positive policy and threshold configuration.

## CEN-042 Financial statements and exports
- Balance sheet from posted balances as-of period, income statement over selected period, cash-flow classification with transfer exclusion, spending trends with coverage notices. Define report filters, currencies, period basis, rounding, completeness flags and reconciliation to source journals.
- Authorized exports: CSV with spreadsheet formula-injection mitigation, PDF where supported, explicit entity/time range, audit event, size cap, no-store, expiring delivery and redaction. Never cache sensitive exports on public CDN. Every report has accessible tabular alternative.
- Acceptance: golden synthetic ledger fixtures with expected journal, reconciliation and report totals; property-based invariants and concurrent posting tests.
