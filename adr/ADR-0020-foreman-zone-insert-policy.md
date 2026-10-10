# ADR-0020: Foreman Zone-Insert Policy (Site-Scoped, Server-Authoritative)

**Status:** Accepted
**Date:** 2026-10-10

## Related documents
- architecture/06-security-threat-model.md
- architecture/04-data-model.md
- `Upcoming Prompts/mine-flow-STEP-57.1-PROMPT.md` (owner gate)
- `Upcoming Prompts/.step56-60-overnight-orchestration-state.md` §Owner decisions (2026-10-10, ~02:20)
- `Upcoming Prompts/mine-flow-STEP-57-PLAN.md`
- `supabase/migrations/20260718000002_rls_policies.sql` (existing zones policies)
- `registries/risks.yml` RISK-0030, RISK-0021
- `lib/features/daily_log/presentation/widgets/zone_picker.dart` (client creation surface)
- `lib/features/zone/presentation/bloc/zone_cubit.dart`
- `lib/features/zone/data/repositories/zone_repository_impl.dart`
- `lib/core/offline/sync_queue_manager.dart` (`_defaultSupabaseSync`, no zone-specific handler)
- `adr/ADR-0005-role-based-access-control-via-rls.md`

## Context
RISK-0030: the Android daily-log journey's inline zone `CreatableCombobox` fails because
foreman INSERTs into `public.zones` are refused by RLS (PostgrestException 42501). The
queued sync mutation lands via `SyncQueueManager._defaultSupabaseSync` (there is no
zone-specific sync registrar — zones fall through to the default upsert path at
`sync_queue_manager.dart:195`), which calls `client.from('zones').upsert(payload)`
(`sync_queue_manager.dart:262`). Because `upsert` performs `INSERT .. ON CONFLICT DO
UPDATE`, the foreman also needs `UPDATE` privilege on the row they create — not just
`INSERT`. Approach A (idempotent staging seed, migration `20261008000001`) unblocks the
FK target for E2E testing, but the product path — a foreman creating a new zone inline
while filing a daily log — stays broken until an INSERT policy exists.

The owner pre-answered the design gate on 2026-10-10 (~02:20), recorded in the
orchestration state file §Owner decisions. This ADR records those answers as the
Accepted decision rather than inferring them.

**Client-side creation surface (verified at app HEAD):**
1. `zone_picker.dart:121` — `onCreateNew: (name) => _handleCreateZone(context, name)`
2. `zone_picker.dart:178-185` — `_handleCreateZone` calls `ZoneCubit.createZone(name, siteId)`
3. `zone_cubit.dart:89-106` — `createZone` builds a `ZoneEntity` with client-generated UUIDv4,
   `siteId` (defaults to `defaultSiteId`), `name`, `category=null`, `description=null`,
   `createdAt`/`updatedAt` = `DateTime.now()`; persists via `repository.saveZone`
4. `zone_repository_impl.dart:43-57` — `saveZone` writes to local Hive, then calls
   `syncQueueManager.enqueueMutation(entityType: 'zones', action: SyncAction.update,
   payloadJson: model.toJson(), timestamp: model.updatedAt ?? DateTime.now())`
5. `sync_queue_manager.dart:225-262` — `_defaultSupabaseSync` executes `client.from('zones').upsert(payload)`
   (LWW-conflict check on `updated_at` precedes the upsert)

No `created_by` column exists on the `zones` table today (schema migration
`20260718000001_core_schema.sql:58-67`). The client payload (`ZoneModel.toJson`,
zone_model.dart:39-50) carries `id`, `site_id`, `name`, `category`, `description`,
`created_at`, `updated_at`, `deleted_at` — but no `created_by`.

## Decision

The owner locked three questions on 2026-10-10 (~02:20); this ADR records them as
the accepted design:

### Q1 — INSERT WITH CHECK scope: site-scoped

Grant foremen INSERT on `public.zones` via a new RLS policy with `WITH CHECK` that
scopes to the caller's own site:

```sql
CREATE OR REPLACE FUNCTION public.current_user_site_id()
RETURNS UUID AS $$
    SELECT site_id FROM public.users WHERE id = auth.uid() AND deleted_at IS NULL;
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

CREATE POLICY foreman_zones_insert ON public.zones
    FOR INSERT TO authenticated
    WITH CHECK (
        public.current_user_role() = 'foreman'
        AND site_id = public.current_user_site_id()
    );
```

- **`current_user_site_id()`** mirrors `current_user_role()` (migration 02, lines 9-12):
  `SECURITY DEFINER`, reads from `public.users` joined to `auth.uid()`.
- The `WITH CHECK` clause ensures a foreman cannot inject a `site_id` belonging to a
  different site — the database evaluates the condition against the row being inserted,
  and `site_id = public.current_user_site_id()` binds the written value to the
  authenticated user's site regardless of what the client sends.
- **Rationale:** The project is multi-tenant-ready (Doc 04 §1: "All operational entities
  include a `site_id` column to support Phase 2 multi-site"). A role-only policy (Q1
  alternative A) would allow a foreman on site A to insert a zone for site B.
- **Alternative A (role-only WITH CHECK):** rejected — leaks site isolation, future
  re-work when multi-site activates.
- **Alternative B (no WITH CHECK, INSERT unrestricted):** rejected — foreman could
  write arbitrary `site_id`, `category`, or `name` values; no defense in depth.
- **Reversibility:** Low. A new policy drop + the trigger column are additive; rolling
  back means dropping the policy, trigger, and column (no user data depends on them
  until 57.2 ships and the E2E passes).

### Q2 — Upsert/UPDATE: `created_by` column + server-side trigger + own-rows UPDATE

The offline sync upserts via `INSERT .. ON CONFLICT DO UPDATE` (via
`SyncQueueManager._defaultSupabaseSync`), so foremen need UPDATE privilege on the rows
they create. Add a `created_by UUID` column to `zones` and:

```sql
ALTER TABLE public.zones ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.users(id);

CREATE OR REPLACE FUNCTION public.zones_set_created_by()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_by IS NULL THEN
        NEW.created_by := auth.uid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER zones_created_by_set
    BEFORE INSERT ON public.zones
    FOR EACH ROW EXECUTE FUNCTION public.zones_set_created_by();

CREATE POLICY foreman_zones_update ON public.zones
    FOR UPDATE TO authenticated
    USING (created_by = auth.uid())
    WITH CHECK (created_by = auth.uid());
```

- The `BEFORE INSERT` trigger sets `created_by = auth.uid()` server-side, making the
  creator unspoofable — a foreman cannot set another user's UUID even if they craft a
  raw payload.
- The `foreman_zones_update` policy scopes UPDATE to rows where `created_by = auth.uid()`,
  so a foreman can upsert their own zones (surviving the `ON CONFLICT DO UPDATE` path) but
  cannot overwrite zones created by supervisors or other foremen. This also gives the
  audit trail for who created each zone.
- **Rationale:** Without UPDATE scoping, the `ON CONFLICT` upsert in
  `_defaultSupabaseSync` (which fires the UPDATE branch) would be refused by RLS after
  the initial INSERT succeeds — the sync item would fail on every retry. The trigger
  also closes the cross-site injection vector: even if a foreman spoofed `created_by`,
  the trigger overwrites it with `auth.uid()`.
- **Alternative A (broad foreman UPDATE without `created_by`):** rejected — a foreman
  could overwrite supervisor-created zones and the audit trail is lost.
- **Alternative B (change client sync to INSERT-only, no upsert):** rejected —
  breaks the idempotency contract of `ON CONFLICT DO NOTHING`/`DO UPDATE` used across
  all other entities (attendance, tracking, benchmark all use the same upsert path);
  introduces a special case in `_defaultSupabaseSync` that must be maintained forever.
- **Reversibility:** Low. Column + trigger + policy are additive; dropping them
  reverts to the pre-STEP-57 state.

### Q3 — Crew: foreman-only (crew stays read-only)

Crew members gain no new zone privileges. The existing `zones_read_active` policy
(migration 02, line 63-65) remains their only access to zones: READ on non-deleted
rows. No INSERT, UPDATE, or DELETE for crew.

- **Rationale:** Crew fieldside operators have no operational need to create zones;
  the product surface (`zone_picker.dart`'s `CreatableCombobox`) is only wired into
  daily-log, cut/fill, land-clearing, and benchmark forms — all foreman-facing flows.
- **Alternative A (crew can create zones with pre-approval flag):** deferred — not
  in the MVP scope; would require a moderation workflow and supervisor review queue.
- **Reversibility:** High — adding crew INSERT later is a one-line policy addition.

## Consequences
- **Easier:** Foremen can create zones inline in daily-log, cut/fill, land clearing,
  and benchmark forms — the E2E loop is unblocked. The staging seed (approach A)
  remains as a known-good FK target for test determinism.
- **Harder:** New attack surfaces: unbounded zone creation (spam), cross-site
  injection via `site_id` spoofing, category/name abuse, and offline-queue replay
  duplication. These are recorded as RISK-0031 and the Doc 06 §7 threat review.
  The `created_by` column + trigger add one column and one trigger to the `zones`
  table — trivial overhead.
- **New risk:** Foreman-created zones are unmoderated at creation time; supervisors
  must review them via a future UI (RISK-0031 revisit trigger).
- **No code change in this STEP:** this ADR is design-only. The migration, trigger,
  and policies ship in STEP-57.2 on staging (owner-authorized per Q4).
