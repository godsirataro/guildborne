---
name: guildborne-animation
description: Author natural locomotion, attacks, spell casts, monster/boss states and animation-marker contracts.
---

# Guildborne Animation

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Inspect current animation controllers and rigs; preserve working clips. Define anticipation, active action, impact, recovery, cancel windows and transitions per ability. Place semantic markers for cast, projectile release, impact, footstep and recovery. Server combat owns hit timing/results; client animation markers are presentation cues, not permission to deal damage. Correct foot sliding, grip drift, body clipping, blend priorities, turn behavior and weight transfer before adding flourish. Bake only approved bones, verify loops/end pose and test representative Human/Orc/Dwarf bodies. Five companion attacks need staggered readable motion without changing server cooldowns. Use authored source clips, approved mocap with provenance or procedural previews clearly labeled; image sequences are not skeleton animation. Avoid global time-freeze to simulate hit stop in multiplayer. Deliver clips, marker manifest, source/export hashes and in-game motion evidence; missing upload permission leaves runtime IDs null.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
