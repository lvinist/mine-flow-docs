## 2026-09-17T07:50:28Z

You are m2_spec_miner_3_gen4, a Spec Miner agent for Milestone 2 of STEP-55.11.
Your working directory is: d:/AppDev/mine_flow/.agents/m2_spec_miner_3_gen4
Your parent Orchestrator conversation ID is: 4af240b7-3229-4675-b201-32ad0b0dea69

MANDATORY INPUTS:
1. Read d:/AppDev/mine_flow/.agents/ORIGINAL_REQUEST.md (Authoritative verbatim user request - read first before starting work).
2. Read d:/AppDev/mine_flow/PROJECT.md
3. Read d:/AppDev/mine_flow/Upcoming Prompts/mine-flow-STEP-55-PLAN.md
4. Read d:/AppDev/mine_flow/Upcoming Prompts/mine-flow-STEP-55.11-PROMPT.md
5. Read d:/AppDev/mine_flow/Upcoming Prompts/mine-flow-STEP-55.11-FINDINGS.md
6. Inspect `Code/mine-flow-app/test_driver/integration_test.dart` and `Code/mine-flow-app/integration_test/design_review_capture_test.dart`.

OBJECTIVE:
Mine and document all authoritative specifications, rubrics, and evidence requirements for the design review capture and Impeccable audit report:
1. Screenshot Matrix Specification:
   - Full inventory of expected screenshot filenames, routes, viewpoints, themes, locales.
   - Breakpoints: phone (400x800 / 412x915), 799dp, 800dp, 801dp, 1024dp, 1280dp.
   - Themes (Light, Dark), Locales (`id`, `en`), Screens/Routes (`/`, `/tools`, `/operations`, `/teams`, `/settings`, and forms/dialogs).
   - Storage path: `reports/design-review/step-0055/`.
   - Screenshot byte & dimension validation (PNG header magic bytes, rejection of 68-byte 1x1 synthetic placeholders).
   - Zero credential/PII leakage requirement (redaction validation).
2. 2-Round Impeccable Audit Protocol:
   - Round 1: capture all required states/platforms together, score defects, batch defects.
   - Round 2: consolidated fix batch, recapture only affected/required confirmations, report remaining gaps.
   - Scoring rubric: Web health score (0-20), Android health score (0-20), defect severity categories (Blocker, Critical, Major, Minor, Polish).
   - Report structure for `Code/mine-flow-docs/reports/2026-09-11-step-55-multiplatform-impeccable-audit.md` (or current date).
3. Test Runner & Execution Scripts:
   - Inspect existing scripts such as `.step55.11h-run-web.sh`, `scripts/`, or command lines for executing `flutter drive` / `flutter test integration_test/`.
   - Document the exact invocation commands and environment variables needed.

OUTPUT REQUIREMENTS:
- Create `BRIEFING.md` and `progress.md` in your working directory `d:/AppDev/mine_flow/.agents/m2_spec_miner_3_gen4/`.
- Write your report to `d:/AppDev/mine_flow/.agents/m2_spec_miner_3_gen4/handoff.md` with structured tables, exact formulas, naming schemes, and report templates.
- When done, send a message to parent (ID: 4af240b7-3229-4675-b201-32ad0b0dea69) with brief summary and path to your handoff.md.
