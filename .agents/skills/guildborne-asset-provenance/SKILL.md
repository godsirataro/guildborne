---
name: guildborne-asset-provenance
description: Track source/export/runtime assets, original kit intake, compatibility and truthful acceptance states.
---

# Guildborne Asset Provenance

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Use the existing docs/uat01/intake registry as canonical where IDs already exist. Import original kit with a verified archive hash using import_character_kit.py; never execute supplied scripts during ingestion. Preserve 89 planned rows,13 body presets,20 palette entries and source naming rather than relabeling them all. Stable logical ID and content revision are separate; do not bake revision into a new semantic ID for each export. Record paths, sha256, origin, license status, fit targets, technical metrics and runtime ID nullable until actual import. Original/generator-produced does not automatically mean exclusive ownership; review provider terms. Validate image alpha/dimensions, 15-body count, equipment compatibility and provenance. Source, exported, imported, tested and human-approved are distinct facts. No planned asset may be promoted by a file merely existing. Preserve input archives/read-only specs; never reset user-updated status by rerunning a generator.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
