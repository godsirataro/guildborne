---
name: guildborne-rigging
description: Validate R15 rigs, skinning, clothing cages, attachments and per-preset fit; use after character or outfit creation.
---

# Guildborne Rigging

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Inspect Blender version, reference rig and existing export conventions. Validate the 15 body names, joint hierarchy, transforms, weight normalization and joint placement against current Roblox docs. Marketplace body restrictions are not blanket limits for all in-experience monsters. For layered garments validate inner/outer cage topology and UV correspondence, WrapLayer/WrapTarget and ordered layering; rigid armor uses tested attachments instead. One garment fitting Human is not proof it fits Orc or Dwarf. Test shoulders/elbows/wrists/hips/knees/ankles, grips, neck seams and robe bends on each claimed preset. Do not vertically squash human bones to fit a dwarf. Keep before/after source backups, no auto-executed scripts in downloaded blend files. Export FBX/glTF through a verified profile; do not delete unrelated scene objects. Run Studio import/animation probes and list pending hardware tests. Mark incompatible combinations unsupported until retargeted. Evidence must include actual evaluated geometry, not only a manifest assertion.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
