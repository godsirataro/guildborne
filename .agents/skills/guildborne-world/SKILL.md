---
name: guildborne-world
description: Build Guildborne city, personal guild zones, adventure maps, props, safe travel and environmental storytelling.
---

# Guildborne World

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Inspect AdventureMapKit, AdventurePropKit, CityInteriorKit and existing Blender city/region generators. Preserve current travel destination IDs, private plot ownership and safe-zone authority. Greybox routes and sightlines first; dress approved routes with modular kits rather than adding an empty giant continent. Make plaza/tavern/market/guild/tower/portal readable by shape, signage and paths. Test player plus five companions through doors, corners, stairs and respawns. Include server-validated Build Mode snapping, plot bounds, collision, cost/refund idempotency if modifying existing building systems. Decorative ambience must not use expensive independent pathfinding per prop. World streaming must tolerate missing client instances. Lighting supports character/combat readability without burying telegraphs in bloom/fog. Export reproducible recipes, source models, district graph, safe spawn/fallback data and screenshots. Do not overwrite all Workspace or silently publish maps.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
