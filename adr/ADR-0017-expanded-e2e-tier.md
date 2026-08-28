# ADR-0017: Expanded Dual-Platform E2E Test Tier

**Status:** Accepted
**Date:** 2026-08-27

## Context
The project initially targeted a "few E2E tests" (as documented in `12-test-strategy.md`) running on an unspecified CI environment. As we approach release readiness, the lack of verifiable offline sync behavior and UI routing fidelity against real data necessitated an expanded E2E test suite. In STEP-45, we expanded the E2E coverage to cover all Tier-1 and Tier-2 features. Additionally, because the application targets both Android and Web platforms with distinct routing and rendering behavior, a single-platform E2E gate was deemed insufficient.

## Decision
1. We will expand the `integration_test` E2E tier to comprehensively cover all Tier-1 and Tier-2 features, including a robust offline/sync journey.
2. We will enforce a **dual-platform E2E CI gate**, running the full `integration_test` suite on both Chrome (web) and a booted Pixel 6a Android emulator in CI.
3. These tests will execute against the dedicated Staging Supabase environment, injecting credentials securely via CI secrets.

## Consequences
- **Positive:** We gain high confidence in field-critical workflows (like offline sync, conflict resolution) and platform-specific routing bugs (like deep-linking on web) before deployment.
- **Negative:** Running Android emulators in CI is resource-intensive and will increase PR pipeline execution time. Maintenance of the E2E suite will require more effort.
