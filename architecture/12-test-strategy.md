# 12. Test Strategy

**Version:** 1.2
**Status:** Approved
**Last updated:** 2026-08-29

- **Test tiers**: Follow a standard Test Pyramid. Unit tests (many, fast), integration tests (some, mocking the backend), and E2E tests (few, testing the real flow).
- **Coverage priorities**: Heavy focus on data entry validation, state management (BLoC), and role-based access control (RLS equivalents on the client). Less focus on UI layout code and third-party libraries.
- **Coverage tooling and reporting**: Use `flutter test --coverage` (producing LCOV). Used as a trend indicator, not a strict numeric gate. Durable summaries stored in `reports/test-results/` only for major milestones.
- **Test data & isolation**: Fake data generated via tools like `mocktail` or `mockito`. Each test gets a fresh state. 
- **Mocking strategy**: Mock all external boundaries (Supabase client, Google Drive API) for unit and integration tests. Test internal Flutter/BLoC code for real.
- **System/e2e testing**: Embedded in the single Flutter repository using `integration_test`. Covers all Tier-1 and Tier-2 features and runs against a dedicated Supabase "Staging/Test" project environment.
- **CI gates**: Commits/merges are blocked by: Linting/Formatting checks, Static Analysis (`flutter analyze`), Unit/Integration Tests (must pass 100%), Dual-Platform E2E (Chrome and Pixel_6a emulator), and a successful app Build.
- **Performance / load testing**: Skipped for the MVP given the scale (~100 users, single site) and backend choice (Supabase Cloud).
- **Coding standards**: Retained and applied the `dart.md`, `sql.md`, and `shell.md` standards; pruned unused languages.

## Open Questions

- None at this time.

## Version Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-18 | Initial Architecture | Created initial Test Strategy |
| 1.1 | 2026-08-27 | Antigravity | Expanded E2E tier (Tier-1/2) and added dual-platform CI gate (ADR-0017) |
| 1.2 | 2026-08-29 | Antigravity | Clarified Chrome E2E execution via flutter drive (STEP-47.8) |

## Details

### 1. Test Tiers
The testing approach follows the standard Test Pyramid:
- **Unit Tests:** High volume, very fast execution. Covers isolated pure logic like formatting, arithmetic, data entry validation, and simple widget states.
- **Integration Tests:** Medium volume. Covers interactions between BLoC state management and the mocked data access layer.
- **End-to-End (E2E) Tests:** Low volume, high fidelity. Covers all Tier-1 and Tier-2 critical user journeys (including offline/sync) by driving the UI on real platforms (Chrome and Android) and interacting with a staging database.

### 2. Coverage Priorities
Rather than chasing an arbitrary 100% test coverage metric (though ~80% remains a healthy guideline), testing effort is concentrated on risk:
- **Must Cover:** Data validation (cut/fill numbers, equipment check arrays), State transitions (loading/success/error in BLoCs), Role-based view logic.
- **Less Focus:** Static UI layout padding/colors, and behaviors internal to third-party SDKs (Supabase, Google Drive).

### 3. Coverage Tooling and Reporting
- **Tool:** Flutter's built-in `flutter test --coverage` which outputs LCOV.
- **Reporting:** Detailed LCOV/HTML reports are kept as ephemeral CI artifacts. For major releases or check-ins, a human-readable summary will be committed to `reports/test-results/`.
- **Threshold:** Treated as a visibility and trend signal rather than a rigid CI failure gate.

### 4. Test Data & Isolation
To prevent tests from mutating shared state and causing flaky failures:
- Test data (fixtures) will be generated locally in memory using standard Dart mocking libraries.
- Unit and integration tests will intercept and mock backend calls. No real database network requests are made.

### 5. System / End-to-End Tests
Since the project is built in a monorepo-style single Flutter app, the E2E tests live directly inside the app repository using the `integration_test` package. To avoid polluting production data, these tests run against a distinctly provisioned Supabase Test environment on both Chrome (executed via `flutter drive` and chromedriver) and a Pixel 6a Android emulator.

### 6. CI Gates
The following checks run on merge requests. A failure in any of these gates blocks the merge:
- Code Formatting & Linting (`dart format` / `flutter analyze`).
- Unit & Integration Test Suite (`flutter test`).
- Dual-Platform E2E Tests (Chrome via `flutter drive` and Pixel 6a via `flutter test`).
- Build Check (ensuring the app compiles).

### 7. Performance / Load Testing
Formal load testing is deferred. The MVP scales to roughly 100 local users, which falls well within the normal operating bounds of the managed Supabase infrastructure. Performance testing will be revisited in Phase 2 for multi-site deployment.

### 8. Coding Standards
The following coding standard rulesets govern the project and reside in [`coding-standards/`](../coding-standards/):
- [`dart.md`](../coding-standards/dart.md) for the Flutter application codebase.
- [`sql.md`](../coding-standards/sql.md) for Supabase Postgres rules and queries.
- [`shell.md`](../coding-standards/shell.md) for basic dev and CI scripts.
