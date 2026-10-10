# STEP-38 — Remediation Addendum (Round 2)

**Status:** STEP-38 remains OPEN — re-audit found 7/10 PASS, 2 PARTIAL, plus 1 new out-of-scope gap surfaced during re-audit
**Basis:** STEP-38 Remediation Re-Audit (Claude Sonnet 4.6, file-verified)
**Relationship to original doc:** Adds 3 new items. Does not reopen items 2, 3, 5, 6, 7, 8, 9, 10 from the original remediation doc — those are confirmed PASS and closed.

## Why this addendum exists

Two of the original remediation's "fixed" screens (Data Bucket, Inventory) were done correctly. But the fixes were built by pattern-matching against Cut/Fill, Land Clearing, and Attendance as "already correct" reference implementations — and re-audit found two of those three references had the same class of bug the whole time, so it was never fixed anywhere. Nothing here is a regression; these are pre-existing gaps that surfaced only because the re-audit checked actual behavior instead of trusting the reference screens' assumed correctness.

---

## Addendum items

### 38.1b — Cut/Fill and Land Clearing list screens: add button disappears on desktop
- **Files:** `lib/features/tracking/presentation/pages/cut_fill_list_screen.dart`, `lib/features/tracking/presentation/pages/land_clearing_list_screen.dart`
- **Current:** `appBar: MediaQuery.of(context).size.width > 800 ? null : AppBar(...)` — on desktop (`>800px`), `appBar` is `null` and there is no replacement. The add `FButton` lives inside that `AppBar`'s `actions`, so it vanishes entirely on desktop. This is the identical bug originally found and fixed on Data Bucket — it was never actually fixed here despite these two screens being cited as the correct pattern to copy.
- **Required:** Replace the width-gated `AppBar`/`null` pattern with an unconditional `FHeader` (same approach used for Data Bucket and Inventory), so the add button renders at all breakpoints.
- **Acceptance:** Add button visible and functional on both narrow and desktop widths on both screens.

### 38.1c — Attendance form back button still Material `AppBar` + `IconButton`
- **File:** `lib/features/attendance/presentation/pages/attendance_form_page.dart` (~L152–L169)
- **Current:** Back navigation uses a raw Material `AppBar` with `IconButton(Icons.arrow_back)`. (Note: this is separate from the Laporan ghost-button on this same screen, which is already correct and not affected.)
- **Required:** Replace with `FHeader`/`FHeader.nested` + ghost `FButton` back arrow, matching the pattern applied to Upload Form (`upload_file_page.dart`).
- **Acceptance:** Attendance form uses `FButton(variant: ghost)` for back navigation, no Material `AppBar`/`IconButton` remaining.

### 38.2b — `ZonePicker` has no null-guard when `ZoneCubit` isn't provided
- **File:** `lib/features/data_bucket/presentation/pages/upload_file_page.dart` (~L57–L75), `lib/features/daily_log/presentation/widgets/zone_picker.dart`
- **Current:** When `zRepo` (from `zoneRepository ?? appServices?.zoneRepository`) resolves to `null`, `BlocProvider<ZoneCubit>` is skipped, but `ZonePicker` unconditionally calls `context.read<ZoneCubit>()` — throws `ProviderNotFoundException` if reached with no provider in the tree. Low severity in production (`appServices` is always initialized by then) but a real risk in tests or a broken init sequence.
- **Required:** Add a guard in `ZonePicker` (or at its call site) for the missing-cubit case — render a disabled/empty state with a visible warning instead of throwing.
- **Acceptance:** `ZonePicker` does not crash when no `ZoneCubit` is available in the widget tree; degrades to a visibly disabled state instead.

---

## Re-closure criteria (updated)

STEP-38 may be marked done once these 3 items pass re-audit, in addition to the 8 items from the original remediation doc that are already confirmed PASS (items 2, 3, 5, 6, 7, 8, 9, 10). No further reference-implementation assumptions should be taken at face value in this closing pass — verify each screen's actual current behavior directly.
