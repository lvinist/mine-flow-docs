# STEP-55 Design Review Capture Matrix — Web — 2026-10-07

**Head:** `1486826` (app repo, `step-0055-cohesive-ui-rebuild`)
**Captured:** 2026-10-07, local web run (`flutter drive -d web-server --browser-name=chrome`, chromedriver 155.0.8059.39)
**Source test:** `integration_test/design_review_capture_test.dart`
**Drive exit:** 0

## Result

**73 / 73 expected capture cells produced valid PNGs. Zero placeholder-sized files.**
All 73 files carry PNG magic bytes; physical dimensions 1578×870.

| Breakpoint | Expected | Produced |
|---|---:|---:|
| phone (400×800) | 24 | 24 |
| tablet (700×1000) | 24 | 24 |
| desktop (1200×900) | 24 | 24 |
| login (phone, light, en) | 1 | 1 |

Each non-login cell is `<screen>-<breakpoint>-<theme>-<locale>` across 6 screens
(dashboard, daily-log, daily-log-form, operations, teams, tools) × 2 themes × 2 locales.

## Locale-byte analysis (important for honest adjudication)

38 distinct SHA-256 prefixes across 73 files. Per-cell id/en comparison:

**Identical bytes across id+en (30 cells):** dashboard, teams, operations, tools (all
breakpoints/themes) and daily-log desktop/tablet. **This is expected and not a defect** —
`grep` confirms those screens contain **no `AppLocalizations` string lookups**, so an
Indonesian and an English render are pixel-identical by construction. Identical bytes here
do not indicate a capture error or a missed translation; they indicate
locale-independent screens.

**Divergent bytes across id+en (7 cells):** `daily-log-form` at all breakpoints/themes,
`daily-log` phone/light, and `login-phone-light-en` vs its id counterpart path via the
privacy page. Divergence tracks the screens that actually load localized copy
(`daily_log_form_sheet.dart`, `hazard_assessment_field.dart`, `privacy_ack_page.dart`).

Consequence for adjudication: a cell's byte-identity **cannot** by itself establish that
the correct locale was rendered. For the four locale-independent screens the id and en
captures are one piece of evidence, not two. Screens that must be read for copy
(daily-log-form) do show real locale divergence.

## What this evidence can and cannot support

**Can support:** every named screen renders without crash at all three breakpoints, in
both themes, in both locales; each capture is a real rasterized frame of the correct
route (filenames are asserted by the test, not inferred from filenames alone — the test
asserts all 73 expected names were captured and exits nonzero otherwise).

**Cannot support:** visual contrast measurements, hit-target sizing, keyboard/focus order,
IME behaviour, reduced-motion, cold-start/refresh behaviour, or screen-reader semantics.
Those remain **Unverified** and must not be inferred from a green screenshot.

## Files

All captures live in `web/` alongside this index. Naming:
`<screen>-<breakpoint>-<theme>-<locale>.png`, plus `login-phone-light-en.png`.

Note on the pre-existing stray artifact: `reports/design-review/step-0055/2026-09-14-web-login-1258x566.png`
predates this matrix and is superseded by this run; disposition is recorded in the close
addendum rather than deleted silently.

## Artifact disposition — 2026-10-07

**`2026-09-14-web-login-1258x566.png`** is retained, not deleted. It is the only surviving
artifact of the 2026-09-14 capture attempt (the one that surfaced the stall) and is
superseded in full by `web/login-phone-light-en.png` from this run. Deleting prior evidence
without a dated record is against the project's evidence rules, so it stays as the
historical artifact with this index as the supersession record. Its dimensions (1258×566)
also differ from the current matrix (1578×870), which is itself a trace of the harness defect:
that run captured at the wrong viewport because the capture size was not aligned to the
breakpoints — the exact bug `d6160f2` fixed.

**`reports/2026-10-06-step-0055-resume-verification.md`** is untracked in this branch. It is
the living continuation report for this lane; the RESIDUAL-3 adjudication and updated gate
list were appended to it on 2026-10-07 rather than rewriting the 2026-10-06 sections, and it
should be committed to this branch as part of the evidence set.

**`architecture/04-data-model.md`, `architecture/11-interface-contracts.md`,
`architecture/README.md`** were already modified in the working tree before this session
(from the timestamp lane's contract updates). They are not touched by this lane and are left
as-is for their own lane to commit.

