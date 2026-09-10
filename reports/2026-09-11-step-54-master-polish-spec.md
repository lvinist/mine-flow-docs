# mine-flow — STEP-54 Master Polish Specification

**Date:** 2026-09-11
**Author:** STEP-54.11 consolidation
**Status:** Approved for STEP-55 planning
**Applies to:** STEP-55 — Cohesive UI Rebuild
**Evidence revision:** `mine-flow-app` branch `step-0054-feature-cohesion-critique` at `fe12531931eed861518b20f7323c6cf6bd0ccb8b`
**Authority:** Doc 07 v0.5.0, the locked D1–D8 blueprint, accepted UI ADRs, and STEP-54 findings 54.1–54.10a
**Finding accounting:** 127/127 `FC-54.*` findings represented; STEP-54.0 is a pre-flight record with no critique IDs

**Review record:** The accountable user approved the specification and STEP-54 close on 2026-09-11 after requesting and reviewing these refinements: popover-first filters, in-context calendar dialogs, the simplified attendance sheet and reason model, structured Daily Log hazards, a tabbed Daily Log review workflow, canonical navigable breadcrumbs, and authenticated header identity.

## 1. Executive decision

STEP-55 shall replace the app's disconnected full-page form and report flows with one route-backed interaction system while preserving mine-flow's compact, data-dense ForUI design language:

- **Forms:** modal right-side sheets on Web/desktop and modal bottom sheets on Android/mobile.
- **Dirty forms:** one dismissal guard for close, scrim, Escape, browser back, Android back, and drag-to-dismiss.
- **Routing:** every create, edit, and applicable detail surface is reconstructable from a GoRouter URL without relying on `state.extra` for durable identity.
- **Reports:** feature-bound `FDialog` experiences that retain the originating list and filters behind the dialog; there is no generic report-type picker in normal feature flows.
- **Details:** route-backed inspectors are used only where inspection is materially different from editing. Dense Equipment and Inventory details receive full-page mobile treatment; shorter comparative records use inspector sheets.
- **Accessibility:** WCAG 2.1 AA is an evidence gate, not an assumption from ForUI. Desktop navigation and header semantics, field names, page language, 48dp targets, contrast, focus, and Android evidence must be demonstrated at runtime.

This specification does not authorize a new brand palette, a sixth mobile navigation tab, direct edits to generated `DESIGN.md`/`PRODUCT.md`, or any relaxation of the five-item mobile bottom-navigation contract. It does require limited non-cosmetic work where the critique found data-trust defects: benchmark projection validation, attendance sync-state honesty, immutable inventory adjustments, and privacy-notice gating.

### 1.1 Delivery priorities

| Priority | Meaning | STEP-55 examples |
|---|---|---|
| **P0 — integrity/release gate** | Must be resolved before STEP-55 can be accepted. | Inventory adjustment reason/history persistence; benchmark invalid-coordinate rejection; privacy notice gate with approved copy; authorization-header log redaction; desktop navigation/header accessibility. |
| **P1 — structural cohesion** | Required to satisfy D1–D7. | Responsive sheets, dirty intercept, URL reconstruction, report dialogs, D7 inspectors, notification reachability. |
| **P2 — operational polish** | Required for coherent field use. | Filter/scroll preservation, attendance bulk action, error/empty states, dashboard shortcuts, upload cancellation. |
| **P3 — token polish** | Required before the final Impeccable audit. | ForUI replacements, semantic badges, 48dp controls, copy and icon cleanup. |

### 1.2 Source reconciliation and adjudications

1. `FC-54.1-005` and `FC-54.1-006` are umbrella findings; feature-specific D5/D6 findings remain independently traceable.
2. Benchmark reporting is present and must migrate to D6; it is not a deliberate report absence.
3. Land Clearing needs a read-only inspector because inspection and editing must be separated. The earlier uncited role-specific rationale is not carried forward.
4. The Benchmark form is proven to be a full page rather than a responsive sheet; the unsupported claim that it necessarily obscures the shell is omitted.
5. Narrow Web captures are not Android evidence. Android authenticated-shell evidence remains owed.
6. The Impeccable DOM/CSS detector is non-authoritative for this CanvasKit app. Its no-signal result is an audit-method constraint, not an application defect to “fix.”
7. Existing aligned behavior is an explicit preservation requirement, not permission to rewrite it opportunistically.
8. The blueprint's STEP-55.9 shorthand mentions a milestone-entry sheet, but `FC-54.9-007` establishes Work Timeline as intentionally read-only for this release. The evidence-backed finding narrows that row: STEP-55.9 must not add milestone creation.
9. User review adds two cross-cutting interaction requirements for STEP-55: data filters must prefer a compact labelled popover menu over persistent filter pills/chip rows, and date/date-range selection must use an in-context calendar dialog rather than navigating to a calendar page. A filter pill is allowed only when it represents an active removable filter after selection, not as the primary selector.
10. Daily Log uses a role-aware **tabbed list**, not Kanban. Its statuses are a permissioned linear workflow (`Draft` → `Submitted` → `Approved`), so drag-and-drop columns would falsely imply that arbitrary status transitions are available. Tabs are more compact on Android, retain explicit approval intent, and make the supervisor review queue a first-class view.

## 2. Reusable responsive sheet contract — STEP-55.0

### 2.1 Component boundary

Create a shared `AppResponsiveSheet<T>` (name may change only if one canonical equivalent is documented) with these inputs:

- `routeIdentity`: create/edit/detail route identity and durable path parameters;
- `title`, optional `subtitle`, and semantic heading;
- `mode`: `form`, `readOnlyInspector`, or `selection`;
- `isDirty`, `isBusy`, and optional `onCancelBusyOperation`;
- `onRequestClose`, `onDiscard`, and optional `onSave`;
- body and footer builders with explicit scrolling ownership;
- optional `initialFocus`, restoration key, and focus-return target;
- platform detail override for the two approved full-page mobile inspectors.

The route owns whether the sheet is open. Opening and closing must not create a parallel local-only modal state that can disagree with the URL. `state.extra` may carry an already-loaded object as a performance hint, but an ID-bearing route must fetch by ID when `extra` is absent.

### 2.2 Web/desktop behavior (D1)

- Applies at viewport width **>= 800 logical pixels**.
- Opens from the right, inside the authenticated shell, with the left `FSidebar` unobstructed.
- Width is `clamp(480dp, 40vw, 600dp)`. The sheet must never force horizontal viewport overflow.
- The underlying list remains mounted, visibly dimmed, and inert. Its filters, selection, scroll offset, BLoC instance, and loaded data remain intact.
- Header and footer are fixed; only the body owns vertical scrolling. Nested feature controls may scroll only where their content model requires it.
- The close control is a labelled 48x48dp target. Escape requests dismissal through the same guard as every other close path.
- Opening moves focus to the semantic heading or first invalid/editable field. Closing returns focus to the invoking list action/card.

### 2.3 Android/mobile behavior (D2)

- Applies below 800 logical pixels on Android/mobile layouts.
- Uses a modal bottom sheet with a visible drag handle, safe-area padding, keyboard insets, and an internally scrollable body.
- Default initial extent is approximately 85% of available height; supported extent is 50%–95%. A feature may start taller for a long form but may not bypass the shared sheet.
- Drag-to-dismiss is enabled only when `isBusy == false`; it still passes through the dirty guard.
- Primary submit action remains reachable above the IME. A footer may pin only when it does not cover the final field or validation message.
- Android system back and predictive-back request the same guarded route pop.
- Approved exception: Equipment inspection detail and Inventory stock-history detail use a route-backed mobile full page because their long audit records are reading surfaces, not entry forms.

### 2.4 Modality and scrim (D3)

- Use one semantic modal-barrier token, not feature-local raw colors. Target opacity: 45% over light surfaces and 60% over dark surfaces, subject to contrast verification.
- The barrier has an accessible modal label and prevents pointer, touch, scroll, and keyboard interaction with background content.
- Opening/closing motion is 150–200ms. If reduced motion is requested, remove translation and use an immediate or minimal fade.
- A barrier tap requests close; it never directly pops the route.

### 2.5 Universal dirty-state contract (D4)

A form is dirty when user-editable state differs from the successfully loaded/saved baseline. Hydration, validation, focus changes, and programmatic formatting alone do not mark it dirty. A successful save resets the baseline. A failed save retains dirty state and user input.

All dismissal sources must call one `requestDismiss(reason)` path:

1. close/X button;
2. Cancel action;
3. Web scrim click;
4. Escape;
5. browser Back/Forward or route replacement;
6. Android system/predictive back;
7. bottom-sheet drag dismissal;
8. parent navigation or logout while the form route is active.

If clean and not busy, close immediately. If dirty and not busy, veto the route pop and show a plain `FDialog`:

- **Title:** `Perubahan belum disimpan`
- **Body:** `Perubahan yang belum disimpan akan hilang.`
- **Safe action:** `Lanjut Mengedit` — closes only the confirmation and restores focus/data.
- **Destructive action:** `Buang Perubahan` — clears the dirty state, performs exactly one pending route pop, and returns to the preserved list.

The safe action receives initial focus. The destructive action uses the destructive semantic style. The dialog itself is not dismissible by barrier tap or Escape; either action must be chosen.

If `isBusy`:

- a non-cancellable save disables dismissal and announces progress;
- an upload exposes a specific `Batalkan Unggahan` path, confirms cancellation if bytes may already have transferred, and does not misuse the dirty dialog;
- Daily Log pending auto-save must be flushed and awaited before close, or the user must receive the dirty dialog if the flush fails or remains pending.

### 2.6 GoRouter deep-link adapter (D5)

#### Canonical URL semantics

- Create: `<feature-base>/form`
- Edit: `<feature-base>/:id/form`
- Read-only detail: `<feature-base>/:id`
- Non-record batch forms may use `/form` plus stable query parameters.
- Query parameters represent reconstructable view state only. Repository objects, entities, callbacks, credentials, and service instances must never be URL state.
- IDs and queries must be parsed and validated. Missing/not-found/unauthorized IDs show a recoverable in-sheet error with `Kembali ke daftar`, not a crash or blank surface.
- A cold browser load must build the shell, list, and open sheet/detail from the URL. Back closes the sheet before leaving the list. Forward reopens it.
- Closing removes only the form/detail route segment and preserves list query/filter state.

#### Full route table

| Feature/surface | List route | Create route | Edit/detail route | Durable route state and fallback | Owner |
|---|---|---|---|---|---|
| Cut & Fill | `/operations/cut-fill` | `/operations/cut-fill/form` | edit `/operations/cut-fill/:id/form` | Fetch edit record by `id`; preserve list `from`, `to`, `zoneId`. No detail route. | 55.2 |
| Land Clearing | `/operations/land-clearing` | `/operations/land-clearing/form?tab=plan|actual` | detail `/operations/land-clearing/:id`; edit `/operations/land-clearing/:id/form?tab=plan|actual` | Fetch by `id`; default invalid/missing tab to `actual`; preserve date/zone filters. | 55.3 |
| Benchmark DB | `/operations/benchmark-db` | `/operations/benchmark-db/form` | detail `/operations/benchmark-db/:id`; edit `/operations/benchmark-db/:id/form` | Fetch by `id`; `extra` is optional cache only. | 55.4 |
| Crew Attendance | `/teams/attendance` | `/teams/attendance/form?date=YYYY-MM-DD&siteId=<id>` | N/A batch form | Missing date defaults explicitly to local current date; site defaults only when authorized. Preserve search/status/date. | 55.5 |
| Daily Logging | `/teams/daily-log` | `/teams/daily-log/form?date=YYYY-MM-DD` | edit/read-only `/teams/daily-log/:id/form` | Fetch by `id`; submitted/approved records render read-only in the same surface. Preserve date/status/scroll. | 55.6 |
| Equipment Checks | `/teams/equipment-check` | `/teams/equipment-check/form?siteId=<id>` | detail `/teams/equipment-check/:id` | Fetch detail by `id`; create derives authenticated foreman, never trusts a user ID from the URL. Preserve search/type/status. | 55.7 |
| Inventory | `/teams/inventory` | `/teams/inventory/form` | detail `/teams/inventory/:id`; edit `/teams/inventory/:id/form` | Fetch item and immutable adjustment history by `id`; preserve category. | 55.8 |
| Data Bucket | `/tools/data-bucket` | upload `/tools/data-bucket/upload` | detail `/tools/data-bucket/:id` | Existing routes become authoritative; fetch file by `id` when `extra` is absent. Preserve list scroll/filter. | 55.9 |
| Work Timeline | `/teams/timeline` | None | None | Read-only for this release; date range may remain list query/state. No fake form route. | 55.9 |
| Settings profile | `/settings` | `/settings/profile/form` | same route edits current user | Display name editable; role read-only/server-managed. | 55.10 |

**Traceability:** `FC-54.1-005`, `FC-54.2-002..004`, `FC-54.3-001..002`, `FC-54.4-002,004,007`, `FC-54.5-008..010`, `FC-54.6-005..007`, `FC-54.7-003`, `FC-54.8-001..002`, `FC-54.9-001..003`, `FC-54.10-012`, `FC-54.10a-014`.

### 2.7 Shared acceptance tests for 55.0

- Widget tests enumerate every dismissal reason in clean, dirty, busy, discard, and continue-editing states.
- Router tests cover direct create/edit/detail URLs, absent `extra`, invalid ID, unauthorized ID, refresh reconstruction, browser back/forward, and list-state preservation.
- Web tests assert right alignment and 480–600dp width at 800, 801, 1024, and 1280dp.
- Android tests assert bottom-sheet semantics, drag interception, system back, IME visibility, focus retention, and scroll-to-error.
- No feature may ship a local `Navigator.push(MaterialPageRoute(...))` form/detail path after its migration.

### 2.8 Shared filter and calendar contract

- **Filter entry:** list pages expose a labelled `Filter` action that opens a ForUI popover/menu anchored to the action on wide layouts and an equivalent compact modal selector where a narrow viewport cannot fit the popover accessibly. Do not render a permanent row of selectable filter pills as the primary filtering UI.
- **Filter contents:** group related criteria (for example zone, category, status, type, and date) in one menu with clear current values, `Terapkan`, and `Reset filter`. Applying filters preserves list scroll where safe and exposes a concise active-filter summary.
- **Active filters:** removable pills/chips may appear only after a filter is active, as status/clear affordances. They must not duplicate the whole option set or create horizontal overflow.
- **Dates:** selecting a date or date range opens a calendar dialog over the current page/sheet. The calendar must never spawn or route to a full calendar page. The dialog retains the originating state, supports keyboard/touch navigation, has explicit Cancel/Apply actions, and returns focus to the invoking control.
- **Date semantics:** single-date and range modes use one shared adapter, enforce valid min/max and start/end ordering, expose localized accessible names, and retain the prior value on cancellation.
- **Tests:** shared widget tests cover open/apply/reset/cancel, active-filter summaries, keyboard focus/trap/return, narrow layout, date bounds/range ordering, and no route change while either menu/dialog is open.

### 2.9 Navigable breadcrumb and authenticated identity contract

- **Breadcrumb structure:** render canonical product labels, not title-cased raw path segments. Begin with `Dashboard`, then the navigable group landing (`Operasional`, `Tim`, or `Alat`), feature, and current surface. Dynamic record IDs and literal route segments such as `form` must never be exposed as labels.
- **Navigation:** every ancestor crumb is a labelled link/button to its canonical route; only the current crumb is non-interactive and marked current. For `/teams/daily-log/:id/form`, for example, render `Dashboard › Tim › Log Harian › Edit Log`, where the first three crumbs navigate. Activating a crumb while a dirty sheet is open still passes through D4.
- **Routing/state:** ancestor navigation preserves applicable list query/filter state where available. Breadcrumb routes come from a centralized route-label/parent map, not string concatenation that can produce invalid paths.
- **Accessibility/responsiveness:** expose a breadcrumb navigation landmark with ordered items, current-page state, keyboard activation, visible focus, and 48dp targets. At constrained widths, collapse middle ancestors into an accessible overflow while retaining Dashboard/parent and current page; do not silently turn crumbs into plain clipped text.
- **Header profile:** the global header profile reads the authenticated `AuthState.user` and displays the same real `name` and localized `role` as Settings. It must never use hardcoded fallback identity (`Pengguna` / `Foreman`) once authenticated. Use a token-aligned avatar/initials, label the action with name and role, and navigate to Settings/profile. Loading and missing-profile states use explicit neutral placeholders without inventing a role.
- **Tests:** route-table tests cover every registered shell route, nested create/edit/detail routes, dynamic IDs, query preservation, current-item non-interactivity, dirty-form interception, overflow behavior, and parity between header and Settings identity.

## 3. Contextual report dialog architecture — STEP-55.1

### 3.1 Shared contract (D6)

Refactor the reusable configuration body out of `report_config_page.dart` into `AppContextualReportDialog` plus a presentation-neutral `ReportConfigContent`. Normal feature entry points call the dialog directly; they do not push `/reports/config`.

Required inputs:

- a non-null, pre-bound `ReportType`;
- source feature ID and semantic dialog title;
- initial date range and optional zone where the originating feature exposes them;
- an immutable snapshot of originating filters for diagnostics/tests;
- the existing reporting and zone dependencies from app services;
- completion callback for share/print/download outcomes.

Behavior:

- Keep the originating list route, widget tree, BLoC, filters, scroll, and selection mounted behind the scrim.
- Never display a report-type picker when opened from a feature.
- Prefill report-supported filters from the list. Unsupported list filters remain preserved behind the dialog but are not falsely presented as PDF filters.
- Date/zone changes inside the dialog do not mutate the list unless the user explicitly applies a future shared-filter action.
- Loading locks configuration controls, announces progress, and prevents duplicate generation.
- Error keeps configuration intact and offers retry. Success exposes share/print/download and `Tutup` without navigating away.
- Desktop dialog maximum width is 640dp; mobile uses an inset, safe-area dialog with internal scrolling and no clipped action row.
- Barrier, Escape, back, focus trap, focus return, 48dp actions, headings, and reduced motion follow the shared modal contract.
- The legacy standalone route may remain only as a compatibility redirect to an authenticated feature or explicit “Reports unavailable without feature context” state; it must not remain a generic type-picker workflow.

### 3.2 Report inventory

| Feature | Binding | Initial context | Deliberate treatment | Integration owner |
|---|---|---|---|---|
| Cut & Fill | `ReportType.cutFill` | active date range + zone | Required contextual dialog. | 55.2 |
| Land Clearing | `ReportType.landClearing` | active date range + zone | Required contextual dialog. | 55.3 |
| Benchmark DB | `ReportType.benchmark` | list remains mounted; use supported report parameters | Required; presence is verified, not absent. | 55.4 |
| Crew Attendance | `ReportType.attendance` | selected date/site; preserve search/status | Required contextual dialog. | 55.5 |
| Daily Logging | `ReportType.dailyLog` | new date filter; preserve status | Required contextual dialog. | 55.6 |
| Equipment Checks | `ReportType.equipmentCheck` | preserve search/equipment/status; pass supported date context | Required contextual dialog. | 55.7 |
| Inventory | `ReportType.inventory` | preserve category; pass supported report parameters | Required contextual dialog. | 55.8 |
| Data Bucket | None | N/A | **Deliberately absent:** no meaningful `ReportType`. | 55.9 preserve |
| Work Timeline | None | N/A | **Deliberately absent** for this release. | 55.9 preserve |

**Traceability:** `FC-54.1-006`, `FC-54.2-001`, `FC-54.3-004`, `FC-54.4-006`, `FC-54.5-011`, `FC-54.6-008`, `FC-54.7-005`, `FC-54.8-003,009`, `FC-54.9-008`, `FC-54.10a-015`.

## 4. Per-feature polish backlog — STEP-55.2 through 55.10

Each subsection is independently executable. Ordering is mandatory: integrity and restructuring precede local polish and token cleanup.

### 4.1 STEP-55.2 — Cut & Fill Volume Tracking

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | Move create/edit into the route-backed responsive sheet. | Canonical routes reconstruct without `extra`; Web and Android use their required sheet forms. | `FC-54.2-002,003` |
| 2 | Wire all dismiss paths to the universal dirty guard already backed by `hasUnsavedChanges`. | Close, Cancel, scrim, Escape, browser/Android back, and drag cannot silently discard. | `FC-54.2-004` |
| 3 | Replace report-route push with pre-bound Cut/Fill dialog. | Active date and zone are prefilled; list filters and scroll survive close. | `FC-54.2-001` |
| 4 | Preserve direct-to-edit D7 behavior. | Record activation opens `/:id/form`; no redundant inspector is introduced. | `FC-54.2-006` |
| 5 | Replace actionable Material FAB/date/text controls with shared ForUI controls; retain only documented interoperability. | No new raw colors or unapproved Material navigation. | `FC-54.2-005` |
| 6 | Runtime audit. | Verify contrast, 48dp targets, keyboard/focus, validation, both themes, and both platforms. | `FC-54.2-007` |

### 4.2 STEP-55.3 — Land Clearing Tracking

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | Implement URL-backed create/edit responsive sheets with D4. | `/form` and `/:id/form` reconstruct and guard all dismissal paths. | `FC-54.3-001` |
| 2 | Make Plan/Actual state restorable. | `tab=plan|actual` survives refresh/back; invalid values fall back safely. | `FC-54.3-002` |
| 3 | Add a route-backed read-only inspector before edit. | Web right inspector and mobile bottom inspector summarize both Plan and Actual; explicit `Edit` opens the edit route. | `FC-54.3-006` |
| 4 | Adapt the selection-only method combobox for mobile without enabling arbitrary creation. | CF-043 remains selection-only; narrow layout avoids keyboard occlusion. | `FC-54.3-003` |
| 5 | Use a pre-bound contextual Land Clearing report. | Date/zone context is prefilled and list state remains mounted. | `FC-54.3-004` |
| 6 | Replace Material tabs, date controls, FABs, and text fields with token-aligned controls. | ForUI semantics and compact density are preserved. | `FC-54.3-005` |
| 7 | Runtime audit. | Verify tab semantics, summary hierarchy, dark/light contrast, 48dp targets, combobox occlusion, sheet behavior, and focus. | `FC-54.3-007` |

### 4.3 STEP-55.4 — Benchmark Database

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | **P0:** Reject projection failure before persistence. | Null/invalid computed coordinates cannot submit and can never become `0.0, 0.0`; tests cover out-of-zone and malformed values. | `FC-54.4-001` |
| 2 | Migrate create/edit to the responsive sheet and ID-backed routes. | Cold edit route fetches by ID; dirty back/cancel is intercepted. | `FC-54.4-002,004,007`, `FC-54.10a-014` |
| 3 | Add a route-backed read-only benchmark inspector. | Coordinates, CRS, datum, order, status, and metadata are readable before an explicit Edit action. | D7 verdict from 54.4; `FC-54.4-002` |
| 4 | Improve CRS recovery copy. | Labels include datum (for example WGS84); errors identify out-of-bounds/zone mismatch and recovery. | `FC-54.4-008` |
| 5 | Replace report push with `ReportType.benchmark` dialog. | List remains mounted and no generic picker appears. | `FC-54.4-006` |
| 6 | Replace FAB/refresh/dropdowns and enlarge delete target. | Delete is labelled and >=48x48dp; selectors use shared ForUI vocabulary. | `FC-54.4-003,005` |
| 7 | Runtime audit. | Verify empty/error states, IME, target geometry, direct URLs, light/dark contrast, and inspector focus. | `FC-54.4-009` |

### 4.4 STEP-55.5 — Crew Attendance

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | Migrate the batch check-in form to a **simple** `/form?date&siteId` responsive sheet with D4. | Refresh reconstructs date/site; accidental dismissal cannot discard the batch; the form has one header row, one crew-card list, and one save footer rather than nested tabs or secondary pages. Use a form-only roster draft model whose status is nullable for crew without a record on that date; do not pre-mark a newly loaded roster as present. The persisted entity/DB status remains non-null after validation. | `FC-54.5-008..010` |
| 2 | Build the sheet header as one responsive row: date on the left, bulk attendance action on the right. | The left control shows the selected date and opens `AppCalendarDialog` without route change. The right action is labelled `Tandai Semua Masuk`; it marks every still-unset crew member as `Masuk` and never overwrites an explicit `Izin`, `Sakit`, or `Alpa` selection. On very narrow widths the row may wrap while preserving date-first reading order and 48dp targets. | `FC-54.5-006` plus user review |
| 3 | Render one compact card per crew member. | Each card shows the crew member's real name as the primary label and position/role as secondary information. Do not expose UUIDs in normal card copy. The full card has a stable accessible label and remains readable at 2.0x text scale. | `FC-54.5-005,012` plus user review |
| 4 | Put four explicit attendance choices directly in every card: `Izin`, `Sakit`, `Alpa`, and `Masuk`. | The persisted mapping is `leave`, `sick`, `absent`, and `present` respectively. Each option has text plus a distinct icon/semantic state, supports one-tap selection, and meets the 48dp target without relying on color. These are record-editing controls, not data-filter pills, so the popover-first filter rule does not hide them. | `FC-54.5-002..005` plus user review |
| 5 | Reveal a collapsible inline reason field only for `Izin` or `Sakit`. | Selecting either status expands an `FTextField` inside that crew card with the label `Alasan izin` or `Alasan sakit`; the reason is required, trimmed, and persisted through the existing attendance `remarks` field. Save focuses/scrolls to the first missing reason. Changing to `Alpa` or `Masuk` collapses and clears the conditional reason after confirmation when non-empty, preventing a stale reason from being saved against the wrong status. State/entity copying must support explicitly clearing `remarks` (not treat null as “keep old value”). | User review; existing `remarks` contract |
| 6 | **Data-trust escalation:** expose record sync state without cluttering the form. | Each changed card shows a compact queued/syncing/failed/synced indicator; failed state has a labelled retry action. Status uses text/icon and is separate from attendance choice. | `FC-54.5-007` |
| 7 | Preserve roster filters and list position across save/close/background refresh. | Search/status/date survive; refresh does not replace the list with a blocking loading screen. List filtering uses the shared popover-first pattern; attendance choices inside the form remain inline. | `FC-54.5-001` |
| 8 | Keep save behavior batch-oriented and validation-safe. | The footer action reads `Simpan Absensi (N Kru)`, remains reachable above the IME, and is disabled only during submission. It does not submit until every crew member has a status and every Izin/Sakit record has a reason. Errors remain on the sheet with user input intact. | `FC-54.5-009` plus user review |
| 9 | Preserve no separate D7 member inspector. | Attendance entry remains a direct, compact batch workflow; tapping a crew card does not navigate to another page. | `FC-54.5-005` |
| 10 | Use contextual attendance reporting. | Selected date/site seed the report dialog; list filters and position remain behind it. | `FC-54.5-011` |
| 11 | Runtime and regression audit. | Test fresh roster rows start unset; bulk action with mixed unset/existing exceptions; all four persisted status mappings; required/trimmed reason; explicit reason clearing and confirmation; dirty dismissal; sync announcements; calendar dialog; >=48dp targets; keyboard/focus/IME; 2.0x text; contrast; restoration; Web and Android. | `FC-54.5-004,013` |

### 4.5 STEP-55.6 — Daily Logging

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | Rework the list as a role-aware tabbed workflow, not Kanban. | Tabs are `Semua`, `Draft`, `Perlu Disetujui`, and `Disetujui`, each with a count. Foreman defaults to `Draft`/their own logs; Supervisor defaults to `Perlu Disetujui` and sees site-wide submitted logs. On narrow screens the tab control remains accessible without a horizontally overflowing filter-pill row. Status changes occur only through explicit actions, never drag-and-drop. | `FC-54.6-001` plus user review |
| 2 | Put date, zone, foreman, and other data filters in `AppFilterPopover`; date selection uses `AppCalendarDialog`. | Tabs express workflow status only. Other filters are grouped in the popover, preserve the selected tab and scroll, and can be reset. No full calendar page or status filter-pill row is spawned. | `FC-54.6-001` plus user review |
| 3 | Make each log card review-oriented. | Show date, foreman identity, zone, weather/hazard summary, updated time, and an icon+text status. Submitted cards visibly expose review eligibility to supervisors; cards remain read-only entry points until an explicit Edit/Approve action. | `FC-54.6-003,004` plus user review |
| 4 | Add an explicit **Supervisor-only `Setujui Log` action** for submitted logs. | The action is visible/enabled only when `AuthState.user.isSupervisor` and `status == submitted`; it opens a confirmation dialog naming the log/date/foreman, then dispatches the existing approval use case with the authenticated supervisor ID. It records `approved_by`, transitions exactly `submitted → approved`, prevents duplicate approval, shows progress/error/success, refreshes counts without losing tab/scroll, and works offline only if the queued state is shown honestly. Foremen and Crew never receive an approval control, and client hiding is backed by repository/RLS authorization. | User review; existing `ApproveDailyLogEvent` / repository contract |
| 5 | Migrate create/edit/read-only mode into route-backed responsive sheets. | Create `/form`, record `/:id/form`; submitted/approved records render read-only for foremen. A supervisor can inspect a submitted log before approving it; approved logs are immutable in this workflow. | `FC-54.6-005,007` |
| 6 | Apply dirty interception with auto-save semantics. | Pending auto-save flushes before close; failure retains input and invokes D4 rather than silently closing. | `FC-54.6-006` |
| 7 | Implement the reviewed structured hazard contract. | The product/data design defines persisted presence, severity, notes/actions, reporting semantics, migration, mapping, offline storage, and tests before UI work. Provide an explicit “Tidak ada bahaya” state; STEP-55.6 must not invent schema fields or ship a UI that cannot persist its claims. Weather remains single-select. | `FC-54.6-002` |
| 8 | Preserve icon+label weather semantics while replacing `ChoiceChip`. | Selection never relies on color alone. | `FC-54.6-003` |
| 9 | Use contextual Daily Log report and ForUI actions/fields/date control. | Selected date/filter context seeds the dialog; no `MaterialPageRoute`, FAB, or unbounded Material form control remains. | `FC-54.6-008,009` |
| 10 | Preserve coherent field grouping and validate long-text ergonomics. | Summary/notes/hazard editors remain usable with Android IME and sheet drag disabled during text selection where necessary. | `FC-54.6-004` |
| 11 | Runtime and authorization audit. | Verify tab defaults/counts by role; supervisors see site review queue; foremen see own logs; approval appears only for submitted logs; submitted→approved and `approved_by` persist; duplicate/unauthorized approval fails safely; filters, deep links, scroll/drag, IME, long text, 48dp targets, focus, screen reader, contrast, both themes/platforms. | `FC-54.6-010` plus user review |

### 4.6 STEP-55.7 — Equipment Digital Checks

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | Replace inline `ExpansionTile` detail with route-backed inspection detail. | Web opens a right-side read-only inspector; Android opens a full page. Both fetch by ID and show 15–30 checklist results, remarks, metadata, inspector, and timestamp. | `FC-54.7-001` |
| 2 | Migrate the long SOP form to the responsive sheet and reconstructable route. | Site context is durable/authorized; every dirty close is guarded; long checklist scroll owns one clear boundary. | `FC-54.7-003` |
| 3 | Standardize status bands and PASS/FAIL controls. | Use shared semantic badges and labelled >=48dp selection controls; status is never color-only. | `FC-54.7-002,004` |
| 4 | Open `ReportType.equipmentCheck` contextually. | Search/equipment/status list state survives and no standalone route is pushed. | `FC-54.7-005` |
| 5 | Remove actionable Material residuals. | Search, expansion replacement, primary actions, and taps use ForUI/shared controls. | `FC-54.7-006` |
| 6 | Runtime audit. | Measure contrast, long-list focus/reading order, targets, sheet scrolling, full-page mobile detail, and report dialog. | `FC-54.7-007` |

### 4.7 STEP-55.8 — Inventory Management

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | **P0:** persist immutable stock-adjustment transactions and update stock atomically. | Every adjustment records item ID, signed delta, reason, actor, server timestamp, and idempotency key; quantity update and ledger insert share one transaction/RPC; failures change neither. | `FC-54.8-005` |
| 2 | Add route-backed stock-history detail. | Web uses a right inspector; Android uses a full page; current item data and ordered immutable adjustment history are shown before Edit/Adjust actions. | `FC-54.8-007` |
| 3 | Migrate item create/edit to responsive sheets with D4/D5. | `/form` and `/:id/form` reconstruct; category/filter/list position survive. | `FC-54.8-001,002` |
| 4 | Preserve the existing contextual stock-adjustment dialog pattern. | Current/next stock preview and explicit Cancel/Confirm remain; transaction persistence is added without turning it into a full page. | `FC-54.8-009` |
| 5 | Differentiate `out of stock` from `low/reorder`. | Domain/presentation exposes separate states with icon, text, semantic label, and tested thresholds. | `FC-54.8-004` |
| 6 | Use contextual inventory report. | Category remains preserved behind the dialog; only supported report parameters are shown. | `FC-54.8-003` |
| 7 | Keep current module placement. | No opportunistic feature-folder refactor; dedicated Inventory BLoC boundary remains. | `FC-54.8-006` |
| 8 | Replace residual Material fields/FABs and repair card actions. | Numeric keyboard behavior remains; adjust/delete are labelled >=48dp controls. | `FC-54.8-008,010` |
| 9 | Runtime audit. | Verify dialog dismissal/sizing, numeric IME, detail history, focus, contrast, screen reader, targets, both platforms. | `FC-54.8-011` |

### 4.8 STEP-55.9 — Data Bucket and Work Timeline

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | Make existing Data Bucket upload/detail routes authoritative. | Callers use GoRouter; direct detail fetches by ID; list refresh, scroll, and filter context survive. | `FC-54.9-001,006` |
| 2 | Migrate upload to responsive sheet with D4. | Selected file/date/metadata mark dirty; accidental close is intercepted; Web/right and Android/bottom behavior conform. | `FC-54.9-002` |
| 3 | Add explicit upload cancellation. | Busy upload presents `Batalkan Unggahan`; cancellation outcome is honest and partial-upload cleanup/retry is defined. | `FC-54.9-003` |
| 4 | Preserve retry and size feedback. | `Coba Lagi` retains selected bytes; 50MB validation and human-readable size remain. | `FC-54.9-004,005` |
| 5 | Convert file detail to route-backed inspector. | Web right inspector and Android bottom inspector keep the list beneath; Delete/Open in Drive remain explicit. | D7 verdict from 54.9 |
| 6 | Keep Work Timeline read-only and keep reports absent for both features. | No milestone form or fake report action is added in STEP-55. | `FC-54.9-007,008` |
| 7 | Replace Data Bucket FAB/date decorator and Timeline `InkWell`. | Use ForUI/shared controls or a documented narrow interoperability boundary. | `FC-54.9-009` |
| 8 | Runtime audit. | Verify keyboard traversal, contrast, Drive-unavailable state, retry/cancel, detail inspector, both platforms. | `FC-54.9-010` |

### 4.9 STEP-55.10 — Shell, Dashboard, Notifications, Settings, and Auth

| Order | Specification item | Acceptance | Finding IDs |
|---:|---|---|---|
| 1 | **P0:** make desktop shell navigation and global header controls real accessibility nodes. | AX tree exposes a navigation landmark, every destination, search, theme, notifications, profile, names/roles, selected state, and keyboard activation. | `FC-54.10a-001,002` |
| 2 | Provide consistent mobile global-control and notification reachability without adding a sixth bottom tab. | Keep five tabs; expose a persistent labelled notification action/badge from every authenticated mobile shell route or an equivalent stable control. | `FC-54.1-001,003`, `FC-54.10-006,009`, `FC-54.10a-007,008` |
| 3 | Repair desktop group/selected/collapse behavior. | `/tools`, `/operations`, `/teams` show a parent/section active state; collapsed sidebar has a persistent reopen affordance, focus order, and keyboard behavior. | `FC-54.1-002,004` |
| 4 | Make the four KPI cards actionable. | Attendance, Cut/Fill, Equipment Check, and Notifications cards expose button/link semantics and navigate to their declared routes. | `FC-54.10-001`, `FC-54.10a-009` |
| 5 | Keep four cards as the intentionally scoped KPI set and add a compact “Workflow shortcuts” group for the other five operational features. | No invented KPI definitions; all nine workflows remain discoverable without crowding the primary metric row. | `FC-54.10-002` |
| 6 | Separate loading, failure, first-use, and real-zero states; add refresh. | Failure has retry, first-use has an entry CTA, zero remains valid, pull/manual refresh preserves content. | `FC-54.10-003..005` |
| 7 | Preserve notification state handling and actions while moving card activation to `FTappable`. | Loading/empty/error, read/unread, individual dismiss, and `Tutup Semua` remain; warning uses the shared warning role. | `FC-54.10-007,008,010,011` |
| 8 | Add profile edit sheet. | Display name is editable through `/settings/profile/form`; role remains visibly server-managed and non-editable. | `FC-54.10-012` |
| 9 | Preserve all three theme modes and locale wiring; fix system-theme reactivity. | Light/Dark/System remain; active OS brightness changes re-render without requiring a settings emit. | `FC-54.10-013`, `FC-54.10a-010,011` |
| 10 | Simplify logout and configuration polish; make header identity truthful. | Plain `FDialog` (no nested `FAlert`), awaited sign-out preserved, support contacts configured rather than hardcoded, token-aligned avatar, and header profile bound to authenticated user name/role with parity to Settings. Remove hardcoded `Pengguna` / `Foreman`; profile action navigates to Settings and exposes name/role to AT. | `FC-54.10-015..017,022`, `FC-54.10a-018` plus user review |
| 11 | **P0 privacy gate:** implement first-login notice acknowledgement. | Before dashboard access, show approved Terms/Privacy copy sourced from Doc 17/product/legal review, version it, record acknowledgement, permit sign-out, and do not claim legal approval from this spec. | `FC-54.10-018`, `FC-54.10a-017`; RISK-0011 |
| 12 | Fix login keyboard/error/accessibility behavior. | Password Done submits; error clears/dismisses; title is heading; email/password have explicit accessible names; document language is `id` for Indonesian UI. | `FC-54.10-019..021`, `FC-54.10a-003..005` |
| 13 | Enforce shared 48dp targets on sampled undersized controls. | Show-password, Masuk, locale, and logout actions meet project target without clipping. | `FC-54.10a-006` |
| 14 | Keep Material interoperability narrow and stop new hardcoded strings. | Shared shell/sheet/dialog work uses ForUI; all new strings enter localization. Existing migration remains RISK-0004. | `FC-54.1-007,008`, `FC-54.10-024` |
| 15 | **P0 evidence pre-flight:** redact sensitive HTTP headers. | `Authorization`, `apikey`, cookies, and tokens are suppressed/redacted before another Android capture; raw secrets never enter artifacts. | `FC-54.10a-016` |
| 16 | Audit-only method constraint. | Do not use clean Impeccable detector output as a pass for CanvasKit; use screenshots, AX/semantics, interaction, and measured geometry. | `FC-54.10a-019` |
| 17 | Runtime audit. | Test 799/800/801dp, Android authenticated shell, light/dark/system, locale, text scale, contrast, motion, focus, and screen reader. | `FC-54.1-009,010`, `FC-54.10-023,024`, `FC-54.10a-012,013` |
| 18 | Replace display-only breadcrumbs with canonical navigable breadcrumbs. | Ancestors navigate through the centralized route-parent map; current item is non-interactive; raw IDs/form segments are hidden; dirty sheets intercept crumb navigation; compact overflow remains keyboard/screen-reader usable. | User review |

## 5. D7 detail-view verdicts

| Feature/surface | Verdict | Platform presentation | Rationale | STEP-55 |
|---|---|---|---|---|
| Cut & Fill | No separate inspector | Direct list → edit sheet | Scalar record; inspector adds an unnecessary step. | 55.2 |
| Land Clearing | Read-only inspector | Web right sheet; Mobile bottom sheet | Separate Plan/Actual inspection from editing and reduce accidental edits. | 55.3 |
| Benchmark DB | Read-only inspector | Web right sheet; Mobile bottom sheet | Survey coordinates are frequently checked without intent to edit. | 55.4 |
| Crew Attendance | No per-member inspector | Inline roster controls | One-tap batch field workflow is primary; history remains reporting scope. | 55.5 |
| Daily Logging | Existing form doubles as detail | Web right sheet; Mobile bottom sheet; submitted/approved mode read-only | Avoid duplicate surface while retaining inspect-before-edit state. | 55.6 |
| Equipment Check | Dedicated route-backed detail | Web right inspector; **Mobile full page** | 15–30 checklist items and defect notes need stable reading space and deep links. | 55.7 |
| Inventory | Dedicated stock-history detail | Web right inspector; **Mobile full page** | Immutable transactions can be long and must be distinct from edit/adjust actions. | 55.8 |
| Data Bucket | File-detail inspector | Web right sheet; Mobile bottom sheet | Comparative metadata review benefits from retained list context. | 55.9 |
| Work Timeline | N/A | Read-only list | Milestone creation/detail is not in this release. | 55.9 |
| Dashboard, Notifications, Settings, Login | N/A | Existing surfaces | Aggregate/self-contained/system surfaces are not record inspectors. | 55.10 |

## 6. Design tokens and shared component gaps

### 6.1 Canonical token additions for Doc 07 v0.5.0

These are semantic application roles layered on ForUI Zinc, not brand-palette overrides:

| Token/role | Use | Constraints |
|---|---|---|
| `modalBarrier` / `modalBarrierDark` | Sheet/dialog scrim | 45% light / 60% dark starting values; verify visually and with focus modality. |
| `statusSuccess` | present, synced, pass, completed | Always paired with icon/text. |
| `statusWarning` | leave, low stock, pending, warning notification | Amber-family semantic role; never substitute Zinc `secondary`. |
| `statusInfo` | informational/in progress | Always paired with label. |
| `statusDestructive` | failed, absent where appropriate, out of stock, critical | Use existing destructive role; never color-only. |
| `controlMinTarget` | all interactive controls | 48x48 logical pixels on both platforms for this project. |
| `sheetDesktopMin/Max` | right sheet | 480/600dp. |
| `responsiveShellBreakpoint` | shell/sheet switch | 800dp, tested at 799/800/801. |
| `motionFast` | sheet/dialog transitions | 150–200ms; reduced-motion alternative required. |

### 6.2 Shared components

| Component | Required responsibility | Finding drivers |
|---|---|---|
| `AppResponsiveSheet` | D1–D5, focus, scroll, route, modal, busy/dirty behavior. | Cross-feature route/sheet findings |
| `AppDirtyDismissDialog` | Exact copy/actions and one guarded close path. | D4 findings |
| `AppContextualReportDialog` | Pre-bound report config and preserved list context. | D6 findings |
| `AppDetailInspector` | Read-only header/body/action pattern; platform override. | D7 findings |
| `AppStatusBadge` | semantic role + icon + text + screen-reader label. | Attendance, Equipment, Inventory, Notifications |
| `AppAccessibleIconButton` | labelled >=48dp action with tooltip/focus. | Benchmark, Inventory, Login, shell |
| `AppSyncStatusBadge` | queued/syncing/failed/synced with retry. | Attendance offline honesty |
| `AppStatePanel` | distinct loading, first-use, empty-filter, error/retry states. | Dashboard and feature state findings |
| `AppPlatformSelect` | compact Web selector and mobile-safe bottom picker. | Land Clearing and form selector gaps |
| `AppFilterPopover` | grouped data filters, Apply/Reset, and active-filter summary without persistent option-pill rows. | User review gate; all list/dashboard surfaces |
| `AppCalendarDialog` | in-context single-date/date-range selection with no calendar route/page. | User review gate; all date controls |

### 6.3 Preservation rules

- Continue ForUI Zinc, Geist/default ForUI typography, Lucide icons, compact spacing, 1px borders, and monospaced/tabular numeric presentation.
- Preserve the five mobile tabs and theme structural consistency already verified.
- Preserve icon+label weather states, Data Bucket retry/size validation, Inventory stock preview, Notification loaded states/actions, and awaited logout.
- Do not expand Material usage. A retained primitive needs an adjacent justification and no suitable shared/ForUI equivalent.

## 7. STEP-55.11 accessibility and platform acceptance gate

### 7.1 Required runtime matrix

| Dimension | Required cases |
|---|---|
| Web widths | 799, 800, 801, 1024, and >=1280 logical px; at least 720px height where practical. |
| Android | Pixel_6a portrait, authenticated supervisor and field-role paths where credentials permit. |
| Themes | Light, Dark, and live System-mode brightness change. |
| Text | 1.0x, 1.3x, and 2.0x scale on representative long forms/details. |
| Input | Mouse, keyboard-only Web, touch, Android back/predictive back, IME. |
| Routes | create/edit/detail cold URL, refresh, back, forward, invalid ID, unauthorized ID. |
| States | loading, first-use empty, filtered empty, validation, backend error/retry, success, dirty, busy, offline queued/failed. |

### 7.2 Checkable acceptance criteria

1. **Contrast:** measure WCAG 2.1 AA: 4.5:1 normal text, 3:1 large text, and 3:1 essential UI/focus indicators. Screenshots alone do not pass contrast.
2. **Targets:** every interactive control is at least 48x48 logical pixels. Record measured exceptions as failures.
3. **Semantics:** desktop AX tree exposes navigation and header controls; mobile exposes five labelled tabs; dialogs announce title and modality; fields have stable explicit names; statuses and errors announce useful text.
4. **Language:** Web document language matches active locale (`id` for Indonesian). Mixed hardcoded surfaces remain a recorded RISK-0004 limitation, not a false localization pass.
5. **Keyboard:** logical traversal, visible focus, Enter/Space activation, Escape through guard, modal focus trap, and focus return to invoker.
6. **Screen reader:** verify login, desktop shell navigation, one form, one long inspector, one report dialog, an error, and a status update on supported platform accessibility tooling.
7. **Responsive layout:** no clipping, overflow, inaccessible footer, nested scroll trap, sidebar obstruction, or bottom-sheet/IME collision.
8. **Motion:** transitions measure 150–200ms; reduced motion removes spatial movement and does not hide state changes.
9. **Theme:** no structural or content loss across light/dark; System responds live.
10. **Routing:** no durable behavior relies exclusively on `state.extra`; URL round trips reconstruct identity and safe context.
11. **Dirty guard:** every dismissal source behaves identically, exact Indonesian copy is present, and discard pops exactly once.
12. **Security evidence:** HTTP headers are redacted before capture; artifacts contain no credentials, production PII, tokens, or operational secrets.
13. **CanvasKit review:** use real byte/dimension-checked screenshots, browser AX/`flt-semantics`, device interaction, and geometry/contrast measurements. `impeccable detect` produces no meaningful CanvasKit signal and cannot be a pass criterion.
14. **Filters and dates:** every rebuilt list uses popover/menu-first filtering; option-pill rows are absent, active removable pills are bounded, and every date/date-range selection stays in an accessible calendar dialog without a route/page transition.

### 7.3 Automated gates

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze` — 0 issues.
- `flutter test` — 100% pass, with targeted unit/widget/router tests added for every changed behavior.
- Web E2E through the documented `flutter drive`/chromedriver path with non-zero execution guard.
- Android E2E on Pixel_6a with non-zero execution guard.
- Successful Web release build and Android build.
- A durable Impeccable review report with real artifact byte sizes/dimensions and explicit remaining `Unverified` items.

## 8. Evidence and findings-accounting appendix

### 8.1 Consolidated accounting

| Slice | Finding range | Count | Verdict accounting | Disposition |
|---|---|---:|---|---|
| 54.1–54.4 | `FC-54.1-001`…`FC-54.4-009` | 33 | 2 Aligned, 12 Polish, 14 Restructure, 5 Unverified | Shared contracts + 55.2–55.4 + 55.11 |
| 54.5–54.8 | `FC-54.5-001`…`FC-54.8-011` | 41 | 4 Aligned, 13 Polish, 20 Restructure, 4 Unverified | 55.5–55.8 + 55.11 |
| 54.9–54.10a | `FC-54.9-001`…`FC-54.10a-019` | 53 | 12 Aligned, 15 Polish, 18 Restructure, 5 Unverified, 3 Escalations | 55.9–55.10 + 55.11 |
| **Total** | All critique IDs | **127** | **18 Aligned, 40 Polish, 52 Restructure, 14 Unverified, 3 Escalations** | **127/127 accounted** |

STEP-54.0 intentionally has zero critique IDs. It established the clean `fe12531` app baseline, 550 passed/5 skipped, analyzer/format cleanliness, and branch state.

### 8.2 Per-substep coverage and implementation handoff

| Substep | IDs/count | Core outcome | STEP-55 owner |
|---|---:|---|---|
| 54.1 | `001..010` / 10 | Rubric, shell, D5/D6 umbrellas, breakpoint debt. | 55.0, 55.1, 55.10, 55.11 |
| 54.2 | `001..007` / 7 | Cut/Fill sheet, route, guard, report, tokens, no D7 inspector. | 55.2, 55.11 |
| 54.3 | `001..007` / 7 | Land Clearing route/sheet/inspector/report/tabs/selector. | 55.3, 55.11 |
| 54.4 | `001..009` / 9 | Benchmark integrity, sheet, ID route, inspector, CRS/report. | 55.4, 55.11 |
| 54.5 | `001..013` / 13 | Attendance filter retention, bulk action, sync honesty, report/sheet. | 55.5, 55.11 |
| 54.6 | `001..010` / 10 | Daily Log filter, hazards, auto-save guard, route/report. | 55.6, 55.11 |
| 54.7 | `001..007` / 7 | Equipment detail split, SOP form, badges/targets/report. | 55.7, 55.11 |
| 54.8 | `001..011` / 11 | Inventory immutable ledger, detail, route/dialog/states. | 55.8, 55.11 |
| 54.9 | `001..010` / 10 | Data Bucket routes/upload/detail; Timeline read-only. | 55.9, 55.11 |
| 54.10 | `001..024` / 24 | Dashboard, notifications, settings, login/privacy. | 55.10, 55.11 |
| 54.10a | `001..019` / 19 | Runtime/AX evidence, Android blocker, contrast/motion debt, detector limit. | 55.10, 55.11 |

### 8.3 Remaining `Unverified` obligations

| Finding IDs | Blocker at STEP-54 | STEP-55.11 obligation |
|---|---|---|
| `FC-54.1-009,010` | Static shell review only. | Visual/a11y audit and exact 799/800/801 width sweep. |
| `FC-54.2-007` | Cut/Fill targets/contrast/focus not run. | Web + Android form/report/runtime checks. |
| `FC-54.3-007` | Tabs, summary, targets, dark mode not run. | Platform and accessibility audit including selector occlusion. |
| `FC-54.4-009` | Benchmark empty/error/IME/contrast not run. | Runtime states and direct-link audit. |
| `FC-54.5-013` | Attendance restoration/targets/screen reader not run. | Both platforms, including sync-status announcement. |
| `FC-54.6-010` | Sheet drag/IME/deep link/a11y not run. | Long-form Android and Web audit. |
| `FC-54.7-007` | Equipment contrast/long-list traversal not run. | Checklist and inspector audit. |
| `FC-54.8-011` | Inventory dialog/detail/IME/a11y not run. | Dialog and stock-history audit. |
| `FC-54.9-010` | Data Bucket keyboard/contrast not run. | Chrome + Pixel_6a, including upload states. |
| `FC-54.10-023,024` | Partial runtime closure only; locale effect/text scale incomplete. | Complete utilities a11y and locale behavior record. |
| `FC-54.10a-012,013` | No contrast measurement or motion probe. | Measured contrast and reduced-motion evidence. |
| Android authenticated shell | Run stopped at secrets boundary. | Redact logging first, then capture and inspect actual Android shell; narrow Web is not a substitute. |
| Browser cold-start route reconstruction | Existing harness does not fully close RISK-0019. | Exercise true cold URL loads for representative create/edit/detail routes. |

### 8.4 Exact finding-ID traceability

The feature tables above sometimes use compact ranges. This manifest expands them so every source ID is mechanically searchable and assigned:

- **54.1 → 55.0/55.1/55.10/55.11:** `FC-54.1-001`, `FC-54.1-002`, `FC-54.1-003`, `FC-54.1-004`, `FC-54.1-005`, `FC-54.1-006`, `FC-54.1-007`, `FC-54.1-008`, `FC-54.1-009`, `FC-54.1-010`.
- **54.2 → 55.2/55.11:** `FC-54.2-001`, `FC-54.2-002`, `FC-54.2-003`, `FC-54.2-004`, `FC-54.2-005`, `FC-54.2-006`, `FC-54.2-007`.
- **54.3 → 55.3/55.11:** `FC-54.3-001`, `FC-54.3-002`, `FC-54.3-003`, `FC-54.3-004`, `FC-54.3-005`, `FC-54.3-006`, `FC-54.3-007`.
- **54.4 → 55.4/55.11:** `FC-54.4-001`, `FC-54.4-002`, `FC-54.4-003`, `FC-54.4-004`, `FC-54.4-005`, `FC-54.4-006`, `FC-54.4-007`, `FC-54.4-008`, `FC-54.4-009`.
- **54.5 → 55.5/55.11:** `FC-54.5-001`, `FC-54.5-002`, `FC-54.5-003`, `FC-54.5-004`, `FC-54.5-005`, `FC-54.5-006`, `FC-54.5-007`, `FC-54.5-008`, `FC-54.5-009`, `FC-54.5-010`, `FC-54.5-011`, `FC-54.5-012`, `FC-54.5-013`.
- **54.6 → 55.6/55.11:** `FC-54.6-001`, `FC-54.6-002`, `FC-54.6-003`, `FC-54.6-004`, `FC-54.6-005`, `FC-54.6-006`, `FC-54.6-007`, `FC-54.6-008`, `FC-54.6-009`, `FC-54.6-010`.
- **54.7 → 55.7/55.11:** `FC-54.7-001`, `FC-54.7-002`, `FC-54.7-003`, `FC-54.7-004`, `FC-54.7-005`, `FC-54.7-006`, `FC-54.7-007`.
- **54.8 → 55.8/55.11:** `FC-54.8-001`, `FC-54.8-002`, `FC-54.8-003`, `FC-54.8-004`, `FC-54.8-005`, `FC-54.8-006`, `FC-54.8-007`, `FC-54.8-008`, `FC-54.8-009`, `FC-54.8-010`, `FC-54.8-011`.
- **54.9 → 55.9/55.11:** `FC-54.9-001`, `FC-54.9-002`, `FC-54.9-003`, `FC-54.9-004`, `FC-54.9-005`, `FC-54.9-006`, `FC-54.9-007`, `FC-54.9-008`, `FC-54.9-009`, `FC-54.9-010`.
- **54.10 → 55.10/55.11:** `FC-54.10-001`, `FC-54.10-002`, `FC-54.10-003`, `FC-54.10-004`, `FC-54.10-005`, `FC-54.10-006`, `FC-54.10-007`, `FC-54.10-008`, `FC-54.10-009`, `FC-54.10-010`, `FC-54.10-011`, `FC-54.10-012`, `FC-54.10-013`, `FC-54.10-014`, `FC-54.10-015`, `FC-54.10-016`, `FC-54.10-017`, `FC-54.10-018`, `FC-54.10-019`, `FC-54.10-020`, `FC-54.10-021`, `FC-54.10-022`, `FC-54.10-023`, `FC-54.10-024`.
- **54.10a → 55.10/55.11:** `FC-54.10a-001`, `FC-54.10a-002`, `FC-54.10a-003`, `FC-54.10a-004`, `FC-54.10a-005`, `FC-54.10a-006`, `FC-54.10a-007`, `FC-54.10a-008`, `FC-54.10a-009`, `FC-54.10a-010`, `FC-54.10a-011`, `FC-54.10a-012`, `FC-54.10a-013`, `FC-54.10a-014`, `FC-54.10a-015`, `FC-54.10a-016`, `FC-54.10a-017`, `FC-54.10a-018`, `FC-54.10a-019`.

### 8.5 Escalations and accepted-risk treatment

| Escalation | Required disposition |
|---|---|
| Privacy notice absent — `FC-54.10-018`, `FC-54.10a-017`, RISK-0011 | P0 pre-release gate. Interaction can be implemented in 55.10, but notice content must be approved by the accountable product/legal authority; this specification is not legal advice or legal approval. |
| Android logging emitted anon-key headers — `FC-54.10a-016` | Redact/suppress sensitive headers before any further runtime evidence. Treat publishability of an anon key as irrelevant to logging hygiene. |
| Inventory discards adjustment reasons/history — `FC-54.8-005` | P0 data-integrity remediation with transactional persistence and tests; do not ship a visual history over fabricated or absent records. |
| Attendance lacks record-level sync truth — `FC-54.5-007` | Implement presentation sync state in 55.5; do not claim offline trust without queued/failed evidence. |
| Localization incomplete — `FC-54.1-008`, `FC-54.10-024`, RISK-0004 | Do not open a duplicate risk. New STEP-55 strings must be localized; full legacy migration remains separately tracked. |
| Existing screenshot placeholder risks — RISK-0015/0016/0023/0024 | 54.10a produced valid new captures but did not replace the committed STEP-48 placeholder set. Keep old artifacts explicitly invalid until separately replaced/cleaned. |

## 9. STEP-55 completion definition

STEP-55 is complete only when:

- all P0 and P1 items in this specification are implemented or explicitly escalated through the project's ADR/risk process;
- each feature section has direct tests and a traceability note to its `FC-54.*` IDs;
- every canonical URL reconstructs without an in-memory-only identity dependency;
- every form dismissal path uses the shared guard and exact approved copy;
- all seven supported report types open contextually, while Data Bucket and Timeline remain deliberately report-free;
- D7 presentation matches the verdict table on both platforms;
- no new unlocalized user-facing strings, raw colors, or unjustified Material navigation paths are introduced;
- the 55.11 matrix is executed with valid Web and Android evidence, measured contrast/targets, AX/screen-reader records, and honest `Unverified` handling;
- formatting, analyzer, unit/integration, dual-platform E2E, and build gates pass with non-zero journey execution;
- Doc 07, architecture/contracts, risks, migrations, generated database contract, and README/test records are updated wherever implementation changed their truth.

---

**Implementation handoff:** STEP-55 may be planned directly from §§2–7. Shared contracts belong to 55.0/55.1; feature sections map 1:1 to 55.2–55.10; all evidence debt and the CanvasKit-specific review method belong to 55.11.
