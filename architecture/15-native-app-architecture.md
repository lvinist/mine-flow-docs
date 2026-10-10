# Doc 15 — Native App Architecture

**Version:** v0.3.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-10-10 (STEP-59.4)
**Audience:** All contributors — this sets the specific capabilities, sync strategies, and security posture of the mobile (and desktop/web) client.

> Defines the offline sync strategy, local storage, device capabilities, and distribution approach for the Flutter app.

## Table of Contents
- [1. Platform Strategy & Targets](#1-platform-strategy-targets)
- [2. Offline Capabilities & Syncing](#2-offline-capabilities-syncing)
- [3. On-Device Storage & State](#3-on-device-storage-state)
- [4. Push Notifications](#4-push-notifications)
- [5. Device Permissions](#5-device-permissions)
- [6. Mobile Device Security](#6-mobile-device-security)
- [7. Distribution & Release](#7-distribution-release)
- [8. Device Performance](#8-device-performance)
- [Decision Summary](#decision-summary)
- [Open Questions](#open-questions)
- [Version Log](#version-log)

## 1. Platform Strategy & Targets
The unified client application is built with **Flutter** (using BLoC for state management). For the MVP, we target:
- **Android:** Direct distribution to foremen operating in the field.
- **Web:** Deployed for supervisors operating from the office.
*iOS and desktop builds are deferred for future phases but inherently preserved by the cross-platform nature of the framework.*

## 2. Offline Capabilities & Syncing
Field conditions require robust offline capabilities for Android clients.
- **Offline-First:** Core data entry (checklists, daily logs, cut/fill volumes, attendance) is written to local storage first, allowing the app to function fully without internet.
- **Background Sync:** The app listens for connectivity. When online, it syncs local changes to Supabase.
- **Conflict Resolution:** A simple "last-write-wins" approach is employed since foremen typically manage their own specific areas/crews, minimizing concurrent edit conflicts.

## 3. On-Device Storage & State
- **Live State:** Handled by BLoC.
- **Everyday Data:** Stored in a fast, plain local database (e.g., SQLite/sqflite or Hive) to manage offline records and sync queues.
- **Sensitive Data:** Session tokens and credentials are encrypted and stored in secure storage (`flutter_secure_storage` utilizing Android Keystore).

## 4. Push Notifications
For the MVP, notifications are restricted to **in-app notifications only**. Alerts (low inventory, attendance thresholds) will display when the app is actively open. Firebase Cloud Messaging (FCM) push notifications are deferred to Phase 2 to reduce initial complexity.

## 5. Device Permissions
The MVP relies on minimal native device permissions:
- **Camera:** Required for foremen to attach photos to checklists and daily logs.
- **Location/GPS:** Not required for MVP (all data manually entered; automated GPS deferred to Phase 2).
- Signature captures (paraf) will utilize on-screen drawing rather than requiring special hardware or permissions.

## 6. Mobile Device Security
Given the internal 1-month MVP timeline:
- **Data at Rest:** Relies on the standard device lock screen (PIN/Biometrics) for everyday data protection. No application-level database encryption is implemented for offline records.
- **Root/Jailbreak Detection:** Explicitly excluded for MVP to maintain simplicity.
- Tokens remain securely stored via `flutter_secure_storage`.

## 7. Distribution & Release
- **Android:** Distributed via **Direct APK Download** (e.g., hosted on Google Drive or a simple internal page). An in-app version check will prompt users to download updates.
- **Web:** Standard continuous deployment, auto-updating on browser refresh.

## 8. Process-Death State Restoration

### 8.1 Scope

All seven form surfaces preserve user-drafted entries across Android/iOS process death via go_router's `restorationScopeId` framework (app-root, app-shell, and 5 branch scopes) plus per-page `restorationId` on `CustomTransitionPage`s. The attendance form was the original reference implementation; STEP-59 extends the same pattern to every remaining form.

### 8.2 Mechanism

- A single `RestorableStringN` per form holds one versioned JSON snapshot (e.g. `cutfill-draft-v1`, `dailylog-draft-v1`, `benchmark-draft-v1`).
- `encode()` captures only ENTRY fields (user-entered values + selected entity ids); CONTEXT fields (record ids, site/foreman identity, timestamps, computed lat/lon, file bytes) are reloaded fresh from the repository on restore.
- `decode()` is strict: version mismatch, malformed JSON, missing required fields, or identity mismatch (siteId/foremanId/date) returns `null` → the form starts clean with no partial draft.
- Restore is status-gated where applicable (daily log only restores `LogStatus.draft` snapshots; submitted/approved rows reject the snapshot).
- The snapshot is cleared on successful close or explicit discard (one-shot `_handleClose` latch is not overridden by restore).

### 8.3 Feature coverage

| Feature | Snapshot key | ENTRY fields | Restore trigger | Reload-before-apply | Notes |
|---|---|---|---|---|---|
| Attendance | `attendance-draft-v1` | status + remarks per crew member | `AttendanceFormRestoreRequested` | Roster + auth reloaded | Reference implementation (`27e5c5c`) |
| Cut/Fill | `cutfill-draft-v1` | zoneId, bcm, lcm, material, elevation, notes | `CutFillFormRestoreRequested` | `getCutFillRecordById` | Zero volumes encoded as null |
| Land Clearing | `landclearing-draft-v1` | zoneId, method, clearingDate, planArea, actualArea, notes, tab | `LandClearingFormRestoreRequested` | `getLandClearingRecordById` | Tab state restored (defaults to Actual) |
| Daily Log | `dailylog-draft-v1` | logDate, zoneId, weather, summary, notes, hazard{state,severity,notes,action} | `DailyLogFormRestoreRequested` | Repository reload | Status-gated (draft only); hazard as-entered, validator re-runs on restore |
| Equipment Check | `eqcheck-draft-v1` | Per-item isPassed (null-preserved), per-item remarks, form remarks | `EquipmentCheckFormRestoreRequested` | Fresh checklist load | CF-017: null = unanswered, never coerced to false; UI selectors (equipmentType, checkType, serialNumber) NOT restored (Q2 Option A) |
| Benchmark | `benchmark-draft-v1` | bmId, northing, easting, orthoHeight, ellipsHeight, code, orde, crsIdentifier, status | `BenchmarkFormRestoreRequested` | Projection recompute | Lat/lon/geom/id excluded from snapshot; 55.4 recompute-on-restore; sentinel coords rejected by projection path |
| Inventory | `inventory-draft-v1` | zoneId, itemName, category, quantityOnHand, unit, minThreshold, sku, notes | `InventoryFormRestoreRequested` | `getInventoryItemById` | CONTEXT fields (id, timestamps) never serialized |
| Data Bucket | `data-bucket-draft-v1` | zoneId, acquisitionDate, notes | `DataBucketMetadataRestoreRequested` | Fresh load | File bytes NOT restorable (Q2); re-pick banner shown with `dataBucketFileUnavailable` l10n key |

### 8.4 Verification

`tester.restartAndRestore()` round-trips are the faithful process-death simulation (not `getRestorationData`/`restoreFrom`, which go_router's one-time registration assertion rejects). Full suite green at the merged head; focused restoration matrix (80 tests) green. The attendance reference test's own `RestorationMixin` wiring does NOT claim OS-engine round-trip — that boundary is carried forward as Unverified (see FINDINGS).

### 8.5 Known boundaries (carried forward)

- Data-bucket file bytes cannot survive process death (binary, >50 MB). Metadata-only restore with a re-pick banner is the chosen mitigation (59.0 §10A, Option A).
- Equipment-check UI selectors (equipmentType, checkType, serialNumber) are not restored — reloaded fresh per Q2 unambiguous-only rule.
- The `attendance` reference test's `RestorationMixin` wiring is widget-proven, not OS-engine-proven. The `restartAndRestore()` simulation exercises the Flutter restoration layer; a true OS kill/restart on a real device is not covered by automated tests.

## 8.6 Device Performance
To ensure adequate battery life for full field shifts:
- Background syncing is strictly event-based (checking internet connection availability) and runs only when connectivity is established.
- Syncing is explicitly **paused** for background/automatic operations if the device battery is low (OS Battery Saver ON OR raw battery <= 20%). Charging bypasses this. Manual syncs are still allowed.
- Syncing primarily triggers when the app is actively open or recently closed, avoiding persistent background battery drain.
- The Android APK size target should be kept small (e.g., < 50MB) to facilitate direct downloads over slow connections.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Target Platforms | Android and Web only | Focuses solo developer time on highest impact surfaces for MVP | iOS/Desktop delayed to later phases |
| 2 | Offline Strategy | Offline-first for Android core entry with "last-write-wins" | Field conditions require offline work; simple conflict resolution is sufficient for isolated foreman duties | Advanced concurrent merge logic |
| 3 | Local Storage | Plain DB (SQLite/Hive) for data, Secure Storage for tokens | Balances speed and sync capabilities with essential security | Fully encrypted local database |
| 4 | Notifications | In-app only | Simplifies MVP build by avoiding FCM and permissions | Users will not be alerted when app is closed |
| 5 | Device Permissions | Camera only | Allows photo attachments for logs; defers GPS to Phase 2 | Automated geolocation tagging |
| 6 | Device Security | Rely on standard lock screen; no root block | Avoids complex security overhead for a fast internal MVP | Complete protection on stolen/rooted devices |
| 7 | Android Distribution | Direct APK Download with in-app update prompt | Bypasses Google Play review delays and developer account requirements | Seamless, silent background auto-updates via Play Store |
| 8 | Performance | Pause background sync on low battery (<=20% or Saver ON); event-based sync | Preserves foreman battery life for full shift | Immediate background sync guarantees if battery is low or app is killed |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| OQ-2 | Specific local DB technology selection (SQLite vs. Hive/Isar) | Resolved — ADR-0006 selected Hive (2026-07-18); migrated to the `hive_ce` community fork in STEP-43 (RISK-0007) | — |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.3a | Initial draft from Native App Architecture session |
| v0.2.1 | 2026-09-08 | STEP-50.1 | OQ-2 marked resolved: ADR-0006 selected Hive; STEP-43 migrated it to `hive_ce` (RISK-0007) |
| v0.2.0 | 2026-07-29 | STEP-39.2 | Defined precise low-battery sync state table rule (ADR-0010) |
| v0.3.0 | 2026-10-10 | STEP-59.4 | Added §8 Process-Death State Restoration: documented go_router restorationScopeId + per-page restorationId + versioned draft snapshot mechanism across all 7 form surfaces (attendance reference + cut/fill, land clearing, daily log, equipment check, benchmark, inventory, data-bucket). code change: restoration extended to all form features, see STEP-59. Feature-coverage table, verification summary, and known boundaries (data-bucket file bytes, equipment UI selectors, attendance test's Unverified OS-engine boundary). |
