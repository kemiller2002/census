# Connectivity and experience requirements

## CEN-009 Plaid integration
Implement a provider-neutral IFinancialDataProvider in F#. Plaid Link authorization via server-generated link token, short-lived public token exchange server-side, encrypted access token reference, /transactions/sync with cursor checkpoint, webhooks authenticated according to Plaid's documented mechanism, paginated sync, retry/backoff, removal handling, reauthorization, disconnect, and account mapping. Never put Plaid secrets in browser bundles. Acceptance: sandbox tests for initial sync, cursor replay, modification/removal, duplicates, and webhook redelivery; account coverage and data freshness visible.

## CEN-010 Authentication and authorization via Fides
Evaluate Fides actual supported OIDC/OAuth2 capabilities and trust boundaries before integration. Require authentication, server-validated sessions, CSRF protection for state-changing operations, secure cookies, session revocation, MFA support or documented external IdP enforcement, per-entity roles (owner, administrator, accountant, viewer), explicit permission checks server-side, and audit logging. Never rely on UI role hiding. Acceptance: authorization matrix tested for every API and cross-entity access; no unauthenticated access to financial data.

## CEN-011 Limen + Forma application
Use Limen WASM where supported, with a progressively rendered accessible HTML shell. Forma components for account connections, transactions, journal review, reconciliation, dashboards, exception queue, and settings. Folio only where suitable for printable reports. Do not ship sensitive data in static assets or publicly hosted GitHub Pages. Acceptance: keyboard accessibility, mobile layouts, empty/error/loading states, and no sensitive payloads cached by default.

## CEN-013 WebAssembly loading screen
Render HTML/CSS loading shell before WASM downloads. Show Census identity, accessible status message (aria-live polite), indeterminate progress until verifiable progress is available, explicit retry action on failure, timeout/recovery, reduced-motion support, and high-contrast focus states. Never invent percentage. Authenticate before loading protected financial data, not necessarily before fetching public WASM binary. Acceptance: simulated slow 3G, offline, WASM initialization error, keyboard-only and screen reader scenarios; first paint does not depend on WASM.

## CEN-015 Reporting
Produce entity-scoped balance sheet, income statement, cash-flow classification with reconciliation, spending trends, weekly exceptions and monthly review. Reports must disclose incomplete connection coverage, stale sync, unposted observations and open reconciliations. Acceptance: balances reconcile to posted journal and coverage gaps cannot appear as zero spend.
