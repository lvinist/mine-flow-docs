# Original User Request

## 2026-09-24T13:22:35Z

This is a single self-contained fix; keep it small and focused.

Resolve the routed E2E residual for STEP-55.7 by updating `integration_test/journeys/equipment_check_journey_test.dart` to interact with `Key('equipment_filter_button')` and `AppFilterPopover` rather than expecting status filter buttons directly on the parent screen, ensuring all quality gates pass, and documenting the fix in findings.

Working directory: d:/AppDev/mine_flow/Code/mine-flow-app
Integrity mode: development

## Requirements

### R1. E2E Journey Test Filter Interaction
Update `integration_test/journeys/equipment_check_journey_test.dart` around lines 205-220:
- When filtering for flagged checks, tap `find.byKey(const Key('equipment_filter_button'))`, wait for the popover to appear, tap `find.byKey(const Key('filter_status_flagged'))`, tap `find.text('Terapkan')`, and verify the expected card appears.
- When filtering for passed checks, tap `find.byKey(const Key('equipment_filter_button'))`, wait for the popover, tap `find.byKey(const Key('filter_status_passed'))`, tap `find.text('Terapkan')`, and verify the non-matching card is absent.
- Ensure no bare `.ensureVisible` is called on popover children before opening the popover.

### R2. Quality Gates & Regression Verification
- Run widget test suites for equipment check:
  `flutter test test/widget/equipment_check_detail_screen_test.dart test/widget/equipment_check_form_test.dart test/widget/equipment_history_screen_test.dart` (ensure all pass).
- Verify static analysis with `flutter analyze`.
- Check formatting with `dart format --output=none --set-exit-if-changed <touched files>`.
- Run baseline checks: `dart run tool/check_l10n_baseline.dart` and `dart run tool/check_supabase_contracts.dart`.

### R3. Findings Addendum & STEP Index
- Append a dated addendum to `Upcoming Prompts/mine-flow-STEP-55.7-FINDINGS.md` documenting the E2E residual fix (root cause: filter controls moved into `AppFilterPopover` in STEP-55.7 while the E2E test asserted against the root scaffold; fix: opening popover and applying filter; test results).
- Prepare the replacement evidence row for `prompts/STEP-index.md` row 55.7.

## Acceptance Criteria

### Test Verification
- [ ] `integration_test/journeys/equipment_check_journey_test.dart` correctly opens the filter popover, selects flagged/passed status, and applies filter without throwing `Bad state: No element`.
- [ ] `flutter test test/widget/equipment_check_detail_screen_test.dart test/widget/equipment_check_form_test.dart test/widget/equipment_history_screen_test.dart` passes (32/32 tests).
- [ ] `flutter analyze` reports "No issues found!".
- [ ] `dart format --output=none --set-exit-if-changed` passes on touched files with exit code 0.
- [ ] `dart run tool/check_l10n_baseline.dart` passes with exit code 0.
- [ ] `dart run tool/check_supabase_contracts.dart` passes with exit code 0.

### Documentation
- [ ] `Upcoming Prompts/mine-flow-STEP-55.7-FINDINGS.md` contains the E2E residual addendum and command evidence.
- [ ] The replacement line for `prompts/STEP-index.md` row 55.7 is reported.

## 2026-09-25T10:41:18Z

Resolve remaining STEP-55.6 residual defects in MineFlow: fix the post-submit navigation race and double-pop stack issue in `DailyLogFormSheet`, fix the list-visibility defect at line 203 in `daily_log_journey_test.dart`, confirm live Supabase migration and contract guard integrity, and record complete verification evidence in the findings document.

Working directory: d:/AppDev/mine_flow/Code/mine-flow-app
Integrity mode: development

## Requirements

### R1. Resolve Post-Submit Close & Stack Navigation Race
In `lib/features/daily_log/presentation/pages/daily_log_form_sheet.dart`, fix the post-submit close behavior where popping leaves the navigator at `/teams` instead of `/teams/daily-log`. Prevent duplicate or stale pops so that returning from the form reliably lands on `DailyLogListScreen` without double-popping the navigation stack.

### R2. Resolve E2E Daily Log List Visibility
Fix the list-visibility defect in `integration_test/journeys/daily_log_journey_test.dart:203` where the created log is not visible in the foreman list view (`find.text(testSummary)` = 0). Ensure appropriate list reload/read-back triggers upon sheet dismissal.

### R3. Contract Integrity & Migration Verification
Verify that Supabase migration `20260912000001_step_55_6_daily_log_hazard_contract.sql` remains applied on the live/staging database, `supabase/types/database.ts` retains all four hazard columns (`hazard_state`, `hazard_severity`, `hazard_notes`, `hazard_action`), and `tool/check_supabase_contracts.dart` passes.

### R4. Approval Dialog ForUI Compliance
Confirm that `daily_log_list_screen.dart` has no unbounded Material dialogs, uses ForUI `FDialog` or the shared `confirmDestructiveAction` helper with dynamic confirmation text and supervisor gating, and retains widget test coverage.

### R5. Controlled Infrastructure & Security
Use only the staging Supabase endpoints configured in `.env`. Do not leak or output secrets, auth tokens, or PII into logs, terminals, or findings artifacts.

### R6. Findings Evidence Update
Append a dated "Residual fix (55.6) — E2E & Contract Verification" section to `Upcoming Prompts/mine-flow-STEP-55.6-FINDINGS.md` recording all executed commands, test counts, git commit details, and updated index row evidence.

## Verification Resources

- Master reference: `Upcoming Prompts/mine-flow-STEP-55.6-RESIDUAL-PROMPT.md`
- Local web-drive repro harness: `run_web_wrapper.dart` with chromedriver on port 4444.
- Staging credentials for Foreman (`TEST_FOREMAN_EMAIL`, `TEST_FOREMAN_PASSWORD`) in `.env`.
- Test commands:
  - `flutter test integration_test/journeys/daily_log_journey_test.dart`
  - `flutter test test/unit/hazard_assessment_test.dart test/unit/daily_log_repository_test.dart test/widget/daily_log_screen_test.dart test/features/daily_log/`
  - `dart run tool/check_supabase_contracts.dart`
  - `flutter analyze`
  - `dart format --output=none --set-exit-if-changed`

## Acceptance Criteria

### E2E Journey & Navigation
- [ ] `daily_log_journey_test.dart` passes completely locally (both `:169` `DailyLogListScreen` assertion and `:203` `testSummary` card visibility).
- [ ] Closing `DailyLogFormSheet` pops exactly once and stays within `/teams/daily-log`.
- [ ] No regression in cold-URL navigation or manual close button behavior.

### Contracts & Code Quality
- [ ] `dart run tool/check_supabase_contracts.dart` exits 0.
- [ ] All 58+ unit and widget tests under `test/features/daily_log/`, `test/unit/`, and `test/widget/` pass.
- [ ] `flutter analyze` and `dart format` pass cleanly with zero warnings or unformatted files.
- [ ] `Upcoming Prompts/mine-flow-STEP-55.6-FINDINGS.md` contains exact test outputs and commands.
