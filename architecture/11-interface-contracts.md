# Doc 11 — Interface Contracts

**Version:** v0.1.0
**Status:** Draft
**Last updated:** 2026-07-18 (STEP-1.11)
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
| **App ↔ Supabase** | Solo Dev | Formal | Code-generated types | Planned |
| **App ↔ Google Drive** | Google | Formal | Typed package interface | Planned |

## 2. Authoring Source & Contract of Record

- **App ↔ Supabase:**
  - **Authoring Source:** Supabase PostgreSQL database schema.
  - **Contract of Record:** Strongly-typed Dart models generated via the Supabase CLI (`supabase gen types dart`).
- **App ↔ Google Drive:**
  - **Authoring Source & Contract of Record:** The official `googleapis` Dart package maintained by Google.

## 3. Artifact Locations

- **Generated Dart Types:** The generated Supabase models will live directly in the Flutter app's codebase under `lib/data/models/generated/` (or similar standard Data layer path) to ensure they are checked into version control alongside the code that uses them.

## 4. Versioning & Compatibility

- **Database Migrations as Versions:** Since the database schema is the contract, versioning is managed via Supabase database migration scripts.
- **Atomic Updates:** Any schema change (migration) must be accompanied by regenerating the Dart types and updating the Flutter app code in the same commit/PR to prevent drift.

## 5. Request / Message Conventions

- **Database Conventions:** Follow standard PostgREST and PostgreSQL conventions.
- **Casing:** Database columns use `snake_case`. The generated Dart code or manual mappers will translate these to `camelCase` for idiomatic Flutter usage.
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
- **CI Gate:** The CI pipeline must simply guarantee that when the database schema changes, the newly generated Dart types still compile successfully against the rest of the Flutter app.

## 10. Ownership & Review

- **Ownership:** The solo developer owns all contracts.
- **Update Rule:** If the database changes, the generated types must be updated and the app must compile before merging.

## 11. Deferred / Informal Interfaces

- Specific data import/export formats (like CSV uploads or PDF report schemas) are deferred for now. If needed later, they will be specified as lightweight format documents.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Contract style (App/DB) | Code-generated typed interfaces | Eliminates manual contract writing; guarantees types match DB | Tightly couples app to DB schema |
| 2 | Contract generation | Supabase CLI (`supabase gen types dart`) | Official supported path | Custom serializers must adapt to the generated shape |
| 3 | Error handling | App Data layer maps raw exceptions to friendly messages | Keeps DB errors from leaking to users | Extra mapping boilerplate in Data layer |
| 4 | Testing | Compile-time checks only in CI | Solo project using generated code doesn't need heavy API tests | Won't catch logical data mismatches, only structural ones |

## Open Questions

None.

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-18 | STEP-1.11 | Initial draft from Interface Contracts session |
