# STEP-55 Design Review Capture Matrix — Android — 2026-10-08

**Head:** `6e0b2e2` (app repo, `step-0055-cohesive-ui-rebuild`, == origin)
**Captured:** CI run `37682414334` (Android emulator leg, `sdk_gphone64_x86_64` API 33), artifact `android-screenshots` (11510907569, 3,048,821 bytes)
**Source test:** `integration_test/design_review_capture_test.dart`
**Run conclusion:** success — all jobs green (Lint/analyze & test, E2E Web, E2E Android, Build Android APK).

## Result

**25 / 25 expected capture cells produced valid PNGs. Zero placeholder-sized files.**
All 25 files carry PNG magic bytes; sizes 68,135–223,573 bytes (no 68-byte placeholder
regression — the RESIDUAL-3 takeScreenshot stall stays fixed).

| Breakpoint | Expected | Produced |
|---|---:|---:|
| phone (400×800) | 24 | 24 |
| login (phone, light, en) | 1 | 1 |

Doc 07 ("Android locks to portrait mobile"): Android's matrix is the phone leg only;
tablet/desktop are a web concern (see `2026-10-07-web-matrix-index.md` for the 73/73 web set).

Each non-login cell is `android-<screen>-phone-<theme>-<locale>` across 6 screens
(dashboard, daily-log, daily-log-form, operations, teams, tools) × 2 themes × 2 locales.

## Run provenance

This is the first Android capture leg of run `37682414334` and the second consecutive
Android leg with a full valid set (run `37535200023` at `1486826` also produced 25 valid
PNGs, 3,033,193-byte artifact). The captures came from the CI emulator rather than a local
run; the `6e0b2e2` fixture fix (equipment-journey barrier poll) does not touch the capture
harness, so the capture evidence at this head is unaffected by it.

## What this evidence can and cannot support

**Can support:** every named screen renders without crash at the portrait-phone breakpoint,
in both themes, in both locales, on Android; each capture is a real rasterized frame of the
correct route (the test asserts all 25 expected names and exits nonzero otherwise).

**Cannot support:** visual contrast measurements, hit-target sizing, keyboard/focus order,
IME behaviour, reduced-motion, cold-start/refresh behaviour, or screen-reader semantics.
Those remain **Unverified** and must not be inferred from a green screenshot. Widget-level
and journey-level runtime semantics evidence for the four FCs comes from the committed
test suites (99cb8b7), not from these captures.

## Files

All captures live in `android/` alongside this index. Naming:
`android-<screen>-phone-<theme>-<locale>.png`, plus `android-login-phone-light-en.png`.
