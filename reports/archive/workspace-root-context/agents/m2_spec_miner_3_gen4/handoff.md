# STEP-55.11 Milestone 2 — Authoritative Specification Mining Report
**Auditor / Spec Miner:** `m2_spec_miner_3_gen4`  
**Date:** 2026-09-17  
**Working Directory:** `d:/AppDev/mine_flow/.agents/m2_spec_miner_3_gen4`  
**Parent Orchestrator ID:** `4af240b7-3229-4675-b201-32ad0b0dea69`  
**Objective:** Mine and document all authoritative specifications, rubrics, and evidence requirements for the design review screenshot capture and Impeccable multiplatform audit report.

---

## 1. Observation

Direct evidence gathered across authoritative repositories, specification documents, and executable scripts:

1. **User Request & Acceptance Mandates (`ORIGINAL_REQUEST.md` lines 16–37, 64–82):**
   - Impeccable Protocol: "Execute a maximum two-round cycle: (1) capture all required states/platforms together, score and batch defects; (2) after one consolidated fix batch, recapture only affected/required confirmations. Stop after confirmation and report remaining gaps."
   - Runtime Matrix: "Web (widths 799, 800, 801, 1024, >=1280px) and Android (Pixel_6a portrait). Cover Light/Dark themes, Text scaling (1.0x, 1.3x, 2.0x), multiple input methods, routes, states, and paths."
   - Evidence Integrity: "Every image record must include command/route, platform/viewport/device, theme/state, bytes, and dimensions. No shortcuts or synthetic evidence allowed." Target: `>=48x48 logical px`. Contrast: WCAG AA `4.5:1` normal text, `3:1` large text and essential UI/focus.
   - Storage isolation: Must write cleanly to `reports/design-review/step-0055/` without clobbering historical artifacts.
   - PII/Credential Hygiene: "Artifacts contain no credentials, PII, tokens, or sensitive operational data."

2. **Project Contract & Interface Layout (`PROJECT.md` lines 10–12, 46–58):**
   - Canonical 800dp breakpoint cleanly separates Desktop (`_WideLayout`: collapsible `FSidebar` + `GlobalAppHeader`) from Mobile (`_NarrowLayout`: 5-tab `FBottomNavigationBar`).
   - Shared Primitives: `AppResponsiveSheet` (modal right sheet 480–600dp on Web, draggable bottom sheet on Mobile), `AppDismissController` & `AppDirtyDismissDialog` (unifying 8 dismissal paths), `AppContextualReportDialog` (7 feature types pre-bound).
   - Test Driver Contract: `test_driver/integration_test.dart` writes to `../mine-flow-docs/reports/design-review/step-0055/$screenshotName.png`. Rejects 68-byte synthetic placeholders and enforces PNG magic header bytes.

3. **UI Design System Specification (`Doc 07 — UI / Design System` v0.5.0):**
   - Section 2: ForUI Zinc (`FThemes.zinc` / `FThemes.zinc.dark`), Geist typography, compact density, Lucide icons.
   - Section 4: Canonical wide/narrow layout boundary is **800dp**. Tests must exercise immediately below (799dp), at (800dp), and immediately above (801dp). Web adapts to breakpoints; Android is strictly locked to portrait mobile.
   - Section 4.1: Responsive form sheets (Web right sheet 480–600dp, Mobile bottom sheet). Universal dirty dismissal with Indonesian copy: *"Perubahan belum disimpan"*, *"Lanjut Mengedit"*, *"Buang Perubahan"*.
   - Section 5: Target size minimum `48x48dp`. Transitions: `150–200ms` with reduced-motion bypass.

4. **STEP-54 Master Polish Spec & Traceability (`2026-09-11-step-54-master-polish-spec.md`):**
   - Full Route Table (§2.6): List, create (`/form`), and edit/detail (`/:id/form` or `/:id`) routes for all 10 feature areas.
   - D7 Detail Verdicts (§5): Read-only inspector for Land Clearing, Benchmark, Data Bucket; mobile full-page detail for Equipment Check and Inventory; direct edit sheet (no inspector) for Cut & Fill; read-only form state for Daily Log; batch form for Attendance.
   - Report Dialog Inventory (§3.2): 7 contextual report types pre-bound; Data Bucket and Timeline are deliberately report-free.

5. **Test Driver Implementation (`Code/mine-flow-app/test_driver/integration_test.dart` lines 4–115):**
   - Destination resolution priority: `args['destinationDirectory']` -> `SCREENSHOT_DESTINATION_DIR` env -> default `../mine-flow-docs/reports/design-review/step-0055`.
   - Historical protection guard: Throws `StateError` if destination path contains `step-0048`, `step-0045`, `step-0046`, `step-0047`, `step-0050`, or `step-0054`.
   - PNG validation: Checks `bytes.isNotEmpty`, `bytes.length >= 8`, PNG magic header `[137, 80, 78, 71, 13, 10, 26, 10]`, and explicitly rejects `bytes.length == 68` (1x1 placeholder).

6. **Capture Harness Implementation (`Code/mine-flow-app/integration_test/design_review_capture_test.dart`):**
   - Web matrix: 3 breakpoints (`phone` 400x800, `tablet` 700x1000, `desktop` 1200x900) × 2 themes (`light`, `dark`) × 2 locales (`id`, `en`) × 6 screens (`dashboard`, `daily-log`, `daily-log-form`, `operations`, `teams`, `tools`) + 1 login = 73 screenshots.
   - Android matrix: 1 breakpoint (`phone` 400x800) × 2 themes × 2 locales × 6 screens + 1 login = 25 screenshots prefixed with `android-`.
   - On Android: calls `binding.convertFlutterSurfaceToImage()` before capturing.

7. **Impeccable Audit Rubric (`.agent/skills/impeccable/reference/audit.md` & `audit.native.md`):**
   - Web Technical Audit: 5 dimensions scored 0–4 (Accessibility, Performance, Theming, Responsive Design, Implementation Integrity), total 0–20.
   - Native Android Audit: 5 dimensions scored 0–4 (Accessibility [VoiceOver/TalkBack], Performance, Appearance & Theming, Platform Conformance, Adaptivity), total 0–20.
   - Rating Bands: 18–20 Excellent, 14–17 Good, 10–13 Acceptable, 6–9 Poor, 0–5 Critical.
   - Severity Tiers: P0 Blocker, P1 Critical/Major, P2 Minor, P3 Polish.

8. **Script Runners & Staging Harness (`Code/mine-flow-app/.step55.11h-run-web.sh`, `ci.yml`):**
   - Shell runners load credentials from `.env` using associative arrays (`declare -A ENVV`) and pass via `--dart-define`, preventing secret leakage in terminal logs or command histories.
   - CI executes Web E2E via `chromedriver --port=4444` and `flutter drive --driver=test_driver/integration_test.dart --target=run_web_wrapper.dart -d web-server --browser-name=chrome`.
   - Android CI executes on `Pixel_6a` emulator (API 33, `swiftshader_indirect`).

---

## 2. Logic Chain

```
[User Request R1/R2/R3 & PROJECT.md]
  │
  ├── 1. Screenshot Matrix Definition
  │     ├── Breakpoints: 799dp (narrow), 800dp (boundary), 801dp (wide), 1024dp, 1280dp, phone (400x800 / 412x915)
  │     ├── Themes (Light/Dark) × Locales (id/en) × Routes (Shell, Forms, Dialogs)
  │     ├── Target isolation: reports/design-review/step-0055/ (protected historical steps)
  │     └── Validation: PNG magic bytes [137, 80, 78, 71, 13, 10, 26, 10], length != 68 bytes, zero PII
  │
  ├── 2. Impeccable Audit Protocol
  │     ├── Round 1: Full multiplatform capture + 5-dimension diagnostic scan (Web 0-20, Android 0-20)
  │     ├── Consolidated Fix Batch: Resolve P0/P1 defects within approved specification
  │     ├── Round 2: Confirmation recapture of affected surfaces; stop and report remaining gaps
  │     └── Durable Report: Code/mine-flow-docs/reports/YYYY-MM-DD-step-55-multiplatform-impeccable-audit.md
  │
  └── 3. Execution Runner & Driver Architecture
        ├── Web: chromedriver + flutter drive --driver=test_driver/integration_test.dart
        ├── Android: flutter drive (for screenshots) or flutter test (for journey validation) on Pixel_6a
        └── Security: Associative .env loading with zero token echo; logger header sanitization
```

1. **Reconciliation of Screenshot Naming & Directory Structure:**
   - In STEP-48, 73 synthetic 68-byte placeholders were committed under `reports/design-review/step-0048/`.
   - In STEP-55, `test_driver/integration_test.dart` was hardened in Milestone 1 to point to `reports/design-review/step-0055/` and actively blocks any path containing historical step names.
   - For Web, the standard matrix consists of 73 baseline screenshots (or 121 extended screenshots covering all 5 explicit widths).
   - For Android, screenshots are prefixed with `android-` (25 baseline screenshots).
   - The naming scheme `[platformPrefix][screen]-[breakpoint]-[theme]-[locale].png` guarantees deterministic mapping and 1:1 traceability.

2. **Root Cause Analysis of Prior Android Capture Failure (1/24 Artifact Gap):**
   - In Run 2 (`mine-flow-STEP-55.11-FINDINGS.md`), only `android-login-phone-light-en.png` was recorded, while subsequent routes timed out.
   - Root causes:
     a. `binding.convertFlutterSurfaceToImage()` was invoked once before login, but modifying `tester.view.physicalSize` in-test without re-synchronizing surface rendering can cause subsequent surface readbacks to hang.
     b. When `flutter test integration_test/design_review_capture_test.dart` is run directly without `flutter drive`, Flutter's integration binding lacks a connected driver server to receive and persist screenshots to the host machine unless an external callback or `flutter drive` protocol is active.
     c. `_captureScreenshot` used a 5-second polling loop with `tester.pump(100ms)`; route navigation transitions and BLoC async loading occasionally exceed 5s on cold emulator frames.

3. **Impeccable Audit Scoring System:**
   - Adapts the canonical Impeccable technical scan to Flutter CanvasKit and Android native widgets.
   - Discards DOM-only detectors (`impeccable detect` produces false negatives on CanvasKit) in favor of real runtime pixel measurements, contrast ratio calculations, touch target bounding boxes (`>=48x48dp`), and platform semantics trees (`flt-semantics` on Web, AccessibilityNodeProvider on Android).
   - Both Web and Android receive an independent 0–20 score based on 5 distinct dimensions (each 0–4).

---

## 3. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Screenshot Matrix | Dual-Platform Filename Convention | Standardized filename format: `[platformPrefix][screen]-[breakpoint]-[theme]-[locale].png` | Prefix (`''` or `'android-'`), screen name, breakpoint name, theme mode, locale code | Unique PNG filename string | Missing parameter produces malformed name | `design_review_capture_test.dart:180-182` |
| 2 | Screenshot Matrix | Target Directory Isolation | Driver routes output to `reports/design-review/step-0055/` with environment and argument override | `SCREENSHOT_DESTINATION_DIR`, CLI args | Absolute file write path | Throws `StateError` if targeting historical release steps | `test_driver/integration_test.dart:52-84` |
| 3 | Screenshot Matrix | PNG Header Magic Byte Guard | Validates 8-byte magic header `[137, 80, 78, 71, 13, 10, 26, 10]` | Screenshot byte buffer | Boolean validity flag | Logs `[driver] ERROR` and rejects file write if invalid | `test_driver/integration_test.dart:4-39` |
| 4 | Screenshot Matrix | Synthetic Placeholder Rejection | Explicitly rejects 68-byte 1x1 synthetic dummy PNGs | Byte count (`length == 68`) | Boolean rejection | Logs synthetic placeholder error; returns false | `test_driver/integration_test.dart:41-47` |
| 5 | Screenshot Matrix | Responsive Width Sweep (Web) | Evaluates layout across 5 widths: 799dp (<800dp narrow), 800dp (boundary), 801dp (>800dp wide), 1024dp, >=1280dp | Viewport physical size and DPR | Responsive layout switch (`_NarrowLayout` vs `_WideLayout`) | Overflow or sidebar obstruction if layout fails | `Doc 07 §4`, `ORIGINAL_REQUEST.md:78` |
| 6 | Screenshot Matrix | Android Portrait Locking | Restricts Android capture to portrait phone (400x800 / 412x915) | Platform check `!kIsWeb` | Phone-only breakpoint iteration | Rejects wide viewport forcing on mobile | `Doc 07 §5`, `design_review_capture_test.dart:14-19` |
| 7 | Screenshot Matrix | Dual-Theme Capture | Captures all screens in both ForUI Zinc light (`FThemes.zinc`) and dark (`FThemes.zinc.dark`) | `ThemeMode.light`, `ThemeMode.dark` | Rendered theme palette | Low contrast or unreadable text flagged | `Doc 07 §2`, `design_review_capture_test.dart:140-144` |
| 8 | Screenshot Matrix | Dual-Locale Verification | Captures Indonesian (`id`) and English (`en`) UI strings | `Locale('id')`, `Locale('en')` | Localized text render | Untranslated or missing ARB keys flagged | `Doc 07 §5`, `design_review_capture_test.dart:145-149` |
| 9 | Screenshot Matrix | Sensitive Header Redaction | RegEx redaction of `Authorization: Bearer`, `apikey`, `cookie`, and `token` | Log messages / HTTP debug outputs | Sanitized output with `<redacted>` | Fails unit test if secrets escape | `lib/core/utils/logger.dart:31-45` |
| 10 | Impeccable Audit | 2-Round Audit Protocol | Maximum two-round inspection: Round 1 (all platforms, score/batch), Round 2 (recapture confirmations only) | Platform captures & defect batches | Baseline & confirmed health scores | Halts cycle after Round 2 confirmation; reports residual gaps | `impeccable/SKILL.md:16`, `ORIGINAL_REQUEST.md:16-18` |
| 11 | Impeccable Audit | Web Health Score (0–20) | 5-dimension diagnostic evaluation: A11y, Performance, Theming, Responsive, Implementation Integrity | 0–4 score per dimension | Total score `??/20` and rating band | Rating < 14 indicates release blockage | `impeccable/reference/audit.md:65-76` |
| 12 | Impeccable Audit | Android Health Score (0–20) | 5-dimension native evaluation: VoiceOver/TalkBack, Performance, Appearance/Theming, Conformance, Adaptivity | 0–4 score per dimension | Total score `??/20` and rating band | Rating < 14 indicates release blockage | `impeccable/reference/audit.native.md:68-79` |
| 13 | Impeccable Audit | Defect Severity Classification | 4-tier defect categorization: P0 Blocker, P1 Critical, P2 Major, P3 Polish | Defect impact, WCAG AA / platform rule | Prioritized defect register | P0/P1 defects block release approval | `impeccable/reference/audit.md:88-103` |
| 14 | Impeccable Audit | Audit Report Markdown Schema | Structured audit report schema under `Code/mine-flow-docs/reports/` | Audit evidence, scores, logs, defect tables | Formatted markdown document | Incomplete evidence marks report as NO-GO | `2026-09-14-step-55-multiplatform-impeccable-audit.md` |
| 15 | Test Execution | Secure Env Injection Runner | Bash script parsing `.env` into associative array without echoing values | `.env` file | Array of `--dart-define` parameters | Exits with error if critical env vars missing | `Code/mine-flow-app/.step55.11h-run-web.sh:8-30` |
| 16 | Test Execution | Web Integration Test Runner | Executes journey or capture tests using ChromeDriver and Flutter web-server driver | Target file, chromedriver on port 4444 | Test log and captured PNG artifacts | Exit non-zero on test assertion failure | `Code/mine-flow-app/.step55.11h-run-web.sh:37-46` |
| 17 | Test Execution | Android Emulator Runner | Executes journeys or capture tests on Pixel_6a emulator via adb / test harness | Target file, emulator serial (`emulator-5554`) | Integration test execution log | Exit non-zero on assertion failure | `Code/mine-flow-app/.step55.11f-run-all.sh:5-25` |
| 18 | Verification Guard | Zero-Executed Test Guard | Verifies that at least one test body executed and wasn't skipped | Test runner log file | Exit code 0 (passed) or 1 (all skipped/vacuous) | Fails CI job if test count is zero | `tool/ci/check_e2e_executed.dart` |

---

## 4. Edge Cases & Boundary Conditions

| # | Feature | Input | Observed Behavior | Handling / Rule |
|---|---------|-------|-------------------|-----------------|
| 1 | Test Driver Destination | Output path targeting `reports/design-review/step-0048/` | Throws `StateError: Hazard prevented: destination directory targets historical release directory` | Explicit protection list prevents accidental clobbering of committed historical evidence. |
| 2 | Screenshot Byte Validator | Injected byte array of exactly 68 bytes | Rejected with `[driver] ERROR: Screenshot is exactly 68 bytes (known 1x1 placeholder)` | Prohibits synthetic placeholders from satisfying evidence requirements. |
| 3 | Screenshot Byte Validator | Byte array with corrupted magic numbers (e.g. `[0, 0, 0, 0, ...]`) | Rejected with `[driver] ERROR: lacks valid PNG signature header` | Prevents writing truncated or corrupt image buffers to reports. |
| 4 | Responsive Boundary (Web) | Viewport width set to exactly `799dp` | Renders `_NarrowLayout` (`FBottomNavigationBar` visible; `FSidebar` hidden; forms open as bottom sheets) | Verifies narrow layout behavior immediately below 800dp boundary. |
| 5 | Responsive Boundary (Web) | Viewport width set to exactly `800dp` | Renders `_WideLayout` (`FSidebar` visible; `FBottomNavigationBar` hidden; forms open as 480–600dp right sheets) | Validates boundary switch point. |
| 6 | Responsive Boundary (Web) | Viewport width set to exactly `801dp` | Renders `_WideLayout` with full desktop sidebar and global header | Verifies wide layout immediately above boundary. |
| 7 | Android Surface Conversion | `binding.takeScreenshot()` invoked without `convertFlutterSurfaceToImage()` | Throws `Bad state: Call convertFlutterSurfaceToImage()` | Must call `await binding.convertFlutterSurfaceToImage()` on Android before capturing any frame. |
| 8 | Android Capture without Driver | `binding.takeScreenshot()` invoked inside standalone `flutter test` | Screenshot captures locally in memory or times out; host file is never written | Must run via `flutter drive --driver=test_driver/integration_test.dart` to persist files to host disk. |
| 9 | Authentication Session Init | Cold app start with populated secure storage | App boots directly into authenticated dashboard or privacy gate, skipping `/login` | Harness must call `await storage.clearAll()` and `signOut()` before login tests. |
| 10 | Privacy Notice Gate | Authenticated user with `privacyAckVersion == 0` | Router redirects any route to `/privacy-gate` | `loginAsStagingUser` must await `updatePrivacyAckVersion(1)` before navigating to feature screens. |
| 11 | Text Scaling at 2.0x | System text scale set to `2.0` on mobile forms | UI elements adjust spacing; text wraps without vertical clipping or button truncation | Must verify no overflow errors (`A RenderFlex overflowed...`). |
| 12 | Dirty Dismissal (8 Paths) | Unsaved form state interrupted by back button, Escape, or scrim tap | Displays `AppDirtyDismissDialog` with *"Perubahan belum disimpan"* | Dismissal blocked until user confirms *"Buang Perubahan"* or resumes via *"Lanjut Mengedit"*. |

---

## 5. Caveats

1. **Harness Driver Distinction:** Running `flutter test integration_test/design_review_capture_test.dart` directly on Android verifies in-app widget assertions, but host-side PNG writing requires the driver protocol (`flutter drive --driver=test_driver/integration_test.dart`). This explains why previous local runs reported `1/24` or green exit codes without persisting images to `reports/design-review/step-0055/`.
2. **CanvasKit DOM Blindness:** The standard Impeccable tool `impeccable detect` inspects HTML/CSS DOM trees. Because Flutter Web compiles to CanvasKit/Skia WebGL canvases, DOM inspections yield no styling signals. All audit scoring must rely strictly on runtime pixel evidence, platform accessibility trees (`flt-semantics`), and widget tree telemetry.
3. **Emulator Pixel Density:** A physical Pixel 6a has a screen resolution of 1080x2400 (412x915 dp @ 2.625 DPR). In Flutter test harnesses, setting `tester.view.physicalSize = const Size(400, 800)` overrides physical geometry. The test must restore physical dimensions when native display fidelity is required.

---

## 6. Conclusion & Specification Architecture

### 6.1 Screenshot Matrix Specification

#### Storage Location
- Target Path: `Code/mine-flow-docs/reports/design-review/step-0055/`
- Full Relative Path from App: `../mine-flow-docs/reports/design-review/step-0055/`

#### Baseline Inventory (98 Total Captured Files)
- **Web Baseline (73 files):**
  - `login-phone-light-en.png`
  - 6 Screens × 3 Breakpoints (`phone`, `tablet`, `desktop`) × 2 Themes (`light`, `dark`) × 2 Locales (`id`, `en`):
    - `dashboard-[phone|tablet|desktop]-[light|dark]-[id|en].png` (12 files)
    - `daily-log-[phone|tablet|desktop]-[light|dark]-[id|en].png` (12 files)
    - `daily-log-form-[phone|tablet|desktop]-[light|dark]-[id|en].png` (12 files)
    - `operations-[phone|tablet|desktop]-[light|dark]-[id|en].png` (12 files)
    - `teams-[phone|tablet|desktop]-[light|dark]-[id|en].png` (12 files)
    - `tools-[phone|tablet|desktop]-[light|dark]-[id|en].png` (12 files)
- **Android Baseline (25 files):**
  - `android-login-phone-light-en.png`
  - 6 Screens × 1 Breakpoint (`phone`) × 2 Themes (`light`, `dark`) × 2 Locales (`id`, `en`):
    - `android-dashboard-phone-[light|dark]-[id|en].png` (4 files)
    - `android-daily-log-phone-[light|dark]-[id|en].png` (4 files)
    - `android-daily-log-form-phone-[light|dark]-[id|en].png` (4 files)
    - `android-operations-phone-[light|dark]-[id|en].png` (4 files)
    - `android-teams-phone-[light|dark]-[id|en].png` (4 files)
    - `android-tools-phone-[light|dark]-[id|en].png` (4 files)

#### Extended Breakpoint Inventory (Web 5-Width Sweep)
When exercising the exact boundary matrix required by Doc 07 §4 and ORIGINAL_REQUEST R3:
- Breakpoints: `w799` (799x800), `w800` (800x900), `w801` (801x900), `w1024` (1024x768), `w1280` (1280x900).
- 6 Screens × 5 Widths × 2 Themes × 2 Locales = **120 files** (+ 1 login = **121 files**).

---

### 6.2 2-Round Impeccable Audit Protocol

```markdown
# Round 1: Full State & Multiplatform Baseline
1. Launch ChromeDriver & Pixel_6a Emulator.
2. Run Web and Android captures simultaneously across all required states.
3. Perform Diagnostic Scan across 5 dimensions for Web and 5 dimensions for Android.
4. Calculate Baseline Health Scores (Web ??/20, Android ??/20).
5. Aggregate and batch all defects into P0, P1, P2, P3 tiers.
6. Publish intermediate findings.

# Consolidated Fix Batch
1. Resolve all P0 blockers (harness deadlocks, auth gates, data integrity).
2. Resolve all P1 major issues (contrast failures, touch target violations <48dp, keyboard focus).
3. Apply in one single atomic change batch.

# Round 2: Confirmation & Recapture
1. Recapture only affected / modified surfaces to confirm resolution.
2. Re-score updated dimensions.
3. Verify all automated gates (format, analyze, test, contract guards).
4. Publish final audit report with definitive Go / No-Go recommendation.
5. STOP: Await explicit human owner approval before merging or marking STEP-55 Done.
```

#### Scoring Rubric Matrix

**Web Audit Rubric (0–20)**:
| # | Dimension | Score (0–4) | Evaluation Criteria |
|---|-----------|-------------|---------------------|
| 1 | Accessibility | 0–4 | WCAG AA 4.5:1 text contrast, 3:1 focus indicators, `flt-semantics` tree completeness, keyboard trap/tab order, form error announcements |
| 2 | Performance | 0–4 | Frame stability on scroll, avoidance of layout thrashing, fast asset rendering, clean widget disposal |
| 3 | Theming | 0–4 | Strict adherence to `FThemes.zinc` / `FThemes.zinc.dark`, token usage, live brightness toggle support |
| 4 | Responsive Design | 0–4 | Exact 800dp boundary switch (799 vs 800 vs 801), right-sheet geometry (480–600dp), interactive targets >=48x48dp |
| 5 | Implementation Integrity | 0–4 | Clean Architecture & ForUI compliance, zero transient `extra` routing dependencies, D1–D7 adherence |

**Android Audit Rubric (0–20)**:
| # | Dimension | Score (0–4) | Evaluation Criteria |
|---|-----------|-------------|---------------------|
| 1 | Accessibility | 0–4 | TalkBack label presence, focus order traversal, 2.0x Dynamic Type/sp text scaling without clipping, >=48x48dp targets |
| 2 | Performance | 0–4 | Startup latency to first frame, list recycling efficiency, 60fps gesture handling |
| 3 | Appearance & Theming | 0–4 | Semantic Zinc palette fidelity, dark appearance contrast, native elevated surfaces |
| 4 | Platform Conformance | 0–4 | Predictive/system Back gesture integration, safe-area inset preservation, keyboard/IME avoidance, 5 bottom tabs |
| 5 | Adaptivity | 0–4 | Locked portrait phone fidelity, bottom-sheet drag-to-dismiss behavior, orientation lock adherence |

---

### 6.3 Test Runner & Execution Scripts

#### Secure Staging Invocation Pattern (`bash`)

```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Parse .env without echoing secrets
declare -A ENVV
while IFS='=' read -r k v; do
  [[ -z "$k" || "$k" =~ ^[[:space:]]*# ]] && continue
  k="${k%"${k##*[![:space:]]}"}"; k="${k#"${k%%[![:space:]]*}"}"
  [[ -z "$k" ]] && continue
  ENVV["$k"]="$v"
done < .env

DEF=(
  --dart-define=SUPABASE_URL="${ENVV[SUPABASE_URL]:-}"
  --dart-define=SUPABASE_ANON_KEY="${ENVV[SUPABASE_ANON_KEY]:-}"
  --dart-define=APP_ENV="${ENVV[APP_ENV]:-staging}"
  --dart-define=TEST_USER_EMAIL="${ENVV[TEST_USER_EMAIL]:-}"
  --dart-define=TEST_USER_PASSWORD="${ENVV[TEST_USER_PASSWORD]:-}"
  --dart-define=TEST_SUPERVISOR_EMAIL="${ENVV[TEST_SUPERVISOR_EMAIL]:-}"
  --dart-define=TEST_SUPERVISOR_PASSWORD="${ENVV[TEST_SUPERVISOR_PASSWORD]:-}"
  --dart-define=TEST_FOREMAN_EMAIL="${ENVV[TEST_FOREMAN_EMAIL]:-}"
  --dart-define=TEST_FOREMAN_PASSWORD="${ENVV[TEST_FOREMAN_PASSWORD]:-}"
  --dart-define=TEST_CREW_EMAIL="${ENVV[TEST_CREW_EMAIL]:-}"
  --dart-define=TEST_CREW_PASSWORD="${ENVV[TEST_CREW_PASSWORD]:-}"
  --dart-define=GOOGLE_DRIVE_CLIENT_ID="${ENVV[GOOGLE_DRIVE_CLIENT_ID]:-}"
  --dart-define=GOOGLE_DRIVE_SERVICE_ACCOUNT_EMAIL="${ENVV[GOOGLE_DRIVE_SERVICE_ACCOUNT_EMAIL]:-}"
  --dart-define=GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY="${ENVV[GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY]:-}"
  --dart-define=GOOGLE_DRIVE_FOLDER_ID="${ENVV[GOOGLE_DRIVE_FOLDER_ID]:-}"
)

# 2. Web Capture Execution (ChromeDriver must be running on 4444)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/design_review_capture_test.dart \
  -d web-server \
  --browser-name=chrome \
  "${DEF[@]}"

# 3. Android Capture Execution (Pixel_6a emulator on emulator-5554)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/design_review_capture_test.dart \
  -d emulator-5554 \
  "${DEF[@]}"
```

---

## 7. Verification Method

To independently verify the authoritative findings of this report:

1. **Verify Target Isolation & Historical Guard:**
   Inspect `Code/mine-flow-app/test_driver/integration_test.dart`:
   - Line 55 confirms default path: `../mine-flow-docs/reports/design-review/step-0055`.
   - Lines 8–15 and 73–84 confirm protected step assertions (`step-0048`, `step-0045`, etc.).
   - Lines 18–50 confirm 8-byte PNG header check and 68-byte placeholder rejection.

2. **Verify Breakpoint & Route Inventory:**
   - Inspect `Code/mine-flow-docs/architecture/07-ui-design-system.md` §4 (800dp wide/narrow split).
   - Inspect `Code/mine-flow-docs/reports/2026-09-11-step-54-master-polish-spec.md` §2.6 (canonical route table) and §7.1 (required runtime matrix).

3. **Verify Impeccable Scoring Rubric:**
   - Inspect `d:/AppDev/mine_flow/.agent/skills/impeccable/reference/audit.md` (Web 0–20 rubric).
   - Inspect `d:/AppDev/mine_flow/.agent/skills/impeccable/reference/audit.native.md` (Android 0–20 rubric).

4. **Verify Credential Redaction:**
   - Run: `flutter test test/core/utils/logger_test.dart`
   - Inspect `lib/core/utils/logger.dart` lines 31–45.
