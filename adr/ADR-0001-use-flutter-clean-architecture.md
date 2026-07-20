# ADR-0001: Use Flutter with Clean Architecture

**Status:** Accepted
**Date:** 2026-07-18

## Related documents
- architecture/01-system-overview.md
- architecture/03-architecture-overview.md
- architecture/15-native-app-architecture.md

## Context
The mine-flow MVP needs to run on Android for field foremen and Web for office supervisors. As a solo developer side-project with a 1-month timeline, building separate native apps for each platform is unfeasible. We need a cross-platform framework that can handle offline data syncing and responsive design.

## Decision
1. **Use Flutter:** We will use Flutter to build a single codebase targeting Android and Web for the MVP, while preserving iOS and Desktop for future phases.
   - **Rationale:** Flutter provides excellent cross-platform performance, rich UI capabilities, and a single language (Dart) to master.
   - **Alternatives:** React Native (less consistent UI across platforms), Progressive Web App (weaker offline capabilities on Android).
   - **Reversibility:** High. A rewrite would be required to change frameworks.

2. **Use Clean Architecture with BLoC:** The app will be structured using Clean Architecture (Presentation, Domain, Data layers) and BLoC for state management.
   - **Rationale:** Decouples UI from business logic, making the complex offline sync logic testable and maintainable.

## Consequences
- **Easier:** Shipping to both Android and Web simultaneously. Testing business logic in isolation.
- **Harder:** Initial setup of Clean Architecture adds boilerplate. Flutter Web can be heavy and requires careful performance tuning compared to traditional HTML/JS.
