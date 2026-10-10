# STEP-38 Remediation — Re-Audit Prompt

## Role

You are the **auditor**, not the implementer. An executor model (DeepSeek V4 Pro) reported completing all 10 fix items from `STEP-38-remediation.md`. Your job is to verify each fix against its actual acceptance criteria in the code — not to trust the executor's summary. Treat the summary below as a claim to be checked, not a fact.

**Do not fix anything.** If something is still wrong, or was fixed differently than specified in a way that matters, report it as FAIL or PARTIAL with the reason. A fix that "looks done" but doesn't meet the specific acceptance criterion is a FAIL.

## What the executor claims to have done

1. Data Bucket list: Material `AppBar` → `FHeader` (wrapped in `PreferredSize`)
2. Upload Form: Material `AppBar`+`IconButton` → `FHeader.nested` + ghost `FButton` back arrow
3. Inventory list: Material `AppBar` → `FHeader`; removed body FAB
4. Data Bucket Zona: hardcoded list → `ZonePicker` backed by `ZoneCubit`/`ZoneRepository`, via an **optional** constructor param
5. Metode Clearing: 6 defaults → exactly `['Excavator', 'Bulldozer', 'Chainsaw']`
6. Laporan buttons (4 files): Material `IconButton` → `FButton(variant: ghost)`
7. Icon-only FABs removed entirely from Cut/Fill and Land Clearing list screens
8. Attendance form: parses stored position out of `remarks` field, pre-selects on edit
9. Inventory Jumlah/Satuan: merged into one `FTextField` with inline `suffixBuilder` dropdown
10. Equipment Check tabs: wrapped in horizontal `SingleChildScrollView` + `ConstrainedBox(minWidth: 110)`

## Verification instructions per item

For each item, read the actual current file content (not the diff/summary) and check against these specific acceptance points. Pay particular attention to the two flagged risks:

1. **Data Bucket list** — Confirm `FHeader` renders (and the add button is visible) at BOTH narrow and desktop widths, not narrow-only as the original bug was.
2. **Upload Form back button** — Confirm the leading widget is genuinely `FButton(variant: ghost)`, not a differently-styled `FButton` or a lingering `IconButton` renamed in a comment only.
3. **Inventory list** — Confirm there is exactly ONE add control. Search the whole file for any remaining `floatingActionButton:` property — it should not exist.
4. **Data Bucket Zona — FLAGGED RISK** — The constructor param for `ZoneRepository` was made optional. Find every call site that constructs this widget and confirm `ZoneRepository` is actually passed at each one. Then check what the widget falls back to when the param is omitted — if there's a default/fallback that isn't the shared repository (e.g. an empty list, or a re-introduced hardcoded list), this is a FAIL regardless of what happens when the param is supplied correctly, because it means the hardcoded-list bug can silently reappear.
5. **Metode Clearing** — Confirm the defaults list is exactly 3 items, no more, no fewer, and matches the 3 named values exactly (not renamed/retranslated versions).
6. **Laporan buttons** — Check all 5 relevant screens (the 4 fixed + Attendance as reference). Confirm all use identical `FButton(variant: ghost)` styling — flag if one screen's implementation diverges stylistically from the others even if each individually passes.
7. **FAB removal** — Confirm no `FloatingActionButton` widget remains anywhere in `cut_fill_list_screen.dart` or `land_clearing_list_screen.dart`, and confirm the `FHeader` add button (from item 1's pattern) is still present and functional as the sole add control on these two screens.
8. **Attendance round-trip** — Trace the actual parsing logic: does it correctly extract the position from the `remarks` string format for a real saved record, and does the dropdown's `initialValue`/`value` genuinely bind to the parsed result (not just compute it and leave it unused)? Check for the case where `remarks` doesn't match the expected `[Position] ...` format (e.g. legacy records) — does it fail gracefully or crash/default silently?
9. **Inventory merge — FLAGGED RISK** — Confirm `suffixBuilder` (or whatever mechanism was used) actually produces a genuinely tappable/interactive dropdown, not a static icon that merely looks like one. If ForUI's `FTextField` suffix slot doesn't support interactive widgets, report exactly what was built instead and whether it functions as a real unit selector or is cosmetic only.
10. **Equipment Check tabs** — Confirm the scroll wrapper is present AND that it actually prevents truncation for the longest equipment type label in the app (not just the one from the original screenshot). Check if `ConstrainedBox(minWidth: 110)` is sufficient for the longest label, or if a longer label would still clip within that fixed minimum width.

## Output format

One row per item (1–10): **Status** (PASS/FAIL/PARTIAL), **Evidence** (file + line range), **What was actually verified**, **Any remaining gap**.

End with: overall count of PASS/FAIL/PARTIAL, and an explicit yes/no on whether STEP-38 can now be re-closed per its remediation doc's re-closure criteria.
