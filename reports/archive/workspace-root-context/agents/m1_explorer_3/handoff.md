# Handoff Report — Milestone 1: E2E Journeys, Recent Commits, and Multiplatform Runners

**Author:** `m1_explorer_3`  
**Role:** Explorer / Investigator (E2E Journeys & Runners)  
**Working Directory:** `d:\AppDev\mine_flow\.agents\m1_explorer_3`  
**Parent Conversation ID:** `59bcb54d-8151-4a70-b05f-f44eef45d09c`  
**Date:** 2026-09-16  

---

## 1. Observation

### 1.1 The 16 E2E Journey Test Files & Helper Infrastructure
The repository contains exactly 16 E2E journey test files under `Code/mine-flow-app/integration_test/` (confirmed via `.github/workflows/ci.yml:175` and codebase inventory):

| # | Test File Path | Primary Scope & Tested Flow |
|---|---|---|
| 1 | `integration_test/app_boots_test.dart` | Boot app and verify login screen render (`find.byType(EditableText)`). |
| 2 | `integration_test/journeys/attendance_journey_test.dart` | Batch attendance sheet (`AttendanceFormSheet`), crew cards, inline reasons, author attribution, list sync. |
| 3 | `integration_test/journeys/auth_journey_test.dart` | Invalid login rejection, real login, session persistence, session restore across cold restart, sign out. |
| 4 | `integration_test/journeys/benchmark_journey_test.dart` | Direct route load (`/operations/benchmark-db/form`), CRS and coordinate inputs, elevation, status, persistence. |
| 5 | `integration_test/journeys/cut_fill_journey_test.dart` | Open form (`FButton` 'Pengukuran Baru'), CreatableCombobox zone picker, volume calculation, persistence. |
| 6 | `integration_test/journeys/daily_log_journey_test.dart` | Foreman-gated log creation, zone picker, weather selection, hazard assessment radio toggle, auto-save flush. |
| 7 | `integration_test/journeys/data_bucket_journey_test.dart` | Part A (Drive-gated honest skip); Part B (staging metadata read under RLS, file list render). |
| 8 | `integration_test/journeys/deep_link_journey_test.dart` | Direct URI resolution for 17 shell routes, AppShell persistence across routes, unauthenticated redirect. |
| 9 | `integration_test/journeys/equipment_check_journey_test.dart` | Open form via FAB, serial validation, 5 SOP checklist items (4 PASS, 1 FAIL with remarks), condition summary badge. |
| 10 | `integration_test/journeys/inventory_journey_test.dart` | Open entry sheet (`FButton` 'Tambah Item'), SKU/category/stock entry, transaction history ledger reflection. |
| 11 | `integration_test/journeys/land_clearing_journey_test.dart` | Open entry sheet (`FButton` 'Clearing Baru'), zone picker, plan vs actual area tabs, method selection. |
| 12 | `integration_test/journeys/notifications_journey_test.dart` | Rule engine evaluation, critical persistent banner render & dismissal, read toggle, Tutup Semua bulk dismiss. |
| 13 | `integration_test/journeys/offline_sync_journey_test.dart` | Part A (Android-only staging offline defer, relaunch persistence, reconnect drain, LWW conflict); Part B (SyncQueueManager contract). |
| 14 | `integration_test/journeys/reporting_journey_test.dart` | Contextual report modal (`AppContextualReportDialog`), `ReportConfigContent`, date range selector, cubit state check. |
| 15 | `integration_test/journeys/rls_authorization_journey_test.dart` | Part A (per-role supervisor/foreman RLS matrix); Part B (single-user authorization, write refusal SQLSTATE 42501). |
| 16 | `integration_test/journeys/timeline_journey_test.dart` | Cumulative progress chart, calendar range filter, milestone status badge styling (`Berjalan`, `Selesai`, `Terlambat`). |

**Helper Infrastructure (`integration_test/helpers/`):**
- `app_harness.dart`: Initializes logging, Hive, Supabase client, pumps `MineFlowApp()`, exposes `appRouter`, `authCubit`, and `currentUserId()`.
- `login_helper.dart`: Resolves per-role credentials (`credentialsForRole`), automates login (`loginAsStagingUser`), and clears the first-login privacy notice (`acknowledgePrivacyGateIfPresent`).
- `staging_config.dart`: Reads `--dart-define` parameters (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `TEST_USER_*`, `TEST_SUPERVISOR_*`, `TEST_FOREMAN_*`, `TEST_CREW_*`), defines `isStagingConfigured`, and provides `recordE2eExecuted` / `recordE2eSkipped` for CI guard tracking.
- `offline_helper.dart`: Mock handler on `dev.fluttercommunity.plus/connectivity` method channel for Android offline tests (`forceOffline`).

---

### 1.2 Impact Analysis of Commits `9c82d1b` and `a301e4b`

#### Commit `9c82d1b` (`test(STEP-55.11): migrate audited journeys and pin privacy gate`)
Directly resolved the primary root cause that blocked 13 of 16 journeys on both platforms during Run 1 & Run 2:
1. **Privacy Gate Deadlock Resolved**:
   - `lib/features/auth/presentation/pages/privacy_ack_page.dart:67-72`: Acknowledgement write `updatePrivacyAckVersion(1)` is now awaited before executing `context.go(dashboard)`.
   - `test/features/auth/presentation/privacy_ack_page_test.dart`: Added real regression tests pinning the persistence-before-navigation order.
   - `integration_test/helpers/login_helper.dart:188-244`: Added `acknowledgePrivacyGateIfPresent(tester, role: role)` to automatically clear the gate on fresh sessions, preventing redirection loops back to `/privacy-gate`.
2. **ForUI Migrations for Class-A Journeys**:
   - `cut_fill_journey_test.dart:68-75`: Replaced retired Material `FloatingActionButton('Pengukuran Baru')` with `FButton('Pengukuran Baru')`.
   - `land_clearing_journey_test.dart:69-74`: Replaced retired `FloatingActionButton('Clearing Baru')` with `FButton('Clearing Baru')`.
   - `inventory_journey_test.dart:66-71`: Replaced retired `FloatingActionButton(heroTag: 'add_inventory_btn')` with `FButton('Tambah Item')`.
   - `benchmark_journey_test.dart:61-196`: Updated coordinate field labels to match real screen (`'Northing (Y)'`, `'Easting (X)'`, `'Tinggi Orthometrik (Z)'`, `'Tinggi Elipsoid (Opsional)'`), migrated CRS/Status dropdowns to `CreatableCombobox` with `warnIfMissed: false`, and updated save button to `'Simpan Benchmark'`.
   - `reporting_journey_test.dart:51-155`: Replaced pushed `ReportConfigPage` route finder with `AppContextualReportDialog` and `ReportConfigContent`.

#### Commit `a301e4b` (`test(STEP-55.11): align attendance and daily log journeys`)
1. **Daily Log Role Alignment**:
   - `daily_log_journey_test.dart:37-55`: Updated test to require foreman credentials and execute `loginAsStagingUser(tester, role: 'foreman')`, aligning with STEP-55.6 specification where daily log creation is restricted to foremen.
2. **Attendance Disambiguation**:
   - `attendance_journey_test.dart:129, 278`: Changed status selection finders from `find.text('Sakit')` / `find.text('Izin')` to `find.bySemanticsLabel('Status: Sakit')` and `find.bySemanticsLabel('Status: Izin')`.

#### CRITICAL HAZARD DISCOVERED IN `a301e4b`: Semantics Label Mismatch in `attendance_journey_test.dart`
- **Location**: `integration_test/journeys/attendance_journey_test.dart:129` and `:278`.
- **Implementation in Code**:
  In `lib/features/attendance/presentation/widgets/attendance_crew_card.dart:178-184`:
  ```dart
  for (final (status, label, icon) in specs)
    Semantics(
      button: true,
      selected: selected == status,
      label: l10n.attendanceStatusChooseLabel(label),
      child: GestureDetector(
        onTap: enabled ? () => onSelected(status) : null, ...
  ```
- **Localization definition** (`lib/l10n/app_id.arb:111`):
  ```json
  "attendanceStatusChooseLabel": "Pilih status {label} untuk kru ini"
  ```
  And in `app_en.arb:63`:
  ```json
  "attendanceStatusChooseLabel": "Choose {label} status for this crew member"
  ```
- **The Problem**:
  The choice button's Semantics label is `"Pilih status Sakit untuk kru ini"`, NOT `"Status: Sakit"`.
  The string `"Status: Sakit"` only exists on the outer card container (`attendanceCrewStatusLabel: "Kru {name} — Status: {status}"`) *after* the status is set.
  When the card is unselected (`status == null`), the card label is `"Kru {name} — Status: Belum Diisi"`.
  Therefore, searching for `find.descendant(of: targetCardFinder, matching: find.bySemanticsLabel('Status: Sakit'))` matches **zero widgets** before the tap, causing the journey to fail!
- **Worker Action Required**: Revert the matching finder to `find.text('Sakit')` and `find.text('Izin')` (which are already scoped to `targetCardFinder` and unambiguous), or use `find.bySemanticsLabel(RegExp(r'Sakit'))`.

---

### 1.3 Runner Commands & Prerequisites Verification

#### Platform A: Web (Chrome + ChromeDriver)
- **Direct CLI Execution Discovery**:
  Running `flutter test integration_test/journeys/attendance_journey_test.dart -d chrome` produces verbatim:
  ```text
  Web devices are not supported for integration tests yet.
  ```
  Therefore, Web E2E tests **cannot** be executed via `flutter test -d chrome`.
- **Authoritative Web Runner**:
  Must be executed via `flutter drive` with ChromeDriver, exactly as defined in `.github/workflows/ci.yml:175-198`.
- **Prerequisites Verified**:
  - Chrome binary: `C:\Program Files\Google\Chrome\Application\chrome.exe` (Version `152.0.7977.84`).
  - ChromeDriver binary: `C:\Users\Alpxalpha\AppData\Roaming\npm\chromedriver` (Version `152.0.7977.64` matching Chrome 152).
- **ChromeDriver Service Command**:
  ```powershell
  # Launch ChromeDriver in background on port 4444:
  Start-Process -FilePath "chromedriver" -ArgumentList "--port=4444" -NoNewWindow
  # Verify ready status:
  curl http://localhost:4444/status
  ```
- **Web Execution Command (Single Journey)**:
  ```powershell
  flutter drive `
    --driver=test_driver/integration_test.dart `
    --target=integration_test/journeys/<journey>_test.dart `
    -d web-server `
    --browser-name=chrome
  ```
- **Web Execution Loop (All 16 Journeys)**:
  ```powershell
  $files = @("integration_test/app_boots_test.dart") + (Get-ChildItem -Path "integration_test/journeys/*_test.dart" | ForEach-Object { $_.FullName })
  foreach ($file in $files) {
      Write-Host "MINE_FLOW_E2E_FILE $file"
      flutter drive `
        --driver=test_driver/integration_test.dart `
        --target="$file" `
        -d web-server `
        --browser-name=chrome
  }
  ```

#### Platform B: Android (Pixel_6a Emulator)
- **Authoritative Android Runner**:
  `flutter test` directly supports Android target devices (`-d <device_id>`).
- **Prerequisites Verified**:
  - Android SDK: `C:\Users\Alpxalpha\AppData\Local\Android\Sdk`.
  - Installed AVD: `Pixel_6a` (`Pixel 6a • Google • android`).
  - Emulator executable: `C:\Users\Alpxalpha\AppData\Local\Android\Sdk\emulator\emulator.exe`.
- **Emulator Launch Command**:
  ```powershell
  # Launch emulator headless / background:
  & "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_6a -no-snapshot -no-boot-anim &
  # Wait for boot completion:
  adb wait-for-device
  while ((adb shell getprop sys.boot_completed).Trim() -ne "1") { Start-Sleep -Seconds 2 }
  ```
- **Android Execution Command (Single Journey)**:
  ```powershell
  flutter test integration_test/journeys/<journey>_test.dart -d <device_id>
  ```
- **Android Execution Command (All 16 Journeys)**:
  ```powershell
  flutter test integration_test/ -d <device_id>
  ```

#### Staging Credentials Parameter Injection
When verifying against live Supabase staging, all commands accept `--dart-define` parameters:
```text
--dart-define=SUPABASE_URL=...
--dart-define=SUPABASE_ANON_KEY=...
--dart-define=TEST_USER_EMAIL=...
--dart-define=TEST_USER_PASSWORD=...
--dart-define=TEST_SUPERVISOR_EMAIL=...
--dart-define=TEST_SUPERVISOR_PASSWORD=...
--dart-define=TEST_FOREMAN_EMAIL=...
--dart-define=TEST_FOREMAN_PASSWORD=...
--dart-define=TEST_CREW_EMAIL=...
--dart-define=TEST_CREW_PASSWORD=...
--dart-define=APP_ENV=staging
```
When running locally without injected staging credentials, all 16 journeys safely skip with explicit, honest skip markers (`recordE2eSkipped`), satisfying the zero-executed CI guard (`check_e2e_executed.dart`).

---

## 2. Logic Chain

1. **Inventory Completeness**:
   - Direct inspection of `Code/mine-flow-app/integration_test/` confirms 15 test files in `journeys/` and 1 in root (`app_boots_test.dart`).
   - `.github/workflows/ci.yml:175` loops over `integration_test/app_boots_test.dart` and `integration_test/journeys/*_test.dart`.
   - Therefore, the exact E2E functional test suite consists of 16 journey files.

2. **Commit Impact & Residual Defect**:
   - Commit `9c82d1b` fixed the privacy gate deadlock in `login_helper.dart` and migrated 5 feature finders to ForUI primitives (`cut_fill`, `land_clearing`, `inventory`, `benchmark`, `reporting`).
   - Commit `a301e4b` aligned `daily_log` to foreman role.
   - However, in `attendance_journey_test.dart`, lines 129 and 278 were replaced with `find.bySemanticsLabel('Status: Sakit')`.
   - Direct inspection of `attendance_crew_card.dart:182` and `app_id.arb:111` shows the status choice widget has label `Pilih status Sakit untuk kru ini`, not `Status: Sakit`.
   - Therefore, running `attendance_journey_test.dart` against a live site roster will fail to tap the Sakit/Izin status choices unless fixed.

3. **Toolchain Constraints**:
   - `flutter test` cannot execute integration tests on Web (`Web devices are not supported for integration tests yet.`).
   - Therefore, Web E2E tests strictly require `flutter drive` with a ChromeDriver instance listening on port 4444.
   - Android (`Pixel_6a`) executes natively via `flutter test -d <device>`.

4. **Safety & Non-Clobbering**:
   - As identified by `m1_explorer_1`, `test_driver/integration_test.dart` hardcodes `reports/design-review/step-0048/`.
   - Running `flutter drive` when screenshot capture is invoked risks clobbering legacy STEP-0048 artifacts unless retargeted to `reports/design-review/step-0055/`.

---

## 3. Caveats

1. **Live Staging Connectivity**: The local environment does not have uncommitted `.env` files or hardcoded staging Supabase secrets in plaintext. Dual-platform execution without `--dart-define` will execute the skip paths (`recordE2eSkipped`). To verify live database mutations, the user/worker must provide staging credentials.
2. **Android Emulator Cold Boot**: Starting the `Pixel_6a` emulator for the first time in a session can take 60–90 seconds depending on host CPU allocation. The verification protocol includes polling `sys.boot_completed`.
3. **No Code Write During Investigation**: Per explorer constraints, no source files were modified during this investigation. Proposed corrections are documented below for the Worker.

---

## 4. Conclusion

1. **Suite Health**: 15 of the 16 journey files are fully aligned with the STEP-55 ForUI architecture and router changes.
2. **Required Worker Fixes Before Run**:
   - **Fix 1 (Attendance Finder)**: In `integration_test/journeys/attendance_journey_test.dart`, change:
     - Line 129: from `matching: find.bySemanticsLabel('Status: Sakit')` to `matching: find.text('Sakit')` (or `matching: find.bySemanticsLabel(RegExp(r'Sakit'))`).
     - Line 278: from `matching: find.bySemanticsLabel('Status: Izin')` to `matching: find.text('Izin')` (or `matching: find.bySemanticsLabel(RegExp(r'Izin'))`).
   - **Fix 2 (Test Driver Path Retargeting - Feature 1)**: Ensure `test_driver/integration_test.dart` writes to `reports/design-review/step-0055/` instead of `step-0048/`.
3. **Dual-Platform Execution Plan**:
   - **Web**: Start `chromedriver --port=4444`, then execute all 16 journeys via `flutter drive`.
   - **Android**: Launch `Pixel_6a`, then execute the suite via `flutter test integration_test/ -d <serial>`.

---

## 5. Verification Method

### Step 1: Worker Code Correction (Attendance Finder)
In `Code/mine-flow-app/integration_test/journeys/attendance_journey_test.dart`:
```dart
// Line 129:
final sakitChoice = find.descendant(
  of: targetCardFinder,
  matching: find.text('Sakit'),
);

// Line 278:
final izinChoice = find.descendant(
  of: formTargetCard,
  matching: find.text('Izin'),
);
```

### Step 2: Web Execution Protocol
```powershell
# 1. Start ChromeDriver in background
Start-Process -FilePath "chromedriver" -ArgumentList "--port=4444" -NoNewWindow
Start-Sleep -Seconds 2
curl http://localhost:4444/status

# 2. Run all 16 journeys sequentially via flutter drive
cd Code/mine-flow-app
$files = @("integration_test/app_boots_test.dart") + (Get-ChildItem -Path "integration_test/journeys/*_test.dart" | ForEach-Object { "integration_test/journeys/" + $_.Name })

"" > all_web.log
foreach ($file in $files) {
    "MINE_FLOW_E2E_FILE $file" | Out-File -FilePath all_web.log -Append
    flutter drive `
      --driver=test_driver/integration_test.dart `
      --target="$file" `
      -d web-server `
      --browser-name=chrome >> all_web.log 2>&1
}

# 3. Verify executed log
dart run tool/ci/check_e2e_executed.dart --platform=web --log=all_web.log
```

### Step 3: Android Execution Protocol
```powershell
# 1. Start emulator
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_6a -no-snapshot -no-boot-anim &
adb wait-for-device
while ((adb shell getprop sys.boot_completed).Trim() -ne "1") { Start-Sleep -Seconds 2 }
$deviceId = (adb devices | Select-String "emulator-").Line.Split("`t")[0]

# 2. Run Android suite
cd Code/mine-flow-app
flutter test integration_test/ -d $deviceId > integration_test.log 2>&1

# 3. Verify executed log
dart run tool/ci/check_e2e_executed.dart --platform=android --log=integration_test.log
```

### Step 4: Automated Gates Sign-off
```powershell
cd Code/mine-flow-app
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

### Invalidation Conditions
- Any journey failure reporting `Found 0 widgets with type "<FeatureScreen>"` (indicates privacy gate regression).
- Any journey failure on `FTextField` or button label matching (indicates unmigrated legacy widget).
- Failure of `check_e2e_executed.dart` returning non-zero.
