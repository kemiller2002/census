# Census UI contract v1 (implementation baseline)

## Navigation
Application shell: Overview, Transactions, Accounts, Connections, Journal, Reconciliation, Exceptions, Reports, Settings. Entity switcher is persistent and explicit; never mix entities silently. Desktop sidebar, mobile navigation drawer. Use Forma components and Limen WASM when compatibility is verified.

## Global requirements
Keyboard navigation, visible focus, WCAG 2.2 AA target, semantic landmarks, reduced motion, 200% zoom and responsive 320px width. Every screen has loading, empty, stale-data, partial-data, error, unauthorized, forbidden and retry states as applicable. Show sync freshness and coverage prominently. Dates localized for display, API UTC; monetary values locale-formatted but stored in minor units. No silent destructive operations; confirmation and audit for reversals, connection removal and period reopening. All mutations show pending/success/failure and preserve input on retry. Never show raw secrets.

## Screen contracts
- Overview: entity, as-of time, connected-account coverage, cash and liabilities, income/expense trends, exceptions and reconciliation state; no false totals when data incomplete.
- Transactions: filters (date, account, merchant, category, state, amount), cursor paging, observation provenance, pending/posted markers, categorization override and match explanation.
- Accounts: institution, last sync, mapped ledger account, balances as-of, connection state, reconciliation health.
- Connections: Plaid Link, reconnect, institution errors, last successful sync, revoke/disconnect with clear retention consequences.
- Journal: debit/credit line editor, balance preview, draft/save/post, reversal history, closed period protection.
- Reconciliation: bank statement snapshot, proposed matches, unresolved differences, close only when balanced and authorized.
- Exceptions: evidence, severity, filters, suppress/reopen, human review decision.
- Reports: balance sheet, income statement, cash-flow classification, spend, monthly review, downloadable export after permission checks.
- Settings: entity membership, role management, preferences, retention, audit activity.

## WASM loading shell
HTML/CSS shell paints immediately before Limen boot. Census logo, app name, text status and indeterminate progress. No fabricated percentage. Status states: downloading, initializing, authenticating, loading authorized data, ready, offline, retryable error, unsupported browser. Timeout shows retry and support reference; status is aria-live polite, failure role=alert. Reduced-motion CSS. Protected data loaded only after session established. If WASM fails, accessible HTML error and retry remain operational. First contentful paint independent of WASM.

## Locked interaction rules
UI never queries PostgreSQL; all reads and mutations through same-origin /api/v1. API owns filtering, pagination, authorization, financial computations and authoritative validation. Client validation improves UX only. Never cache financial JSON in a service worker. Preserve unsaved drafts only in memory unless explicit secure persistence is designed. Cross-entity switch clears previous entity's in-memory sensitive state. Authentication expiry sends user to reauthentication without revealing protected data.
