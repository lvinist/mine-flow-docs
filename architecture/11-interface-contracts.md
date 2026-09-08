# Doc 11 — Interface Contracts

**Version:** v0.3.0
**Status:** Draft
**Last updated:** 2026-09-08 (STEP-50.1)
**Audience:** All contributors — this sets the rules for how boundaries are specified and kept in sync.

> Defines how the interfaces between the app and its external services (Supabase, Google Drive) are specified, generated, and versioned.

## Table of Contents
- [1. Boundary Contract Inventory](#1-boundary-contract-inventory)
- [2. Authoring Source & Contract of Record](#2-authoring-source-contract-of-record)
- [3. Artifact Locations](#3-artifact-locations)
- [4. Versioning & Compatibility](#4-versioning-compatibility)
- [5. Request & Message Conventions](#5-request-message-conventions)
- [6. Error Model](#6-error-model)
- [7. Auth, Authorization & Privacy](#7-auth-authorization-privacy)
- [8. Observability Hooks](#8-observability-hooks)
- [9. Contract Testing & CI Inputs](#9-contract-testing-ci-inputs)
- [10. Ownership & Review](#10-ownership-review)
- [11. Deferred & Informal Interfaces](#11-deferred-informal-interfaces)
- [Decision Summary](#decision-summary)
- [Open Questions](#open-questions)
- [Version Log](#version-log)

## 1. Boundary Contract Inventory

| Boundary | Owner | Contract Level | Style | Status |
|----------|-------|----------------|-------|--------|
| **App ↔ Supabase** | Solo Dev | Formal | Generated TypeScript schema types | Active |
| **App ↔ Google Drive** | Google | Formal | Typed package interface | Active |

## 2. Authoring Source & Contract of Record

- **App ↔ Supabase:**
  - **Authoring Source:** Supabase PostgreSQL database schema.
  - **Contract of Record:** `supabase/types/database.ts` — TypeScript schema types generated via `supabase gen types --lang typescript --linked`, committed in the app repo (ADR-0019). The CLI's Dart output was removed (`supabase/cli#6230`), so the TS dump is the committed contract snapshot; the app's Dart models are hand-written mappers reconciled against it.
- **App ↔ Google Drive:**
  - **Authoring Source & Contract of Record:** The official `googleapis` Dart package maintained by Google.

## 3. Artifact Locations

- **Generated TypeScript Types:** `Code/mine-flow-app/supabase/types/database.ts` — real typegen output, checked into version control alongside the migrations it reflects. The guard `tool/check_supabase_contracts.dart` rejects stubs and stale artifacts.

## 4. Versioning & Compatibility

- **Database Migrations as Versions:** Since the database schema is the contract, versioning is managed via Supabase database migration scripts.
- **Atomic Updates:** Any schema change (migration) must be accompanied by regenerating the TypeScript contract artifact and updating the Flutter app code in the same commit/PR to prevent drift.

## 5. Request / Message Conventions

- **Database Conventions:** Follow standard PostgREST and PostgreSQL conventions.
- **Casing:** Database columns use `snake_case`. Hand-written Dart mappers translate these to `camelCase` for idiomatic Flutter usage.
- **Timestamps:** Use `timestamptz` for all date/time fields.

## 6. Error Model

- **Raw Errors:** Supabase/PostgREST returns standard database errors (e.g., `PostgrestException`).
- **App Handling:** The Flutter app's Data layer will catch these raw errors and map them to **plain-language, user-friendly error messages** before bubbling them up to the UI (e.g., mapping a foreign key or permissions error to "You don't have permission to edit this").

## 7. Auth, Authorization & Privacy

- **Auth Mechanism:** The app automatically sends secure JWTs with every request via the Supabase SDK.
- **Authorization:** Enforced strictly via Supabase Row Level Security (RLS) policies.
- **Privacy:** RLS ensures sensitive fields (like NIK and birth dates) are isolated appropriately.

## 8. Observability Hooks

- **Logging Boundaries:** API failures will be logged locally and to the designated crash reporting tool (e.g., Crashlytics) in the app before the user-friendly error is shown.
- **Request Context:** Rely on Supabase's internal request IDs for backend tracing; client-side logs will include relevant contextual metadata (endpoint, action attempted).

## 9. Contract Testing & CI Inputs

- **Testing Rule:** Heavy contract testing is skipped due to the nature of the project.
- **CI Gate:** The CI pipeline runs `dart run tool/check_supabase_contracts.dart` (contract & l10n guards run in the `test` job): when the database schema changes, the artifact must be regenerated or the build fails.

## 10. Ownership & Review

- **Ownership:** The solo developer owns all contracts.
- **Update Rule:** If the database changes, the generated types must be updated and the app must compile before merging.

## 11. Deferred / Informal Interfaces

- Specific data import/export formats (like CSV uploads or PDF report schemas) are deferred for now. If needed later, they will be specified as lightweight format documents.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Contract style (App/DB) | Code-generated typed interfaces | Eliminates manual contract writing; guarantees types match DB | Tightly couples app to DB schema |
| 2 | Contract generation | `supabase gen types --lang typescript --linked` → committed `supabase/types/database.ts` (ADR-0019) | Only output the CLI still emits; diffable committed snapshot with a hardened CI guard | Dart models are hand-written mappers reconciled against the TS artifact, not generated |
| 3 | Error handling | App Data layer maps raw exceptions to friendly messages | Keeps DB errors from leaking to users | Extra mapping boilerplate in Data layer |
| 4 | Testing | Compile-time checks only in CI | Solo project using generated code doesn't need heavy API tests | Won't catch logical data mismatches, only structural ones |

## Open Questions

None.

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.3.0 | 2026-09-08 | STEP-50.1 | Contract of record corrected to the real artifact: `supabase/types/database.ts` TypeScript types via `supabase gen types --lang typescript --linked` (ADR-0019); removed the dead `gen types dart` / `lib/core/data/models/generated/` path the CLI no longer emits; boundary statuses Active; CI gate names the real guard |
| v0.2.0 | 2026-08-03 | STEP-41 | Updated generated models path to `lib/core/data/models/generated/` and established CI guard |
| v0.1.0 | 2026-07-18 | STEP-1.11 | Initial draft from Interface Contracts session |
