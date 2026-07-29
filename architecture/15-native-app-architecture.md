# Doc 15 — Native App Architecture

**Version:** v0.2.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-29 (STEP-39.2)
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

## 8. Device Performance
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
| OQ-2 | Specific local DB technology selection (SQLite vs. Hive/Isar) | STEP 2+ | Implementation |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.3a | Initial draft from Native App Architecture session |
| v0.2.0 | 2026-07-29 | STEP-39.2 | Defined precise low-battery sync state table rule (ADR-0010) |
