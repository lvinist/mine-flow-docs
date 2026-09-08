# ADR-0019: Supabase Contract of Record — TypeScript Types over Removed Dart Typegen\r
\r
**Status:** Accepted\r
**Date:** 2026-09-08\r
\r
## Related documents\r
- architecture/11-interface-contracts.md\r
- ADR-0002 (Use Supabase for Backend)\r
- Code/mine-flow-app `tool/check_supabase_contracts.dart` (contract staleness guard)\r
\r
## Context\r
The Interface Contracts architecture doc (Doc 11) originally recorded the App↔Supabase\r
contract of record as "strongly-typed Dart models generated via `supabase gen types dart`",\r
committed under `lib/core/data/models/generated/`. STEP-41 added a CI guard to keep that\r
artifact fresh. In practice, the Supabase CLI removed Dart from its `gen types` ecosystem\r
(supabase/cli#6230; the official `supabase_typegen` package remains a placeholder), so the\r
documented generation path stopped existing. STEP-42.2 (commit ca72391) switched the project\r
to committing real `supabase gen types --lang typescript --linked` output at\r
`supabase/types/database.ts` and hardened the guard to reject stubs and stale artifacts.\r
The app's own Dart models remain hand-written mappers under `lib/features/*/data/models/`.\r
That implementation decision was never recorded as an ADR, and Doc 11 / the app README kept\r
describing the removed Dart-typegen path — found as drift at the STEP-50.1 check-in.\r
\r
## Decision\r
1. The App↔Supabase **contract of record** is the TypeScript schema dump at\r
   `Code/mine-flow-app/supabase/types/database.ts`, regenerated with\r
   `supabase gen types --lang typescript --linked` against the linked non-production project.\r
   - **Rationale.** It is the only typegen output the Supabase CLI still emits; committing it\r
     keeps a reviewable, diffable snapshot of the DB contract inside the app repo, and the\r
     hardened `tool/check_supabase_contracts.dart` guard enforces regeneration on migration\r
     changes (locally against uncommitted migrations, in CI against the base ref).\r
   - **Alternatives rejected.** (a) Dart typegen — no longer exists in the CLI.\r
   (b) `supabase_typegen` package — official but still a placeholder.\r
   (c) No committed artifact — loses the drift guard and the reviewable contract snapshot.\r
2. Dart-side models stay **hand-written mappers** (`toSupabase`/`fromSupabase`) owned by each\r
   feature's data layer; the TS artifact is the reference they are reconciled against, not\r
   generated Dart.\r
3. This ADR does not change the migration-atomicity rule: any schema change still ships with\r
   a regenerated `database.ts` in the same commit/PR.\r
\r
## Consequences\r
- Doc 11 v0.3.0 and the app README now document the TS artifact and the real regeneration\r
  command; the stale `gen types dart` / `lib/core/data/models/generated/` references are\r
  removed.\r
- The contract guard's stub-rejection (real typegen output must contain\r
  `export type Database` and `__InternalSupabase`) remains the mechanical gate; the guard,\r
  not the ADR, is what catches drift.\r
- If the Supabase CLI reintroduces Dart output, this decision can be revisited via a\r
  superseding ADR; until then the TS dump is authoritative.\r
