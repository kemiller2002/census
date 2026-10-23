# Census architecture

These are proposed component relationships, subject to verification against installed Echelon releases.

```mermaid
flowchart TD
  Browser[Browser HTML loading shell] --> Limen[Limen WASM + Forma UI]
  Limen --> API[F#/.NET Census API]
  API --> Fides[Fides / trusted identity provider]
  API --> Ledger[Double-entry ledger]
  API --> Reports[Financial intelligence + Folio]
  API --> Provider[Provider-neutral ingestion]
  Provider --> Plaid[Plaid API]
  Plaid --> Hooks[Signed webhooks]
  Hooks --> Queue[Ingestion queue]
  Queue --> Provider
  Ledger --> PG[(Private AWS PostgreSQL)]
  Provider --> PG
  Reports --> PG
  Strata[Strata schema management] --> PG
  Arca[Arca persistence adapter - if compatible] --> PG
```

```mermaid
sequenceDiagram
  participant User
  participant UI as Census UI
  participant API as Census API
  participant Plaid
  participant DB as PostgreSQL
  User->>UI: Connect account
  UI->>API: Request link token (authenticated)
  API->>Plaid: Create link token
  Plaid-->>UI: Link token
  User->>UI: Authorize institution through Plaid Link
  UI->>API: Exchange public token
  API->>Plaid: Exchange token
  API->>DB: Store secret reference + connection metadata
  Plaid-->>API: Transaction update webhook
  API->>Plaid: Incremental transaction sync
  API->>DB: Store observations and cursor atomically
  API->>DB: Match, classify, propose balanced postings
```

```mermaid
flowchart LR
  Start[HTML shell paints] --> Fetch[Download WASM and assets]
  Fetch --> Init[Initialize Limen runtime]
  Init --> Auth[Check authenticated session]
  Auth --> Ready[Render Census dashboard]
  Fetch -->|network failure| Fail[Accessible error + Retry]
  Init -->|runtime failure| Fail
  Auth -->|unauthorized| Login[Secure sign-in]
```

## Boundary rules
- Browser has no Plaid access token, DB credentials or signing secrets.
- Identity is server-verified; authorization always occurs on API.
- Plaid observations are not journal postings.
- Journal posting is balanced, transactional and immutable.
- Provider sync cursor is committed with the complete observation batch.
- GitHub Pages can serve only public, cache-safe shell assets, never private financial records.
