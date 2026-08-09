# Doc 10 — Observability

**Version:** v0.1.0
**Status:** Draft
**Last updated:** 2026-07-18 (STEP-1.10)
**Audience:** Technical team, Developers, DevOps

> Defines the logging, metrics, alerting, and error tracking strategies for monitoring the system's health in production.

## 1. Logging
- **Format:** Structured (JSON) logs to make searching and filtering easy.
- **Key Events Logged:** App startup/crashes, login success/failure, offline sync start/success/failure, and Supabase/Google Drive API errors.
- **Correlation IDs:** Each offline sync session generates a unique ID to trace its path from the device to the database.
- **The "Never-Log" List:** Passwords, session tokens, National ID numbers, and Date of Birth are strictly excluded from all logs.

## 2. Metrics
- **Latency (Speed):** Track data entry time (< 1 second) and dashboard load times (< 1-2 seconds).
- **Traffic & Errors:** Number of API requests to Supabase/Drive and their failure rates.
- **Saturation (Capacity):** Supabase database connection usage (crucial during the "sync rush hour").
- **Domain Metrics:** Number of daily cut/fill logs submitted and the volume of pending offline syncs.

## 3. Tracing & Health Checks
- **Distributed Tracing:** Skipped for the MVP. The architecture is a simple client-server model (Flutter talking directly to Supabase) with no custom middle-tier APIs, so tracing across services is unnecessary. We rely on Correlation IDs in logs instead.
- **Health Checks:** Skipped for the custom components. The Flutter app is a client, and Supabase/Google Drive are managed services with their own built-in health monitoring and public status pages.

## 4. Error Tracking
- **Crash Reporting:** Integrate **Sentry** (or Firebase Crashlytics if Sentry's free tier proves insufficient, though Sentry is the primary choice).
- **Function:** Automatically catches app crashes and groups identical exceptions, providing the exact stack trace from the field.

## 5. Dashboards & Alerts
- **Dashboards:** Use the built-in Supabase and Sentry dashboards for system health. No custom Grafana/Prometheus setup for the MVP.
- **Alerts (via Email to Admin/Developer):**
  - **System Saturation:** Alert when the Supabase database nears 90% storage or connection capacity.
  - **Crash Spike:** Alert via Sentry if the app experiences a sudden spike in crashes (e.g., > 10 crashes an hour).

## 6. Tooling & Retention
- **Tooling:** Fully hosted (Supabase for backend metrics/logs, Sentry for error tracking).
- **Retention:** System logs and crash reports are kept for **30 days**, keeping costs near zero while allowing enough time to investigate bugs. (Business data is kept indefinitely per the Privacy & Compliance doc).

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Logging Strategy | Structured JSON with Correlation IDs | Easy to search and trace sync events without complex tracing setups. | Plain text logs. |
| 2 | Metrics to Track | Golden signals + domain metrics | Directly ties into the Scaling & Performance targets. | Extensive custom BI dashboards for system metrics. |
| 3 | Distributed Tracing | Skip for MVP | The system lacks custom middle-tier APIs; tracing is overkill. | Granular span-level latency tracking across components. |
| 4 | Health Checks | Rely on Supabase/Drive status | No custom servers to health check. | Custom uptime heartbeat endpoints. |
| 5 | Error Tracking | Sentry (Free Tier) | Automatically captures and groups crashes in the field without user reporting. | Relying purely on user bug reports. |
| 6 | Alerting | Minimal (Spikes & Saturation) | Prevents alert fatigue for a solo developer side-project. | Proactive alerting on minor, non-blocking issues. |
| 7 | System Log Retention | 30 Days (Hosted) | Standard, cheap, and sufficient for debugging recent issues. | Long-term historical system log analysis. |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
|    |          |       |            |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-18 | STEP-1.10 | Initial draft from Observability session |
