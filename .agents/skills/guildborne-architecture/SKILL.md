---
name: guildborne-architecture
description: Plan and review Guildborne module boundaries, source ownership and safe migration against its existing Roblox/Luau runtime.
---

# Existing game architecture

Read `AGENTS.md`, `docs/ARCHITECTURE.md`, `production/LATEST_GOALS.md`, `PROGRESSION_CONTRACT.md`, actual modules and the matching playbook section. Resolve entrypoints, services, adapters and canonical IDs before changing a boundary.

Server owns combat/economy/inventory/progression/guild/build authority; client owns native UI and presentation. Shared definitions cannot expose session tokens, receipts or private audit records. Reuse services and transaction paths instead of parallel implementations from suggested directories.

Preserve old earned classes/levels, saves, active jobs, receipt ownership, market fencing and conservation. Keep combat ancestry separate from cosmetic IDs. Novice 10/35/70 and Hall math already have source contracts; default flags do not change without a reviewed migration/cutover task.

Produce a concrete dependency/module map, affected scopes, invariants, compatibility plan and meaningful checks. Studio `route`/`handoff` plans do not grant ownership; claim/check leases through the shared Forge ledger. Review actual diff and fresh baseline before integration. Architecture work does not authorize cloud writes, release or new commerce processing.
