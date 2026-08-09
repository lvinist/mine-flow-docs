# ADR-0004: Offline-First Sync with Last-Write-Wins

**Status:** Accepted
**Date:** 2026-07-18

## Related documents
- architecture/04-data-model.md
- architecture/15-native-app-architecture.md

## Context
Foremen operating in the mine site often lack internet connectivity. They need to reliably record attendance, equipment checks, and cut/fill volumes. If the app requires a constant connection, it will be useless in the field.

## Decision
**Implement Offline-First with Last-Write-Wins Sync:** The Flutter app will write all operational data to a local database (SQLite/Hive) first. A background process will detect connectivity and sync pending records to Supabase. Conflicts are resolved simply by timestamps (the most recently edited record overwrites older ones).
- **Rationale:** Guarantees field usability. Since foremen are generally assigned specific crews and zones, concurrent edits on the exact same record by different users are extremely rare, making simple last-write-wins sufficient.
- **Alternatives:** Require online connection (fails field requirement), Operational Transformation or CRDTs (overly complex for the MVP scope).
- **Reversibility:** High. The sync logic is confined to the Data layer of the Clean Architecture.

## Consequences
- **Easier:** Field crews can work uninterrupted regardless of network conditions.
- **Harder:** Sync logic must handle edge cases (e.g., app killed during sync, syncing large batches on low battery). All database records require UUID primary keys generated on the client to avoid collisions.
