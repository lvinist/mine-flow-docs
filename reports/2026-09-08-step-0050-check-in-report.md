# mine-flow — STEP-0050 Check-In Report

**Date:** 2026-09-08
**Check-in STEP:** STEP-50 (substep 50.1 — doc drift, conditional coverage, risks & security gate)
**Report path:** `reports/2026-09-08-step-0050-check-in-report.md`
**Reviewed commit(s):** mine-flow-app@`d10253d` (master), mine-flow-docs@`c1824ca` (main), prompts@`6946493` (main at review start)
**Runbook:** `runbooks/check-in.md`

> Note: the STEP-50 PLAN (authored 2026-08-29) predicted the report filename
> `2026-08-29-step-0050-check-in-report.md`. This check-in actually ran 2026-09-08,
> after STEP-48's close, and a 2026-08-29-dated report containing 2026-09-08 evidence
> would be misleading — so the report carries the actual run date per the runbook's
> `YYYY-MM-DD` naming rule.

## Mechanical pass

`scripts/check.sh` (via `./doctor.sh check`): **0 failures, 1 warning**, before and after
this check-in's edits. The warning is workspace-root hygiene: ~130 STEP-48 substep evidence
logs and scratch files (`step48*.log`, `des.tmp`, `edit_risks.js/py`, `.step48-work`, …).
Dispositions: the `step4826_r7_*.log` quartet is cited by the archived STEP-48.15 close
record as retained raw evidence, and `reports/test-results/` exists for durable test
output — the remaining logs are transient re-run debris. The 48.15 findings name the four
`step4826_r7_*` logs as the retained set; a workspace-root cleanup that preserves those
four (or moves them under a repo) is recommended at STEP-50 close. Not executed here
because the STEP-48 archive cites them at their current path.

## Drift

All 16 `architecture/NN-*.md` docs reviewed in both directions against the system as of
STEP-48's close. Docs 01, 02, 03, 05, 07, 09, 12, 16, 17 are current (04/09/12 were
reconciled by the STEP-48.15 docs-true close on this same date; the others verified
drift-free this pass). Fixes applied with Version-Log bumps:

| Area | Reviewed | Finding | Action |
|------|----------|---------|--------|
| Doc 11 Interface Contracts | vs. `supabase/types/database.ts` + `tool/check_supabase_contracts.dart` | **Docs vs. code (stale doc).** Contract of record still documented as `supabase gen types dart` → `lib/core/data/models/generated/database.dart` — a path the CLI removed (`supabase/cli#6230`) and that does not exist on disk. Real artifact: TS types at `supabase/types/database.ts` (regenerated through STEP-48.21, 845 lines), guarded by the hardened contract check. Boundary rows still "Planned". The STEP-42.2 switch was a real, un-recorded decision. | Doc fixed → **v0.3.0**; decision recorded as **ADR-0019**; app README Contract Regeneration section fixed in kind |
| Doc 08 Infrastructure & Deployment | vs. `.github/workflows/ci.yml` | **Docs vs. code (stale doc).** §2 pipeline still described the STEP-42 four-job CI; STEP-45 added `e2e-web`/`e2e-android` (ADR-0017) and `deploy-staging` now `needs: [build-android, e2e-web, e2e-android]`. | Doc fixed → **v0.2.1** (§2 reconciled with real job graph) |
| Doc 13 Glossary | vs. terms the code uses | **Docs vs. code (stale doc).** `Benchmark`, `Timeline Milestone` (both tables since STEP-48.17), `BCM`/`LCM` (ADR-0012 semantics) and `LWW` (Doc 04 §4 contract) had no glossary entries. | Doc fixed → **v0.1.1** (4 terms added) |
| Doc 15 Native App Architecture | vs. ADR-0006 + STEP-43 | **Docs vs. code (stale doc).** OQ-2 ("local DB selection: SQLite vs. Hive/Isar — STEP 2+") was resolved 2026-07-18 by ADR-0006 (Hive; migrated to `hive_ce` in STEP-43). | Doc fixed → **v0.2.1** (OQ-2 marked resolved) |
| `architecture/README.md` index | vs. doc headers on disk | All 16 rows' version/status matched after this pass's bumps; the reconciliation comment mislabeled the last reconciliation as "STEP-50 (2026-08-29)" when it was actually written by STEP-48.12 on 2026-08-30. | Index reconciled; comment corrected (now genuinely STEP-50.1, 2026-09-08) |
| `registries/repos.yml` | vs. real repo topology | Stale header note claimed "Mono-repo-for-now: entries are folders inside the single repo". The three entries are real independent repos with `github.com/lvinist/*` remotes. | Registry fixed (posture note corrected) |
| App README (`Code/mine-flow-app/README.md`) | Contract Regeneration section | Same dead `gen types dart` path as Doc 11 (drift dates to STEP-42.2). Setup/Running/Testing sections otherwise verified current (STEP-47.8 rewrote host prerequisites; E2E commands verified then). | README fixed (command, path, prereq `supabase link`, ADR-0019 pointer) |
| Repo READMEs (docs hub, prompts) | overview/setup/test claims | No drift found (`gen types`/generated-path/dependency_overrides/kotlin greps empty). | None |
| Interface contract artifact | `supabase/types/database.ts` vs. migrations | Artifact is genuine typegen output (guard rejects stubs; regenerated with the 48.17/48.20/48.21 migrations); `git log` shows it tracked every schema change since STEP-42.2. | None |
| Docstrings | spot-check: LWW `updated_at` writers; reporting presentation map | `attendance_repository_impl.dart:203` documents the updatedAt-desc read contract; `reporting_remote_datasource.dart:52-56` documents the BCM/LCM presentation-map boundary (STEP-48.27). Both describe current behavior. | None |
| Docs 04/09/12 | vs. STEP-48 close | Reconciled by the 48.15 docs-true close earlier the same day (Doc 04 v0.1.7 covers all STEP-48 migrations incl. `timeline_milestones`/`benchmarks`/notes columns; Doc 09 v0.5.0 carries the branch-head gate evidence and named boundaries; Doc 12 v1.3 rewritten). Cross-checked; no further drift found. | None |
| Docs 01/02/03/05/07/16/17 | vs. current system | No drift: system overview, phase sketches, component boundaries, scaling posture, design system (v0.4.0 reconciled at STEP-50 header fix), identity/auth decisions, privacy posture all still accurate. Known implementation gaps against still-correct docs are all registered (below). | None |

**Code-vs-docs (bug-class) findings — none new.** Every gap where code diverges from a
still-correct doc is already registered and owned: RISK-0011 (privacy notice absent,
Doc 17 §3), RISK-0021 (crew RLS unverified, Doc 06 posture), RISK-0012/0013 (ops cluster),
STEP-51 (CF-087 Material remainder vs. Doc 07's ForUI-only canon). No unregistered drift
of this class was found.

## Conditional Coverage

All three `templates/architecture-sessions/conditional-*.md` enumerated (no others exist;
check.sh contract test passes). All were **Included** and run in STEP-1 (STEP-1 PLAN
"Conditional sessions considered" table) and remain applicable — no re-interview triggers:

| Conditional session | Current disposition | Evidence | Follow-up |
|---------------------|---------------------|----------|-----------|
| `conditional-native-app.md` | Included — still accurate | Doc 15 v0.2.1 (OQ-2 now marked resolved); Android+web surfaces unchanged | None |
| `conditional-identity-auth.md` | Included — still accurate | Doc 16 v0.1.1; Supabase Auth email/password + RBAC unchanged | None |
| `conditional-privacy-compliance.md` | Included — still accurate; **implementation gap registered** | Doc 17 v0.1.0; first-login privacy notice still absent from the app | RISK-0011 (pre-release gate; owner decision when to schedule) |

## Risks And Debt

`registries/risks.yml` reviewed row by row (RISK-0001..0024 after this pass). Decisions:

| Risk/debt item | Status before | Decision | Action |
|----------------|---------------|----------|--------|
| RISK-0001 (anti-DDoS deferred) | open | Still valid (pre-public-beta trigger) | None |
| RISK-0002/0003 | closed | History intact | None |
| RISK-0004 (l10n migration incomplete) | open | Still valid (CI guard mitigates) | None |
| RISK-0005 (fl_chart v1.x) | open | Still valid | None |
| RISK-0006 (go_router v18) | closed 2026-09-08 | Correctly closed by 48.15 (route matrix passed; cold-start split to RISK-0019) | None |
| RISK-0007 (hive_ce maintenance) | open | **Revisit trigger FIRED**: last stable release 2.19.3 was 2026-02-03 (~7 months; verified pub.dev; pre-releases don't count) | Registry annotated; **STEP-53 reserved** |
| RISK-0008 (secure_storage v9→v11 skip) | monitoring | Still valid (dev-only until real users) | None |
| RISK-0009 (Flutter 3.47 semantics regression) | open | **Half-triggered**: fix PR flutter/flutter#191587 merged to master 2026-09-03 (verified); no stable containing it has shipped (3.47.1 is 2026-08-19) | Registry annotated; **STEP-53 reserved** |
| RISK-0010 (staging ClickOps) | open | Still valid (runbook documents repro) | None |
| RISK-0011 (privacy notice absent) | open, high | Still valid; confirmed absent at runtime in 48.13 | Owner decision when to schedule (pre-release gate) |
| RISK-0012 (no auto backups) | open, high | Still valid (free tier; manual procedure documented) | None |
| RISK-0013 (ops cluster: branch protection, secret scanning, Dependabot, monitoring) | open | Still valid — **Unverified locally**: `gh` CLI not installed, GitHub-settings items can't be read from this machine | To re-verify in STEP-52 (S0 re-check) or when `gh` is available |
| RISK-0014 (reporting semantics / PDF regression) | mitigated | Still valid (dedicated PDF regeneration check outstanding) | None (owner: before operational PDF use) |
| RISK-0015/0016 (login light-mode / sidebar active-state) | monitoring | Correctly returned to monitoring by the 48.15 retraction | None (valid-capture trigger) |
| RISK-0017/0018 (Drive behavior / OOM ceiling) | monitoring | Still valid (D2 deferral) | None |
| RISK-0019 (cold-start deep links) | monitoring | Still valid | None |
| RISK-0020 (SDK-pinned transitives) | open | Still valid; `flutter pub outdated` this pass shows only minor drift (file_picker 12.1.2→12.2.0, go_router 18.0.0→18.0.1, lucide_icons_flutter, build_runner; `archive` still SDK-pinned) | Noted in **STEP-53** scope |
| RISK-0021 (crew RLS unverified) | open | Still valid (`TEST_CREW_*` secrets still absent) | Adjudicate in **STEP-52** |
| RISK-0022 (benchmark journey) | **open — registry defect** | 48.15 intended to close it (commit message says so; `closed:` block filled 2026-09-08) but the `status:` field was left `open` | **Fixed: status → closed** |
| RISK-0023 (screenshots / screen-reader) | monitoring | Still valid | None (valid-capture trigger) |
| RISK-0024 (placeholder PNGs) | — new | The 73 committed 1×1 placeholder PNGs under `reports/design-review/step-0048/` were only described inside RISK-0023's text; they deserve their own indexed row so a future reader can't mistake them for evidence | **Row added** (low, open) |

**Design-review coverage (UI-heavy STEPs since STEP-39/40):** STEP-46 (97-findings
remediation) was booked complete, but the 2026-09-05 implementation audit (§F-2/§F-3)
proved the CF-087 Material purge ~half done and the assigned widget-test tier largely
unfulfilled; the STEP-48.13 runtime design review's "Verified" verdicts were retracted
(placeholder PNGs). Owning STEP: **STEP-51** (reserved, PLAN authored) for the UI/test
debt; RISK-0015/0016/0023/0024 carry the visual-evidence residuals. The coverage
confirmation therefore **passes with named owners** — no unowned Blocking/Unverified result
remains.

## Security Review Gate

| Level | Current status | Due? | Action |
|-------|----------------|------|--------|
| S0 Security Baseline | 2026-08-26 (STEP-44, run as report `reports/security/2026-08-26-step-0044-s0-security-baseline-report.md`, reviewed commit `5536191`) | **Yes** — invalidated per its own cadence rule ("after any major CI/hosting/ownership change") by STEP-45 (dual-platform E2E gate, new secrets/runner surface), STEP-47 (build-chain + CI wiring changes), and STEP-48 (staging schema/fixture/secret surface: TEST_USER_*, Drive secrets, seed alignment). Also: two RLS-covered tables (`timeline_milestones`, `benchmarks`) postdate the baseline's "all 9 tables" audit claim — RLS policies exist in their migrations (verified this pass) but were never audited. | **STEP-52 reserved** (Security Baseline re-check) |
| S1 Security Sweep | Never run | Not yet — no S1 cadence elapsed (first sweep cadence is quarterly from first run; triggers evaluated below) | None this check-in |
| S2 Security Audit | Never run | No — internal tool, no public launch milestone reached | None |

Triggers evaluated: no auth/AuthZ change since S0 (RLS posture unchanged; crew-leg gap is
credential-limited, registered RISK-0021); no public API/surface change beyond the staging
pipeline (covered by the S0 re-check above); no payment/regulated workflow; no AI/agent
capability; no incident. Per the runbook, S0/S1/S2 are not run inside a check-in —
`registries/security-reviews.yml` intentionally **not** updated (no review ran this STEP).

## Tests

| Repo / suite | Command | Result | Notes |
|--------------|---------|--------|-------|
| mine-flow-app | `flutter test` | **Pending — substep 50.2** | Full suite is 50.2's deliverable (PLAN gates Part 2 on Part 1). Known flake to diagnose, not wave through: `test/integration/attendance_daily_log_sync_test.dart` (Hive `setUpAll`) fails intermittently full-suite, green isolated (seen again at the STEP-48.15 close). |

## Carry-Forward

| Item | Type | Owner | Next action |
|------|------|-------|-------------|
| STEP-52 Security Baseline re-check | follow-up STEP | — (unassigned) | Reserved on prompts/main (`c6012c1`); run before production release or next major CI change |
| STEP-53 Dependency Maintenance (hive_ce fired trigger; Flutter fix retest when stable ships; minor pub outdated drift) | follow-up STEP | — (unassigned) | Reserved on prompts/main (`c6012c1`) |
| STEP-51 UI debt (CF-087 remainder, 46.4 test debt) | follow-up STEP | — (unassigned) | Already reserved (`e2d2087`); PLAN in `Upcoming Prompts/` (authored with the 2026-09-05 audit's remediation routing) |
| RISK-0011 privacy notice | risk (high, pre-release gate) | User | Decide when to schedule implementation |
| RISK-0013 GitHub-settings items | risk (Unverified locally — no `gh` CLI) | User | Install `gh` or verify in GitHub UI; fold into STEP-52 |
| Workspace-root evidence logs (~130 files) | hygiene | User/next session | Clean up at STEP-50 close, preserving the four `step4826_r7_*` logs cited by the archived 48.15 record (or relocate under a repo and update citations) |
| STEP-48 user-side staging hygiene (PAT revocation; 10 `name='150'` inventory rows; placeholder PNGs → RISK-0024) | handoff | User | Named in 48.15's handoff section; PAT revocation recommended now that the gate is green |
| Substep 50.2 full `flutter test` | substep | Hermes | Run after this substep (fresh chat per convention) |

## Summary

Project health at the STEP-47/48 breakpoint is **sound with named residuals**. The
mechanical gates are green (check.sh 0 failures; duplicate scans empty; branch-head CI run
34225431645 GO at STEP-48's close). This pass found and fixed six genuine doc-drift items
— the most material being Doc 11/app-README documenting a Supabase Dart-typegen path that
no longer exists (now ADR-0019 + v0.3.0), and Doc 08's CI description predating the E2E
gates — plus one registry defect (RISK-0022's un-flipped close status), one fired risk
trigger (hive_ce ~7 months without a release), one half-fired (upstream Flutter fix merged,
no stable yet), and the S0-baseline invalidation, which spawned STEP-52 (S0 re-check) and
STEP-53 (dependency maintenance) on the shared trunk. All code-vs-doc gaps remain
registered with owners; no new bug-class drift was found. Next check-in: ~10–20 STEPs out
(target around STEP-60–70, or earlier if a production-release decision changes the risk
picture).

*Part 2 (substep 50.2 — full `flutter test` run and its disposition) appends to the Tests
section above when it runs.*
