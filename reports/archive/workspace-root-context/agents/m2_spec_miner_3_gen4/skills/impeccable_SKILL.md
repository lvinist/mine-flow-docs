---
name: impeccable
description: Use when the user wants to design, redesign, shape, critique, audit, polish, clarify, distill, harden, optimize, adapt, animate, colorize, extract, or otherwise improve a frontend interface. Covers websites, landing pages, dashboards, product UI, app shells, components, forms, settings, onboarding, and empty states. Handles UX review, visual hierarchy, information architecture, cognitive load, accessibility, performance, responsive behavior, theming, anti-patterns, typography, fonts, spacing, layout, alignment, color, motion, micro-interactions, UX copy, error states, edge cases, i18n, and reusable design systems or tokens.
version: 4.3.1
license: Apache 2.0
---

Core methodology summary:
1. Two-round audit cycle: Round 1 (all states/platforms together, score & batch defects), Round 2 (consolidated fix batch, recapture only affected/required confirmations, report remaining gaps).
2. Diagnostic scan across 5 dimensions, 0-4 each (total 0-20 score):
   - Web: Accessibility (A11y), Performance, Theming, Responsive Design, Implementation Integrity.
   - Android: Accessibility (VoiceOver/TalkBack), Performance, Appearance & Theming, Platform Conformance, Adaptivity.
3. Health Score rating bands:
   - 18-20: Excellent (minor polish)
   - 14-17: Good (address weak dimensions)
   - 10-13: Acceptable (significant work needed)
   - 6-9: Poor (major overhaul)
   - 0-5: Critical (fundamental issues)
4. Defect severity tiers:
   - P0: Blocker (prevents task completion, fix immediately)
   - P1: Major / Critical (significant difficulty or WCAG AA / platform guideline violation, fix before release)
   - P2: Minor (annoyance, workaround exists, fix in next pass)
   - P3: Polish (nice-to-fix, no real user impact, fix if time permits)
5. Structured report output with executive summary, health scores, severity-counted findings, positive findings, evidence inventory, and explicit Unverified blockers.
