# mine-flow — Release Notes: v1.3.0 (Phase 3 Completion)

**Release date:** 2026-10-10
**Audience:** Internal operators, field crews, and dashboard users
**Scope:** Phase 3 — Release Readiness, Integration & Scale (STEP-41 through STEP-55)

> Phase 3 completes mine-flow's release-readiness baseline: a dedicated staging environment
> with a promotion pipeline, security/privacy and release-control guardrails, dual-platform
> (web + Android) end-to-end testing, a cohesive multi-platform UI rebuild with accessibility
> hardening, and repairs to offline sync and the data contract. This note records the
> completed engineering milestone; production deployment remains blocked pending the RISK-0025
> release conditions, and staging is the evidenced environment.

## Highlights

- **Staging environment and promotion pipeline:** A separate staging path with synthetic seed
  data, CI deployment, and explicit rollback/release procedures now backs every release check.
- **Cohesive UI rebuild:** Form sheets, report dialogs, filters, calendars, and navigation were
  rebuilt across web and Android as one coherent ForUI-based experience, with accessibility
  hardening (accessible names, 48dp touch targets, text-scaling overflow fixes).
- **Dual-platform E2E gate:** Both web and Android end-to-end journeys run in CI against
  staging, so release evidence covers both platforms instead of web alone.

## What's New

- Staging environment with a promotion pipeline, deployment, and rollback procedures.
- Security, privacy, and release-control baseline: row-level security behavior, account
  lifecycle, privacy notice, secrets posture, backups, and a restore fire-drill record,
  re-checked after later CI changes (allow-list self-update guard).
- Dual-platform (web + Android) end-to-end gate with runtime design-review evidence.
- Responsive form sheets, contextual report dialogs, popover-first filters, and dialog
  calendars replacing the previous inline selection and date-field patterns.
- Breadcrumbs and ForUI migration completion across the application.
- Accessibility hardening: accessible names on numeric and status inputs, 48dp touch targets,
  and text-scaling overflow fixes at 2.0x pump coverage.
- OS process-death restoration for attendance (landed 2026-10).
- Localization guard against new hardcoded strings in non-exempt files.

## Improvements

- Offline sync and data-contract repairs: server-authored timestamps, the hazard/approval
  daily-log contract, and benchmark projection rejection.
- Android build chain remediation (AGP 9 / local device builds), restoring local device builds
  and eliminating dependency overrides after a 9-major dependency sweep.
- Dependency maintenance: hive_ce / forui / Flutter regression follow-ups verified without
  functional changes.
- Release-candidate E2E and runtime design review resolved carried-forward findings into
  executable journey evidence.

## Fixes

- Fixed offline sync losing queued items when a zone was not already present.
- Fixed the benchmark projection fallback persisting sentinel 0.0, 0.0 coordinates.
- Fixed attendance records exposing no offline synchronization state.
- Fixed Android journey flake failures from lingering-barrier interactions after form saves.

## Breaking Changes / Action Required

- No end-user migration is required for this milestone.
- **Production deployment remains blocked** pending RISK-0025 release conditions: identify the
  production target, apply and verify the security guard there under an approved deployment
  procedure, and retain real authorization regression evidence. Staging is the evidenced
  environment; no production readiness is claimed by this note.

## Known Issues

- Real-device screen-reader and contrast evidence remains unverified (FC residuals
  FC-54.2-007, FC-54.3-007, FC-54.5-004, FC-54.5-013): widget-level coverage is green, but
  TalkBack/VoiceOver semantics, measured contrast inventories, hardware keyboard traversal,
  and combobox occlusion at runtime are still Unverified.
- Foreman on-the-fly zone creation fails on staging (RISK-0030): the daily-log Android journey
  stays red when creating a zone inline. Assigned to STEP-57.
- Privacy-copy placeholder pending legal/product approval (55.10).
- RISK-0025: Privilege escalation in the users self-update policy — guard is present and
  enabled on staging; production rollout and authorization evidence remain a release condition
  (production deployment stays blocked).
- Seeded-zone round-trip (STEP-56 lane) and production migration remain open per owner dispositions.

## Documentation

- This release note records the completed Phase 3 milestone.
- Phase README, STEP-index, close addendum, and CI run records are referenced below; user-facing
  doc reconciliation completed via STEP-56.2 and this review (STEP-61) tightened the record.

## References

- **Released version/tag:** v1.3.0 (GitHub release on mine-flow-app, tagged at `c4f4030`)
- **Released tag:** `v1.3.0` at `c4f40302153f992871965a7926eb321182ea0c4c` (annotated git tag, pushed)
- **Deployed to:** staging only
- **Phase README:** `prompts/003-release-readiness-integration-scale/README.md`
- **STEP-index:** `prompts/STEP-index.md` rows STEP-41..STEP-60
- **Close addendum:** `reports/2026-10-08-step-0055.11-close-addendum.md` and the follow-up
  correction `reports/2026-10-08-step-0055-follow-up-correction.md`
- **CI run:** [`37949922909`](https://github.com/lvinist/mine-flow-app/actions/runs/37949922909)
  at `db4466b`
- **Batch close CI runs:** STEP-57 [`38030561898`](https://github.com/lvinist/mine-flow-app/actions/runs/38030561898)
  at `63deed7`; STEP-59 [`38049230677`](https://github.com/lvinist/mine-flow-app/actions/runs/38049230677)
  at `4c74e87`; STEP-60 [`38058477936`](https://github.com/lvinist/mine-flow-app/actions/runs/38058477936)
  at `c4f4030`
- **Related STEPs:** STEP-41 through STEP-60
- **Architecture / ADRs:** `architecture/02-phasing-roadmap.md`; `architecture/07-ui-design-system.md`;
  ADR-0008 (Impeccable Bridge and UI Design Tokens); ADR-0019 (TS contract of record)
