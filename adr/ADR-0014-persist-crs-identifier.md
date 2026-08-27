# ADR-0014: Persist CRS Identifier on Benchmark Records

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/04-data-model.md
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-033)

## Context
STEP-46.3 (CF-033) found the benchmark form lets the operator pick a CRS (UTM
zone) for their Northing/Easting coordinates, but the selection lives only in
transient form state and is never persisted. The `Benchmark` entity has no CRS
field, so on edit the lat/lon are re-derived from a hardcoded default
(`UTM Zone 51S`) instead of the CRS the surveyor actually used — silently
rewriting coordinates. A UTM N/E pair without its zone is ambiguous.

## Decision
1. **Persist `crsIdentifier` on the `Benchmark` entity** (default `UTM Zone 51S`
   for new records), thread it through `BenchmarkModel` (snake_case `crs_identifier`
   for Supabase JSON + `crsIdentifier` for Hive), seed it on edit, and store it
   on save so reopening re-derives lat/lon from the stored CRS.

## Consequences
- Implemented in the entity, model (JSON + Hive), and `BenchmarkBloc`
  (`_onEditBenchmark` reads the stored CRS; `_onSubmitBenchmark` persists it).
- **Open follow-up:** the `benchmarks` table is absent from the committed
  Supabase schema (`supabase/migrations` and `supabase/types/database.ts`), so
  the remote column `crs_identifier` is not yet migrated. The model already
  emits `crs_identifier` in `toJson()`, so the column only needs the table's
  migration to be reconciled (a separate gap, tracked separately from CF-033).
- Local (Hive) records round-trip the CRS correctly today.
