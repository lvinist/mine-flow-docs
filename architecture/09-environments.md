# Doc 09 — Environments

**Version:** v0.1.0
**Status:** Draft
**Last updated:** 2026-07-18 (STEP-1.9)
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

## 4. Promotion Flow

Code promotion follows a simple, automated path managed by GitHub Actions:

1. **Local to Staging:** Merging or pushing code to the `main` branch automatically triggers a build and deployment to the Staging environment.
2. **Staging to Production:** Creating a "Release" (tagging a version) in GitHub manually triggers a deployment of that exact codebase to the Production environment. This provides a deliberate checkpoint before updating the live app.

## 5. Access Control

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
