# Doc 07 — UI / Design System

**Version:** v0.1.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-17 (STEP-1.7)
**Audience:** All contributors — this sets the visual foundations, reusable UI components, and navigation patterns across all clients.

> Defines the core design system, component guidelines, and platform navigation patterns for the mine-flow application.

## Table of Contents
- [1. Design Principles](#1-design-principles)
- [2. Design Tokens](#2-design-tokens)
- [3. Components](#3-components)
- [4. Navigation & Layout](#4-navigation--layout)
- [5. System Capabilities](#5-system-capabilities)
- [6. Implementation Stack](#6-implementation-stack)
- [Decision Summary](#decision-summary)
- [Open Questions](#open-questions)
- [Version Log](#version-log)

## 1. Design Principles
- **Data-Dense & Minimalist:** Strips away unnecessary visual noise, padding, and borders to maximize the amount of data (tables, lists, metrics) visible on screen without sacrificing readability.
- **Modern & Professional:** Emulates top-tier web admin dashboards (like shadcn-admin) translated into a cross-platform context.

## 2. Design Tokens

### Color Palette: Forest & Stone
- **Primary / Brand:** Deep Forest Green (`#166534`). Used for primary actions, active navigation states, and highlights.
- **Grayscale (Stone):** Warm grays ranging from near-black text (`#292524`, `#44403c`) to muted borders/labels (`#78716c`, `#e7e5e4`) and off-white backgrounds (`#fafaf9`).
- **Semantic:** Standard semantic colors for status (e.g., Green `#15803d` on light green `#dcfce7` for success/passed checks).

### Typography
- **Primary UI Font:** **Inter**. Best-in-class readability for dense UI and small text on screens.
- **Monospace Font:** **Roboto Mono** or similar tabular font for displaying numbers in data tables to ensure decimal alignment.

### Spacing & Layout
- **Density:** **Compact**. A tighter base spacing unit (e.g., 4px/12px scale) to fit ~30% more data on screen while keeping touch targets large enough for field workers using mobile devices.

### Shape & Elevation
- **Rounded & Subtle:** 4px corner radius for cards and buttons. Very subtle 1px light borders (`#e7e5e4`) and faint drop shadows (`box-shadow: 0 1px 3px rgba(0,0,0,0.05)`). Keeps the UI highly structured but modern.

## 3. Components
- **Buttons:** Primary (solid Forest green), Secondary/Outline (Stone border, transparent background), Ghost (transparent).
- **Cards:** White background, 4px radius, subtle border. Used for dashboard metrics (e.g. Cut Volume) and grouping forms.
- **Inputs:** Outline style inputs with a 4px radius, adapting to the compact spacing scale.
- **Badges:** Small colored pills with rounded corners for statuses (e.g., Active, Passed).

## 4. Navigation & Layout
- **Web (Supervisors):** **Collapsible Left Sidebar**. Maximizes vertical space for data tables and dashboard metrics.
- **Android (Foremen):** **Bottom Tab Bar**. Highly ergonomic for one-handed use in the field.

## 5. System Capabilities
- **Theme Support:** **Both (Manual Toggle)**. The system implements both Light (default) and Dark modes, allowing the user to switch between them or inherit the OS system preference.
- **Responsive Strategy:** Adaptive layouts. Web relies on standard breakpoints for sidebar expansion; Android locks to portrait mobile.
- **Iconography:** **Lucide Icons** (or a Flutter equivalent) for clean, consistent line-art icons.
- **Accessibility:** Target **WCAG 2.1 AA** contrast (supported by Forest & Stone). UI responds to OS text scaling and reduced motion preferences.
- **Internationalization (i18n):** MVP ships **Indonesian (ID)** by default. All user-facing strings are routed through a localization layer from day one. No RTL support for MVP.
- **Motion:** Snappy and subtle (150-200ms fades). No heavy physics or bouncy animations.

## 6. Implementation Stack
- The design system will be implemented as a custom `ThemeData` object in Flutter, explicitly mapping the Forest & Stone colors, Inter typography, and 4px shape tokens.
- Platform conventions (e.g., Material ripple effects on Android) are handled natively by Flutter.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Design Principle | Data-Dense & Minimalist | Prioritizes data visibility on dashboards and field devices | Large, airy consumer-style layouts |
| 2 | Color Palette | Forest & Stone | Professional, subtly nods to earthworks/mining, maintains high contrast | Bright/playful color schemes |
| 3 | Typography | Inter | Specifically designed for dense, complex UIs on computer screens | OS-native fonts (Roboto/San Francisco) |
| 4 | Spacing Density | Compact | Fits more data without making touch targets impossible to hit | Standard/relaxed web spacing |
| 5 | Shape & Elevation | Rounded & Subtle (4px) | Matches modern admin dashboard aesthetics perfectly | Brutalist (0px) or highly bubbly (12px+) designs |
| 6 | Navigation Pattern | Sidebar (Web) + Tab Bar (Mobile) | Maximizes vertical space on desktop; optimizes for one-handed use on mobile | Top Nav on Web; Hamburger drawer on Mobile |
| 7 | Theme Support | Both (Manual Toggle + System) | Gives users flexibility for outdoor glare vs. low light | Shipping light-mode-only faster |
| 8 | Internationalization | Indonesian (ID), routed through strings | App uses Indonesian terms, but wrapping strings allows future translation | Hardcoded strings; RTL support |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
|    | None currently |       |            |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.7 | Initial draft from UI / Design System session |
