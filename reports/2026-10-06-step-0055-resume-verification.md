# STEP-55 — continuation verification, 2026-10-06

**Status: In progress; not a release or close approval.**

Resumed sessions `20261004_184933_3be359` and `20261004_235647_c3c7f9`.
Initial application head: `1941c0ea4330fa938cb3ef4cd5248878ca67f99e`, three commits ahead of the fetched STEP branch. Docs head `092b222`; prompts head `d106c9e` with a pre-existing two-hunk index edit. Historical findings and accepted ADRs are not rewritten by this report.

## Owner boundaries recovered from disk

`Upcoming Prompts/step55-remediation/owner-decisions.md` records:

- Both privacy notice translations were approved by the accountable product owner. This is not independent legal validation or proof of retention/deletion implementation.
- The named Supabase project is test-only; normal E2E synthetic fixtures are authorized. Schema deployment, zone seeding and live security attacks require separate approval.
- The approved non-supervisor self-edit fields are name, phone and the two emergency-contact fields; existing supervisor administration rights are retained.
- Keep STEP-55 In progress until all required gates pass. No conditional Done, archive, merge, branch deletion or release approval is inferred.

## Inherited commits and new verification

| Commit / area | Verified result | Remaining limitation |
|---|---|---|
| `d6160f2` capture viewport and daily-log close assertion | Source retains engine metrics, uses binding surface size plus matching MediaQuery; fresh capture-viewport/widget tests pass | Previous matrix execution is historical evidence, not a new exact-head device/CI run |
| `8fc6447` inventory cold edit and mobile history | Durable item ID is passed to form initialization; missing/foreign/deleted records are rejected; all three history states use mobile full-page mode; focused widget tests pass | Timestamp disposition in the commit message is incorrect; see below |
| `1941c0e` self-profile field guard | Fresh disposable PostgreSQL cluster: original exploit test fails with the expected self-promotion regression before migration; passes after migration; 20 protected-field writes rejected; allowed fields and supervisor/service-role administration preserved; fixture rollback verified | No live attack/write test performed; risk remains open pending recorded close authority and complete acceptance |

Fresh commands on 2026-10-06:

- `flutter test --no-pub test/tool/capture_viewport_test.dart test/features/tracking/presentation/inventory_item_entry_screen_test.dart test/features/tracking/presentation/inventory_history_screen_test.dart`: **5 passed**.
- `flutter test --no-pub test/features/tracking/ test/app/router_test.dart test/features/reporting/presentation/widgets/app_contextual_report_dialog_test.dart`: **185 passed**, exit 0. This includes the existing report-dialog matrix; it is not a full-suite result.
- Security runner applies the repository migrations to an isolated PostgreSQL 17 cluster with explicit fixture grants and minimal local Auth accessors. Regression before the security migration: exit 3 and `REGRESSION: crew can self-promote to supervisor`. After the migration: exit 0, approved and forbidden paths checked. Synthetic user count after rollback: 0. Cluster stopped.
- Initial contract guard: local invocation exit 0; `CI=true dart run tool/check_supabase_contracts.dart` exit 1, rejecting the trigger-only migration because `database.ts` did not change. Fix is in progress separately; a local pass is not a CI pass.

Raw local evidence is retained in `Upcoming Prompts/step55-remediation/resume-20261006/`. Security evidence is local-only; it does not claim an authenticated remote authorization test.

## Read-only remote verification

On 2026-10-06 the migration registry includes both `20260913000001` (inventory transactions) and `20261004000001` (profile permissions). The profile trigger `guard_users_self_update` exists, is enabled (`O`), runs BEFORE UPDATE, and calls the expected SECURITY INVOKER function with empty search_path and the four-field allow-list. No database state was changed in this continuation.

Therefore earlier statements that the inventory migration is unapplied, type generation is blocked on that deployment, or the profile trigger is merely local are stale. Deployment presence is not proof of all remote behavior; no live attack is inferred from this read-only check.

## Inventory timestamp correction and escalation

The `8fc6447` message says client `createdAt` is local-only and the remote item upsert uses server timestamps. **That is false at this head.**

The actual path is:

1. `inventory_bloc.dart` initializes a new draft with `createdAt: DateTime.now()`.
2. `tracking_repository_impl.dart:287–300` serializes that entity into the sync payload.
3. `inventory_item_model.dart:64` includes non-null `created_at`.
4. `tracking_sync_registrar.dart:98–108,143–150` retains it while re-anchoring only `updated_at`.
5. `tracking_remote_datasource.dart:121–128` upserts the complete serialized item.

The live `inventory_items.created_at` default is `now()`, but an explicit client value overrides it. This must not be described as server-authored.

Separately, the live `adjust_inventory` function inserts `p_created_at` into `inventory_transactions.created_at`; the client passes the queue timestamp. The ledger also uses client event time, not server audit time. Doc 04 already records that caveat; the residual prompt's server-timestamp assertion is stale. The approved master specification requires a server timestamp (`FC-54.8-005`). Item timestamps and ledger audit timestamps are different contracts and must not be conflated.

Owner decisions obtained in this continuation: inventory-item creation time intentionally remains client-authored, with the contract documented honestly. For the adjustment ledger, retain client event time separately and make new `created_at` values server-authored; preserve existing `created_at` values and explicitly label them as legacy client timestamps. Prepare and test that migration locally first; deployment still needs separate approval. Implementation is pending. Remote transactional/rollback/replay/authorization/concurrency proof remains Unverified, not "credentials absent" by assumption.

## Capture integrity versus coverage

Re-read both successful historical run summaries and PNG bytes from `matrix-web-aligned-3` / `matrix-android-aligned-3`:

| Platform | Expected / present | Physical PNG dimensions | Distinct byte hashes |
|---|---:|---|---:|
| Web | 73 / 73 | 1578 × 870 | 38 |
| Android | 25 / 25 | 1080 × 2400 | 14 |

Every file is larger than the rejected placeholder size. Summary filenames match the directories and both historical logs end with `All tests passed`. The existing source derives 73 Web cells and 25 Android cells; the old prompt's 25-Web expectation is stale.

These are **capture-throughput results**, not complete visual/a11y acceptance. Logical test sizes are 400×800, 700×1000 and 1200×900 on Web; Android exercises 400×800. Logical layout and physical screenshot dimensions are intentionally different.

Some different locale labels have identical PNG bytes, and `/teams` can preserve the same shell-branch screen as `/teams/daily-log`. The capture harness does not assert each resulting route/screen identity. Identical bytes alone do not establish whether the cause is hardcoded copy, retained shell state or a capture error. Do not count filenames as independently reviewed states.

The six named screens are dashboard, daily-log, daily-log-form, operations, teams and tools. This does not establish direct Cut & Fill form/report, Land Clearing tab/selector, or Attendance roster coverage. Consequently `FC-54.2-007`, `FC-54.3-007` and `FC-54.5-004/013` remain **Unverified**, including measured contrast, targets, keyboard/focus, IME, restoration and screen-reader behavior. No visual pass is claimed from source or file counts. Captures remain preserved locally pending content/PII review and a correctly labelled evidence matrix; historical artifacts are not deleted.

## Guard implementation update — 2026-10-06

The delegated implementation was interrupted by provider rate limiting. The parent re-read and completed the dirty files; no child success claim was accepted.

- **24 guard tests pass**, including exact receipt bindings, malformed/partial receipts, separate staged/worktree validation, full push ranges, merge-base PR comparison, shallow push/PR checkouts, new-branch pushes and retained stale-artifact checks.
- Parent-observed RED→GREEN corrections: staged stub hidden by a valid working copy; missing full push history in a depth-2 checkout; missing target branch in shallow PR checkout; zero-before new-branch event handling.
- Analyzer for the two changed Dart files: **0 issues**. Staged diff whitespace check passes; both files preserve LF-at-HEAD conventions. Added-line security pattern scan: zero flagged patterns.
- Real `supabase gen types --lang typescript --linked` using CLI 2.113.0 returned exit 0 and **26,890 bytes**, exactly equal to the committed artifact. SHA-256: `58396b65c554d166900745f76b324e0c403cf2bd90443dc7dfdc275cd4575d24`.
- `supabase/types/no_shape_change.json` is a reviewed attestation bound to the exact trigger migration and unchanged artifact Git blobs, not a SQL-parser shortcut or fabricated type diff. The guard rejects unknown/missing Git history rather than returning a vacuous pass; it fetches required history using the existing CI workflow without workflow edits.
- Four files are staged for this lane: README, guard, isolated tests, receipt. Independent review and full local gates are pending; no commit/push or ledger migration is claimed yet.

## Timestamp preparation update — 2026-10-06

The owner-approved ledger change is now locally implemented in migration `20261006000001_step_55_inventory_audit_timestamps.sql`, DTO/entity mapping and localized history labels. **It has not been deployed or committed.**

- Existing ledger `created_at` is preserved and copied to `occurred_at`, with `created_at_source=legacy_client`. New inserts use a database trigger to set server `created_at` and provenance `server`; caller-provided audit values cannot override it.
- The existing RPC signature is unchanged, so queued clients continue passing their event time as `p_created_at`; the RPC stores that value in `occurred_at`. Inventory-item creation time and the existing item updated_at/LWW behavior are unchanged.
- Fresh local PostgreSQL RED: the original RPC accepted client time as ledger audit time, triggering the explicit regression assertion. GREEN after migration: correct new audit time, preserved legacy values/source, separate event time, unchanged replay timestamps/stock/count, rollback on missing event time, preserved item creation time, and spoof-resistant direct INSERT. All test writes and the migration were rolled back in this regression run; the cluster was stopped.
- Model RED→GREEN proves DTO/domain round-trip preservation and rejects unknown provenance or a server-labelled row missing event time. Unmigrated responses are conservatively labelled legacy, never server-authored.
- UI RED→GREEN: event/server/legacy labels render on 400dp and 1200dp layouts, in Indonesian and English. New text uses parameterized ARB keys and regenerated localization classes. These widget tests are not a native-device or screen-reader pass.
- Fresh tracking + router suite: **185 passed**. Analyzer of the five modified/new timestamp Dart files: **0 issues**. Owned diff whitespace check passes. Impeccable scoped clarify guidance used; launcher reports the known out-of-repo context limitation; detector returns `[]`, which is not CanvasKit visual evidence.
- The preceding full suite, before this timestamp implementation and the reviewer follow-up, passed **863 tests with 5 skips**, analyzer 0, formatting 340 files unchanged, and l10n guard green. That is a baseline, not the final combined-head gate.
- Supabase CLI local generation failed because Docker/Podman is absent. The official `@supabase/postgres-meta@0.100.0` generator was then installed **only in scratch**, and successfully generated before/after public-schema types from separate real local PostgreSQL databases. The generator's schema delta contains the two added columns in Row/Insert/Update. The output is retained as `step55-local-types-before.ts` and `step55-local-types-after.ts` in the local evidence folder. The full output also differs from the linked artifact due to generator version and local extensions; it is not silently substituted for the linked `database.ts`. No hand-written types or invented generator output are used. Regeneration from the deployed target remains part of the separately authorized deployment gate.

## Guard reviewer follow-up — 2026-10-06

The reviewer found an artifact-only staging gap: `_checkBatch` returned before checking snapshot validity when no migrations changed. The separate fix agent failed on provider rate limiting before making changes, so the parent repaired the exact finding directly. New staged-deletion and staged-stub cases both failed as expected before the fix and pass afterward. Snapshot validation now precedes the no-migration return.

**26 guard tests pass; analyzer 0; format unchanged.** A disposable clone of the four staged guard files (excluding the pending timestamp lane) ran the guard against the real push-base `03180ec`: exit 0, exact reviewed trigger receipt accepted. This is local candidate evidence, not a GitHub CI run. Final independent re-review is pending; no repository commit/push is claimed.

## RESIDUAL-3 adjudication — 2026-10-07

RESIDUAL-3's harness defect (2/25 capture stalls) is **resolved** by two causes acting at
different times. The product-side cause was the capture viewport not being aligned to the
breakpoints, fixed in `d6160f2` (which also added the hard daily-log close gate and
`capture_viewport.dart` with its own unit test) — that commit is an ancestor of this head.
The remaining blocker at this head was **environmental**: the local driver used chromedriver
152 against Chrome 155 (`SessionNotCreated` / session timeouts). With a version-matched
chromedriver 155.0.8059.39 on port 4444, a web capture run at head `1486826` produced
**73/73 valid PNGs** (drive exit 0), zero placeholder-sized files. Captures are archived at
`reports/design-review/step-0055/web/` with the dated index
`2026-10-07-web-matrix-index.md` (per-cell names, sizes, SHA prefixes, locale-byte analysis).
The earlier 2/25 stall is not reproduced at this head.

The RESIDUAL-3 verdicts below are recorded per the prompt's adjudication contract: anything
not provable from captures stays **Unverified** with the blocker named.

### Per-FC verdicts

| FC | Scope | Verdict | Basis and blocker |
|---|---|---|---|
| `FC-54.2-007` | Cut & Fill runtime audit (contrast, 48dp targets, keyboard/focus, validation, both themes/platforms) | **Unverified** | The matrix visits six shell routes only — `/`, `/teams/daily-log`, `/teams/daily-log/form`, `/operations`, `/teams`, `/tools`. **No `/operations/cut-fill` or `/operations/cut-fill/form` route is in the matrix**, so no Cut & Fill rendering exists in this run at all. Even with routes added, captures cannot measure contrast or hit targets; those need an accessibility-traversal probe or a contrast check on the tokens themselves. |
| `FC-54.3-007` | Land Clearing runtime audit (tab semantics, summary hierarchy, dark/light contrast, 48dp targets, selector occlusion, sheet behavior, focus) | **Unverified** | Same route gap: `/operations/land-clearing` and its `form` / `:id` / `:id/form` children are **absent from the matrix**. The combination-box occlusion and sheet-behavior checks are interactive and cannot be inferred from a static frame. |
| `FC-54.5-004` | Attendance regression audit (unset roster rows, bulk-action exceptions, persisted status mappings, reason validation, dirty dismissal, sync announcements, calendar dialog, 2.0x text) | **Unverified** | `/teams/attendance` and `/teams/attendance/form` are **absent from the matrix**. Nearly all of this FC is behavioral (bulk-action exception handling, sync announcements), not visual — a capture could not close it even with the route present. |
| `FC-54.5-013` | Attendance restoration/targets/screen reader (both platforms, sync-status announcement) | **Unverified** | Route absent as above, plus two further blockers: screen-reader semantics are not obtainable from a PNG, and restoration is a cold-start behavior by definition. |

All four FCs were **already Unverified** at 2026-10-06 and remain Unverified. The capture
fix does not advance any of them. This is recorded explicitly because 73/73 green captures
could otherwise be mistaken for a runtime-audit pass; it is a **harness** pass only.

### What the matrix does establish

That the six shell screens render at phone/tablet/desktop, light/dark, id/en without
crashing, that the responsive breakpoints fire at the intended widths (the test asserts
`MediaQuery` size matches each breakpoint before capturing), and that the four
locale-independent screens (`dashboard`, `teams`, `operations`, `tools`) contain no
localized string lookups — confirmed by `grep` — so their byte-identical id/en captures are
expected rather than a missed translation. This is evidence the UI shell is cohesive, not
that any feature's accessibility contract holds.

### Required follow-up to close these FCs

1. Extend the capture matrix (or a new accessibility journey) to include the feature routes:
   `/operations/cut-fill`, `/operations/land-clearing`, `/teams/attendance`, each with form
   and detail variants.
2. For contrast and 48dp targets, run a programmatic check — semantics traversal with
   `find.bySemanticsLabel` / `Semantics` tree assertions, or compute contrast from the design
   tokens in `lib/core/theme` — rather than eyeballing captures.
3. For `FC-54.5-004`'s behavioral items (bulk exceptions, sync announcements, restoration),
   these need the existing integration journeys, not the capture harness.

These remain owner-gated lanes, not work assumed by this session.

## Next gates — updated 2026-10-07

1. ~~Finish and independently verify the migration/typegen guard fix~~ — DONE: guard `a84281b`
   + timestamp lane `1486826` pushed; CI run `37535200023` all-green including Android.
2. ~~Run full static/unit gates, publish reviewed lane commits, verify CI at the exact head~~ — DONE.
3. ~~Resolve inventory timestamp semantics~~ — DONE (migration `20261006000001` deployed and
   live-verified).
4. Complete real feature-level visual/a11y evidence — PARTIALLY DONE: shell-level matrix
   complete and archived; **feature-level coverage for Cut & Fill, Land Clearing, and
   Attendance is still missing** and blocks `FC-54.2-007`, `FC-54.3-007`, `FC-54.5-004/013`.
5. Close-path bookkeeping: commit the prompts STEP-index diff (verify against disk first),
   correct the stale 55.1 row, and dispose of the stray pre-matrix artifact
   `reports/design-review/step-0055/2026-09-14-web-login-1258x566.png` per the RESIDUAL-3
   disposition instruction (dated addendum, never silent deletion).
6. Reconcile risk/status records, deferred zone seed (RISK-0030) and remote contract evidence
   (`55.8` items (a)–(e) remain Unverified). Keep STEP-55 **In progress**.
