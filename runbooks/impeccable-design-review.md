# Runbook — Impeccable Implemented-Design Review

> **How to run:** Say **"run the Impeccable design review"** (or *"review the implemented design"*). For an in-flight UI-heavy STEP, make this a named verification substep in that STEP's PLAN. For a cross-screen, release, or check-in review, create a dedicated **Design Review STEP** with a thin PLAN that points to this runbook.
>
> **Purpose:** Verify the *running* Flutter app against the canonical UI/design-system contract. This is not a design-authoring workflow and it does not replace ordinary code review, automated tests, accessibility tests, or the Throughstone check-in.
>
> **Mode:** Review first. Do not change application code, architecture docs, bridge files, or STEP records while gathering evidence. Present findings and obtain the user's direction before starting remediation. A separately planned remediation substep or STEP owns fixes.

## Why this runbook exists

Source inspection can prove that a screen imports `FButton`, avoids a raw `Card`, or uses an expected token. It cannot prove that a form fits a phone viewport, a desktop table is readable, a focus state is visible, an action is discoverable, or that the visual hierarchy matches the product's data-dense operating context.

This runbook closes that gap. It captures runtime evidence and compares it with the current design contract, so an Impeccable-driven UI change is not marked complete merely because it compiles or passes widget tests.

## 1. Authority and boundaries

### Canonical sources

Read these before reviewing:

1. `architecture/07-ui-design-system.md` — **canonical current UI contract**.
2. Accepted UI-related ADRs, especially `adr/ADR-0008-impeccable-bridge.md` and later UI decisions — historical rationale and approved deviations.
3. `prompts/STEP-index.md` plus the active STEP PLAN — review scope/status.
4. The relevant feature's README, architecture docs, interface-contract and test-strategy docs — expected behavior and test obligations.

`DESIGN.md` and `PRODUCT.md` at the workspace root are generated Impeccable context. They are useful inputs for a reviewer but **not canonical** and must never be edited directly. If they differ substantively from Doc 07, report bridge drift; repair Doc 07 first if needed, then regenerate both files with `scripts/impeccable-bridge.ps1` in a separately authorized documentation task.

### What this review decides

- **Doc 07 defines the intended design.**
- This review determines whether the observed implementation matches that contract.
- It does **not** silently change the design to match code.
- An intentional implementation deviation needs an explicit product/owner decision. Material decisions require an ADR and an update/version-log entry in Doc 07 before the bridge is regenerated.

## 2. When a review is required

Run this review:

- before closing any STEP that materially changes a screen, navigation, shared UI component, design token/theme, responsive layout, localization, or accessibility behavior;
- after a broad UI migration or an Impeccable-driven rebuild;
- before a release or milestone involving UI changes;
- when a check-in identifies UI/design-system drift; or
- whenever the user explicitly asks for visual/UX validation.

A small, non-visual change does not require a standalone review. The STEP PLAN must say why if a UI-facing change is deliberately not reviewed.

## 3. Pre-flight and evidence setup

1. Resolve the target from disk: run `./doctor.sh status`, read the matching row in `prompts/STEP-index.md`, and read the active PLAN or archived STEP artifacts.
2. Define the target surface(s), workflow(s), user role(s), and states to inspect. Do not review only the happy path when the screen has loading, empty, error, validation, permission, destructive, or offline/sync states.
3. Start the application using the repository's documented command and safe non-secret local configuration. Record the exact command, working directory, revision/commit, platform, and whether the build launched successfully.
4. Use an evidence-capable reviewer: actual browser/device/emulator interaction plus screenshots or recordings. If such runtime access is unavailable, do a **static pre-review only** and label all visual, interaction, layout, animation, and responsive verdicts **Unverified** — never PASS them from source code alone.
5. Capture the relevant surfaces at minimum:
   - Android/phone portrait at a representative narrow width;
   - Web/desktop at a representative wide width;
   - any breakpoint, orientation, or platform explicitly affected by the change.
6. Use safe fixtures/test accounts. Do not put credentials, production PII, tokens, or screenshots containing sensitive operational data into the report.

## 4. Review procedure

### A. Contract and bridge parity

- Confirm the generated bridge headers identify Doc 07 as the source.
- Compare the substantive content of `DESIGN.md` and `PRODUCT.md` against Doc 07, excluding their documented generated headers.
- Check the active STEP's claimed design requirements against the current Doc 07 and accepted ADRs; classify any contradiction rather than choosing the convenient source.

### B. Runtime visual and responsive review

For every target workflow and state, inspect the running app and capture evidence for:

- **Information hierarchy:** important operational data and actions are prominent; labels are understandable; no generic/consumer-style layout displaces dense field/dashboard work.
- **Layout:** no overflow, clipping, accidental scroll traps, overlap, cramped controls, inaccessible off-screen actions, or inappropriate whitespace at the inspected viewport.
- **Responsive behavior:** desktop/sidebar and mobile/navigation patterns remain usable at affected breakpoints; primary workflows are not hidden contrary to Doc 07.
- **Design tokens/components:** ForUI components and semantic theme tokens are used where the design contract requires them; no legacy palette/custom `ThemeData` or raw Material substitutes appear without a documented, justified exception.
- **Typography and density:** Geist/default ForUI typography, compact spacing, readable tabular/numeric content, subtle borders and standard radii are applied coherently.
- **Theme:** both supported light/dark modes remain legible and structurally consistent if the target exposes the theme toggle.
- **Motion:** transitions are brief, subtle, and do not block interaction; reduced-motion behavior is respected when testable.

### C. Interaction and accessibility review

Exercise, where applicable:

- touch/click targets, keyboard traversal, visible focus, Enter/Space activation, and back navigation;
- semantic labels and meaningful screen-reader order, using platform accessibility tools where available;
- text scaling and contrast at ordinary and enlarged text settings;
- form validation, disabled/loading states, destructive confirmations, error recovery, and empty states;
- role-based visibility and sensitive-data presentation using authorized test accounts;
- Indonesian localization and the absence of newly hard-coded user-facing strings outside the localization layer.

This review supplements, rather than replaces, automated widget/integration/accessibility tests. Run the STEP's specified automated gate after the review evidence is captured.

## 5. Findings and disposition

Use one row per finding with the fields in `templates/reports/design-review/impeccable-design-review-report-template.md`.

Classify each result as one of:

| Verdict | Meaning | Required treatment |
|---|---|---|
| **Verified** | Runtime evidence shows the target matches the applicable contract. | Record evidence; no action. |
| **Blocking** | Violates a canonical UI, usability, accessibility, security, or responsive requirement; do not close/release the target STEP. | Create or continue a remediation substep/STEP; add/adjust tests; rerun this review. |
| **Needs remediation** | Material inconsistency that is not an immediate release block. | File a remediation substep/STEP with owner and acceptance criteria. |
| **Approved deviation** | Intentional difference from the contract. | Record owner approval; update Doc 07/version log and ADR if material; regenerate bridge afterward. |
| **Unverified** | Runtime evidence was unavailable or incomplete. | Do not claim visual acceptance; schedule/rerun runtime review. |

Do not call a screen visually verified based only on static code, widget tests, a passing analyzer, or a prior report from another revision.

## 6. Outputs and follow-through

### In an implementation STEP

1. Add the review as a named verification substep in the PLAN, with target screens/workflows, required platforms, and the automated test command.
2. Save the completed report under:
   `reports/design-reviews/YYYY-MM-DD-step-NNNN-impeccable-design-review.md`
3. Link that report from the STEP review/archived artifacts and update the substep status only after its verdict is resolved.
4. Do not mark the STEP Done with any unresolved **Blocking** or **Unverified** result.

### As a standalone Design Review STEP

Use a thin PLAN that points here. It may update documentation, create remediation STEPs, and write the report, but it must not bundle implementation fixes. Archive the PLAN like any other completed STEP.

### When the review finds drift

- **Code wrong; docs right:** file a bug/remediation STEP. Do not alter Doc 07 to bless the drift.
- **Docs stale; implementation is an approved decision:** update Doc 07 and its Version Log; add/supersede an ADR for a material decision; then regenerate the bridge.
- **Bridge stale:** repair the canonical doc if needed, regenerate `DESIGN.md` and `PRODUCT.md`, and record the generation/evidence.
- **Test gap:** add the appropriate widget, integration, golden/visual, accessibility, or end-to-end test to the remediation scope.
- **Accepted temporary risk/debt:** first create the explanatory report/ADR/STEP artifact, then add a concise `registries/risks.yml` entry with owner, severity, revisit trigger, and reference.

## 7. Completion gate

A design-review substep or dedicated review STEP is complete only when:

- [ ] Canonical Doc 07, relevant ADRs, bridge files, STEP scope, and test strategy were read.
- [ ] Runtime evidence was captured for every planned surface/state, **or** each unavailable item is explicitly Unverified.
- [ ] Narrow/mobile and wide/desktop behavior was assessed where applicable.
- [ ] Interaction, accessibility, theme, localization, and responsive checks were considered and their coverage recorded.
- [ ] Each finding has a verdict, evidence, impact, owner, and required Throughstone treatment.
- [ ] Blocking findings have a remediation owner/STEP and Unverified findings prevent visual acceptance.
- [ ] The report is saved under `reports/design-reviews/` and linked from the active STEP/review record.
- [ ] The relevant automated tests and analyzer command were run and their actual results recorded.
- [ ] The next disk-derived action is stated.
