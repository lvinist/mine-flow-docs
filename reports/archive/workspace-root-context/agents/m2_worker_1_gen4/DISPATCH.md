## 2026-09-17T08:05:21Z

You are m2_worker_1_gen4, the Worker agent for Milestone 2 of STEP-55.11.
Your working directory is: d:/AppDev/mine_flow/.agents/m2_worker_1_gen4
Your parent Orchestrator conversation ID is: 4af240b7-3229-4675-b201-32ad0b0dea69

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

MANDATORY INPUTS (READ BEFORE STARTING):
1. d:/AppDev/mine_flow/.agents/ORIGINAL_REQUEST.md (Authoritative verbatim user request)
2. d:/AppDev/mine_flow/PROJECT.md
3. d:/AppDev/mine_flow/.agents/m2_explorer_1_gen4/handoff.md (Detailed fix plan for E2E Journeys)
4. d:/AppDev/mine_flow/.agents/m2_explorer_2_gen4/handoff.md (Detailed fix plan for Impeccable Audit, contrast, touch targets, layout scaling)
5. d:/AppDev/mine_flow/.agents/m2_spec_miner_3_gen4/handoff.md (Screenshot matrix, rubrics, execution commands)
6. d:/AppDev/mine_flow/.agent/skills/impeccable/SKILL.md (Domain skill for impeccable design)

FILE WRITE OWNERSHIP:
You have exclusive write ownership of:
- `Code/mine-flow-app/lib/app/app.dart` (theme contrast adjustments)
- `Code/mine-flow-app/lib/app/presentation/widgets/global_app_header.dart` (touch targets, avatar width constraints, flexible search, MediaQuery breakpoint)
- `Code/mine-flow-app/lib/app/presentation/pages/app_shell.dart` (FSidebarItem touch target constraints)
- `Code/mine-flow-app/lib/core/presentation/widgets/app_interaction_primitives.dart` (AppResponsiveSheet Escape key, focus trap, Wrap footer, 48dp constraints)
- `Code/mine-flow-app/lib/features/tracking/presentation/pages/cut_fill_form_screen.dart` (_hasClosed guard)
- `Code/mine-flow-app/lib/features/tracking/presentation/pages/inventory_item_entry_screen.dart` (_hasClosed guard)
- `Code/mine-flow-app/lib/features/tracking/presentation/pages/land_clearing_entry_screen.dart` (initialTab & tab switching)
- `Code/mine-flow-app/lib/features/benchmark/presentation/pages/benchmark_form_screen.dart` (CreatableCombobox & FTextField)
- `Code/mine-flow-app/integration_test/journeys/cut_fill_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/land_clearing_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/inventory_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/benchmark_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/equipment_check_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/reporting_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/attendance_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/daily_log_journey_test.dart`
- `Code/mine-flow-app/integration_test/journeys/offline_sync_journey_test.dart`
- `Code/mine-flow-app/integration_test/design_review_capture_test.dart`

TASKS:
1. Implement the E2E Journey fixes detailed in `m2_explorer_1_gen4/handoff.md`:
   - Class A fixture updates: `cut_fill_journey_test.dart` (FButton, scoped volume, notes), `land_clearing_journey_test.dart` (FButton, tab navigation), `inventory_journey_test.dart` (FButton, indices), `benchmark_journey_test.dart` (FTextField labels, CreatableCombobox, FButton), `equipment_check_journey_test.dart` (FButton, serial number label), `reporting_journey_test.dart` (AppContextualReportDialog, localized actions).
   - Form sheets double-pop guard: verify `_hasClosed` in `cut_fill_form_screen.dart` and `inventory_item_entry_screen.dart`.
   - Class B role gating: verify `daily_log_journey_test.dart` foreman credentials and flow.
   - Class B offline sync: update `offline_sync_journey_test.dart` Part A (purge Hive `sync_queue` at test start, idempotent delete by `user_id` and `date`).
   - Attendance journey: ensure button locators `find.text('Sakit')` and `find.text('Izin')` are clean and intact.

2. Implement the Impeccable Audit fixes detailed in `m2_explorer_2_gen4/handoff.md`:
   - Contrast: in Neutral Dark theme, fix `destructiveForeground` on `destructive` contrast ratio to meet WCAG AA >= 4.5:1 (e.g. override `theme.colors.destructiveForeground` to `#0A0A0A` or adjust `destructive` to `#DC2626`).
   - Touch Target Geometry: ensure interactive elements meet >=48x48dp in `global_app_header.dart` (icon buttons, avatar widget, breadcrumbs), `app_shell.dart` (sidebar items), and `app_interaction_primitives.dart` (sheet action buttons).
   - Text Scaling & Layout Resilience: in `global_app_header.dart`, constrain avatar user name width to 160 with ellipsis, make search field flexible, and use `MediaQuery.sizeOf(context).width >= 800` for breakpoint check. In `app_interaction_primitives.dart`, wrap sheet footer buttons in `Wrap` to prevent overflow at 2.0x text scaling.
   - Navigation: in `AppResponsiveSheet`, support Escape key dismissal via `CallbackShortcuts` mapping `LogicalKeyboardKey.escape` to `_requestDismiss(AppDismissReason.escape)`, and wrap in `FocusScope(traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop)`.

3. Automated Gates Verification:
   In directory `d:/AppDev/mine_flow/Code/mine-flow-app`:
   - Run: `dart format .`
   - Run: `flutter analyze` (Must pass with ZERO issues!)
   - Run: `dart run tool/check_l10n_baseline.dart` (Must pass!)
   - Run: `dart run tool/check_supabase_contracts.dart` (Must pass!)
   - Run: `flutter test -j 1 test/tool` and relevant unit/widget tests
   - Run: `flutter test test/features/auth/presentation/privacy_ack_page_test.dart`
   - Run any explorer verification tests (e.g. contrast, target geometry, scaling, offline sync Part B)
