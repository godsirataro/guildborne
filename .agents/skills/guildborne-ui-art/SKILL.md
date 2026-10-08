---
name: guildborne-ui-art
description: Produce original Guildborne logo, icons, panels, atlases and image assets; distinguish generated files from concept requests.
---

# Guildborne Ui Art

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read production/ART_BIBLE.md and current asset registry. Build a reference-locked batch of small related assets instead of one giant sheet. Original Guildborne crest, semantic navigation icons, class/skill icons, quest markers, item frames, shop cards and system states share visual rules. Use an available image tool only after confirming access and cost authorization. If absent, generate deterministic placeholders with generate_primitives.py and mark them procedural-preview, never final AI art. Use true alpha, consistent padding and 9-slice metadata; separate text/prices/rates from decoration. Reuse tintable neutral masks. Check at actual 48/64/96 pixel icon sizes and on light/dark backgrounds. Prefer model-derived item/hero portraits to misleading concept art. No copyrighted competitor imagery or redistributed fonts. Record provider/tool, input references, revision, source/export paths, checksum and license status. Asset IDs remain null until verified import. Deliver image files plus manifest and comparison evidence, not screenshots of an imagined UI.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
