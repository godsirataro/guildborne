---
name: guildborne-combat-ai
description: Implement and refine authoritative player/hero combat, skills, companion AI, monsters and boss encounters.
---

# Guildborne Combat Ai

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Inspect existing combat services, attack timing and tests. Validate action intent, identity, ownership, target, range/line of sight, alive state, resources and server cooldowns. Never expose generic DealDamage or GiveReward remotes. Keep companion formation, leash, stuck recovery, threat, taunt, ranged spacing and healer selection explicit. Design enemy behaviors with meaningful differences: flanker, guard, ranged harasser, healer, charger, caster and boss phase mechanics, not just recolors. Bosses telegraph fairly and have interruption/recovery rules. Matchmaking, PvP and large guild war require separate bounded test tasks. Avoid per-frame full-world scans and path recomputation; use budgets/central scheduling. Reconcile damage/projectile visuals under latency without trusting client effects. Test duplicate deaths/rewards, respawn, ownership, simultaneous parties and loss of target. Preserve old 600-sample companion probe where present; verify actual test counts.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
