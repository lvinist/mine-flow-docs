# mine-flow — STEP-54 & STEP-55 Design Blueprint & Specification

**Date:** 2026-09-10  
**Status:** Locked Decisions & Reserved Scope  
**Author:** User interview via `/grill-me`  
**Related STEPs:** [STEP-54](file:///d:/AppDev/mine_flow/prompts/STEP-index.md#L300), [STEP-55](file:///d:/AppDev/mine_flow/prompts/STEP-index.md#L301)  

---

## 1. Executive Summary

This document captures the architectural decisions, UX interaction patterns, and substep roadmaps for:
- **STEP-54:** Multiplatform Impeccable Feature-Cohesion Critique & Polish Spec
- **STEP-55:** Cohesive UI Rebuild — Form Sheets, Contextual Report Dialogs & Impeccable Audit

The primary goal of these STEPs is to eliminate fragmented, disconnected screen flows and unify the entire application across Web (desktop) and Mobile (Android) under cohesive feature workflows. Each operational domain is treated as a unified lifecycle (List view → Form input sheet → Detail inspector → Contextual report dialog).

---

## 2. Locked Architectural & Interaction Decisions

| Decision ID | Area | Decision | Details & Rationale |
|---|---|---|---|
| **D1** | **Web/Desktop Sheet Placement** | **Right-side modal flyout sheet** | Desktop width 480–600dp. Anchored on the right side so the permanent left navigation sidebar (`FSidebar`) remains unobstructed and accessible. |
| **D2** | **Mobile Sheet Placement** | **Modal bottom sheet** | Native Android/mobile ergonomics; draggable and scrollable within the thumb zone. |
| **D3** | **Modality & Scrim** | **Modal overlay with dimmed backdrop** | Dims the background content. Prevents accidental background interactions while focusing the user on data entry. |
| **D4** | **Unsaved Changes Intercept** | **Universal dirty-state confirmation guard** | Any dismiss attempt (`X` close button, backdrop tap, `ESC` key, or Android back gesture) is intercepted when form fields contain unsaved modifications.<br>Presents an alert dialog:<br>• **"Lanjut Mengedit"** (Cancel dismiss, retain input data)<br>• **"Buang Perubahan"** (Confirm dismiss, discard input data) |
| **D5** | **Deep Linking & URL Sync** | **Synchronized GoRouter routes** | Opening a form sheet updates the browser URL (e.g. `/operations/cut-fill/form` or `/teams/daily-log/form`), ensuring browser refresh, bookmarking, and forward/back navigation work predictably. |
| **D6** | **Report Presentation** | **Contextual modal dialog (`FDialog`)** | Clicking "Buat Laporan" on any list screen opens a modal dialog pre-bound to that feature's `ReportType`, preserving table filters and list state behind it rather than redirecting away to a separate screen. |
| **D7** | **Item Detail Views** | **Evaluated per feature in STEP-54** | STEP-54 critique determines whether each feature's detail view (e.g. Data Bucket file inspection or Equipment Check records) should become a side-sheet inspector or remain a full page. |
| **D8** | **Substep Granularity** | **1:1 feature parity** | Every individual feature workflow is critiqued as its own dedicated substep in STEP-54, and implemented as its own dedicated substep in STEP-55. |

---

## 3. STEP-54: Multiplatform Impeccable Feature-Cohesion Critique & Polish Spec

**Objective:** Conduct an end-to-end Impeccable critique evaluating each feature as a cohesive suite across Web and Mobile, producing an actionable specification and design system tokens.

### Substep Breakdown:
- **54.1: Shell, Navigation & Responsive Foundation Critique**  
  Desktop `FSidebar`, mobile `FBottomNavigationBar`, global app header, responsive breakpoints (800dp), theme toggles, and token consistency.
- **54.2: Operations Suite 1 — Cut & Fill Volume Tracking**  
  Cohesive review of list table/cards, entry form sheet, and contextual PDF report dialog.
- **54.3: Operations Suite 2 — Land Clearing Tracking**  
  Cohesive review of tabbed summary (Plan vs Actual), shared method combobox, entry sheet, and report dialog.
- **54.4: Operations Suite 3 — Benchmark Database**  
  Cohesive review of benchmark list, coordinate entry sheet, CRS projection helpers, and spatial validation.
- **54.5: Teams Suite 1 — Crew Attendance**  
  Cohesive review of attendance roster, status badges, check-in form sheet, and attendance summary report dialog.
- **54.6: Teams Suite 2 — Daily Logging**  
  Cohesive review of timeline log entries, weather/hazard chips, structured log entry sheet, and daily log report dialog.
- **54.7: Teams Suite 3 — Equipment Digital Checks**  
  Cohesive review of equipment history, status band headers, SOP checklist form sheet, and inspection details.
- **54.8: Teams Suite 4 — Inventory Management**  
  Cohesive review of stock dashboard, item entry sheet, stock adjustment modal, and inventory report dialog.
- **54.9: Tools & Timeline — Data Bucket & Work Timeline**  
  Cohesive review of file repository (list, upload sheet, file detail inspector), and work timeline milestone sheet.
- **54.10: System Utilities — Dashboard, Notifications, Settings & Auth**  
  Cohesive review of KPI cards, notification center, settings (profile, locale, theme), and login screen.
- **54.11: Master Impeccable Polish Specification & Interaction Blueprint**  
  Consolidate findings into the formal design blueprint: reusable sheet contract, dirty-check interaction flow, contextual report dialog architecture, and design tokens for STEP-55.

---

## 4. STEP-55: Cohesive UI Rebuild — Form Sheets, Contextual Report Dialogs & Impeccable Audit

**Objective:** Implement the STEP-54 blueprint across all features with 1:1 substep execution, concluding with a multiplatform Impeccable technical audit.

### Substep Breakdown:
- **55.0: Core Foundation — Responsive Sheet Container & Dirty Intercept Scaffold**  
  Build `AppResponsiveSheet` (Right sheet on Web desktop, bottom sheet on Mobile) with `PopScope` integration, dirty-form state tracker, and GoRouter deep-link adapter.
- **55.1: Contextual Report Dialog Container**  
  Refactor `ReportConfigPage` into an `FDialog`-compatible modal retaining feature context.
- **55.2: Feature Rebuild — Cut & Fill Volume Tracking**  
  Migrate form to `AppResponsiveSheet`, integrate contextual report dialog, apply UI polish.
- **55.3: Feature Rebuild — Land Clearing Tracking**  
  Migrate form to `AppResponsiveSheet`, integrate contextual report dialog, apply UI polish.
- **55.4: Feature Rebuild — Benchmark Database**  
  Migrate form to `AppResponsiveSheet`, integrate CRS details, apply UI polish.
- **55.5: Feature Rebuild — Crew Attendance**  
  Migrate form to `AppResponsiveSheet`, integrate contextual report dialog, apply UI polish.
- **55.6: Feature Rebuild — Daily Logging**  
  Migrate form to `AppResponsiveSheet`, integrate contextual report dialog, apply UI polish.
- **55.7: Feature Rebuild — Equipment Digital Checks**  
  Migrate form to `AppResponsiveSheet`, polish SOP inspection flow and details.
- **55.8: Feature Rebuild — Inventory Management**  
  Migrate form to `AppResponsiveSheet`, polish stock adjustment dialog and report dialog.
- **55.9: Feature Rebuild — Data Bucket & Work Timeline**  
  Migrate upload to `AppResponsiveSheet`, detail inspector integration, milestone entry sheet.
- **55.10: Shell, Dashboard, Notifications & Settings Polish**  
  Polish global shell header, dashboard overview cards, notification tiles, and settings.
- **55.11: Multiplatform Impeccable Technical Audit & Gate Verification**  
  Technical audit: accessibility (contrast, touch targets, screen-reader semantics), responsive layout stress tests across mobile/desktop, `flutter analyze` 0 issues, format clean, and full automated test suite pass on Web & Android.
