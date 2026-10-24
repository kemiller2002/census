# CEN-048..052 UI, API, Forma/Limen and integration contracts
Status: normative; wireframes and API implementation unverified.

## CEN-048 API contract
- Versioned OpenAPI 3.1 as source of truth for /api/v1; generate or validate F# request/response DTOs. Every operation documents auth permission, entity scope, nested IDs, pagination, sorting, filtering, errors, limits, idempotency, audit and cache policy. Standard problem responses with safe error codes and correlation ID; never leak SQL, tokens or private stack traces.
- Mutating financial operations require idempotency key with actor/entity/operation scope, bounded lifetime and payload hash; conflicting replay returns explicit conflict. Optimistic version checks on drafts/reviews and durable operation outcome on retries. Explicit time zone and minor-unit currency conventions.
- Separate /health/live and /health/ready, minimal public details. Same-origin browser API; private data responses no-store; CDN must bypass API caching. Content Security Policy, HSTS, CSRF, origin validation, output encoding and file download protections.

## CEN-049 UI screen contracts
- UI-01..UI-12 from requirements/ui-screen-design.md are mandatory. For every page create screen specification: navigation, fields/labels, table columns, sorting/filtering, permissions, actions/confirmations, loading/empty/error/partial/unauthorized/offline states, keyboard behavior and mobile 320px layout.
- Map each visible action to exact OpenAPI operation or explicitly mark disabled/unimplemented. Do not present simulated actions as working. Entity switching clears stale in-memory financial state and cancels outstanding requests. Require step-up/confirmation for sensitive connection, export and role changes.

## CEN-050 Forma and Limen
- Pin verified immutable Forma/Limen releases. Use canonical Forma patterns and semantic color/brand tokens, no local forks or invented <ef-*> behavior. Limen handles browser interactions, WASM bootstrap and state transitions; F# domain owns accounting/authorization. Check component mapping against the pinned release, not main.
- Immediate static accessible loading shell independent of WASM, with meaningful states and failure/retry; no fabricated progress. Tests: slow network, offline, initialization failure, reduced motion, high contrast, 200% zoom, keyboard, screen reader, accessible chart table alternatives.
- Build-time semantic token validator, machine-operability contract and browser visual regression on desktop/tablet/mobile.

## CEN-051 API-to-database boundary
- API/worker can execute only approved census_api routines and no direct table SQL. API validates authenticated actor and membership; routines independently enforce tenant/resource scope using a proven, nonspoofable authorization design. Every endpoint has negative tenant/role tests. Keep DB role credential out of browser and worker-specific privileges separate.

## CEN-052 User journeys
- End-to-end: create personal/entity book -> invite member -> link bank -> approve account mapping -> sync -> classify -> draft/post -> reconcile -> close period -> view statements -> export -> disconnect/revoke. Also deny invite, connection failure, partial sync, invalid journal, revoked membership and restore/offline cases.
- Acceptance: test each journey against seeded local PG16 + fake provider with real API and UI, capture screenshots and trace requirements to test IDs.
