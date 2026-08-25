# STEP-43 Upgrade Report — Flutter 3.47 & Dependency Overhaul

**Date:** 2026-08-25
**STEP:** 43 — Flutter 3.47 Upgrade & Dependency Overhaul
**Branch:** `step-0043-flutter-upgrade` (from master @ `9277507`)

> This report anchors the real verification evidence in `mine-flow-docs`.
> The full key-findings narrative lives in the working-files record:
> `prompts/003-release-readiness-integration-scale/step-0043/README.md`.

---

## Context

STEP-43 was created to unblock STEP-42 (now STEP-46 Staging Pipeline), which was
blocked by a broken Android CI build caused by:

- `flutter_bloc ^9.1.1` constraint that pub could not resolve (no such version published)
- Stale Flutter SDK (3.44.x) with known incompatibilities against the package versions
  needed for the rest of the upgrade

The original session archived this STEP as Done with fabricated evidence. It was
re-executed from scratch on a salvaged worktree (see README for details).

---

## What Shipped (4 commits on `step-0043-flutter-upgrade`)

| Commit | Scope |
|--------|-------|
| `c9c8ace` | Toolchain/deps: CI pinned to Flutter 3.47.0 + JDK 17 Temurin both jobs; flutter_bloc ^8.1.6; hive_ce; flutter_secure_storage ^11; file_picker ^11; go_router ^17.3; forui ^0.26.0; fl_chart ^1.2 |
| `cab1d81` | lib/: hive_ce_flutter imports; secure_storage v11 (Keystore at minSdk 23+, no encryptedSharedPreferences); file_picker v11 static API; inventory-entry unit dropdown wrapped in Flutter material-localizations scope (forui 0.26 localizations fix) |
| `1306b4d` | test/: widget finders TextField -> EditableText (forui 0.26 renders field internals via material_ui -- no Material TextField in the tree); harness updates |
| `1fe161a` | build/android: compileSdk 37; gradle wrapper 9.3.1; Windows Kotlin workaround (kotlin.compiler.execution.strategy=in-process, kotlin.incremental=false) |

---

## Key Technical Findings

### 1. Flutter 3.47 Semantics Regression (flutter/flutter#191095)
Flutter 3.47 ships a semantics regression that crashes widget tests using
`isMergedIntoParent` assertions. forui <=0.25 triggers it (FTextField wraps itself
in MergeSemantics). Upstream fix PR #191587 is not yet merged.

**Resolution:** Migrated from forui ^0.24.2 to ^0.26.0 (which dropped the MergeSemantics
wrapper) and wrapped the inventory-entry suffix dropdown in a Flutter
material-localizations scope. Test finders updated from TextField -> EditableText.

Tracked as **RISK-0009** (open).

### 2. win32 Version Conflict (flutter_secure_storage v11 vs file_picker v11)
`flutter_secure_storage ^11.0.0` pulls in `flutter_secure_storage_windows ^4.2.2`
which requires `win32 ^6.0.1`, conflicting with `file_picker ^11.0.3` which uses
`win32 ^5.9.0`. win32 v6 renamed APIs used by file_picker's Windows implementation,
so a raw win32 override breaks test compilation.

**Resolution:** `dependency_overrides: flutter_secure_storage_windows: 4.0.0`
(uses win32 ^5.x, compatible with file_picker). Safe for Android/web target --
Windows FFI code is not executed in production or unit tests.

Tracked as **RISK-0008** (monitoring — skipped v10 key migration; minSdk 23;
win32 override reconciled via `dependency_overrides: flutter_secure_storage_windows: 4.0.0`).

### 3. Windows Kotlin Daemon Crash (CI / local build)
The external Kotlin daemon crashes with "Daemon compilation failed" and corrupts
incremental caches on Windows builds.

**Resolution:** Added to `gradle.properties`:

    kotlin.compiler.execution.strategy=in-process
    kotlin.incremental=false

### 4. hive -> hive_ce Migration
The original `hive` package is abandoned. `hive_ce` is the community-maintained
successor. 26 Dart files migrated (`package:hive/` -> `package:hive_ce/`;
`package:hive_flutter/` -> `package:hive_ce_flutter/`).

Tracked as **RISK-0007** (open — fork continuity).

### 5. fl_chart v2.x Skipped
fl_chart upgraded to ^1.2.0 (v1.x latest), skipping v2.x which was not yet
required and may carry breaking chart API changes.

Tracked as **RISK-0005** (monitoring).

---

## Verification Evidence (Real)

| Gate | Result |
|------|--------|
| `flutter pub get` | exit 0 on regenerated lock against fresh master base |
| `flutter analyze` | 0 errors / 0 warnings (20 pre-existing infos) |
| Guard: `check_supabase_contracts` | pass |
| Guard: `check_l10n_baseline` | pass |
| `flutter test` | **434/434 pass** (re-run during 2026-08-25 housekeeping: all pass; an earlier draft of this report said 435 — the correct total on this tree is 434) |
| `flutter build apk --debug` | exit 0 (187 MB artifact) |
| Local toolchain | Flutter 3.47.1 / Dart 3.13.1 (CI pins 3.47.0) |

Housekeeping re-verification (2026-08-25): `flutter pub get`, `flutter analyze`
(0 issues), both guards, and the full test suite were re-executed locally with
identical results (434/434). The APK build was not re-run (no Android/gradle
changes since `1fe161a`; original exit 0 stands).

---

## Risks Opened by This STEP

| ID | Title | Status | Severity |
|----|-------|--------|----------|
| RISK-0005 | fl_chart upgraded to v1.2.0; chart API migration completed | open | low |
| RISK-0006 | go_router upgraded from v15 to v17; route API changes audited | monitoring | medium |
| RISK-0007 | Hive offline storage migrated to community fork hive_ce | open | medium |
| RISK-0008 | flutter_secure_storage upgraded from v9 directly to v11 (skipped v10 migration) | monitoring | medium |
| RISK-0009 | Flutter 3.47 semantics regression #191095; forui pinned >=0.26 as mitigation | open | medium |

All five entries are in `registries/risks.yml` (canonical register @ `15de557`).

---

## Deferred Items

| Item | Deferred To |
|------|-------------|
| STEP-42 Staging Pipeline | STEP-46 |
| go_router deep-link E2E validation | STEP-45 |
| flutter/flutter#191095 workaround revisit (once #191587 lands) | RISK-0009 revisit trigger |
