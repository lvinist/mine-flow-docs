# Runbook — Staging Environment Provisioning

> Reproduces the mine-flow staging environment from scratch. Documents exactly what was done
> in STEP-42.1–42.3 (2026-08). If the staging Supabase project is ever deleted, this runbook
> is the recovery path (see RISK-0010).
>
> Provisioning model is **ClickOps + Database as Code** per `architecture/08-infrastructure-deployment.md`
> §3 — infrastructure is created manually in dashboards; the database schema lives strictly as
> code in migrations. This runbook records the manual steps.

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Supabase CLI | 2.x (verified with 2.113.0) | Linked/DB commands run from inside `Code/mine-flow-app/` |
| Flutter | 3.47.0 stable (CI pin; local 3.47.1 works) | Required for tests and builds |
| Git | any recent | Access to both repos (`mine-flow-app`, `mine-flow-docs`) |
| GitHub repo admin access | — | Needed for Secrets and Environments settings |
| Google Cloud Console access | — | Needed for the GCP service account |

- A Supabase account with the staging project already created (in STEP-42 the project existed;
  creation via dashboard is not covered here).
- You will need three identifiers handy:
  - **Project Reference ID**: Supabase Dashboard → *Project Settings* → *General* → *Reference ID*.
  - **Project URL** + **anon public key**: Supabase Dashboard → *Project Settings* → *API*.
  - **Staging Drive folder ID**: the trailing path segment of the folder URL
    (`https://drive.google.com/drive/folders/<FOLDER_ID>`).

## Step 1 — Install the Supabase CLI

Windows:

```powershell
scoop install supabase
# or download the official .msi:
# https://supabase.com/docs/guides/local-development/cli/getting-started
supabase --version
```

## Step 2 — Link to the staging project

Run from `Code/mine-flow-app/`:

```bash
supabase login                       # opens browser auth
supabase link --project-ref <STAGING_PROJECT_REF>
```

`link` generates/commits `supabase/config.toml`. That file contains only the project reference
ID — safe to commit. Never put secrets into it.

## Step 3 — Apply migrations

```bash
supabase db push
```

- Applies every SQL file in `supabase/migrations/` in filename order; each is tracked remotely,
  so re-running is **idempotent** — already-applied migrations are skipped.
- Verify afterwards: `supabase migration list --linked` must show every local migration applied
  (this was the STEP-42 audit evidence command).

## Step 4 — Seed data

```bash
supabase db seed --file supabase/seed.sql
```

Loads the synthetic dataset (all 8 feature tables; includes the STEP-33/36/38 additions: benchmark
records, BCM/LCM material-type rows, clearing methods, second attendance record). Confirm rows in
the Supabase dashboard after loading.

## Step 5 — Generate the API type contract

> **Changed since the original plan:** the Supabase CLI dropped Dart typegen entirely
> (`gen types dart` errors on every current release; restore PR supabase/cli#6230 remains an
> unmerged draft). The committed contract artifact is therefore **TypeScript**, validated by a
> guard instead of compiled Dart classes.

```bash
supabase gen types --lang typescript > supabase/types/database.ts
```

Commit `supabase/types/database.ts`. A pre-existing stub or drifted output is caught by the
contract guard (stub-rejection + staleness checks):

```bash
dart run tool/check_supabase_contracts.dart   # must exit 0
```

If that tooling changes again, update this step and `tool/check_supabase_contracts.dart`
together — they are one contract.

## Step 6 — GCP staging service account

All done in the Google Cloud Console (ClickOps):

1. Create (or pick) a GCP project dedicated to **staging**.
2. Enable the **Google Drive API** for that project (*APIs & Services* → *Library* → search
   "Google Drive API" → *Enable*).
3. Create the service account: *IAM & Admin* → *Service Accounts* → *Create Service Account*.
   Give it no project-level roles — Drive access comes solely from folder sharing in step 5.
4. Open the service account → *Keys* → *Add key* → *Create new key* → **JSON** → download.
   From the JSON extract `client_email` (the service-account email) and `private_key`.
   Treat this file as a secret: never commit it anywhere.
5. In Google Drive create the **staging folder**, share it with the service-account email as
   **Editor**, and copy its folder ID from the URL.

Staging uses a **fully separate service account** from production (credential isolation — see
ADR-0011). Do not reuse keys across environments.

## Step 7 — GitHub repository secrets

Repo → *Settings* → *Secrets and variables* → *Actions* → *New repository secret*. All five
staging secrets (names only here — values never enter the repo):

| Secret | Value source |
|--------|--------------|
| `STAGING_SUPABASE_URL` | Step 2 — Project Settings → API → Project URL |
| `STAGING_SUPABASE_ANON_KEY` | Step 2 — Project Settings → API → anon public key |
| `STAGING_GOOGLE_DRIVE_SERVICE_ACCOUNT_EMAIL` | Step 6.4 — `client_email` from JSON key |
| `STAGING_GOOGLE_DRIVE_SERVICE_ACCOUNT_KEY` | Step 6.4 — `private_key` from JSON key |
| `STAGING_GOOGLE_DRIVE_FOLDER_ID` | Step 6.5 — staging Drive folder ID |

The `deploy-staging` job consumes these as `--dart-define` build flags
(see `.github/workflows/ci.yml`). After setting them, confirm the CI `test` job runs green.

## Step 8 — GitHub Actions environments

Repo → *Settings* → *Environments*:

1. **Create environment `staging`.** No protection rules needed (deploys automatically).
2. **Create environment `production`.** Under *Deployment protection rules* enable
   **Required reviewers** and add yourself. Every `deploy-production` run then blocks until
   manually approved.

## Rollback procedures

| Surface | How |
|---------|-----|
| Staging web | GitHub → *Actions* → find the last passing `Deploy to Staging` run → *Re-run all jobs*. It rebuilds that commit and republishes `gh-pages-staging`. |
| Android APK (staging) | Download the `staging-apk-<sha>` artifact from the last passing run (14-day retention) and sideload it. |
| Production web + APK | GitHub → *Releases* → re-publish the previous release tag. This re-triggers `deploy-production`; approve the required-reviewer gate. |

## Related

- Promotion checklist: `runbooks/release-procedure.md`
- Decision record: `adr/ADR-0011-staging-promotion-pipeline.md`
- Risk register: RISK-0010 (ClickOps-only provisioning)
