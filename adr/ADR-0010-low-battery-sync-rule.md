# ADR-0010: Low-Battery Sync Rule

**Status:** Proposed
**Date:** 2026-07-29

## Related documents
- architecture/15-native-app-architecture.md
- Upcoming Prompts/mine-flow-STEP-39-PLAN.md

## Context
During Phase 2 Tier 2, we needed to formalize the low-battery synchronization policy for the native app architecture. The app requires a robust offline capability and syncing mechanisms without unnecessarily draining field workers' batteries. A state table rule needs to be adopted to definitively control this behavior.

## Decision
1. **Low-Battery Sync Rule:** Adopt a "Hybrid" approach where background/automatic sync pauses if OS Battery Saver is ON OR raw battery is <= 20%. 
   - **Rationale:** Protects field workers' battery life while ensuring data can still be forcefully synced if absolutely necessary.
   - **Manual syncs:** Allowed regardless of battery level.
   - **Charging:** Bypasses the pause (sync proceeds normally).
   - **Fallback:** If battery status is unavailable (e.g. Web), treat as healthy.

## Consequences
- Implementation of the `battery_plus` package is required to properly detect battery state and battery saver mode across platforms.
- `sync_queue_manager.dart` will be modified to respect these new rules.
