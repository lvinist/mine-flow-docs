# Handoff Report: Benchmark Edit-Route Push Navigation Defect Resolution

## 1. What I changed
- `lib/core/presentation/widgets/app_interaction_primitives.dart`:
  - Guarded `didPushNext()` in `_AppResponsiveSheetState` with `if (widget.isDirty)` so that only dirty sheets request dismissal evaluation when a route is pushed on top of them. Clean sheets (such as `BenchmarkInspectorScreen`, which is read-only) remain mounted in the background without triggering an approved pop that unmounts the incoming route.
- `test/app/router_test.dart`:
  - Added `observers: [routeObserver]` to `_buildTestRouter` to match production routing behavior.
  - Added test case `push transition from benchmark inspector to edit form mounts edit view` in the `Benchmark route paths` group.
- `test/features/benchmark/presentation/benchmark_navigation_test.dart`:
  - Created a targeted navigation and push transition test suite testing direct route navigation to `BenchmarkFormScreen`, push navigation from `BenchmarkInspectorScreen` via `Key('benchmark_edit_button')`, and the complete list-to-inspector-to-edit user journey flow with `routeObserver` active.
- `Upcoming Prompts/mine-flow-STEP-55.4-FINDINGS.md`:
  - Appended a dated section `E2E Residual Fix: Benchmark Edit-Route Push Navigation — 2026-09-24` detailing the root cause, fix, verification commands, and pass counts.

## 2. Why
In `integration_test/journeys/benchmark_journey_test.dart:189`, tapping `Key('benchmark_edit_button')` resulted in `Found 0 widgets with type "BenchmarkFormScreen"` because `AppResponsiveSheetState.didPushNext()` invoked `_requestDismiss(AppDismissReason.parentNavigation)` unconditionally whenever a route was pushed on top of an `AppResponsiveSheet`. For a clean sheet (`isDirty: false`), the dismissal controller returned `dismiss`, scheduling a post-frame `context.pop()` that popped the newly pushed `BenchmarkFormScreen` on the very next frame. Guarding `didPushNext()` with `if (widget.isDirty)` aligns implementation with the documented design contract and prevents premature dismissal.

## 3. Verification Record
- **Deep Verification (ran actual tests):**
  - `flutter test test/features/benchmark/presentation/benchmark_navigation_test.dart`: 3/3 passed (including direct navigation, inspector edit button push, and list -> inspector -> edit journey flow with `routeObserver` active).
  - `flutter test test/app/router_test.dart test/features/benchmark/`: 82/82 passed (40 benchmark + 42 router tests).
  - `flutter test test/features/benchmark/core/utils/crs_utils_test.dart test/features/benchmark/presentation/benchmark_bloc_test.dart`: 35/35 projection rejection and core benchmark tests passed.
  - `flutter test`: 822/822 passed (5 skipped across the entire repository).
  - `flutter analyze`: 0 issues found.
  - `dart format --output=none --set-exit-if-changed lib/core/presentation/widgets/app_interaction_primitives.dart test/app/router_test.dart test/features/benchmark/presentation/benchmark_navigation_test.dart`: exited 0 (all formatted).
  - `dart run tool/check_l10n_baseline.dart`: exited 0 with `[OK] No new hardcoded strings detected in non-exempt files.`
  - `dart run tool/check_supabase_contracts.dart`: exited 0 with `[OK] Contract verification passed.`
- **Shallow Verification (manual run only):**
  - Inspected route declarations in `lib/app/router.dart` and sheet implementations across other features.
- **Unverified aspects:**
  - Live execution of `integration_test/journeys/benchmark_journey_test.dart` against a live Supabase staging backend on Chrome/Android (test is credential-gated for CI; desktop Windows platform is unconfigured in this repository).

## 4. Known Issues
- `Minor Robustness Risk`: If an interactive form sheet is dirty when a nested route is pushed on top of it, `didPushNext` still triggers discard confirmation for the parent sheet. This matches the documented contract in `app_interaction_primitives.dart`, but sub-route navigation from dirty sheets is rare in practice.

## 5. Untested Edge Cases & Next Step
- Reviewer should run the CI web and android E2E pipeline for `benchmark_journey_test.dart` with valid staging credentials to observe live push transition on real browser and mobile targets.
