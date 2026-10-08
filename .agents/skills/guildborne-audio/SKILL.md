---
name: guildborne-audio
description: Create original UI/combat/world audio cue contracts, spatial mix and natural animation synchronization.
---

# Guildborne Audio

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Audit existing sounds and authored assets with provenance. Separate UI, player feedback, spatial combat, ambience, music and dialogue buses. Build event-level cue variants, concurrency limits, priority ducking and fallbacks for missing asset IDs. Sync release/impact/footsteps to verified animation/server event timing. Keep boss warnings intelligible among five companions and multiplayer fights. Prevent per-frame sound creation and infinitely looping orphan emitters. Use available generation providers only with explicit budget/rights; synthetic placeholders remain labeled. Do not imitate a real person's voice or use unlicensed tracks. Save lossless master, runtime export, cue manifest, loop points and loudness/mix notes. Test zero audio, spatial distance, mobile speakers/headphones and accessibility equivalents. Never infer audio quality from text alone.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
