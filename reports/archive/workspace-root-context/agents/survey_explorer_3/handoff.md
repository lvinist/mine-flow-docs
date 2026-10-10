# Survey Explorer 3 — Codebase Structure, Toolchains, Automated Gates & Doctor Status Report

**Agent**: `survey_explorer_3`  
**Date**: 2026-09-16  
**Scope**: Codebase layout, git/repo status, build/test toolchain, automated gates, doctor checks, test suite structure, and environment prerequisites.

---

## 1. Observation

### 1.1 Workspace Layout & Multi-Repo Structure
- **Workspace Root**: `d:\AppDev\mine_flow`
  - The root directory is **not** a git repository (`fatal: not a git repository (or any of the parent directories): .git`).
  - Follows the Throughstone multi-repo specification (`Code/mine-flow-docs/AGENTS.md` lines 98–105).
- **Repositories & Directories**:
  1. **Flutter Application Repo**: `d:\AppDev\mine_flow\Code\mine-flow-app`
     - Contains the full Flutter/Dart application code (`lib/`), test suites (`test/`), integration test journeys (`integration_test/`), and CI tools (`tool/`).
  2. **Documentation Hub Repo**: `d:\AppDev\mine_flow\Code\mine-flow-docs`
     - Contains durable architecture docs (`architecture/01-*.md` through `17-*.md`), ADR records (`adr/`), registries (`registries/repos.yml`, `risks.yml`, `security-reviews.yml`), operational scripts (`scripts/`), and published audit reports (`reports/`).
  3. **Prompts & Roadmap Repo**: `d:\AppDev\mine_flow\prompts`
     - Contains `prompts/STEP-index.md` (roadmap and single source of truth for STEP statuses) and archived step plans/substeps (`prompts/001-*`, `002-*`, `003-*`).
  4. **Active STEP Scratchpad**: `d:\AppDev\mine_flow\Upcoming Prompts`
     - Working directory for in-flight work: contains active `mine-flow-STEP-55-PLAN.md`, prompts, and finding reports (`mine-flow-STEP-55.0-FINDINGS.md` through `mine-flow-STEP-55.11-FINDINGS.md`).
  5. **Workspace Scripts**:
     - `d:\AppDev\mine_flow\doctor.sh` — root Throughstone doctor wrapper, delegating to `Code/mine-flow-docs/scripts/doctor.sh`.
     - `d:\AppDev\mine_flow\init.sh` — project initialization and bootstrap script.

---

### 1.2 Git Status & Branch/Commit History (STEP-54 & STEP-55)

#### A. `Code/mine-flow-app`
- **Branch**: `step-0055-cohesive-ui-rebuild`
- **Status**: Clean working tree, up to date with `origin/step-0055-cohesive-ui-rebuild`.
- **Commit History**:
  - `a301e4b` `test(STEP-55.11): align attendance and daily log journeys`
  - `9c82d1b` `test(STEP-55.11): migrate audited journeys and pin privacy gate`
  - `c64b0b9` `style(data-bucket,timeline): dart format re-flow, l10n legacy exemptions (STEP-55.11 follow-up)`
  - `6ef9b52` `feat(shell): STEP-55.10 shell, dashboard, notifications, settings, and auth`
  - `89077bf` `feat(data-bucket,timeline): STEP-55.9 cohesion — authoritative routes, sheet/inspector, cancel/retry`
  - `aa04996` `fix(inventory): differentiate out-of-stock from low-stock states (STEP-55.8 follow-up)`
  - `16e31bd` `feat(inventory): Complete Substep 55.8 Cohesive UI Rebuild`
  - `9c28b12` `STEP-55.7: Equipment Check Migration and Polish`
  - `5db79c4` `STEP-55.6: Daily Log Role-Aware Workflow and Data Contract`
  - `116bb19` `STEP-55.5: Crew Attendance workflow rebuild`
  - `ee7de94` `feat(benchmark): benchmark integrity, inspector, and polish (STEP-55.4)`
  - `a74b20a` `fix(land-clearing): migrate UI, fix fetch by ID and tab routing`
  - `9dad444` `feat(STEP-55.0/55.1): implement shared primitives and contextual report dialog`
  - `fe12531` `chore(STEP-53.3): upgrade direct deps within declared ranges; fix lengthSync` (Pre-STEP-55 baseline head; STEP-54 was critique/spec only with no code changes on app).

#### B. `Code/mine-flow-docs`
- **Branch**: `step-0055-cohesive-ui-rebuild`
- **Status**: Untracked files present:
  - `reports/2026-09-14-step-55-multiplatform-impeccable-audit.md`
  - `reports/design-review/step-0055/` (contains `2026-09-14-web-login-1258x566.png`)
- **Recent Commits**:
  - `0102a9d` `STEP-55.6: Document structured hazard and approval contract`
  - `7659df7` `docs(STEP-54.11): publish master polish specification`
  - `bc77632` `docs(STEP-54.0): archive STEP-53 verification logs`
  - `891ce66` `docs(STEP-53.1-53.3): update RISK-0007, RISK-0009, RISK-0020 from 53.x findings`

#### C. `prompts`
- **Branch**: `main`
- **Status**: Ahead of `origin/main` by 2 commits; unstaged working tree modification in `STEP-index.md` (local edit marking 55.9 Done).
- **Recent Commits**:
  - `3ddfe2a` `STEP-55.7: Equipment Check Migration and Polish`
  - `89effe6` `STEP-55.6: Daily Log Role-Aware Workflow and Data Contract`
  - `61ed599` `chore: mark substep 55.4 as Done`
  - `e55d202` `Update STEP-55.0 and 55.1 status to Done`
  - `f71f433` `Start STEP-55 cohesive UI rebuild`

---

### 1.3 Automated Gates Invocations & Verbatim Results

#### Gate 1: Code Formatting
- **Command**: `dart format --output=none --set-exit-if-changed .` (in `Code/mine-flow-app`)
- **Exit Code**: `0`
- **Output**:
  ```text
  Formatted 360 files (0 changed) in 1.87 seconds.
  ```
- **Verdict**: **PASS**

#### Gate 2: Static Analysis
- **Command**: `flutter analyze` (in `Code/mine-flow-app`)
- **Exit Code**: `0`
- **Output**:
  ```text
  Analyzing mine-flow-app...
  No issues found! (ran in 129.1s)
  ```
- **Verdict**: **PASS**

#### Gate 3: Unit & Widget Test Suite
- **Command**: `flutter test` (in `Code/mine-flow-app`)
- **Exit Code**: `0`
- **Output**:
  ```text
  02:52 +684 ~5: All tests passed!
  ```
- **Breakdown**: 684 passed, 5 skipped, 0 failed. All 5 skips are pre-existing CI grammar fixture guards in `test/tool/check_e2e_executed_test.dart` that intentionally skip when local workspace CI artifacts are absent.
- **Verdict**: **PASS 100%**

#### Gate 4: Web Release Compilation
- **Command**: `flutter build web --release` (in `Code/mine-flow-app`)
- **Exit Code**: `0`
- **Output**:
  ```text
  Compiling lib\main.dart for the Web...
  Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag...
  Font asset "lucide.ttf" was tree-shaken, reducing it from 877160 to 38976 bytes (95.6% reduction)...
  Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 8128 bytes (99.5% reduction)...
  Compiling lib\main.dart for the Web...                             99.4s
  √ Built build\web
  ```
- **Verdict**: **PASS**

#### Gate 5: Doctor Status & Duplicate STEP Scan
- **Command**: `& "C:\Program Files\Git\bin\sh.exe" .\doctor.sh status` (from workspace root)
- **Exit Code**: `0`
- **Output**:
  ```text
  Throughstone status — /d/AppDev/mine_flow

  Where you are:
    Building — STEP-55 (Cohesive UI Rebuild — Form Sheets, Contextual Report Dialogs & Impeccable Audit) is In progress.

  Next action:
    → open STEP-55's PLAN in "Upcoming Prompts/" and run its lowest open substep ("run substep N.M"). When the last is done: review, archive to prompts/, mark STEP-55 Done.
    (start a fresh chat for it — state lives on disk, not in this conversation.)

  Check-in cadence:
    last at STEP-50, 5 STEPs ago — ~5–15 STEPs of headroom.
  ```
- **Verdict**: **PASS**

- **Duplicate STEP Scan Command**:
  `& "C:\Program Files\Git\bin\sh.exe" -c "grep -oE '^\|[[:space:]]*STEP-[0-9]+' prompts/STEP-index.md | grep -oE 'STEP-[0-9]+' | sort | uniq -d"`
- **Exit Code**: `0`
- **Output**: (empty string — 0 duplicate STEP numbers found)
- **Verdict**: **PASS**

#### Gate 6: Additional Repository Automated Guards
1. **Localization Hardcoding Guard**:
   - Command: `dart run tool/check_l10n_baseline.dart` (in `Code/mine-flow-app`)
   - Exit Code: `0`
   - Output: `Files scanned (non-exempt): 22, Files exempt (legacy): 47, [OK] No new hardcoded strings detected in non-exempt files.`
   - Verdict: **PASS**
2. **Supabase Contract Sync Guard**:
   - Command: `dart run tool/check_supabase_contracts.dart` (in `Code/mine-flow-app`)
   - Exit Code: `0`
   - Output: `[OK] Contract verification passed.`
   - Verdict: **PASS**

#### Gate 7: Doctor Structural Integrity Check (`doctor.sh check`)
- **Command**: `& "C:\Program Files\Git\bin\sh.exe" .\doctor.sh check` (from workspace root)
- **Exit Code**: `1` (fails on Check 10 only)
- **Detailed Subcheck Results**:
  - `1. Duplicate STEP numbers`: **PASS**
  - `2. Duplicate ADR numbers`: **PASS**
  - `3. Statuses valid`: **PASS**
  - `4. Architecture docs carry Version / Status / Version Log`: **PASS** (all 16 docs verified)
  - `5. ADR registry matches ADR files on disk`: **PASS** (19 ADRs verified)
  - `6. Legacy local user profile fields`: **PASS**
  - `7. Workspace-root hygiene`: **WARN** (`unexpected entr(ies) at workspace root: DESIGN.md NUL ORIGINAL_REQUEST.md PRODUCT.md .agent .agents .gemini .hermes .impeccable .scratch-tmp` — expected advisory in agent multi-tool workspace)
  - `8. Architecture-session template numbering`: **PASS**
  - `9. Conditional-session template contract`: **PASS**
  - `10. Registry YAML parse and byte hygiene`: **FAIL**
    - Verbatim error:
      ```text
      Python was not found; run without arguments to install from the Microsoft Store, or disable this shortcut from Settings > Apps > Advanced app settings > App execution aliases.
        [FAIL] registries/repos.yml is invalid or has unsafe bytes: Python was not found...
      ```
    - Investigation of Failure: Check 10 executes `command -v python` and invokes `python -`. On this Windows installation, `python.exe` resolves to the Microsoft Store execution alias stub `C:\Users\Alpxalpha\AppData\Local\Microsoft\WindowsApps\python.exe`.
    - **Independent Verification of YAML Integrity**: Executed `uv run --with pyyaml python -c "..."` using the machine's installed Python 3.11.15.
      - `Code/mine-flow-docs/registries/repos.yml`: **VALID**
      - `Code/mine-flow-docs/registries/risks.yml`: **VALID**
      - `Code/mine-flow-docs/registries/security-reviews.yml`: **VALID**
      - Zero `0x0c` form-feed or lone `0x0d` bytes exist in any of the three registry files.

---

### 1.4 Test Suite Organization & Runners

The test suites are organized across two main directories in `Code/mine-flow-app`:

1. **Unit & Widget Test Suites (`test/` — 73 test files, 684 passing tests)**:
   - Runner: `flutter test`
   - Structure:
     - `test/app/`: `app_shell_test.dart`, `locale_configuration_test.dart`, `router_test.dart` (validates deep-link URL parsing, query params, branch persistence).
     - `test/core/`: Network clients (Google Drive service), presentation widgets (`app_interaction_primitives_test.dart`, `creatable_combobox_open_test.dart`), PDF generation, logger redaction.
     - `test/features/`: Feature BLoC, repository, and UI widget tests across attendance, auth (`privacy_ack_page_test.dart`), benchmark, daily log, data bucket, notifications, reporting (`app_contextual_report_dialog_test.dart`), settings, timeline, tracking, and zone.
     - `test/integration/`: Sub-system integration tests for sync queues and auth repositories (`attendance_daily_log_sync_test.dart`, `sync_queue_manager_test.dart`).
     - `test/tool/`: Subprocess verification tests for the repo guards (`check_e2e_executed_test.dart`, `check_l10n_baseline_test.dart`, `check_supabase_contracts_test.dart`).
     - `test/unit/`: Model serialization, repository implementations, Hive local storage adapters.
     - `test/widget/`: Screen-level widget tests and design system compliance (e.g. verifying zero legacy Material buttons/cards remain).

2. **Integration / End-to-End Test Suite (`integration_test/` — 21 journey files)**:
   - Runner:
     - Web: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/journeys/<journey>_test.dart -d chrome`
     - Android: `flutter test integration_test/journeys/<journey>_test.dart -d <emulator_id>`
   - Drivers: `test_driver/integration_test.dart`
   - Journeys: `app_boots`, `auth`, `attendance`, `benchmark`, `cut_fill`, `daily_log`, `data_bucket`, `deep_link`, `equipment_check`, `inventory`, `land_clearing`, `notifications`, `offline_sync`, `reporting`, `rls_authorization`, `timeline`, `design_review_capture`.
   - Helper infrastructure: `integration_test/helpers/` (`app_harness.dart`, `login_helper.dart`, `offline_helper.dart`, `staging_config.dart`).

---

### 1.5 Toolchain & Environment Prerequisites

- **Host OS**: Microsoft Windows 11 (25H2, build 10.0.26200.9445).
- **Flutter SDK**:
  - Version: `3.47.1` (channel stable, revision `6655482ec0`).
  - Path: `D:\AppDev\flutter`.
- **Dart SDK**:
  - Version: `3.13.1` (DevTools 2.60.0).
- **Java / JDK**:
  - Version: OpenJDK Runtime Environment Temurin-17.0.20.1+1 (build 17.0.20.1+1).
  - Path: `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\java`.
- **Android Toolchain**:
  - Android SDK: Version 36.0.0 at `C:\Users\Alpxalpha\AppData\Local\Android\sdk`.
  - Platforms: `android-37.0`, build-tools `36.0.0`.
  - Emulator: Version 35.5.10.0.
  - Installed AVD: `Pixel_6a` (`Pixel 6a • Google • android`).
  - Known toolchain notes:
    - Multiple `adb` binaries found: Android SDK platform-tools vs Genymobile scrcpy WinGet package.
    - Android licenses: `Some Android licenses not accepted` (`flutter doctor --android-licenses` can be run if needed).
- **Web Browsers**:
  - Google Chrome: Version 152.0.7977.84 at `C:\Program Files\Google\Chrome\Application\chrome.exe`.
  - Microsoft Edge: Version 153.0.4234.32.
- **Python Environment**:
  - System `python.exe` / `python3.exe`: Points to Microsoft Store App Execution Alias stub at `C:\Users\Alpxalpha\AppData\Local\Microsoft\WindowsApps\python.exe`.
  - Python 3.11 runtime: Managed by `uv` (0.12.13) at `C:\Users\Alpxalpha\AppData\Roaming\uv\python\cpython-3.11.15-windows-x86_64-none\python.exe`.
- **Shell & Terminal Protocol**:
  - Shell scripts (`.sh`) **must** be executed via Git Bash from Windows PowerShell:
    `& "C:\Program Files\Git\bin\sh.exe" .\doctor.sh <command>`
  - Path switching across drives requires explicit drive letter selection first in PowerShell.

---

## 2. Logic Chain

1. **Workspace Architecture**:
   - Observation 1.1 establishes that the root is not a git repository and contains three distinct sibling repositories (`Code/mine-flow-app`, `Code/mine-flow-docs`, and `prompts`).
   - Therefore, commands targeting application code must run with `Cwd: Code/mine-flow-app`, documentation commands in `Code/mine-flow-docs`, and index operations in `prompts`.

2. **Automated Gates Reliability**:
   - Observations 1.3 demonstrate that:
     - `dart format` reported 0 changes across 360 files.
     - `flutter analyze` finished with 0 issues in 129.1s.
     - `flutter test` executed all 689 tests with 684 passed, 5 skipped (fixture guards), 0 failed.
     - `flutter build web --release` successfully produced `build\web`.
     - `check_l10n_baseline.dart` and `check_supabase_contracts.dart` passed with 0 violations.
     - `doctor.sh status` and the duplicate STEP regex scan passed cleanly.
   - Therefore, the local static, unit test, and compilation gates are in a 100% green state.

3. **Root Cause of `doctor.sh check` Failure**:
   - Observation 1.3 (Check 10) and Observation 1.5 reveal that `check.sh` and `links.sh` execute `python` / `python3`.
   - On Windows, `python.exe` in PATH is captured by `WindowsApps\python.exe` which exits with error code 9009 unless configured in Windows App Execution Aliases.
   - Observation 1.3 independently verified all registries (`repos.yml`, `risks.yml`, `security-reviews.yml`) via `uv run --with pyyaml python`, confirming 0 syntax errors and 0 illegal bytes.
   - Therefore, the project registries and documentation are semantically healthy; the failure is purely an environment-level alias shadowing issue in Git Bash on Windows.

4. **STEP-54 / STEP-55 Implementation State**:
   - Observation 1.2 demonstrates that the app repo is clean at commit `a301e4b`, which completed the STEP-55.11 journey alignment and privacy gate pinning.
   - All 55.0–55.10 feature rebuilds are committed on branch `step-0055-cohesive-ui-rebuild`.
   - Upcoming Prompts contains detailed evidence through `mine-flow-STEP-55.11-FINDINGS.md`.
   - Therefore, the application is at the final verification and audit close stage of STEP-55.11.

---

## 3. Caveats

1. **End-to-End Test Execution**: While unit/widget tests were executed and passed 100% (684/684), full live dual-platform E2E journeys (`integration_test/`) were not re-executed during this read-only survey. Running them requires booting the `Pixel_6a` emulator, starting ChromeDriver, and connecting to the live Supabase staging project with valid test credentials (`TEST_SUPERVISOR_*`, `TEST_CREW_*`).
2. **Untracked Docs Files**: `Code/mine-flow-docs` has untracked reports (`reports/2026-09-14-step-55-multiplatform-impeccable-audit.md` and `reports/design-review/step-0055/`). These are artifacts from earlier audit rounds awaiting formal staging/commit during close.
3. **Unstaged Index Edit**: `prompts/STEP-index.md` has an unstaged modification marking substep 55.9 as Done.
4. **No Assumptions on Android Licenses**: `flutter doctor -v` reported unaccepted Android licenses. If native Android Gradle builds fail during future steps, running `flutter doctor --android-licenses` will be required.

---

## 4. Conclusion

1. **Codebase & Workspace Health**: The codebase structure strictly follows Throughstone multi-repo conventions. The workspace root, app repository, docs repository, and prompts repository are cleanly separated and functional.
2. **Automated Gates Status**:
   - `dart format`: **PASS**
   - `flutter analyze`: **PASS**
   - `flutter test`: **PASS (684/684)**
   - `flutter build web --release`: **PASS**
   - `./doctor.sh status` & duplicate STEP scan: **PASS**
   - Project-specific guards (`check_l10n_baseline`, `check_supabase_contracts`): **PASS**
   - `./doctor.sh check`: **9/10 passed/warned**; check 10 failed solely due to Windows Python App Execution Alias, while the underlying YAML files were proven valid.
3. **Toolchain Readiness**: Flutter 3.47.1, Dart 3.13.1, Java 17 Temurin, Android SDK 36, Pixel_6a emulator, and Google Chrome 152 are installed and ready for full execution.

---

## 5. Verification Method

To independently verify these findings, run the following commands:

1. **Verify Root & Doctor Status**:
   ```powershell
   & "C:\Program Files\Git\bin\sh.exe" .\doctor.sh status
   & "C:\Program Files\Git\bin\sh.exe" -c "grep -oE '^\|[[:space:]]*STEP-[0-9]+' prompts/STEP-index.md | grep -oE 'STEP-[0-9]+' | sort | uniq -d"
   ```
   *Expected*: Status indicates STEP-55 In progress; duplicate scan output is empty.

2. **Verify App Code Formatting & Static Analysis**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   ```
   *Expected*: `Formatted 360 files (0 changed)`, `No issues found!`.

3. **Verify Full Unit/Widget Test Suite**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   flutter test
   ```
   *Expected*: `All tests passed! (684 passed, 5 skipped)`.

4. **Verify Web Release Build**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   flutter build web --release
   ```
   *Expected*: Exit code 0, `√ Built build\web`.

5. **Verify Project Guards**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   dart run tool/check_l10n_baseline.dart
   dart run tool/check_supabase_contracts.dart
   ```
   *Expected*: Both output `[OK]` with exit code 0.

6. **Verify Registry YAML Validity**:
   ```powershell
   cd d:\AppDev\mine_flow
   uv run --with pyyaml python -c "import glob, yaml; [yaml.safe_load(open(p, 'rb').read()) for p in glob.glob('Code/mine-flow-docs/registries/*.yml')]; print('ALL REGISTRIES VALID')"
   ```
   *Expected*: `ALL REGISTRIES VALID`.
