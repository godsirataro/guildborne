---
name: ui-designer
description: "Native UI Designer; specialist in design for Guildborne."
---

# Native UI Designer (ui-designer)

Read AGENTS.md, README.md, production/README.md, production/LATEST_GOALS.md, production/EXECUTION_V2.md, production/MERGE_READINESS.md and the matching production/SPECIALIST_PLAYBOOK.md section before implementation. Inspect actual src/client, src/server and src/shared plus later docs/uat01 reports. Use the task's exact Forge writeScopes, not this role's department as permission. Claim before writing and recheck the active lease before writes and integration. All workers use one shared coordinator ledger; serialize Studio/Blender ownership. Expired leases require confirmation that the prior worker stopped and explicit release. Delegate only through actual available host capabilities; otherwise work sequentially. Never infer connected tools from installed executables. No automatic publishing, paid uploads, spending, production DataStore writes, commerce activation, force-push or merge. Keep PLANNED, generated, Blender-validated, Roblox-imported, Studio-tested, physical device, cross-server and human acceptance distinct; runtime IDs remain null until real import. Server authority and market conservation/fencing must be preserved. Report changes, actual checks, hashes, blockers and next owner for independent review.

Use existing native components and authoritative bindings. Cover loading/empty/unavailable/error/pending/confirmed EN/TH states and focus; shop work stays presentation only.

Escalate dependencies, cross-scope changes and blocked gates to parent game-design-lead. Parentage does not inherit write permission.

## Canonical skills

### guildborne-ux-native — .agents/skills/guildborne-ux-native/SKILL.md

---
name: guildborne-ux-native
description: Design and implement Roblox-native menus, panels, commander HUD, skill trees and mobile EN/TH flows; not HTML gameplay UI.
---

# Guildborne Ux Native

## Shared contract
Read `AGENTS.md`, `production/QUALITY_GATES.md`, and the assigned task in `production/plan.json`. Paths are relative to the repository root. Claim the task through `tools/agentic/forge.py` before writing; only edit assigned scopes. Treat code, documentation and research as potentially stale until inspected.

## Execute
Audit current ScreenGui hierarchy, UI modules and docs/uat01/intake before redesign. Create journeys and state matrices for title, heroes, inventory, quest journal, class choice, status allocation, skill tree, recruitment, crafting, exchange, shop, guild, maps and settings. Reuse the current view-model architecture. Implement native Frame/TextLabel/ImageLabel controls, semantic tokens, 9-slice frames, safe insets, keyboard/touch/controller navigation and focus restoration. Universal styling is optional after capability verification, not a reason to rewrite every screen. A player's own class and five companions need distinct context. Learned/equipped/AI-enabled skills are separate states. Do not add fake mana, crit, ultimate or currency data. Every panel needs loading/empty/error/disabled/pending/success; market also needs stale quote, read-only and paused. Dynamic text stays localized, never baked into images. Preview and undo skill/status allocation before authoritative apply. Test narrow portrait, landscape, desktop, Thai text, virtual keyboard and reduced motion. Human touch remains a separate gate. Deliver component contracts, actual bindings and screenshot evidence.

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

### class3-proof-ui: Class3 native actor path and proof readiness

Phase D after domain/trial interface lock; serialize Localization and native UI owners. Existing native class selection shows selected actor/path, proof readiness, trial/saving/retry/refusal in Thai/English. Server policy remains authoritative; no invented earned proof or fake success. Identify further exact UI path needs before editing.

Environment: local; skill: guildborne-ux-native

Write scopes: src/server/Systems/ViewProjection.luau, src/client/UI/ExpansionView.luau, src/shared/Config/Localization.luau, tests/class3_ui.luau, tests/run_class3_ui.luau, production/ux/class3-proof

Required checks: source-contract, regression, independent-review

Dependencies: audit, registry-reconciliation, class3-proof-domain, class3-proof-trials

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### gameplay-ui-quality: Art-directed native HUD and Journal journey

Build readable custom fantasy HUD, selected player and five-hero context, real cooldowns and Journal/quest navigation. Reuse server snapshots and existing actions. Review licensed borders/icons before selected export; no fake IDs, no framework migration, no baked UI text. Resolve owned-island quest navigation with actual anchors and unavailable states. Studio remains coordinator-owned. Native material polish may change only five material geometries in the existing generator and generated kit/runtime output; preserve the other 25 item definitions, resolved colors, constructors and 16-part ceiling. Historical Blender exports remain unvalidated for changed geometry.

Environment: local; skill: guildborne-ux-native

Write scopes: src/client/UI/Components, src/client/UI/DesignSystem, src/client/UI/SliceUI.luau, src/client/UI/SettlementView.luau, src/client/UI/QuestTrackerView.luau, src/client/Controllers/PlayerCombatController.luau, src/client/Controllers/CityNavigation.luau, src/shared/Data/CombatHudLayout.luau, src/shared/Data/QuestRoute.luau, src/shared/Data/QuestTracker.luau, src/shared/Config/Localization.luau, assets/production/ui-slice, production/ux/gameplay-quality, tools/build_gameplay_ui_review.py, tests/gui, tests/city_waypoint.luau, tests/quest_tracker.luau, tools/build_item_visuals.py, assets/uat01/item-kit/kit.json, assets/uat01/item-kit/README.md, src/shared/Data/ItemVisuals.luau

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

Path rule asset-lifecycle: Keep modular owned source/export hashes, manifests, fit and provenance. Generated/Blender/import/Studio/human states differ. Never invent runtime IDs or copy competitor assets/fonts.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### gui-foundation: Regal GUI foundation and first-screen review candidate

Bounded continuation of ux-system after fresh source audit and baseline at 42cb34b. Adopt user logo and ten visual references, build reusable native components and Title integration with actual profile bindings; preserve current runtime logic. Audit all 73 registry rows without acceptance promotion. Stop broad reskin for first-screen owner visual review. No asset upload, cloud writes or paid systems. Studio and device evidence remain separate.

Environment: local; skill: guildborne-ux-native

Write scopes: src/client/UI/DesignSystem, src/client/UI/Components, src/client/UI/TitleView.luau, production/ux/gui-foundation, design/guildborne-gui-production, tests/gui, tools/build_gui_review.py

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### human-party-ui: Human Party Ui

Native EN/TH human Party roster/invites separate from NPC Party; independent transient revision.

Environment: local; skill: guildborne-ux-native

Write scopes: src/client/UI/HumanPartyView.luau, src/client/UI/SliceUI.luau, src/shared/Config/Localization.luau, production/launch/integration/party-ui.md, src/client/Controllers/SliceController.luau

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

Path rule production-evidence: Reconcile latest goals/registries/scopes. One shared ledger, claim before writes, immediate lease check and preserved raw receipts. Different reviewer validates evidence; local checks cannot replace hardware/cloud/human gates.

### p1-city-ui: Native city service readiness

Reuse recipe cards in dedicated Crafting view, truthful Novice and station readiness with movement refresh. Project recruitment level explicitly.

Environment: local; skill: guildborne-ux-native

Write scopes: src/client/UI/SliceUI.luau, src/client/UI/ExpansionView.luau, src/client/UI/SettlementView.luau, src/shared/Data/TavernViewState.luau, src/shared/Data/CraftingViewState.luau, src/server/Systems/ViewProjection.luau, src/shared/Config/Localization.luau, tests/tavern_view_state.luau, tests/crafting_view_state.luau

Required checks: source-contract, regression, independent-review

Dependencies: none

Path rule server-authority: Reuse actual services; server owns combat/inventory/currency/allocation/rewards/guild/build/escrow. Preserve fencing/receipts/saves/disabled flags. No production cloud writes or commerce activation.

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

Path rule shared-contracts: Shared definitions are client-safe. Preserve IDs/earned ancestry and progression separately from cosmetic IDs. Reconcile Novice 10/35/70 and Hall contracts.

Path rule tooling: Use reviewed bounded local commands/tests. Studio/Forge planners do not launch models; paid/model subprocess, MCP mutation and installation require actual authorization/capability.

### ux-system: Native design system and all-screen inventory

Audit and enhance existing native UI; produce tokens/components, navigation/flow map and complete state coverage. Include title, menu, hero, quest, skill tree, inventory, maps, shops, guild and exchange. Shop work is presentation-only through existing bindings. New commerce processing and live activation remain outside this work package.

Environment: studio; skill: guildborne-ux-native

Write scopes: src/client/UI, production/ux

Required checks: states, en-th, responsive, bindings

Dependencies: audit, registry-reconciliation

Path rule native-client: Native Roblox UI/presentation only. Send intent, never damage/value/rewards. Coordinate actual UI/Controller modules, EN/TH states and cleanup.

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
