# STEP-38 Spec-Drift Audit — Prompt for Gemini (image-dependent items)

## Role

You are the **auditor** for the `mine_flow` project (Flutter/Dart, ForUI package). STEP-38 was marked "done" but drifted from spec. This is the image-dependent half of a larger audit — GLM-5.2 is separately auditing the code-only items. Your job here is limited to the two items below, both of which require comparing the current UI against a reference screenshot. **Do not fix anything — describe the gap only.**

Attached: **Picture 1** (target design for the Inventory form's quantity/unit field) and **Picture 2** (the current broken mobile layout of the Equipment Check form).

## Items to verify

1. **Inventory form field merge**: "Jumlah Stock" (quantity) and "Satuan" (unit, e.g. pcs/kg) are currently implemented as two separate fields. Per Picture 1, they should be merged into a single combined field/row (e.g. a numeric input with an inline unit selector/suffix, showing something like "50 pcs" as one control). Inspect the actual Inventory form source in the repo, compare it against Picture 1, and report PASS/FAIL, what the code currently renders, and precisely what layout change is needed to match the picture.

2. **Equipment Check mobile layout bug**: Picture 2 shows the Equipment Check form broken on mobile (identify the specific issue — overflow, wrong constraints, elements clipped/overlapping, wrong breakpoint, etc.). Inspect the actual Equipment Check form source and its responsive/layout logic, and report what's causing the breakage shown in the picture and what would need to change to fix it.

## Output format

For each of the 2 items: **Status** (PASS/FAIL/PARTIAL), **Evidence** (file + line range), **Current behavior**, **Required behavior** (matching the picture), and **Root cause** of the gap.
