# Doc 13 — Glossary

**Version:** v0.1.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-18 (STEP-1.13)
**Audience:** All contributors — to ensure consistent vocabulary across codebase and docs.

> Defines the precise meaning of the project's key terms, acronyms, and naming conventions.

## 1. Glossary of Terms

| Term | Definition | Notes / Not to be confused with |
|------|------------|---------------------------------|
| **Attendance Record** | A daily entry logging whether a specific user (crew member or foreman) was present for work on a given day. | |
| **Crew Member** | An on-the-ground worker who logs their own attendance, views assigned tasks, and records daily work entries. | |
| **Cut/Fill Record** | A measurement representing the volume of earth removed (cut) or added (fill) within a specific Zone. | |
| **Daily Log** | A structured daily progress report submitted by a foreman to capture work completed, site conditions, and general notes. | |
| **Data Bucket** | A searchable file registry within the app that holds metadata (such as location and time) for heavy geospatial files (.shp, .tiff), linking directly to where the files are stored on Google Drive. | Not to be confused with an AWS S3 Bucket or raw object store. |
| **Equipment Check** | A standard operating procedure (SOP) checklist completed before and after work to record the physical condition of survey tools (like drones or RTK units). | |
| **Foreman** | A user who manages assigned crews, logs daily progress (such as cut/fill volumes and land clearing), and tracks attendance for their specific area. | |
| **Inventory Item** | Any physical material, equipment, or consumable tracked on the site to monitor stock levels. | |
| **Land Clearing Record** | A measurement (typically in hectares) of the area cleared of vegetation or obstacles within a specific Zone. | |
| **Supervisor** | A user who oversees overall site operations, reviews all data across zones, manages other users, and receives system-wide alerts. | |
| **Task** | A planned activity represented on the Work Timeline. | Not to be confused with "Job", which we avoid using to prevent overlap with someone's employment role. |
| **User** | Anyone who logs into the app (Supervisor, Foreman, or Crew). | Not to be confused with "Account" or "Member", which are not used for this concept. |
| **Work Timeline** | A visual schedule that compares the planned progress against the actual progress for various site activities. | |
| **Zone** | A specific geographical area of the mine site (e.g., PIT Rusia, Soil Bank Sochi) where operational metrics and files are tracked. | |

## 2. Acronyms & Abbreviations

| Acronym | Meaning | Notes |
|---------|---------|-------|
| **PII** | Personally Identifiable Information | E.g., National IDs; requires strict privacy protection. |
| **RLS** | Row Level Security | Supabase feature used to restrict access based on user role. |
| **SOP** | Standard Operating Procedure | Defined rules/checklists for things like equipment checks. |
| **UUID** | Universally Unique Identifier | Used for database keys to prevent offline sync collisions. |

## 3. Naming Conventions

- **Database IDs**: Use UUIDs universally across the data model to prevent collisions during offline sync.
- **Roles vs. Accounts**: Always use the term `User` rather than `Account` or `Member` when referring to a person who logs in.
- **Timeline items**: Always use the term `Task` to denote work items on the timeline, avoiding `Job`.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Persona naming | Supervisor, Foreman, Crew Member, generally grouped as User | Aligns with the core data model entities and avoids overloaded words like "Account" | N/A |
| 2 | "Task" vs "Job" | Standardized on "Task" for timeline items | Prevents confusion between an employment role (job) and a scheduled activity (task) | N/A |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| | None at this time | | |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-18 | STEP-1.13 | Initial draft |
