# Handoff Report: Test Driver Path Hazard Investigation & Hardening

**Agent**: `m1_explorer_1`  
**Working Directory**: `d:\AppDev\mine_flow\.agents\m1_explorer_1`  
**Parent Conversation ID**: `59bcb54d-8151-4a70-b05f-f44eef45d09c`  
**Milestone**: Milestone 1: E2E Harness Hardening & Dual-Platform Verification — Focus on Test Driver Path Hazard  
**Date**: 2026-09-16T17:07:30+07:00  

---

## 1. Observation

### 1.1 Sole Test Driver in Repository
A filesystem search across `d:\AppDev\mine_flow` for test driver files confirms that `Code/mine-flow-app/test_driver/integration_test.dart` is the only test driver Dart file in the repository.

Current file contents of `Code/mine-flow-app/test_driver/integration_test.dart` (lines 1–18):
```dart
1: import 'dart:io';
2: import 'package:integration_test/integration_test_driver_extended.dart';
3: 
4: Future<void> main() => integrationDriver(
5:   onScreenshot:
6:       (
7:         String screenshotName,
8:         List<int> screenshotBytes, [
9:         Map<String, Object?>? args,
10:       ]) async {
11:         final File image = await File(
12:           '../mine-flow-docs/reports/design-review/step-0048/$screenshotName.png',
13:         ).create(recursive: true);
14:         image.writeAsBytesSync(screenshotBytes);
15:         return true;
16:       },
17: );
```

### 1.2 The Hardcoded Path Defect & Past Clobber Incident
Line 12 hardcodes the screenshot output path to:
`'../mine-flow-docs/reports/design-review/step-0048/$screenshotName.png'`

In `Upcoming Prompts/mine-flow-STEP-55.11-FINDINGS.md` (lines 196–212):
> "### Side effect discovered and repaired: STEP-0048 screenshot clobber
> `test_driver/integration_test.dart` hardcodes its screenshot destination as `../mine-flow-docs/reports/design-review/step-0048/$name.png` — a **tracked** directory belonging to an older STEP. Running the web capture on 2026-09-15 therefore overwrote **22 committed 68-byte placeholder PNGs** in STEP-0048 with real pre-fix captures (1578x870, 23-75 KB each), all stamped 13:32-13:34. That is another STEP's artifact set, and the captures were taken **before** this session's fix, so they are not valid 55.11 evidence either.
> Repaired: the 22 files were copied aside to `Upcoming Prompts/.step55.11c-step0048-clobber/` (preserved, not deleted) and `git checkout -- reports/design-review/step-0048/` restored the directory to its committed state... **Owner decision:** retarget the driver to a per-STEP output directory (e.g. `reports/design-review/step-0055/`) before the next capture run."

Inspection of `d:\AppDev\mine_flow\Upcoming Prompts\.step55.11c-step0048-clobber/` confirms 22 salvaged PNG files (23 KB to 75 KB each).
Inspection of `Code/mine-flow-docs/reports/design-review/step-0048/` confirms 73 committed 68-byte placeholder PNG files.
Inspection of `Code/mine-flow-docs/reports/design-review/step-0055/` confirms 1 committed PNG file (`2026-09-14-web-login-1258x566.png`).

### 1.3 Driver Usage in CI and Harness
1. In `Code/mine-flow-app/.github/workflows/ci.yml` (lines 179–183), web E2E invokes:
   ```bash
   flutter drive \
     --driver=test_driver/integration_test.dart \
     --target="$wrapper" \
     -d web-server \
     --browser-name=chrome \
     ...
   ```
2. In `Code/mine-flow-app/tool/ci/check_e2e_executed.dart` (lines 45–67), the CI execution guard verifies test execution by parsing the `result {"result":"true|false", ...}` marker line printed by `package:integration_test/integration_test_driver_extended.dart` line 133 (`print('result $jsonResponse');`).
3. In Flutter SDK `packages/integration_test/lib/common.dart` (lines 30–33):
   > "Since the function is executed on the host driving the test, you can access any environment variable from it."
   > `typedef ScreenshotCallback = Future<bool> Function(String name, List<int> image, [Map<String, Object?>? args]);`
4. In `Code/mine-flow-app/integration_test/design_review_capture_test.dart` (lines 38–64, 104–108, 175–178), screenshots are captured via `binding.takeScreenshot(name)`.

---

## 2. Logic Chain

1. **Root Cause of Hazard**:
   - `test_driver/integration_test.dart` has a fixed, hardcoded relative path string `'../mine-flow-docs/reports/design-review/step-0048/$screenshotName.png'`.
   - When tests calling `takeScreenshot` (such as `design_review_capture_test.dart`) run under `flutter drive`, the driver writes directly into `step-0048/`.
   - Because `step-0048` is a committed, historical release directory, any execution unconditionally clobbers historical artifacts.

2. **Insufficiency of Naive Hardcoding (`step-0055`)**:
   - If line 12 is merely replaced with `'../mine-flow-docs/reports/design-review/step-0055/$screenshotName.png'`, the immediate issue for STEP-55 is solved, but the architectural flaw remains: subsequent steps (STEP-56, STEP-60, etc.) or local experimental runs will silently clobber STEP-55's committed evidence.
   - Therefore, the destination path must be configurable via:
     - (a) Runtime arguments passed to `onScreenshot` (`args`),
     - (b) Environment variables (`SCREENSHOT_DESTINATION_DIR` or `SCREENSHOT_DIR`),
     - (c) Sensible default targeting `../mine-flow-docs/reports/design-review/step-0055`.

3. **Clobber Prevention Mechanism**:
   - The driver must contain an explicit safeguard that rejects writes if the resolved destination targets any protected historical release directory (`step-0048`, `step-0045`, `step-0046`, `step-0047`, `step-0050`, `step-0054`).
   - If an operator or CI config accidentally sets `SCREENSHOT_DESTINATION_DIR` to a protected historical directory, the driver must throw an immediate `StateError` before any file creation occurs.

4. **Screenshot Byte Handling & Synthetic Placeholder Prevention**:
   - Currently, `image.writeAsBytesSync(screenshotBytes)` performs no validation on incoming bytes.
   - If `screenshotBytes` is empty (0 bytes) or truncated (< 8 bytes, lacking PNG header `[137, 80, 78, 71, 13, 10, 26, 10]`), the driver should reject it and return `false`, preventing corrupted artifacts from being recorded as successful tests.
   - Furthermore, `PROJECT.md` line 50 explicitly mandates: `"No synthetic placeholders or 1x1 images allowed."` The known 1x1 placeholder PNGs from STEP-48 are exactly 68 bytes. A specific validation rule should reject 68-byte placeholder PNGs.
   - The byte write should use `await image.writeAsBytes(screenshotBytes, flush: true)` to ensure that OS buffers are flushed to disk before the driver completes the WebDriver command.
   - Every screenshot write should log metadata to stdout (`[driver] Saved screenshot: <path> (<bytes> bytes)`), satisfying the auditability requirement in `PROJECT.md`.

5. **Zero External Dependency Constraint**:
   - `Code/mine-flow-app/pubspec.yaml` does not declare `path` as a direct dependency. Using `dart:io` and standard string normalization avoids introducing any new dependencies or causing `flutter analyze` warnings.

---

## 3. Caveats

1. **Android Direct `flutter test` Execution**:
   - When running on Android via `flutter test integration_test/ -d <device>` (as in `ci.yml:291` without `flutter drive`), `test_driver/integration_test.dart` is not invoked. In that mode, `takeScreenshot` collects bytes inside `IntegrationTestWidgetsFlutterBinding`. Driver hardening affects `flutter drive` executions (Web E2E and driver-driven mobile runs).
2. **Pre-existing Class-A / Class-B Journey Test Regressions**:
   - Retargeting and hardening `test_driver/integration_test.dart` addresses the path hazard and screenshot writing mechanism (Feature 1 / Milestone 1). It does not alter test assertions in journey tests that may be failing due to ForUI widget migrations (documented in `STEP-55.11-FINDINGS.md`).
3. **Protected Directory List**:
   - The protected step list (`step-0048`, `step-0045`, `step-0046`, `step-0047`, `step-0050`, `step-0054`) is explicit. When future steps (e.g. STEP-56) complete, `step-0055` should be added to the protected list.

---

## 4. Conclusion & Recommended Implementation

The test driver `Code/mine-flow-app/test_driver/integration_test.dart` must be replaced with a hardened implementation that:
1. Defaults to `../mine-flow-docs/reports/design-review/step-0055`.
2. Supports overrides via `args['destinationDirectory']` / `args['destination_dir']` and environment variables `SCREENSHOT_DESTINATION_DIR` / `SCREENSHOT_DIR`.
3. Actively blocks writing to historical release directories (`step-0048`, etc.).
4. Validates PNG signature header and rejects 0-byte and 68-byte placeholder files.
5. Performs flushed asynchronous disk writes and logs artifact metadata to stdout.

### Exact Recommended Replacement Code for Worker

Target file: `Code/mine-flow-app/test_driver/integration_test.dart`

```dart
import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// PNG specification 8-byte magic signature.
const List<int> _pngMagic = [137, 80, 78, 71, 13, 10, 26, 10];

/// Historical step directories whose committed artifacts must never be clobbered.
const List<String> _protectedHistoricalSteps = [
  'step-0048',
  'step-0045',
  'step-0046',
  'step-0047',
  'step-0050',
  'step-0054',
];

/// Validates that incoming screenshot bytes represent real, non-placeholder PNG image data.
bool _validateScreenshotBytes(String name, List<int> bytes) {
  if (bytes.isEmpty) {
    stderr.writeln('[driver] ERROR: Screenshot "$name" received 0 bytes.');
    return false;
  }

  if (bytes.length < 8) {
    stderr.writeln(
      '[driver] ERROR: Screenshot "$name" length (${bytes.length}) is shorter than PNG header.',
    );
    return false;
  }

  for (var i = 0; i < 8; i++) {
    if (bytes[i] != _pngMagic[i]) {
      stderr.writeln(
        '[driver] ERROR: Screenshot "$name" lacks valid PNG signature header.',
      );
      return false;
    }
  }

  // Reject known 68-byte 1x1 placeholder artifacts (STEP-48 / RISK-0023 / RISK-0024).
  if (bytes.length == 68) {
    stderr.writeln(
      '[driver] ERROR: Screenshot "$name" is exactly 68 bytes (known 1x1 placeholder). '
      'Synthetic placeholder artifacts are forbidden by PROJECT.md.',
    );
    return false;
  }

  return true;
}

/// Resolves screenshot destination directory in priority order:
/// 1. `args['destinationDirectory']` or `args['destination_dir']`
/// 2. `SCREENSHOT_DESTINATION_DIR` or `SCREENSHOT_DIR` environment variables
/// 3. Default: `../mine-flow-docs/reports/design-review/step-0055`
String _resolveDestinationDirectory(Map<String, Object?>? args) {
  final argDir = (args?['destinationDirectory'] ?? args?['destination_dir']) as String?;
  if (argDir != null && argDir.trim().isNotEmpty) {
    return argDir.trim();
  }

  final envDir = Platform.environment['SCREENSHOT_DESTINATION_DIR'] ??
      Platform.environment['SCREENSHOT_DIR'];
  if (envDir != null && envDir.trim().isNotEmpty) {
    return envDir.trim();
  }

  return '../mine-flow-docs/reports/design-review/step-0055';
}

/// Throws a [StateError] if the destination path points to a protected historical release directory.
void _assertSafeDestination(String dir) {
  final normalized = dir.replaceAll('\\', '/').toLowerCase();
  for (final step in _protectedHistoricalSteps) {
    if (normalized.contains(step)) {
      throw StateError(
        'Hazard prevented: destination directory "$dir" targets historical release '
        'directory "$step". Overwriting prior step design review artifacts is prohibited.',
      );
    }
  }
}

/// Saves screenshot bytes safely to disk and logs output.
Future<bool> _handleScreenshot(
  String screenshotName,
  List<int> screenshotBytes, [
  Map<String, Object?>? args,
]) async {
  if (!_validateScreenshotBytes(screenshotName, screenshotBytes)) {
    return false;
  }

  final destDir = _resolveDestinationDirectory(args);
  _assertSafeDestination(destDir);

  final cleanDir = destDir.endsWith('/') || destDir.endsWith('\\')
      ? destDir.substring(0, destDir.length - 1)
      : destDir;
  final cleanName = screenshotName.endsWith('.png') ? screenshotName : '$screenshotName.png';
  final file = File('$cleanDir/$cleanName');

  await file.parent.create(recursive: true);
  await file.writeAsBytes(screenshotBytes, flush: true);

  stdout.writeln(
    '[driver] Saved screenshot: ${file.path} (${screenshotBytes.length} bytes)',
  );
  return true;
}

Future<void> main() => integrationDriver(
  onScreenshot: (
    String screenshotName,
    List<int> screenshotBytes, [
    Map<String, Object?>? args,
  ]) => _handleScreenshot(screenshotName, screenshotBytes, args),
);
```

---

## 5. Verification Method

To independently verify the fix:

1. **Static Analysis**:
   ```bash
   cd Code/mine-flow-app
   flutter analyze test_driver/integration_test.dart
   ```
   Must produce `No issues found!`.

2. **Code Formatting Check**:
   ```bash
   cd Code/mine-flow-app
   dart format --output=none --set-exit-if-changed test_driver/integration_test.dart
   ```
   Must exit 0.

3. **Clobber Prevention Test**:
   - Set environment variable `SCREENSHOT_DESTINATION_DIR="../mine-flow-docs/reports/design-review/step-0048"`.
   - Run a test with `flutter drive`.
   - Verify that the driver throws `StateError` with `Hazard prevented: destination directory ... targets historical release directory "step-0048"`.
   - Verify `git status Code/mine-flow-docs/reports/design-review/step-0048` remains completely clean (0 modified files).

4. **Default Destination Test**:
   - Run without setting `SCREENSHOT_DESTINATION_DIR`.
   - Verify that captured screenshots are written to `Code/mine-flow-docs/reports/design-review/step-0055/`.
   - Verify driver stdout prints: `[driver] Saved screenshot: ../mine-flow-docs/reports/design-review/step-0055/<name>.png (<bytes> bytes)`.
