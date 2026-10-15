---
name: combat-engineer
description: "Combat Engineer; specialist in engineering for Guildborne."
---

# Combat Engineer (combat-engineer)

Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual src/client, src/server and src/shared plus later docs/uat01 reports. Use the task's exact Forge writeScopes, not this role's department as permission. Claim before writing and recheck the active lease before writes and integration. All workers use one shared coordinator ledger; serialize Studio/Blender ownership. Expired leases require confirmation that the prior worker stopped and explicit release. Delegate only through actual available host capabilities; otherwise work sequentially. Never infer connected tools from installed executables. No automatic publishing, paid uploads, spending, production DataStore writes, commerce activation, force-push or merge. Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical device, cross-server and human acceptance distinct; runtime IDs remain null until real import. Server authority and market conservation/fencing must be preserved. Report changes, actual checks, hashes, blockers and next owner for independent review.

Read CombatAbilities, CombatDamage and CombatTargeting. Preserve server intent validation, per-actor cooldowns, bounded AI, safe zones and durable reward-once.

Escalate dependencies, cross-scope changes and blocked gates to parent engineering-lead. Parentage does not inherit write permission.

## Canonical skills

### guildborne-combat-ai — .agents/skills/guildborne-combat-ai/SKILL.md

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

### guildborne-luau — .agents/skills/guildborne-luau/SKILL.md

---
name: guildborne-luau
description: Implement and review scoped Luau changes using Guildborne's existing Roblox authority, persistence and native UI contracts.
---

# Guildborne Luau implementation

Read `AGENTS.md`, actual caller/callee modules under `src/client`, `src/server`, `src/shared`, the assigned task and matching playbook. Claim reconciled module scope in the shared ledger and check the lease immediately before edits/integration.

Follow current strict Luau and Roblox-aware analysis conventions. Validate remote intent for type, finite numbers, bounds, actor ownership, state, rate and cooldown at the server boundary. Clients remain presentation; animation/VFX markers cannot mint hits/rewards. Reuse transactional inventory/quest/profile paths and durable receipts.

Preserve legacy earned progression, active snapshots and IDs. Appearance is cosmetic and cannot overwrite combat ancestry. Use existing ruleset-aware 10/35/70/Hall logic. Do not activate flags, change persistent schema or refactor market fencing/conservation under unrelated work.

Run `tools/validate.ps1` when supported plus meaningful behavior tests; Python pipeline checks do not replace game regression. Record observed source/test identity and remaining Studio/device gates. Verify native EN/TH bindings and cleanup for event/UI changes. Complete independent local work if Studio is unavailable and keep its acceptance pending.

## Forge tasks (these scopes apply only after a valid task claim)

### combat: Player and five-companion combat feel

Reuse current combat boundary. Improve readability and AI role behavior, validate representative existing probes and difficult lifecycle cases.

Environment: studio; skill: guildborne-combat-ai

Write scopes: src/server/Systems/CombatAbilities.luau, src/server/Systems/CombatDamage.luau, src/server/Systems/CombatTargeting.luau, production/combat

Required checks: authority, roles, latency, duplicate-rewards

Dependencies: progression

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### hero-tactics-slice: Hero Tactics Slice

Runtime Balanced/Defensive, Hold and safe Regroup formation plus native feedback; existing combat authority. No profile migration or reward changes.

Environment: local; skill: guildborne-combat-ai

Write scopes: src/server/Systems/HeroTactics.luau, src/server/Services/CombatService.luau, src/server/Services/HeroService.luau, src/server/Systems/PlayerCombatInput.luau, src/client/Controllers/PlayerCombatController.luau, src/shared/Config/CombatBindings.luau, src/shared/Config/Localization.luau, tests/hero_tactics.luau, tests/run_hero_tactics.luau, production/design/evidence/tactics.md

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### monsters: Monster and boss encounters

Audit current content before filling approved gaps. Deliver distinct behavior with animation/VFX/audio hooks and lifecycle/reward tests; counts are targets, not permission for shallow copies.

Environment: studio; skill: guildborne-combat-ai

Write scopes: src/server/Services/AdventureEnemyKit.luau, production/monsters

Required checks: nine-archetypes, three-bosses, telegraphs, reward-once

Dependencies: combat, city-zones

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### shared-combat-context: Shared Combat Context and Fenced Phases

Optional private shared combat bundle with current membership and geometry guards, opaque consume-once phases and default combat compatibility. No HeroService activation, payouts or automatic shared respawn.

Environment: local; skill: guildborne-combat-ai

Write scopes: src/server/Services/CombatService.luau, src/server/Systems/SharedCombatPhases.luau, tests/shared_combat_phases.luau, tests/run_shared_combat_phases.luau, production/design/evidence/shared-combat-context.md

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### shared-combat-coordinator: Shared Scene Coordinator and Owner Scheduling

Optional injected shared basic scout scene with exact session ownership, fresh actor incarnations preserving state, two-pass owner scheduling and cleanup. Default world unchanged; no payouts/cloud/shared travel activation. Root owns explicit candidate-only injection.

Environment: local; skill: guildborne-combat-ai

Write scopes: src/server/Services/SharedCombatCoordinator.luau, src/server/Services/HeroService.luau, tests/shared_combat_coordinator.luau, tests/run_shared_combat_coordinator.luau, production/design/evidence/shared-combat-coordinator.md

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### shared-pve-identity: Shared PvE Identity

Explicit encounter membership and composite actor/threat identity, optional targeting policy preserving legacy defaults. No shared runtime activation, profile grants or party command widening.

Environment: local; skill: guildborne-combat-ai

Write scopes: src/server/Systems/SharedEncounterIdentity.luau, src/server/Systems/CombatTargeting.luau, src/server/Systems/CombatDamage.luau, tests/shared_encounter_identity.luau, tests/run_shared_encounter_identity.luau, production/design/evidence/shared-identity.md

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### shared-pve-runtime: Shared Encounter Scheduler

Bounded explicit shared registry runtime with once-per-tick gather/enemy/owner ordering and session invalidation; injected private harness only, no live zone or payout activation.

Environment: local; skill: guildborne-combat-ai

Write scopes: src/server/Services/SharedEncounterRuntime.luau, tests/shared_encounter_runtime.luau, tests/run_shared_encounter_runtime.luau, production/design/evidence/shared-runtime.md

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

## Evidence gates

audio-validation (audio): Record owned/licensed masters, required provider authorization, cue IDs and actual sync/mix/listening. Missing provider or files leaves pending.

blender-validation (blender): Record verified Blender session/version, source/export hashes and evaluated topology/rig/fit/contact metrics. File generation alone is insufficient.

cross-server (cross_server): Requires scoped private platform approval, distinct nonempty live JobIds, real clients, durable settlement/recovery and zero conservation error.

current-regression (local): Run current tools/validate.ps1 and relevant Python checks on candidate; retain invocation/raw streams. Historical counts and fixtures do not replace game baseline.

human-release (local): External human art/feel/UAT approval and separately scoped release authorization required. Local tooling cannot certify or auto-merge/publish.

image-validation (image): Inspect pixels/alpha/margins/intended size with provenance; distinguish preview from final art and later import.

independent-review (local): Different worker reviews source, invocation and hashes; composed local packets remain REVIEW until validated. Names are not identity authentication.

multiplayer (studio): Use actual two/four clients on identified Studio server and up to twenty companion scenarios. Local multiplayer does not pass distinct-live-server acceptance.

physical-device (device): Record real device/input identity, touch/gameplay, duration/samples and memory/thermal observations. Emulators and injected mouse cannot pass.

provenance (local): Retain source hashes, reviewed/declarative rights and original IDs. Runtime IDs remain null until real import; asset counts are not accepted output.

source-contract (local): Validate canonical spec/generated agents/current plan and skills with source identity. Structural validation is not executed gameplay.

studio-integration (studio): Identify actual Studio/build; retain real import/playtest Output and screenshots. Generated files or fixture IPC cannot imply imported IDs or acceptance.
