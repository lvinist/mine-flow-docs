# ADR 0007: Re-scope Phase 2 to Impeccable UI Rebuild

**Status:** Accepted
**Date:** 2026-07-21

## Context
Originally, Phase 2 of the mine-flow project was scoped as "Integration & Scale," which included features such as automated data imports (GPS, drone, telemetry), multi-site support, and full offline functionality for all features. This roadmap was established in the initial Architecture Overview and Phasing & Roadmap documents to prioritize proving the manual-entry workflows and data model during the MVP (Phase 1) before scaling up.

However, following the completion of the Phase 1 MVP, an evaluation of the resulting user interface revealed the need for a comprehensive design overhaul to ensure consistency, eliminate generic UI patterns, and achieve the desired professional and highly functional brand personality. The new requirement introduces a cross-cutting "Impeccable-driven" UI rebuild of all Phase 1 screens.

## Decision
We have decided to formally replace the original Phase 2 scope with the **Impeccable-driven UI rebuild of all Phase 1 screens**. 

The original Phase 2 scope—Integration & Scale (automated data imports, multi-site support, and full offline)—is not being dropped. Instead, it is being **deferred to Phase 3**, alongside the existing Phase 3 scope (Enterprise & Analytics).

## Consequences
- **Positive:** The UI rebuild is prioritized, ensuring that the application meets the strict visual and functional design standards required for field adoption before introducing more complex integrations.
- **Positive:** The original Integration & Scale goals are preserved in Phase 3, keeping the technical roadmap intact for future scaling.
- **Negative/Constraint:** Features like multi-site support and automated data imports are delayed. Future architectural choices must continue to respect the "Don't-Foreclose List" (e.g., maintaining the `site_id` data foundation) for a longer period before those features are actually implemented.

## Amendments
None.
