# ADR-0009: UI Design System Drift

**Status:** Accepted
**Date:** 2026-07-29

## Related documents
- architecture/07-ui-design-system.md
- architecture/15-native-app-architecture.md
- Upcoming Prompts/mine-flow-STEP-39-PLAN.md

## Context
During Phase 2 Tier 2 audit validation, intentional UI deviations from the documented architecture were found. The implementation drifted to include Geist typography and 5 permanently visible mobile navigation items, diverging from the initial Inter font and standard bottom tab bar designs. We need to formalize these UI drift decisions to align the architecture with the implementation.

## Decision
1. **Typography:** Approve `Geist` font as the primary UI font, replacing Inter.
   - **Rationale:** Geist provides a better data-dense aesthetic for our specific dashboard requirements.
2. **Mobile Navigation:** Approve 5 permanently visible mobile navigation items.
   - **Rationale:** Accommodates all primary foreman workflows without burying them in menus.

## Consequences
- The design system documentation is updated to reflect Geist and the new navigation structure.
