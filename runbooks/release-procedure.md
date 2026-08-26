# Runbook — Release Procedure (Staging → Production)

> Checklist for promoting a build from staging to production. Produces a GitHub Release which
> triggers `deploy-production` (web to `gh-pages`, release APK attached), gated by the
> `production` environment's required reviewer.
>
> The generic discipline lives in `runbooks/release-deploy.md`; this file is the concrete
> mine-flow procedure. Context: `architecture/09-environments.md` §4.

## Promotion checklist

Work top to bottom; do not skip ahead — every line is a gate for the next.

1. [ ] **Confirm staging web loads** and login succeeds with
       `supervisor@mineflow.dev` against the staging Pages URL.
2. [ ] **Install the staging APK** from the latest `staging-apk-<sha>` CI artifact
       (14-day retention) on a test device or emulator; smoke-test:
       login → attendance entry → data sync attempt.
3. [ ] **Run the full suite on `master`:**

       ```bash
       flutter test    # must be 434+ tests, 0 failures
       ```
4. [ ] **Static analysis on `master`:**

       ```bash
       flutter analyze # must be 0 issues
       ```
5. [ ] **Create the GitHub Release.** Tag format `v<MAJOR>.<MINOR>.<PATCH>` (semver),
       target `master`, mark as **Latest release** (not pre-release). Write brief
       release notes (highlights + known issues). Publishing the release is what
       triggers `deploy-production`.
6. [ ] **Approve the deploy gate.** In GitHub Actions, open the triggered
       `deploy-production` run → *Review deployments* → approve. The run stays
       waiting until you do — that is the deliberate checkpoint.
7. [ ] **Verify the production web URL loads** correctly post-deploy
       (correct data domain — production Supabase, not staging).
8. [ ] **Verify the release APK asset** is attached to the GitHub Release
       (`app-release.apk` uploaded by the workflow's final step).
9. [ ] **Rollback (only if production breaks):** go to GitHub Releases →
       re-publish the previous release tag. This retriggers `deploy-production`
       with the previous build — approve the gate again. See also the rollback
       table in `runbooks/staging-provision.md`.

## Notes

- Production deploys **only** via released tags — there is no continuous deployment to
  production; the release + approval pair is the human checkpoint (Doc 09 §4).
- Rolling back by re-publishing an old tag redeploys old application code but does **not**
  roll back any database schema — migrations applied since remain in place. Check whether
  the intervening releases touched `supabase/migrations/` before treating a rollback as
  complete; if they did, roll forward with a fix instead where possible.
- After any production rollback, follow `runbooks/incident-postmortem.md`.
