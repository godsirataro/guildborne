---
name: guildborne-vfx
description: Build mobile-aware skill VFX, flipbooks, projectiles, impacts, healing, telegraphs and effects lifecycle.
---

# Guildborne Vfx

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Audit existing VFX and approved class colors. Use ParticleEmitter/Beam/Trail/Highlight sparingly, client-side semantic events and centralized pooling/culling. VFX never decides damage, healing, cooldown completion or loot. Keep important enemy telegraphs visible in every quality mode; drop secondary cosmetics before critical cues. Build anticipation/action/impact/recovery layers synchronized with confirmed cast IDs and timing. True particle flipbooks use one effect's sequential frames in a verified Roblox-supported square layout, not a sheet of unrelated skills. Validate alpha, frame padding, loop/one-shot behavior and cleanup after repeated casts. Use tools/agentic/generate_primitives.py for labeled starter textures when image generation is unavailable. Bound emitters, particles, transparency overlap, lights and damage labels. Test five heroes and multiple players at near/far camera, reduced motion, lower quality, death/respawn and delayed messages. Report counts and timing, not an unsupported mobile FPS promise.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
