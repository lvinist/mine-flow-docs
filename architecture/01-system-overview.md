# Doc 01 — System Overview, Requirements & Non-Goals

**Version:** v0.2.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-21 (STEP-1.1)
**Audience:** All contributors — this is the foundation every other architecture doc builds on.

> Defines what mine-flow is, who it's for, what it must do, what it deliberately does not do, and the constraints, assumptions, and risks shaping the design.

## Table of Contents
- [1. Problem & Value](#1-problem-value)
- [2. Users & Stakeholders](#2-users-stakeholders)
- [3. Success Criteria](#3-success-criteria)
- [4. Scope](#4-scope)
- [5. Constraints](#5-constraints)
- [6. Assumptions](#6-assumptions)
- [7. Risks](#7-risks)
- [Decision Summary](#decision-summary)
- [Open Questions](#open-questions)
- [Version Log](#version-log)

## 1. Problem & Value

Mining site operations generate a constant stream of data — earthwork volumes (cut/fill),
land clearing area, crew attendance, equipment condition checks, inventory levels, and
geospatial survey files — but today this information is scattered across spreadsheets,
paper logs, and people's heads. Supervisors lack a single, real-time view of site
progress. When reports are needed, someone manually compiles data from multiple sources,
which takes over an hour and is error-prone. Geospatial files (.shp, .tiff) sit on Google
Drive with no structured way to search by location or acquisition date.

**Why now:** A new mine site is opening and the risk of losing operational data is
unacceptable. The survey supervisor (who is also the developer) needs a system that
gathers all the data required to identify and oversee site growth from day one. Building
this system also fulfills a KPI obligation around digitalization — making work faster,
reducing errors, and giving the team visibility into survey operations at scale.

## 2. Users & Stakeholders

### Primary personas

| Role | Description | Key needs |
|------|-------------|-----------|
| **Supervisor** (you) | Survey supervisor overseeing overall site operations. Also the developer. | Full data access, reports, alerts, user management, geospatial data bucket. |
| **Foreman** | Leads individual survey crews on the ground. Works in the field and office. | Enter attendance, equipment checks, daily logs from the field (including offline). View their crew's data. |
| **Crew member** | Survey crew personnel. | View-only: own attendance, assigned tasks. No data entry. |

### Others affected (future)
- **Other departments** (e.g., project managers, safety officers, office staff) — will gain
  access in later phases. The role-based access model should accommodate additional roles
  without a rewrite.

### Access model summary
- Foremen and above: read + write (data entry).
- Crew members: read-only (own data).
- No external / public access — this is an internal tool.

## 3. Success Criteria

| # | Criterion | Measure | Target |
|---|-----------|---------|--------|
| SC-1 | Adoption | All foremen logging attendance and equipment checks through the app | Within 2 weeks of launch |
| SC-2 | Speed | Time to compile a progress report | Under 30 minutes (down from 1+ hours) |
| SC-3 | Data completeness | Days with missing attendance or equipment-check records | Zero, after the first month |
| SC-4 | Error reduction | Data discrepancies flagged by supervisor | Noticeably fewer vs. spreadsheet era |
| SC-5 | KPI deliverable | Survey operations digitalized, demonstrable to management | System live at site opening |

## 4. Scope

### Core capabilities (MVP — Phase 1)

All features below are in scope for MVP, internally tiered so the most critical pieces are
built first. If time runs short, Tier 1 ships first; Tier 2 follows days later.

**Tier 1 — Daily operations (build first):**
- Crew attendance logging (entered by foremen / supervisors)
- Equipment digital checks — SOP-based pre-work and post-work condition checks for GNSS
  RTK, Total Station, and Drone/UAV (see overview.md for item-level detail)
- Daily logging — structured daily reports (work done, conditions, notes)
- Role-based authentication (supervisor, foreman, crew)
- **Offline support (field-critical)** — attendance, equipment checks, and daily logs work
  offline and sync via timestamp-based last-write-wins when connectivity returns

**Tier 2 — Tracking & measurement:**
- Cut/fill volume tracking — manual entry per zone, historical tracking over time
- Land clearing area tracking — manual entry per zone
- Inventory tracking — materials, equipment, consumables on site
- Data bucket — geospatial file upload via Google Drive API with metadata entry in-app
  (location coordinates, acquisition timestamp). Browse, search, filter.

**Tier 3 — Reporting & polish:**
- Work timeline — visual planned vs. actual progress
- Reports / PDF export — crew attendance & overtime, cut/fill (weekly, monthly, YTD, PTD),
  inventory tracking
- Notifications — in-app only, with persistent banner for critical items (e.g., post-work
  equipment check reminders)

### Zone structure

Zones follow a two-level categorical model:

| Category | Example zones |
|----------|---------------|
| PIT | Rusia, Italy, … |
| ETO | (single zone) |
| Soil Bank | Sochi 1, Sochi 2, … |
| Waste Dump | Moscow, Sahara, … |
| Camp | (single zone) |
| Office | (single zone) |

Categories and zones are extensible — new ones can be added without schema changes.

### Scope table

| Core (in — MVP / Phase 1) | Not now (Deferred to Phase 2) | Deferred to Phase 3 & Future | Not ever |
|------------------|--------------------|--------------------|----------|
| Crew attendance (foreman-entered) | **Features:**<br>- Settings page (lang, profile, theme, logout, support)<br>- Profile card on appbar (desktop mode)<br>- Benchmark database<br>- Weather tracking (daily/weekly/hourly) with tiles | Automated data imports (GPS, drone, telemetry) | Public-facing / external access |
| Equipment digital checks (3 types) | **Bugfixes:**<br>- Move theme button to appbar<br>- Crew attendance shows name & status, not ID<br>- Zone comboboxes (cut/fill, land clearing) with "add new" | Multi-site support | Replacing Google Drive as geospatial file store |
| Daily logging | **QoL Improvements:**<br>- Collapsible sidebar<br>- Navigation Regrouping (Dashboard, Tools, Operations, Teams, Settings)<br>- Sectioned Nav (desktop) / tiles (mobile)<br>- Integrate Laporan to feature screens<br>- Remove lat/lon from data bucket<br>- Zone/Nama Item/Method comboboxes with "add new"<br>- 2-column cut/fill layout with BCM/LCM units + soil type choices<br>- Plan/actual on land clearing<br>- Inventory form layout fixes | Advanced analytics / BI | |
| Cut/fill volume tracking | | Other department access | |
| Land clearing area tracking | | Full offline for all features | |
| Inventory tracking | | Rendering / processing geospatial files | |
| Data bucket (geospatial metadata) | | Maps with geoPDF/DXF/KML import and CRS ID | |
| Work timeline | | Slope calculator and inclination | |
| Reports / PDF export | | | |
| In-app notifications (persistent banner) | | | |
| Role-based auth (3 roles) | | | |
| Offline (field-critical only) | | | |
| Google Drive file upload via API | | | |

## 5. Constraints

| # | Constraint | Impact |
|---|-----------|--------|
| C-1 | **Solo developer, evenings only** — side project alongside full-time survey supervisor role. ~1 month MVP target. | Scope must be aggressively tiered. AI-assisted development. |
| C-2 | **Flutter + BLoC** — non-negotiable technology choice. | All UI and business logic in Dart/Flutter. |
| C-3 | **Supabase (cloud-hosted, free tier)** — Postgres, Auth, Realtime, Storage. | 500MB DB, 1GB storage, 50K MAU. No paid-tier-only features in MVP. Self-hosted later. |
| C-4 | **Google Drive** — geospatial file storage via Drive API. | Files uploaded through the app; metadata in Supabase. |
| C-5 | **Architecture must accommodate future multi-site** — don't hardcode single-site assumptions. | Data model needs a site/tenant dimension even if MVP has only one. |
| C-6 | **Zero budget for extra tools** — no paid-tier SaaS or 3rd party tools this year. | Must build custom or rely on free tiers. |

## 6. Assumptions

| # | Assumption | If wrong… |
|---|-----------|-----------|
| A-1 | ~100 users at launch, single survey team. | Free tier limits may be hit sooner; revisit hosting. |
| A-2 | Supabase cloud is reliable enough for MVP. | Would need self-hosted fallback earlier than planned. |
| A-3 | Foremen have smartphones (Android likely) for field use. | Would need feature-phone or SMS fallback. |
| A-4 | Google Drive is already in use for geospatial files. | Would need a migration path from the current storage. |
| A-5 | Flutter + BLoC + local storage (Hive/Isar/SQLite) is sufficient for offline field use. | Would need a different offline strategy or native code. |
| A-6 | Solo developer — no PR review process or team coordination overhead. AI assists. | Would need collaboration tooling and code review process. |
| A-7 | Greenfield — no existing system to migrate data from. | Would need a data migration STEP. |

## 7. Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|------|-----------|--------|------------|
| R-1 | **Timeline vs. scope** — evenings-only with all MVP features is tight. | High | High | Internal tiering: daily ops first, then polish. Ship Tier 1 even if Tier 2/3 slip a few days. |
| R-2 | **Offline sync complexity** — conflict resolution can get tricky even with timestamp-based approach. | Medium | Medium | Scoped to field-critical only; keep sync simple (last-write-wins). Most field entries are append-only (attendance, checks). |
| R-3 | **Supabase free tier limits** — 500MB DB could fill if daily logs and metadata grow quickly. | Low | Medium | Monitor usage. Geospatial files stay on Drive, not Supabase. Self-host when needed. |
| R-4 | **Solo developer / bus factor** — if developer is unavailable, project stalls. | Medium | Medium | Architecture docs make design transferable. AI-assisted development reduces single-point dependency. |
| R-5 | **Google Drive API complexity** — authentication, quota, file management may be more involved than expected. | Medium | Low | Explore in Architecture Overview session; fall back to simple URL linking if API proves too complex for MVP. |

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Problem statement | Data scattered across paper/spreadsheets at new mine site; need centralized digital system | New site opening, data-loss risk, KPI obligation | — |
| 2 | Users & stakeholders | Supervisor (full access), Foreman (field + office data entry), Crew (view-only) | Matches actual team structure; crew don't need write access | Other departments deferred; role model must be extensible |
| 3 | Success criteria | Adoption in 2 weeks, report time < 30 min, zero missing data days, fewer errors, KPI delivered | Measurable, tied to real pain points | Qualitative error metric is imprecise but acceptable for MVP |
| 4 | Core capabilities | All listed features in MVP, internally tiered (daily ops → tracking → reporting) | Everything is needed, but tiering ensures critical pieces ship first | If Tier 3 slips, timeline/notifications/PDF come post-launch |
| 5 | Non-goals | Deferred: auto-imports, multi-site, BI, other depts, full offline. Never: public access, replace Drive | Keeps MVP achievable for solo evening dev | Multi-site deferred means data model must still allow it |
| 6 | Constraints | Solo/evenings, Flutter+BLoC, Supabase free tier, Drive API, multi-site-ready model, zero budget | Non-negotiable stack + realistic timeline | Paid third-party enterprise tools |
| 7 | Assumptions | ~100 users, cloud Supabase, smartphones available, Drive in use, greenfield | All reasonable for a single-team MVP | Each has a "if wrong" fallback identified |
| 8 | Risks & open questions | Timeline, offline sync, free tier, bus factor, Drive API | Biggest risk is timeline; mitigated by tiering | Zone structure, sync strategy, notification UX resolved in-session |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| OQ-1 | Google Drive API integration details — auth flow (service account vs. OAuth), upload UX, quota management | STEP-1.3 | Architecture Overview |
| OQ-2 | Offline sync edge cases — what happens when two foremen edit the same record offline? (Likely rare given crew assignment, but needs a defined behavior) | STEP-1.3 / 1.4 | Architecture Overview / Data Model |
| OQ-3 | Report template details — exact fields, groupings, and layout for each report type | STEP-1.7 | UI / Design System |
| OQ-4 | Notification trigger rules — specific thresholds for attendance, inventory low stock, timeline milestones | STEP-1.4 / 1.7 | Data Model / UI |
| OQ-5 | Zone/category management — can foremen add zones, or only supervisors? | STEP-1.4 | Data Model |
| OQ-6 | Benchmark DB — exact table structure? (User has this ready) | STEP-1.4 | Data Model |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.1 | Initial draft from System Overview session |
| v0.2.0 | 2026-07-21 | STEP-1.1 | Updated Scope with Phase 2 Tier 2 features, Bugfixes, QoL, and zero-budget constraint |
