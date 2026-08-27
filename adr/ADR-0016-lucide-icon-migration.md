# ADR-0016: Lucide Icon Migration

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/07-ui-design-system.md (§5 — Lucide)
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-088)

## Context
STEP-46.3 (CF-088) found the app uses Material `Icons.*` throughout, while the
design system (Doc 07 §5) specifies Lucide icons. The result is visual drift from
the approved design tokens and inconsistent glyph styling.

## Decision
1. **Migrate to Lucide repo-wide**: add the `lucide_icons` package and replace
   Material `Icons.*` usages with their Lucide equivalents across all screens and
   widgets.

## Consequences
- **Implementation status: decision locked, implementation pending.** This is a
  broad, mechanical sweep across ~dozens of files; it is sequenced separately
  from the higher-priority P1 logic remediation so each change stays reviewable.
- After migration, `Icons.*` should be absent from `lib/` (the existing
  "Impeccable purge" tests can be extended to assert this).
