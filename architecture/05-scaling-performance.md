# Doc 05 — Scaling & Performance

**Version:** v0.1.0
**Status:** Draft
**Last updated:** 2026-07-17 (STEP-1.5)
**Audience:** Technical team, Architecture reviewers

> Defines the performance targets, scaling strategy, and mitigation for future bottlenecks for the MVP.

## 1. Load Profile
- **Launch (MVP):** ~100 users at a single mine site. Assuming a few hundred daily data entries (attendance, cut/fill logs, equipment checks) and a handful of geospatial files added per week.
- **Later (~12 months):** Expanding to multi-site. Perhaps 3–5 sites, totaling 300–500 users, generating a few thousand records a day, and holding hundreds of geospatial files.

## 2. Performance Targets
- **Loading dashboards/lists** (e.g., viewing work timeline, daily attendance, searching geospatial file registry): **Under 1–2 seconds**.
- **Data entry** (e.g., submitting cut/fill log, daily report, equipment check): **Under 1 second** (plus instant UI feedback through local cache).
- **Offline Sync:** When reconnecting, background syncing of offline logs completes seamlessly without freezing or locking up the app UI.

## 3. Stateful vs. Stateless Components
- **Flutter App (Frontend):** Mostly stateless. Holds temporary local state (current user session token, offline queue). Fetches fresh data from the cloud.
- **Supabase (Backend):** Holds all permanent state (Postgres database, user accounts, authentication). Since Supabase is a managed service, this offloads our hardest state management and scaling burden to them.

## 4. Bottlenecks & Scaling Strategy
- **Bottlenecks:**
  - **Offline Sync "Rush Hour":** Hundreds of crew members returning to camp at the same time (e.g., 5:00 PM) causing a burst of database connections and write operations.
  - **Google Drive Limits:** Potential API rate limits if automated fetching of geospatial files becomes too frequent.
- **Scaling Strategy:**
  - **Vertical Scaling for Backend:** We rely on Supabase's managed Postgres instance. As load grows, we will scale vertically by upgrading the Supabase instance plan, avoiding any code changes.

## 5. Caching & Async Plan
- **Caching:** The Flutter application will heavily utilize local on-device caching for data like the work timeline, attendance lists, and the geospatial file registry. This ensures instant load times and supports the core offline mode. Data is refreshed in the background on startup or via pull-to-refresh.
- **Async & Heavy Work:** 
  - **Offline sync:** Handled as a background task.
  - **PDF Reports:** Generated directly on the user's device (frontend) to completely offload this intensive task from the backend.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Scaling strategy | Vertical scaling via Supabase plan upgrades | Keeps MVP simple with zero code changes required to scale the backend for hundreds of users. | Forecloses custom distributed database topologies for now; fully relies on Supabase's pricing model. |
| 2 | Heavy computation (PDFs) | Local on-device PDF generation | Offloads CPU-intensive tasks from the server, protecting database performance for all users. | Requires the client device to have sufficient resources to generate PDFs, which is acceptable for modern devices. |
| 3 | Single site MVP design | Add a `site_id` column to all tables immediately | Prevents a massive database rewrite when expanding to multiple sites later (avoids single-site lock-in). | A very minor overhead in current queries to filter by the default site. |
| 4 | Offline sync overload mitigation | Exponential backoff in the Flutter app | Spreads out the "sync rush hour" traffic spike naturally without needing a complex message queue (like RabbitMQ) on the server. | Real-time sync might be slightly delayed during peak times. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| 1 | Is Google Drive file linking subject to specific public link rate limits? | | Infrastructure / Interface Contracts |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.5 | Initial draft |
