# ADR-0013: Report Type Expansion and Reports Entry

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/04-data-model.md
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-025–CF-030)

## Context
STEP-46.3 found five "Buat Laporan …" FABs that all passed a mismatched
`ReportType` (Daily Log → attendance, Land Clearing → cutFill, Equipment →
inventory, Benchmark → inventory, Data Bucket → cutFill), so they generated the
wrong report. The `ReportType` enum only had three values (attendance, cutFill,
inventory), and the `/reports/config` route had no navigation entry and
dead-ended with "Jenis laporan tidak ditemukan" when opened without an `extra`.

## Decision
1. **Add four report types** — `dailyLog`, `landClearing`, `equipmentCheck`,
   `benchmark` — each backed by its own Supabase query and PDF table/summary.
2. **Fix the FAB mappings** to their correct types.
3. **Remove the Data Bucket report FAB** — data-bucket has no meaningful report
   type; the upload action remains the primary FAB.
4. **Give Reports a real entry**: `/reports/config` renders a report-type picker
   landing when opened without a type, and a "Reports" item is added to the
   desktop sidebar.

## Consequences
- `ReportType` gains four values (with `displayName` + `tableName`); the
  datasource, repository interface, repository impl, and `PdfService` each gain
  four corresponding methods/cases.
- Reports is now reachable from a fresh load / deep link without depending on
  another feature screen's FAB.
- The Reports entry navigates to the standalone `/reports/config` route (it does
  not yet retain the `StatefulShellRoute` chrome on the web layout); making
  Reports a first-class shell branch is a follow-up.
