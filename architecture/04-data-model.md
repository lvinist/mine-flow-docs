# Doc 04 — Data Model, Ownership & Retention

**Version:** v0.1.5
**Status:** Draft <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-09-01 (STEP-48.20)
**Audience:** All contributors — this sets the entities, relationships, ownership, and retention rules.

> Defines the core entities, who owns them, how they are stored, and rules for retention and data sensitivity.

## 1. Entity Model

The following are the core entities (nouns) and their relationships:

- **User:** Represents a supervisor, foreman, or crew member.
- **Zone:** An area of the site (e.g., PIT Rusia, Soil Bank Sochi) with a category and name.
- **AttendanceRecord:** A daily log linking a `User` to their attendance status for the day. (Many-to-One with User)
- **EquipmentCheck:** Start/end of day condition logs for survey tools. (Linked to User/Foreman)
- **DailyLog:** Structured daily progress reports submitted by foremen. (Linked to User)
- **CutFillRecord:** Earthwork volume measurements. (Many-to-One with Zone)
- **LandClearingRecord:** Area cleared. (Many-to-One with Zone)
- **InventoryItem:** Materials, equipment, or consumables tracked on site.
- **GeospatialFile:** Metadata (Drive link, location, acquisition time) of survey files. (Many-to-One with Zone)
- **Benchmark:** Survey control points with known coordinates and elevations. Fields include: `id` (UUID Primary Key), `site_id`, `bm_id` (unique per site natural identifier), `northing`, `easting`, `ortho_height`, `code`, `orde`, `geom` (nullable JSON value; PostGIS is not enabled), `latitude`, `longitude`, `crs_identifier`, `ellips_height`, `status`, and soft-delete/timestamp fields. Designed to support offline creation in the field via the UUID key.
- **TimelineMilestone:** A planned-versus-actual work target for a site and optionally a zone. Fields include: `id`, `site_id`, `zone_id`, `title`, `description`, `category`, `target_value`, `actual_value`, `target_date`, `start_date`, `end_date`, `status`, and soft-delete/timestamp fields. `target_date` and `start_date`/`end_date` keep planning dates distinct from actual progress, consistent with ADR-0015's plan/actual separation.

_Identifiers:_ All entities use UUIDs (Universally Unique Identifiers) as primary keys to prevent conflicts during offline data creation.
_Multi-tenancy:_ All operational entities include a `site_id` column to support Phase 2 multi-site capability, even though Phase 1 only provisions a single site.

## 2. Ownership Table

| Entity                                                          | Owning Component             | Notes                                                                                                 |
| --------------------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| All structured data (User, Zone, Logs, Records, Metadata, etc.) | Supabase (Postgres Database) | The source of truth for structured application data. The Flutter app caches data but does not own it. |
| Geospatial Files (.shp, .tiff)                                  | Google Drive                 | Owns the physical heavy files; Supabase just holds the metadata linking to them.                      |

## 3. Storage

**Storage Choice:**
We use a single shared relational database (Supabase PostgreSQL) for all structured data, and blob/file storage (Google Drive) for heavy geospatial files.

**Rationale:**
PostgreSQL provides robust relational mapping which makes report generation and data consistency easy. Since the Flutter app directly interfaces with Supabase, this avoids the need for a custom middle-tier. Using Google Drive offloads heavy storage, avoiding Supabase's free-tier storage limits for the MVP.

## 4. PII & Sensitive Data

| Data Class                                       | Sensitivity                           | Retention & Audit                                      | Deletion                                                                               |
| ------------------------------------------------ | ------------------------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------- |
| Name, Email, Address, Gender, Emergency Contacts | Ordinary PII                          | Soft-deleted when employee leaves                      | Hard-deleted after 7-year retention period                                             |
| Crew National ID & Birthdate                     | Highly Confidential / Regulated (PII) | Soft-deleted when employee leaves                      | Hard-deleted after 7-year retention period                                             |
| Cut/Fill, Land Clearing, Benchmark               | Internal Confidential (Operational)   | Indefinite for historical reporting                    | Soft deletion via UI                                                                   |
| User Passwords                                   | Security                              | Kept until user deletes account                        | Handled automatically by Supabase Auth                                                 |
| Standard Logs & Checks                           | Internal                              | Indefinite (with audit trail: active, edited, deleted) | Soft deletion via UI (keeps history of original, edited, and deleted states for audit) |

_Audit Trail:_ All operational data supports soft deletion and edit tracking. The system maintains a history of edits (original, edited, deleted) with timestamps. By default, the app shows the latest version, but detail views display the full audit trail. Clients supply `updated_at` explicitly on every write so offline-first last-write-wins synchronization can order edits across devices; the `update_updated_at_column` trigger fills the stamp only when a write omits it (server-side backstop) and must never overwrite a client-supplied value (STEP-48.20, migration 20260901000001).

## 5. Consistency & Evolution

- **Consistency:** Eventual consistency (timestamp-based last-write-wins). Since foremen operate offline in the field, local changes are synced back to Supabase when connectivity returns. Timestamps ensure the most recent offline edit is the final state.
- **Evolution:** Schema changes will be managed through Supabase database migrations, allowing tables to evolve without data loss.

## Decision Summary

| #   | Decision           | Choice                                                    | Rationale                                                                 | Forecloses / tradeoff                                                            |
| --- | ------------------ | --------------------------------------------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| 1   | Core Entities      | Defined list (User, Zone, Attendance, etc.)               | Standardizes names for the glossary and database schema                   | N/A                                                                              |
| 2   | Ownership          | Supabase owns structured data; Drive owns heavy files     | Centralized source of truth; prevents app sync conflicts                  | Offline app is strictly a caching client                                         |
| 3   | Storage            | Relational DB (Supabase Postgres) + Google Drive          | Simplest MVP setup that supports relational reporting and avoids DB bloat | Tightly couples schema to Postgres                                               |
| 4   | Identifiers        | UUIDs                                                     | Prevents ID collisions when records are created offline                   | Slightly larger index size than integers                                         |
| 5   | PII Classification | National ID identified as regulated PII                   | Ensures proper security and retention policies are applied                | Requires a privacy/compliance check (Session 1.6a)                               |
| 6   | Retention & Audit  | 7-year retention for PII, indefinite for operational logs | Limits liability while retaining operational history                      | Indefinite retention of employee PII                                             |
| 7   | Consistency        | Eventual consistency via timestamps                       | Required for offline support                                              | Complex merge conflicts on single fields might just overwrite based on timestamp |

## Open Questions

| ID   | Question                                                                           | Owner     | Feeds into           |
| ---- | ---------------------------------------------------------------------------------- | --------- | -------------------- |
| OQ-1 | Do we need to comply with specific local privacy laws for storing the National ID? | STEP-1.6a | Privacy & Compliance |

## Version Log

| Version | Date       | STEP      | Change                                                                                                                                  |
| ------- | ---------- | --------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| v0.1.0  | 2026-07-17 | STEP-1.4  | Initial draft from Data Model session                                                                                                   |
| v0.1.1  | 2026-07-18 | STEP-1.14 | Explicitly added site_id to Entity Model                                                                                                |
| v0.1.2  | 2026-07-18 | STEP-8.1  | Enhanced GeospatialFile entity with mime_type, file_size_bytes, latitude, longitude, notes, drive_link and allowed file type constraint |
| v0.1.3  | 2026-07-21 | STEP-1.4  | Added Benchmark entity and marked as internal confidential |
| v0.1.4  | 2026-08-31 | STEP-48.17 | Added the TimelineMilestone entity and reconciled Benchmark's applied schema, including CRS persistence, soft-delete timestamps, and JSONB geom because PostGIS is not enabled |
| v0.1.5  | 2026-09-01 | STEP-48.20 | Recorded the client-supplied `updated_at` contract that offline-first LWW sync depends on; `update_updated_at_column` now fills only missing stamps (migration 20260901000001) instead of overwriting every write |
