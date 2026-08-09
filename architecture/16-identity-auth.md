# Doc 16 — Identity & Auth

**Version:** v0.1.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-17 (STEP-1.6a)
**Audience:** All contributors — this sets the authentication methods and authorization roles for the system.

> Defines how users authenticate, what authorization roles exist, and how access is enforced.

## 1. Authentication Methods

For the MVP, we use standard **Email and Password** (or Phone Number and Password). This is simple, universally understood, and quick to set up for field crews. Complex methods like MFA or Single Sign-On (SSO) are deferred for later phases.

## 2. Identity Provider

We utilize **Supabase Auth** as a fully managed identity provider (the "buy" approach) rather than rolling a custom identity solution. This handles secure password storage, token generation, and password resets safely, integrating seamlessly with our backend data.

## 3. User / Account Model

The account lifecycle is strictly controlled:
- **Creation (Signup):** No public signup exists. Accounts are created manually by Supervisors for new Foremen and Crew members. Because the client app cannot hold the `service_role` key required to create users in Supabase Auth, this will be handled via a **Supabase Edge Function** called from the app by authorized Supervisors.
- **Recovery:** Standard password reset (e.g., via email or phone link).
- **Deactivation:** When an employee leaves, their account is *deactivated* to prevent login, but it is never deleted. This preserves the audit trail of their historical work logs.

## 4. Authorization Model

Access is controlled via **Role-Based Access Control (RBAC)** enforced strictly at the database layer using **Supabase Row Level Security (RLS)**.

Three core roles exist:
1. **Supervisor:** Can view, edit, and manage all data across the site, including user accounts and geospatial files.
2. **Foreman:** Can log daily progress (cut/fill, clearing), perform equipment checks, and view their assigned crew's attendance.
3. **Crew:** Can only log their own attendance and view their specific assignments.

## 5. Multi-Tenancy

While the MVP supports only a single mine site, the database design supports future multi-tenancy. A hidden `site_id` (or `tenant_id`) is attached to records. For the MVP, all users are invisibly assigned to a default single site. This prevents a massive rewrite when scaling to multiple sites in Phase 2.

## 6. Sessions & Tokens

Session management relies on standard **Supabase defaults (JWT and Refresh Tokens)**:
- Tokens are stored in the device's **encrypted secure storage** by the Flutter SDK.
- Tokens automatically refresh in the background, allowing uninterrupted access in the field.
- Deactivating an account revokes the token, instantly blocking access across all devices.
- Users can be logged into multiple devices simultaneously.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Auth Method | Email/Password | Simple, quick setup, universally understood by crews. | Social logins or MFA in the MVP. |
| 2 | Identity Provider | Supabase Auth (Buy) | Handles security safely without reinventing the wheel, tight integration with Postgres. | Custom auth flows outside of what Supabase provides. |
| 3 | Account Lifecycle | Supervisor-only creation, Soft Deactivation | Protects against unauthorized public signups while preserving the audit trail of departed employees. | Self-service signup for the public. |
| 4 | Authorization | RBAC via Supabase RLS | 3 fixed roles cover the business needs. Enforcing at DB level prevents bypass via API bugs. | Highly dynamic custom attribute-based permissions (ABAC). |
| 5 | Multi-tenancy | Include `site_id` foundation | Prevents a complete rewrite when adding multi-site in Phase 2, despite MVP being single-site. | Slightly more complex queries (must filter by `site_id` even when there's only one). |
| 6 | Sessions | Supabase defaults (JWT) | Secure, automatic background refresh, supports multiple devices simultaneously. | Custom session expiration logic. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
|    |          |       |            |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.6a | Initial draft from Identity & Auth conditional session |
| v0.1.1 | 2026-07-18 | STEP-1.14 | Added Edge Function requirement for Supervisor account creation |
