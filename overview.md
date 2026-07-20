# mine-flow — Project Overview

<!-- PROJECT-STATUS: kickoff-complete -->
<!-- ^ Kickoff gate (do not delete this line). `init.sh` seeds it as "not-started". The agent
     flips it to "kickoff-complete" at the end of the bootstrap (BOOTSTRAP-PROMPT.md). While it
     reads "not-started", opening this project in an AI agent starts the kickoff interview
     automatically; once "kickoff-complete", agents resume from prompts/STEP-index.md instead. -->

## In one sentence
An internal mining operations dashboard that lets site supervisors, foremen, and crew track
cut/fill volumes, land clearing progress, crew attendance, work timelines, daily logs,
inventory, and geospatial data — all from a single cross-platform app.

## The problem
Mining site operations generate a constant stream of data — how much earth was moved, how
much land was cleared, who showed up for work, what equipment and materials are on hand —
but today this information is scattered across spreadsheets, paper logs, and people's
heads. Supervisors and project managers lack a single, real-time view of progress. When
reports are needed, someone has to manually compile data from multiple sources, which is
slow and error-prone. Geospatial data files (.shp, .tiff) sit on Google Drive with no
structured way to find what was acquired when and where.

## Who it's for
- **Supervisors** — oversee overall site operations, review all data, manage users and
  permissions, receive alerts.
- **Foremen** — manage their assigned crews, log daily progress (cut/fill, land clearing),
  track attendance and timelines for their area.
- **Crew members** — log attendance, view assigned tasks and timelines, record daily work
  entries.
- (Later: **Office staff / Project Managers** reviewing cross-site reports — deferred to
  multi-site phase.)

## What it does (core capabilities)
- **Cut/fill volume tracking** — manual entry of earthwork measurements per area/zone, with
  historical tracking over time.
- **Land clearing area tracking** — manual entry of cleared hectares/area, linked to zones.
- **Crew attendance** — daily attendance logging per crew member, viewable by foremen and
  supervisors.
- **Work timeline** — visual timeline of planned vs. actual progress for site activities.
- **Daily logging** — structured daily reports capturing work done, conditions, notes.
- **Inventory tracking** — track materials, equipment, and consumables on site.
- **Data bucket** — geospatial file (.shp, .tiff) metadata management: files stored on
  Google Drive, with location coordinates and acquisition timestamps linked in Supabase
  tables. Browse, search, and filter by location/date.
- **Notifications / alerts** — in-app alerts for key events (e.g., attendance thresholds,
  inventory low stock, timeline milestones).
- **Reports / PDF export** — generate and download formatted reports from tracked data.
- **Role-based authentication** — login with three roles (supervisor, foreman, crew), each
  with appropriate data visibility and edit permissions.
- **Equipment digital check (SOP-based)** — daily pre-work and post-work condition checks
  for survey equipment per SOP checklists. Three equipment types at launch:
  - **GNSS RTK** — Base unit (12 check items: receiver, antenna, battery, tribrach, mini
    pole, statif, roll meter, box, external antenna, external cable, external antenna
    adaptor, battery/accu) + Rover unit (6 check items: receiver, antenna, battery,
    controller, pole/stick, box). Each item has defined inspection standards.
  - **Total Station** — Main unit (16 check items: box, battery, vertical/horizontal axes,
    lenses, clamps, fine adjustment, centering system, bubble levels, adjustment screw,
    keyboard, display, distometer) + accessories (roll meter, statif, pole/stick, prisma,
    umbrella).
  - **Drone/UAV** — Drone unit (9 check items: box, body, battery, gimbal camera, lens,
    propeller, SD card, RTK module, remote controller) + support unit (5 check items: data
    cable, charger head, battery charger, preflight/postflight form, area flight plan).
  - Only **start-of-work** (Sebelum Bekerja) and **end-of-work** (Setelah Bekerja) checks
    are captured — no during-work check. Each check records pass/fail per item, equipment
    count, and optional remarks. Signed off (paraf) by the responsible person.

## What it does NOT do (for now)
- **Automated data imports** — no GPS, drone survey, or equipment telemetry integration in
  the MVP. All data is manually entered. (Phase 2: integrate with survey tools.)
- **Multi-site support** — the MVP serves a single mine site. The architecture should be
  designed so multi-site is addable later without a rewrite. (Phase 2.)
- **Advanced analytics / BI** — no predictive analytics, trend forecasting, or BI-style
  dashboards beyond basic reports. (Future.)
- **External / public access** — this is an internal tool; no public-facing features.

## Scale & shape
- **~100 users at launch**, single mine site.
- **Cross-platform app** built with **Flutter + BLoC** state management — one codebase
  targeting web, mobile (Android/iOS), and desktop. Responsive/adaptive UI (aspect-agnostic).
- **Backend: Supabase** (cloud-hosted) — Postgres database, authentication, real-time
  subscriptions, Row Level Security for role-based access.
- **Geospatial file storage: Google Drive** — heavy files (.shp, .tiff) remain on Drive;
  Supabase holds metadata (file link, location, acquisition timestamp).
- Multi-site scale (future): likely hundreds of users across several sites.

## Constraints & must-haves
- **Solo developer, side project** — 1-month target for MVP.
- **Flutter + BLoC** — non-negotiable technology choice.
- **Supabase** — non-negotiable backend choice (Postgres, Auth, Realtime, Storage).
- **Google Drive integration** — for geospatial data file storage and linking.
- **Architecture must accommodate future multi-site** — don't hardcode single-site
  assumptions into the data model.

## Sensitive data & risk
- **Personal data** — crew members' place and date of birth, national identification
  numbers. Must be protected and access-restricted.
- **Passwords** — handled via Supabase Auth; must never be stored in plaintext or exposed.
- **Operational data** — cut/fill volumes and land clearing areas are considered
  commercially sensitive and must not leak.
- Supabase Row Level Security (RLS) should enforce data boundaries per role.

## Known unknowns
- Exact structure of zones/areas for cut/fill and land clearing tracking — to be defined in
  architecture.
- How Google Drive integration works in practice (API vs. simple URL linking) — to be
  explored.
- Notification delivery mechanism (in-app only, or also push/email?) — to be decided.
- Report templates and what data each report includes — to be specified.

## Anything else
- Geospatial file formats (.shp, .tiff) are standard in mining/surveying — the app doesn't
  need to render or process them, just catalog and link to them.
- The "data bucket" concept is essentially a searchable file registry with metadata, not a
  raw object store.

## Design reference
- **Primary inspiration: [shadcn-admin](https://github.com/satnaing/shadcn-admin)** — a
  modern admin dashboard built with shadcn/ui. Key design elements to adopt in Flutter:
  - Collapsible sidebar navigation with icon + label
  - Card-based dashboard with stat summaries
  - Clean data tables with search/filter
  - Dark / light mode toggle
  - Subtle borders, shadows, and professional spacing
  - Modern typography (Inter or similar)
  - Responsive layout that works across desktop, tablet, and mobile
- The Flutter UI should replicate this **design language**, not the tech stack (shadcn is
  React/Radix — we translate the visual aesthetic to Flutter widgets).
