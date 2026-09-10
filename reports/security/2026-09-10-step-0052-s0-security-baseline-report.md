# S0 Security Baseline Report — mine-flow

**Review level:** S0 — Security Baseline
**Review date:** 2026-09-10
**Trigger:** Cadence rule triggered (15 days since first S0)
**Reviewer(s):** Antigravity
**Report owner:** Antigravity
**Reviewed commit:** 6fbce5e
**STEP / issue:** STEP-52

## Summary

- **Baseline decision:** Partial (Pre-production check, 1 critical finding)
- **Release-readiness impact:** Blocked for production release until FINDING-52.1-01 is remediated.
- **Highest-risk gap:** FINDING-52.1-01 — Privilege Escalation in `public.users` table self-update policy.
- **Next required action:** Remediate `users_update_self` RLS policy.
- **Next review trigger/date:** Next S0 review / S1 sweep.

## Scope

### Included

- Repositories: `Code/mine-flow-app`
- CI/CD systems: GitHub Actions (`.github/workflows/ci.yml`)
- Package ecosystems: Flutter/Dart (pubspec.yaml)
- Deployment artifacts: Android APK, Web Build
- Infrastructure/cloud/IaC: Supabase (Auth, Postgres RLS for 11 tables)
- Secret stores and environments: GitHub Secrets, local `.env`
- External security tooling/dashboards: Supabase Auth logs

### Intentionally skipped

| Area skipped | Reason | Owner | Revisit trigger |
|--------------|--------|-------|-----------------|
| Container/image scanning | No Docker/container images; static Web and Android APK | Team | If containers introduced |
| IaC/cloud config scanning | No IaC (Terraform/Pulumi). Supabase managed via SQL migrations | Team | If IaC is introduced |

## Change Markers

| Marker | Value | Notes |
|--------|-------|-------|
| Previous S0 report | 2026-08-26-step-0044-s0-security-baseline-report.md | Commit 5536191 |
| Elapsed time since previous S0 | 15 days | |
| Reviewed commit | 6fbce5e | Match `registries/security-reviews.yml`. |
| Commits since previous S0 | 75 | Across STEPs 45–51 |
| Rough SLOC or equivalent size | ~14,000 Dart LOC | |
| Rough SLOC delta since previous S0 | +~3,000 LOC | |
| Major repo/CI/hosting/ownership changes | Dual-platform E2E, AGP 9 / JDK 17, 2 new tables | |

## Baseline Decision Table

Use statuses exactly as defined by
[`runbooks/security-review-s0-checklist.md`](../../../runbooks/security-review-s0-checklist.md):
`Done`, `Planned`, `Deferred`, `Accepted Risk`, or `N/A`.

| Area | Baseline item | Status | Decision date | Owner | Reason / evidence | Revisit trigger | Risk ref |
|------|---------------|--------|---------------|-------|-------------------|-----------------|----------|
| Setup | Read last S0 report & ledger | Done | 2026-09-10 | Antigravity | Read `reports/security/2026-08-26-step-0044-s0-security-baseline-report.md` (commit `5536191`); evaluated +75 commits across STEPs 45–51, +3k LOC, 2 new tables. | Next S0 review / S1 sweep | — |
| Release posture | First-release security baseline recorded | Done | 2026-09-10 | Team | STEP-52 re-check confirms updated security posture post-STEP-48. | Before public release | — |
| Release posture | Release runbook security pre-flight | Done | 2026-09-10 | Team | `runbooks/release-procedure.md`, `release-deploy.md`, `staging-provision.md`; `deploy-production` gated by manual reviewer. | After deployment changes | — |
| Ownership | Security owners identified | Accepted Risk | 2026-09-10 | Project Manager | Internal MVP; owner is Project Manager / Site Supervisor; no formal role separation yet. | Team growth / production handoff | RISK-0013 |
| Ownership | Access review cadence | Deferred | 2026-09-10 | Project Manager | Small team; reviews tied to Throughstone check-in cadence (~10–20 STEPs). | Before production with real data | — |
| Repository hygiene | Default branch protection configured | Accepted Risk | 2026-09-10 | Project Manager | Unverified locally (`gh` CLI not installed). Strict CI gates on all pushes. | Before external contributors | RISK-0013 |
| Repository hygiene | Required status checks configured | Accepted Risk | 2026-09-10 | Project Manager | CI runs on all pushes/PRs; GitHub branch protection settings unverified locally without `gh`. | Before external contributors | RISK-0013 |
| Repository hygiene | Security policy / reporting path | N/A | 2026-09-10 | Team | Internal enterprise mining tool; source and app not publicly distributed. | Before public source / release | — |
| Repository hygiene | OpenSSF Scorecard repo hygiene | Deferred | 2026-09-10 | Team | Internal MVP; automated Scorecard badge adds disproportionate overhead. | Before public launch | — |
| Repository hygiene | Release provenance recorded | Done | 2026-09-10 | Team | GitHub release tags trigger `deploy-production`; `softprops/action-gh-release@v2` attaches APK by SHA. | Before distributing signed APKs | — |
| CI hygiene | CI runs from reviewed repository code | Done | 2026-09-10 | Team | `.github/workflows/ci.yml` reviewed; uses standard `pull_request` (not `pull_request_target`). | After workflow changes | — |
| CI hygiene | CI token permissions least-privilege | Done | 2026-09-10 | Team | `test` and `build` jobs have no write permissions; `contents: write` scoped only to deploy jobs. | After modifying permissions | — |
| CI hygiene | Third-party CI actions controlled/pinned | Accepted Risk | 2026-09-10 | Team | Major-version tag pinned (`@v4`, `@v2`), not full commit SHA digest pinned. Standard for MVP. | Before regulated/audit use | RISK-0013 |
| CI hygiene | CI secrets exposed only to trusted jobs | Done | 2026-09-10 | Team | Staging and Production environments segregated; production requires manual approval. | After CI environment changes | — |
| CI hygiene | Build/test workflows cover release branches | Done | 2026-09-10 | Team | Required CI gates include execution guards (`check_e2e_executed.dart`, contract & l10n guards); fail closed. | Before adding release branches | — |
| Secrets handling | Secrets stored in CI/secret manager | Done | 2026-09-10 | Team | Stored in GitHub Secrets; `.env` gitignored; zero hardcoded secrets in repository files. | After adding integrations | — |
| Secrets handling | Secret scanning enabled | Accepted Risk | 2026-09-10 | Team | GitHub push protection / secret scanning unverified locally (no `gh` CLI). Git history clean. | Before production release | RISK-0013 |
| Secrets handling | Suspected secret exposure response path | Done | 2026-09-10 | Team | `runbooks/secrets-rotation.md` covers Supabase keys, Google Drive credentials, and GitHub PATs. | After adding secret classes | — |
| Secrets handling | Local dev uses ignored files & templates | Done | 2026-09-10 | Antigravity | `.gitignore` covers `.env`; `.env.example` updated with E2E test runner credentials (`6fbce5e`). | After adding config keys | — |
| Dependency alerts | Vulnerability alerting enabled | Accepted Risk | 2026-09-10 | Team | Dependabot status unverified locally. Regular review during Throughstone check-ins. | Before production release | RISK-0013 |
| Dependency alerts | Dependency update policy exists | Done | 2026-09-10 | Team | `runbooks/dependency-supply-chain.md` exists; dependency checks at check-in cadence (~10–20 STEPs). | After major SDK upgrades | — |
| Dependency alerts | Lockfiles committed & checked | Done | 2026-09-10 | Team | `pubspec.lock` committed and verified by `flutter pub get` in CI. | After adding package managers | — |
| Dependency alerts | License compatibility review planned | N/A | 2026-09-10 | Team | Internal tool; no external redistribution. All packages use permissive licenses (MIT/BSD/Apache). | Before commercial redistribution | — |
| Static analysis | Security linting / SAST configured | Done | 2026-09-10 | Team | `flutter analyze` with `flutter_lints`, plus contract and l10n custom guards in CI. | After Flutter SDK upgrades | — |
| Static analysis | Findings triaged & clean | Done | 2026-09-10 | Team | `flutter analyze` reports 0 issues globally; CI enforces zero errors/warnings. | Each S1 sweep / check-in | — |
| Artifacts | Container / image scanning | N/A | 2026-09-10 | Team | No Docker/container images; static Web on GitHub Pages and Android APK directly from Gradle. | If containers introduced | — |
| Artifacts | Release artifacts reproducible & traceable | Done | 2026-09-10 | Team | Built from tagged release commit with pinned Flutter `3.47.1` and committed lockfile; APK traceable to SHA. | After pipeline changes | — |
| Infrastructure | IaC / cloud config scanning | N/A | 2026-09-10 | Team | No IaC (Terraform/Pulumi). Supabase managed via SQL migrations and ClickOps. | If IaC is introduced | RISK-0010 |
| Infrastructure | Production environments access controlled | Accepted Risk | 2026-09-10 | Team | Staging separated from Production. RLS enabled on 11/11 tables. FINDING-52.1-01 identified that `users_update_self` permits role escalation if not guarded; tracked for remediation before production. | Before production release | FINDING-52.1-01 / Doc 06 |
| SBOM | SBOM generation | Deferred | 2026-09-10 | Team | Internal MVP; no customer or regulatory distribution requirement. | Before enterprise distribution | — |
| Monitoring | Security operational signals identified | Accepted Risk | 2026-09-10 | Team | Supabase Auth logs capture login failures. No custom alerting/SIEM dashboard configured for MVP. | Before production use | RISK-0013 |
| Incident readiness | Incident response entry point documented | Done | 2026-09-10 | Team | `runbooks/incident-postmortem.md` defines RCA, patch, and postmortem workflow. Owner: Project Manager. | Before production use | — |
| Backup/recovery | Backup, restore, rollback assumptions | Accepted Risk | 2026-09-10 | Team | Supabase free-tier (no automated backups/PITR). Manual CLI procedure documented; no fire-drill yet. | Before production data load | RISK-0012 |
| Data handling | Sensitive data classes & controls reflected | Done | 2026-09-10 | Team | Doc 06 (Threat Model) and Doc 17 (Privacy) identify NIK, DOB, emergency contacts, and geospatial data. | When data scope changes | RISK-0011 |

## Tooling Inventory

| Tool / control | Purpose | Scope | Status | Evidence / link | Owner |
|----------------|---------|-------|--------|-----------------|-------|
| Dependabot | Dependency alerts | GitHub Repo | Deferred | GitHub UI | Project Manager |
| GitHub Secret Scanning | Secret scanning | GitHub Repo | Deferred | GitHub UI | Project Manager |
| flutter analyze | SAST / security lint | Dart/Flutter Code | Configured | CI Workflow | Team |
| N/A | Container/image/package scan | N/A | N/A | | |
| N/A | IaC/cloud config scan | N/A | N/A | | |
| N/A | SBOM generation | N/A | N/A | | |
| N/A | OpenSSF Scorecard-style repo hygiene | N/A | N/A | | |

## Findings and Decisions

### Fixed During Review

| Item | Change made | Evidence |
|------|-------------|----------|
| Missing CI Secrets | Wired `--dart-define=TEST_CREW_EMAIL=${{ secrets.TEST_CREW_EMAIL }}` into workflows. | `commit be44843` |
| Dev Config Documentation | Updated `.env.example` with E2E test runner credentials. | `commit 6fbce5e` |

### Planned Follow-Up

| Item | Owner | Target date / trigger | STEP / issue | Risk ref |
|------|-------|-----------------------|--------------|----------|
| Privilege Escalation in `public.users` self-update | Team | Before production release | TBD | FINDING-52.1-01 |

### Deferred Or Accepted Risk

| Risk ref | Decision | Reason | Owner | Revisit trigger |
|----------|----------|--------|-------|-----------------|
| RISK-0011 | Open | In-app Privacy Notice absent from first-login flow. | Team | Pre-release |
| RISK-0012 | Open | Supabase free-tier: no backups. | Team | Pre-production data load |
| RISK-0013 | Accepted Risk | S0 baseline operations cluster (branch protection, secret scanning, Dependabot, monitoring) missing. | Team | Before external contributors |
| RISK-0021 | Partial RLS matrix (Crew tests unwired) | Gap resolved; but tests skipped as creds not yet provisioned in GitHub secrets. | Team | When secrets provisioned |

## Reviewer Notes

Overall security posture improved with dual-platform CI E2E tests, but the critical privilege escalation vulnerability (FINDING-52.1-01) must be fixed before going to production. RLS is actively enforced on all 11 tables. Crew logic isolation verified.
