# Doc 03 — Architecture Overview & Component Boundaries

**Version:** v0.1.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-17 (STEP-1.3)
**Audience:** All contributors — this sets the high-level boundaries and component structure of the system.

> Defines the major components, their responsibilities, boundaries, and overall architectural style of the system.

## Table of Contents
- [1. Client Surfaces](#1-client-surfaces)
- [2. Top-Level Components](#2-top-level-components)
- [3. Architecture Style](#3-architecture-style)
- [4. Boundaries & Contract Candidates](#4-boundaries--contract-candidates)
- [5. Key Flows](#5-key-flows)
- [6. Tech Stack & Build vs. Buy](#6-tech-stack--build-vs-buy)
- [Decision Summary](#decision-summary)
- [Open Questions](#open-questions)
- [Version Log](#version-log)

## 1. Client Surfaces

The system relies on a single unified client application deployed across two primary surfaces for the MVP:
- **Android:** Primary device target for foremen (and supervisors acting as foremen) operating in the field with potentially intermittent connectivity.
- **Web:** Primary surface for supervisors operating in the office for reporting, data management, and file uploads.
- *(Note: iOS is deferred but the cross-platform nature of the framework preserves it for the future.)*

*Because of the Android client surface, the Native App Architecture session (1.3a) applies. Because of the graphical interface, the UI / Design System session (1.7) applies.*

## 2. Top-Level Components

The system is stripped down to three major top-level pieces to maximize speed and simplicity for a solo developer:

| Component | Responsibility | Tech |
|-----------|----------------|------|
| **mine-flow-app** (Client) | A unified application handling all user interactions, state management, local offline caching, and data synchronization. | Flutter (Dart) |
| **Supabase** (Backend) | Cloud-hosted backend acting as the source of truth for structured data, handling authentication, and enforcing data access policies. | Supabase (PostgreSQL) |
| **Google Drive** (Data Bucket) | External storage bucket for holding heavy geospatial files (.shp, .tiff) natively outside of the relational database. | Google Drive REST API |

```ascii
                            +--------------------+
                            |   mine-flow-app    |
                            | (Flutter Client)   |
                            +---------+----------+
                                      |
                       +--------------+---------------+
                       |                              |
             +---------v----------+         +---------v----------+
             |      Supabase      |         |    Google Drive    |
             | (Database & Auth)  |         | (Geospatial Files) |
             +--------------------+         +--------------------+
```

## 3. Architecture Style

**Client-Server with Backend-as-a-Service (BaaS)**
The system avoids a custom middle-tier API server. The Flutter client directly accesses the database and auth services via the Supabase SDK. 

**Modular Monolith (Clean Architecture)**
Within the `mine-flow-app` client, the codebase will be structured as a modular monolith utilizing **Clean Architecture**. The app will be divided into Presentation, Domain, and Data layers, separated by feature domains (e.g., Attendance, Inventory, Tracking). This ensures business logic remains decoupled from UI components, keeping the system highly maintainable.

## 4. Boundaries & Contract Candidates

Because we are utilizing BaaS components, we don't need to define custom OpenAPI specs or GraphQL schemas for internal services, but we still define how data crosses the wire.

| Boundary | What crosses it | Sync/Async | Data owner | Likely contract style | Notes for Interface Contracts (1.11) |
|----------|-----------------|------------|------------|-----------------------|--------------------------------------|
| App ↔ Supabase | Structured data (logs, checks, user data) and auth tokens | Async | Supabase | Supabase SDK (WebSocket/REST) | Formal contracts are managed via DB schema/types generated from Supabase |
| App ↔ Google Drive | Heavy geospatial files (.shp, .tiff) and returned URLs/IDs | Async | Google Drive | Google APIs (REST) | Rely on standard `googleapis` Dart package; metadata stored in Supabase |

## 5. Key Flows

**Flow A: Foreman logs equipment condition offline, then syncs**
*(Note: Supervisors possess a superset of permissions and can perform these actions as well).*
1. Foreman opens the app in the field without internet and completes the Total Station pre-work checklist.
2. The Flutter app saves this data locally using its internal storage (Data layer in Clean Architecture).
3. Foreman returns to an area with connectivity. The app detects the connection and pushes the cached checklist to Supabase via the official SDK.
4. Supabase accepts the data, applies Row Level Security (RLS) rules to verify permissions, and commits it.

**Flow B: Supervisor uploads a heavy geospatial file**
1. Supervisor opens the Web app and selects a large `.tiff` file for the 'Rusia' PIT zone.
2. The Flutter app streams the file directly to Google Drive via the Drive API.
3. Upon success, Google Drive returns a file ID or link. The Flutter app packages this metadata (link, zone, acquisition timestamp) and saves it to Supabase via the SDK.
4. Supabase stores the metadata, making the file instantly searchable in the app's Data Bucket.

## 6. Tech Stack & Build vs. Buy

**Tech Stack**
- **Client App:** Dart / Flutter (Clean Architecture).
- **Backend/Database:** PostgreSQL (via Supabase).

**Build vs. Buy**
- **Build:** The entire unified client application, offline sync logic, and UI.
- **Buy (Managed Services):** 
  - Authentication (Supabase Auth)
  - Database & Backend API (Supabase PostgreSQL & PostgREST)
  - Geospatial File Storage (Google Drive)

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Client surfaces | Android (Foremen/Field) and Web (Supervisor/Office) | Matches the real-world usage and hardware availability | iOS is deferred for MVP (though preserved by Flutter) |
| 2 | Top-Level Components | Flutter App, Supabase, Google Drive | Stripped down for speed; delegates heavy lifting to managed services | No custom background workers or scheduled jobs running outside of Supabase |
| 3 | Architecture Style | Client-Server (BaaS) with Clean Architecture modular monolith on the client | Simplest to build for a solo developer while keeping the code scalable and testable | Forecloses a custom middle-tier API; all logic lives in the client or DB |
| 4 | Boundaries | App ↔ Supabase (via SDK), App ↔ Drive (via standard REST API) | Avoids custom API contract management; leverages robust existing SDKs | Client app is tightly coupled to Supabase SDK |
| 5 | Role Inheritance | Supervisor role is a superset of Foreman role | Supervisors often need to step in and perform field tasks | UI must gracefully handle showing field tasks to office users |
| 6 | Build vs. Buy | Buy Auth, DB, and heavy storage; Build client app | Focus developer time strictly on the domain problem, not plumbing | Vendor lock-in to Supabase and Google Drive |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
| OQ-1 | Detailed internal folder structure for Clean Architecture in Flutter | STEP-1.3a | Native App Architecture |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.3 | Initial draft from Architecture Overview session |
