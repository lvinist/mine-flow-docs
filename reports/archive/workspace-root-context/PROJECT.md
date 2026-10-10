# Project: STEP-55 Multiplatform Impeccable Audit, Verification, Docs, and Close

## Architecture
- **Multi-Repo Layout**:
  - `Code/mine-flow-app`: Flutter client application (Clean Architecture: presentation, domain, data; BLoC/Cubit state management; ForUI design system; GoRouter navigation; Hive local storage).
  - `Code/mine-flow-docs`: Architecture specifications (`01`–`17`), ADRs (`ADR-0001`–`ADR-0019`), registries (`risks.yml`, `repos.yml`, `security-reviews.yml`), operational scripts, and published audit reports.
  - `prompts`: Master roadmap `STEP-index.md` and archived step slices.
  - `Upcoming Prompts`: In-flight active workspace for STEP-55 plan, prompts, and findings.
- **UI & Platform Boundaries**:
  - Breakpoint: 800 logical px cleanly separates Desktop (`_WideLayout`: collapsible `FSidebar` + `GlobalAppHeader`) from Mobile (`_NarrowLayout`: 5-tab `FBottomNavigationBar`).
  - Shared Primitives: `AppResponsiveSheet` (docked right sheet 480–600dp on Web, bottom sheet on Mobile, full page for long checklists/ledgers), `AppDismissController` & `AppDirtyDismissDialog` (unifying 8 dismissal paths), `AppContextualReportDialog` (7 feature types pre-bound), `AppFilterPopover`, `AppCalendarDialog`.
  - Platforms: Web (multiple widths: 799dp, 800dp, 801dp, 1024dp, 1280dp) & Android (Pixel_6a portrait, 412x915).

## Feature Inventory
Every feature identified during the Survey phase is mapped to a milestone below. No feature is left unassigned.

| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Test Driver Retargeting | Fix `test_driver/integration_test.dart` to write screenshots to `reports/design-review/step-0055/` instead of `step-0048/` | M1 | Survey (explorer_2, explorer_3) |
| 2 | Dual-Platform E2E Verification | Execute full 16 E2E journey test files on Web (Chrome) and Android (Pixel_6a) on head `a301e4b` | M1 | Survey (explorer_2, explorer_3) |
| 3 | Impeccable Audit Protocol (R1) | Execute 2-round audit cycle: full capture across required states/platforms, score & batch defects, consolidated fix batch, recapture confirmations | M2 | ORIGINAL_REQUEST R1 |
| 4 | Runtime Matrix Execution (R2) | Test across Web (multiple widths) and Android (Pixel_6a portrait) in Light/Dark/System themes and Text Scaling (1.0x, 1.3x, 2.0x) | M2 | ORIGINAL_REQUEST R2 |
| 5 | Accessibility & Target Geometry | Measure and verify WCAG AA contrast (4.5:1 text, 3:1 focus/large) and interactive targets >=48x48 logical px | M2 | ORIGINAL_REQUEST Acceptance Criteria |
| 6 | Interaction & Layout Verification | Verify dirty dismissal across 8 paths, keyboard order/focus/trap, no overflow/sidebar obstruction/footer clipping/IME collision | M2 | ORIGINAL_REQUEST Acceptance Criteria |
| 7 | Secure Evidence Collection | Collect non-synthetic screenshot artifacts with required metadata (command, platform/viewport, theme/state, bytes, dimensions); zero PII/creds | M2 | ORIGINAL_REQUEST R2, Acceptance Criteria |
| 8 | Architecture Docs Updates | Update `04-data-model.md` (hazards, inventory transactions, `adjust_inventory`), `06-security-threat-model.md` (header redaction, privacy gate), `07-ui-design-system.md` (D1–D7, 800dp), `11-interface-contracts.md`, `16-identity-auth.md`, `17-privacy-compliance.md` with Version Log bumps | M3 | ORIGINAL_REQUEST R3.2 |
| 9 | Risk Registry Reconciliation | Update `Code/mine-flow-docs/registries/risks.yml` dispositioning RISK-0026, RISK-0027, RISK-0028, RISK-0029, and maintaining active risks | M3 | ORIGINAL_REQUEST R3.2 |
| 10 | Contract & Guard Verification | Validate Supabase database types (`database.ts`), localization baseline (`check_l10n_baseline.dart`), and contract guard (`check_supabase_contracts.dart`) | M3 | Survey (spec_miner_1, explorer_3) |
| 11 | 127 `FC-54.*` Reconciliation | Map and reconcile all 127 critique findings across 54.1–54.10a to STEP-55 implementation deliverables, commits, and tests | M4 | ORIGINAL_REQUEST R3.1 |
| 12 | Findings Document & Plan Status | Finalize `Upcoming Prompts/mine-flow-STEP-55.11-FINDINGS.md` with Run 3 / head `a301e4b` analysis, scores, and complete `mine-flow-STEP-55-PLAN.md` Definition of Done | M4 | ORIGINAL_REQUEST R3.3 |
| 13 | Roadmap & Index Alignment | Reconcile substeps 55.0–55.11 and main STEP-55 row in `prompts/STEP-index.md` to reflect verified statuses | M4 | Survey (spec_miner_1, explorer_3) |
| 14 | Automated Gates Sign-off | Verify 100% pass on `dart format`, `flutter analyze`, `flutter test`, `flutter build web --release`, `./doctor.sh check` and duplicate STEP scan | M4 | ORIGINAL_REQUEST Automated Gates |
| 15 | Release Verdict & Close Hold | Produce victory audit report for user review; enforce explicit hold on branch archive/merge/delete until user approves | M4 | ORIGINAL_REQUEST R3.4 |

## Milestones

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | E2E Harness Hardening & Dual-Platform Verification | Fix test driver path hazard (`step-0048` -> `step-0055`), run Web & Android E2E journeys on head `a301e4b`, verify zero regressions | none | DONE |
| M2 | Multiplatform Impeccable Audit & Runtime Matrix Evidence | Execute 2-round Impeccable audit on Web and Android (Pixel_6a), verify contrast, 48dp targets, text scaling, keyboard, dirty dismissals, capture full metadata image records | M1 | IN_PROGRESS |
| M3 | Durable Documentation, Architecture, Contracts & Risks | Update architecture docs 04, 06, 07, 11, 16, 17 with version logs, update registries/risks.yml, verify generated contracts | none | IN_PROGRESS |
| M4 | 127 FC-54.* Reconciliation, Findings Report & STEP-55 Close | Reconcile all 127 FC-54.* IDs, finalize STEP-55.11 findings & PLAN, update STEP-index.md, pass all automated gates, produce verdict report, hold close | M1, M2, M3 | PLANNED |

## Interface Contracts

### Driver ↔ Evidence Storage
- `test_driver/integration_test.dart` writes to `../mine-flow-docs/reports/design-review/step-0055/$screenshotName.png`.
- Every image metadata entry must follow format:
  `| Command / Route | Platform / Viewport / Device | Theme / State | Bytes | Dimensions | Artifact Path |`
  No synthetic placeholders or 1x1 images allowed.

### Application ↔ Architecture Docs
- `hazard_assessment` table & RLS policies in `04-data-model.md` match `20260912000001_step_55_6_daily_log_hazard_contract.sql`.
- `inventory_transactions` table & `adjust_inventory` RPC in `04-data-model.md` match `20260913000001_step_55_8_inventory_transactions.sql`.
- HTTP header sanitization in `06-security-threat-model.md` matches `logger.dart` redaction logic.

### Audit ↔ User Sign-off Gate
- No branch merge, deletion, or archive commands may execute without explicit human user approval of the audit verdict in chat.

## Code Layout
- `Code/mine-flow-app/lib/`: Application source code.
- `Code/mine-flow-app/test/`: Unit & widget test suites.
- `Code/mine-flow-app/integration_test/`: E2E journey test suites.
- `Code/mine-flow-app/test_driver/`: Integration test driver scripts.
- `Code/mine-flow-docs/architecture/`: Durable architecture documents.
- `Code/mine-flow-docs/registries/`: Machine-readable registries (`risks.yml`, etc.).
- `Code/mine-flow-docs/reports/`: Audit reports and design-review screenshots.
- `Upcoming Prompts/`: Active step planning and findings files.
- `prompts/`: Global roadmap (`STEP-index.md`).
- `.agents/`: Agent metadata only.
