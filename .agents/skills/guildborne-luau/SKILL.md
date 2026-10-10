---
name: guildborne-luau
description: Implement and review scoped Luau changes using Guildborne's existing Roblox authority, persistence and native UI contracts.
---

# Guildborne Luau implementation

Read `AGENTS.md`, actual caller/callee modules under `src/client`, `src/server`, `src/shared`, the assigned task and matching playbook. Claim reconciled module scope in the shared ledger and check the lease immediately before edits/integration.

Follow current strict Luau and Roblox-aware analysis conventions. Validate remote intent for type, finite numbers, bounds, actor ownership, state, rate and cooldown at the server boundary. Clients remain presentation; animation/VFX markers cannot mint hits/rewards. Reuse transactional inventory/quest/profile paths and durable receipts.

Preserve legacy earned progression, active snapshots and IDs. Appearance is cosmetic and cannot overwrite combat ancestry. Use existing ruleset-aware 10/35/70/Hall logic. Do not activate flags, change persistent schema or refactor market fencing/conservation under unrelated work.

Run `tools/validate.ps1` when supported plus meaningful behavior tests; Python pipeline checks do not replace game regression. Record observed source/test identity and remaining Studio/device gates. Verify native EN/TH bindings and cleanup for event/UI changes. Complete independent local work if Studio is unavailable and keep its acceptance pending.
