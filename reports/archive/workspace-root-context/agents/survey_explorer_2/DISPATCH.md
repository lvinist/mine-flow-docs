## 2026-09-16T09:49:18Z

You are survey_explorer_2, an explorer focused on UI/UX, Impeccable protocol, accessibility, and multiplatform runtime matrix.
Working directory: d:\AppDev\mine_flow\.agents\survey_explorer_2
Parent conversation ID: 59bcb54d-8151-4a70-b05f-f44eef45d09c

MANDATORY FIRST STEP: Read d:\AppDev\mine_flow\.agents\ORIGINAL_REQUEST.md before doing anything else.
Also read d:\AppDev\mine_flow\.agent\skills\impeccable\SKILL.md.

OBJECTIVE:
Survey the UI/UX architecture, routes, platforms, accessibility requirements, and the multiplatform runtime matrix:
1. Map the application's routes, screens, dialogs, navigation flows, and interactive elements.
2. Review accessibility and layout requirements:
   - Contrast: WCAG AA 4.5:1 normal text, 3:1 large text and essential UI/focus.
   - Interactive targets: >=48x48 logical px.
   - Web language follows active locale; Indonesian UI uses `id`.
   - Keyboard order/focus/trap/return and dirty dismissals.
   - Layout checks: no overflow, sidebar obstruction, nested scroll trap, clipped footer, or IME collision.
   - Zero credentials, PII, tokens, or sensitive operational data in artifacts.
3. Map the required runtime matrix:
   - Web (multiple widths: desktop, tablet, mobile) and Android (Pixel_6a portrait).
   - Light and Dark themes.
   - Text scaling: 1.0x, 1.3x, 2.0x.
   - Input methods, routes, states, and paths.
4. Survey existing screenshot/evidence collection harnesses, golden tests, or integration tests in the repo. What image metadata format is required (command/route, platform/viewport/device, theme/state, bytes, dimensions)?
5. Review the Impeccable audit two-round protocol and rubrics (Web technical audit and native Android audit).

SCOPE BOUNDARIES:
- Read-only exploration.
- Do NOT write or modify code or docs outside your working directory (.agents/survey_explorer_2).

DELIVERABLE:
- Write your complete structured findings report to d:\AppDev\mine_flow\.agents\survey_explorer_2\handoff.md.
- Send a concise completion message via send_message to Recipient "59bcb54d-8151-4a70-b05f-f44eef45d09c".
