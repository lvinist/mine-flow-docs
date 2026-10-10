# Forensic Audit Report — Milestone 1: E2E Harness Hardening & Dual-Platform Verification

**Auditor:** `m1_auditor_1`  
**Role:** Forensic Integrity Auditor  
**Working Directory:** `d:\AppDev\mine_flow\.agents\m1_auditor_1`  
**Parent Conversation ID:** `59bcb54d-8151-4a70-b05f-f44eef45d09c`  
**Target:** Milestone 1 Changes  
**Integrity Mode:** Benchmark Mode (Maximum Strictness)  
**Verdict:** **CLEAN**  

---

## 1. Observation

### 1.1 Scope & Modified Files Inspected
Direct inspection via `git status -s` in `Code/mine-flow-app` confirmed exactly three modified files:
- `Code/mine-flow-app/test_driver/integration_test.dart`
- `Code/mine-flow-app/integration_test/design_review_capture_test.dart`
- `Code/mine-flow-app/integration_test/journeys/attendance_journey_test.dart`

### 1.2 Verbatim Git Diff Examination

#### File 1: `test_driver/integration_test.dart`
```diff
diff --git a/test_driver/integration_test.dart b/test_driver/integration_test.dart
index ce835cc..cc9205c 100644
--- a/test_driver/integration_test.dart
+++ b/test_driver/integration_test.dart
@@ -1,17 +1,123 @@
 import 'dart:io';
 import 'package:integration_test/integration_test_driver_extended.dart';
 
+/// PNG specification 8-byte magic signature.
+const List<int> _pngMagic = [137, 80, 78, 71, 13, 10, 26, 10];
+
+/// Historical step directories whose committed artifacts must never be clobbered.
+const List<String> _protectedHistoricalSteps = [
+  'step-0048',
+  'step-0045',
+  'step-0046',
+  'step-0047',
+  'step-0050',
+  'step-0054',
+];
+
+/// Validates that incoming screenshot bytes represent real, non-placeholder PNG image data.
+bool _validateScreenshotBytes(String name, List<int> bytes) {
+  if (bytes.isEmpty) {
+    stderr.writeln('[driver] ERROR: Screenshot "$name" received 0 bytes.');
+    return false;
+  }
+
+  if (bytes.length < 8) {
+    stderr.writeln(
+      '[driver] ERROR: Screenshot "$name" length (${bytes.length}) is shorter than PNG header.',
+    );
+    return false;
+  }
+
+  for (var i = 0; i < 8; i++) {
+    if (bytes[i] != _pngMagic[i]) {
+      stderr.writeln(
+        '[driver] ERROR: Screenshot "$name" lacks valid PNG signature header.',
+      );
+      return false;
+    }
+  }
+
+  // Reject known 68-byte 1x1 placeholder artifacts (STEP-48 / RISK-0023 / RISK-0024).
+  if (bytes.length == 68) {
+    stderr.writeln(
+      '[driver] ERROR: Screenshot "$name" is exactly 68 bytes (known 1x1 placeholder). '
+      'Synthetic placeholder artifacts are forbidden by PROJECT.md.',
+    );
+    return false;
+  }
+
+  return true;
+}
+
+/// Resolves screenshot destination directory in priority order:
+/// 1. `args['destinationDirectory']` or `args['destination_dir']`
+/// 2. `SCREENSHOT_DESTINATION_DIR` or `SCREENSHOT_DIR` environment variables
+/// 3. Default: `../mine-flow-docs/reports/design-review/step-0055`
+String _resolveDestinationDirectory(Map<String, Object?>? args) {
+  final argDir =
+      (args?['destinationDirectory'] ?? args?['destination_dir']) as String?;
+  if (argDir != null && argDir.trim().isNotEmpty) {
+    return argDir.trim();
+  }
+
+  final envDir =
+      Platform.environment['SCREENSHOT_DESTINATION_DIR'] ??
+      Platform.environment['SCREENSHOT_DIR'];
+  if (envDir != null && envDir.trim().isNotEmpty) {
+    return envDir.trim();
+  }
+
+  return '../mine-flow-docs/reports/design-review/step-0055';
+}
+
+/// Throws a [StateError] if the destination path points to a protected historical release directory.
+void _assertSafeDestination(String dir) {
+  final normalized = dir.replaceAll('\\', '/').toLowerCase();
+  for (final step in _protectedHistoricalSteps) {
+    if (normalized.contains(step)) {
+      throw StateError(
+        'Hazard prevented: destination directory "$dir" targets historical release '
+        'directory "$step". Overwriting prior step design review artifacts is prohibited.',
+      );
+    }
+  }
+}
+
+/// Saves screenshot bytes safely to disk and logs output.
+Future<bool> _handleScreenshot(
+  String screenshotName,
+  List<int> screenshotBytes, [
+  Map<String, Object?>? args,
+]) async {
+  if (!_validateScreenshotBytes(screenshotName, screenshotBytes)) {
+    return false;
+  }
+
+  final destDir = _resolveDestinationDirectory(args);
+  _assertSafeDestination(destDir);
+
+  final cleanDir = destDir.endsWith('/') || destDir.endsWith('\\')
+      ? destDir.substring(0, destDir.length - 1)
+      : destDir;
+  final cleanName = screenshotName.endsWith('.png')
+      ? screenshotName
+      : '$screenshotName.png';
+  final file = File('$cleanDir/$cleanName');
+
+  await file.parent.create(recursive: true);
+  await file.writeAsBytes(screenshotBytes, flush: true);
+
+  stdout.writeln(
+    '[driver] Saved screenshot: ${file.path} (${screenshotBytes.length} bytes)',
+  );
+  return true;
+}
+
 Future<void> main() => integrationDriver(
   onScreenshot:
       (
         String screenshotName,
         List<int> screenshotBytes, [
         Map<String, Object?>? args,
-      ]) async {
-        final File image = await File(
-          '../mine-flow-docs/reports/design-review/step-0048/$screenshotName.png',
-        ).create(recursive: true);
-        image.writeAsBytesSync(screenshotBytes);
-        return true;
-      },
+      ]) => _handleScreenshot(screenshotName, screenshotBytes, args),
 );
```

#### File 2: `integration_test/design_review_capture_test.dart`
```diff
diff --git a/integration_test/design_review_capture_test.dart b/integration_test/design_review_capture_test.dart
index 0c2cd12..70884e6 100644
--- a/integration_test/design_review_capture_test.dart
+++ b/integration_test/design_review_capture_test.dart
@@ -38,24 +38,27 @@ import 'helpers/login_helper.dart';
 Future<bool> _captureScreenshot(
   WidgetTester tester,
   IntegrationTestWidgetsFlutterBinding binding,
-  String name,
-) async {
+  String name, {
+  Duration timeout = const Duration(seconds: 5),
+}) async {
   try {
     final future = binding.takeScreenshot(name);
     // On Android, takeScreenshot asks the engine to schedule a frame, but inside
     // testWidgets the test framework does not render scheduled frames unless pump()
     // is called. We pump frames in short intervals until the screenshot completes
     // or a safety timeout expires.
-    final deadline = DateTime.now().add(const Duration(seconds: 1));
+    final deadline = DateTime.now().add(timeout);
     while (DateTime.now().isBefore(deadline)) {
       final done = await Future.any([
         future.then((_) => true),
-        Future.delayed(const Duration(milliseconds: 50), () => false),
+        Future.delayed(const Duration(milliseconds: 100), () => false),
       ]);
       if (done) return true;
-      await tester.pump(const Duration(milliseconds: 50));
+      await tester.pump(const Duration(milliseconds: 100));
     }
-    debugPrint('Warning: takeScreenshot($name) timed out after 1s');
+    debugPrint(
+      'Warning: takeScreenshot($name) timed out after ${timeout.inSeconds}s',
+    );
     return false;
   } catch (e) {
     debugPrint('Warning: takeScreenshot($name) failed: $e');
@@ -87,6 +90,8 @@ void main() {
       await binding.convertFlutterSurfaceToImage();
     }
 
+    final captured = <String>[];
+
     // Initial Login Screen check for RISK-0011 (Privacy/Terms notice) and RISK-0015 (Light Mode Theme)
     await tester.pumpAndSettle();
 
@@ -101,11 +106,15 @@ void main() {
     tester.view.physicalSize = const Size(400, 800);
     tester.view.devicePixelRatio = 1.0;
     await tester.pumpAndSettle();
-    await _captureScreenshot(
+    const loginScreenshotName = '${platformPrefix}login-phone-light-en';
+    final loginCapturedOk = await _captureScreenshot(
       tester,
       binding,
-      '${platformPrefix}login-phone-light-en',
+      loginScreenshotName,
     );
+    if (loginCapturedOk) {
+      captured.add(loginScreenshotName);
+    }
 
     // Reset view before logging in so the login screen renders at native surface dimensions
     tester.view.resetPhysicalSize();
@@ -147,8 +156,6 @@ void main() {
       (name: 'tools', route: '/tools'),
     ];
 
-    final captured = <String>[];
-
     for (final bp in breakpoints) {
       tester.view.physicalSize = bp.size;
       tester.view.devicePixelRatio = 1.0;
@@ -188,27 +195,31 @@ void main() {
     // A capture run that reports green while writing nothing is the vacuous pass
     // this STEP exists to eliminate: assert the expected count and print the
     // names so the job log carries the evidence.
-    final expected =
-        breakpoints.length * themes.length * locales.length * screens.length;
-    if (kIsWeb) {
-      expect(
-        captured.length,
-        expected,
-        reason: 'every matrix cell must produce a screenshot on web',
-      );
-    } else {
-      // On Android, headless emulator or testWidgets environment bounds captures so
-      // the suite cannot wedge the CI gate (STEP-48.22 A-1 requirement).
-      expect(
-        captured.isNotEmpty,
-        isTrue,
-        reason:
-            'capture matrix must execute and produce screenshots without wedging the gate',
-      );
-    }
+    final expectedNames = <String>[
+      '${platformPrefix}login-phone-light-en',
+      for (final bp in breakpoints)
+        for (final th in themes)
+          for (final loc in locales)
+            for (final screen in screens)
+              '$platformPrefix${screen.name}-${bp.name}-${th.name}-${loc.name}',
+    ];
+
+    final missing = expectedNames.toSet().difference(captured.toSet());
+    expect(
+      missing,
+      isEmpty,
+      reason:
+          'All ${expectedNames.length} matrix cells must produce valid screenshots on $platformPrefix (missing: ${missing.join(', ')})',
+    );
+    expect(
+      captured.length,
+      expectedNames.length,
+      reason:
+          'Captured count (${captured.length}) must match expected (${expectedNames.length})',
+    );
     debugPrint(
-      'design-review captures (${captured.length}/$expected): '
+      'design-review captures (${captured.length}/${expectedNames.length}): '
       '${captured.join(', ')}',
     );
-  }, timeout: const Timeout(Duration(minutes: 5)));
+  }, timeout: const Timeout(Duration(minutes: 15)));
 }
```

#### File 3: `integration_test/journeys/attendance_journey_test.dart`
```diff
diff --git a/integration_test/journeys/attendance_journey_test.dart b/integration_test/journeys/attendance_journey_test.dart
index 65e7bb2..694fd7d 100644
--- a/integration_test/journeys/attendance_journey_test.dart
+++ b/integration_test/journeys/attendance_journey_test.dart
@@ -126,7 +126,7 @@ void main() {
         // find.text('Sakit').first can hit another card's chip.
         final sakitChoice = find.descendant(
           of: targetCardFinder,
-          matching: find.bySemanticsLabel('Status: Sakit'),
+          matching: find.text('Sakit'),
         );
         expect(sakitChoice, findsOneWidget);
         await tester.tap(sakitChoice.first);
@@ -275,7 +275,7 @@ void main() {
 
         final izinChoice = find.descendant(
           of: formTargetCard,
-          matching: find.bySemanticsLabel('Status: Izin'),
+          matching: find.text('Izin'),
         );
         expect(izinChoice, findsOneWidget);
         await tester.tap(izinChoice.first);
```

### 1.3 Forensic Check Results & Empirical Command Outputs

1. **Dart Format Gate**:
   - Command: `dart format --output=none --set-exit-if-changed .`
   - Exit code: `0`
   - Output: `Formatted 360 files (0 changed) in 2.23 seconds.`
2. **Flutter Static Analysis Gate**:
   - Command: `flutter analyze`
   - Exit code: `0`
   - Output: `Analyzing mine-flow-app... No issues found! (ran in 69.5s)`
3. **Localization Baseline Guard**:
   - Command: `dart run tool/check_l10n_baseline.dart`
   - Exit code: `0`
   - Output:
     ```
     Localization Baseline Guard
     ---------------------------
     Files scanned (non-exempt): 22
     Files exempt (legacy):      47
     [OK] No new hardcoded strings detected in non-exempt files.
     ```
4. **Supabase Contracts Guard**:
   - Command: `dart run tool/check_supabase_contracts.dart`
   - Exit code: `0`
   - Output:
     ```
     Supabase Contract Check
     -----------------------
     Contract artifact: supabase/types/database.ts
     [OK] Contract verification passed.
     ```
5. **Tool Test Suite (Serial Run)**:
   - Command: `flutter test -j 1 test/tool`
   - Exit code: `0`
   - Output: `00:50 +40 ~5: All tests passed!`
6. **Adversarial Driver Verification Suite**:
   - Command: `dart run tool/verify_test_driver_adversarial.dart`
   - Exit code: `0`
   - Output: `VERIFICATION SUMMARY: 63 passed, 0 failed` (verifying anti-clobber, magic PNG byte validation, 68-byte placeholder rejection, fallback priority, and flushed disk writes).

---

## 2. Logic Chain

1. **Test Driver Retargeting & Anti-Clobber Integrity**:
   - *Observation 1.2 (File 1)* shows that the destination directory in `test_driver/integration_test.dart` default points to `../mine-flow-docs/reports/design-review/step-0055`, fulfilling Feature 1 and Milestone 1 objectives.
   - The anti-clobber guard `_assertSafeDestination` explicitly throws a `StateError` if any target path contains historical steps (`step-0048`, `step-0045`, `step-0046`, `step-0047`, `step-0050`, `step-0054`).
   - The screenshot validator `_validateScreenshotBytes` verifies the 8-byte PNG magic header `[137, 80, 78, 71, 13, 10, 26, 10]`, rejects files smaller than 8 bytes, and explicitly blocks known 68-byte 1x1 synthetic placeholders (satisfying PROJECT.md R2 anti-synthetic rule).
   - Real disk writes occur via `await file.writeAsBytes(screenshotBytes, flush: true)`. There is no fake stub, dummy return, or bypassed I/O.

2. **Capture Harness Assertion Strengthening**:
   - *Observation 1.2 (File 2)* shows that in `design_review_capture_test.dart`, the assertion on Android previously used `expect(captured.isNotEmpty, isTrue)`. This was a known weak assertion where capturing 1 of 24 screenshots produced a false-positive pass.
   - The new implementation computes `expectedNames` symmetrically for both platforms, captures the initial login screenshot into `captured`, and enforces:
     - `expect(missing, isEmpty)`
     - `expect(captured.length, expectedNames.length)`
   - Timeout was increased from 1s to 5s per frame pump to prevent false timeouts on emulators, and test timeout was expanded to 15m.
   - The change **strengthens** test rigor and closes a bypass loop; it does not delete or weaken any tests.

3. **Attendance Journey Finder Correctness**:
   - *Observation 1.2 (File 3)* shows updating the matcher from `find.bySemanticsLabel('Status: Sakit')` to `find.text('Sakit')` and `find.text('Izin')` scoped to the card.
   - Inspection of `lib/features/attendance/presentation/widgets/attendance_crew_card.dart:182` revealed that the semantics label rendered on the button was `l10n.attendanceStatusChooseLabel(label)` (`"Pilih status Sakit untuk kru ini"`), making `find.bySemanticsLabel('Status: Sakit')` an impossible match.
   - Matching `find.text('Sakit')` inside `targetCardFinder` accurately finds the actual button on screen and triggers genuine onTap interactions. The test logic and assertions were not mocked or bypassed.

4. **Zero Secrets, Credentials, or PII**:
   - Audited the git diff across all 3 files line by line.
   - No hardcoded API keys, Supabase service roles, bearer tokens, passwords, or personally identifiable information were added.
   - All test strings are standard synthetic labels (e.g. `'Izin sakit shift pagi ...'`).

5. **Mode-Specific Benchmark Evaluation**:
   - Under Benchmark Mode (maximum strictness), zero external code delegation or framework bypasses were detected.
   - Standard Dart/Flutter testing primitives were used throughout.
   - All 5 forensic prohibited patterns (hardcoded test results, facade implementations, fabricated verification outputs, self-certifying tests, execution delegation) are absent.

---

## 3. Caveats

1. **Path Traversal in Test Driver Parameter**:
   - An adversarial stress test revealed that while `_assertSafeDestination(destDir)` validates `destDir`, passing a crafted relative traversal in `screenshotName` (e.g., `../step-0048/exploit`) could theoretically bypass destination path validation. However, in actual test harnesses, `screenshotName` is strictly an internal constant string constructed by the test file (e.g., `android-daily-log-phone-light-en`), not external user input.
2. **Subprocess Test Concurrency (`test/tool`)**:
   - `test/tool/check_supabase_contracts_test.dart` manipulates git index staging and temporary files on disk. When `flutter test` runs all suites concurrently across parallel isolate workers, temporary file conflicts can occur. Running `flutter test -j 1 test/tool` runs with 100% pass (+40 ~5).
3. **Staging Credential Absences in CI**:
   - As documented in the test architecture, E2E journey tests gracefully report `e2e_skipped: staging credentials absent` when live Supabase `--dart-define` credentials are not injected. This is honest runtime behavior, not an integrity bypass.

---

## 4. Conclusion

- The changes made for Milestone 1 are authentic, robust, and adhere strictly to all project constraints.
- No tests were deleted, disabled, or mocked out.
- Test assertions were strengthened (closing the Android capture loophole).
- No secrets, tokens, or PII were introduced.
- All static, format, analyze, and contract guards pass cleanly.

**Final Forensic Verdict**: **CLEAN**

---

## 5. Verification Method

To independently reproduce and verify this audit:

1. **Verify Static Code & Analysis**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   dart run tool/check_l10n_baseline.dart
   dart run tool/check_supabase_contracts.dart
   ```
   *Expected*: All commands exit with `0`.

2. **Verify Adversarial Stress Harness**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   dart run tool/verify_test_driver_adversarial.dart
   ```
   *Expected*: Exits `0`, reports `VERIFICATION SUMMARY: 63 passed, 0 failed`.

3. **Verify Tool Test Suite**:
   ```powershell
   cd d:\AppDev\mine_flow\Code\mine-flow-app
   flutter test -j 1 test/tool
   ```
   *Expected*: Exits `0`, all 40 tests pass.

4. **Invalidation Conditions**:
   - Introducing any write targeting `step-0048` invalidates the driver fix.
   - Any reintroduction of `captured.isNotEmpty` invalidates the capture harness fix.
   - Any failure of `flutter analyze` or contract guards invalidates verification.
