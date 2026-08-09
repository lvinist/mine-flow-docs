# ADR-0002: Use Supabase for Backend

**Status:** Accepted
**Date:** 2026-07-18

## Related documents
- architecture/03-architecture-overview.md
- architecture/08-infrastructure-deployment.md
- architecture/16-identity-auth.md

## Context
Building and maintaining a custom middle-tier API server, database, authentication system, and deployment pipeline is too time-consuming for a 1-month solo MVP. We need a robust backend that handles authentication and relational data out of the box.

## Decision
**Use Supabase (managed cloud):** We will use Supabase for PostgreSQL, Authentication, Row Level Security (RLS), and Edge Functions (for privileged operations like user creation).
- **Rationale:** Supabase provides a fully managed PostgreSQL database with a powerful SDK for Flutter, allowing the client to query the database directly and securely without a middle-tier API.
- **Alternatives:** Firebase (NoSQL structure makes complex reporting harder), Custom Node/Go API (too much overhead).
- **Reversibility:** Medium. We are locked into the Supabase SDK, but the underlying database is standard PostgreSQL, which can be migrated or self-hosted if needed.

## Consequences
- **Easier:** Instant backend setup, built-in auth, no server maintenance.
- **Harder:** Migrating off the Supabase Flutter SDK later would require building a custom API tier. Relies on Supabase free-tier limits for MVP.
