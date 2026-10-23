# Census requirements staging

These documents are the **source requirements draft**, not an assertion that Praxis has ingested them. An implementing agent must inspect the pinned Praxis installation and its input conventions, then move or copy them into the verified intake location without creating GitHub Issues.

## Documents
- [Core and ledger](core-ledger.md)
- [Integrations and UI](integrations-ui.md)
- [Infrastructure and security](infrastructure-security.md)

Each requirement has an identifier and verifiable acceptance criteria. Preserve IDs when importing into Praxis.

## Dependencies
CEN-001 -> CEN-002 -> CEN-003 -> CEN-004 -> CEN-005; CEN-006 depends on CEN-002; CEN-007 depends on CEN-003 and CEN-006; CEN-008 depends on CEN-007; CEN-009 depends on CEN-002; CEN-010 depends on CEN-009; CEN-011 depends on CEN-008; CEN-012 depends on CEN-003; CEN-013 depends on CEN-006 and CEN-010; CEN-014 is a release gate across all requirements.
