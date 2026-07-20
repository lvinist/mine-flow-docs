# Doc 06 — Security & Threat Model

**Version:** v0.1.0
**Status:** Draft
**Last updated:** 2026-07-17 (STEP-1.6)
**Audience:** Developers, Architects, Project Managers

> Defines the assets, trust boundaries, and minimum viable security mitigations for the mine-flow MVP.

## 1. Assets

The primary assets that must be protected in the MVP are:
*   **Personal Data:** Crew members' sensitive information (national ID numbers, place/date of birth).
*   **Credentials & Keys:** User passwords (managed by Supabase) and integration keys (e.g., Google Drive API).
*   **Proprietary Operational Data:** Commercially sensitive information including cut/fill volumes, land clearing areas, and geospatial files (.shp, .tiff).
*   **System Availability:** Keeping the dashboard and database operational to ensure daily logging is not blocked.

## 2. Trust Boundaries

The system data crosses lines of trust at these main boundaries:
1.  **Public Internet ↔ Supabase Backend:** External internet traffic interacting with our Supabase database and authentication endpoints.
2.  **Role Privilege Boundaries:** Internal privilege boundaries separating Crew, Foreman, and Supervisor data access.
3.  **App ↔ Google Drive:** Our app interacting with an external third-party service (Google Drive) to read geospatial files.

## 3. Threats & Mitigations

| Threat | Boundary | MVP Mitigation | Deferred / Blast Radius |
|--------|----------|----------------|-------------------------|
| Impersonation | Internet ↔ Supabase | Supabase Auth with strong passwords. No default shared accounts. | - |
| Data Eavesdropping | Internet ↔ Supabase | Enforce HTTPS/TLS everywhere (Supabase default). | - |
| Denial of Service (DoS) | Internet ↔ Supabase | Rely on Supabase's built-in rate limiting. | **Deferred:** Custom anti-DDoS infrastructure. *Blast Radius:* App availability could be degraded by heavy automated attacks. |
| Privilege Escalation | Role Privileges | Strict Row Level Security (RLS) in the Supabase database. | - |
| Information Disclosure | App ↔ Google Drive | Restrict Google Drive folder permissions to authorized Google Workspace accounts only. | - |

## 4. Authentication & Authorization Posture

*   **Authentication:** Supabase Auth (Email/Password or Phone/Password) will handle login verification.
*   **Authorization:** A Role-Based Access Control (RBAC) system (Crew, Foreman, Supervisor) enforced natively in the database via Supabase Row Level Security (RLS).
*   *(Note: Deep design of these flows will be covered in the conditional Identity & Auth session).*

## 5. Secrets & Data Protection

*   **Development Secrets:** Kept in a local, `.gitignore`d `.env` file. The repository only contains a safe `.env.example` template.
*   **Production Secrets:** Managed securely via the hosting platform's environment variables or a secrets manager, not in code.
*   **Data in Transit:** Secured via HTTPS/TLS.
*   **Data at Rest:** Secured by Supabase's default encryption at rest.
*   **Rotation:** Compromised or leaked secrets (e.g., Supabase service keys, Google API keys) must be rotated immediately.

## 6. Web & App Risk Posture

*   **Input Validation & Injection:** Mitigated by Flutter's built-in UI text field sanitization (preventing XSS) and Supabase SDK's secure Postgres communication (preventing SQL injection).
*   **Rate Limiting:** Mitigated by Supabase API rate limits.
*   **Dependency Vulnerabilities:** Stick to official/reputable packages (`flutter_bloc`, `supabase_flutter`) and audit them periodically for security updates.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Anti-DDoS Strategy | Rely on Supabase default rate limiting | Custom infrastructure is overkill for a 100-user MVP. | Custom fine-grained IP blocking or bot protection. |
| 2 | Authorization Enforcement | Supabase Row Level Security (RLS) | Secures data at the database layer, preventing bypassing via direct API calls. | Moving away from Supabase or Postgres RLS would require rebuilding authorization logic in a middle tier. |
| 3 | Geospatial File Access | Drive folder permissions | MVP doesn't need a complex proxy service if Google Workspace handles access control natively. | Publicly shareable map links. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| 1 | Exactly which Google Workspace accounts will have access to the Drive folder? | Product | Setup & Deployment |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.6 | Initial draft |
