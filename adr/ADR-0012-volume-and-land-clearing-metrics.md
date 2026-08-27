# ADR-0012: Volume & Land-Clearing Metrics Correction

**Status:** Accepted
**Date:** 2026-08-27

## Related documents
- architecture/04-data-model.md
- architecture/07-ui-design-system.md
- prompts/003-release-readiness-integration-scale/step-0046/mine-flow-STEP-46.3-FINDINGS.md (CF-011, CF-013, CF-014)

## Context
STEP-46.3 surfaced three related data-correctness defects in the earthworks
reporting path. Cut/fill "net volume" was computed as `BCM − LCM`, a quantity
that is physically meaningless because bank (BCM) and loose (LCM) cubic metres
measure the same material on two different bases, not "cut minus fill". The
dashboard headline summed raw `BCM + LCM` (double-counting the same material),
land-clearing "Total" summed `plan + actual` area (a target plus its own
result), and the entity exposed misleading `totalArea`/`totalAreaHa` getters.

## Decision
1. **Volume headline is a swell-factor-derived bank-equivalent figure** (CF-011/014):
   `net = BCM + LCM / (1 + swell)`, with a **default swell factor of 25%** and a
   per-material override map (`VolumeNormalizer`). BCM and LCM are relabelled
   "Volume (BCM)" / "Volume (LCM)" to stop implying cut-vs-fill.
   - **Rationale.** Express everything on the in-situ (bank) basis; the dashboard,
     form, and summary card then all report one physically consistent number.
   - **Alternatives rejected.** Reporting BCM only (loses LCM signal); reporting
     BCM+LCM raw (double-counts); keeping `BCM−LCM` (meaningless).
2. **Land-clearing "Total" is plan-vs-actual variance in hectares** (CF-013):
   `variance = (actualArea − planArea) / 10 000`, labelled "Varians (Ha)". The
   entity getters `totalArea`/`totalAreaHa` now mean variance, not `plan + actual`.

## Consequences
- Implemented in `VolumeNormalizer`, `CutFillRecord.netVolume`,
  `LandClearingRecord.totalArea`/`totalAreaHa`, `dashboard_cubit.dart`,
  `cut_fill_bloc.dart`, and the volume/clearing summary cards.
- The reporting datasource still maps legacy `cut_volume_m3`/`fill_volume_m3`
  column names and `net = cut − fill`; that path is flagged for a follow-up
  alignment with the entity's `bcm_volume`/`lcm_volume` columns.
- Historical records produced under the old `BCM − LCM` meaning are not
  re-keyed; new records use the corrected semantics.
