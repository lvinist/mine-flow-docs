# Handoff Report — UI/UX, Impeccable Protocol, Accessibility, and Runtime Matrix Survey

**Author:** survey_explorer_2  
**Role:** UI/UX, Impeccable protocol, accessibility, multiplatform runtime matrix  
**Working Directory:** `d:\AppDev\mine_flow\.agents\survey_explorer_2`  
**Parent Conversation ID:** `59bcb54d-8151-4a70-b05f-f44eef45d09c`  
**Date:** 2026-09-16  

---

## 1. Observation

### 1.1 UI Architecture, Shell Layout, and Breakpoint
- **Breakpoint Configuration:** Defined at `Code/mine-flow-app/lib/app/presentation/pages/app_shell.dart:35` and `lib/app/presentation/widgets/global_app_header.dart:19`:
  ```dart
  const double _kBreakpoint = 800;
  ```
  Layout splits cleanly at 800 logical pixels:
  - Viewports `>= 800dp` render `_WideLayout` (`app_shell.dart:214`), featuring a 256px wide collapsible `FSidebar` (`app_shell.dart:293`) with a 200ms easeOutQuart transition, animated between width 0 and 256.
  - Viewports `< 800dp` render `_NarrowLayout` (`app_shell.dart:217`), displaying a persistent 5-item `FBottomNavigationBar` (`app_shell.dart:438-458`) for mobile ergonomics.
- **Global Header (`global_app_header.dart:58-118`):**
  - Desktop layout: Sidebar collapse toggle (`LucideIcons.panelLeft`), canonical breadcrumbs (`_Breadcrumb`), search field (280px wide), theme toggle button (`_ThemeIconButton`), notifications button (`_NotificationIconButton` with unread badge), and authenticated user avatar (`_AvatarWidgetDesktop`) displaying initials and navigating to `/settings`.
  - Mobile layout: Search-centric header displayed on root branch routes (`app_shell.dart:435`).
- **Authenticated Identity Binding:** Header reads `AuthState.user` directly (`global_app_header.dart:450-480`), presenting the real authenticated name and localized role (Supervisor / Pengawas or Foreman / Mandor), eliminating legacy hardcoded fallback placeholders (`Pengguna` / `Foreman`).

### 1.2 Route and Screen Inventory
Mapped from `Code/mine-flow-app/lib/app/router.dart:77-116` (`AppRoutes`) and GoRouter branch definitions (`router.dart:148-1023`):

| Area | Route | Screen / Component | Description & Key Elements |
|---|---|---|---|
| **Auth** | `/login` | `LoginPage` | Email and password inputs (`FTextField`), password visibility toggle (>=48dp), 'Masuk' button (`FButton`, >=48dp). Document language `id`. |
| **Auth** | `/privacy-gate` | `PrivacyAckPage` | Terms & Privacy notice, versioned acknowledgment button 'Setuju & Lanjutkan' (persisting version 1 before routing, `privacy_ack_page.dart:67-72`), logout button. |
| **Testing** | `/__interaction-fixture` | `AppInteractionFixturePage` | Route and form sheet test fixture for verifying modal geometry and dismissal. |
| **Branch 0: Dashboard** | `/` | `DashboardPage` | 4 actionable KPI cards (Attendance, Cut/Fill, Equipment Check, Notifications) navigating directly to feature routes; compact Workflow Shortcuts row (Data Bucket, Land Clearing, Benchmark DB, Daily Log, Inventory, Timeline); recent activity feed; refresh. |
| **Branch 1: Tools** | `/tools` | `GroupLandingPage` | Group landing tile for Data Bucket. |
| **Branch 1: Tools** | `/tools/data-bucket` | `DataBucketListPage` | Geospatial file list, search, filter, upload action button, refresh. |
| **Branch 1: Tools** | `/tools/data-bucket/upload` | `UploadFilePage` | Responsive modal sheet (`AppResponsiveSheet`). File picker, zone select (`AppPlatformSelect`), upload button with cancellation (`Batalkan Unggahan`), dirty guard. |
| **Branch 1: Tools** | `/tools/data-bucket/:id` | `FileDetailRoute` | Read-only inspector (`AppDetailInspector`). Deep link/refresh safe (fetches file by `:id` if `extra` is absent, `router.dart:283`). Metadata preview, Drive link, delete. |
| **Branch 2: Operations** | `/operations` | `GroupLandingPage` | Group landing tiles for Cut / Fill, Land Clearing, Benchmark DB. |
| **Branch 2: Operations** | `/operations/cut-fill` | `CutFillListScreen` | Cut/Fill volume records, in-context range date picker (`AppCalendarDialog`), zone filter popover (`AppFilterPopover`), contextual report button (`ReportType.cutFill`), create action (`/form`). Direct row tap opens edit form (`/:id/form`). |
| **Branch 2: Operations** | `/operations/cut-fill/form` | `CutFillFormScreen` | Responsive create sheet. Date, zone, volume, material type, notes, save, cancel, dirty guard. |
| **Branch 2: Operations** | `/operations/cut-fill/:id/form` | `CutFillFormScreen` | Responsive edit sheet. Fetches record by `:id` when `extra` is absent. Prefilled fields, update, delete with confirmation, dirty guard. |
| **Branch 2: Operations** | `/operations/land-clearing` | `LandClearingSummaryScreen` | Plan vs Actual summary metrics, Plan/Actual tabs, record list, filter popover, contextual report button (`ReportType.landClearing`), create action (`/form`). Row tap opens inspector (`/:id`). |
| **Branch 2: Operations** | `/operations/land-clearing/form` | `LandClearingEntryScreen` | Responsive create sheet with restorable `?tab=plan\|actual`. Zone, date, area, method selection dropdown (`AppPlatformSelect`, selection-only per CF-043), dirty guard. |
| **Branch 2: Operations** | `/operations/land-clearing/:id` | `LandClearingInspectorScreen` | Read-only inspector (`AppDetailInspector`: Web right sheet, Mobile bottom sheet). Plan/Actual comparative view, explicit 'Edit' button navigating to `/:id/form`. |
| **Branch 2: Operations** | `/operations/land-clearing/:id/form` | `LandClearingEntryScreen` | Responsive edit sheet, fetches by `:id`. |
| **Branch 2: Operations** | `/operations/benchmark-db` | `BenchmarkListScreen` | Search field, CRS filter, benchmark table/cards, contextual report button (`ReportType.benchmark`), create action (`/form`). Row tap opens inspector (`/:id`). |
| **Branch 2: Operations** | `/operations/benchmark-db/form` | `BenchmarkFormScreen` | Responsive create sheet. Code, name, coordinates (Lat/Lon or UTM Easting/Northing), elevation, CRS/datum selector. Projection validation rejects invalid/out-of-zone coordinates before submission, preventing (0.0, 0.0) persistence. Dirty guard. |
| **Branch 2: Operations** | `/operations/benchmark-db/:id` | `BenchmarkInspectorScreen` | Read-only inspector (`AppDetailInspector`). Coordinates, CRS, datum, order, status, metadata, explicit 'Edit' button navigating to `/:id/form`. |
| **Branch 2: Operations** | `/operations/benchmark-db/:id/form` | `BenchmarkFormScreen` | Responsive edit sheet, fetches by `:id`. |
| **Branch 3: Teams** | `/teams` | `GroupLandingPage` | Group landing tiles for Attendance, Daily Log, Inventory, Equipment Check, Timeline Pekerjaan. |
| **Branch 3: Teams** | `/teams/attendance` | `AttendanceScreen` | Daily crew roster, date selector, status pills, filter popover, contextual report button (`ReportType.attendance`), batch check-in action (`/form?date=...&siteId=...`). |
| **Branch 3: Teams** | `/teams/attendance/form` | `AttendanceFormSheet` | Responsive batch sheet. Date picker (`AppCalendarDialog`) + bulk action `Tandai Semua Masuk` (marks only unset crew as Masuk). Crew cards with real names (no raw UUIDs), 4 explicit choices (`Masuk`, `Izin`, `Sakit`, `Alpa`), inline expandable reason for `Izin`/`Sakit`, sync status badges, footer submit `Simpan Absensi (N Kru)`, dirty guard. |
| **Branch 3: Teams** | `/teams/daily-log` | `DailyLogListScreen` | 4-tab role-aware workflow: `Semua`, `Draft`, `Perlu Disetujui`, `Disetujui` (Foremen default to Draft; Supervisors default to Perlu Disetujui). Filter popover (date, zone, foreman), contextual report button (`ReportType.dailyLog`). Supervisor-only `Setujui Log` action on submitted logs. Create action (`/form?date=...`). Card tap navigates to `/:id/form`. |
| **Branch 3: Teams** | `/teams/daily-log/form` | `DailyLogFormSheet` | Responsive create sheet (`?date=YYYY-MM-DD`). Date, foreman, zone, weather selector (icon + label), structured hazards (explicit "Tidak ada bahaya" toggle, severity, notes), activities, auto-save flush on dismiss, dirty guard. |
| **Branch 3: Teams** | `/teams/daily-log/:id/form` | `DailyLogFormSheet` | Record sheet resolving log by `:id`. Renders editable form for drafts; read-only inspector for submitted/approved logs with supervisor review status. |
| **Branch 3: Teams** | `/teams/inventory` | `InventoryDashboardScreen` | Stock dashboard, category filter popover, low stock / out of stock distinct badges, contextual report button (`ReportType.inventory`), quick stock adjust button (`showStockAdjustmentDialog`), create action (`/form`). Card tap opens detail (`/:id`). |
| **Branch 3: Teams** | `/teams/inventory/form` | `InventoryItemEntryScreen` | Responsive create sheet. Item name, SKU, category, unit, initial stock, reorder point, dirty guard. |
| **Branch 3: Teams** | `/teams/inventory/:id` | `InventoryHistoryScreen` | **D7 Mobile Full Page / Web Right Inspector**. Item details, immutable adjustment transaction history ledger (actor, server timestamp, delta, reason), explicit 'Edit' button navigating to `/:id/form`. |
| **Branch 3: Teams** | `/teams/inventory/:id/form` | `InventoryItemEntryScreen` | Responsive edit sheet, fetches by `:id`. |
| **Branch 3: Teams** | `/teams/equipment-check` | `EquipmentHistoryScreen` | Inspection history list, search, check type/status filter popover, contextual report button (`ReportType.equipmentCheck`), create action (`/form?siteId=...`). Row tap opens detail (`/:id`). |
| **Branch 3: Teams** | `/teams/equipment-check/form` | `EquipmentCheckFormScreen` | Responsive create sheet. Equipment selector, 15–30 checklist items with standardized PASS/FAIL/NA buttons (labelled >=48dp targets, dual icon+text), notes, dirty guard. |
| **Branch 3: Teams** | `/teams/equipment-check/:id` | `EquipmentCheckDetailScreen` | **D7 Mobile Full Page / Web Right Inspector**. Full 15–30 checklist results, defect notes, inspector name, timestamp. |
| **Branch 3: Teams** | `/teams/timeline` | `TimelinePage` | Read-only project timeline/milestone tracking with date range filter. Milestone creation is deliberately omitted for this release per FC-54.9-007. |
| **Branch 4: Settings** | `/settings` | `SettingsPage` | User profile card (real name, server-managed role), 'Edit Profil' action (`/settings/profile/form`), Language selector (English / Indonesia with partial translation note), Theme selector (Terang / Gelap / Sistem), version info, 'Keluar' logout button with confirmation dialog. |
| **Branch 4: Settings** | `/settings/profile/form` | `ProfileEditPage` | Responsive sheet. Display name input (`FTextField`), server-managed role (read-only), save, dirty guard. |
| **Standalone** | `/notifications` | `NotificationListPage` | Full-page notification center. Unread/all filters, notification cards (`FTappable`), mark as read, delete, 'Tutup Semua' bulk dismiss. |
| **Standalone** | `/reports/config` | `ReportConfigPage` / `ReportTypePickerPage` | Standalone fallback if navigated directly without feature context. |

### 1.3 Dialogs and Modal Primitives
Implemented in `Code/mine-flow-app/lib/core/presentation/widgets/app_interaction_primitives.dart` and feature modules:
1. **`AppDirtyDismissDialog` (`app_interaction_primitives.dart:313-355`):**
   - Non-dismissible confirmation modal shown when user attempts to close a dirty form:
     - Title: `Perubahan Belum Disimpan`
     - Body: `Anda memiliki perubahan yang belum disimpan. Yakin ingin membuangnya?`
     - Actions: `Lanjutkan Mengedit` (autofocus, returns false, retains state) and `Buang Perubahan` (error color, returns true, authorizes single route pop).
2. **`AppContextualReportDialog` (`lib/features/reporting/presentation/widgets/app_contextual_report_dialog.dart:21-70`):**
   - Contextual report generation modal pre-bound to `ReportType` without a generic report picker.
   - Originating list, filters, and scroll remain mounted and preserved behind the scrim.
   - Seven features supported: `cutFill`, `landClearing`, `benchmark`, `attendance`, `dailyLog`, `equipmentCheck`, `inventory`.
   - Data Bucket and Work Timeline are deliberately report-free (FC-54.9-008).
3. **`AppFilterPopover` (`app_interaction_primitives.dart:524-583`):**
   - Compact popover (max width 360dp) grouping related filter criteria with explicit `Batal`, `Reset filter`, and `Terapkan` actions. Eliminates persistent horizontal filter pill rows.
4. **`AppCalendarDialog` (`app_interaction_primitives.dart:591-625`):**
   - In-context date picker (`showSingle`) and date-range picker (`showRange`) with `Batal` and `Terapkan` buttons. Preserves state without route transition or full calendar pages.
5. **Feature-specific Dialogs:**
   - `showStockAdjustmentDialog` in Inventory: Modal dialog showing current stock, adjustment delta, reason selection, and calculated new stock.
   - Supervisor approval dialog in Daily Log: Confirmation dialog naming the log date, foreman, and site before executing `ApproveDailyLogEvent`.
   - Sign-out dialog in Settings: Confirmation dialog before executing `AuthCubit.signOut()`.

### 1.4 Accessibility, Theming, and Layout Mechanics
- **Theming & System Reactivity (`lib/app/app.dart:73-88`):**
  - Uses ForUI `FTheme.neutral.light.touch` and `FTheme.neutral.dark.touch`.
  - System mode live brightness reactivity:
    ```dart
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = settingsState.themeMode == ThemeMode.dark ||
        (settingsState.themeMode == ThemeMode.system && brightness == Brightness.dark);
    ```
    Re-evaluates dynamically on OS brightness changes.
- **Interactive Targets (>=48x48dp):**
  - Explicitly coded across interactive controls: `AppAccessibleIconButton` (`width: 48, height: 48` in `app_interaction_primitives.dart:405-406`), `SOPChecklistItemCard` (`height: 48` in `sop_checklist_item_card.dart:105, 129`), `StatusToggleChips` (`minHeight: 48` in `status_toggle_chips.dart:91`), `CheckTypeToggle` (`minHeight: 48` in `check_type_toggle.dart:43`), and `AttendanceCrewCard` (`minHeight: 48` in `attendance_crew_card.dart:188`).
- **Web Document Language & Locales:**
  - `web/index.html:2` sets static `<html lang="id">`.
  - App supports `id` and `en` (`app.dart:58-64`), with Indonesian as the primary release language.
  - English is incomplete and tracked under RISK-0004 ("Terjemahan bahasa Inggris masih sebagian" displayed in `settings_page.dart:132`).
  - Web document language attribute is not dynamically synced in DOM when toggling to English.
- **Universal Dirty-State Dismissal Guard (`app_interaction_primitives.dart:32-48, 140-155, 205-208`):**
  - Unifies 8 dismissal sources: (1) close button, (2) cancel, (3) scrim tap, (4) Escape key, (5) browser navigation, (6) system back, (7) bottom sheet drag, (8) parent navigation.
  - If `isBusy == true`: Dismissal is blocked and accessibility announcement is emitted (`SemanticsService.sendAnnouncement`, `app_interaction_primitives.dart:161-166`).
  - If `isDirty == true`: Prompts `AppDirtyDismissDialog.show(context)`.
- **Security & Header Redaction:**
  - `test/core/utils/logger_test.dart:7-43` tests and verifies that `Authorization: Bearer <redacted>` and `apiKey=<redacted>` are sanitized before outputting to debug logs.
  - Verified 0 hits for JWT, Bearer, or service_role in prior audit logs (`mine-flow-STEP-55.11-FINDINGS.md:169`).

### 1.5 Screenshot Harnesses and Test Driver Hazard
- **Harness (`integration_test/design_review_capture_test.dart`):**
  - Iterates over breakpoints, themes (light/dark), locales (id/en), and screens (`dashboard`, `daily-log`, `daily-log-form`, `operations`, `teams`, `tools`, plus initial `login`).
  - Total required matrix cells: Web = 3 breakpoints x 2 themes x 2 locales x 6 screens = 72 (+1 login = 73); Android = 1 breakpoint x 2 themes x 2 locales x 6 screens = 24 (+1 login = 25).
  - Android assertion defect (`design_review_capture_test.dart:200-208`):
    ```dart
    expect(captured.isNotEmpty, isTrue);
    ```
    This assertion passes even if only 1 out of 24 screenshots succeeds, masking capture failures on Android (producing the 1/24 artifact gap noted in Run 2).
- **Test Driver Path Hazard (`test_driver/integration_test.dart:11-13`):**
  - Current implementation:
    ```dart
    final File image = await File(
      '../mine-flow-docs/reports/design-review/step-0048/$screenshotName.png',
    ).create(recursive: true);
    ```
  - **CRITICAL HAZARD:** Hardcoded path points to `step-0048`. In STEP-55 Run 2, executing web captures overwrote 22 committed placeholder PNGs in STEP-0048 (`mine-flow-STEP-55.11-FINDINGS.md:196-211`). It MUST be retargeted to `../mine-flow-docs/reports/design-review/step-0055/`.
- **Required Image Metadata Format:**
  Every capture record in durable reports must document:
  1. Command / Route (e.g., `flutter drive --target=... /teams/daily-log`)
  2. Platform / Viewport / Device (e.g., Web Desktop 1200x900, Android Pixel_6a 412x915)
  3. Theme / State (e.g., Light / Dark / System / Dirty Dialog)
  4. File Size in bytes (e.g., 19,553 bytes; proves non-empty, non-1x1 placeholder)
  5. Image Dimensions in pixels (e.g., 1,258 x 566 px)

### 1.6 Current Git & Commit State
- In `Code/mine-flow-app` (`step-0055-cohesive-ui-rebuild`):
  - Working tree clean.
  - Recent commits:
    - `a301e4b test(STEP-55.11): align attendance and daily log journeys`
    - `9c82d1b test(STEP-55.11): migrate audited journeys and pin privacy gate` (fixed `privacy_ack_page.dart:67` await bug, migrated 6 Class-A journeys).
- In `Code/mine-flow-docs` (`step-0055-cohesive-ui-rebuild`):
  - Untracked audit report: `reports/2026-09-14-step-55-multiplatform-impeccable-audit.md`.
  - Untracked screenshot folder: `reports/design-review/step-0055/2026-09-14-web-login-1258x566.png`.
- In `prompts`:
  - `STEP-index.md` has an unstaged edit.

---

## 2. Logic Chain

1. **Premise 1: Shell and Form Responsiveness:**
   - From Section 1.1, `app_shell.dart:35` and `app_interaction_primitives.dart:69, 172` establish that the 800dp breakpoint controls both the shell (FSidebar vs BottomNav) and form presentations (`AppResponsiveSheet`: right modal sheet 480-600dp on Web, draggable bottom sheet on Mobile).
   - Therefore, any responsive testing must explicitly probe 799dp, 800dp, and 801dp to verify layout stability across this threshold.

2. **Premise 2: Navigation & D7 Detail Decisions:**
   - Master polish spec §5 and `router.dart` establish deliberate per-feature inspection patterns:
     - Cut & Fill: Direct list-to-edit sheet (no separate inspector).
     - Land Clearing & Benchmark DB: Route-backed read-only inspectors before editing.
     - Equipment Check & Inventory: Dedicated route-backed detail, where Web uses a right inspector but Android uses a **full page** (`mobileFullPage: true`) to accommodate long records (15-30 checklist items and ledger histories).
     - Timeline: Read-only view with no milestone creation for this release.
   - Therefore, Android E2E and visual captures must treat Equipment and Inventory as full-page navigation destinations rather than modal bottom sheets.

3. **Premise 3: Report Binding Architecture:**
   - From Section 1.3, `AppContextualReportDialog` is bound directly to 7 features (`cutFill`, `landClearing`, `benchmark`, `attendance`, `dailyLog`, `equipmentCheck`, `inventory`), keeping the list, filters, and scroll state mounted behind the dialog. Data Bucket and Timeline intentionally have no report action.
   - Therefore, the legacy `/reports/config` route is only a standalone fallback; all in-app feature audits must exercise the contextual dialog over the active list.

4. **Premise 4: Test Driver Clobber Defect:**
   - From Section 1.5, `test_driver/integration_test.dart:12` writes output to `step-0048/` instead of `step-0055/`.
   - In Run 2, this clobbered 22 committed STEP-48 placeholder images and failed to populate the STEP-55 evidence directory.
   - Therefore, running `flutter drive` with the current harness without retargeting the output directory will pollute tracked git history and fail to produce valid STEP-55 evidence.

5. **Premise 5: Accessibility and Verification Gaps:**
   - From Section 1.4, WCAG AA contrast (4.5:1 text, 3:1 focus/large) and 48dp geometry are implemented in code tokens and constraints, but have **zero automated runtime test measurements** in the repo.
   - Furthermore, text scaling (1.0x, 1.3x, 2.0x) is neither exercised in widget tests nor integration tests.
   - The Web accessibility tree was only captured for the login screen (8 nodes); the authenticated shell AX tree remains unverified.
   - Therefore, these areas represent genuine runtime evidence obligations that must be verified on live devices or headless drivers rather than inferred from source code.

---

## 3. Caveats

1. **Read-only Exploration:** No code changes or test runs were executed during this survey, maintaining strict scope discipline.
2. **Android Hardware/Emulator Availability:** Android execution requires a running `Pixel_6a` emulator or connected physical device; adb connection state was not modified in this turn.
3. **English Localization (RISK-0004):** English strings are only partially translated in `lib/l10n/app_en.arb`. Indonesian (`id`) is the authoritative language for this audit pass.
4. **Driver Retargeting Dependency:** The fix for `test_driver/integration_test.dart` targeting `step-0055` must be implemented before running full capture passes to avoid clobbering STEP-48.

---

## 4. Conclusion

The application possesses a mature, well-structured multiplatform UI architecture:
- **Navigation & Routing:** 24 distinct routes across 5 branches in GoRouter, with clean deep-link reconstruction (no in-memory `extra` dependencies for durable state), canonical breadcrumbs, and truthful header identity.
- **Interaction Primitives:** Shared `AppResponsiveSheet`, `AppDirtyDismissDialog`, `AppContextualReportDialog`, `AppFilterPopover`, and `AppCalendarDialog` enforce consistent interaction paradigms and guard against accidental data loss across 8 dismissal paths.
- **Impeccable Alignment:** The codebase adheres to the ForUI Zinc aesthetic, 800dp breakpoint, and 5-item mobile tab contract.
- **Immediate Actionable Blockers for Audit Execution:**
  1. `test_driver/integration_test.dart` must be retargeted from `step-0048` to `step-0055` to prevent overwriting older release artifacts.
  2. The Android screenshot harness assertion in `design_review_capture_test.dart` should be hardened so that all 24 cells must be captured.
  3. The runtime matrix must execute across Web (799, 800, 801, 1024, 1280dp) and Android (Pixel_6a portrait) with Light, Dark, System themes, and 1.0x, 1.3x, 2.0x text scaling.
  4. Explicit measurements of contrast ratios and 48dp touch rectangles must be captured to retire the open evidence debt.

---

## 5. Verification Method

### 5.1 Static Verification Commands
```powershell
# In d:\AppDev\mine_flow\Code\mine-flow-app:
dart format --output=none --set-exit-if-changed .
flutter analyze
dart run tool/check_l10n_baseline.dart
dart run tool/check_supabase_contracts.dart
flutter test test/core/utils/logger_test.dart
flutter test test/features/auth/presentation/privacy_ack_page_test.dart
flutter test
```

### 5.2 Build & Driver Verification Commands
```powershell
# Web Release Build
flutter build web --release

# Android Debug Build
flutter build apk --debug

# Web E2E (after retargeting test_driver output path)
chromedriver --port=4444
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/design_review_capture_test.dart -d chrome

# Android E2E (on Pixel_6a emulator)
flutter test integration_test/design_review_capture_test.dart -d emulator-5554
```

### 5.3 Invalidation Conditions
- Any route in `lib/app/router.dart` relying on `state.extra` for durable record identification invalidates deep-link URL reconstruction.
- Any form dismissal path that bypasses `AppDismissController` or drops the dirty confirmation dialog invalidates acceptance criterion 4.
- If `test_driver/integration_test.dart` continues to write to `reports/design-review/step-0048/`, any capture run invalidates historical release records.
- If screenshots are committed with byte sizes under 1KB (1x1 placeholders) or lacking metadata headers (command, platform, theme, bytes, dimensions), evidence acceptance fails.
