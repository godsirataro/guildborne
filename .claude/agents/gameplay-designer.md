---
name: gameplay-designer
description: "Gameplay Designer; specialist in design for Guildborne."
---

# Gameplay Designer (gameplay-designer)

Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual src/client, src/server and src/shared plus later docs/uat01 reports. Use the task's exact Forge writeScopes, not this role's department as permission. Claim before writing and recheck the active lease before writes and integration. All workers use one shared coordinator ledger; serialize Studio/Blender ownership. Expired leases require confirmation that the prior worker stopped and explicit release. Delegate only through actual available host capabilities; otherwise work sequentially. Never infer connected tools from installed executables. No automatic publishing, paid uploads, spending, production DataStore writes, commerce activation, force-push or merge. Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical device, cross-server and human acceptance distinct; runtime IDs remain null until real import. Server authority and market conservation/fencing must be preserved. Report changes, actual checks, hashes, blockers and next owner for independent review.

Reuse Content, Expansion, StatusPoints, Hall caps and hero-start math. Preserve earned paths and opt-in flags. Verify refunds, prerequisites and no Hall deadlocks.

Escalate dependencies, cross-scope changes and blocked gates to parent game-design-lead. Parentage does not inherit write permission.

## Canonical skills

### guildborne-progression — .agents/skills/guildborne-progression/SKILL.md

---
name: guildborne-progression
description: Implement approved levels, class branches, skill/status points, respec, Hall caps and old-save migration.
---

# Guildborne Progression

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Read production/PROGRESSION_CONTRACT.md and current configuration. Player starts Novice Lv1; Class1 Lv10, Class2 Lv35, Class3 Lv70 require quests; no Class4. New heroes start Lv10; recruit after Class1 plus main-story Hall unlock. Cap=min(100,20+5*(Hall-1)) for Hall>=1; Hall17 unlocks100, Hall18-20 add non-level benefits. Preserve previously earned levels/classes under migration. Separate race, rank, class tier, hero identity and progression. Skill/status points are per actor; respec refunds already-earned totals rather than granting a new budget. Proposed point formulas are design defaults pending balance audit, not an instruction to overwrite existing tuned data. Validate tree DAG, mutually-exclusive branches, rank costs, learn/equip/AI states and atomic apply. Class quests check the subject hero's level, not the owner's. Remove circular Hall/class/mainquest prerequisites. Deliver migration fixtures, before/after invariants, UI previews and actual route tests.

## Handoff
Deliver changed paths, assumptions, tests actually run, evidence hashes, unresolved issues and next owner. Submit for an independent review; do not mark human UAT or public release complete.

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

### progression: Class, skill tree, status and Hall integration

Read LATEST_GOALS.md. Reuse Content.ProgressionRulesets, HallLevelCap, RecruitmentStartingXP and StatusPoints. Novice Class2 readiness is35; retain legacy policy and earned paths. Do not switch default campaign flags or create a competing progression service. Additional migration/cutover requires its own tested fixture plan.

Environment: local; skill: guildborne-progression

Write scopes: src/shared/Data/Expansion.luau, src/shared/Data/StatusPoints.luau, src/server/Systems/ProgressionV2Preview.luau, production/progression

Required checks: gates, points, migration, no-deadlock

Dependencies: audit, registry-reconciliation

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

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
