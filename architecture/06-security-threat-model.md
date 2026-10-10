# Doc 06 — Security & Threat Model

**Version:** v0.4.0
**Status:** Draft
**Last updated:** 2026-10-10 (STEP-57.1)
**Audience:** Developers, Architects, Project Managers

> Defines the assets, trust boundaries, and minimum viable security mitigations for the mine-flow MVP.

## 1. Assets

The primary assets that must be protected in the MVP are:
*   **Personal Data:** Crew members' sensitive information (national ID numbers, place/date of birth).
*   **Credentials & Keys:** User passwords (managed by Supabase) and integration keys (e.g., Google Drive API).
*   **Proprietary Operational Data:** Commercially sensitive information including cut/fill volumes, land clearing areas, and geospatial files (.shp, .tiff).
*   **System Availability:** Keeping the dashboard and database operational to ensure daily logging is not blocked.

## 2. Trust Boundaries

The system data crosses lines of trust at these main boundaries:
1.  **Public Internet ↔ Supabase Backend:** External internet traffic interacting with our Supabase database and authentication endpoints.
2.  **Role Privilege Boundaries:** Internal privilege boundaries separating Crew, Foreman, and Supervisor data access.
3.  **App ↔ Google Drive:** Our app interacting with an external third-party service (Google Drive) to read geospatial files.

## 3. Threats & Mitigations

| Threat | Boundary | MVP Mitigation | Deferred / Blast Radius |
|--------|----------|----------------|-------------------------|
| Impersonation | Internet ↔ Supabase | Supabase Auth with strong passwords. No default shared accounts. | - |
| Data Eavesdropping | Internet ↔ Supabase | Enforce HTTPS/TLS everywhere (Supabase default). | - |
| Denial of Service (DoS) | Internet ↔ Supabase | Rely on Supabase's built-in rate limiting. | **Deferred:** Custom anti-DDoS infrastructure. *Blast Radius:* App availability could be degraded by heavy automated attacks. |
| Privilege Escalation | Role Privileges | Strict Row Level Security (RLS) in the Supabase database. | - |
| Information Disclosure | App ↔ Google Drive | Restrict Google Drive folder permissions to authorized Google Workspace accounts only. | - |

## 4. Authentication & Authorization Posture

*   **Authentication:** Supabase Auth (Email/Password or Phone/Password) will handle login verification.
*   **Authorization:** A Role-Based Access Control (RBAC) system (Crew, Foreman, Supervisor) enforced natively in the database via Supabase Row Level Security (RLS).
*   *(Note: Deep design of these flows will be covered in the conditional Identity & Auth session).*

## 5. Secrets & Data Protection

*   **Development Secrets:** Kept in a local, `.gitignore`d `.env` file. The repository only contains a safe `.env.example` template.
*   **Production Secrets:** Managed securely via the hosting platform's environment variables or a secrets manager, not in code.
*   **Data in Transit:** Secured via HTTPS/TLS.
*   **Data at Rest:** Secured by Supabase's default encryption at rest.
*   **Rotation:** Compromised or leaked secrets (e.g., Supabase service keys, Google API keys) must be rotated immediately.

## 6. Web & App Risk Posture

*   **Input Validation & Injection:** Mitigated by Flutter's built-in UI text field sanitization (preventing XSS) and Supabase SDK's secure Postgres communication (preventing SQL injection).
*   **Rate Limiting:** Mitigated by Supabase API rate limits.
*   **Dependency Vulnerabilities:** Stick to official/reputable packages (`flutter_bloc`, `supabase_flutter`) and audit them periodically for security updates.

## 7. Threat Review: Foreman Zone-Insert Policy (STEP-57.1)

> **Change class:** Security-surface design. **Code change:** none in this STEP (documentation + ADR only). **No code change** in this edit. The policy, `created_by` column, and `BEFORE INSERT` trigger ship as a new migration in STEP-57.2 (owner-authorized staging apply, Q4 of the 2026-10-10 owner decision block).
> **Decision log:** `adr/ADR-0020-foreman-zone-insert-policy.md` (Accepted, 2026-10-10). **Risk register:** `registries/risks.yml` RISK-0030 (approach A delivered), RISK-0031 (new, residual).

This section reviews the residual risks of the owner-locked foreman zone-INSERT policy before any migration is written. The owner pre-answered the three design questions on 2026-10-10 (~02:20); this review analyzes the *approved design's* residual risks honestly, not to rubber-stamp.

### v1 log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.4.0 | 2026-10-10 | STEP-57.1 | Added §7 threat review for the foreman zone-INSERT policy (ADR-0020); recorded residual risks RISK-0031. No code change. |

### Client-side creation surface (verified at app HEAD)

A foreman creates a zone inline via the `CreatableCombobox` in `zone_picker.dart:121` (`onCreateNew` → `_handleCreateZone` at line 178–185 → `ZoneCubit.createZone` at `zone_cubit.dart:89` → `ZoneRepositoryImpl.saveZone` at `zone_repository_impl.dart:43`). The repository writes to local Hive first, then enqueues a sync mutation (`zone_repository_impl.dart:51–56`: `enqueueMutation(entityType: 'zones', action: SyncAction.update, payloadJson: model.toJson())`). There is **no** zone-specific sync registrar — the queue drains fall through to `SyncQueueManager._defaultSupabaseSync` (`sync_queue_manager.dart:195, 225–262`), which executes `client.from('zones').upsert(payload)` — an `INSERT .. ON CONFLICT DO UPDATE`. The client payload (ZoneModel.toJson, zone_model.dart:39–50) carries: `id` (UUIDv4 client-generated), `site_id` (defaults to `defaultSiteId` from app_constants.dart:55), `name`, `category` (null on inline creates), `description`, `created_at`, `updated_at`, `deleted_at`. No `created_by` today.

### Threat-by-scenario analysis

| Scenario | Risk | Mitigation in approved design | Residual / unmitigated |
|----------|------|-------------------------------|----------------------|
| **Zone spam / unbounded growth** | A foreman can create unlimited zones, bloating the `zones` table and cluttering pickers. | None at creation time — the owner scope did not add a cap. | **RISK-0031.** Revisit trigger: implement supervisor zone-moderation UX or a creation-rate limit. Bounded for MVP (100-user ceiling per S0 baseline). |
| **Cross-site injection (site_id spoofing)** | A foreman on site A could try to insert a zone with `site_id` pointing to site B's UUID. | `WITH CHECK (site_id = public.current_user_site_id())` evaluates the *inserted row's* `site_id` against the authenticated user's site — the database binds the write to the caller's site regardless of client payload. The `current_user_site_id()` helper mirrors `current_user_role()` (SECURITY DEFINER, reads from `public.users`). | Neutralized for INSERT. UPDATE is scoped to own rows via `created_by`, so cross-site UPDATE is also blocked. No residual for this vector. |
| **Category abuse (client sends category NULL)** | Inline zone creation in `zone_picker.dart` / `ZoneCubit.createZone` (lines 89–106) sets `category: null` — the field is not collected from the user. | Acceptable per owner scope Q2: not a validation failure, just an unvalidated field. Supervisor visibility of category is not required for MVP. | **Low residual.** Category stays NULL for foreman-created zones; reporting that filters by category will not see them. Revisit if category-filtered reports become operational. |
| **Name collisions** | Two foremen on the same site could create two zones with the same `name`. | No uniqueness constraint on `zones.name` (schema migration `20260718000001`, lines 58–67). The client generates a unique UUID `id`, so the row is distinct; `name` is free-form. | **Low residual.** Duplicate zone names are visible in pickers and disambiguated by context. Revisit if name-based lookups replace UUID lookups. |
| **Soft-delete coherence** | A foreman deletes a zone (soft-delete via `deleteZone` → `deletedAt: DateTime.now()` enqueued as `SyncAction.delete` → `_defaultSupabaseSync` line 267: `client.from('zones').delete().eq('id', ...)`). The existing `zones_read_active` policy (migration 02, line 63–65) filters `deleted_at IS NULL` on SELECT. | No change to soft-delete path in the approved design; the existing `zones_read_active` policy applies to all roles. A deleted zone disappears from foreman/crew pickers. | **Low residual.** `daily_logs.zone_id` FK is `ON DELETE SET NULL` (schema line 128), so deleting a zone a log references nullifies the FK — acceptable data behavior. Hard-delete path (Hive local delete only) is unchanged. |
| **Offline-queue replay duplication** | The sync queue replays mutations with FIFO by `timestamp` (sync_queue_manager.dart:282). `_defaultSupabaseSync` (line 262) calls `upsert`, which is idempotent — re-submitting the same UUID `id` updates in place. The LWW check on `updated_at` (line 240–250) skips the upsert when remote is newer. | `upsert` with a client-authored UUID is naturally idempotent — the same zone row is overwritten, not duplicated. Replay of a completed mutation (queue item still pending) overwrites the same row. | **Low residual.** Risk of double-execution only if the client generates two distinct UUIDs for the same logical zone (e.g., create invoked twice offline before Hive write completes). This is a pre-existing client-side race, not introduced by the policy. The `updated_at` LWW check prevents clobbering newer server edits. |
| **Policy interplay with `supervisor_zones_all`** | `supervisor_zones_all` (migration 02, line 58–60) is `FOR ALL TO authenticated USING (current_user_role() = 'supervisor')` — permissive for supervisors. A supervisor can INSERT/UPDATE/DELETE any zone. Does this shadow the new `foreman_zones_insert` and `foreman_zones_update` policies? | **PostgreSQL RLS evaluation:** A row operation succeeds if *any* applicable policy permits it (USING for read-side, WITH CHECK for write-side). The new `foreman_zones_insert` policy applies to `authenticated` role users with `current_user_role() = 'foreman'`. A supervisor hits `supervisor_zones_all` (permissive FOR ALL) and bypasses the foreman policies entirely — this is by design. A crew member hits neither (no INSERT policy for crew) and is correctly denied. Foremen hit only their own scoped policies. There is no shadowing conflict because roles are mutually exclusive per user. | No residual. Evaluation order is explicitly: (1) supervisor → `supervisor_zones_all` FOR ALL, (2) foreman → `foreman_zones_insert` / `foreman_zones_update` scoped, (3) crew → `zones_read_active` SELECT only. The new INSERT policy is *additive* and does not relax supervisor access. |
| **`created_by` unspoofability** | A foreman could craft a raw payload setting `created_by` to a supervisor's UUID, then the UPDATE policy (`created_by = auth.uid()`) would block them. | The `BEFORE INSERT` trigger (`zones_set_created_by`, migration in STEP-57.2) forces `created_by = auth.uid()` when `created_by IS NULL`, and the policy requires `created_by = auth.uid()` on UPDATE. A foreman cannot set `created_by` to another user because the trigger overwrites it. | **Neutralized.** The trigger is the authoritative source of `created_by`. Note: if a client *explicitly* sets `created_by` to a non-null value, the trigger preserves it (guard is `IF NEW.created_by IS NULL`). The sync path via `_defaultSupabaseSync` upserts the full payload from `ZoneModel.toJson`, which does *not* include `created_by` (zone_model.dart:39–50 omits it) — so the trigger always fires and sets it correctly. |
| **Last-write-wins upsert conflict semantics** | Offline sync uses `updated_at`-based LWW (`_defaultSupabaseSync` lines 240–262). If a supervisor edits a foreman-created zone, the foreman's offline replay could clobber the supervisor's edit. | `created_by = auth.uid()` UPDATE policy blocks the foreman from touching a zone they didn't create — the upsert would be refused by RLS (42501) for rows where `created_by != auth.uid()`. The sync queue would then fail the item (retry, then fail after maxRetries). | **Medium residual.** A foreman who created a zone, went offline, and then the supervisor modified it remotely: when the foreman comes back online, their sync item fails (RLS denies UPDATE). This is *safe* (no clobber) but *noisy* (queue item goes to failed state). Revisit trigger: supervisor-zone-edit-while-foreman-offline scenario — could require a conflict-resolution UI or an auto-merge strategy. Not blocking for MVP. |

### Notes on unverified-at-HEAD items
- The `current_user_site_id()` helper is *proposed* in ADR-0020 and ships in STEP-57.2. It does not exist yet at HEAD (`20260718000002_rls_policies.sql` defines only `current_user_role()`).
- The `created_by` column does not exist on `zones` at HEAD (schema migration `20260718000001_core_schema.sql:58–67` has no such column).
- The staging apply (Q4) is authorized but deferred to STEP-57.2; no live DB changes occur in this substep.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Anti-DDoS Strategy | Rely on Supabase default rate limiting | Custom infrastructure is overkill for a 100-user MVP. | Custom fine-grained IP blocking or bot protection. |
| 2 | Authorization Enforcement | Supabase Row Level Security (RLS) | Secures data at the database layer, preventing bypassing via direct API calls. | Moving away from Supabase or Postgres RLS would require rebuilding authorization logic in a middle tier. |
| 3 | Geospatial File Access | Drive folder permissions | MVP doesn't need a complex proxy service if Google Workspace handles access control natively. | Publicly shareable map links. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| 1 | Exactly which Google Workspace accounts will have access to the Drive folder? | Product | Setup & Deployment |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.6 | Initial draft |
| v0.2.0 | 2026-08-26 | STEP-44 | S0 baseline verification complete: RLS audit clean (all 9 tables covered); account lifecycle confirmed correct; RISK-0011 (privacy notice), RISK-0012 (backup), RISK-0013 (ops cluster) added to risks register |
| v0.3.0 | 2026-09-10 | STEP-52 | S0 baseline re-check complete: RLS audit expanded to 11 tables, privilege escalation finding recorded (FINDING-52.1-01 / RISK-0025); CI secrets gap closed. |
| v0.4.0 | 2026-10-10 | STEP-57.1 | Added §7 threat review for the foreman zone-INSERT policy (ADR-0020, owner-accepted 2026-10-10); recorded residual risks RISK-0031. No code change. |
