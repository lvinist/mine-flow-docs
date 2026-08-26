# ADR-0011: Staging Promotion Pipeline

**Status:** Accepted
**Date:** 2026-08-09

## Related documents

- architecture/08-infrastructure-deployment.md (§2 Build & Deploy Pipeline, §3 ClickOps)
- architecture/09-environments.md (§4 Promotion Flow, §5 Rollback Procedures)
- runbooks/staging-provision.md
- runbooks/release-procedure.md
- RISK-0010 (`registries/risks.yml`)

## Context

Reaching Phase 3, mine-flow needed a real, reproducible staging environment and a deliberate
production promotion gate. Three decisions were made simultaneously, all about the same
promotion pipeline:

1. How to target two deployment slots (staging, production) in GitHub Pages without making
   branch topology complicated.
2. How to provision the staging Supabase project — managed infrastructure-as-code or manual.
3. How to scope Google Drive credentials for staging versus production.

The project is solo-developer MVP work on three fully managed services (GitHub Pages,
Supabase Cloud, Google Drive), with an explicit cost/coupling posture of accepting vendor
lock-in and minimal toolchain (Doc 08 §3, §7).

## Decision

1. **Use GitHub Actions environments (`staging`, `production`), not branch-per-environment.**
   **Rationale.** Keeps `master` the single trunk — push/merge deploys staging; publishing a
   Release triggers production with a native required-reviewer approval gate. No extra branch
   management overhead. **Alternatives.** Branch-per-environment rejected: complex topology
   (every change must be cherry-picked/merged between environment branches) and no native
   approval gate. **Reversibility.** Low-cost: jobs reference an environment name; renaming or
   re-pointing an environment does not move code.

2. **Use ClickOps plus a runbook, not Terraform, for Supabase staging provisioning.**
   **Rationale.** Per Doc 08 §3 ("ClickOps + Database as Code"), the infrastructure footprint
   is too small (one Supabase project, one GCP service account, one Drive folder) to justify
   IaC toolchain complexity; schema reproducibility — the part that actually matters — already
   lives as code in migrations, and `runbooks/staging-provision.md` documents every manual step
   for reproducibility. **Alternatives.** Terraform rejected: overkill for 3 managed services;
   provider coverage and state management would outweigh the footprint it manages.
   **Reversibility.** Medium: adopting IaC later means codifying what the runbook documents —
   nothing prevents that.

3. **Use a fully separate GCP service account for staging, not shared with production.**
   **Rationale.** Credential isolation: a leaked staging key cannot touch production Drive
   data, and separate accounts make access auditing straightforward (one identity per
   environment). **Alternatives.** A shared service account distinguished only by Drive folder
   was rejected: no credential isolation and harder auditing. **Reversibility.** Low-cost:
   create another account per environment whenever needed.

## Consequences

- Staging provisioning is ClickOps-only; if the staging project is deleted, recovery is manual
  by following `runbooks/staging-provision.md`. Tracked as **RISK-0010** in
  `registries/risks.yml`.
- Production releases require a Release publication **and** a human approval — intentional
  friction; emergencies are slower by design.
- The Dart-type contract originally planned here changed during execution (Supabase CLI dropped
  Dart typegen): the committed contract artifact is TypeScript (`supabase/types/database.ts`)
  validated by `tool/check_supabase_contracts.dart`. That substitution does not alter any of
  the three decisions above.

<!--
  Amendments: never rewrite the Decision above. If something changes, append:
  ## Amendment ({{DATE}} — {{reason/STEP}})
-->
