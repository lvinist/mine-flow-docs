# ADR-0014: Persist CRS Identifier on Cut/Fill Records

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/04-data-model.md
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-033)

## Context
STEP-46.3 (CF-033) found the cut/fill form lets the operator pick a CRS (UTM
zone / datum) for their Northing/Easting coordinates, but the selected CRS is
never persisted — the schema has no `crs_identifier` column, so the survey data
is not reproducible (coordinates without a coordinate reference system are
ambiguous).

## Decision
1. **Add a `crs_identifier` column** to `cut_fill_records` (migration) and thread
   it through the model, entity, form state, and sync contract.

## Consequences
- **Implementation status: decision locked, implementation pending.** This is a
  schema change requiring a Supabase migration plus a contract update; it is
  intentionally sequenced separately from the UI remediation already landed in
  STEP-46.4, to avoid breaking the Supabase contract guard mid-step.
- Existing rows will need a default/backfill value (e.g. the project default CRS)
  or the column is nullable with a fallback at read time.
- The benchmark form already persists CRS; this aligns cut/fill with that
  precedent.
