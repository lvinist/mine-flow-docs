# mine-flow — Release Notes: v1.2.0 (Phase 2 Completion)

**Release date:** 2026-08-03
**Audience:** Internal operators, field crews, and dashboard users
**Scope:** Phase 2 — Impeccable UI Rebuild (STEP-13 through STEP-40)

> Phase 2 completes mine-flow's cross-screen UI rebuild and stabilizes the resulting
> application test suite. The Android and web client now use a consistent neutral ForUI-based
> interface, with improved navigation, settings, field-entry workflows, and operations data
> screens. This note records the completed engineering milestone; production deployment remains
> subject to the Phase 3 release-readiness work.

## Highlights

- **Consistent operational interface:** All Phase 1 workflows were rebuilt around the shared
  ForUI design system, including login, dashboard, attendance, daily logs, tracking,
  equipment checks, data bucket, reporting, timeline, and notifications.
- **Field and office navigation:** The app now adapts its navigation to the device: a collapsible
  desktop sidebar for supervisors and a mobile-oriented navigation experience for foremen.
- **Stabilized build baseline:** STEP-40 resolved the remaining Phase 2 test failures. The
  archived closure record reports a passing `flutter test` suite and clean `flutter analyze`.

## What's New

- Settings for language, profile, theme, logout, and support routing.
- Benchmark Database under Operations.
- Improved data-entry workflows for cut/fill, land clearing, daily logs, inventory, attendance,
  equipment checks, and data-bucket metadata.
- Feature-local report actions, removing the former central reporting-menu dependency.
- Low-battery-aware automatic sync behavior while preserving manual sync capability.

## Improvements

- Responsive layouts, compact data-dense surfaces, semantic UI treatment, and consistent ForUI
  controls across the application.
- Reorganized desktop and mobile navigation around Dashboard, Tools, Operations, Teams, and
  Settings.
- Cleaner zone, material, and inventory-item selection through shared creatable comboboxes.
- Benchmark, routing, breadcrumbs, form layouts, and app-bar behavior corrected across the
  operations workflows.

## Fixes

- Fixed the remaining widget-test wrapper and route assumptions after the ForUI and attendance
  form migrations.
- Removed the retry-timing race in the offline sync queue test.
- Fixed the app-launch smoke test accessibility-scope crash.

## Breaking Changes / Action Required

- No end-user migration is required for this UI milestone.
- Operators should validate their preferred theme and language setting after upgrading. Indonesian
  is the intended default-language direction, but its full localization implementation is planned
  as Phase 3 work.

## Known Issues

- A cross-screen runtime design review remains planned; static code and automated tests do not
  substitute for phone and desktop rendered-state validation.
- Production deployment, staging, generated Supabase contract enforcement, security/privacy
  baseline work, and full staging E2E coverage are Phase 3 release-readiness work.

## Documentation

- This release note records the completed Phase 2 milestone.
- Current architecture reconciliation and release-readiness decisions will be recorded through
  new Phase 3 STEPs; historical Phase 2 plans and reports are preserved unchanged.

## References

- **Released version/tag:** v1.2.0 milestone record; no production deployment/tag asserted
- **Deployed to:** Not asserted by this release note
- **Related STEPs:** STEP-13 through STEP-40
- **Architecture / ADRs:** `architecture/07-ui-design-system.md`; ADR-0008 (Impeccable Bridge
  and UI Design Tokens); ADR-0009 (UI Design System Drift); ADR-0010 (Low-Battery Sync Rule)
