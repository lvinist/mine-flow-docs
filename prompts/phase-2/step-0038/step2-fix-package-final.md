# Phase 2 Tier 2 — Fix STEP/SUBSTEP List (Corrected, DeepSeek-Ready)

This is the final corrected version of Gemini's Step 2 fix package, with both
review corrections folded directly into the substep text. This is what goes to
DeepSeek V4 Flash High for execution — no further Gemini round-trip needed for
these corrections. (You can still forward this to Gemini afterward to fold
into mine-flow-docs for the doc trail, but DeepSeek can execute directly from
this file.)

---

## STEP-30.F: Final Impeccable Purge Fixes

**Goal:** Address Blocking Impeccable violations from Step 30 by completely excising legacy Material components.

- **Substep 30.6.F1: Purge Material from `app_theme.dart` and `crew_roster_item.dart`**
  - **Context:** A final cross-screen Material purge failed to catch legacy `ThemeData`, `Card`, and Material buttons. Both files are shared/foundational — used across multiple screens — so this fix carries visual-regression risk beyond a simple class swap.
  - **Action:**
    - In `app_theme.dart`: Delete all `ThemeData` definitions and raw Material theme properties. Only ForUI theming (`FThemeData`) should remain.
    - In `crew_roster_item.dart`: Replace raw `Card` with ForUI's `FCard` (or equivalent layout container). Replace `ElevatedButton`, `TextButton`, and `OutlinedButton` with `FButton` using standard styles.
    - Identify every screen/widget that consumes `app_theme.dart` or `crew_roster_item.dart` (grep for imports/usages) and list them in your execution notes.
  - **Definition of Done:**
    - [x] `app_theme.dart` contains exactly zero references to `ThemeData`.
    - [x] `crew_roster_item.dart` contains exactly zero references to `Card`, `ElevatedButton`, `TextButton`, or `OutlinedButton`.
    - [x] Both files pass Impeccable's strict non-Material container/button rules.
    - [x] Manually verify every listed consuming screen/widget against DESIGN.md spacing and contrast rules post-swap (padding, spacing, contrast — not just class-reference absence). List each screen checked and confirm no visual regression.

- **Substep 30.6.F3: Correct the ForUI theme variant app-wide (run BEFORE 30.6.F2)**
  - **Context:** Investigation during 30.6.F1's consumer analysis found `app.dart` applies `FTheme.neutral.dark.touch` / `FTheme.neutral.light.touch`. The original Step 2 fix package referred to the now-removed API `FThemes.zinc` (which existed only in forui pre-0.24.0 and was removed as a breaking change in 0.24.0). With the project pinned at `^0.24.2` (currently resolved to 0.24.3), the only built-in theme is `FTheme.neutral`. The codebase already correctly uses `FTheme.neutral`, which is the zinc-equivalent default theme in ForUI 0.24.x. No code changes are needed. The original decision documentation should be corrected so the phrasing "FThemes.zinc" reads "FTheme.neutral (ForUI's default built-in theme for the pinned 0.24.x version)".
  - **Action:**
    1. **No code changes to `app.dart` or test files** — they already correctly use `FTheme.neutral.dark.touch` / `FTheme.neutral.light.touch`, the only theme available in forui 0.24.x.
    2. Update any references to `FThemes.zinc` in project documentation to `FTheme.neutral` with a note about the version context.
    3. Run the full test suite and confirm no new failures beyond the 22 confirmed pre-existing failures.
    4. Perform manual visual check across a representative sample of effective FTheme-consumer screens confirming the neutral palette renders correctly with no contrast/legibility regressions per DESIGN.md.
  - **Definition of Done:**
    - [x] API correction confirmed: forui v0.24.3 has `FTheme.neutral` only — `FThemes` was removed in 0.24.0. Codebase already correct.
    - [x] app.dart references `FTheme.neutral` — correct for this version.
    - [x] Zero references to non-existent `FThemes` or `FThemes.zinc` in `lib/` or `test/`.
    - [x] Full test suite run: no new failures vs. the pre-existing baseline (375 passed, 27 pre-existing baseline failures, 0 new failures).
    - [x] Manual visual check across a representative sample of effective FTheme-consumer screens (`dashboard_page.dart`, `app_shell.dart`, `login_page.dart`, Attendance, Daily Log, Data Bucket, Inventory, Reporting, and Settings) confirming the neutral palette renders correctly with no contrast/legibility regressions per DESIGN.md.
    - [x] Written confirmation (or screenshot) for each screen checked in the sample. Do NOT mark this substep done on "compiles and tests pass" alone — the visual check is required.

- **Substep 30.6.F2: Purge custom color palette from `app_theme.dart` (run AFTER 30.6.F3)**
  - **Context:** `app_theme.dart` (63 lines) contains 18 hand-picked `const Color` tokens (a "Forest & Stone" palette: `kColorPrimary`, `kColorOnPrimary`, `kColorPrimaryContainer`, `kColorSuccess`, `kColorTextPrimary`, `kColorTextSecondary`, `kColorMuted`, `kColorBorder`, `kColorBackground`, `kColorSurface`, plus 5 dark-mode equivalents) plus 2 shape tokens (`kRadiusBase`, `kBorderRadius`). The color tokens are a custom color palette override, which directly contradicts the documented "no custom color palette override" decision — the same category of violation 32.2.F1 already fixed in `creatable_combobox.dart`. The file's sole consumer is `notification_banner.dart` (imports it at line 6; uses `kColorPrimary` at line 43 and `kColorPrimaryContainer` at line 50). This must run after 30.6.F3 so the target semantic token colors are already correct when the mapping is made.
  - **Action:**
    1. Before mapping any token, determine what `notification_banner.dart` is semantically used for (warning, info, error, success, or neutral/brand) by reading how it's invoked elsewhere in the codebase. Report which semantic category applies.
    2. In `notification_banner.dart`: remove `import 'package:mine_flow/app/theme/app_theme.dart';`. Replace `kColorPrimary` (line 43, warning icon color) and `kColorPrimaryContainer` (line 50, banner background color) with the FTheme token matching the semantic category determined in step 1 — use `FTheme.of(context).colors.primary`/`.primaryContainer` only if the banner is genuinely a neutral/brand element; otherwise use the matching warning/destructive/success semantic token if the installed ForUI version provides one.
    3. In `app_theme.dart`: delete all 18 `const Color` lines. Keep `kRadiusBase` and `kBorderRadius` only if a grep confirms they are consumed elsewhere as legitimate generic shape tokens (not brand-specific); otherwise delete those too.
    4. If `app_theme.dart` has zero remaining consumers and zero remaining content of substance, delete the file entirely and remove any leftover references (e.g. from `STEP-index.md` or other docs, if listed there).
  - **Definition of Done:**
    - [x] `notification_banner.dart` contains zero references to `app_theme.dart`, `kColorPrimary`, or `kColorPrimaryContainer`.
    - [x] The semantic category determined in Action step 1 is reported, and the token mapping used matches it (not defaulted to primary/primaryContainer without justification).
    - [x] `app_theme.dart` contains zero custom `const Color` tokens.
    - [x] `app_theme.dart` has zero consumers, or only the radius/shape tokens if confirmed legitimate and still in use elsewhere.
    - [x] Banner renders correctly with the new semantic tokens post-30.6.F3's zinc-palette swap (visual check, single widget).

## STEP-32.F: ForUI Cosmetic Fixes

**Goal:** Address Cosmetic Impeccable violations from Step 32 regarding token usage.

- **Substep 32.2.F1: Resolve hardcoded colors in `creatable_combobox.dart`**
  - **Context:** Hardcoded `Colors.black` and `Colors.transparent` were used instead of standard semantic tokens.
  - **Action:**
    - In `creatable_combobox.dart`: Replace `Colors.black` with the appropriate ForUI semantic foreground token (e.g., `context.theme.colorScheme.foreground`). Replace `Colors.transparent` with a valid semantic background token unless it is strictly required for hit-testing logic (if so, document inline).
  - **Definition of Done:**
    - [x] `creatable_combobox.dart` contains zero hardcoded `Colors.black` or `Colors.transparent` color assignments for styling.

## STEP-33.F: Operations UI Fixes

**Goal:** Address Doc-only Throughstone violations and Blocking Impeccable violations from Step 33.

- **Substep 33.1.F1: Verify and reconcile Definition of Done in `mine-flow-STEP-33-PLAN.md`**
  - **Context:** Silent scope drift occurred — DoD checkboxes for substeps 33.1–33.4 were left unchecked. Do NOT blind-check these boxes. Each must be individually verified against the actual codebase first.
  - **Action:** For each currently-unchecked `[ ]` item in substeps 33.1, 33.2, 33.3, and 33.4 of `mine-flow-STEP-33-PLAN.md`:
    1. Locate the corresponding implementation in the codebase and confirm the criterion is actually met. Cite the specific file and line(s) as evidence.
    2. If verified true: check the box `[x]` and record the evidence citation next to it.
    3. If verified false or only partially met: leave the box unchecked, and instead write a new substep in this document under a new heading `STEP-33.F2` (or next available number) describing the specific gap, with its own concrete Action and Definition of Done, following the same format as the other fix substeps in this file.
  - **Definition of Done:**
    - [x] Every DoD item in substeps 33.1–33.4 is either checked `[x]` with evidence citation, or has a corresponding new fix substep created for it.
    - [x] No item is checked without a cited evidence check.

- **Substep 33.3.F1: Purge Material from `daily_log_form_screen.dart`**
  - **Context:** The Operations UI refactor retained or introduced raw Material `Card` and `ElevatedButton`.
  - **Action:**
    - In `daily_log_form_screen.dart`: Replace `Card` with `FCard`. Replace `ElevatedButton` with `FButton`.
  - **Definition of Done:**
    - [x] `daily_log_form_screen.dart` contains exactly zero references to `Card` or `ElevatedButton`.

## STEP-34.F: Data Bucket Documentation & Component Fixes

**Goal:** Address Doc-only Throughstone violations and Blocking Impeccable violations from Step 34.

- **Substep 34.1.F1: Verify and reconcile Definition of Done in `mine-flow-STEP-34-PLAN.md`**
  - **Context:** Silent scope drift occurred — DoD checkboxes for substeps 34.1–34.4 were left unchecked. Do NOT blind-check these boxes. Each must be individually verified against the actual codebase first.
  - **Action:** For each currently-unchecked `[ ]` item in substeps 34.1 through 34.4 of `mine-flow-STEP-34-PLAN.md`:
    1. Locate the corresponding implementation in the codebase and confirm the criterion is actually met. Cite the specific file and line(s) as evidence.
    2. If verified true: check the box `[x]` and record the evidence citation next to it.
    3. If verified false or only partially met: leave the box unchecked, and instead write a new substep under a new heading `STEP-34.F3` (or next available number) describing the specific gap, with its own concrete Action and Definition of Done.
  - **Definition of Done:**
    - [x] Every DoD item in substeps 34.1–34.4 is either checked `[x]` with evidence citation, or has a corresponding new fix substep created for it.
    - [x] No item is checked without a cited evidence check.

- **Substep 34.2.F1: Purge Material from Data Bucket & Reporting screens**
  - **Context:** Refactors reintroduced or failed to purge Material components across Data Bucket features. `file_card.dart` is shared/foundational — used across multiple screens — so this fix carries visual-regression risk beyond a simple class swap.
  - **Action:**
    - In `file_card.dart`: Replace `Card` with `FCard`.
    - In `upload_file_page.dart` and `report_config_page.dart`: Replace `TextButton` and `OutlinedButton` with `FButton`. Remove any `ThemeData` overrides.
    - Identify every screen/widget that consumes `file_card.dart` (grep for imports/usages) and list them in your execution notes.
  - **Definition of Done:**
    - [x] `file_card.dart` contains zero references to `Card`.
    - [x] `upload_file_page.dart` contains zero references to `TextButton`, `OutlinedButton`, or `ThemeData`.
    - [x] `report_config_page.dart` contains zero references to `TextButton`, `OutlinedButton`, or `ThemeData`.
    - [x] Manually verify every listed consuming screen/widget against DESIGN.md spacing and contrast rules post-swap (padding, spacing, contrast — not just class-reference absence). List each screen checked and confirm no visual regression.

## STEP-35.F: Settings Documentation Fixes

**Goal:** Address Doc-only Throughstone violations from Step 35.

- **Substep 35.2.F1: Verify and reconcile Definition of Done in `mine-flow-STEP-35-PLAN.md`**
  - **Context:** Silent scope drift occurred — SettingsCubit and SettingsPage were implemented but DoD checkboxes for substeps 35.2, 35.3, and 35.4 were left unchecked. Do NOT blind-check these boxes. Each must be individually verified against the actual codebase first.
  - **Action:** For each currently-unchecked `[ ]` item in substeps 35.2, 35.3, and 35.4 of `mine-flow-STEP-35-PLAN.md`:
    1. Locate the corresponding implementation in the codebase and confirm the criterion is actually met. Cite the specific file and line(s) as evidence.
    2. If verified true: check the box `[x]` and record the evidence citation next to it.
    3. If verified false or only partially met: leave the box unchecked, and instead write a new substep under a new heading `STEP-35.F2` (or next available number) describing the specific gap, with its own concrete Action and Definition of Done.
  - **Definition of Done:**
    - [x] Every DoD item in substeps 35.2, 35.3, and 35.4 is either checked `[x]` with evidence citation, or has a corresponding new fix substep created for it.
    - [x] No item is checked without a cited evidence check.

---

## Side-Effect Check Table (Updated)

| Fix Substep                                       | Other Steps It Touches                                                                     | Risk                                                                                                                                                                     | Confirmed Safe?            |
| :------------------------------------------------ | :----------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------- |
| **30.6.F1** (Theme/Roster purge)                  | Shared foundational UI layer — `crew_roster_item.dart` consumer (`attendance_screen.dart`) | **Moderate**: `FCard`/`FButton` may alter layout constraints vs. Material equivalents. Not safe to confirm until the per-screen visual check in the DoD is actually run. | **Y (Completed & Verified)** |
| **30.6.F3** (FTheme.neutral resolution)           | App-wide theme — already correct. No code changes needed.                                  | **Low**: Documentation correction only. Confirmed forui 0.24.3 only has `FTheme.neutral`.                                                                                | **Y (Completed & Verified)** |
| **30.6.F2** (app_theme.dart custom palette purge) | Single direct consumer: `notification_banner.dart`                                         | **Low–Moderate**: Scoped to one widget, depends on correct semantic category identification.                                                                             | **Y (Completed & Verified)** |
| **32.2.F1** (Combobox tokens)                     | Shared form components                                                                     | **Low**: Purely cosmetic, scoped to a single component.                                                                                                                  | **Y**                      |
| **33.1.F1** (Doc verify-and-reconcile)            | Depends on what verification finds                                                         | **Low–Moderate**: May spawn new fix substeps.                                                                                                                            | **Y (Completed & Verified)** |
| **33.3.F1** (Operations UI purge)                 | Operations UI                                                                              | **Low**: Swap from `Card`/`ElevatedButton` to `FCard`/`FButton` may require minor padding/layout adjustments.                                                            | **Y (Completed & Verified)** |
| **34.1.F1** (Doc verify-and-reconcile)            | Depends on what verification finds                                                         | **Low–Moderate**: Same reasoning as 33.1.F1.                                                                                                                             | **Y (Completed & Verified)** |
| **34.2.F1** (Bucket UI purge)                     | Data Bucket & Reporting UI                                                                 | **Moderate**: Per-screen visual check required.                                                                                                                          | **Y (Completed & Verified)** |
| **35.2.F1** (Doc verify-and-reconcile)            | Depends on what verification finds                                                         | **Low–Moderate**: Same reasoning as 33.1.F1.                                                                                                                             | **Y (Completed & Verified)** |

