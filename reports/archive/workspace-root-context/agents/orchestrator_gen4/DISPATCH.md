# DISPATCH: Orchestrator Gen 4

## Mission
Resume and complete STEP-55.11 for the mine-flow Flutter application across Web and Android: resolve remaining E2E test failures from the ForUI migration, run the multiplatform Impeccable audit, pass all automated verification gates, reconcile documentation and risk registers, and prepare the final close disposition for owner approval.

## Context
- Original User Request: d:/AppDev/mine_flow/.agents/ORIGINAL_REQUEST.md
- Project Scope: d:/AppDev/mine_flow/PROJECT.md
- Canonical Docs & Method: d:/AppDev/mine_flow/Code/mine-flow-docs/AGENTS.md and METHOD.md
- Prior Orchestrators: orchestrator_1, orchestrator_gen2, orchestrator_gen3 (see .agents/orchestrator_gen3/progress.md and BRIEFING.md)
- M1 Verification: d:/AppDev/mine_flow/.agents/m1_auditor_1/handoff.md (M1 signed off CLEAN)

## Instructions
1. Initialize BRIEFING.md and progress.md in your working directory: d:/AppDev/mine_flow/.agents/orchestrator_gen4
2. Execute remaining milestones (M2: Impeccable audit & matrix evidence, M3: Durable docs & risks, M4: FC-54.* reconciliation & STEP-55 close).
3. Enforce the Project Pattern: Explorer -> Worker -> Reviewer -> Challenger -> Auditor.
4. When finished and all criteria pass, report completion to Sentinel.

## 2026-09-17T07:48:46Z
You are Orchestrator Gen 4 for the mine_flow STEP-55.11 project.

Your working directory is: d:/AppDev/mine_flow/.agents/orchestrator_gen4
Your parent Sentinel conversation ID is: 738044a7-0f3a-4b1f-b6ad-0a73303d0468

Read immediately:
1. d:/AppDev/mine_flow/.agents/ORIGINAL_REQUEST.md (Authoritative user request, including latest follow-up at 2026-09-17T07:47:47Z)
2. d:/AppDev/mine_flow/PROJECT.md
3. d:/AppDev/mine_flow/Code/mine-flow-docs/AGENTS.md and METHOD.md
4. d:/AppDev/mine_flow/.agents/orchestrator_gen4/DISPATCH.md
5. State history: d:/AppDev/mine_flow/.agents/orchestrator_gen3/ (BRIEFING.md, progress.md) and d:/AppDev/mine_flow/.agents/m1_auditor_1/handoff.md (M1 signed off CLEAN)

Mission:
Resume and complete STEP-55.11 for the mine-flow Flutter application across Web and Android:
- R1: Resolve E2E Journey Regressions (Class A & Class B) in Code/mine-flow-app/integration_test/journeys/.
- R2: Automated Verification & Quality Gates (dart format, flutter analyze with 0 issues, localization and Supabase contract guards, flutter test 100%, web release build, android debug apk build, dual-platform E2E execution).
- R3: Multiplatform Impeccable Audit & Design Review Evidence (Web widths 799, 800, 801, 1024, >=1280px; Android Pixel_6a portrait; touch targets >=48x48dp, WCAG AA contrast 4.5:1, keyboard nav, dark/light modes; screenshots cleanly into reports/design-review/step-0055/).
- R4: Documentation, Risk Reconciliation & STEP-55 Close Preparation (reconcile FC-54.* in Upcoming Prompts/mine-flow-STEP-55.11-FINDINGS.md, update Code/mine-flow-docs/reports/, sync registries/risks.yml, prepare commit plan, require explicit user approval prior to marking STEP-55 Done or merging branches).

Constraints:
- You are a pure orchestrator: do not write code or execute tests directly; dispatch specialized subagents.
- Maintain your working directory at d:/AppDev/mine_flow/.agents/orchestrator_gen4 with BRIEFING.md and progress.md.
- Ensure sensitive credentials, PII, and tokens are never leaked into test artifacts or logs.
- When all milestones are completed and verified, report completion to Sentinel.
