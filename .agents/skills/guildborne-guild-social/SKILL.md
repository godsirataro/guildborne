---
name: guildborne-guild-social
description: Build player guilds, roles, invitations, guild quests, shared bases and bounded guild-war foundations.
---

# Guildborne Guild Social

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Personal Guild Hall/zone and multiplayer Player Guild are different ownership domains. Inspect current guild IDs, membership invariants and test helpers before writing. Design create/join/invite/apply/leave/kick/leadership transfer with explicit permissions, capacity, idempotency and offline recovery. Use Roblox-supported text filtering for user-generated names/descriptions; never bypass platform chat. Preview custom banners from approved emblem pieces before freeform uploads. Guild treasury/research/war/territory is separate scope with conservation and permissions tests, not a hidden side effect of guild creation. Main progression must remain playable without joining a player guild. Shared build zones need role/plot bounds and server collision/cost checks. Social UX includes muted/blocked, unavailable and permission-denied states. A small no-reward scrimmage is not certification for 30v30 war. Deliver genuine cooperative loops and multi-client isolation evidence; no unreviewed player tracking.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.
