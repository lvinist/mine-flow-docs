# STEP-55 authorized follow-up correction — 2026-10-08

**Status:** In progress. This report supersedes only the explicitly corrected follow-up claims below; it does not reopen the owner's conditional STEP-55 close or claim a new release gate passed.

## Authority and baseline

- Resume source: Hermes session `20261008_010201_de8257`.
- Owner previously authorized all four follow-up lanes: RISK-0025, production migration/type generation, staging zone seed, and bounded attendance OS restoration.
- Current owner decisions: complete attendance restoration and its route wiring (date, status, reason, restart/save regression tests); leave other features out of scope. Correct production/seed records, keep production deployment blocked, and do not alter applied migration history.
- App baseline: `0dbe3b3edc7a212cbed4f59fdaacc92cf7102b2c`, synchronized with the feature-branch upstream at initial inspection.
- Docs baseline: `5316cc4`; prompts baseline: `4cd928a`.
- Pre-existing dirty localization generated files are byte-identical to HEAD after CRLF/LF normalization. They are preserved, not treated as functional changes. The dirty RISK-0025 closure is inherited from the resumed session and requires correction before publication.

## Confirmed corrections

### Current-head gate is red

GitHub run [37707666304](https://github.com/lvinist/mine-flow-app/actions/runs/37707666304) is for the exact baseline head and completed with Android E2E failure. Web E2E, lint/analyze/tests, and APK smoke build succeeded; deployment jobs were skipped. Historical green run `37682414334` belongs to `6e0b2e2`, not the current head.

The prior session's `step56-full-ci-shape.log` ends with **22 passed, 2 skipped, 1 failed**, failing the equipment filter-panel interaction. Thus the claim that commit `0dbe3b3` resolved the failure is not established. The route-opacity explanation and retry comments must be re-derived from the actual interceptor rather than repeated as fact.

### Attendance restoration evidence was insufficient

`attendance_form_sheet_restoration_test.dart` merely entered text and checked its visibility; it never called `restartAndRestore` or restored a captured bucket. It cannot prove registration or restoration. The pinned go_router 18 documentation requires a restorable shell page, shell/branch scopes, and restoration IDs on custom pages; the baseline only set the top-level MaterialApp and GoRouter IDs. Restorable text must also be reconciled with the BLoC draft that Submit actually saves, including the dirty state and explicit clears.

### Production deployment was not completed

A fresh `supabase projects list` exposed one accessible project, `rpdnonpivoyhghzolyzv`, identified by the project environment contract as staging. This is not evidence of a separate production deployment. The workflow's production job builds web/APK with `PROD_*` secrets; it does **not** provision a database or run migrations. The prior session's statement that the release workflow automatically applies migrations to future production is false.

**Owner disposition:** production migration/deployment remains blocked pending an identified production target and a reviewed deployment procedure. Do not retarget the staging link or publish a release as part of this correction.

### Staging seed is present but its intended round-trip was not proven

Read-only linked verification found exactly one expected seed row (`6e60b2e2-0000-4000-8000-000000005656`, site `f47ac10b-58cc-4372-a567-0e02b2c3d479`, name `Pit Alpha`) and zero daily-log rows referencing that seed ID at inspection. The journey only typed the name and optionally clicked an Add tile; it did not select an existing match or assert the seeded zone ID. A pass with an absent zone is not proof of this lane's acceptance criterion.

`20261008000001_step_56_staging_zone_seed.sql` is in the general migration chain and has no environment guard. Its comment that it cannot affect production is incorrect: applying the migration to a future production database would insert the test row. The original STEP-56 draft called for a dedicated staging-only seed artifact. **Owner disposition:** preserve applied history, record this as a production blocker, and require seed isolation review before applying that chain to production. No policy change granting foreman zone creation is authorized.

### Security and type-generation facts reverified

Read-only linked inspection confirms `guard_users_self_update` is enabled and invokes the committed allow-list function. Migration history lists `20260913000001`, `20261004000001`, `20261006000001`, and `20261008000001` as applied on staging. This does not by itself prove every live authorization behavior or any production state.

Fresh `supabase gen types --lang typescript --linked` exited 0 and produced **27,091 bytes**, SHA-256 `b526fed5545105f5dc99523ee419bb02f979e158133f2bfb57aa88c4f2942bd4`, byte-identical to committed `supabase/types/database.ts`. No fabricated generated-file change is needed.

## Evidence location

Local raw evidence for this correction is under `C:/Users/Alpxalpha/AppData/Local/hermes/cache/scratch/resume-de8257/`: baseline hashes, exact-head run/job JSON, read-only staging SQL and result, actual regenerated type artifact, and diagnostic/test logs. Scratch is not a durable artifact store; final measured results will be summarized here before completion.

## Pending verification

- Root-cause reproduction and minimal fix for equipment filter interception.
- Genuine attendance restart/restore/save tests, scoped by authenticated user/site/date.
- Seeded-zone selection and live daily-log round-trip, without zone policy changes.
- Focused and broad local gates; exact-head CI after an authorized commit/push.
- Reconcile the risk register and STEP index with final evidence and retained production blockers.

## Verified results (2026-10-08, resumed session)

The interrupted session (`20261008_181311_d59ff1`) left the attendance restoration lane half-landed; this continuation completed and verified it.

### Equipment filter interception — root cause confirmed and fixed

The true root cause was the shared `AppResponsiveSheet.onPopInvokedWithResult` **ignoring `didPop=true`**: after a successful save, the programmatic pop re-entered the dismissal guard with the previous frame's dirty value, opening an orphan `AppDirtyDismissDialog` whose modal barrier then absorbed the equipment history filter taps (run `37707666304`'s failure). The route-opacity explanation from the earlier session was wrong — the fixed primitive removes the orphan dialog, so no barrier race exists.

- RED→GREEN proven: 4 probe tests (dirty→orphan dialog, clean→double-pop; both layouts) failed on the old primitive, then passed after the fix.
- `test/app/router_restoration_test.dart` pins the production shell contract (go_router 18.0.1 requires shell + branch `restorationScopeId`s; a hand-rolled `CustomTransitionPage` must set `restorationId: state.pageKey.value` to match the default platform page, or the page subtree is excluded from restoration data).
- `integration_test/journeys/equipment_check_journey_test.dart` cleaned: `[RESUME-DIAG]` instrumentation and `flutter/rendering.dart` import removed; the barrier-wait saga and `tapUntilEffect` retry loop replaced by a bounded poll for form teardown + hard `expect`, an `AppDirtyDismissDialog` findsNothing assertion, and a single filter-button tap; serial and both remarks made unique per run (`GNSS-E2E-<µs>`) so concurrent CI legs sharing staging cannot cross-match prior-run rows.
- Unpushed heads carry no CI evidence; the Android E2E leg for this fix remains **Unverified until the lane's commit/push lands and a run completes at the new head**.

### Attendance restoration — implementation completed and locally verified

- `attendance_draft_restoration.dart` (new): versioned JSON snapshot of editable values only (status + remarks per crew), decoding rejects malformed/incompatible data; authorization and roster identities are reloaded, never restored.
- `AttendanceFormRestoreRequested` event + `_onRestoreRequested` handler: reloads the current site's roster baseline before applying restored values; unknown crew IDs cannot manufacture rows.
- Sheet `RestorationMixin` captures the draft as one `RestorableStringN` snapshot (controller text alone is not authoritative for Submit validation, date, or the dirty guard); restoration defers until the roster loads.
- Router: `restorationScopeId` added to the shell (`app-shell`) and all five branches (`branch-dashboard/tools/operations/teams/settings`); attendance form's `CustomTransitionPage` now sets `restorationId: state.pageKey.value`.
- Tests: `router_restoration_test.dart` (2) proves URL + sheet + unsaved draft survive `tester.restartAndRestore()` (go_router's own process-death simulation; `restoreFrom` into a surviving State is not equivalent and trips go_router's one-time branch registration). `attendance_form_sheet_roundtrip_test.dart` (8) covers encode/decode round-trips, dirty/clean, explicit clears, restore-failure fallthrough.

### Local gates (fresh runs at this session's tree)

| Gate | Result |
|---|---|
| `flutter analyze` (whole repo) | No issues found |
| Focused suite (8 files incl. attendance, equipment, sheet, router restoration) | **88 passed, 0 failed** |
| `dart format` on all touched files | clean |
| EOL audit | all touched files match HEAD convention (router.dart stays CRLF, others LF); the prior session's l10n CRLF reflow (pure EOL churn, `git diff -w` empty) was normalized back — l10n files are byte-identical to HEAD |

### Known gaps (retained, not claimed)

- Android/web E2E for the equipment journey and the attendance restoration behavior is **Unverified** until commit/push and a CI run at the new head; nothing has been committed or pushed in this continuation.
- The other 15 hand-rolled `CustomTransitionPage`s in `router.dart` still lack `restorationId`; out of this lane's scope (only the attendance route was owner-authorized) — flagged for the owner as a follow-up sweep.
- Seeded-zone round-trip (STEP-56 lane), RISK-0025 production rollout, and production migration remain open per the owner dispositions above.
