# ADR-0018: Android Build Chain Posture & Built-in Kotlin Migration

**Status:** Accepted
**Date:** 2026-08-29

## Related documents
- architecture/09-environments.md
- ADR-0017-release-readiness-evidence

## Context
The project's local Android build and CI `e2e-android` job failed under AGP 9.1.0. The root cause was that AGP 9 rejects the unconditional `apply plugin: 'kotlin-android'` block. Two legacy plugins (`package_info_plus` 9.0.1, `file_picker` 11.0.3) did exactly that.
Upgrading only the offending plugins was blocked by a `win32` version coupling with `flutter_secure_storage`. A previously introduced `dependency_overrides` block pinned `flutter_secure_storage_windows` to 4.0.0, which made partial upgrades unresolvable. Furthermore, attempting to use the `android.builtInKotlin=false` escape hatch in `gradle.properties` failed at the `:app:compileDebugJavaWithJavac` stage because plugin Kotlin output was routed differently while compiling against a stub.

## Decision
1. **Adopt AGP 9 built-in Kotlin** for the project, keeping `android.newDsl=false` as Flutter's required compatibility shim.
2. **Upgrade plugins** to AGP-9-native versions (`package_info_plus` 10.x, `file_picker` 12.x) and delete the `dependency_overrides` block that previously constrained them.
3. **Reject AGP-8 downgrade**: Flutter 3.47 emits deprecation warnings for AGP < 9.0.1, and AGP 10 will mandate the built-in Kotlin migration regardless. We choose to fix forward.

## Consequences
- **Plugin Constraints:** Plugin choices are now constrained to AGP-9-native versions that do not unconditionally apply the legacy Kotlin plugin.
- **Dependency Upgrades:** `win32` 6.x is adopted project-wide. `flutter_secure_storage_windows` moved from 4.0.0 to 4.2.2. This change strictly touches the Windows-desktop storage surface and does not alter the Android Keystore path that ADR-0005 and Doc 06 depend on.
- **Host Prerequisites:** Local Android builds now strictly require the documented host setup, notably JDK 17 and a same-drive `PUB_CACHE` rule.

