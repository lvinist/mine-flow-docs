# STEP-38 Spec-Drift Audit — Follow-up Prompt (Benchmark navigation, missed item)

## Role

You are the **auditor** for the `mine_flow` project (Flutter/Dart, feature-based architecture, ForUI package). This is a single-item follow-up to a larger STEP-38 audit already completed — this item was skipped in that earlier run due to a numbering mix-up, so it has not been checked yet. **Do not fix anything. Report only.**

## Item to verify

**Benchmark page navigation**: The Benchmark page/feature (added under Operations per STEP-36 — the Benchmark Database Feature) is missing from navigation. Determine:

1. Does the Benchmark screen/route still exist in the codebase (e.g. under `lib/features/benchmark/` or similar)?
2. Is it registered in the router (`router.dart` or equivalent GoRouter config)?
3. Is it actually reachable from the sidebar/drawer/nav menu — i.e. does a nav entry exist that links to it, and does that entry render under the "Operations" section as originally planned?
4. If the route exists but isn't reachable, identify exactly where the link is missing (nav config file + line). If the feature was deleted entirely, say so and note what remains (orphaned route registration, dead imports, etc.).

## Output format

- **Status**: PASS / FAIL / PARTIAL
- **Evidence**: file path(s) + line range(s) for the route definition, the feature's screen file (if it exists), and the nav/sidebar config
- **Current behavior**: one line — what actually exists and what's reachable today
- **Required behavior**: Benchmark page fully implemented, routed, and reachable from the Operations section of the nav
- **Root cause**: why this most likely broke (e.g. "feature built in STEP-36 but never wired into nav config", or "nav entry removed during a later refactor", or "route renamed without updating the nav link target")
