# S0 Security Baseline Report — mine-flow

**Review level:** S0 — Security Baseline
**Review date:** 2026-08-26
**Trigger:** First release approaching (Phase 3 pre-staging); STEP-44 release-control baseline
**Reviewer(s):** Antigravity (Claude Sonnet 4.6 Thinking)
**Report owner:** Project Manager / Site Supervisor
**Reviewed commit:** `5536191` (mine-flow-app `master`); `ae7a51f` (prompts `main`)
**STEP / issue:** STEP-44

---

## Summary

- **Baseline decision:** Done (S0 complete with accepted risks and planned items recorded)
- **Release-readiness impact:** Two pre-release gaps must close before production: privacy notice
  (RISK-0011) and production backup procedure (RISK-0012). All other gaps are tracked with owners
  and revisit triggers.
- **Highest-risk gap:** Privacy notice absent from first-login flow (RISK-0011) — required by
  Doc 17 §3 before production.
- **Next required action:** Implement in-app privacy notice (RISK-0011) as a pre-release gate;
  provision production Supabase project on a paid plan or document manual backup before first
  production data load (RISK-0012).
- **Next review trigger/date:** Before production release; or after any major CI/hosting/repo
  ownership change; or at the next S1 sweep (~3 months post-release).

---

## Scope

### Included

- Repositories: `mine-flow-app` (commit `5536191`), `mine-flow-docs` (commit on `step-0044-security-baseline`)
- CI/CD systems: GitHub Actions (`.github/workflows/ci.yml`)
- Package ecosystems: Dart/Flutter (`pubspec.yaml` + `pubspec.lock`)
- Deployment artifacts: Flutter Web (GitHub Pages), Android APK
- Infrastructure/cloud/IaC: Supabase (cloud-hosted, free tier), GitHub Pages
- Secret stores and environments: GitHub Repository Secrets (`staging`, `production` environments)
- External security tooling/dashboards: GitHub platform secret scanning (status: not verified locally — see row)

### Intentionally skipped

| Area skipped | Reason | Owner | Revisit trigger |
|---|---|---|---|
| S2 deep structured audit | Project not yet in production use; S0 sufficient pre-staging | Team | Before public launch or sensitive production use |
| Live RLS behavior test (via Supabase dashboard) | No live staging credentials available in local environment; static review performed | STEP-45 owner | STEP-45 E2E test pass against staging |
| External penetration test | Overkill for 100-user internal tool MVP | TBD | Before external/public launch if ever applicable |

---

## Change Markers

| Marker | Value | Notes |
|---|---|---|
| Previous S0 report | None | This is the first S0 baseline |
| Elapsed time since previous S0 | N/A | First run |
| Reviewed commit | `5536191` (mine-flow-app) | Most recent master commit at time of review |
| Commits since previous S0 | N/A | First run |
| Rough SLOC or equivalent size | ~11,000 Dart LOC (lib/) | Estimate |
| Rough SLOC delta since previous S0 | N/A | First run |
| Major repo/CI/hosting/ownership changes | STEP-42 (staging CI pipeline), STEP-43 (Flutter 3.47 upgrade) | Both completed before this review |

---

## Baseline Decision Table

| Area | Baseline item | Status | Decision date | Owner | Reason / evidence | Revisit trigger | Risk ref |
|---|---|---|---|---|---|---|---|
| Setup | Read the last S0 report and `registries/security-reviews.yml`; record elapsed time, commits, rough size change, previous baseline decisions, and carry-forward items. | Done | 2026-08-26 | Antigravity | First S0 — no previous report; `security-reviews.yml` was empty; all rows filled fresh. | Next S0 review | — |
| Release posture | First-release security baseline decision recorded. | Done | 2026-08-26 | Team | This report is the baseline decision. | Before public launch; when release scope changes | — |
| Release posture | Release runbook has a security-aware pre-flight: tests green, config/secrets in place, rollback plan, and production verification. | Done | 2026-08-26 | Team | `runbooks/release-procedure.md` and `runbooks/release-deploy.md` exist; `deploy-production` CI job has manual approval gate via `production` GitHub environment; rollback path documented in `runbooks/staging-provision.md`. | After deployment process changes | — |
| Ownership | Security owners or accountable maintainers are identified for code, infrastructure, secrets, and incident response. | Accepted Risk | 2026-08-26 | TBD | MVP internal tool; owner is the Project Manager / Site Supervisor. No formal role separation yet. | Before team growth or production handoff | RISK-0013 |
| Ownership | Access review cadence exists for repos, CI/CD, package registries, cloud accounts, production systems, and secret stores. | Deferred | 2026-08-26 | TBD | No formal cadence; rely on check-in review cycle (~10-20 STEPs). | Before production use with real data | — |
| Repository hygiene | Default branch protection or equivalent merge control is configured for protected branches. | Accepted Risk | 2026-08-26 | TBD | Not verified locally; GitHub UI not inspected. Single-developer project in development phase — no outsider PRs expected. | Before external contributors; before production | RISK-0013 |
| Repository hygiene | Required review/status checks are configured for security-relevant branches. | Accepted Risk | 2026-08-26 | TBD | CI passes on every push; no explicit required-status-checks rule confirmed in branch protection settings. | Before external contributors; before production | RISK-0013 |
| Repository hygiene | Security policy or vulnerability-reporting path exists. | N/A | 2026-08-26 | Team | Internal tool, no external users or public source. No `SECURITY.md` needed for MVP. | Before public source or external users | — |
| Repository hygiene | OpenSSF Scorecard-style repo hygiene has been reviewed or intentionally deferred. | Deferred | 2026-08-26 | TBD | Internal tool at dev stage; not worth scorecard overhead. | Before public launch | — |
| Repository hygiene | Release provenance expectations are recorded. | Done | 2026-08-26 | Team | Release tags + `softprops/action-gh-release` attaches APK to GitHub Release; `ci.yml` documents artifact source. No signed releases required for internal MVP. | Before distributing APK externally | — |
| CI hygiene | CI workflows run from reviewed repository code and avoid dangerous pull-request contexts. | Done | 2026-08-26 | Team | Workflow in `.github/workflows/ci.yml` — reviewed. All steps use repository code. No fork PR triggers that would expose secrets. `push` and `pull_request` triggers are standard. | After adding/changing workflows | — |
| CI hygiene | CI token permissions are least-privilege by default. | Done | 2026-08-26 | Team | `deploy-staging` and `deploy-production` jobs explicitly declare `permissions: contents: write` only where needed for Pages push. Test and build jobs have no explicit write permissions. | After workflow changes | — |
| CI hygiene | Third-party CI actions are pinned or controlled. | Accepted Risk | 2026-08-26 | TBD | Actions use tag-based pinning (`@v4`, `@v2`) not SHA-digest pins. Acceptable for internal tool at this stage. | Before regulated/high-assurance use | RISK-0013 |
| CI hygiene | CI secrets are only exposed to trusted jobs/environments. | Done | 2026-08-26 | Team | `STAGING_*` secrets scoped to the `staging` GitHub environment; `PROD_*` scoped to the `production` environment with required reviewer gate. Test job uses `STAGING_*` via `secrets.*` — not printed. | After CI/provider changes | — |
| CI hygiene | Build and test workflows cover the release branches and fail closed for required checks. | Done | 2026-08-26 | Team | `ci.yml` triggers on `push` and `pull_request`; `deploy-production` needs manual approval. 434/434 tests passing (STEP-43.9). | Before adding release branches | — |
| Secrets handling | Secrets are stored in a secret manager or CI secret store, not in tracked files. | Done | 2026-08-26 | Team | `.env` is gitignored (`.gitignore` line 47-48). All CI credentials use `${{ secrets.* }}`. No hardcoded values found in any workflow or Dart source. | Before deploying shared environments | — |
| Secrets handling | `.env.example` exists documenting required keys without values. | Done | 2026-08-26 | Team | `.env.example` created in STEP-44.5. Previously missing — remediated in this STEP. | After adding new config keys | — |
| Secrets handling | Secret scanning is enabled or run for repository history. | Accepted Risk | 2026-08-26 | TBD | GitHub push protection / secret scanning status not verified locally (requires GitHub UI access). No secrets appear in code review of Dart files or CI. Enable GitHub secret scanning in repo settings. | Before production; at next S1 sweep | RISK-0013 |
| Secrets handling | A suspected-secret-exposure response path exists and points to the secrets rotation runbook. | Done | 2026-08-26 | Team | `runbooks/secrets-rotation.md` exists and covers Supabase keys, Google Drive credentials, and GitHub PATs. | After adding secret classes | — |
| Secrets handling | Local development configuration uses ignored secret files and committed examples only. | Done | 2026-08-26 | Team | `.gitignore` covers `.env`; `.env.example` created in STEP-44.5. `ONBOARDING.md` references the pattern. | After adding config/secrets | — |
| Dependency alerts | Dependency vulnerability alerting is enabled or scheduled. | Accepted Risk | 2026-08-26 | TBD | GitHub Dependabot not confirmed enabled; OSV-Scanner not configured. Dependency review was done manually in STEP-43. | Before production; enable Dependabot in repo settings; add to check-in cadence | RISK-0013 |
| Dependency alerts | Dependency update policy exists for security patches. | Done | 2026-08-26 | Team | `runbooks/dependency-supply-chain.md` exists; STEP-43 upgraded all outdated packages; check-in cadence at ~10-20 STEPs. | After check-in finds stale dependencies | — |
| Dependency alerts | Lockfiles or equivalent reproducible dependency controls are committed. | Done | 2026-08-26 | Team | `pubspec.lock` is committed and checked by `flutter pub get` in CI. | After adding package managers | — |
| Dependency alerts | License compatibility scanning or manual review is planned. | N/A | 2026-08-26 | Team | Internal tool; no external redistribution. All packages are Apache 2.0 / BSD / MIT. | Before any public distribution | — |
| Static analysis | Security-oriented linting or SAST is configured. | Done | 2026-08-26 | Team | `flutter analyze` (Dart analyzer) is a required CI gate. Catches unsafe code patterns, null safety issues, deprecated APIs. No dedicated SAST — acceptable for internal Flutter app. | Before regulated/high-assurance use | — |
| Static analysis | SAST/security lint findings are triaged. | Done | 2026-08-26 | Team | `flutter analyze` reports 0 issues (STEP-43.9 verified). No outstanding analyzer warnings. | Each S1 sweep | — |
| Artifacts | Container/image/package scanning configured. | N/A | 2026-08-26 | Team | No container images. Flutter Web deployed as static assets; Android APK attached to GitHub Release. | Before shipping container images | — |
| Artifacts | Release artifacts are built reproducibly enough to trace source. | Done | 2026-08-26 | Team | `ci.yml` build jobs reference pinned Flutter `3.47.0` and build from the committed source at the release tag. APK attached to GitHub Release by SHA. | After pipeline changes | — |
| Infrastructure | IaC/cloud configuration scanning configured. | N/A | 2026-08-26 | Team | No IaC; Supabase provisioned via ClickOps (RISK-0010). GitHub Pages is the only cloud infra. | Before IaC/cloud automation | — |
| Infrastructure | Production-like environments have baseline access controls. | Done | 2026-08-26 | Team | Staging Supabase project: credentials in GitHub Secrets, `staging` environment gates all deploys. Production: `production` environment requires manual reviewer approval. | Before production use | — |
| SBOM | SBOM generation is configured, planned, or explicitly deferred. | Deferred | 2026-08-26 | TBD | Internal tool; no enterprise/customer distribution requirement. | Before enterprise distribution or regulated use | — |
| Monitoring | Security-relevant operational signals are identified. | Accepted Risk | 2026-08-26 | TBD | Supabase Auth logs capture login failures. No custom alerting or audit-log dashboard configured. Acceptable for internal MVP pre-launch. | Before production use with real data | RISK-0013 |
| Incident readiness | Incident response entry point and escalation owner are documented. | Done | 2026-08-26 | Team | `runbooks/incident-postmortem.md` exists. Escalation owner is Project Manager / Site Supervisor. | Before production use | — |
| Backup/recovery | Backup, restore, and rollback assumptions recorded. | Accepted Risk | 2026-08-26 | TBD | Supabase free-tier: no automatic daily backups. Manual snapshot procedure documented in §Backup below. Accepted until production data load. | Before first production data load | RISK-0012 |
| Data handling | Sensitive data classes and minimum controls reflected in architecture docs. | Done | 2026-08-26 | Team | Doc 06 (Security & Threat Model) and Doc 17 (Privacy & Compliance) document sensitive data classes and controls. RLS enforces role-level access. | Before collecting sensitive data; after product scope changes | — |

---

## Area Detail: RLS / Authorization Behavior (44.2)

**Audit method:** Static review of all 5 Supabase migration files against Doc 06 §4 and RBAC design.

**Tables covered by RLS (migration 02):** `users`, `zones`, `attendance_records`, `equipment_checks`, `daily_logs`, `cut_fill_records`, `land_clearing_records`, `inventory_items`, `geospatial_files` — **all 9 tables**.

**Post-RLS migrations reviewed:**

| Migration | Scope | New tables? | RLS impact |
|---|---|---|---|
| `20260718000003_data_bucket_enhancements.sql` | Adds columns to `geospatial_files`; adds indexes | None | RLS inherited; idempotent fallback policies included in migration |
| `20260723_step_33_1_data_model_polish.sql` | Renames columns in `cut_fill_records` and `land_clearing_records` | None | No RLS change needed — same table names, same policies |
| `20260724_step_34_1_drop_geospatial_file_lat_lon.sql` | Drops `latitude`/`longitude` columns from `geospatial_files` | None | No RLS impact — column drop only |

**Finding:** No RLS coverage gaps. All tables have role-appropriate policies. **No remediation migration needed.**

**Policy completeness check:**

| Table | Supervisor | Foreman | Crew | Self-update | Notes |
|---|---|---|---|---|---|
| users | ALL | SELECT (active only) | SELECT (active only) | UPDATE own | Hard-delete blocked; cascade from auth.users is Supabase-controlled (intentional) |
| zones | ALL | SELECT (active) | SELECT (active) | — | |
| attendance_records | ALL | SELECT/INSERT/UPDATE | SELECT own / INSERT own | — | Crew sees own attendance only |
| equipment_checks | ALL | SELECT/INSERT/UPDATE | SELECT | — | |
| daily_logs | ALL | SELECT/INSERT/UPDATE | SELECT (approved only) | — | Crew sees approved logs only |
| cut_fill_records | ALL | SELECT/INSERT/UPDATE | SELECT | — | |
| land_clearing_records | ALL | SELECT/INSERT/UPDATE | SELECT | — | |
| inventory_items | ALL | SELECT/INSERT/UPDATE | SELECT | — | |
| geospatial_files | ALL | SELECT/INSERT | SELECT | — | No foreman UPDATE — upload-only by design |

---

## Area Detail: Account Lifecycle (44.3)

**Finding:** Correctly implemented. `users.deleted_at` exists; only supervisors can DELETE; hard-delete requires Supabase Admin API (not accessible via anon key). No gaps.

---

## Area Detail: Privacy Notice (44.4)

**Finding:** NOT implemented. Zero matches for privacy/terms/privasi patterns across all Dart files. Recorded as **RISK-0011** — pre-release gate.

---

## Area Detail: Secrets Posture (44.5)

**Finding:** Sound. `.env` gitignored; all CI secrets via `secrets.*`; no hardcoded values found. `.env.example` was absent — created in STEP-44.5 (remediated). GitHub secret scanning status not verified locally.

---

## Area Detail: Backup / Restore Fire-Drill (44.6)

**Supabase plan:** Free tier — no automatic daily backups.

**Manual backup procedure:**
1. Supabase dashboard → select project → **Database → Backups** → trigger manual snapshot before destructive operations.
2. Alternatively: `pg_dump "$(supabase db url)" > backup-$(date +%Y%m%d).sql`
3. Restore: `psql "$(supabase db url)" < backup-YYYYMMDD.sql`
4. After restore: re-run `supabase db push` to ensure migrations are current.

**Fire-drill record:** 2026-08-26 — procedure reviewed; live restore NOT performed (no production data; staging only). Accepted as adequate for MVP pre-production phase. See **RISK-0012**.

---

## Remediation Summary

| Item | Action | Status |
|---|---|---|
| `.env.example` missing | Created `Code/mine-flow-app/.env.example` | Done (STEP-44.5) |
| Privacy notice absent | RISK-0011 added as pre-release gate | Tracked |
| Backup not verified | RISK-0012 added (revisit: before prod data) | Tracked |
| Operations / access review cluster | RISK-0013 added (umbrella) | Tracked |
| RLS gaps | None found | Done |
| Account lifecycle | Correctly implemented | Done |
