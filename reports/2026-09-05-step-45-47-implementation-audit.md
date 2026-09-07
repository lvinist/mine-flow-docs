# Implementation audit — STEP-45, STEP-46, STEP-47 closes vs. disk

**Date:** 2026-09-05
**Author:** Hermes / Claude Opus 4.8 (audit re-verification and triage)
**Scope:** the three closed STEPs' index rows and archived claims, checked against
`Code/mine-flow-app` `c73a00e` + the current working tree, `Code/mine-flow-docs`
`41cfbb6`, and `prompts` `2aabfcc`.
**Status:** findings confirmed; remediation routed to STEP-48.28–48.30 and STEP-51.

> This report is the durable source for the new substeps. It records only what was
> re-derived mechanically this session; every count below was produced by a command whose
> output is quoted or reproducible from the recipes in §8.

## 1. Live gate state (re-run 2026-09-05 on the current tree)

| Gate | Command | Result |
|---|---|---|
| Analyzer | `flutter analyze` | `No issues found!` (8.1s) |
| Formatter | `dart format --output=none --set-exit-if-changed lib/ test/` | `Formatted 315 files (0 changed)` |
| Unit/widget/integration | `flutter test` | **513 passed / 0 failed** (`01:36 +513: All tests passed!`) |
| Supabase contract guard | `dart run tool/check_supabase_contracts.dart` | `[OK] Contract verification passed.` |
| l10n baseline guard | `dart run tool/check_l10n_baseline.dart` | `[OK]` — 33 scanned, 29 exempt |
| Throughstone doctor | `./doctor.sh check` | 0 fail / 1 warn (workspace-root scratch) |
| Link checker | `./doctor.sh links` | 133/133 resolve |

The tree under test is `c73a00e` **plus** the uncommitted 48.23/48.27 fixes (26 modified
files + 1 untracked test). Those commits are 48.25's lane; nothing in this report stages them.

## 2. STEP-47 — claims verified

Every substantive line of the STEP-47 index row is true on disk: no `dependency_overrides`,
`flutter_secure_storage_windows` 4.2.2 with `win32` 6.4.0 resolved transitively, the 9-major
sweep at the claimed majors, AGP 9.1.0 / KGP 2.4.0 with `newDsl=false` + `builtInKotlin=true`,
STEP-43's Kotlin-daemon workaround gone, `file_picker` v11→v12 API migration complete
(`FilePickerResult`/`withData` absent repo-wide), and 47.9's `risks.yml` de-duplication real
at `a8e6939` (20 unique ids, parses clean).

Drift, not misstatement: `pub outdated` is no longer "all up to date" — `file_picker`
12.1.2→12.2.0, `go_router` 18.0.0→18.0.1, `lucide_icons_flutter` 3.1.17→3.1.18,
`build_runner` 2.16.0→2.16.1 shipped after 2026-08-29.

## 3. Overstated claims (3 confirmed)

### F-1 — STEP-47.8's index row misdescribes Doc 12

The row claims `architecture/12-test-strategy.md` §6 was "clarified that both E2E gates are
boot-smoke-only". Commit `b48df96` is the entire Doc 12 change: it bumped v1.1→v1.2, added
`flutter drive`/chromedriver to §5, and reworded §6 to
`- Dual-Platform E2E Tests (Chrome via flutter drive and Pixel 6a via flutter test).`
There is no boot-only, smoke, skip, or credential caveat anywhere in the file. The honest
version lives in Doc 09 §4 ("a green E2E gate currently proves only that the test harness
executes"). Doc 12 v1.2 is the document a future reader consults for what CI proves.

Compounding it: the caveat is **now itself stale**. Branch-head run `33953949570` reports
`e2e-android` `24 tests passed, 2 skipped` — real journeys, not a harness smoke test. So the
fix is not to add the missing caveat; it is to correct the index row's claim and let 48.15
(which already owns "Doc 12 updated if the E2E tier's real shape differs from v1.2") write
what the gate proves today.

### F-2 — CF-087 "Material purge" is ~half done and booked as complete

STEP-46's row states all 97 findings fixed. The commits ("Material purge (buttons, tiles,
dividers)", "AlertDialog to FDialog/FAlert (all 7 sites)") are true as far as they go, but
the register entry CF-087 names "dialogs, alerts/snackbars, headers, selects, buttons".
Current `lib/` (`grep -rlE`/`-roE`, files/hits):

| Family | Files | Hits | ForUI equivalent shipped in forui 0.26 |
|---|---|---|---|
| `AlertDialog` / `ElevatedButton` / `OutlinedButton` / `TextButton` / `ListTile(` / `Card(` / Material `FilterChip` | 0 | 0 (comment references only) | — done |
| `Icons.` | 0 | 0 (`LucideIcons.` 291) | CF-088 genuinely complete |
| `SnackBar(` | 13 | 35 | `FToast` / `FToaster` (`widgets/toast/`) |
| `Scaffold(` | 25 | 37 (`FScaffold(` 3) | `FScaffold` (`widgets/scaffold.dart`) |
| `CircularProgressIndicator(` | 22 | 25 | `FCircularProgress` (`widgets/progresses/`) |
| `AppBar(` | 14 | 19 (`FHeader` 9) | `FHeaderData` / root+nested header (`widgets/header/`) |

~116 call sites across ~30 files, and 73 of 240 `lib/` files still import
`package:flutter/material.dart`. Every replacement exists in the pinned forui version — this
is an unfinished sweep, not a blocked one.

### F-3 — 46.4's "add tests for each fix" is largely unfulfilled

The register assigns an explicit test tier to **84 of 97** findings (80 of them "Widget
test"); 13 say "No test feasible". The STEP-46 merge `040def9` moved the case count
361 → 369 (**+8 net**, matching the claimed 434→442) and added **zero new test files**
(`git diff --diff-filter=A 040def9^1..040def9 -- test/` is empty). **13** of 97 CF ids are
cited anywhere under `test/` (34 counting `integration_test/`). The prompt's own escape hatch
`// TODO(STEP-46.4): test not written because …` is used **0** times. The fixes are real; they
are largely unguarded against regression.

## 4. STEP-46 fixes: spot-check confirms them

Traced all 97 ids across lib comments, test comments, `integration_test/`, and commit
messages: 89 traceable, 8 untraced — all 8 hand-verified as genuinely fixed at the cited site
(CF-009/010 attribution at `router.dart:264,275,428`; CF-021/022/023 via supervisor-gated
`confirmDestructiveAction()` with the draft-only delete affordance at `daily_log_card.dart:166`;
CF-060/061/089; CF-011/012/014 volume + attendance semantics; CF-030 and CF-026..029 report
routes; CF-097/NR-006 benchmark child route). One false alarm worth naming so it is not
re-reported: `admin@mineflow.id` at `login_page.dart:134` is the field's `hint:`, not a
controller value — CF-002 is fixed and `login_page_test.dart:102` asserts it.

## 5. Real gaps no STEP owns

### G-1 — `registries/risks.yml` is unparseable again (committed)

`yaml.safe_load` throws `ReaderError: unacceptable character #x000c … position 18357`.
Three corrupt bytes, all inside RISK-0014's `description`, each where the source had a
backtick followed by a letter that Python/JS string escapes consume:

| Offset | Byte | Source text destroyed |
|---|---|---|
| 18291 | `0x0D` (lone CR) | `` `reporting_remote_datasource.dart` `` → `` \reporting… `` |
| 18371 | `0x0C` (form feed) | `` `fill_volume_m3` `` → `` \fill_volume_m3 `` |
| — | real newline | `` `net_volume_m3` `` → line break + `et_volume_m3` |

Provenance is unambiguous. `91d1dae` ("STEP-48.18: Amend RISK-0014 status") is the only commit
in the file's history carrying `0x0C=1`, and the same commit converted the whole file to CRLF
(`before=0 after=519` CR bytes), which is why a one-sentence status amendment shows as
`522 insertions(+), 520 deletions(-)`. Ignoring CR, the semantic diff is **4 changed lines,
all in RISK-0014** — the intended edit plus the three mangled escapes. `45457da` and
`origin/main` both parse clean (`0x0C=0, CR=0`, 20 ids). An edit script interpreted `\r`,
`\f`, `\n` in text that meant backtick-plus-letter; the pre-corruption block is recoverable
verbatim from `45457da`.

This silently undoes the health property 47.9 established, and **`scripts/check.sh` never
parses YAML at all** — it has no reference to `risks.yml`, `yq`, or a YAML load anywhere in
its 9 checks — so nothing catches it. Current file: 23 ids (RISK-0001..0023; 0021–0023 were
added legitimately by 48.14's `45457da`, so the "20 unique ids" figure from 47.9 is simply
outdated, not evidence of another duplicate paste).

### G-2 — Both "did anything actually run?" guards can pass vacuously

`.github/workflows/ci.yml` (branch head) guards both E2E jobs with
`grep -qE "\+[1-9]|\-[1-9]|All tests passed|Some tests failed"`. Demonstrated:

- a synthetic Android line `00:05 +0 ~17: All tests passed!` **satisfies** the guard —
  0 passed, 17 skipped reads as green;
- on web, `flutter drive` prints `All tests passed.` **per file**, including files that
  skipped everything. `step4824_e2e_web_all.log` contains 15 such lines and 15
  `result {"result":"true","failureDetails":[]}` records.

So the guard 48.2 added — the guard whose whole purpose is detecting the STEP-45 failure mode —
cannot detect an all-skipped run on either platform. (Separately: `master`'s `ci.yml` still
targets `app_boots_test.dart` only; the expansion is unmerged on `step-0048-runtime-evidence`.)

### G-3 — The l10n guard has a 21-of-33 blind spot

`_hardcodedTextPattern` is matched **line by line** (`check_l10n_baseline.dart:177`), so
`Text(\n  'literal'\n)` is invisible. Of the 33 non-exempt presentation files, **21 contain 36
such literals** — including a file created by 46.4 itself
(`report_type_picker_page.dart` → `'Pilih Jenis Laporan'`) and both `app_shell.dart` copies,
`global_app_header.dart`, `zone_picker.dart`, and 9 tracking/timeline cards. CF-063 correctly
plugged the router-label hole; this second hole was never seen. Making the pattern multi-line
turns 21 files red at once, so the repair must land with an honest baseline decision in the
same commit.

### G-4 — CF-043 is not fixed as specified, and the dead "Tambah" tile is a 3-site class

`land_clearing_entry_screen.dart` still has two independent `CreatableCombobox<String>`
instances (`:372` Plan tab, `:485` Actual tab) over the fixed 3-item `_clearingMethods`
(`:98`), both dispatching the same `MethodChangedEvent`, against a register entry that asked
to "constrain method to the enumerated set" and "use one shared control, not two".

Separately and more concretely: neither passes `onCreateNew`, yet `CreatableCombobox` renders
its `Tambah "$query"` tile whenever `_queryMatchesNone` (`creatable_combobox.dart:313`) and
`_createNew` then calls `widget.onCreateNew?.call(text)` — so the tile appears, is tappable,
clears the field, and does nothing. Sweeping the class: **3 of 5 call sites** pass no
`onCreateNew` — `land_clearing_entry_screen.dart:372`, `:485`, and
`cut_fill_form_screen.dart:436` (material type). Only `zone_picker.dart:121` wires it.
The widget cannot express "selection only", so every non-zone combobox ships a dead control.

Note what this is *not*: STEP-48.20's staging `42501` came from the **zone** combobox, whose
`onCreateNew` works and correctly hit `supervisor_zones_all` — that verdict stands.

(CF-044's shared date+zone above the `TabBar` was done properly, matching ADR-0015.)

### G-5 — RISK-0014's register row is stale in the *other* direction

At `c73a00e` the row is accurate: `reporting_remote_datasource.dart` reads
`cut_volume_m3`/`fill_volume_m3` and computes `net_volume_m3: cutVol - fillVol` — the formula
ADR-0012 rejects. On the **working tree** 48.27 already fixed it: reads `bcm_volume`/`lcm_volume`,
emits `VolumeNormalizer.bankEquivalent(...)`, and documents the report-facing keys as an
explicit presentation-map boundary. So the code defect is remediated-but-uncommitted; what is
wrong is the register row (which additionally carries G-1's corruption).

### G-6 — Dead and shadowing files in `lib/`

Of 240 `lib/` Dart files, **7 are referenced by no `import`/`export`/`part` anywhere** and 17
are unreachable from `lib/main.dart`. Two are genuine shadowing traps:

- `lib/app/presentation/pages/settings_page.dart` — a 630-byte STEP-31 placeholder
  (`// This is a stub branch destination — the full Settings page … STEP-35`) shadowing the
  routed `lib/features/settings/presentation/pages/settings_page.dart`; it also holds the last
  raw `TextStyle(fontSize: 24)` outside `pdf_service.dart` (the remaining three are
  `copyWith(fontSize:)` on theme typography in `daily_log_card.dart`, which is legitimate).
- `lib/app/presentation/widgets/app_shell.dart` — 6416 bytes shadowing the routed
  `lib/app/presentation/pages/app_shell.dart` that `router.dart:25` and 3 journeys import.

The rest are unimported barrels (`tracking.dart`, `benchmark.dart`, `data_bucket.dart`,
`data/data.dart`, `domain/domain.dart`) plus `notification_badge.dart` and
`report_type_card.dart`; deleting those needs a per-file consumer check, not a sweep.

### G-7 — ADR-0018 cites a non-existent ADR

`adr/ADR-0018-android-build-chain-posture.md` "Related documents" lists
`ADR-0017-release-readiness-evidence`. The real file is `ADR-0017-expanded-e2e-tier.md`
("Expanded Dual-Platform E2E Test Tier"). It is not a markdown link, so `links.sh` passes it.

## 6. STEP-45: the corrected close is accurate

15 journey files exist, each gated by `markTestSkipped` behind `isStagingConfigured`;
`app_boots_test.dart` self-skips identically; `offline_sync_journey_test.dart` Part B runs
unconditionally. 45.2's "required before deploy-staging" is true
(`needs: [build-android, e2e-web, e2e-android]`). NR-001 is really implemented —
`report_config_page.dart` threads `enabled: !isLoading` into `DateRangeSelector` and
`ZonePicker` and nulls `onPress`, asserted at `report_config_page_test.dart:170`.

## 7. Remediation routing

Decided with the user 2026-09-05. Everything that threatens STEP-48's own close stays inside STEP-48
as substeps 48.28–48.30 (one branch, one close); the UI debt that belongs to STEP-46 becomes STEP-51.

| Finding | Owner | State |
|---|---|---|
| G-1 risks.yml repair + `check.sh` YAML gate, G-5 RISK-0014 row, G-7 ADR-0018 xref, F-1 index-row correction | **STEP-48.28** | PLAN row + prompt authored |
| G-2 zero-executed guards, G-3 l10n multi-line blind spot | **STEP-48.29** | PLAN row + prompt authored |
| G-4 dead `Tambah` tile (3 sites), G-6 two shadowing `lib/` files | **STEP-48.30** | PLAN row + prompt authored |
| Doc 12 §6 substantive rewrite (what the gate proves today) | **STEP-48.15** | already in its DoD |
| F-2 CF-087 remainder (register re-scope, then per-feature sweep with widget tests), F-3 46.4 test debt, CF-043's one-shared-control half, the 5 remaining unreferenced `lib/` files | **STEP-51** | reserved `e2d2087`, PLAN authored |
| `pub outdated` drift (§2) | next dependency-touching STEP | not a gate blocker |

Prompts: `Upcoming Prompts/mine-flow-STEP-48.28-PROMPT.md`, `…-48.29-PROMPT.md`,
`…-48.30-PROMPT.md`; plan `…-STEP-51-PLAN.md`.

## 8. Reproduction recipes

```bash
# G-1
python -c "b=open('registries/risks.yml','rb').read(); print(b.count(b'\x0c'), sum(1 for i,c in enumerate(b) if c==0x0d and (i+1>=len(b) or b[i+1]!=0x0a)))"
python -c "import yaml; yaml.safe_load(open('registries/risks.yml','rb').read())"

# G-2 (proves the guard is satisfied by a 0-passed run)
printf '00:05 +0 ~17: All tests passed!\n' | grep -qE "\+[1-9]|\-[1-9]|All tests passed|Some tests failed" && echo VACUOUS
grep -c 'All tests passed' step4824_e2e_web_all.log     # 15, one per drive file

# F-2
for p in 'SnackBar\(' '[^F]Scaffold\(' 'CircularProgressIndicator\(' '[^r]AppBar\('; do \
  echo "$p $(grep -rlE "$p" lib --include='*.dart' | wc -l) files"; done

# F-3
git diff --name-status --diff-filter=A 040def9^1..040def9 -- test/    # empty
git grep -hoE '^\s*(testWidgets|test)\(' 040def9^1 -- 'test/**/*_test.dart' | wc -l   # 361
git grep -hoE '^\s*(testWidgets|test)\(' 040def9   -- 'test/**/*_test.dart' | wc -l   # 369
```

## Version Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-09-05 | Hermes / Claude Opus 4.8 | Initial audit: 3 overstated claims, 7 unowned gaps, all re-verified on disk; routing to 48.28–48.30 and STEP-51 |
