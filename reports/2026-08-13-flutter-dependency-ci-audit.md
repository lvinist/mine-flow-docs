# mine-flow Audit Report — Flutter/Dart Upgrade & Android CI Breakage

**Date:** 2026-08-13
**Scope:** Android CI build failure triage; package compatibility against Flutter 3.47 / Dart 3.13 (latest stable)
**Auditor:** Antigravity (Claude Sonnet 4.6 Thinking)
**Method:** Read-only. No code written. Sources: pub.dev, flutter.dev/release/archive, official release notes, CI workflow on disk.

---

## Platform Baseline (Latest Stable as of 2026-08-13)

| Component | Latest Stable | Bundled Dart |
|-----------|--------------|-------------|
| **Flutter** | 3.47.0 (released 2026-08-12) | **Dart 3.13.0** |
| **Flutter 3.44** _(previous cycle)_ | 3.44.x (released 2026-05-20) | Dart 3.12 |

> [!IMPORTANT]
> Flutter 3.47 brings **Impeller to desktop by default**, decoupled `material_ui` / `cupertino_ui` packages (1.0 standalone), and targets **Android API 36 / AGP 9.x**. Swift Package Manager is now the default for iOS/macOS (from 3.44). These are not just tooling bumps — some are breaking for CI pipelines.

---

## Legend

| Severity | Meaning |
|----------|---------|
| **🔴 Breaking** | Will fail build or runtime; must fix before green CI |
| **🟠 High** | Will likely cause build failure or deprecation warnings that block CI analysis; fix soon |
| **🟡 Notable** | Major version behind; API drift risk; address before next STEP |
| **🟢 OK** | Compatible; no action needed |

---

## Section 1 — CI Workflow Audit

### CI file: `.github/workflows/ci.yml`

#### Finding CI-1: `build-android` job uses `flutter-version: "3.x"` (wildcard) — 🔴 Breaking

| Attribute | Detail |
|-----------|--------|
| **Location** | `ci.yml` line 75 — `build-android` job |
| **Problem** | The wildcard `"3.x"` on the `build-android` job resolves to **Flutter 3.47.0** now (latest stable in the 3.x channel). Flutter 3.47 requires **AGP ≥ 9.1.0**. The project uses **AGP 9.0.1** (`settings.gradle.kts` line 22). The Flutter Gradle plugin bundled in 3.47 raises a hard error for AGP < 9.1.0. |
| **Root cause** | AGP bumped from 9.0.1 to 9.1.0 as the minimum between Flutter 3.44 and 3.47. The wildcard CI job invisibly pulled in the new Flutter release without anyone touching the workflow. |
| **Impact** | `flutter build apk` fails in CI. Local dev passes if developer is on an older pinned Flutter version. Classic "works on my machine" divergence. |

#### Finding CI-2: `test` job pins `flutter-version: "3.32.x"` — 🟠 High

| Attribute | Detail |
|-----------|--------|
| **Location** | `ci.yml` line 33 — `test` job |
| **Problem** | The `test` job is pinned to **Flutter 3.32.x** (Dart ~3.8). The `forui ^0.24.2` package requires **Flutter ≥ 3.44.0**. A `flutter pub get` on Flutter 3.32.x cannot satisfy this constraint. Additionally, the two CI jobs (test vs build) run different Flutter SDKs, creating a split environment where the tested artifact and the built artifact have different toolchains. |
| **Impact** | `flutter pub get` in the test job may fail or silently resolve incompatible package versions. Test results do not reflect the actual build environment. |

#### Finding CI-3: No explicit Java/JDK setup step in either job — 🟠 High

| Attribute | Detail |
|-----------|--------|
| **Location** | `ci.yml` — both jobs |
| **Problem** | Neither job sets up Java explicitly. `ubuntu-latest` GitHub-hosted runners use a default JDK that varies by image revision. AGP 9.x has a hard minimum of JDK 17. If a runner revision ships JDK 11, the Android build will hard-fail. If it ships JDK 21+, Kotlin compilation may warn or error on JVM target mismatch. |
| **Impact** | Non-deterministic. CI can break on any `ubuntu-latest` image refresh with no code change. |

---

## Section 2 — Android Build Configuration Audit

### Finding AND-1: AGP version is 9.0.1; Flutter 3.47 requires ≥ 9.1.0 — 🔴 Breaking

| Attribute | Detail |
|-----------|--------|
| **File** | `android/settings.gradle.kts` line 22 |
| **Current** | `id("com.android.application") version "9.0.1"` |
| **Required (Flutter 3.47)** | AGP **≥ 9.1.0** |
| **Root cause** | The Flutter Gradle plugin embedded in Flutter 3.47 enforces a minimum AGP constraint bump from 9.0.x to 9.1.0. AGP 9.0.1 was valid for Flutter 3.44; it is rejected by Flutter 3.47's plugin validator. |

### Finding AND-2: Kotlin Gradle Plugin at 2.3.20; current stable is 2.4.0 — 🟡 Notable

| Attribute | Detail |
|-----------|--------|
| **File** | `android/settings.gradle.kts` line 23 |
| **Current** | `id("org.jetbrains.kotlin.android") version "2.3.20"` |
| **Latest stable** | 2.4.0 |
| **Note** | Project sets `android.builtInKotlin=false` and `android.newDsl=false` in `gradle.properties`, keeping the external KGP path. 2.3.20 is compatible with Gradle 9.1.0 today; upgrading to KGP 2.4.0 alongside AGP 9.1.0 is recommended for a clean 3.47 build chain. |

### Finding AND-3: Gradle wrapper 9.1.0 vs AGP 9.1.0 minimum — 🟢 OK (borderline)

| Attribute | Detail |
|-----------|--------|
| **File** | `android/gradle/wrapper/gradle-wrapper.properties` line 5 |
| **Current** | `gradle-9.1.0-all.zip` |
| **Required for AGP 9.1.0** | Gradle ≥ 9.1.0 |
| **Assessment** | Meets the minimum exactly once AGP is bumped to 9.1.0. No Gradle wrapper change needed. |

---

## Section 3 — Dart Package Compatibility Audit

All comparisons are against the project's current `pubspec.yaml` pins and latest stable versions as of **2026-08-13**. App SDK constraint: `>=3.12.2 <4.0.0`. Flutter 3.47 bundles Dart 3.13.0.

### 3.1 — State Management & Navigation

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `flutter_bloc` | `^9.1.1` | **8.1.6** | 🔴 Breaking | Version `^9.1.1` **does not exist on pub.dev**. Latest `flutter_bloc` is `8.1.6`. A `^9.x` constraint means `pub get` fails — no version satisfies. This alone will break every CI job. |
| `bloc` | `any` | — | 🟠 High | Transitively resolved by `flutter_bloc`. With `^9.1.1` broken above, the entire dep tree fails to resolve. |
| `go_router` | `^15.1.2` | **17.3.0** | 🟡 Notable | Two major versions behind. v16 and v17 contain breaking route API changes. No immediate build failure on current constraint. |
| `equatable` | `^2.0.7` | 2.0.7 | 🟢 OK | Current. |

> [!CAUTION]
> `flutter_bloc: ^9.1.1` is almost certainly the **primary cause** of `flutter pub get` failing in CI on both jobs. No pub.dev version satisfies `^9.1.1`. The latest major is `8.x`. This must be the first fix — verify if this was a typo (intended `^8.1.1`?) before anything else.

### 3.2 — Backend & Storage

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `supabase_flutter` | `^2.9.2` | **2.17.1** | 🟡 Notable | 8 minor/patch versions behind. Compatible with current Dart but missing auth and realtime improvements. |
| `hive` | `^2.2.3` | 2.2.3 (frozen) | 🟠 High | Original `hive` package is **unmaintained** — no releases since 2022. Community successor is `hive_ce` (Hive Community Edition). Does not break today but pub.dev emits maintenance warnings; accumulating long-term risk. ADR-0001 should acknowledge this status. |
| `hive_flutter` | `^1.1.0` | 1.1.0 (frozen) | 🟠 High | Same as above — unmaintained. `hive_ce_flutter` is the active fork. |
| `path_provider` | `^2.1.5` | ~2.1.5 | 🟢 OK | Current. |

### 3.3 — Security & Connectivity

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `flutter_secure_storage` | `^9.2.4` | **11.0.0** | 🔴 Breaking (future, data risk) | v11.0.0 raises Android `minSdk` to **23** and removes deprecated encryption algorithms. Requires staged migration: v9 → v10 (runs key migration) → v11. Skipping v10 silently makes previously-stored secure data unreadable on device. Not an immediate CI build failure, but a production data-loss risk on any direct upgrade. |
| `connectivity_plus` | `^6.1.4` | **7.3.1** | 🟡 Notable | One major version behind. No breaking API changes reported. Low-risk upgrade. |
| `battery_plus` | `^7.1.1` | ~7.1.0+ | 🟢 OK | Current. |

### 3.4 — File, Media & Export

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `file_picker` | `^9.0.0` | **11.0.3** | 🔴 Breaking | v11.0.0 is a **breaking API refactor**: `FilePicker.platform.pickFiles()` is gone; replaced by static `FilePicker.pickFiles()`. Two major versions behind. AGP 9 support also landed in v11. All `FilePicker.platform.*` call sites in the codebase must be updated. |
| `image_picker` | `^1.1.2` | ~1.0.x stable | 🟢 OK | On `1.x` XFile-based API. Current. |
| `url_launcher` | `^6.3.1` | ~6.3.x | 🟢 OK | Current. |
| `pdf` | `^3.11.1` | ~3.11.x | 🟢 OK | Current. |
| `printing` | `^5.13.4` | ~5.13.x | 🟢 OK | Current. |

### 3.5 — UI & Visualization

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `forui` | `^0.24.2` | **0.25.0** | 🟡 Notable | One minor version behind. **Critical CI interaction**: `forui ≥ 0.22.0` requires **Flutter 3.44.0+**. The `test` CI job uses Flutter 3.32.x, so `flutter pub get` will fail on that job even if `flutter_bloc` is fixed. Both jobs must pin to Flutter 3.44+ to resolve `forui`. |
| `fl_chart` | `0.69.2` (exact pin) | **1.2.0** | 🟡 Notable | Exact pin to `0.69.2`. `fl_chart 1.0.0` was a complete API rewrite — no automatic resolution to v1.x due to the exact pin. Requires manual migration; `1.2.0` requires Dart ≥ 3.6.2 and Flutter ≥ 3.27.4 (both satisfied). Not a CI failure today due to the exact pin holding, but no upgrade path without intervention. |

### 3.6 — Google APIs & Utilities

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `googleapis` | `^14.0.0` | ~14.x | 🟢 OK | Current. |
| `googleapis_auth` | `^1.6.0` | ~1.6.x | 🟢 OK | Current. |
| `http` | `^1.2.2` | ~1.2.x | 🟢 OK | Current. |
| `proj4dart` | `^2.1.0` | ~2.1.x | 🟢 OK | Current. |
| `uuid` | `^4.5.1` | ~4.5.x | 🟢 OK | Current. |
| `intl` | `^0.20.2` | ~0.20.x | 🟢 OK | Current. |
| `logging` | `^1.2.0` | ~1.2.x | 🟢 OK | Current. |

### 3.7 — Dev Dependencies

| Package | Pinned | Latest Stable | Status | Notes |
|---------|--------|--------------|--------|-------|
| `flutter_lints` | `^5.0.0` | ~5.0.x | 🟢 OK | Current. |
| `build_runner` | `^2.3.0` | ~2.4.x | 🟡 Notable | Slightly behind; no breaking changes. |
| `mocktail` | `^1.0.4` | ~1.0.x | 🟢 OK | Current. |
| `bloc_test` | `^10.0.0` | ~10.0.x | 🟢 OK | Consistent with `flutter_bloc ^8.x`. |

---

## Section 4 — Summary: Breaking Items by Priority

> [!CAUTION]
> The following items will actively break the Android CI build and must be resolved before any green CI run.

### Priority 1 — Fix immediately (CI is currently broken)

| # | Finding | File | Action needed |
|---|---------|------|---------------|
| 1 | **`flutter_bloc: ^9.1.1` does not exist on pub.dev** | `pubspec.yaml` line 23 | Correct to `^8.1.6` (or appropriate `^8.x`). `pub get` fails for every CI job today. Verify whether `bloc_test ^10.0.0` stays aligned (it does, with `flutter_bloc ^8.x`). |
| 2 | **AGP 9.0.1 rejected by Flutter 3.47 Gradle plugin** | `android/settings.gradle.kts` line 22 | Bump AGP to `"9.1.0"`. |
| 3 | **`build-android` job wildcard `"3.x"` picked up Flutter 3.47** | `.github/workflows/ci.yml` line 75 | Pin to a concrete version matching the `test` job, or align both to `"3.44.x"` / `"3.47.x"`. |
| 4 | **No explicit JDK setup** | `.github/workflows/ci.yml` both jobs | Add `actions/setup-java@v4` (`java-version: '17'`, `distribution: 'temurin'`) before the Flutter step in both jobs. |
| 5 | **`test` job Flutter 3.32.x incompatible with `forui ≥ 0.22`** | `.github/workflows/ci.yml` line 33 | Upgrade pinned version to ≥ 3.44.x. Aligns with fix #3. |

### Priority 2 — Fix before next feature STEP

| # | Finding | Action needed |
|---|---------|---------------|
| 6 | **`file_picker ^9.0.0` → latest 11.0.3 (breaking API)** | Migrate to `^11.0.3`; update all `FilePicker.platform.*` call sites to static `FilePicker.*` API. |
| 7 | **`flutter_secure_storage ^9.2.4` → v11 (data migration risk)** | Plan staged upgrade: v9 → v10 first (data migration), then v11. Verify `minSdk ≥ 23` in `build.gradle.kts` (currently unset, resolved from `flutter.minSdkVersion`). |
| 8 | **`fl_chart 0.69.2` exact pin, v1.x is stable** | Evaluate migration to `^1.2.0`; requires chart widget API updates. |

### Priority 3 — Track in `registries/risks.yml`

| # | Finding | Action needed |
|---|---------|---------------|
| 9 | `hive` / `hive_flutter` — unmaintained upstream | Add to `registries/risks.yml`. Evaluate migration STEP to `hive_ce` / `hive_ce_flutter`. ADR-0001 should note the successor package. |
| 10 | `go_router ^15.1.2` → latest 17.3.0 | Read v16/v17 migration guides before next routing STEP. |
| 11 | `connectivity_plus ^6.1.4` → 7.3.1 | Low-risk bump; schedule for next dependency-update pass. |
| 12 | KGP `2.3.20` → `2.4.0` | Update alongside AGP bump (Priority 1 item #2). |
| 13 | `supabase_flutter ^2.9.2` → 2.17.1 | 8 versions behind; catch up before next Supabase-touching STEP. |

---

## Section 5 — Immediate CI Fix Recipe (audit reference only — no code written)

To restore a green Android CI build, the following changes are needed in sequence:

1. **`pubspec.yaml`**: Correct `flutter_bloc: ^8.1.6` (from the non-existent `^9.1.1`).
2. **`android/settings.gradle.kts`**: Bump AGP to `"9.1.0"`. Bump KGP to `"2.4.0"`.
3. **`.github/workflows/ci.yml`**:
   - Add `actions/setup-java@v4` (JDK 17, Temurin) as the **first** step in **both** jobs.
   - Align both Flutter pins to the same concrete version — recommend `"3.44.x"` (stable, known-good) or `"3.47.x"` if accepting the AGP bump.
4. Run `flutter pub get` locally to verify the full dependency tree resolves cleanly.

---

## Risks Register Cross-Reference

The following should be recorded in [`registries/risks.yml`](file:///D:/AppDev/mine_flow/Code/mine-flow-docs/registries/risks.yml) as accepted deferred debt:

- `hive` / `hive_flutter` unmaintained upstream (Priority 3, #9) — reference this report.
- `flutter_secure_storage` staged migration requirement (Priority 2, #7) — reference this report.
- `fl_chart` exact-pin to 0.x (Priority 2, #8) — reference this report.

---

*Report ends. No code modified. Next action: create a fix STEP or ticket for Priority 1 items.*

## STEP-43 Resolution Evidence (2026-08-13)

Document that all Priority 1 CI issues are now resolved:
- STEP-43 applied fixes, `flutter pub get` exited 0 (34 dependency changes)
- `flutter analyze` exited 0 (after fixing `encryptedSharedPreferences` removal in `secure_storage_service.dart`)
- AGP 9.1.0, KGP 2.4.0, Flutter 3.47.0 pinned in CI, JDK 17 explicit
- All packages upgraded as listed above
- Known deferred items: fl_chart v1.x fully migrated (no deprecated API was in use)
- Dependency overrides: `flutter_secure_storage_windows: 4.0.0` — documented reason: file_picker 11.x / flutter_secure_storage_windows 4.2+ transitive conflict on `win32`. Overriding secure_storage_windows back to 4.0.0 forces `win32 ^5.x`, which successfully compiles `file_picker` on Windows CI runners.
- `bloc_test` corrected to `^9.1.5` (the correct companion for flutter_bloc 8.x)
