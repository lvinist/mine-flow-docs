# STEP-38 — Remediation (Reopened)

**Phase:** 2 — Impeccable UI Rebuild
**Tier:** 3
**Status:** REOPENED — spec-drift audit found 6 FAIL + 4 PARTIAL out of 19 substeps originally marked done
**Supersedes:** original STEP-38 completion sign-off
**Audit basis:** STEP-38 Spec-Drift Audit (code-only items, Claude Sonnet 4.6) + vision audit (inventory/equipment-check items, Gemini 3.1 Pro) + Benchmark-nav follow-up (PASS, no action needed)

## Background

STEP-38 was marked complete by the executor, but a targeted drift audit against this plan found that roughly half the substeps were closed on a shallow acceptance check (e.g. "a button with an icon exists") rather than the actual spec (e.g. "the button is specifically an `FButton`, not a Material `IconButton`"). This doc formally reopens STEP-38, replacing prior sign-off, and defines the exact remaining work as a fix spec. STEP-38 is not considered closed again until every item below is re-verified against this doc, not against the original acceptance notes.

## Scope note

Of the original 19 items, 9 were re-verified as genuine PASS (Language config, Breadcrumbs, Attendance page-vs-inline, Cut/Fill relabel, Cut/Fill row layout, Cut/Fill stepper removal, Plan/Actual stepper removal, Land Clearing tabs, Benchmark nav) and require no further action. This doc covers only the 10 items requiring a fix.

---

## Fix items

### 38.1 — Data Bucket list uses Material `AppBar`, not `FAppBar`
- **Status:** PARTIAL → fix required
- **File:** `lib/features/data_bucket/presentation/pages/data_bucket_list_page.dart` (~L81–L128)
- **Current:** `FButton` ("Upload File", icon + label) sits inside a Material `AppBar`, which is only rendered on narrow screens — no add button exists at all on desktop (`>800px`).
- **Required:** Replace Material `AppBar` with ForUI `FAppBar`, matching the Cut/Fill and Land Clearing list screen pattern. Ensure the add button renders on all breakpoints, not narrow-only.
- **Acceptance:** `FAppBar` present; add button visible and functional on both mobile and desktop widths.

### 38.1 — Upload Form back button uses Material `AppBar` + `IconButton`, not `FAppBar` + ghost `FButton`
- **File:** `lib/features/data_bucket/presentation/pages/upload_file_page.dart` (~L228–L248)
- **Current:** Material `AppBar` with `IconButton(Icons.arrow_back)`.
- **Required:** `FAppBar` with title "Upload File" and a leading ghost-variant `FButton` (`Icons.arrow_back`, calls `context.pop()`), matching Cut/Fill and Land Clearing forms.
- **Acceptance:** Widget tree uses `FAppBar` + `FButton(variant: ghost)`, not Material equivalents.

### 38.1 — Inventory list uses Material `AppBar` and has a redundant FAB
- **File:** `lib/features/tracking/presentation/pages/inventory_dashboard_screen.dart` (~L67–L168)
- **Current:** `FButton` ("Tambah Item") exists in a Material `AppBar`; a second `FButton` also exists as a `floatingActionButton` in the body — two add controls for one action.
- **Required:** `FAppBar` (not Material `AppBar`) with the add `FButton` in its actions only. Remove the body FAB entirely.
- **Acceptance:** Exactly one add control, in `FAppBar` actions, ForUI components throughout.

### 38.2 — Data Bucket Zona field uses a hardcoded static list instead of `ZoneRepository`
- **File:** `lib/features/data_bucket/presentation/pages/upload_file_page.dart` (~L85–L91, L265–L287)
- **Current:** `CreatableCombobox<String>` backed by a hardcoded `_availableZones` list (`'PIT Rusia'`, `'Soil Bank Sochi'`, `'Area Barat'`, `'Area Timur'`) — not connected to `ZoneRepository`.
- **Required:** Rewire to use `ZoneCubit` + `ZoneRepository`, matching the Daily Log form's zone source exactly — one shared source of truth across all forms.
- **Acceptance:** Data Bucket, Cut/Fill, Land Clearing, and Daily Log all read zones from the same `ZoneRepository`-backed cubit; no hardcoded zone lists remain anywhere in the app.

### 38.2 — Metode Clearing has 6 default options instead of the specified 3
- **File:** `lib/features/tracking/presentation/pages/land_clearing_entry_screen.dart` (~L78–L85)
- **Current:** `_clearingMethods = ['Bulldozer', 'Excavator', 'Manual Tree Felling', 'Chainsaw', 'Grader', 'Lainnya']`.
- **Required:** Reduce hardcoded defaults to exactly `['Excavator', 'Bulldozer', 'Chainsaw']`. Widget stays `CreatableCombobox` (users may still add custom values at runtime) — only the seeded defaults are in scope here.
- **Acceptance:** Default list contains exactly these three values, in this set.

### 38.1 — Laporan button uses Material `IconButton` instead of ghost `FButton` (4 of 5 screens)
- **Files:** `data_bucket_list_page.dart` (~L115–L127), `cut_fill_list_screen.dart` (~L119–L131), `land_clearing_list_screen.dart` (~L118–L130), `inventory_dashboard_screen.dart` (~L110–L123)
- **Current:** Raw Material `IconButton`. (Attendance screen already correctly uses `FButton(variant: ghost)` — use it as the reference implementation.)
- **Required:** Replace all four with `FButton(variant: ghost, child: Icon(...))`, positioned to the right of the add `FButton`, matching Attendance's existing pattern.
- **Acceptance:** All 5 list screens use the identical ghost-`FButton` pattern for Laporan.

### 38.1 — Add-data FABs are icon-only on mobile (Cut/Fill, Land Clearing)
- **Files:** `cut_fill_list_screen.dart` (~L140–L210), `land_clearing_list_screen.dart` (~L139–L210)
- **Current:** On narrow/mobile widths, a plain Material `FloatingActionButton` with icon only (no label) renders in addition to the `FAppBar` add button.
- **Required:** Every add-data control must show icon + label per spec. Either give the FAB a label (extended FAB) using `FButton`, or remove the FAB entirely in favor of the `FAppBar` button (preferred, for consistency with Data Bucket/Inventory once 38.1 items above are fixed).
- **Acceptance:** No icon-only add controls remain anywhere in the app; exactly one add control per screen, consistent with the rest of the fixes above.

### 38.6 — Attendance form doesn't round-trip saved position when editing
- **File:** `lib/features/attendance/presentation/pages/attendance_form_page.dart` (~L44–L65, L156–L229)
- **Current:** On edit, `_nameController` correctly loads `rec?.userName`, but the position `DropdownButtonFormField` defaults to `_kPositions.first` regardless of the record's actual stored position (encoded in `remarks` as `[Position] ...`).
- **Required:** Parse the stored position out of the existing record and pre-select it in the dropdown when editing.
- **Acceptance:** Opening an existing attendance record for edit shows the position it was actually saved with, not always the first list item.

### 38.7 — Inventory Jumlah/Satuan fields not merged (vision-audited)
- **File:** `lib/features/tracking/presentation/pages/inventory_item_entry_screen.dart` (~L304–L371)
- **Current:** Quantity (`FTextField`, flex 3) and unit (`DropdownButton` in a `Container`, flex 2) are two separate sibling widgets in a `Row`.
- **Required:** Merge into a single cohesive field — unit selector as an inline suffix/trailing element inside the quantity `FTextField`, not a sibling widget. Verify ForUI's `FTextField` suffix slot supports an interactive (tappable) widget before committing to this approach; if it only supports static suffix icons, build a small composite widget instead.
- **Acceptance:** Quantity and unit render as one visually unified control, matching the reference design.

### 38.8 — Equipment Check form broken on mobile (vision-audited)
- **File:** `lib/features/equipment_check/presentation/widgets/equipment_type_tabs.dart` (~L40–L91)
- **Current:** Tab labels (e.g. "GNSS Receiver") are clipped/ellipsized on narrow screens; `Row` + `Expanded` layout doesn't give labels enough width.
- **Required:** Fix structurally, not just for the one label that happened to clip — wrap tabs in a horizontally scrollable container (`SingleChildScrollView(scrollDirection: Axis.horizontal)`) or equivalent wrapping mechanism so any future equipment type label, regardless of length, degrades gracefully on small screens.
- **Acceptance:** No tab label truncates on the smallest supported mobile width; layout holds for labels longer than any current equipment type name.

---

## Re-closure criteria

STEP-38 may be marked done again only when all 10 items above pass re-audit against this doc (not against the original substep checklist, which is now known to have been insufficiently strict). Recommend re-running the same audit-prompt pattern used to find these issues as the closing verification step, rather than trusting the executor's own "done" self-report.

## Next after this step

Once STEP-38 is re-closed, resume Phase 2 Tier 3 planning for the remaining feature/bugfix/QoL backlog.
