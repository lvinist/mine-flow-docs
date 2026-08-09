# mine-flow — Phase 2 Tier 2 Audit & Reconciliation Runbook

> **Purpose:** Execute a complete, evidence-first audit of the `mine-flow` Flutter implementation against Throughstone specifications and the Impeccable bridge.
>
> **Execution model:** Run this file sequentially. Do not skip a STEP or substep. Finish each substep’s required output before continuing.
>
> **Mode:** Read-only audit. Do not modify tracked files, reserve a STEP number, create branches, or apply fixes during this run.
>
> **Stage gate:** Execute only one `AUDIT STEP` per turn. After completing its deliverable and checklist, stop with `AUDIT STEP-N COMPLETE — WAITING FOR REVIEW`. Do not begin the next AUDIT STEP until the user explicitly says `CONTINUE TO AUDIT STEP-N`.

---

## 0. Audit Contract

You are acting as a senior staff Flutter engineer, software architect, QA lead, security reviewer, and Throughstone compliance auditor.

The project has completed Phase 2 Tier 2 through STEP-38. Your job is to determine whether the current Flutter implementation, tests, migrations, configuration, architecture docs, generated Impeccable files, STEP records, and risk records still agree.

This audit must identify drift in all directions:

1. **Specification → implementation drift**
   - A documented requirement is missing, partial, incorrectly implemented, or no longer true.

2. **Implementation → specification drift**
   - Code contains behavior, routes, models, fields, services, dependencies, or decisions absent from current docs.

3. **Documentation → documentation drift**
   - Architecture docs, overview, ADRs, STEP records, generated bridge files, reports, or risk records contradict each other.

4. **Claim → evidence drift**
   - A STEP is marked Done or claims verification, but its deliverable or test result cannot be reproduced.

### 0.1 Non-negotiable rules

- Work from the workspace root.
- Read root `AGENTS.md`.
- Read canonical `Code/mine-flow-docs/AGENTS.md`.
- Read `Code/mine-flow-docs/METHOD.md`.
- Treat state on disk as authoritative over chat memory.
- The project is already initialized unless the on-disk status marker proves otherwise.
- Do not restart kickoff.
- Do not edit code, docs, tests, migrations, generated files, configuration, or STEP records.
- Do not fix findings during the audit.
- Do not trust `Done` status without evidence.
- Do not trust filenames or class names as proof of behavior.
- Do not repeat historical test counts as current results.
- Do not claim a command ran unless its command, working directory, exit code, and result are recorded.
- Do not silently skip inaccessible or missing files.
- When evidence is unavailable, classify the item as **Unverified**.
- Separate static inspection, test evidence, build evidence, and actual runtime/manual evidence.
- Do not call a visual behavior verified from static code alone.
- Do not call authorization secure from UI role checks alone.
- `DESIGN.md` and `PRODUCT.md` are generated bridge artifacts. Never recommend editing them directly.
- Complete every required checklist item before writing the final verdict.

### 0.2 Source-of-truth hierarchy

Use this order when sources conflict:

1. Accepted ADRs for historical architectural decisions
2. Current versioned architecture documents for the present design
3. `prompts/STEP-index.md` for roadmap and STEP status
4. Active or archived STEP PLANs, substep prompts, reviews, and reports
5. `Code/mine-flow-docs/overview.md`
6. Generated root `DESIGN.md` and `PRODUCT.md`
7. Repository README and internal architecture documentation
8. Actual source code, migrations, configuration, tests, and runtime behavior

Interpretation:

- Architecture docs describe what the system should be now.
- ADRs explain why significant decisions were made.
- STEP artifacts record planned and historical execution.
- Code shows current reality.
- Tests prove only what they actually execute.
- A conflict must be classified, not silently resolved.

### 0.3 Required finding fields

Every finding must include:

- Finding ID
- Severity
- Classification
- Requirement or claim
- Specification evidence
- Implementation evidence
- Test or command evidence
- Impact
- Recommended Throughstone treatment

Severity:

- **Critical** — security, privacy, authorization, data corruption, or release blocking
- **High** — core deliverable absent or materially broken
- **Medium** — partial implementation, significant inconsistency, regression, platform mismatch, or weak verification
- **Low** — stale documentation, metadata mismatch, or minor inconsistency
- **Informational** — verified alignment or historical clarification

Treatment:

- Implementation bug
- Documentation correction
- Architecture update
- ADR required
- Risk-register entry
- Test-gap follow-up
- Generated bridge regeneration
- New implementation STEP
- New Check-in STEP candidate
- Lightweight issue
- No action

---

# AUDIT STEP-1 — Resolve Project State and Build Inventory

## 1.1 Read canonical project context

Read:

- root `AGENTS.md`
- `Code/mine-flow-docs/AGENTS.md`
- `Code/mine-flow-docs/METHOD.md`
- `Code/mine-flow-docs/overview.md`
- `prompts/STEP-index.md`
- `Code/mine-flow-docs/registries/repos.yml`
- `Code/mine-flow-docs/registries/risks.yml`
- README of every repository relevant to STEP-29 through STEP-38
- any active files in `Upcoming Prompts/`

## 1.2 Resolve current Throughstone state

Run:

```powershell
& "C:\Program Files\Git\bin\sh.exe" .\doctor.sh status
```

If not using PowerShell:

```sh
./doctor.sh status
```

Confirm the result against `prompts/STEP-index.md`.

Determine:

- project status marker;
- current phase and tier;
- last completed STEP;
- any STEP currently In progress;
- any Planned, Deferred, or Abandoned items;
- whether a check-in is due;
- whether milestone review, release notes, or user-facing docs review is due;
- the next action implied by `METHOD.md` §10.

## 1.3 Inventory repositories and artifacts

Create a repository inventory:

| Repository | Purpose | README inspected | Relevant to audit | Notes |
|---|---|---|---|---|

Create a STEP artifact inventory for STEP-29 through STEP-38:

| STEP | Index row | PLAN | Substep prompts | Review/evidence | Archived path | Missing artifacts |
|---|---|---|---|---|---|---|

Search both:

- `Upcoming Prompts/`
- `prompts/**/step-NNNN/`

Do not assume an artifact is absent after checking only one location.

## 1.4 STEP-1 deliverable

Write:

- resolved project-state summary;
- repository inventory;
- artifact inventory;
- command ledger entry for the status resolver;
- blocked or missing items.

### STEP-1 completion gate

- [ ] Canonical agent context inspected
- [ ] Method inspected
- [ ] Overview inspected
- [ ] Status resolver run
- [ ] STEP index confirmed
- [ ] Repositories inventoried
- [ ] STEP-29 through STEP-38 artifacts inventoried
- [ ] Missing artifacts explicitly recorded

Do not continue until no item remains unchecked.

Stop this turn with exactly:

`AUDIT STEP-1 COMPLETE — WAITING FOR REVIEW`

Do not begin AUDIT STEP-2 until the user explicitly says:

`CONTINUE TO AUDIT STEP-2`

---

# AUDIT STEP-2 — Documentation and Impeccable Bridge Drift

## 2.1 Inspect architecture and project documents

Inspect all documents relevant to:

- system overview;
- phasing and roadmap;
- architecture and component boundaries;
- native Flutter architecture;
- data model and retention;
- security and threat model;
- identity, roles, and RLS;
- privacy and sensitive data;
- UI/design system;
- infrastructure and deployment;
- environments;
- observability;
- interface contracts;
- test strategy;
- glossary;
- offline storage and synchronization;
- Google Drive integration;
- reporting;
- notifications;
- settings;
- benchmark functionality;
- responsive/platform behavior;
- localization.

Record each document’s:

- current header version;
- status;
- last-updated metadata;
- latest Version Log row;
- relevant decisions;
- contradictions or stale statements.

## 2.2 Audit generated Impeccable bridge files

Inspect:

- root `DESIGN.md`
- root `PRODUCT.md`
- `Code/mine-flow-docs/scripts/impeccable-bridge.ps1`
- upstream `architecture/07-ui-design-system.md`

Determine:

- intended generation source;
- whether `DESIGN.md` and `PRODUCT.md` should be identical;
- whether they are currently identical;
- whether either file differs from its upstream source;
- whether the bridge was regenerated after the latest architecture change;
- whether generated metadata is stale;
- whether the bridge script itself introduces drift.

Do not edit generated files.

## 2.3 Mandatory documentation-drift investigations

Confirm, partially confirm, refute, or mark Unverified:

### D1 — Version metadata mismatch

Investigate whether:

- header version remains `v0.2.0`;
- latest Version Log row is `v0.2.1`;
- last-updated metadata still points to STEP-29.1;
- the mismatch exists upstream, only in generated files, or in both.

Identify the true correction point and whether regeneration is required.

### D2 — Obsolete `FThemes.zinc`

Investigate:

- STEP-30 summary wording;
- architecture docs;
- generated files;
- source code;
- tests and configuration.

Determine whether this is:

- stale historical wording;
- current documentation drift;
- current implementation drift;
- already corrected everywhere except immutable history.

### D3 — Data Bucket coordinates

Determine separately whether latitude/longitude were removed from:

- UI forms;
- list/detail screens;
- domain entities;
- models;
- Hive/local storage;
- Supabase schema;
- migrations;
- filters/search;
- interface contracts;
- overview and architecture docs.

Do not collapse UI removal and data-model removal into one conclusion.

### D4 — Supported platforms and responsive behavior

Determine:

- officially supported platforms now;
- platforms that merely compile;
- whether Android is actually portrait-locked;
- whether iOS and desktop behavior is defined and implemented;
- whether “web supervisors” and “Android foremen” are requirements or examples;
- whether navigation and breakpoints match docs.

### D5 — STEP-38 verification evidence

Determine:

- whether the PLAN has an explicit final verification gate;
- whether a review/completion artifact exists;
- whether all recorded fixes have targeted regression tests;
- whether current analyzer and tests reproduce the claims;
- whether missing evidence is only absent from the index summary or absent entirely.

### D6 — Check-in cadence

Determine:

- exact number of STEPs since STEP-28;
- whether check-in cadence is due;
- whether Phase 2 Tier 2 closeout is due;
- whether a milestone review is due;
- whether release notes/user docs should be raised.

Do not reserve a STEP.

### D7 — Bridge consistency

Determine:

- whether generated files are byte-identical when expected;
- whether their source content and ordering match upstream;
- whether regeneration is reproducible;
- whether drift is generated-file drift or architecture-source drift.

## 2.4 Reverse documentation audit

Identify:

- current code concepts absent from architecture docs;
- removed functionality still documented;
- terminology missing from the glossary;
- new dependencies/services absent from infrastructure docs;
- accepted debt absent from `registries/risks.yml`;
- significant decisions lacking ADRs.

## 2.5 STEP-2 deliverable

Create:

### Document comparison matrix

| Document | Current claim | Conflicting source/reality | Status | Required treatment |
|---|---|---|---|---|

### Mandatory candidate results

| Candidate | Result | Evidence | Correct interpretation | Treatment |
|---|---|---|---|---|

Allowed results:

- Confirmed
- Partially confirmed
- Refuted
- Unverified

### STEP-2 completion gate

- [ ] Relevant architecture docs inspected
- [ ] ADRs inspected
- [ ] Risk registry inspected
- [ ] `DESIGN.md` inspected
- [ ] `PRODUCT.md` inspected
- [ ] Bridge script inspected
- [ ] All seven mandatory candidates classified
- [ ] Reverse documentation drift checked
- [ ] No generated file edited

Do not continue until no item remains unchecked.

Stop this turn with exactly:

`AUDIT STEP-2 COMPLETE — WAITING FOR REVIEW`

Do not begin AUDIT STEP-3 until the user explicitly says:

`CONTINUE TO AUDIT STEP-3`

---

# AUDIT STEP-3 — Build the Testable Specification Ledger

## 3.1 Extract testable requirements

Convert material requirements into atomic assertions.

Sources:

- current architecture docs;
- accepted ADRs;
- overview;
- STEP-29 through STEP-38 index rows;
- PLANs and definitions of done;
- substep completion claims;
- generated `DESIGN.md` and `PRODUCT.md`;
- repository README/architecture docs.

Examples:

- App uses `FTheme.neutral` and `FTheme.neutral.dark`.
- Legacy custom `ThemeData` is not the design-system source.
- User-facing strings route through localization.
- Desktop uses the documented sectioned sidebar.
- Mobile uses the documented bottom navigation behavior.
- Reporting dashboard route is removed.
- Report actions are integrated into feature screens.
- Data Bucket coordinate fields are removed at the documented layers.
- Benchmark route is reachable under the documented path.
- Attendance form extraction exists and is reachable.
- Sensitive data access is enforced by RLS.
- Every required sync registrar is wired.

## 3.2 Build requirement ledger

Use:

| Requirement ID | Atomic requirement | Source | Exact section/line | Relevant STEP | Evidence needed |
|---|---|---|---|---|---|

Rules:

- One behavior per requirement.
- Do not combine UI, persistence, synchronization, and authorization into one row.
- Do not use vague assertions such as “feature works.”
- Include compliant requirements as well as suspected failures.

## 3.3 Build STEP claim ledger

For every STEP from STEP-29 through STEP-38, extract:

- scope claim;
- each deliverable;
- each DoD item;
- each analyzer/test/build claim;
- each manual verification claim;
- later follow-up/fix claim.

Use:

| Claim ID | STEP | Claim | Source file | Exact section/line | Required evidence |
|---|---|---|---|---|---|

## 3.4 STEP-3 deliverable

Produce:

- complete requirement ledger;
- complete STEP claim ledger;
- list of ambiguous requirements requiring interpretation;
- list of historical claims that must not be treated as current truth.

### STEP-3 completion gate

- [ ] Architecture requirements extracted
- [ ] UI/design requirements extracted
- [ ] Data/security requirements extracted
- [ ] Platform/localization requirements extracted
- [ ] Offline/sync requirements extracted
- [ ] Every STEP-29 through STEP-38 claim extracted
- [ ] Every DoD item extracted
- [ ] Historical and current claims separated

Do not continue until no item remains unchecked.

Stop this turn with exactly:

`AUDIT STEP-3 COMPLETE — WAITING FOR REVIEW`

Do not begin AUDIT STEP-4 until the user explicitly says:

`CONTINUE TO AUDIT STEP-4`

---

# AUDIT STEP-4 — Specification-to-Implementation Traceability

## 4.1 Inspect Flutter implementation

At minimum inspect:

- `pubspec.yaml`;
- app entry point;
- app/router shell;
- theme configuration;
- localization configuration and generated files;
- BLoC/Cubit/provider wiring;
- dependency injection/service locator;
- domain entities;
- models and adapters;
- repositories;
- Supabase datasources;
- Hive/local datasources;
- offline queue and sync registrars;
- Supabase migrations;
- RLS policies;
- Google Drive service;
- reporting/PDF services;
- feature presentation code;
- tests;
- analyzer/lint config;
- CI config;
- Android/iOS/web/desktop platform config.

## 4.2 Verify every requirement

For every Requirement ID, record:

| Requirement ID | Implementation evidence | Test evidence | Runtime/build evidence | Status | Severity | Notes |
|---|---|---|---|---|---|---|

Allowed status:

- Compliant
- Partially compliant
- Non-compliant
- Documentation obsolete
- Intentional divergence requiring ADR/doc update
- Historically true but superseded
- Unverified

Rules:

- Filename is not proof.
- Class existence is not proof of wiring.
- Route declaration is not proof of reachability.
- Widget existence is not proof of correct rendering.
- Test-file existence is not proof of passing.
- UI role checks are not backend authorization evidence.

## 4.3 Reverse implementation audit

Search current implementation for undocumented reality:

- new routes;
- new data fields;
- new models;
- new Hive boxes/adapters;
- new services/dependencies;
- new role logic;
- new platform restrictions;
- new sync registrars;
- removed features;
- new accepted debt;
- new terminology;
- design decisions not reflected upstream.

Use:

| Implementation item | Evidence | Missing/stale documentation | Impact | Treatment |
|---|---|---|---|---|

## 4.4 Focused searches

Search relevant repositories for:

- `FThemes.zinc`
- custom `ThemeData`
- legacy theme files
- raw `Colors.*` in presentation code
- `Card`
- `ElevatedButton`
- `TextButton`
- `OutlinedButton`
- `MaterialBanner`
- hardcoded user-facing strings
- bypassed locale values
- old report-dashboard routes
- old benchmark routes
- latitude/longitude fields
- dead route names
- unreachable screens
- duplicate feature folders
- missing sync registrar bindings
- TODO
- FIXME
- HACK
- placeholder
- stub
- mock
- unimplemented
- skipped/disabled tests
- analyzer exclusions
- ignored lints
- hardcoded roles
- missing RLS
- committed secrets

Evaluate every match in context. Do not report harmless imports or strings as violations without reading the code.

## 4.5 STEP-4 deliverable

Produce:

- specification-to-implementation traceability matrix;
- implementation-to-documentation drift matrix;
- focused-search result summary;
- provisional findings list.

### STEP-4 completion gate

- [ ] Every requirement has implementation evidence
- [ ] Every requirement has a status
- [ ] Relevant tests inspected
- [ ] Reverse audit completed
- [ ] Focused searches completed
- [ ] Harmless matches filtered through context
- [ ] Provisional findings have evidence

Do not continue until no item remains unchecked.

Stop this turn with exactly:

`AUDIT STEP-4 COMPLETE — WAITING FOR REVIEW`

Do not begin AUDIT STEP-5 until the user explicitly says:

`CONTINUE TO AUDIT STEP-5`

---

# AUDIT STEP-5 — STEP-29 Through STEP-38 Completion Verification

Audit each STEP independently in numerical order.

For each STEP:

1. Read the index row.
2. Read the PLAN.
3. Read every substep prompt.
4. Read review/completion evidence.
5. Extract DoD.
6. Locate every claimed file/deliverable.
7. Verify current implementation.
8. Verify current tests.
9. Identify later STEP interactions.
10. Classify whether it was validly closed.

## 5.1 Required per-STEP table

| STEP | Claimed scope | Artifacts complete | Deliverables verified | Tests reproducible | Later impact | Current validity | Verdict |
|---|---|---|---|---|---|---|---|

Allowed verdict:

- Verified complete
- Complete with documentation drift
- Complete when closed, later superseded
- Partially complete
- Incorrectly marked Done
- Unable to verify

## 5.2 Historical versus current truth

For each failed or changed claim, distinguish:

- incomplete when marked Done;
- valid when completed but later superseded;
- docs became stale later;
- current implementation regressed;
- current evidence unavailable.

## 5.3 Required STEP-specific checks

### STEP-29
Verify Impeccable/Throughstone bridge and documentation reconciliation.

### STEP-30
Verify ForUI migration, theme API, Material purge, analyzer claims, tests, and later API corrections.

### STEP-31
Verify shell routing, desktop/mobile navigation, header, profile/theme behavior, tests, and route reachability.

### STEP-32
Verify `CreatableCombobox`, shared state/local storage, colors/tokens, and use across expected forms.

### STEP-33
Verify models, repositories, migrations, adapters, forms, combobox/auto-predict behavior, and tests.

### STEP-34
Verify Data Bucket field removal at each layer, report route removal, feature-level report actions, dead references, and tests.

### STEP-35
Verify settings repository/entity/local datasource/Cubit/UI/router, locale/theme/profile/logout/support integration, and tests.

### STEP-36
Verify benchmark domain/data/presentation/sync/CRS behavior, route, navigation, migrations/storage, and tests.

### STEP-37
Verify residual Material purge claims in every named widget, distinguish legitimate interoperability, and reproduce analyzer/tests.

### STEP-38
Verify every recorded UI/UX fix, the claimed count of fixes, regression tests, manual/runtime evidence, and final verification gate.

## 5.4 STEP-5 deliverable

Produce:

- STEP-29 through STEP-38 completion table;
- one subsection per STEP;
- list of prematurely closed STEPs;
- list of historically valid but superseded STEPs;
- list of missing evidence.

### STEP-5 completion gate

- [ ] STEP-29 audited
- [ ] STEP-30 audited
- [ ] STEP-31 audited
- [ ] STEP-32 audited
- [ ] STEP-33 audited
- [ ] STEP-34 audited
- [ ] STEP-35 audited
- [ ] STEP-36 audited
- [ ] STEP-37 audited
- [ ] STEP-38 audited
- [ ] Historical/current truth separated
- [ ] Every STEP has a verdict

Do not continue until no item remains unchecked.

Stop this turn with exactly:

`AUDIT STEP-5 COMPLETE — WAITING FOR REVIEW`

Do not begin AUDIT STEP-6 until the user explicitly says:

`CONTINUE TO AUDIT STEP-6`

---

# AUDIT STEP-6 — Execute Verification Commands

## 6.1 Baseline commands

From `Code/mine-flow-app`, run:

```sh
flutter pub get
flutter analyze
flutter test
```

Record exact command, working directory, exit code, duration, and result summary.

## 6.2 Targeted tests

Run targeted tests for:

- app shell and router;
- settings and localization;
- attendance;
- cut/fill;
- land clearing;
- inventory;
- equipment checks;
- Data Bucket;
- reporting;
- benchmark;
- offline sync;
- authentication/authorization where available.

## 6.3 Builds and generated artifacts

Where the environment supports it, verify:

- debug buildability for officially supported platforms;
- localization generation consistency;
- code generation consistency;
- migration consistency;
- Hive adapter identifiers;
- route reachability;
- sync registrar bindings;
- CI command parity.

Do not call a platform supported merely because it compiles.

## 6.4 Security, privacy, and data integrity

Audit:

- RLS policies;
- role boundaries;
- personal data access;
- secrets;
- migrations;
- destructive operations;
- offline sync conflict/failure handling;
- Google Drive credentials and access handling;
- data-loss risks;
- hardcoded or UI-only authorization.

## 6.5 Command ledger

| Command | Working directory | Exit code | Duration | Result | Findings/claims supported |
|---|---|---:|---:|---|---|

## 6.6 Test ledger

| Test file | Test/group | Executed | Result | Requirement/claim supported |
|---|---|---|---|---|

## 6.7 STEP-6 deliverable

Produce:

- analyzer results;
- full test results;
- targeted test results;
- build results;
- CI comparison;
- security/privacy/data-integrity findings;
- blockers and environment limitations.

### STEP-6 completion gate

- [ ] `flutter pub get` attempted
- [ ] `flutter analyze` attempted
- [ ] Full `flutter test` attempted
- [ ] Targeted test groups attempted
- [ ] Historical counts separated from current results
- [ ] Buildability checked where possible
- [ ] Security/RLS reviewed
- [ ] Secrets reviewed
- [ ] Offline sync/data integrity reviewed
- [ ] Every blocked command documented

Do not continue until no item remains unchecked.

Stop this turn with exactly:

`AUDIT STEP-6 COMPLETE — WAITING FOR REVIEW`

Do not begin AUDIT STEP-7 until the user explicitly says:

`CONTINUE TO AUDIT STEP-7`

---

# AUDIT STEP-7 — Final Reconciliation Report

Create one Markdown report. Do not modify project files.

## 7.1 Required structure

### 1. Executive verdict

Include:

- overall implementation/spec alignment;
- whether Phase 2 Tier 2 is genuinely complete;
- count of Critical, High, Medium, Low, and Informational findings;
- whether a check-in is due;
- top five discrepancies;
- audit limitations.

### 2. Resolved current state

Include:

- project marker;
- current phase/tier;
- last completed STEP;
- in-progress STEP;
- status resolver result;
- index confirmation;
- next Throughstone action.

### 3. Audit coverage

Include:

- files inspected;
- repositories inspected;
- code areas inspected;
- commands run;
- tests run;
- unverified areas.

### 4. Specification-to-implementation traceability matrix

| ID | Requirement | Specification source | Implementation evidence | Test evidence | Status | Severity | Action |
|---|---|---|---|---|---|---|---|

### 5. Mandatory documentation-drift results

One subsection for D1–D7, each marked:

- Confirmed
- Partially confirmed
- Refuted
- Unverified

### 6. Additional specification → implementation discrepancies

### 7. Additional implementation → documentation drift

### 8. STEP-29 through STEP-38 completion audit

| STEP | Claimed scope | Deliverables verified | Tests reproduced | Current validity | Gaps | Verdict |
|---|---|---|---|---|---|---|

### 9. Test, analyzer, build, and CI results

Show exact current commands and results.

### 10. Security, privacy, and data-integrity findings

### 11. UI/design-system and Impeccable bridge findings

Cover:

- ForUI compliance;
- legitimate versus violating Material usage;
- theme tokens;
- typography;
- density;
- navigation;
- responsive behavior;
- localization;
- accessibility;
- motion;
- generated bridge consistency.

### 12. Documentation corrections required

For every correction name:

- source-of-truth file;
- exact section;
- current error;
- proposed correction;
- version bump;
- bridge regeneration;
- ADR requirement.

### 13. Recommended remediation backlog

Order by:

1. security/data;
2. broken functionality;
3. spec/code contradictions;
4. test gaps;
5. documentation drift;
6. cosmetic issues.

Classify each as:

- lightweight issue;
- follow-up substep;
- new implementation STEP;
- architecture-only follow-up;
- Check-in STEP;
- ADR;
- risk entry.

### 14. Proposed Throughstone next action

State, but do not execute:

- whether to reserve a Check-in STEP;
- suggested title;
- one-line scope;
- repositories;
- why it qualifies as a STEP;
- suggested high-level substeps;
- final verification gate.

### 15. Unverified claims and blockers

### 16. Evidence integrity ledger

#### Files

| File | Why inspected | Sections/symbols | Findings supported |
|---|---|---|---|

#### Commands

| Command | Working directory | Exit code | Result | Findings supported |
|---|---|---:|---|---|

#### Tests

| Test file | Test/group | Executed | Result | Requirement supported |
|---|---|---|---|---|

### 17. Final conclusion

Answer directly:

1. Are the specifications and implementation aligned?
2. Is Phase 2 Tier 2 actually complete?
3. What must happen before it is reconciled?
4. What is the single highest-priority next action?

## 7.2 Final integrity gate

Before finishing, verify:

- [ ] Every requirement has a status
- [ ] Every STEP-29 through STEP-38 has a verdict
- [ ] All seven mandatory drift candidates are classified
- [ ] Every finding has evidence
- [ ] Every command claim appears in the command ledger
- [ ] Every inspected file appears in the file ledger
- [ ] Historical test counts are separated from current results
- [ ] Static, test, build, and runtime evidence are separated
- [ ] Generated files were not edited
- [ ] No project file was modified
- [ ] Remediation is proposed but not executed

End with exactly:

`PHASE 2 TIER 2 AUDIT COMPLETE — NO PROJECT FILES MODIFIED`
