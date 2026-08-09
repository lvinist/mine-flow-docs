# ADR-0006: Local Offline Storage — Hive over SQLite/sqflite

**Status:** Accepted
**Date:** 2026-07-18

## Related documents
- architecture/15-native-app-architecture.md — §3 On-Device Storage & State (Open Question OQ-2)
- STEP-2 PLAN — prompted this decision during repository scaffold

## Context

Doc 15 — Native App Architecture deferred the selection between SQLite/sqflite
and Hive (or another key-value store) as Open Question OQ-2. During STEP-2 (repo
scaffold) we must commit to a library in order to pin it in `pubspec.yaml`.

The offline storage must handle two use cases:
1. **Sync queue** — a FIFO queue of pending writes to be pushed to Supabase when
   connectivity is restored. Records are key-value shaped (UUID → JSON blob).
2. **Local record cache** — a read-through cache of recently fetched Supabase
   records so the app is usable offline. Also key-value or collection shaped.

Additional constraints:
- The app targets **Android** (primary) and **Flutter Web** (secondary).
- The Web target eliminates any library requiring a native SQLite binary
  (`sqflite` uses a platform channel that only works on Android/iOS/Windows,
  not the browser).
- The project is a solo-developer MVP with a 1-month timeline — simplicity
  counts.

Candidates evaluated:

| Library | Web support | API complexity | Maturity |
|---------|-------------|----------------|----------|
| `sqflite` | ❌ (no web) | Medium (SQL) | High |
| `hive` | ✅ (pure Dart) | Low (box/key-value) | High (stable v2) |
| `isar` | ✅ (experimental web) | Medium (query DSL) | Medium (newer) |
| `drift` (moor) | ✅ (via sqlite3 wasm) | High (ORM + SQL) | High |

## Decision

Use **Hive v2** (`hive` + `hive_flutter`) as the local offline storage engine.

**Rationale:**
- Works on both Android and Web (pure Dart, no native binary).
- Extremely simple API: open a `Box<T>`, `put(key, value)`, `get(key)` — zero
  SQL boilerplate for the sync queue and record cache use cases.
- Stable, widely used, well-documented Flutter ecosystem package.
- TypeAdapters will be written manually for the MVP's small model set, avoiding
  the `hive_generator` code-gen dependency which has a broken transitive
  dependency chain with `build_runner` 2.4+.

**Alternatives rejected:**
- `sqflite` — no Web target support; eliminated immediately.
- `isar` — Web support is experimental; adds risk on the secondary target.
- `drift` — feature-rich but heavy for the sync queue / cache use case;
  introduces complex SQL ORM overhead for a solo MVP developer.

**Reversibility:** Low-medium. Hive boxes are abstracted behind repository
interfaces (Clean Architecture pattern), so swapping the storage engine in a
later phase requires changing only the Data layer implementations, not the
Domain or Presentation layers.

## Consequences

- **Easier:** Local sync queue and record cache are quick to implement with
  the Hive `Box` API. No migration tooling needed for MVP-scale data.
- **Harder:** Complex relational queries (joins, aggregations) are not native
  to Hive — but those queries run against the Supabase remote, not the local
  cache, so this is not a practical constraint for the MVP.
- **Risk:** Hive v2 is mature but not actively maintained for new features;
  `hive` v3 / migration to Isar may be considered in a later phase if the
  data model grows complex. This risk is tracked in `registries/risks.yml`.
- **New work:** Hive TypeAdapters must be hand-written for each domain entity
  persisted locally. This is a small overhead per entity.
