# CEN-028: Census screen-by-screen UI design contract

Status: proposed implementation contract; no visual approval or working screens claimed. Source of truth for presentation is the installed, pinned Forma component library and design tokens. Limen owns browser/engine interaction boundary. No hand-coded parallel component system.

## Global layout
Desktop >=1024px: persistent left navigation (Overview, Transactions, Accounts, Connections, Journal, Reconciliation, Exceptions, Reports, Settings), top bar with entity switcher, date/as-of, sync status and account menu; content max width appropriate to tables, consistent spacing via Forma tokens. Tablet 600-1023px: collapsible nav. Mobile <600px: accessible drawer and single-column cards; tables become accessible responsive row summaries with drilldown, not horizontal clipping as sole strategy. No arbitrary hardcoded brand colors or spacing: derive from Forma tokens. Theme follows Forma-supported light/dark/high contrast.

## Page definitions and states
UI-01 Sign-in/session: Fides login initiation, callback progress, expired session, access denied, logout, secure return route.
UI-02 WASM boot: immediate static HTML/CSS shell, Census identity, status updates, reduced motion, retry/offline/failure. No fake progress percentages. Must survive runtime failure.
UI-03 Overview: entity/date header; summary tiles (cash, liabilities, net flow, unresolved exceptions); trend charts; account coverage and freshness; recent transactions; prioritized action queue. Cards link to filtered detail.
UI-04 Transactions: filter/search bar, date/account/category/status selectors, sort, cursor-paged table (date, merchant, account, category, amount, state); detail drawer with raw observation, classification explanation, matching, manual override and audit.
UI-05 Accounts: institution groupings, balance as-of, currency, account kind, linked ledger account, last sync, connection warnings; account detail history and mapping.
UI-06 Connections: institution tiles, add via Plaid Link, connection detail, reconnect, sync history, revoke with consequences; never display access tokens.
UI-07 Journal: entries table, status/period filters, draft entry editor with 2+ debit/credit rows, running balance difference, post confirmation, immutable history, reverse flow, closed-period error.
UI-08 Reconciliation: choose account/period, external and ledger balance summary, suggested match list with evidence, unmatched list, side-by-side review, close disabled until constraints pass.
UI-09 Exceptions: severity/status filters, evidence panel, reason and confidence, review/suppress/reopen actions, audit history, coverage disclaimers.
UI-10 Reports: report selector (balance sheet, income statement, cash flow, spending, monthly review), as-of and comparison filters, completeness notice, accessible chart/table alternatives, authorized export.
UI-11 Settings: entity membership/roles, identity/session, data retention/export, audit activity, preferences, security.
UI-12 Global feedback: forbidden/not-found, API unavailable, no connections, stale sync, partial coverage, empty search, optimistic conflict, success/error toasts, confirmation dialogs.

## Interaction rules
Every screen must have annotated desktop, tablet and mobile wireframes; component inventory mapping each control to a pinned Forma primitive; keyboard/tab/focus order; loading/empty/error/unauthorized/partial/offline states; field validation and API action mapping. Design first, implementation after approval. Every user action must map to a documented /api/v1 endpoint or be explicitly labeled read-only/unimplemented. No invented interactions. API owns authority; UI never talks to PostgreSQL. Browser cache must not retain sensitive financial data by default.

## Accessibility
WCAG 2.2 AA target; landmarks, labels, screen reader announcements, contrast, reduced motion, focus trapping/restoration for modal/drawer, responsive 320px width, 200% zoom. Charts must have accessible data tables. Money and negative values distinguishable without color alone.

## Visual acceptance
Produce one coherent reference implementation for desktop and mobile, screenshot/visual regression baselines, interaction tests, loading and failure screenshots, and a traceability matrix screen -> Forma components -> API operations -> acceptance tests. Review before mass implementation. Do not treat stock reference images as approved designs.

## Dependencies
CEN-011, CEN-013, CEN-024 API contracts, CEN-027 local stack, pinned Forma/Limen audit.