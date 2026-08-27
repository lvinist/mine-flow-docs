# ADR-0015: Shared Date/Zone on the Land-Clearing Form

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/04-data-model.md
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-044)

## Context
STEP-46.3 (CF-044) found the land-clearing "Rencana (Plan)" and "Realisasi
(Actual)" tabs each rendered their own date picker and zone picker bound to the
same underlying fields (`clearingDate`, `zoneId`). Editing the date or zone on
the Actual tab rewrote the Plan tab's value and vice-versa, so operators could
not express a plan-vs-actual date/zone variance the model cannot hold.

## Decision
1. **Share date + zone once, in a single section above the tabs** (not per-tab).
   The Plan and Actual tabs then differ only by area (and method is likewise a
   single shared value), matching the current data model — which stores one
   `clearing_date` and one `zone_id` per record.

## Consequences
- Implemented: the date selector and zone picker are moved out of both tabs into
  a shared section above the `TabBar`; the per-tab copies are removed.
- No schema change. If a true plan-vs-actual date/zone variance is ever needed,
  a separate ADR + migration would add plan/actual date and zone columns.
