# Doc 09 — Environments

**Version:** v0.4.0
**Status:** Active
**Last updated:** 2026-08-29 (STEP-47.8)
**Audience:** Developers, Operations

> Defines the environments (Local, Staging, Production), how configuration differs, and how code is promoted between them.

## 1. Environments Overview

We will maintain three environments for the MVP, balancing development speed with a safe path to production:

| Environment | Purpose | Access | Data |
|-------------|---------|--------|------|
| **Local / Dev** | Writing and testing code on the developer's machine. | Developer only | Synthetic data via seed script |
| **Staging** | A high-parity "dress rehearsal" to test changes before they go live. | Developer only | Synthetic data via seed script |
| **Production**| The live application used by field crews. | Field crews (app), Developer (admin) | Real user data |

*Note: A Sandbox/Demo environment is explicitly excluded for the MVP to minimize infrastructure overhead.*

## 2. Configuration & Secrets

Secrets (e.g., Supabase API keys) will be managed differently across environments to prevent accidental leakage in the codebase:

- **Local:** Configuration and secrets are stored in a `.env` file on the developer's machine. This file is explicitly ignored by Git. A `.env.example` file is committed to the repository to document required keys without values.
- **Staging & Production:** Real API keys are stored securely in **GitHub Repository Secrets**. The GitHub Actions CI/CD pipeline injects these secrets during the build process, ensuring they never reside in the codebase or on the deployed servers.

## 3. Environment Parity

- **Production:** Supabase Cloud backend, GitHub Pages web app hosting, Android APK.
- **Staging (High Parity):** Exact same cloud services (Supabase Cloud, GitHub Pages) as Production, but operating on a separate database instance and URL. This ensures most production-specific bugs are caught in Staging.
- **Local (Medium Parity):** Runs directly on the developer's machine, likely connecting to a local instance of Supabase. Network configurations may differ slightly from the cloud.
  - **Host Toolchain Parity:** Local development must match CI to produce reproducible builds. Required parity includes: JDK 17 (Temurin), Flutter pinned to `3.47.1`, AGP 9.1.0, KGP 2.4.0, Gradle 9.3.1, and the `PUB_CACHE` must be located on the same drive as the Flutter SDK and project to satisfy AGP 9 path resolution.

## 4. Promotion Flow

Code promotion follows a simple, automated path managed by GitHub Actions (implemented in STEP-42; see `.github/workflows/ci.yml`):

1. **Local to Staging:** Pushing or merging code to the `master` branch automatically triggers the `deploy-staging` CI job, which builds Flutter Web with staging secrets and deploys it to the staging GitHub Pages slot (`gh-pages-staging`, served under `/staging/`). It also publishes a `staging-apk-<sha>` debug-APK artifact (14-day retention). Both require the dual-platform `e2e-web` and `e2e-android` CI gates to pass. (Note: Web E2E runs via `flutter drive` + chromedriver, not `flutter test -d chrome`). **Crucially, a green E2E gate currently proves only that the test harness executes** — the emulator boots, the APK installs, and the harness runs. The actual 14 staging journeys remain Deferred to STEP-48 and are skipped on CI due to missing credentials.
2. **Staging to Production:** Publishing a GitHub Release triggers the `deploy-production` CI job, which builds and deploys to the production Pages slot and attaches a signed release APK to the Release. The job runs in the `production` Actions environment with a **required reviewer approval gate** — the run blocks until explicitly approved.

Both jobs are defined as GitHub Actions **environments** rather than per-environment branches (ADR-0011).

## 5. Rollback Procedures

| Surface | Procedure |
|---------|-----------|
| Staging web | Re-run the last passing `deploy-staging` workflow run in GitHub Actions — it rebuilds that commit and republishes `gh-pages-staging`. |
| Android APK (staging) | Download the `staging-apk-<sha>` artifact from the last passing run (14-day retention). |
| Production | Re-publish the previous GitHub Release tag — this re-triggers `deploy-production` with the previous build; approve the required-reviewer gate. |

Full detail: `runbooks/staging-provision.md`; production promotion checklist: `runbooks/release-procedure.md`.

## 6. Access Control

As a solo-developer project, access control is strictly centralized:
- **Developer:** Retains full deployment rights, infrastructure configuration access, and database viewing rights across Local, Staging, and Production.
- **Field Crews:** Limited exclusively to the frontend interfaces (Web App and Android APK) of the Production environment.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Environments | Local, Staging, Production | Provides a safe testing ground (Staging) before Prod without excessive overhead. | Simplicity of pushing straight from Local to Prod. |
| 2 | Sandbox | Skip for MVP | Reduces infrastructure and management overhead. | A dedicated environment for external demos without risk of affecting Staging. |
| 3 | Config & Secrets | `.env` locally, GitHub Secrets deployed | Standard secure practice; prevents keys in codebase. | Hardcoding config for faster setup. |
| 4 | Test Data | Synthetic data (seed script) for Local/Staging | Easy to automate, zero risk of leaking PII/sensitive data. | Testing against real-world edge cases found only in Prod data. |
| 5 | Parity | High (Staging), Medium (Local) | Staging catches cloud-specific bugs before Production. | Maintaining perfect parity locally (e.g., Dockerizing everything exactly like Prod). |
| 6 | Promotion | `main` -> Staging, Release -> Prod | Automates Staging but requires deliberate human action for Production. | Fully continuous deployment (CD) straight to Prod. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
|    |          |       |            |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-18 | STEP-1.9 | Initial draft from Environments session |
| v0.2.0 | 2026-08-09 | STEP-42.7 | Status Active; §4 promotion flow concrete (`deploy-staging` on `master` push, `deploy-production` on Release with approval gate); added §5 Rollback Procedures; ADR-0011 |
| v0.3.0 | 2026-08-27 | STEP-45.15 | Updated promotion flow with dual-platform E2E gate evidence (ADR-0017) |
| v0.4.0 | 2026-08-29 | STEP-47.8 | §3 parity details added (JDK 17, Flutter 3.47.1, AGP 9.1.0, PUB_CACHE); §4 promotion flow clarified (`flutter drive` E2E, journeys deferred) |
