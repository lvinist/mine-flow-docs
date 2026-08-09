# STEP-38 Spec-Drift Audit — Prompt for GLM-5.2 (code-only items)

## Role

You are the **auditor**, not the implementer, for the `mine_flow` project (Flutter/Dart, feature-based architecture, ForUI package with FTheme/FThemes.zinc). STEP-38 has already been implemented and marked "done" by the executor model, but the actual implementation has drifted from the intended spec. Your job is to inspect the current codebase and report exactly where it diverges from the list below — item by item. **Do not fix anything. Do not mark anything as acceptable because it technically runs or compiles.** A substep that runs without errors but doesn't match the described behavior is a FAIL, not a PASS.

Do not consult external repositories, reference implementations, or search for "correct" versions of this app online. Judge only against the spec given below and the actual code in this repository.

Note: two items from the full STEP-38 spec (inventory quantity/unit merge, equipment check mobile layout) depend on reference screenshots and are being audited separately by a vision-capable model — they are NOT included below, so don't flag their absence.

## Tool-use discipline (read this before you start)

You tend to decompose a task like this into many small, sequential tool calls — a separate grep or file read per pattern, per directory, per item — which multiplies round-trips without adding useful signal. Follow these rules:

- **No broad, unscoped rediscovery.** Do not grep the entire `lib/` tree for every component name "just in case." Each item below already tells you which screen/feature it belongs to — go straight to that feature's files.
- **Consolidate searches.** If you need to find multiple patterns (e.g. `FButton`, `IconButton`, `ElevatedButton`, `TextButton`, `OutlinedButton`) across the same set of directories, run ONE combined search per directory using alternation (e.g. `grep -rnE 'FButton|IconButton|ElevatedButton|TextButton|OutlinedButton' lib/features/data_bucket/`), not one command per pattern.
- **Read files once, fully, and reuse that context** for every item that touches that file — don't re-read the same file separately for item 1 and again for item 2 if both concern Data Bucket.
- **Batch your context-loading reads into as few tool calls as possible** before starting the item-by-item audit — ideally one pass, not an open-ended exploration phase with its own sub-checklist.
- **Do not ask for "full file contents with line numbers, do not summarize" as a blanket instruction** — request full contents only for the specific file(s) directly relevant to the item you're currently auditing, not for every file a search happens to touch.
- If you catch yourself about to issue a fifth-plus tool call for what is fundamentally one exploration goal, stop and consolidate the remaining lookups into a single call instead.

## Context you must load before auditing

Load these in as few consolidated tool calls as possible — this is a fixed, known file list, not an open-ended search:

- PRODUCT.md and DESIGN.md (Throughstone/Impeccable context files at the outer workspace root) — one read each.
- The STEP-38 planning doc / substep breakdown as originally written — one read.
- The actual source files for each screen/feature referenced below: Data Bucket, Attendance, Cut/Fill, Land Clearing, Breadcrumbs component, navigation/sidebar/router config, language/localization config, and the Inventory screen's add-button only (not its form-merge logic, which is out of scope here). Read each feature's relevant file(s) once, in full, rather than searching for them repeatedly across items.

## Spec items to verify (STEP-38 scope, code-only)

For each item below, report: **PASS / FAIL / PARTIAL**, the file(s) and line(s) inspected, what the code currently does, and what it should do per the spec. If FAIL or PARTIAL, state precisely what would need to change (describe the fix — do not write the fix).

1. Data Bucket "add" control should be an `FButton`, not a generic `Button`, and should NOT appear as a center-of-screen upload button on the app bar — it must follow the same add-button pattern used elsewhere (e.g. Cut/Fill, Land Clearing).
2. Data Bucket form should have an app-bar back button matching the pattern used on the Cut/Fill and Land Clearing forms.
3. The "Zona"/Zone field on Land Clearing, Cut/Fill, and Data Bucket forms must all use the same combobox component/data source as the Zone field on the Daily Log form — one shared source of truth, not separate implementations.
4. Language/localization configuration — verify it is wired correctly (check for hardcoded strings, missing locale delegates, or a config that doesn't actually switch language at runtime).
5. Inventory "add" control should be an `FButton`, not a generic centered `Button`.
6. Breadcrumbs must render human-readable labels with spaces, not raw route slugs — e.g. "Daily Log" not "Daily-log". Check the breadcrumb-generation logic for any place still doing a raw route-string-to-label pass without normalizing hyphens.
7. Attendance form should open as its own sheet/page (modal or route push), not be embedded inline within the attendance list/parent page.
8. Attendance form should display employee **name and position**, not raw employee ID, in the UI (ID can still be the underlying key/value).
9. Cut/Fill form: the BCM field should be relabeled/displayed as "Cut Volume" with unit "m³" in the value position; LCM field should be relabeled/displayed as "Fill Volume" with unit "m³" in the value position.
10. Cut and Fill fields should be laid out in the same row, 2-column layout — not stacked.
11. Remove any +/- stepper buttons on the Cut and Fill fields — should be plain numeric input only.
12. Remove any +/- stepper buttons on the Plan and Actual fields — should be plain numeric input only.
13. Land Clearing form should be restructured into a tabbed screen with separate "Plan" and "Actual" tabs, rather than one combined form.
14. "Metode Clearing" field should be a combobox with default options: Excavator, Bulldozer, Chainsaw (verify these exact three options exist and it's a combobox, not free text or a different widget).
15. Every `FButton` used for "add data" actions across the app must show both its icon AND its title text — audit all add-data buttons app-wide for icon-only or text-only instances.
16. The "Laporan" (Report) button should be displayed as an icon-only button positioned to the right of the "add data" FButton — check placement and styling relative to the add button.
17. The Benchmark page/feature is missing from navigation — locate whether the screen/route still exists in code but was dropped from the nav config (sidebar/drawer/router), or whether it was deleted entirely, and report which.

## Output format

Produce a table or numbered list, one row per item (1–17), with columns/fields:

- **Item #**
- **Status**: PASS / FAIL / PARTIAL
- **Evidence**: file path + line range
- **Current behavior**: one line
- **Required behavior**: one line
- **Root cause** (why the executor likely marked this "done" despite the gap — e.g. "checklist only verified widget renders, not which button component was used")

End with a short summary: how many of the 17 are FAIL, how many PARTIAL, how many genuinely PASS, and whether STEP-38 as a whole should be reopened.
