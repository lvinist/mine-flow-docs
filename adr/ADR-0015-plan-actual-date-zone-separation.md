# ADR-0015: Separate Plan/Actual Date and Zone on Land Clearing

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/04-data-model.md
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-044)

## Context
STEP-46.3 (CF-044) found the land-clearing "Plan" and "Actual" tabs share a
single date field and a single zone field. A plan is authored at one time for a
future zone, while the actual clearing is recorded later (possibly in a
different zone), so collapsing them onto one pair loses the plan-vs-actual
timeline the tabs are meant to capture.

## Decision
1. **Separate the plan and actual date + zone fields** on the land-clearing
   record, so the Plan tab and Actual tab each carry their own date and zone.

## Consequences
- **Implementation status: decision locked, implementation pending.** This is a
  schema change (`land_clearing_records` gains plan/actual date + zone columns,
  or a related structure) requiring a migration + contract update, sequenced
  separately from the UI remediation to avoid breaking the contract guard.
- Until implemented, the plan and actual entries still share one date/zone pair
  (the original defect).
