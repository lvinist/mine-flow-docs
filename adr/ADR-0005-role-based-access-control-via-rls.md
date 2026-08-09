# ADR-0005: Role-Based Access Control via Supabase RLS

**Status:** Accepted
**Date:** 2026-07-18

## Related documents
- architecture/06-security-threat-model.md
- architecture/16-identity-auth.md
- architecture/17-privacy-compliance.md

## Context
The system has three distinct user roles (Supervisor, Foreman, Crew) with different data visibility and edit permissions. Because we are skipping a custom middle-tier API and allowing the client to query the database directly, we must ensure users cannot maliciously or accidentally access data they shouldn't.

## Decision
**Use Supabase Row Level Security (RLS):** We will enforce all RBAC rules natively within the PostgreSQL database using RLS policies.
- **Rationale:** Secures data at the lowest possible level. Even if the Flutter client is compromised or bypassed via direct API calls, the database will strictly enforce role boundaries.
- **Alternatives:** Client-side filtering only (highly insecure), Custom API Server (too much development overhead).
- **Reversibility:** Medium. Moving away from Supabase/Postgres would require reimplementing these security rules in a new application tier.

## Consequences
- **Easier:** Eliminates the need to write authorization boilerplate in a backend language.
- **Harder:** RLS policies can become complex to write and debug in SQL. Testing RLS requires specialized database tests or thorough integration testing.
