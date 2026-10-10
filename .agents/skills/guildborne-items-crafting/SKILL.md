---
name: guildborne-items-crafting
description: Design and implement items, inventory, equipment, gathering, crafting and resource sinks.
---

# Guildborne Items Crafting

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Use actual item IDs, equipped-instance ownership and current inventory UI. Keep material stacks versus unique equipment explicit. Craft input reservation, output grant, gathering grants and sale refunds are authoritative and idempotent. Never trade equipped/bound items unless the approved system intentionally supports it. Recipes define deterministic costs/outcomes and source/sink accounting before adding randomness. Support full bag, partial quantities, stale ownership, duplicate click, service failure and reconnect. Compare real derived stats without granting them from UI. Generate item art from verified weapon/item models, not arbitrary imagined screenshots. Profession progression should have accessible guaranteed material paths. Preserve marketplace allowlist and receipt logic. Balance against existing economy and simulate affordability; no automatic Gold/Robux conversion. Deliver recipes/catalog binding, asset IDs only when real, tests and complete gather-craft-equip loop.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
