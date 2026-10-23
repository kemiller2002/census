# CEN-029: Mandatory Forma conformance for all Census UI

Status: required design/implementation gate. Derived from kemiller2002/forma docs/CONSUMING-FORMA.md, docs/AGENT-USAGE.md, docs/COMPONENT-INVENTORY.md and docs/BRANDING.md (reviewed 2026-10-23). No Census UI implementation has yet been audited.

## Authority and version
- Pin an immutable released @echelon-foundry/design-system artifact. Forma's consumer guide says application baseline 0.9.1, but its sample dependency URL still points to v0.3.0; **verify published release assets and hashes before selecting the actual pin**. Never track main, copy Forma CSS or invent an npm package URL.
- Import documented package CSS (typically @echelon-foundry/design-system/all.css), register optional behavior-free runtime diagnostic once and report actual Forma/Limen/Fides versions.
- Canonical pattern markup comes from pinned package patterns/*, using inert <ef-*> wrappers around native semantic HTML and .ef-* classes. Never customElements.define these wrappers or treat Forma as a JS component framework.
- Before building each control, search the pinned patterns and inventory. Inventory on reviewed main reports 168 implemented components and 29 requirements-only; never assume unimplemented catalog items exist.

## Ownership
Forma owns visual patterns, tokens, responsive geometry, accessible presentation, non-color cues and motion. Census owns domain content and screen data. Limen owns browser I/O and effects; F# application/Ordo owns legal state transitions and authorization; Census API owns server authority. Never implement financial logic, permissions or async behavior in Forma CSS or markup.

## Screen mapping (verify exact patterns in pinned artifact)
- Sign-in/boot: form, operation-status, progress-bar, fault presentation, button.
- App shell: workspace-shell/navigation-shell, sidebar, skip-link, scope-trail, mobile-action-bar.
- Overview: surface, grid, key-value list, status-lozenge, data visualization patterns where actually implemented.
- Transactions: collection-toolbar, search, date-range, data-grid, pagination, flyout, validation-message.
- Accounts/connections: surface, status-lozenge, data-grid, dialog, operation-status.
- Journal: form, form-row, text-field, select, numeric input patterns, validation-summary, dialog.
- Reconciliation: data-grid, split layout, choice group, operation-status, dialog.
- Exceptions: collection-toolbar, status-lozenge, flyout, fault/notification.
- Reports: tabs, data-grid, chart patterns if implemented; always accessible tabular alternative.
- Settings: form, switch, select, dialog, validation summary.
This is a candidate map, not proof each pattern is in the selected release. Resolve every mapping against the exact pinned inventory and record any gaps.

## Styling, accessibility, responsiveness
- Use documented --ef-* semantic tokens, Forma layout primitives, approved color pairings and Forma-provided brand manifests/skins. No arbitrary hardcoded color, local fork, copied CSS or guessed --ef-color-* variable.
- Run the pinned Forma color-contract validator against Census CSS. Prefer built-in theme/brand, data-ef-theme and data-ef-skin. A Census-specific brand must be compiled through Forma's Brand Manifest contract.
- Preserve native labels, ARIA relationships, focus management, reduced motion, non-hue status, forced-colors, 320px layout and 200% zoom.
- Machine operability: each action discoverable by role/name and its completion observable; no coordinate-only actions or test IDs as canonical interface. Read Forma's machine-operability and universal UI conformance contracts.

## Required artifacts before implementation signoff
1. Exact Forma release/version/hash and a working package installation.
2. Screen-by-screen matrix of every control -> actual pinned pattern -> native semantics -> Limen action -> Census API operation.
3. Desktop/mobile wireframes using canonical patterns, with loading/empty/error/unauthorized states.
4. Screenshot baselines and browser accessibility/keyboard/zoom/forced-colors tests.
5. Automated check rejecting copied Forma CSS, unknown semantic tokens and unapproved component duplication.
6. Gaps submitted as requirements to Forma's own Praxis input convention, not implemented as undocumented Census component forks.

## Acceptance
`make verify` runs conformance checks, including CSS token validation and browser tests. A screen fails review if it invents an existing Forma primitive, violates pattern markup, hides a state in color only, or uses unapproved styling. No production UI release until every screen's pattern matrix and test evidence are complete.
