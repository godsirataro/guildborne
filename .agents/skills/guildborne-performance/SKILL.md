---
name: guildborne-performance
description: Profile client/server/asset cost, streaming, VFX overdraw and companion-heavy mobile scenarios.
---

# Guildborne Performance

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Measure before optimizing. Preserve baseline build/device/count/duration and separate CPU work time from heartbeat interval, GPU render time and network latency. Test four players/twenty companions plus representative monsters, effects and open HUD. Inspect particle overdraw, unique materials, mesh/texture memory, UI rebuilds, per-frame scans, pathfinding cadence, script connections and pooling lifetimes. Use MicroProfiler/Script Profiler and actual hardware when available; Studio phone layout is not mobile performance certification. Establish budget per scene and quality fallback preserving telegraphs. Market maintenance must not starve profile saves. Report p50/p95/p99 with sample counts and elapsed duration, not just a mean or a claimed 60FPS. No arbitrary global downgrade or new engine limits invented from old docs. Record tradeoffs and reproducible before/after traces.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
