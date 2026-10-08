---
name: guildborne-progression
description: Implement approved levels, class branches, skill/status points, respec, Hall caps and old-save migration.
---

# Guildborne Progression

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read production/PROGRESSION_CONTRACT.md and current configuration. Player starts Novice Lv1; Class1 Lv10, Class2 Lv35, Class3 Lv70 require quests; no Class4. New heroes start Lv10; recruit after Class1 plus main-story Hall unlock. Cap=min(100,20+5*(Hall-1)) for Hall>=1; Hall17 unlocks100, Hall18-20 add non-level benefits. Preserve previously earned levels/classes under migration. Separate race, rank, class tier, hero identity and progression. Skill/status points are per actor; respec refunds already-earned totals rather than granting a new budget. Proposed point formulas are design defaults pending balance audit, not an instruction to overwrite existing tuned data. Validate tree DAG, mutually-exclusive branches, rank costs, learn/equip/AI states and atomic apply. Class quests check the subject hero's level, not the owner's. Remove circular Hall/class/mainquest prerequisites. Deliver migration fixtures, before/after invariants, UI previews and actual route tests.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
