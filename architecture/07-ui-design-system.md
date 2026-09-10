# Doc 07 — UI / Design System

**Version:** v0.5.0
**Status:** Draft        <!-- Draft (v0.x) → MVP (v1.x) → Stable (v2.x); see METHOD.md §6 -->
**Last updated:** 2026-09-11 (STEP-54.11)
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
- **Semantic status:** Success, warning, destructive, pending, and informational states use a shared app-level mapping onto theme tokens. A status must pair color with an icon, label, or shape; warning must not fall back to a neutral secondary token, and distinct business states (for example present vs. leave, or out-of-stock vs. reorder-warning) must remain distinguishable without color.

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
- **Data filters:** Prefer one compact, labelled popover/menu that groups the page's filter criteria and provides Apply/Reset actions. Do not use a persistent row of selectable pills as the primary filter control. Pills are reserved for concise active-filter summaries and one-step removal after filters are applied.
- **Date selection:** Open single-date and date-range calendars in an in-context dialog over the current page or sheet. Date selection must not navigate to or spawn a full calendar page; Cancel retains the previous value and Apply returns focus to the invoking field.

## 4. Navigation & Layout
- **Web (Supervisors):** **Collapsible Left Sidebar**. Maximizes vertical space for data tables and dashboard metrics.
- **Android (Foremen):** **Bottom Tab Bar with 5 items**. Highly ergonomic for one-handed use in the field, keeping all primary workflows permanently visible.
- **Responsive breakpoint:** The canonical wide/narrow layout boundary is **800dp**. Tests exercise immediately below, at, and immediately above the boundary; wide layouts use the desktop shell and narrow layouts use the mobile shell.
- **Breadcrumbs:** Authenticated desktop pages use canonical, navigable breadcrumbs: Dashboard → group → feature → current surface. Ancestors are keyboard/AT-operable links, the current page is marked current, raw IDs/route tokens are hidden, and compact overflow preserves navigation on constrained widths.
- **Authenticated identity:** The global header profile is bound to the signed-in user's real name and localized role and matches Settings. It must not display a hardcoded or invented identity after authentication.

### 4.1 Form and inspector surfaces
- **Web forms:** Open as a modal right-side sheet, 480–600dp wide. The left sidebar remains visible; a dimmed scrim blocks interaction with the background.
- **Mobile forms:** Open as a modal, draggable bottom sheet with bounded internal scrolling and keyboard-inset handling.
- **URL synchronization:** Opening a create, edit, or inspector sheet updates the GoRouter URL. Create routes carry reconstructable context in path/query parameters; edit/detail routes carry a stable record ID. Browser refresh, back/forward, Android back, and direct links reconstruct the same surface without relying on transient `extra` objects.
- **Dirty dismissal:** Every close button, scrim tap, Escape key, browser navigation, and Android back gesture passes through one dirty-state guard. A dirty form presents a confirmation with **“Lanjut Mengedit”** (cancel dismissal and retain input) and **“Buang Perubahan”** (discard and close). Clean or successfully saved forms close directly.
- **Detail pattern (D7):** Use a read-only inspector when users need to review complex, safety-sensitive, comparative, or historical data before editing. On Web it uses the right-side sheet; on Mobile it normally uses the bottom sheet, except long checklist histories may use a URL-backed full page. Simple scalar records may open the edit sheet directly. Every inspector provides an explicit Edit action rather than making the read-only surface implicitly editable.

### 4.2 Contextual reports and dialogs
- A feature's **Buat Laporan** action opens an `FDialog` over the current list, pre-bound to that feature's `ReportType` and initialized from its active filters. Closing the dialog returns to the unchanged list position and filters.
- A report action is omitted when no meaningful report type exists; absence is a deliberate per-feature decision, not a placeholder route.
- Confirmation and focused adjustment flows use a single `FDialog` surface. Do not nest an `FAlert` as a second chrome container inside a dialog unless the alert conveys a distinct in-dialog state.
- The full route inventory, per-feature D7 decisions, report inventory, and implementation acceptance criteria live in [`reports/2026-09-11-step-54-master-polish-spec.md`](../reports/2026-09-11-step-54-master-polish-spec.md).

## 5. System Capabilities
- **Theme Support:** **Both (Manual Toggle + System)**. Powered by ForUI's `FTheme` wrapper supporting light mode (`FThemes.zinc`) and dark mode (`FThemes.zinc.dark`).
- **Responsive Strategy:** Adaptive layouts. Web relies on standard breakpoints for sidebar expansion; Android locks to portrait mobile.
- **Iconography:** **Lucide Icons** (via `forui` / Flutter lucide icons) for clean, consistent line-art icons.
- **Accessibility:** Target **WCAG 2.1 AA** contrast supported out-of-the-box by ForUI Zinc theme. UI responds to OS text scaling and reduced motion preferences.
- **Target size and semantics:** Interactive targets are at least **48×48dp** on mobile. Navigation, headings, fields, controls, dialogs, and status changes expose meaningful accessible names, roles, states, and traversal order at runtime; source `Semantics` wrappers alone are not acceptance evidence.
- **Internationalization (i18n):** MVP ships **Indonesian (ID)** by default. Locale selection works, and an `AppLocalizations` delegate exists as a minimal scaffold at `lib/l10n/`, but full screen-by-screen string migration remains incomplete. No RTL support for MVP.
> **Phase 3 status (STEP-41.3):** The `AppLocalizations` scaffold (`l10n.yaml`, baseline ARB
> files, generated delegate) was established. Full migration of the ~27 legacy presentation
> files is tracked as RISK-0004 and must be completed before a public multi-language release.
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
| 9 | Responsive boundary | 800dp wide/narrow split | Matches the shared shell contract and gives one testable boundary | Per-feature breakpoint drift |
| 10 | Form presentation | URL-backed right sheet (Web) / bottom sheet (Mobile) with modal scrim and universal dirty guard | Preserves list context while keeping browser and Android navigation predictable | Full-page forms and transient-only route state |
| 11 | Reports | Contextual, pre-bound `FDialog` | Preserves filters and list state | Standalone report configuration navigation |
| 12 | Details | Per-feature read-only inspector decision | Separates safe inspection from editing where complexity or history justifies it | One universal detail-page pattern |
| 13 | Data filtering | Grouped popover/menu first; active pills only after selection | Keeps data-dense lists compact and avoids horizontal chip overflow | Persistent option-pill rows as the main filter UI |
| 14 | Calendar selection | In-context calendar dialog | Preserves page/form state and keeps date selection focused | Full calendar pages or route transitions for picking dates |
| 15 | Breadcrumbs | Canonical navigable ancestors + non-interactive current page | Makes hierarchy useful for navigation and accessible orientation | Display-only text generated from raw URL segments |
| 16 | Header identity | Authenticated name and localized role | Keeps global identity truthful and consistent with Settings | Hardcoded `Pengguna` / `Foreman` profile copy |

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
| v0.3.1 | 2026-08-06 | STEP-41.3 | Established minimal l10n scaffold (l10n.yaml, ARB baseline, AppLocalizations delegate). Full string migration deferred to a future STEP. |
| v0.4.0 | 2026-08-08 | STEP-41.5 | Added Phase 3 localization scaffold status note (ISSUE-10 audit fix). |
| v0.5.0 | 2026-09-11 | STEP-54.11 | Canonized the 800dp breakpoint; responsive form/inspector sheets, URL reconstruction, universal dirty-dismiss guard, contextual report dialogs, per-feature D7 detail pattern, popover-first data filters, dialog calendars, navigable breadcrumbs, authenticated header identity, semantic statuses, and the runtime accessibility bar. Detailed implementation contract remains in the STEP-54 master polish specification. |
