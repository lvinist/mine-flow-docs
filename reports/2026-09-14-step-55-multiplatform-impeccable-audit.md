# mine-flow — STEP-55 Multiplatform Impeccable Audit Report

**Run date:** 2026-09-14
**Auditor:** STEP-55.11
**Verdict:** **NO-GO — close blocked**
**App audit head:** `89077bf31131a03ce082ff3cfdb27eff3b608ebf`
**App branch:** `step-0055-cohesive-ui-rebuild`

## Executive verdict

The implementation has substantial local evidence, but STEP-55 is not release-ready and must remain In progress. The exact local app head has no CI run. The remote step head's only run failed the foundation test job and skipped Android/Web E2E. Android runtime evidence was unavailable because no Pixel_6a emulator/device was connected. The Web render was real, but the runtime accessibility tree exposed only Flutter's `Enable accessibility` placeholder. The analyzer gate currently fails on two style findings. The 55.10 implementation remains a large uncommitted lane, so prior substep evidence cannot be treated as a single committed branch-head record.

## Health scores

Scores are not quality claims; they summarize evidence completeness against the 55.11 matrix.

| Platform | Health score | Basis |
|---|---:|---|
| Web | 5/20 | One valid login render and route registration observed; required authenticated, responsive, theme, interaction, state, AX, and cold-route matrix not evidenced |
| Android | 0/20 | No connected Pixel_6a/emulator; no native runtime evidence |

## Severity-counted findings

| Severity | Count | Finding |
|---|---:|---|
| P0 | 2 | Exact-head CI/E2E gate absent; Android runtime/accessibility gate unavailable |
| P0 | 1 | RISK-0025 privilege-escalation finding remains open |
| P1 | 3 | Web AX tree remains placeholder-only; privacy copy approval is unverified; analyzer gate fails |
| P1 | 2 | True browser cold-start routes unverified; 55.10 lane is not committed or represented by a common CI head |
| P2 | 3 | Required widths/themes/text-scale/state/input matrix incomplete; Drive/OOM and crew RLS remain deferred |
| P3 | 1 | Obsolete STEP-48 placeholder PNG set remains and must not be mistaken for evidence |

## Positive findings

- `dart format --output=none --set-exit-if-changed .` passed.
- Localization and Supabase contract guards passed.
- Sensitive-header regression test passed.
- First full test run recorded 681 passed, 5 skipped, 1 failure; the exact failing integration file passed twice in isolation, and the complete rerun passed 681 passed, 5 skipped, 0 failed. This supports a non-reproducible shared-state/order flake, but does not turn the first failure into a pass.
- `flutter build web --release` passed.
- `flutter build apk --debug` passed.
- Web login capture is a valid non-placeholder PNG: 19,553 bytes, 1,258 × 566 pixels.
- Runtime diagnostics showed redacted `apikey` and `Authorization: Bearer ***`; no raw credential was recorded in the audit artifacts.
- Docs structural check passed with 0 failures and 1 existing workspace-root hygiene warning.
- Duplicate STEP scan returned no duplicates.

## Automated gate record

| Gate | Result |
|---|---|
| Redaction test | PASS, exit 0 |
| l10n guard | PASS, exit 0 |
| Supabase contract guard | PASS, exit 0 |
| Format | PASS, exit 0 |
| Analyzer | FAIL, 2 `curly_braces_in_flow_control_structures` infos in `app_shell.dart:269` and `:272` |
| Full test first run | FAIL, 681 passed / 5 skipped / 1 failed |
| Full test rerun | PASS, 681 passed / 5 skipped / 0 failed |
| Web release build | PASS, exit 0 |
| Android debug build | PASS, exit 0 |
| Exact local-head CI lookup | No run, API `total_count: 0` |
| Remote step-head CI | Run `34547595586`, failure after 30 seconds; test failed and build/E2E jobs skipped via `needs:` |

## Evidence inventory

| Artifact | Metadata | Assessment |
|---|---|---|
| `reports/design-review/step-0055/2026-09-14-web-login-1258x566.png` | 19,553 bytes; 1,258 × 566; Web login | Valid render, insufficient matrix |
| Existing STEP-54.10a PNGs | 20 inspected; 18,218–71,067 bytes; valid dimensions | Stale prior-step evidence, not current-head proof |
| Existing STEP-48 design-review PNGs | Known 1×1 placeholders | Invalid and excluded |
| Android 55.11 captures | None | Unverified |

## Runtime audit matrix

| Area | Web | Android | Notes |
|---|---|---|---|
| 799/800/801/1024/1280 widths | Unverified | Unverified | Only 1,258px Web login capture exists |
| Authenticated supervisor/field role | Unverified | Unverified | No credentials used in this session |
| Light/Dark/System | Unverified | Unverified | No complete in-app theme cycle |
| Text 1.0/1.3/2.0 | Unverified | Unverified | Not captured |
| Mouse/keyboard/touch/Escape/back/IME | Unverified | Unverified | Not exercised as a complete matrix |
| Create/edit/detail/report cold routes | Unverified | Unverified | No exact-head E2E run |
| Loading/empty/error/validation/dirty/busy/offline | Unverified | Unverified | Static/widget evidence does not establish runtime parity |
| AX/semantics/screen reader | Placeholder-only | Unverified | Browser snapshot remained `Enable accessibility`; no Android device |
| Contrast/48dp geometry | Unverified | Unverified | No measured runtime rectangles/contrast |
| Motion/reduced motion | Unverified | Unverified | Not captured |

## Required remediation before close

1. Resolve the stranded 55.10 app lane as its own ownership/commit boundary, preserving unrelated work and auditing CRLF changes. Push the resulting exact head.
2. Fix the two analyzer findings and rerun focused tests plus analyzer/format guards.
3. Run CI on the exact pushed head and verify `head_sha` equality before reading any E2E result.
4. Provide a Pixel_6a emulator/device and capture Android screenshots, IME/back behavior, targets, themes, and accessibility evidence.
5. Enable and capture the browser AX/`flt-semantics` trees beyond the placeholder, including shell navigation, fields, modal titles, status/error names, and focus order.
6. Resolve or explicitly route P0 privacy-copy approval and RISK-0025 through the accountable product/security authority. Keep RISK-0019, RISK-0021, RISK-0023, and RISK-0024 visible.

## Post-audit follow-up — 2026-09-14

The owner selected the recommended 55.10 return path. The two analyzer findings in
`lib/app/presentation/pages/app_shell.dart:269` and `:272` were fixed locally;
`flutter analyze` now exits 0, and focused shell/router/login/logger tests pass **29/29**.
This fix is not yet committed or pushed. The remaining ownership blocker is that the dirty
app tree also contains substantive 55.9 Data Bucket/Timeline changes and shared-file hunks,
so they must be separated before the 55.10 commit and exact-head CI run.

The local Web server used for the audit was stopped, and its child listener on port 8765 was
terminated and rechecked; no listener remained. This is cleanup evidence, not a release gate.

---

# Run 2 — 2026-09-15 (resumption)

**Verdict:** **NO-GO**, but evidence-backed rather than blocked. The three gaps this report listed
on 2026-09-14 are now closed, the red E2E gate has a proven single root cause, and a bounded fix
batch has been applied and re-measured on both platforms.

## What changed since 2026-09-14

| 2026-09-14 claim | 2026-09-15 reality |
|---|---|
| No CI run for local HEAD | Run `34837033251` exists at `c64b0b9`, and local `HEAD` **equals** `origin/step-0055-cohesive-ui-rebuild` |
| Android evidence unavailable (`adb devices` empty) | **Pixel_6a emulator launched**; full Android suite + capture run executed on it |
| Web AX tree placeholder-only | **Real AX tree captured** (8 semantic nodes) |
| E2E red, cause unknown | Root cause identified, fixed in one batch, re-measured |

## Root cause of the red E2E gate

`AppRouter.redirect` parks every authenticated session whose persisted `privacyAckVersion < 1` on
`/privacy-gate`. Every E2E journey clears secure storage on entry, so **every journey** landed on
the gate and each subsequent `appRouter.go(<feature>)` was redirected straight back — surfacing on
CI as `Found 0 widgets with type "<FeatureScreen>"`. That single cause produced **13 of 16 Android
failures and 12 of 16 Web failures**.

The gate was also **unclearable in production**: the acknowledgement button called the async
`updatePrivacyAckVersion(1)` without awaiting it and then navigated, so the redirect re-read the
still-zero version and bounced the user back — a real defect (a user permanently stuck on the
notice), not just a harness problem.

## Fix batch (round 2 of the mandated two-round cycle)

1. `integration_test/helpers/login_helper.dart` — `loginAsStagingUser` acknowledges the gate once
   for all 13 callers; fails loudly if the gate does not clear.
2. `lib/features/auth/presentation/pages/privacy_ack_page.dart` — acknowledgement **awaited before**
   navigation (the product half of the defect).
3. `test/features/auth/presentation/privacy_ack_page_test.dart` (new) — regression pin, verified to
   **fail against pre-fix code** and pass after.

## Measured result of the fix batch

| Platform | CI `c64b0b9` (before) | Fixed tree (after) |
|---|---|---|
| Android `flutter test integration_test/` | 11 passed / 13 failed / 2 skipped | **14 passed / 9 failed / 3 skipped** |
| Web `flutter drive` per-file loop | 4 of 16 files green | **8 of 16 files green** |

Newly green on **both** platforms: `deep_link`, `notifications`, `timeline`.

## Remaining failures (9 Android / 8 Web) — classified, not fixed

- **Class A — fixture staleness (6 journeys).** The STEP-55 substeps replaced Material widgets with
  ForUI primitives but did not migrate the journey finders: `cut_fill:64`, `land_clearing:64`,
  `inventory:62` still look for `FloatingActionButton`; `benchmark:77` and `equipment_check:84/:90`
  use `FTextField`-labelled finders; `reporting:61` expects `ReportConfigPage` (now
  `AppContextualReportDialog`).
- **Class B — behaviour/role mismatches (3).**
  - `daily_log:66` logs in as **supervisor** but looks for the create FAB that STEP-55.6
    deliberately hides from supervisors.
  - `offline_sync` Part A — `getPendingItems()` is not empty after the reconnect drain; a
    **product-side sync defect**, the only non-fixture residual.
  - `attendance:131` — the status chip finder predates the STEP-55.5 card rebuild.

## Automated gates (re-derived on the fixed tree)

`dart format` **PASS** (0 changed) · `flutter analyze` **PASS** (no issues) · l10n guard **PASS** ·
Supabase contract guard **PASS** · `flutter test` **PASS** (684 passed / 5 skipped / 0 failed) ·
`flutter build web --release` **PASS** · `flutter build apk --debug` **PASS** · redaction test
**PASS** · docs check 0 fail / 1 warning · duplicate STEP scan clean.

## Runtime evidence

- **Web AX tree** — real semantics now exposed after enabling accessibility: group, app title,
  tagline, `Email` field, `Kata Sandi` field, `Show password` button, `Masuk` button. This retires
  the 2026-09-14 "placeholder-only" finding. Authenticated-shell AX is still unverified.
- **Android capture run** — the gate now clears (2 redirects at login, then routes resolve 24x),
  confirming the fix on device. **Screenshot output is still 1 of 24 cells** — the artifact gap
  identified in the 2026-09-14 addendum persists and is not laundered by the harness's relaxed
  Android assertion.
- **Secret scan** — 0 hits for JWT / `Bearer` / `service_role` across all three 2026-09-15 logs.

## Still blocking close

1. E2E gate red on both platforms (Class A is mechanical fixture migration; Class B needs an owner
   decision).
2. Privacy notice copy has no recorded accountable approval.
3. RISK-0025 remains open.
4. Design-review screenshot artifact gap (1/24).
5. Cold-start/refresh, contrast, 48dp geometry, text-scale, reduced-motion, IME/back, and
   authenticated-shell AX unverified.
6. The fix batch is **uncommitted** — commit/push/merge/archive are owner-authorized actions.

No index flip, risk closure, archive, merge, branch deletion, or STEP Done claim is authorized by
this report. STEP-55 remains **In progress** pending the accountable user's explicit decision.
