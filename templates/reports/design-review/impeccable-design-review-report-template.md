# mine-flow — STEP-{{NNNN}} Impeccable Design Review

**Date:** {{YYYY-MM-DD}}
**Review scope:** {{screen(s), workflow(s), and target roles}}
**Related STEP:** STEP-{{N}} / {{standalone Design Review STEP}}
**Reviewed revision(s):** {{repo@commit list}}
**Runbook:** `runbooks/impeccable-design-review.md`
**Canonical UI contract:** `architecture/07-ui-design-system.md` v{{version}}
**Runtime evidence:** {{screenshot/recording path(s), platform/device/browser, or explicit unavailable reason}}

> This report records runtime design evidence. A static code inspection, passing analyzer, or
> widget test alone is not visual verification.

## Review coverage

| Surface / workflow | Role / fixture | Platform and viewport | States exercised | Evidence | Result |
|---|---|---|---|---|---|
| {{e.g., Attendance form}} | {{Foreman test account}} | {{Android, 360×800}} | {{default, validation, save, error}} | {{path/link}} | {{Verified / Unverified / finding IDs}} |

## Contract and bridge parity

| Check | Evidence | Result | Action |
|---|---|---|---|
| Doc 07 and relevant ADRs read | {{versions/paths}} | {{aligned / conflict}} | {{none / finding}} |
| `DESIGN.md` generated from Doc 07 | {{comparison or generation evidence}} | {{aligned / stale / unverified}} | {{none / regenerate bridge}} |
| `PRODUCT.md` generated from Doc 07 | {{comparison or generation evidence}} | {{aligned / stale / unverified}} | {{none / regenerate bridge}} |
| Active STEP requirements align with design contract | {{PLAN + citations}} | {{aligned / conflict}} | {{none / finding}} |

## Findings

| ID | Verdict | Area | Requirement / expected behavior | Runtime evidence | Impact | Throughstone treatment | Owner / follow-up |
|---|---|---|---|---|---|---|---|
| DR-{{NNNN}} | {{Verified / Blocking / Needs remediation / Approved deviation / Unverified}} | {{layout / responsive / component / a11y / interaction / theme / localization}} | {{contract citation and concise expectation}} | {{screenshot, recording, interaction steps, or unavailable reason}} | {{user/business impact}} | {{fix / ADR+Doc update / bridge regen / test gap / risk / none}} | {{owner, STEP or substep}} |

## Verification record

| Category | What was checked | Result / evidence | Limitation |
|---|---|---|---|
| Information hierarchy and density | {{key data/actions}} | {{result}} | {{none / limitation}} |
| Mobile/responsive layout | {{narrow viewport}} | {{result}} | {{none / limitation}} |
| Desktop/sidebar layout | {{wide viewport}} | {{result}} | {{none / limitation}} |
| Theme and token consistency | {{light/dark, ForUI/semantic tokens}} | {{result}} | {{none / limitation}} |
| Interaction and navigation | {{touch, click, keyboard, back}} | {{result}} | {{none / limitation}} |
| Accessibility | {{focus, semantics, scaling, contrast}} | {{result}} | {{none / limitation}} |
| Localization | {{Indonesian strings/localization path}} | {{result}} | {{none / limitation}} |
| Automated gate | `{{exact command}}` | {{exit code, counts}} | {{none / limitation}} |

## Decision and next action

**Review outcome:** {{accepted / remediation required / intentionally deviated / incomplete runtime evidence}}

**Closure rule:** {{No Blocking or Unverified results remain, OR list the remediation STEP(s) required before the parent STEP/release may close.}}

**Next action from disk:** {{Run substep / remediation STEP / regenerate bridge / archive review.}}
