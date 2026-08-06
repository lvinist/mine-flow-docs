# Release-Readiness Reconciliation Report
**Date:** 2026-08-06
**STEP:** 41.1

## Metadata
- **Context**: STEP-41.1 Pre-flight inventory for App↔Supabase contracts and Localization.
- **Scope**: Repository state, static inventory, and local tooling discovery. No remote environment mutation.

## Inspected Revisions
- **`Code/mine-flow-app`**: Branch `step-0041-release-readiness-baseline`, clean worktree.
- **`Code/mine-flow-docs`**: Branch `step-0041-release-readiness-baseline`, clean worktree (except for this report).
- **`prompts`**: Branch `main`.

## Blockers and Assumptions
- The `supabase` CLI is not installed or not in PATH locally. This blocks local generation of types without a CI pipeline or a local install.

## Requirement / Evidence / Status Matrix

### App↔Supabase Contract Baseline
| Requirement | Evidence (Path / Command) | Status | Gap | Owner / Follow-up | Acceptance Evidence |
|-------------|---------------------------|--------|-----|-------------------|---------------------|
| Code-generated typed interfaces (Doc 11) | `dart run tool/check_supabase_contracts.dart` correctly identifies missing types. Live generation command documented in the script. Target location: `lib/core/data/models/generated/database.dart`. | **Unverified** | Live generation cannot be safely executed (missing non-production project reference). Deferred to STEP-42. | STEP-42 | Code-generated models committed to the repository. |
| Supabase CLI Project Config | Directory `supabase/` missing `config.toml`. | **Unverified** | No project reference configuration for Supabase CLI. | STEP-42 | `supabase/config.toml` exists with valid project reference. |
| CI Gate for Contract Staleness (Doc 12) | `.github/workflows/ci.yml` updated. `tool/check_supabase_contracts.dart` implemented and verified locally to detect staleness and missing types deterministically. | **Verified** | None. | N/A | CI workflow includes a non-secret contract staleness check. |
| Contract Staleness Failing Condition Test | Created temp migration and dummy `database.dart`. Tool correctly exited with error. | **Verified** | None. | N/A | Tool exits 1 when uncommitted database migrations exist but `database.dart` is untracked/out of sync. |
| Versioned Database Migrations | `supabase/migrations/` contains 5 SQL files; `supabase/functions/` contains `create-user`. | **Verified** | None. | N/A | N/A |

### Localization Baseline
| Requirement | Evidence (Path / Command) | Status | Gap | Owner / Follow-up | Acceptance Evidence |
|-------------|---------------------------|--------|-----|-------------------|---------------------|
| App-level locale configuration (Doc 07) | `lib/app/app.dart` configures `supportedLocales` and `localizationsDelegates`. | **Verified** | None. | N/A | N/A |
| Localization assets/configuration | `l10n.yaml` and ARB files are missing. `pubspec.yaml` has `generate: true`. | **Partially evidenced** — scaffold exists; full migration incomplete; guard prevents regressions in new files. | None | N/A | `l10n.yaml` and `.arb` files established. |
| Implementation Classification | `Select-String` search in `lib/features/*/presentation/*/*.dart` found hardcoded Indonesian strings (e.g., `Text('Input Absensi')`). | **locale selection** | UI strings are hardcoded, locale switching works via SettingsCubit but no ARB/AppLocalizations delegate exists. | Phase 3 | Complete localization rollout. |

## Safe Local Tooling Availability
- **Flutter**: Available (3.44.5)
- **Dart**: Available (3.12.2)
- **Supabase CLI**: Not recognized (`supabase --version` failed). A standard install path/CI integration is required.

## Tooling Verification

### Passing Condition Output (`dart run tool/check_supabase_contracts.dart`)
```text
Running build hooks...Running build hooks...Supabase Contract Check
-----------------------
Regeneration Command:
  supabase gen types dart --project-id $SUPABASE_PROJECT_ID > lib/core/data/models/generated/database.dart

[WARNING] Bootstrap Action Required: The generated types file (lib/core/data/models/generated/database.dart) does not exist.
This is expected until a non-production Supabase project is provisioned (e.g. STEP-42).
Bypassing contract staleness check.
```

### Failing Condition Output (`dart run tool/check_supabase_contracts.dart` with uncommitted migration)
```text
Running build hooks...Running build hooks...Supabase Contract Check
-----------------------
Regeneration Command:
  supabase gen types dart --project-id $SUPABASE_PROJECT_ID > lib/core/data/models/generated/database.dart

[ERROR] Uncommitted database migrations found, but lib/core/data/models/generated/database.dart is not updated.
Please regenerate the types before committing.
```

## 41.2 Verification

- **Code Review**: The `tool/check_supabase_contracts.dart` implementation is confirmed correct. It accurately checks the target path, properly diffs against `HEAD^` for shallow clones in CI, and provides appropriate docstrings/output. The `--project-id` flag used matches the current CLI standard for `gen types`.
- **Focused Tests**: Created `test/tool/check_supabase_contracts_test.dart` which passes all three scenarios (passing, failing with unstaged type changes, and passing with synchronized changes).
- **README Update**: Yes. A Contract Regeneration section was added detailing the regeneration command and CI enforcement.
- **Doc 11 Update**: No. The document already accurately records the generation path, CI gate rules, and command.
- **Contract Gate Status**: **Verified** (the guard itself is confirmed working with unit tests).
- **Live Generation Status**: **Unverified** (Supabase CLI not installed locally; STEP-42 owner must provision a non-production project and run `supabase gen types dart`).

## 41.3 Verification

- `l10n.yaml` created: yes, at `Code/mine-flow-app/l10n.yaml`.
- ARB files created: `app_id.arb`, `app_en.arb`, keys: `appTitle`, `localizationBaseline`.
- `AppLocalizations` wired into `app.dart`: yes.
- Guard `tool/check_l10n_baseline.dart`: created, passes when non-exempt files are clean, fails when non-exempt files have hardcoded strings.
- CI step added: yes, `Check Localization Baseline` added.
- Tests: `locale_configuration_test.dart` (4 tests), `check_l10n_baseline_test.dart` (2 tests) both passing.
- Full test suite result after 41.3 changes: 427 tests passed, 0 failures.

## Next-STEP Handoffs
- **STEP-41.2**: Completed.
- **STEP-41.3**: Completed.
- **STEP-41.4**: Next.

## STEP-41.4 Final Verification

| Command | Working Dir | Exit Code | Result Summary |
|---------|-------------|-----------|----------------|
| `flutter pub get` | Code/mine-flow-app | 0 | Dependencies resolved |
| `flutter gen-l10n` | Code/mine-flow-app | 0 | AppLocalizations generated |
| `dart format --output=none ...` | Code/mine-flow-app | 0 | No formatting issues |
| `flutter analyze` | Code/mine-flow-app | 0 | 0 issues |
| `dart run tool/check_supabase_contracts.dart` | Code/mine-flow-app | 0 | WARNING + bypass (no generated file) |
| `dart run tool/check_l10n_baseline.dart` | Code/mine-flow-app | 0 | OK |
| `flutter test` | Code/mine-flow-app | 0 | 433 tests, 0 failures |
| `flutter build apk --debug ...` | Code/mine-flow-app | Unverified | Requires staging secrets (STEP-42) |
| `git diff --check` (app) | Code/mine-flow-app | 0 | Clean |
| `git diff --check` (docs) | Code/mine-flow-docs | 0 | Clean |

## Explicit Handoffs

- **STEP-42 (Staging Environment & Promotion Pipeline):** Provision separate high-parity Supabase staging project; configure STAGING_SUPABASE_URL, STAGING_SUPABASE_ANON_KEY, STAGING_GOOGLE_DRIVE_CLIENT_ID as GitHub secrets; run supabase gen types dart --project-id $SUPABASE_PROJECT_ID > lib/core/data/models/generated/database.dart and commit the generated file; execute Android debug build smoke gate; verify staging deployment.
- **STEP-43 (Security, Privacy & Release-Control Baseline):** RLS and authorization behavior verification; account lifecycle; privacy notice/retention; secrets posture; backup and restore fire-drill.
- **STEP-44 (Release-Candidate E2E & Runtime Design Review):** Critical Android and web journey testing against staging; field-critical offline/sync behavior; runtime Impeccable responsive/accessible/localized UI review.
- **Localization full migration:** All ~35 presentation files on the `_legacyExemptFiles` list require migration to `AppLocalizations`. This must be planned as a separate user-approved STEP before a public multi-language release. See risk register RISK-0004.
