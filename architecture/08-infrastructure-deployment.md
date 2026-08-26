# Doc 08 — Infrastructure & Deployment

**Version:** v0.2.0
**Status:** Active
**Last updated:** 2026-08-09 (STEP-42.7)
**Audience:** Developers, Operations, Project Managers

> Defines where the system runs, how code is deployed, and how it recovers from failure.

## 1. Hosting & Compute

- **Client (Flutter Web):** Hosted statically on **GitHub Pages**. All application compute happens in the user's browser.
- **Client (Android APK):** Executed locally on the user's mobile device.
- **Backend & Database:** Hosted on **Supabase Cloud** (managed PostgreSQL). Includes **Supabase Edge Functions** for privileged operations (e.g., Supervisor user creation).
- **Geospatial Files:** Stored on **Google Drive** using standard Google APIs.

## 2. Build & Deploy Pipeline

Code becomes a running version via automated **GitHub Actions** (`.github/workflows/ci.yml`; implemented in STEP-42):

- **Test gate (`test`):** On every push/PR — formatting, analyze, contract & l10n guards, full test suite.
- **Android APK (`build-android`):** Builds the debug APK as a smoke check; uploaded as a CI artifact.
- **Staging web (`deploy-staging`):** On push to `master`: `test` → `build-android` → `deploy-staging` builds Flutter Web with staging secrets and deploys to `gh-pages-staging` (staging Pages slot under `/staging/`); a debug APK artifact is re-published as `staging-apk-<sha>` with 14-day retention.
- **Production (`deploy-production`):** On GitHub Release publish: deploys Flutter Web release build to `gh-pages` and attaches the signed APK to the Release. Runs in the `production` Actions environment and **requires reviewer approval** before deploying.
- **Rollback:** Web: re-run the last passing workflow run (staging) or re-publish the previous Release tag (production, triggers redeploy); APK: download/re-publish artifacts. See Doc 09 §5 and `runbooks/staging-provision.md`.

## 3. Infrastructure as Code

Due to the extremely small infrastructure footprint, we will adopt a "ClickOps + Database as Code" approach:
- **Projects & Hosting:** The Supabase project, GitHub repository settings, and Google Drive folder will be created manually through their respective web dashboards.
- **Database:** All database schemas, tables, and Row Level Security (RLS) rules will be managed strictly as code using **Supabase Migrations**.

## 4. Networking, TLS, and Secrets

- **Networking & TLS:** Fully managed. Both GitHub Pages (using the default `*.github.io` domain) and Supabase provide automatic, free TLS (HTTPS) certificates. 
- **Surfaces:** The web dashboard and database API are accessible over the public internet, but strictly secured via Supabase Auth and RLS.
- **Secrets:** Configuration values (like Supabase URL/Anon Key and Google APIs) will be stored securely in **GitHub Repository Secrets** and injected into the build pipeline by GitHub Actions. They are never committed to the repository.

## 5. Failure Modes & Resilience

The offline-first architecture provides natural resilience against failure:
- **Supabase Outage:** The web dashboard goes down, but field crews can continue logging data completely offline on their Android devices and sync later.
- **Google Drive Outage:** The app degrades gracefully, temporarily disabling geospatial features and showing a "try again later" message without crashing the core app.
- **Availability Target:** We accept standard cloud uptime (~99.9%) and single-region deployment, as brief central dashboard outages are tolerable given the field's offline capabilities.

## 6. Backups & Disaster Recovery

We leverage the offline caches on mobile devices as a secondary safety net alongside managed backups:
- **Backups:** Supabase automatically takes daily database snapshots.
- **RPO (Recovery Point Objective):** ~1 day for the central database, but effectively much lower as mobile devices can re-sync their recent local data once the database is restored.
- **RTO (Recovery Time Objective):** A few hours (to trigger a restore or stand up a new Supabase project).
- **Rehearsal:** We will conduct one "fire drill" test restore to an empty Supabase project prior to MVP launch to verify the recovery process.

## 7. Cost & Cloud Coupling

- **Cost:** Extremely low. The MVP will run on the free tiers of GitHub Pages and Supabase, with potential scaling to a ~$25/month Supabase Pro plan if database limits are exceeded.
- **Cloud Coupling:** High. We accept strict vendor lock-in to Supabase (Auth, DB, RLS, SDK) in exchange for the massive development speed boost required for a 1-month solo-developer MVP.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Hosting | GitHub Pages (Web) + Supabase (Backend) | Eliminates all custom server maintenance for a solo developer. | Custom container orchestration or self-hosted VMs. |
| 2 | CI/CD | GitHub Actions | Natural fit for a GitHub repository; automates deployments and APK builds for free. | Manual, error-prone local builds for production. |
| 3 | Infrastructure setup | Manual ClickOps + Supabase Migrations | Terraform is overkill for 3 managed services, but DB schema must be reproducible. | Fully automated, single-command environment cloning. |
| 4 | Domain & TLS | Default GitHub Pages domain | Sufficient for an internal MVP and provides zero-config TLS. | Custom branded domain (can be added later). |
| 5 | Secrets | GitHub Repository Secrets | Keeps credentials out of code while seamlessly injecting them into the CI build. | Hardcoding secrets. |
| 6 | Availability Target | Single-region Supabase | Offline-first mobile app makes central database downtime tolerable. | Expensive multi-region replication. |
| 7 | Disaster Recovery | Daily Supabase snapshots + 1 Fire Drill | Balances managed convenience with the reality that untested backups are dangerous. | Real-time continuous replication to a cold standby. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
|    |          |       |            |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.8 | Initial draft from Infrastructure & Deployment session |
| v0.1.1 | 2026-07-18 | STEP-1.14 | Included Supabase Edge Functions for privileged operations |
| v0.2.0 | 2026-08-09 | STEP-42.7 | Status Active; §2 pipeline concrete: four-job CI (`test`, `build-android`, `deploy-staging` on `master` push, `deploy-production` on Release with manual approval gate); rollback pointers |
