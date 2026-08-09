# ADR-0008: Impeccable Bridge and UI Design Tokens

**Status:** Accepted
**Date:** 2026-07-22

## Related documents
- architecture/07-ui-design-system.md
- ADR-0007-rescope-phase2.md

## Context
During Phase 2 (Impeccable UI Rebuild), a conflict emerged between the Impeccable input contracts (`DESIGN.md` and `PRODUCT.md` at the workspace root) and the canonical architecture documentation (`architecture/07-ui-design-system.md`). The input contracts contained static design tokens, while the actual implementation evolved to use `shadcn-admin` and Flutter's `ColorScheme` tokens. Additionally, the workspace hygiene rule in `METHOD.md` §7 strictly forbids non-pointer files at the workspace root. We need to clarify the relationship between these files, establish which is canonical for UI tokens, and resolve the hygiene violation. This ADR amends ADR-0007's silence on UI tokens.

## Decision
1. **07-ui-design-system.md is canonical.** The architecture doc `07-ui-design-system.md` is the single source of truth for UI design tokens, conventions, and the `shadcn-admin` system.
2. **Root files are generated bridge context.** `DESIGN.md` and `PRODUCT.md` at the workspace root are explicitly allowed as unversioned, generated input contracts for the Impeccable agent. They are bridged context, not the canonical project truth.
3. **Amend METHOD.md.** We will amend `METHOD.md` §7 to explicitly name `DESIGN.md` and `PRODUCT.md` as allowed exceptions to the workspace-root hygiene rule.

## Consequences
- The UI token system remains robust and tied to the implementation reality rather than stale input docs.
- The Impeccable workflow can continue to use its expected input files at the root without violating project hygiene rules.
- Any future changes to the design system must update `07-ui-design-system.md`, and bridge scripts will need to read from it to generate the Impeccable context.
