# Doc 07 — UI / Design System

**Version:** v0.3.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-07-29 (STEP-39.2)
**Audience:** All contributors — this sets the visual foundations, reusable UI components, and navigation patterns across all clients.

> Defines the core design system, component guidelines, and platform navigation patterns for the mine-flow application.

## 1. Design Principles
- **Data-Dense & Minimalist:** Strips away unnecessary visual noise, padding, and borders to maximize the amount of data (tables, lists, metrics) visible on screen without sacrificing readability.
- **Modern & Professional:** Emulates top-tier web admin dashboards (like shadcn-admin) translated into a cross-platform context using ForUI widgets and theme structure.

## 2. Design Tokens

### Color Palette: ForUI Zinc (`FThemes.zinc`)
- **Canonical Theme:** Standard Zinc palette from the `forui` package (`FThemes.zinc` for light mode and `FThemes.zinc.dark` for dark mode) with no brand color overrides.
- **Replacement:** Custom `ThemeData` definitions and legacy color schemes (e.g. Forest & Stone) are completely replaced by ForUI defaults.
- **Grayscale & Accent:** Clean, neutral zinc grays for surfaces, cards, and borders with crisp high-contrast text and standard semantic feedback tokens.

### Typography
- **Primary UI Font:** **Geist** (or default ForUI typography stack). Best-in-class readability for dense UI and small text on screens.
- **Monospace Font:** **Roboto Mono** or similar tabular font for displaying numbers in data tables to ensure decimal alignment.

### Spacing & Layout
- **Density:** **Compact**. Employs ForUI spacing tokens with a tighter base spacing scale to fit data on screen while keeping touch targets accessible for field workers using mobile devices.

### Shape & Elevation
- **Rounded & Subtle:** ForUI standard border radii and subtle 1px borders. Maintains structural, modern card and form element framing without visual clutter.

## 3. Components
- **Framework Widgets:** ForUI widgets (`FButton`, `FCard`, `FTextField`, `FBadge`, `FSelect`, etc.) are used across all screens.
- **Buttons:** ForUI buttons (primary, secondary, outline, ghost).
- **Cards:** ForUI cards with 1px border surfaces used for dashboard metrics and grouped form sections.
- **Inputs:** ForUI outline input fields adhering to compact spacing.
- **Badges:** ForUI status badges and pills.

## 4. Navigation & Layout
- **Web (Supervisors):** **Collapsible Left Sidebar**. Maximizes vertical space for data tables and dashboard metrics.
- **Android (Foremen):** **Bottom Tab Bar with 5 items**. Highly ergonomic for one-handed use in the field, keeping all primary workflows permanently visible.

## 5. System Capabilities
- **Theme Support:** **Both (Manual Toggle + System)**. Powered by ForUI's `FTheme` wrapper supporting light mode (`FThemes.zinc`) and dark mode (`FThemes.zinc.dark`).
- **Responsive Strategy:** Adaptive layouts. Web relies on standard breakpoints for sidebar expansion; Android locks to portrait mobile.
- **Iconography:** **Lucide Icons** (via `forui` / Flutter lucide icons) for clean, consistent line-art icons.
- **Accessibility:** Target **WCAG 2.1 AA** contrast supported out-of-the-box by ForUI Zinc theme. UI responds to OS text scaling and reduced motion preferences.
- **Internationalization (i18n):** MVP ships **Indonesian (ID)** by default. All user-facing strings are routed through a localization layer from day one. No RTL support for MVP.
- **Motion:** Snappy and subtle (150-200ms fades). No heavy physics or bouncy animations.

## 6. Implementation Stack
- The design system is implemented using the **`forui`** package in Flutter.
- Standard custom `ThemeData` objects are replaced by `FTheme` and `FThemes.zinc` / `FThemes.zinc.dark`.
- Platform conventions (e.g., Material ripple effects on Android) are managed cleanly via ForUI and Flutter integrations.

## Decision Summary

| # | Decision | Choice | Rationale | Forecloses / tradeoff |
|---|----------|--------|-----------|-----------------------|
| 1 | Design Principle | Data-Dense & Minimalist | Prioritizes data visibility on dashboards and field devices | Large, airy consumer-style layouts |
| 2 | Color Palette | ForUI Zinc (`FThemes.zinc`) | Standardized shadcn-inspired widget theme; replaces custom `ThemeData` | Custom brand color overrides & legacy Forest & Stone |
| 3 | Typography | Geist | Specifically designed for dense, complex UIs on computer screens | OS-native fonts (Roboto/San Francisco) and Inter |
| 4 | Spacing Density | Compact | Fits more data without making touch targets impossible to hit | Standard/relaxed web spacing |
| 5 | Shape & Elevation | ForUI Standard Borders & Surfaces | Matches modern shadcn-admin aesthetic out of the box | Brutalist (0px) or highly bubbly (12px+) designs |
| 6 | Navigation Pattern | Sidebar (Web) + Tab Bar with 5 visible items (Mobile) | Maximizes vertical space on desktop; optimizes for one-handed use on mobile without burying primary items | Top Nav on Web; Hamburger drawer on Mobile |
| 7 | Theme Support | Both (`FThemes.zinc` / `zinc.dark`) | Gives users flexibility for outdoor glare vs. low light | Light-mode-only |
| 8 | Internationalization | Indonesian (ID), routed through strings | App uses Indonesian terms, but wrapping strings allows future translation | Hardcoded strings; RTL support |

## Open Questions

| ID | Question | Owner | Feeds into |
|----|----------|-------|------------|
|    | None currently |       |            |

## Version Log

| Version | Date | STEP | Change |
|---------|------|------|--------|
| v0.1.0 | 2026-07-17 | STEP-1.7 | Initial draft from UI / Design System session |
| v0.2.0 | 2026-07-22 | STEP-29.1 | Reconciled UI design system to specify ForUI package + FThemes.zinc (default, no brand override) replacing custom ThemeData |
| v0.3.0 | 2026-07-29 | STEP-39.2 | Formalized UI drift: Approved Geist font and 5 visible mobile navigation items (ADR-0009) |
