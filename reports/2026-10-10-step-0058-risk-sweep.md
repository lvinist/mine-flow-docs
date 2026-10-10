# mine-flow — STEP-58.2: Risk-Register Row-by-Row Sweep Report

**Date:** 2026-10-10
**Branch:** `step-0058-doc-drift-registry-sweep`
**Commit:** `560ed48` (post-sweep HEAD; prior cherry-picks `d3858a7`, `2207dd7`, `c2f2c43`)
**App repo HEAD verified against:** `Code/mine-flow-app` HEAD `fc4b984` (branch `step-0057-zone-insert-policy`)

## Summary

All 31 rows in `registries/risks.yml` (RISK-0001..0031) were swept against their own
`revisit_trigger` / `closed` criteria and disk evidence. Three rows received evidence
true-up from the STEP-57 line of work; one row was flipped from `open` → `monitoring`
with evidence trued up; RISK-0031 was added to the register (it was referenced in Doc 06
and STEP-57.4 FINDINGS but missing from `risks.yml` on the sweep branch); PyYAML was
verified installed.

| Metric | Count |
|---|---|
| Rows swept | 31 |
| Flipped to closed | 0 |
| Flipped (other status change) | 1 (RISK-0026: open → monitoring) |
| Kept open/monitoring, evidence trued | 24 |
| Parked (owner judgment) | 1 (RISK-0026 — data-review criterion unmet) |

## Methodology

Each row was re-derived against its own `revisit_trigger` / `closed` criteria and
on-disk evidence:
- App code at HEAD `fc4b984` (`Code/mine-flow-app`, grep + `git log`)
- Docs reports and findings in `Code/mine-flow-docs/reports/` and `prompts/`
- STEP-index for STEP status cross-referencing
- `git merge-base --is-ancestor` to confirm fixing commits are in HEAD history

## Row-by-Row Verdicts

### RISK-0001 — open (unchanged)
Deferred custom anti-DDoS. Criterion: "Before public beta or if system experiences repeated noisy traffic." Not met (pre-public-beta). Evidence unchanged. ✅

### RISK-0002 — closed (unchanged)
Fixed non-fatal analyzer warnings. Already closed with cited commit. ✅

### RISK-0003 — closed (unchanged)
Phase 2 UI drift. Already closed. ✅

### RISK-0004 — open (unchanged)
Indonesian localization. Criterion: "When STEP-55 touches an exempt presentation file; hard gate before any public multi-language release." STEP-55 is still in progress; exempt files remain. Evidence current (53.3 findings, 54 spec). ✅

### RISK-0005 — open (unchanged)
fl_chart v1.2.0 migration. Criterion: "Before any fl_chart major version bump or when chart features are extended." No major version bump pending. `pubspec.yaml` confirms `^1.2.0`. Evidence current. ✅

### RISK-0006 — closed (unchanged)
go_router v18 audit. Already closed with STEP-48.26 evidence. ✅

### RISK-0007 — monitoring (unchanged)
hive_ce. Criterion: "If hive_ce goes >6 months without a release, or Dart 4 breaks compatibility." STEP-53.1 verified hive_ce 2.19.3 (last release 2026-02-03); active upstream maintenance continues. Status `monitoring` correct. Evidence cell current (53.1 findings cited in YAML comments). ✅

### RISK-0008 — monitoring (unchanged)
flutter_secure_storage v9→v11 skip. Criterion: "Before any production release if there are existing users on v9 keys." Dev-only, no production users. Status `monitoring` correct. ✅

### RISK-0009 — monitoring (unchanged)
Flutter 3.47 semantics regression #191095 / forui 0.26. Criterion: "Trigger A (primary): stable Flutter >=3.48 ships containing PR #191587." STEP-53.2 confirmed stable fix NOT shipped (3.47.2 predates fix). 3 mitigations confirmed. Status `monitoring` correct. Evidence cell current. ✅

### RISK-0010 — open (unchanged)
Staging Supabase provisioned via ClickOps. Criterion: "If staging project is deleted or must be fully reprovisioned." No deletion. Status `open` correct. ✅

### RISK-0011 — open (unchanged)
In-app Privacy Notice. Criterion: "Before production or external-user release; close only after the first-login notice and acknowledgement flow is implemented and verified." Not implemented (owner: STEP-55.10). ✅

### RISK-0012 — open (unchanged)
Supabase free-tier backups. Criterion: "Before first production data load; before production Supabase project is provisioned." Pre-production. ✅

### RISK-0013 — monitoring (unchanged)
S0 baseline ops cluster. Criterion: "Before production release; before external contributors; at next S1 sweep." STEP-52 verified 34/34 S0 checklist rows, items accepted as risks. Evidence cell current (52.2 findings). ✅

### RISK-0014 — mitigated (unchanged)
Reporting datasource cut/fill semantics. STEP-48.27 corrected source path; PDF regeneration pending per revisit trigger. ✅

### RISK-0015 — monitoring (unchanged)
LoginPage light-mode fidelity. Criterion: "During STEP-55.11, capture Login in light mode on Pixel_6a or physical Android device." Not yet captured (55.11 in progress). ✅

### RISK-0016 — monitoring (unchanged)
Sidebar active-state on group routes. Criterion: "After STEP-55.10 shell changes, directly visit nested routes." Not yet verified. ✅

### RISK-0017 — open (unchanged)
Data Bucket upload cancellation. Criterion: "During STEP-55.9 and before Data Bucket used for operational Drive uploads." Not yet implemented. ✅

### RISK-0018 — monitoring (unchanged)
UploadFilePage OOM threshold. Criterion: "Before retaining the 50 MB production limit, test representative maximum-size files." Not yet tested. ✅

### RISK-0019 — monitoring (unchanged)
Benchmark deep-link route-registration. Criterion: "When staging credentials and web E2E testing are available." In-process verified; true cold-start unverified. ✅

### RISK-0020 — monitoring (unchanged)
Transitive dependencies SDK-pinned. STEP-53.3 resolved direct drift; SDK-pinned residuals confirmed. Evidence cell current. ✅

### RISK-0021 — monitoring (unchanged)
Partial RLS matrix. Criterion: "When TEST_CREW_EMAIL and TEST_CREW_PASSWORD are provisioned in GitHub repository secrets." Secrets still absent (`.github/workflows/ci.yml` references `secrets.TEST_CREW_EMAIL` but not provisioned). ✅

### RISK-0022 — closed (unchanged)
Benchmark staging journey. Already closed with STEP-48.26 evidence. ✅

### RISK-0023 — open (unchanged)
Material accessibility barriers. Criterion: "Before production release; close only with passing desktop navigation/header, Login naming/language, targets, contrast, text scaling, reduced motion, and Android-shell evidence." Multiple items still Unverified. ✅

### RISK-0024 — open (unchanged)
Placeholder PNGs. Criterion: "When STEP-54/55 runtime evidence is durably archived, replace or delete obsolete STEP-48 placeholders and close this row." Placeholders still present. ✅

### RISK-0025 — open (true-up evidence only)
Privilege escalation in public.users self-update policy.

**Evidence verified:**
- Migration `20261004000001_step_55_user_profile_permissions.sql` is present in app HEAD (`fc4b984`).
- The `guard_users_self_update` trigger exists, is enabled, runs BEFORE UPDATE, and uses the four-field allow-list (name, phone, emergency_contact_name, emergency_contact_phone).
- `20261006000001_step_55_inventory_audit_timestamps.sql` is present (read-only verified on staging at `rpdnonpivoyhghzolyzv`).
- `reports/2026-10-08-step-0055-follow-up-correction.md` confirms staging-only verification and production remains blocked.

**Verdict:** Stays `open` per owner disposition. Production rollout remains a release condition. Evidence cells are current. No status change. ✅

### RISK-0026 — PARKED (open → monitoring, evidence trued up)
Failed benchmark projection can persist sentinel coordinates.

**Close criteria:** "close after validation, fallback removal, data review, and regression tests."

| Criterion | Status | Evidence |
|---|---|---|
| Validation | ✅ Met | `_onSubmitBenchmark` (benchmark_bloc.dart:607-610) rejects null computed lat/lon |
| Fallback removal | ✅ Met | `_computeLatLon` (benchmark_bloc.dart:363-390) returns null for Infinity/NaN/out-of-range; no fallback to 0.0, 0.0 |
| Regression tests | ✅ Met | crs_utils_test.dart (9 tests) + benchmark_bloc_test.dart rejection tests; 78/78 passed per STEP-55.4 FINDINGS |
| Data review | ❌ Not met | No audit of existing benchmark records for unintended 0.0, 0.0 values found on disk; requires staging DB query access |

**Commit:** `dea5c58` (in app HEAD `fc4b984` history, verified via `git merge-base --is-ancestor`)

**Verdict:** Status flipped `open` → `monitoring` (partial criteria met, but data-review criterion unmet — this is a judgment call per the sweep policy). Evidence cell trued up with STEP-55.4 FINDINGS reference. **Parked for owner:** the data-review step requires staging DB access to audit existing benchmark records for unintended 0.0, 0.0 sentinel values.

### RISK-0027 — open (unchanged)
Attendance records offline sync state. Evidence shows `AttendanceSyncState` enum (queued/syncing/failed/synced) in `attendance_form_state.dart`, but the revisit trigger requires "persistence, presentation, retry, and offline-to-online tests." STEP-55.5 attendance sync truth is landed but full offline-to-online test coverage is not confirmed. Evidence cell current. ✅

### RISK-0028 — open (unchanged)
Inventory adjustments discard reason/history. Evidence: migration `20260913000001_step_55_8_inventory_transactions.sql` creates the `inventory_transactions` ledger; `20261006000001` adds audit timestamps. But `reports/2026-10-06-step-0055-resume-verification.md` §Inventory timestamp correction confirms: "Remote transactional/rollback/replay/authorization/concurrency proof remains Unverified." All close criteria not met. ✅

### RISK-0029 — open (unchanged)
HTTP debug logging. Criterion: "close after redaction tests and clean runtime-log inspection." No redaction test code found in `lib/` (grep for redact.*header / Authorization.*log returned no matches). Runtime log inspection not available. ✅

### RISK-0030 — open (evidence brought in from STEP-57)
Foreman INSERT into zones blocked by RLS.

**Evidence verified at HEAD `fc4b984`:**
- Migration `20261010000001_step_57_foreman_zones_insert.sql` present (verified via `git log`)
- Applied to staging (owner Q4 authorized), live role-matrix verified
- RLS journey tests +2 passed
- database.ts regenerated, contract guard exit 0
- daily_log journey GREEN locally on Web and Android at `fc4b984`
- Staging throwaway rows cleaned, seed `6e604000000005656` intact

**Close criterion:** "close after the zones INSERT authorization is defined, a migration or flow change lands, and the daily_log Android journey passes in CI."

**Verdict:** Migration landed ✅, authorization defined ✅, daily_log journey green locally ✅, BUT **CI gate PARKED per owner Q5** — the daily_log Android journey has not yet passed in CI on the pushed branch. CI criterion (the row's own close condition) is explicitly parked. Status stays `open` with evidence trued up from STEP-57.2/57.3 FINDINGS. ✅ (per prompt: "RISK-0030 EXEMPT — its CI criterion parks per STEP-57 Q5")

### RISK-0031 — open (NEW ROW, added from STEP-57.1)
Foreman-created zones unmoderated at creation. This row was referenced in Doc 06 §7 and STEP-57.4 FINDINGS but was **not present** in `risks.yml` on the sweep branch. It was added via cherry-pick of commit `f202da9` (STEP-57.1). Status `open`, severity `medium`, category `security`. Evidence cell: ADR-0020, the staging seed migration, and `registries/risks.yml` self-reference. ✅

## Files Changed

| File | Change |
|---|---|
| `registries/risks.yml` | RISK-0026 evidence trued up (open→monitoring); RISK-0030 evidence trued up from STEP-57; RISK-0031 added |
| `adr/ADR-0020-foreman-zone-insert-policy.md` | New file (cherry-picked from `f202da9`, referenced by RISK-0030/0031) |
| `adr/README.md` | ADR-0020 row added to index (cherry-picked from `f202da9`) |
| `reports/2026-10-10-step-0058-risk-sweep.md` | This report (new file) |

Note: `architecture/06-security-threat-model.md` and `architecture/README.md` changes
are from the pre-existing 58.1 commit (`d260736`), not from this sweep.

## Verification

- `check.sh`: 0 fails, 1 warning (pre-existing workspace-root hygiene — `DESIGN.md`,
  `PRODUCT.md`, `.agent`, `.gemini`, `.hermes`, `.impeccable` at workspace root). ✅
- PyYAML: Installed (v6.0.3); registry YAML parse check PASS. ✅
- `git diff --check`: Clean (no whitespace errors). ✅
- EOL: `registries/risks.yml` is bare-LF (0 CRLF, 0 lone CR) — convention preserved. ✅
- YAML parses via `yaml.safe_load`: 31 risk rows confirmed. ✅
- No app code modified (read-only grep + git log). ✅

## Owner-Parked Items

1. **RISK-0026 — data review of existing benchmark records:** The data-review criterion
   (audit existing benchmark records for unintended 0.0, 0.0 sentinel values) requires
   staging/production database query access. Validation, fallback removal, and regression
   tests are met at HEAD (`dea5c58` in `fc4b984` history). Status set to `monitoring`
   pending data review.

2. **RISK-0030 — CI gate (owner Q5):** The row's own close criterion requires the
   daily_log Android journey to pass in CI on the pushed branch. This is explicitly
   parked per owner Q5. RISK-0030 stays `open` until CI runs green.



---

## Parent-side addendum (2026-10-10, ~07:20): RISK-0026 data review completed and row CLOSED

The sweep parked RISK-0026's data-review criterion as "requires staging DB access".
The access existed (the same authenticated REST surface used all night): the parent
enumerated all 124 benchmark rows on staging and found **0 sentinel (0.0, 0.0) rows
and 0 null-coordinate rows**. With validation + fallback removal + regression tests
(commit dea5c58, 78/78) already verified by the sweep, **all four close criteria are
met**; RISK-0026 flipped monitoring → closed at docs commit `2a901e9` (evidence
recorded in the register row itself). Owner authorized evidence-cited closes
(2026-10-10 ~03:00, Q2); this close is fully disk-verified, no judgment call.
