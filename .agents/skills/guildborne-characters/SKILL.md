---
name: guildborne-characters
description: Create modular Human, Elf, Orc and Dwarf bodies, natural body/skin variants and shared player/hero appearance contracts.
---

# Guildborne Characters

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read production/character-kit-v1/README.md and the imported Shared Contract. Use exactly 15 visible R15 parts; root is invisible and separate. Keep clothing, hair, beard, ears, tusks, headwear, armor and weapons removable. Wizard is Human appearance, not a fifth race. Start Human Standard and Heavy plus one tunic/trousers/hair golden path. Expand to 13 presets and 20 palette options only after fit tests; inspect original IDs instead of inventing new prefixes. Neutral A/T reference pose, assembled export, separate exploded preview. Skin tint must not recolor eyes, teeth or garments. Body preset is authored geometry, not an assumed runtime Blender shape-key feature. A generated image is reference only. Use existing tools/blender_character_kit.py as a reviewed starting point, not proof that modular clothing already works. Preserve editable blend, report evaluated mesh counts and deformation. Cosmetic race/body must not silently change combat stats, reach, hitboxes or unlocks. No hidden nudity when garments are removed; keep non-exposing base coverage. Deliver actual source/export and an honest compatibility matrix.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
