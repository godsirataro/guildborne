# GL-2.0 P0 — source inventory and open decisions

2026-10-15. Source audit of the current working tree; not a clean committed evidence packet, Studio acceptance or content sign-off. The shared coordinator is `build/agentic/launch-v20-ledger.sqlite3`. P0 remains OPEN.

The [scope matrix](GL2_SCOPE_MATRIX.json) maps all20 existing feature IDs to17 delivery groups, including explicit Federation, war and territory groups omitted as standalone rows in the older20-theme registry. Owners are canonical Studio roles. `forgeTasks` references existing work packages, not authorization to write outside their current scopes or skip their dependencies. New implementation boundaries must be reconciled before those tasks are claimed.

## Verified existing identities

Each row below is a source inventory. A catalog entry does not establish import, functioning gameplay, tuned progression or acceptance. These counts are existing definitions; the proposed additions in the next section remain unapproved.

| Family / owner | Canonical IDs | Source and remaining acceptance |
|---|---|---|
| Novice / quest-designer | `MAIN_00_01`…`MAIN_00_06` (6) | `src/server/Config/NoviceChapter.luau`; fresh ordinary-input TH/EN/device routes |
| Campaign / quest-designer | `MAIN_01_01`…`MAIN_01_06`; `MAIN_02_01`…`MAIN_02_06`; `MAIN_03_01`…`MAIN_03_06`; `MAIN_04_01`…`MAIN_04_06`; `MAIN_05_01`…`MAIN_05_06`; `MAIN_06_01`…`MAIN_06_06` (36) | `src/server/Config/ChapterOne.luau` through `ChapterSix.luau`; all supported branches, rejoin and migration |
| Base classes / gameplay-designer | `Warrior`, `Knight`, `Archer`, `Mage`, `Priest` | `src/server/Config/Content.luau`; real class quests and ordinary player/hero route |
| Class2→3 / gameplay-designer | `berserker→warlord`, `duelist→sword_saint`, `guardian→fortress`, `paladin→holy_sentinel`, `ranger→beastwarden`, `sniper→deadeye`, `elementalist→archmage`, `spellblade→arcane_knight`, `cleric→high_priest`, `oracle→prophet` | `src/shared/Data/Expansion.luau`; preserve Novice35/70 and earned legacy Class2@30 |
| Special paths / gameplay-designer | `commander`, `rune_knight`, `bard`, `shadow_dancer` | Same source; every prerequisite/loadout/actor tested |
| Heroes / narrative-designer | `warrior_01`…`warrior_03`, `knight_01`…`knight_03`, `archer_01`…`archer_03`, `mage_01`…`mage_03`, `priest_01`…`priest_03` (15 templates) | `Content.luau`; owned instances are separate from template IDs; Rowan remains Warrior/`warrior_01` |
| Tower / gameplay-designer | Floors1–10; entry1/6; checkpoint5 | `src/server/Services/ExpansionService.luau`; generated `tower:<serial>` run identity, no invented named floor IDs |
| Hall/buildings / guild-engineer | `guildHall` levels1–20, `warehouse`, `quarters`, `forge` | `Content.luau`, `Expansion.luau`; Hall18–20 currently lacks campaign permits and defined non-level benefits |
| Cities / world-builder | `Crownford`, `Sylvaris`, `Deepforge`, `Astralis`, `Crosshaven`, `Ironroot` | `src/shared/Config/CivicCities.luau`; P1 benchmark starts now, all cities require P8 acceptance |
| Nodes / gameplay-designer | `wood`, `stone`, `ore`, `herbs`, `greenwood_wood`, `greenwood_herbs`, `ironveil_stone`, `ironveil_ore`, `ashen_herbs`, `ashen_stone` | `Expansion.luau`; node IDs are not market item IDs |
| Recipes / gameplay-designer | `iron_ingot`, `guardian_plate`, `vitality_charm`, `watchblade`, `oathblade`, `yew_longbow`, `tide_staff`, `dawn_crozier`, `scout_coat`, `runewoven_mantle` | `Expansion.luau`; balance/material coverage through100 remains to qualify |
| Furniture / world-builder | `hearth_table`, `hearth_chair`, `welcome_bench`, `guild_bookcase`, `woven_rug`, `guild_banner`, `garden_planter`, `crystal_lantern`, `display_plinth`, `hearth_bed` | `Expansion.luau`; placement/restore/fit/device and human art gates remain separate |
| Material market / market-engineer | `stone`, `timber`, `iron_ore`, `iron_ingot`, `herb` | `src/server/Config/Market.luau`; Gold/materials only, actual distinct-server conservation required |
| Human bodies / character-artist | `CHR_BDY_HUMAN_SLIM_V01`, `CHR_BDY_HUMAN_STANDARD_V01`, `CHR_BDY_HUMAN_ATHLETIC_V01`, `CHR_BDY_HUMAN_HEAVY_V01` | `src/shared/Data/AppearanceCatalog.luau`; source/export/import/fit/human acceptance separately tracked |
| Elf bodies / character-artist | `CHR_BDY_ELF_GRACEFUL_V01`, `CHR_BDY_ELF_RANGER_V01`, `CHR_BDY_ELF_STURDY_V01` | Same catalog; never invent Elf STANDARD |
| Orc bodies / character-artist | `CHR_BDY_ORC_LEAN_V01`, `CHR_BDY_ORC_STANDARD_V01`, `CHR_BDY_ORC_HEAVY_V01` | Same catalog; cosmetic IDs never replace ancestry balance |
| Dwarf bodies / character-artist | `CHR_BDY_DWARF_BROAD_V01`, `CHR_BDY_DWARF_COMPACT_V01`, `CHR_BDY_DWARF_STOUT_V01` | Same catalog; authored proportions and all outfit fits |
| Daily/season / market-engineer | Seven daily steps; six preview season tiers; `launch_preview_01` | `src/server/Config/LaunchRewards.luau`; preview is not final Battle Pass. Premium disabled; no product/pass IDs invented |

## Required unresolved decisions

These are explicit P0 blockers with `canonicalIds: null` in the matrix. IDs below identify planning decisions, not runtime content.

| Decision | Owner | Proposed size / dependency | Exit requirement |
|---|---|---|---|
| combos | combat-engineer | 3; existing tactical/skill authority | Named mechanics/IDs, timing, interruption and balance; prototype one before expanding |
| hero-stories | narrative-designer | 3 templates; owned-instance identity/save | Named chapters, replay keys and duplicate-template policy |
| research-nodes | gameplay-designer | Military/Crafting/Exploration ×3 nodes | IDs, costs, caps, respec, visible utility and no Hall/class bypass |
| event-types | quest-designer | 3 types; shared eligibility/settlement | IDs, lifecycle/expiry/recovery and reward authority |
| team-challenges | gameplay-designer | 3; endgame and shared encounter authority | Named win/lose/replay/mastery/trophy contract |
| territories | world-builder | 3; war results/world support | Actual locations/IDs, ownership, contest, caps/upkeep/season reset |
| hall18-20 | gameplay-designer | 3 levels; campaign permits | Obtainable permit route and meaningful non-level benefits |
| release-content | asset-curator | Complete enemy/boss/item/quest/outfit/action/VFX/audio inventory | Every required ID, owner, source/export/runtime binding, provenance and acceptance; no required unknown count |
| capacity-devices | performance-engineer | War/server population and minimum hardware unresolved | Measured population/frame/memory budgets and named Android/iOS targets; no invented launch capacity |
| commerce-catalog | market-engineer | Scoped receipt work and products/seasons unresolved | Reviewed catalog/fulfillment contract and explicit authority for blocked commerce work; no live activation |

P0 cannot be declared complete from this partial named inventory. No launch date is forecast before work decomposition, actual staffing/throughput and external qualification are known. Existing Forge packages for missing systems need narrowed implementation tasks before production writes.

## Source findings that determine sequencing

1. `ReleaseContent.luau` remains `guildborne.launch.lv35.1`, MaxLevel35, MaxHall4, CampaignChapters12. `ReleasePolicy.luau` applies that boundary only to an explicitly isolated Studio/zero place+game IDs/Memory candidate. It is not a universal game cap and is not expanded by these planning changes.
2. Six campaign arcs already exist. Historical `docs/uat01/WORK_CHECKLIST.md` reports an ordinary-input Memory Chapter00–06 route on2026-10-06 at Mage100/Hall17. That is prior integration evidence, not current-build/all-class/persistence/device acceptance.
3. `PersonalGuildService.luau` requires the next Hall permit in Novice campaign mode; `ChapterSix.luau` ends permits at17. Upgrade definitions18–20 alone do not supply a playable route. Do not bypass the gate without the approved utility/story contract.
4. The source audit found no identified runtime Bond/combo/research/Federation/territory/world-event/TrainingGround/StrategyTable implementation using those names. Reuse existing actor, Hall and transaction authority when implementing; a text search is not exhaustive semantic proof of absence.
5. Human organization foundations already exist in `PlayerGuildSchema`, membership/join/founder/removal/recovery and store modules. Federation needs a reviewed mapping; never rename persisted namespaces automatically.
6. Shared combat and store injection remain isolated candidate seams. The existence of settlement/claim code does not prove a live durable provider or distinct-server recovery.
7. `CentralCityWorld.luau` tavern/blacksmith sign routes still use `CityFuture`; civic-city taverns have recruitment bindings. The P1 square→tavern→forge benchmark must name its real route and service interactions before art acceptance.
8. Hero follower recovery previously cleared a path without invalidating an in-flight `ComputeAsync`; a stale completion could restore an obsolete route. This batch assigns the scoped fix to `shared-combat-coordinator`. Direct local closure tests and Studio journey acceptance are separate.

## Acceptance layers and handoff

Fresh setup and full baseline on the pre-fix working tree:885 Luau tests, Rojo build/sourcemap, Roblox-aware analysis, compile, repository/boundary checks and whitespace passed. Raw logs: `build/agentic/gl2-setup.log`, `build/agentic/gl2-baseline.log`. Final post-fix checks are recorded in [execution report](GL2_EXECUTION_REPORT.md).

Reconciliation:502 assets,73 screens,89 planned kit assets,402 file hashes and0 missing references. Character contract:15 required core body parts; no new meshes/fit approvals. Studio v3 metadata validation/verification passed. Actual Studio MCP discovery returned an empty instance list; no current Studio test or screenshot is claimed.

The tree contains pre-existing uncommitted implementation work. Logs remain local observations, not `record_check.py` clean-commit evidence, Forge acceptance or release readiness. Different review must inspect changes. Next owners: gameplay/narrative for unresolved P0 designs, technical director for task scopes/durable integration, art/world for P1 ordinary route, QA for actual Studio/device/cross-server qualification.
