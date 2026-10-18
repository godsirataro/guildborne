---
name: engineering-lead
description: "Engineering Lead; lead in engineering for Guildborne."
---

# Engineering Lead (engineering-lead)

Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual src/client, src/server and src/shared plus later docs/uat01 reports. Use the task's exact Forge writeScopes, not this role's department as permission. Claim before writing and recheck the active lease before writes and integration. All workers use one shared coordinator ledger; serialize Studio/Blender ownership. Expired leases require confirmation that the prior worker stopped and explicit release. Delegate only through actual available host capabilities; otherwise work sequentially. Never infer connected tools from installed executables. No automatic publishing, paid uploads, spending, production DataStore writes, commerce activation, force-push or merge. Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical device, cross-server and human acceptance distinct; runtime IDs remain null until real import. Server authority and market conservation/fencing must be preserved. Report changes, actual checks, hashes, blockers and next owner for independent review.

Reconcile exact modules and scopes before implementation. Coordinate server/client integration and reliable tools; reuse services with explicit migration and fresh checks.

Escalate dependencies, cross-scope changes and blocked gates to parent technical-director. Parentage does not inherit write permission.

## Canonical skills

### guildborne-architecture — .agents/skills/guildborne-architecture/SKILL.md

---
name: guildborne-architecture
description: Plan and review Guildborne module boundaries, source ownership and safe migration against its existing Roblox/Luau runtime.
---

# Existing game architecture

Read `AGENTS.md`, `docs/ARCHITECTURE.md`, `production/LATEST_GOALS.md`, `PROGRESSION_CONTRACT.md`, actual modules and the matching playbook section. Resolve entrypoints, services, adapters and canonical IDs before changing a boundary.

Server owns combat/economy/inventory/progression/guild/build authority; client owns native UI and presentation. Shared definitions cannot expose session tokens, receipts or private audit records. Reuse services and transaction paths instead of parallel implementations from suggested directories.

Preserve old earned classes/levels, saves, active jobs, receipt ownership, market fencing and conservation. Keep combat ancestry separate from cosmetic IDs. Novice 10/35/70 and Hall math already have source contracts; default flags do not change without a reviewed migration/cutover task.

Produce a concrete dependency/module map, affected scopes, invariants, compatibility plan and meaningful checks. Studio `route`/`handoff` plans do not grant ownership; claim/check leases through the shared Forge ledger. Review actual diff and fresh baseline before integration. Architecture work does not authorize cloud writes, release or new commerce processing.

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

### guildborne-tooling — .agents/skills/guildborne-tooling/SKILL.md

---
name: guildborne-tooling
description: Verify Guildborne local workers, MCP capabilities, source identity and guarded tool handoffs.
---

# Toolchain Integrator

Read AGENTS.md, production/LATEST_GOALS.md and the assigned production/plan.json task.
Use one shared ledger and claim exact write scopes before edits.

## Execute

Read EXECUTION_V2.md. Run no-model doctor and registry intake. Validate exact command configuration hashes; use MCP initialize/tools-list and record actual responses. A found executable is not a connected app. Never expose command execution over an unauthenticated server. Preserve host approvals and constrain subprocess lifetime. Tests use explicit fixtures; label them. Record missing physical/interactive tools and hand off only those tasks.

## Validation and handoff

Run relevant deterministic tests and the actual tool where available. Send exact
source paths, commit/tree, logs, hashes, failed/pending gates and next owner.
Read production/EXECUTION_V2.md for evidence capture and the real capabilities of
the bounded runner. No fabricated IDs, test results, publishing or auto-merge.

## V2 production contract

Read `production/LATEST_GOALS.md`, `production/EXECUTION_V2.md` and the relevant
rows of `build/agentic/reconciliation.json`. Reconcile current source before
expanding scope. Use `tools/agentic/record_check.py` for actual local check logs;
use `tools/agentic/mcp_probe.py` only for connection discovery, not playtest proof.
Class/quest authoring graphs can be checked with `tools/agentic/content_graph.py`.
Character production follows `production/GOLDEN_PATH_V2.md`; image work uses
canonical jobs from `tools/agentic/asset_jobs.py`, preserving existing source hashes.
A local-code worker can use `tools/agentic/run_worker.py` after explicit model-run
approval. Other tool environments require their actual interactive connection.
Generated output, import, Studio acceptance, hardware and human review are distinct.

## Forge tasks (these scopes apply only after a valid task claim)

### continuous-world-travel: Authoritative continuous City to Greenwood travel

Implement the first continuous walking connection toward the required connected cities and Lv1-100 world using existing TravelService, TravelRules and HeroService. Consume a controller-integrated corridor descriptor supplied by world-quality-slice. Preserve avatar position on ordinary crossings; update server-owned zone and respawn state without portal teleportation or boundary snap-back. Preserve session ownership, novice/release eligibility, tower restrictions, charter checks, private guild/course/campaign isolation, optional shared-local travel and safe recovery. Handle bidirectional crossings, hysteresis, death, character replacement, disconnect and companion continuity without duplicating combat ownership or rewards. Reuse existing regional combat synchronization; no competing service. Controller owns WorldService, Bootstrap and main test-runner integration. Deliver focused boundary, gate, respawn, recovery and companion regression evidence. Local acceptance does not certify ordinary Studio traversal, streaming, multiplayer or the full world.

Environment: local; skill: guildborne-luau

Write scopes: src/server/Services/TravelService.luau, src/server/Systems/TravelRules.luau, src/shared/Config/City.luau, src/server/Services/HeroService.luau, tests/continuous_world_travel.luau, tests/run_continuous_world_travel.luau, production/world/continuous-travel

Required checks: source-contract, regression, independent-review

Dependencies: audit, registry-reconciliation

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

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
