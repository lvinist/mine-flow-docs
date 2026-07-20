# Doc 17 — Privacy, Compliance & Data Governance

**Version:** v0.1.0
**Status:** Draft
**Last updated:** 2026-07-17 (STEP-1.6b)
**Audience:** Developers, Architects, Product Managers, Legal/Compliance

> Defines the applicable privacy regimes, the personal data inventory, lawful basis for collection, retention periods, and governance for mine-flow.

## 1. Applicable Regimes

Because the app is an internal tool for a single mine site (utilizing Indonesian terminology) and stores National ID numbers, massive international frameworks (GDPR, CCPA) do not strictly apply.
*   **Regime:** Local data protection and employment laws (e.g., Indonesia's UU PDP) apply.
*   *Note:* This requires formal legal confirmation to ensure full alignment with local labor regulations regarding National IDs.

## 2. Personal-Data Inventory

We collect the following personal data, stored in Supabase:
*   **Name, Phone Number / Email:** Ordinary PII
*   **Address, Gender, Emergency Contacts:** Ordinary PII (justified for HR/safety needs)
*   **Passwords:** Security Data (hashed/managed securely by Supabase Auth)
*   **National ID Number & Date of Birth:** Highly Confidential / Regulated PII
*   *Special-category data (health, biometric, etc.) is explicitly NOT collected.*

## 3. Lawful Basis & Consent

The app does not rely on complex consent-withdrawal mechanisms (like cookie banners) because the data collection is mandatory for operations.
*   **Employment Contract / Legal Obligation:** Used as the lawful basis for collecting National IDs, Address, Gender, and Emergency Contacts.
*   **Legitimate Business Interest:** Used as the lawful basis for daily operational tracking (cut/fill logs, daily attendance).
*   *Implementation:* A simple internal "Terms of Use & Privacy Notice" will be provided on first login to inform users how their data is used.

## 4. Data Minimization & Purpose Limitation

*   All fields collected are strictly tied to business needs.
*   Address and Emergency Contacts are retained explicitly for worksite safety.
*   Gender is retained for HR and work-environment policies.
*   No extraneous "nice-to-have" data is stored.

## 5. Retention & Deletion

*   **Operational Data:** Kept indefinitely for historical reporting (cut/fill, land clearing, checks).
*   **Personal Data (Ex-Employees):** When an employee leaves, their account is soft-deleted to revoke access. Their personal records are retained for a strict **7-year period** to comply with standard employment and tax audits. After 7 years, the data is permanently hard-deleted.

## 6. Data-Subject Rights

*   **Process:** Manual.
*   If an employee submits an access, export, or deletion request, the Site Supervisor or Database Admin will manually execute the export (e.g., CSV dump) or deletion directly within the Supabase dashboard.
*   No automated "Export My Data" buttons will be built for the MVP.

## 7. Data Residency & Sub-processors

*   **Data Residency:** Supabase database hosted in the **Southeast Asia** region (e.g., Jakarta or Singapore) to comply with local data sovereignty preferences.
*   **Sub-processors:** Limited exclusively to **Supabase** (structured data, auth) and **Google Drive** (geospatial file storage). No third-party analytics or AI APIs are used.

## 8. Governance & Accountability

*   **Privacy Owner:** The internal Project Manager (or Site Supervisor) owns privacy for the MVP.
*   **Breach Notification:** In the event of a data leak, the Privacy Owner must notify the company's internal HR/Legal team within 72 hours.
*   **Privacy Policy:** A lightweight, internal-facing policy presented at first login.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Applicable Laws | Local data protection (UU PDP) | App is internal and stores National IDs. | Assuming no regulation applies. |
| 2 | Data Minimization | Keep Address & Gender | Required for safety/emergency contact and HR tracking. | The smallest possible data footprint. |
| 3 | Lawful Basis | Employment Contract & Legitimate Interest | Removes the need to build complex consent-withdrawal flows. | Using data for marketing or external sharing. |
| 4 | Retention Period | 7 years post-employment, then purge | Meets typical tax/labor audit requirements without hoarding data forever. | Indefinite retention of employee PII. |
| 5 | Data Rights Processing | Manual | Saves significant development time for the MVP. | Automated self-serve privacy portal. |
| 6 | Data Residency | Southeast Asia (Supabase) | Keeps data locally compliant with ASEAN/Indonesian norms. | Cheaper hosting in US/EU regions. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| OQ-1 | Formal legal review of local privacy compliance (UU PDP). | Legal / DPO | Phase 2 / Ongoing Compliance |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.6b | Initial draft from Privacy & Compliance session |
