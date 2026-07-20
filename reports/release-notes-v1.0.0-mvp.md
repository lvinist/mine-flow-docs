# mine-flow — Release Notes: v1.0.0 (MVP)

**Release date:** 2026-07-20
**Audience:** Field operators, site supervisors, and project managers
**Scope:** Phase 1 MVP (STEP-1 through STEP-12)

> The v1.0.0 Minimum Viable Product (MVP) of the mine-flow application is now complete. It introduces a comprehensive offline-first mobile and desktop dashboard for field operations, encompassing crew attendance, daily logging, equipment checks, tracking, reporting, and large data bucket integrations.

## Highlights
- **Full Offline Capability:** The app includes a robust offline-first synchronization engine (via Hive and Supabase), ensuring that field workers in low-connectivity areas can continue logging data, running equipment checks, and recording attendance without interruption.
- **Comprehensive Tracking:** Replaced manual and disparate field records with integrated tracking for cut/fill volume, land clearing area, and inventory, ensuring unified reporting and clear visibility.
- **Data Bucket Integration:** Seamless integration with Google Drive allows for the secure upload of heavy geospatial files (.shp, .tiff) with robust metadata tagging directly linked to Supabase.

## What's New
- **Authentication & Core Data:** Complete and secure login utilizing Supabase Auth with Row Level Security (RLS) policies to protect company data.
- **Attendance & Daily Logging:** Dedicated screens for managing crew attendance and structured daily logs for field operations.
- **Equipment Digital Checks:** Standard Operating Procedure (SOP) based pre-work and post-work condition checks specifically for GNSS, Total Station, and Drone/UAV equipment.
- **Field Tracking Modules:** Intuitive dashboards for tracking cut/fill volumes, managing land clearing areas, and entering inventory or stock adjustments.
- **Work Timeline:** A visual work timeline to keep track of operational progress and daily activities.
- **Reporting & Notifications:** Automatic PDF report generation for daily operations and an in-app notification system that follows rules-based alerts.
- **Responsive UI & Themes:** A brand new shadcn-admin collapsible sidebar shell offering responsive navigation, alongside a dark/light mode toggle.

## Improvements
- Initial scaffolding established using Flutter and Clean Architecture principles, ensuring scalability for future phases.
- High stability and code quality, passing all comprehensive unit, widget, and integration tests, as well as zero analyzer warnings.

## Fixes
- Addressed multiple edge cases in the offline synchronization registrar wiring for tracking, attendance, logging, and equipment.
- Resolved orphaned UI screens and completely wired all components into the main router logic.

## Breaking Changes / Action Required
- **Initial Setup:** Site supervisors must ensure all crew members receive their Supabase login credentials.
- **Google Drive Authentication:** Users uploading geospatial data must ensure they have proper Google Service Account authorization as provisioned by IT.

## Known Issues
- Large geospatial uploads via the Data Bucket may pause and resume depending on the Google Drive API rate limits or connectivity disruptions. This is monitored and will gracefully degrade per architecture specifications.

## Documentation
- The canonical architecture documents have been completed and are available in the `Code/mine-flow-docs/architecture/` directory.
- For onboarding and developer setup, refer to `Code/mine-flow-docs/ONBOARDING.md`.

## References
- **Related STEPs:** STEP-1 to STEP-12
- **Architecture / ADRs:** Refer to `Code/mine-flow-docs/architecture/03-architecture-overview.md`
