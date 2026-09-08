# Doc 02 — Phasing & Roadmap

**Version:** v0.2.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-21 (ADR-0007; header version reconciled at STEP-50)
**Audience:** All contributors — defines what ships when, and what the MVP architecture must not block.

> Splits the work into phases — what the first shippable version includes, what's deliberately deferred, and the architectural constraints future phases impose on the MVP.

## Table of Contents
- [1. Phase 1 (MVP)](#1-phase-1-mvp)
- [2. Later Phases](#2-later-phases)
- [3. Phase Dependencies](#3-phase-dependencies)
- [4. Don't-Foreclose List](#4-dont-foreclose-list)
- [Decision Summary](#decision-summary)
- [Open Questions](#open-questions)
- [Version Log](#version-log)

## 1. Phase 1 (MVP)

### Goal
Give foremen and supervisors a single app to log daily operations (attendance, equipment
checks, daily logs) and track site progress (cut/fill, land clearing, inventory) —
replacing paper and spreadsheets from day one at the new site.

### In-scope capabilities

All features below belong to Phase 1. They are internally tiered as a **build order and
safety valve**: if time runs short, Tier 1 ships on schedule and Tiers 2–3 follow days
later. This is not a scope cut — the full MVP includes all three tiers.

**Tier 1 — Daily operations (build first):**
- Crew attendance logging (entered by foremen / supervisors)
- Equipment digital checks — SOP-based pre-work and post-work condition checks for GNSS
  RTK, Total Station, and Drone/UAV (see `overview.md` for item-level detail)
- Daily logging — structured daily reports (work done, conditions, notes)
- Role-based authentication (supervisor, foreman, crew)
- Offline support (field-critical) — attendance, equipment checks, and daily logs work
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

### Launch criteria

| # | Criterion | Ties to |
|---|-----------|---------|
| LC-1 | All Tier 1 features working: attendance, equipment checks (all 3 types), daily logs, auth with 3 roles, field-critical offline + sync | SC-1, SC-3 |
| LC-2 | All Tier 2 features working: cut/fill, land clearing, inventory, data bucket with Drive upload | SC-5 |
| LC-3 | At least one report type exportable to PDF (e.g., attendance report) | SC-2 |
| LC-4 | In-app notifications functional for at least equipment check reminders | SC-3 |
| LC-5 | App runs on **Android** (primary field device) and **web** (supervisor's desktop). iOS deferred. | C-2 |
| LC-6 | Supabase RLS enforces role-based data boundaries — tested | SC-4 |
| LC-7 | Supervisor can create/manage user accounts | SC-1 |
| LC-8 | Deployed and accessible to the team at the new site opening | SC-5 |

### Target platforms (Phase 1)
- **Android** — primary field device for foremen
- **Web** — supervisor's desktop browser
- **iOS** — deferred (Flutter supports it; no launch requirement)

## 2. Later Phases

> These groupings are tentative sketches. The exact scope and ordering of Phase 2 and
> Phase 3 will be refined as the MVP lands and real usage data emerges.

### Phase 2 — Impeccable-driven UI Rebuild

| In-scope item | Description |
|--------------|--------------|
| Impeccable-driven UI rebuild | Rebuild of all Phase 1 screens using Impeccable for improved UI consistency and design quality. |

### Phase 3 — Integration, Scale, Enterprise & Analytics (tentative)

> Note: The scope of the original Phase 2 (Integration & Scale) has been formally deferred to Phase 3.

**Deferred from original Phase 2 (Integration & Scale):**
| Deferred item | Why deferred to Phase 3 |
|--------------|--------------|
| Automated data imports (GPS, drone, telemetry) | Requires hardware integration R&D; MVP proves the workflow first with manual entry |
| Multi-site support | Only one site at launch; architecture accommodates it but building it now adds complexity with no user |
| Full offline for all features | Field-critical offline covers the real need; extending to everything is a large effort for low payoff |

**Original Phase 3 (Enterprise & Analytics):**
| Deferred item | Why deferred |
|--------------|--------------|
| Advanced analytics / BI dashboards | Needs historical data to be meaningful; build after data accumulates |
| Other department access (project managers, safety officers, office staff) | Different personas with different needs; expand after core team is solid |
| Rendering/processing geospatial files in-app | Specialized GIS tooling; out of scope — the app catalogs, not processes |

## 3. Phase Dependencies

### Phase 1 → Phase 2
- **UI Consistency:** The Phase 2 Impeccable-driven UI rebuild depends on the Phase 1 MVP screens and logic being completed and stable.

### Phase 2 → Phase 3
- **Multi-site** needs the single-site data model to be proven first. The MVP data model
  must include a `site_id` dimension (constraint C-5) so multi-site doesn't require a
  rewrite.
- **Automated imports** need the manual-entry workflows to be stable — you need to know
  *what* data to auto-import before building the integration.
- **Full offline** needs the field-critical offline sync to be battle-tested before
  extending to all features.
- **Analytics/BI** needs accumulated historical data from Phase 1 to be meaningful.
- **Other department access** needs stable role-based auth and a clear picture of what
  data those personas need visibility into.

### Key architectural implication
Phase 1's data model must include a `site_id` dimension even though the MVP has only one
site. This was already flagged as constraint C-5 in the System Overview.

## 4. Don't-Foreclose List

These are capabilities the MVP is *not* building, but the MVP architecture must not block.
They become constraints for the Architecture Overview, Data Model, and other sessions.

| # | Future capability | Architectural implication |
|---|-------------------|--------------------------|
| DF-1 | **Multi-site** | Data model includes `site_id`; RLS policies are site-aware; no hardcoded single-site assumptions |
| DF-2 | **Additional roles** (safety officer, project manager, office staff) | Role model is extensible (not a fixed 3-value enum) |
| DF-3 | **Automated data imports** (GPS, drone, telemetry) | Data entry layer is abstracted — manual entry and future API ingestion write to the same tables |
| DF-4 | **iOS deployment** | Flutter already covers this; don't introduce Android-only dependencies |
| DF-5 | **Self-hosted Supabase** | No reliance on cloud-only Supabase features; keep infra config portable |
| DF-6 | **Full offline for all features** | Offline sync architecture is extensible beyond field-critical subset |
| DF-7 | **Advanced analytics / BI** | Data model supports time-series queries; don't denormalize in ways that block aggregation |

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | MVP goal | Single app replacing paper/spreadsheets for daily ops and site tracking at new mine site | Captures the core value — centralized digital operations | — |
| 2 | Phase 1 scope | All three tiers (daily ops, tracking, reporting) with internal build-order safety valve | Everything is needed; tiering handles timeline risk | If Tier 3 slips, timeline/notifications/PDF follow days later — not a scope cut |
| 3 | Later phases | Phase 2: Impeccable-driven UI rebuild. Phase 3: Integration, scale, enterprise & analytics (imports, multi-site, full offline, BI, other depts, GIS). | UI consistency is prioritized before expanding feature set | Original Phase 2 integration scope is pushed to Phase 3 |
| 4 | Phase dependencies | P1→P2: stabilize screens for UI rebuild. P2→P3: prove data model, battle-test offline, accumulate data. | Each phase builds on the previous; prevents premature complexity | — |
| 5 | Launch criteria | 8 criteria covering all tiers, Android + web, RLS tested, deployed at site opening | Concrete and measurable; tied to success criteria from System Overview | iOS deferred from launch |
| 6 | Don't-foreclose list | 7 items: multi-site, extensible roles, abstracted data entry, iOS, self-hosted Supabase, extensible offline, time-series-friendly model | Keeps MVP architecture open for known future needs without building them | Adds modest design constraints (e.g., `site_id` dimension) that are worth the future flexibility |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| OQ-1 | Exact Phase 2 / Phase 3 scope and ordering — to be refined after MVP lands | User | Future planning session |
| OQ-2 | iOS launch timing — when does it become a requirement? | User | Future planning |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.2.0 | 2026-07-21 | ADR-0007 | Re-scoped Phase 2 to Impeccable UI Rebuild, deferred Integration & Scale to Phase 3 |
| v0.1.0 | 2026-07-17 | STEP-1.2 | Initial draft from Phasing & Roadmap session |
