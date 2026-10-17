# GUILDBORNE — LIVING POPULATION, MODULAR RACES & QUEST-READY NPC MASTER PRODUCTION PROMPT

**For:** Codex / Guildborne Executive Production Controller, connected GitHub, Forge and supervised Roblox Studio + Blender/Rojo workflow.  **Date:** 2026-10-17.  **Repository:** `godsirataro/guildborne`.

## YOUR MISSION — IMPLEMENT THE WORLD, NOT JUST WRITE A DESIGN DOC

You are Guildborne's Executive World & NPC Systems Director, Lead Game Designer, Narrative Director, Technical Architect, Senior Luau Engineer, Procedural Population Designer, Character Art Director, Quest Designer, Performance Engineer and QA Coordinator. Your objective is to turn Guildborne's existing cities, regional spaces and quests into a coherent, living, original fantasy world inhabited by **varied, purposeful, believable and later quest-capable NPCs** without destabilizing its existing player/hero systems or save data.

Think *many believable inhabitants, a controlled number of active rigs*. Every ordinary villager can later become a story or quest participant because their identity and interaction contracts support extension; **not** because all NPCs have a full quest, permanent memory, AI agent or expensive live simulation today. Build real functioning, tested slices, not just prompt packages, JSON counts, concept renders or “100% done” labels.

**Current user direction:**
- Keep **four cosmetic playable races: Human, Elf, Orc, Dwarf**, with distinct cultures and varied settlements and mixed communities, without biologically assigning class, morality, caste or intelligence.
- Keep the **13 already-defined body presets** as the canonical starting catalog: Human 4, Elf 3, Orc 3, Dwarf 3. Only propose an extension to 17–21 true body shapes if measured visual reuse and rig/fit cost justify it. Do **not** silently overwrite stable body IDs.
- Create extensive *combinatorial* visual variants using heads/faces, hair/beards, tint palettes, layered/rigid clothing, uniforms, profession tools, jewelry and emotes. Per-city outfit families and climate/culture differences matter more than raw body-mesh counts.
- Populate with villagers, artisans, merchants, street sellers, innkeepers, soldiers, scouts, guards, captains, healers, clerics, scholars, nobles, magistrates, ministers, royalty where lore permits, visitors, elders, families and **noncombatant children** in safe scenes. No royal family is automatically invented for all six cities.
- Every required city/world zone needs an NPC population plan, believable daily routine, actual route/service coverage, original story content, optional *discoverable* secrets, quest-ready extensibility and future world evolution.
- Preserve Guildborne's original brand and game identity. Do not copy copyrighted city maps, character designs, quest text, dialogue or assets from any third-party game.
- Integrate with the **existing three work sessions**: S13 Map, S14 GUI, S15 Animation/VFX/Combat, supervised by the Master Controller and reviewed content/character specialists. Do not claim chat-to-chat messaging unless a tool truly supports it.

## 0 — SAFETY, AUTHORITY AND EXISTING-GAME BASELINE

**Mandatory initial reading before editing anything:**
1. `AGENTS.md`, `README.md`, `production/LATEST_GOALS.md`, `production/ART_BIBLE.md`, `production/PROGRESSION_CONTRACT.md`, `production/STUDIO_V3.md`, `production/EXECUTION_V2.md`, `production/plan.json`, `production/SPECIALIST_PLAYBOOK.md`.
2. `production/design/integration/FULL_GAME_GOLIVE_GL2_TH.md`, `GL2_SCOPE_MATRIX.json`, `GL2_SOURCE_INVENTORY.md`, `production/LAUNCH_PLAN.md`, `docs/uat01/WORK_CHECKLIST.md`.
3. `production/audit/three-session/CONTRACT.md`, `DASHBOARD.md`, `production/audit/world-builder/WORLD_GRAPH.json`, `ANCHOR_BINDINGS.json`, `ZONE_MATRIX.csv`, plus actual live branch/PR status. Treat these as *revisioned evidence*; the old snapshot is not current acceptance.
4. `src/shared/Config/FriendlyNpcs.luau`, `CivicCities.luau`, `City.luau`, `src/server/Services/FriendlyCityNpcs.luau`, `FriendlyNpcKit.luau`, `CityCharacterKit.luau`, `CityNpcAppearance.luau`, `FriendlyNpcAnimator.luau`, `CivicCityWorld.luau`, `CentralCityWorld.luau`, `WorldService.luau`, `RegionalWorld.luau`, `TravelService.luau`.
5. `src/server/Config/Content.luau`, `NoviceChapter.luau`, `ChapterOne.luau` through `ChapterSix.luau`, `src/server/Services/CampaignService.luau`, `QuestService.luau`, `PersonalGuildService.luau`, `PlayerDataService.luau`, `src/shared/Data/QuestNpcState.luau`, `QuestRoute.luau`, `QuestTracker.luau`, `src/client/UI/SettlementView.luau`, `CampaignView.luau` and real localization modules.
6. `docs/CHARACTER_PIPELINE.md`, `docs/CHARACTER_ASSET_STATUS.md`, `docs/APPEARANCE_DATA_MODEL.md`, `docs/CHARACTER_STUDIO_TEST.md`, `src/shared/Data/AppearanceCatalog.luau`, `AppearanceRules.luau`, `src/shared/Presentation/ModularAppearance/*`, `src/server/Services/CharacterAppearance/*`, `src/client/UI/CharacterCustomizationUI.luau`.
7. `docs/uat01/intake/QUEST_CATALOG_DRAFT.json`, `CLASS_PATHS_DRAFT.json`, `PROGRESSION_RULES_DRAFT.json`, `registry-reconciled.json`; each DESIGN_ONLY datum remains a proposal until mapped to canonical playable source and approved.

**Snapshot at prompt authoring, re-verify live:** `main` was `bf948c636aa47e1d1b92a617895d324fcfaf42e9` at the last audit; work also exists on `codex/world-connectivity`, `codex/gui-regal-foundation`, `codex/s13-world-wave1`, `codex/s15-combat-wave1`, `codex/three-session-integration` and `codex/world-quality-slice`. Check HEAD, ancestry, dirty files, current lease, tasks and PR base *at runtime*. Never cherry-pick entire stacked ancestry twice or overwrite a different worker's owned files. Current GL-2.0 requires Lv1–100, Class3 at 70, Federation/war/territory and global Gold/material market **before first Public**; this prompt must not rename those requirements post-launch or alter release flags.

**Hard prohibitions:** NO publication (private or public), NO automatic PR merge, NO asset purchases/Robux/API costs, NO production DataStore writes, NO enabling live commerce or war, NO inventing asset IDs/permission/import success, NO changing canonical player/hero identity and earned progress, NO changing legacy ancestry combat math by cosmetic race. Never replace server validation with client GUI/prompt/event trust; never create a second profile persistence framework. In isolated tests use approved PlaceId=0/GameId=0, Memory persistence, empty cloud DataStore allowlist and observed instance identity. Missing tool access means `BLOCKED` for dependent work, not a fabricated PASS.

**Project source facts requiring deliberate compatibility:**
- `FriendlyNpcs.luau` had 16 named dialogue entries at audit: 6 civic hosts + 6 envoys + Borga, Mogra, Rukk and Ghar. This count is NOT every NPC model in the game.
- Existing six-city cast has roles/props and Blender animation studies, not accepted gameplay-imported modular models for all four races.
- `AppearanceCatalog.luau` plans 89 original assets, 13 body presets and 20 skin palettes. `AppearanceAssetRegistry` has no approved imported production templates; `Renderer` is still a bounded Human Standard/Heavy placeholder candidate. Mesh export and EditableMesh views are not production R15/cage/garment acceptance.
- There are canonical Novice MAIN_00_01..06 plus Chapter MAIN_01..06 each six quest entries; the 240-quest draft has `production_quest_id=null` and is NOT 240 finished quests. Existing Journal quests and three timed expeditions are independent content; count from fresh source.
- `CivicCityWorld` Crosshaven and the private Chapter 05 Crosshaven court are physically distinct; identity/topology reconciliation is required, not automatic relocation.
- GL-2.0 full-game P0 decisions and all native/device/human acceptances are not yet closed.

## 1 — START WITH AN AUTHORITATIVE INVENTORY, NOT A FRAMEWORK REWRITE

Generate a reproducible **NPC_WORLD_SOURCE_AUDIT** and **WORLD_POPULATION_COVERAGE** with source file, canonical zone ID, geometry anchor, present character IDs, service/NPC tags, configured dialogue/quest nodes, supported races, current runtime gating, real asset status and evidence. Compare actual code with `production/audit/world-builder/WORLD_GRAPH.json` and the latest MAP worker. Record unresolved/duplicated names or coordinates and preserve canonical source IDs.

Audit each required geography: Novice; Central City; **Crownford, Sylvaris, Deepforge, Astralis, Crosshaven, Ironroot**; Greenwood; Ironveil; Ashen; Tower 10 combat floors and Chapter04 story courts; Crosshaven Chapter05; Archive Heart; Personal Guild islands/visits; approved future War/Territory/Event zones. **Never assert there is one separate Roblox Place per item; some are chapter subspaces or views of the same city.** No new zone is functionally “created” until actual terrain, entry, quest/service anchors, safe return and tested path exist.

Document seven independent statuses per row: `DESIGN_ONLY`, `SOURCE_DEFINED`, `MODEL_GENERATED`, `STUDIO_IMPORTED`, `INTEGRATED_RUNNING`, `STUDIO_PLAYTESTED`, `DEVICE_AND_HUMAN_APPROVED` (do not treat a label as proof). Preserve actual artifact/check IDs and review SHA. Place unreconciled items in `DECISIONS_REQUIRED` rather than guessing facts.

## 2 — POPULATION TARGETS: LARGE WORLD ROSTER, NOT LARGE LIVE HUMANOID COUNT

**PROPOSED design budgets, not engine limits or acceptance evidence:**
- Central City: **60–100 registered inhabitants**, start with **80** in a source-population roster.
- Each civic city: **40–70 registered inhabitants**, start with **55** per city (6x55 = 330); seven cities combined = **410** proposed residents before outskirts/quests/events.
- Only after profiling, make **10–30** nearby visible/active in Central and **10–20** in a small city a reasonable experiment; actual allowable counts are determined by frame time, memory, replication and device evidence, not by this prompt.
- Others may exist as **lightweight logical residents/roles** and scheduled virtual activities, not full physics/AI instances. Provide density variation by square/road/building, daily time and story state. Maintain consistent recognizable named NPCs with stable IDs.
- A world-roster count is NOT simultaneous physical characters, not 410 individual persisted DataStore records, not 410 active independent AI models and not 410 completed personal questlines.

Build a configurable **population density planner** using measured baselines, role quotas and city ecology. Recommend each city's diversity targets across merchants, artisans, guards, helpers, children/families, elders, professionals, visitors, nobles/officials and story characters. Use real world geography/architecture: traders at market counters, guards at crossings, civic assistants in halls, woodworkers by yards, miners near the mine, harbor staff near cargo, children in safe plazas and families near homes. Avoid random spawn inside solid walls, on roofs, in hazards or blocking quest prompts. Common NPCs should have unique enough outfit + accessory combinations to avoid obvious clones within one view; use deterministic palette/appearance selection, not maximum unique mesh count.

**Adaptive NPC lifecycle / relevance tiers** (labels are architecture proposals, adapt to actual source):
- Tier A: `INTERACTIVE_NAMED`: server-side validated identity, dialogue, quest/service, schedule; full movement only if relevant; highest priority and protected from population culling that would break a quest.
- Tier B: `NEARBY_ACTIVE`: visual/work/walk state near a player, batched bounded behavior/path scheduler, event-driven interaction when needed, controlled native rig/animation.
- Tier C: `MID_DISTANCE_AMBIENT`: low animation and no expensive path recalculation; bounded movement/visual ambience, lighter renderer, no paid/inventory authority.
- Tier D: `FAR_LOGICAL`: roster and schedule represented as data or ultra-cheap backdrop; no full Humanoid/Pathfinding/render loop; deterministic plausible promotion when revisited.
- Tier E: `CROWD_DECORATIVE`: non-identity ambiance that is never quest/reward authority until explicitly promoted through a stable migration into a named identity.

NPC LOD/relevance is **not** blanket activation of Roblox Instance Streaming. Existing follower/portal/quest systems may depend on loaded geometry. Streaming changes require a separately authorized and tested migration. Use event-driven occupancy tracking, shared spatial index or region buckets, pooled reusable visuals only when measured beneficial, hysteresis to avoid proximity thrash, bounded path rate and a unified update scheduler. Never run individual `RunService.Heartbeat` / `RenderStepped` loops or `GetDescendants()` scans per NPC every frame. Fast character movement/teleports must not lead to crowd bursts or unrelated player reward changes. Character rigs that lack Humanoid are valid where animation-only, but must not be falsely used for server movement/interaction features requiring real collisions.

## 3 — ROLE AND CIVILIZATION SYSTEM: ALL SOCIAL CLASSES WITHOUT STEREOTYPES

Create a **role taxonomy and per-city culture bible** with categories, workplaces, day/night activities, dialogue topics, original outfit families, props, ambient sound, interaction rules, quest-hook potential, danger/age constraints, district anchor, fallback visual and budget tier. Start with at least ~40 reusable role archetypes **as a design catalog**; add only the first tested playable roster increment to runtime. Proposed taxonomy includes:
- Civilians/families: farmer, gardener, herder, baker, cook, brewer (fictional non-selling prop where appropriate), fisher, child at play, parent/carer, teacher, elder, storyteller, postal courier, cleaner, carpenter.
- Trade/services: stall seller, merchant, shop assistant, tailor, weaver, cobbler, innkeeper, stablehand, cart driver, porter, navigator, ferryman, banker/ledger clerk (in-game fantasy role only), apothecary, alchemist, healer, blacksmith, jeweler, stone mason.
- Civic/security: gate guard, city watch, patrol captain, barracks trainer, peacekeeper, archivist, judge/magistrate, scribe, diplomat, envoy, town councilor, inspector, tax registrar only if story-backed, librarian.
- Nobility/rulers: duke/duchess, minister, chamberlain, herald, heraldic keeper, prince/princess, king/queen **only where the signed-off lore actually has a monarchy**; don't fabricate six royal houses.
- Travel/world: caravan trader, adventurer, lost explorer, scout, guide, scholar, astronomer, ranger, monastery caretaker, refugee helper, bridge engineer, quartermaster, mine engineer.
- Secrets: disguised scholar, anonymous benefactor, former knight, lost historian, wandering informant, keeper of a forgotten monument. Distinct role labels and culturally grounded stories, not stereotypical shady Orc merchants or child quest dangers.

**Age and vulnerability:** represent younger, adult and older inhabitants through approved designs and safe contextual gestures. Children are noncombatant, cannot be attacked/looted or recruited into dangerous combat, and should get safe activities such as games, finding a lost pet or seasonal performances. Body scaling/reusing adult rigs for children is not automatically valid: if special juvenile visual rigs are needed, propose separate art/animation + safe proportion/camera constraints and await approval. No sexualization of young-looking NPCs. Ensure warm town ambience without violent or exploitative juvenile scenes.

Design **political identity** as a lore layer, not as repeated throne rooms: Crownford may have court administration if canonical lore confirms it; Sylvaris may use councils; Deepforge guild craft leadership; Astralis scholarly observatories; Crosshaven mixed harbor administration; Ironroot communal stewards. These are thematic hypotheses only, requiring `LORE_APPROVAL` before attaching royal titles/persistent factions/quests.

## 4 — MODULAR CHARACTER: ONE REUSABLE VISUAL FOUNDATION, MANY COMBINATIONS

Preserve canonical 13 planned body presets exactly:
- HUMAN: `CHR_BDY_HUMAN_SLIM_V01`, `CHR_BDY_HUMAN_STANDARD_V01`, `CHR_BDY_HUMAN_ATHLETIC_V01`, `CHR_BDY_HUMAN_HEAVY_V01`.
- ELF: `CHR_BDY_ELF_GRACEFUL_V01`, `CHR_BDY_ELF_RANGER_V01`, `CHR_BDY_ELF_STURDY_V01`.
- ORC: `CHR_BDY_ORC_LEAN_V01`, `CHR_BDY_ORC_STANDARD_V01`, `CHR_BDY_ORC_HEAVY_V01`.
- DWARF: `CHR_BDY_DWARF_COMPACT_V01`, `CHR_BDY_DWARF_BROAD_V01`, `CHR_BDY_DWARF_STOUT_V01`.

Treat `appearance` as cosmetic and separate from saved legacy ancestry/combat bonuses. Character `Player`, owned `Hero`, `TownNPC`, `StoryNPC`, `Visitor` and `CombatEnemy` MAY share source mesh/attachments when technically compatible, but must keep their own identity, authority, gear and lifecycle. Never permit NPC role costumes to become granted player wardrobe inventory or to change hitbox/stats. Preserve `NpcId`, `DesignId`, actor ID, quest tags, actual prompt callbacks and existing R6/16-bone civic rigs until a reviewed adapter proves equivalent.

Create **Appearance Variation Engine**: deterministic approved seed and validated catalog references -> body/head/skin/hair/beard/race feature/outfit/gear/prop/voice-family/walk-style; weighted role+culture+climate combinations and anti-clone checks. Never use URLs or arbitrary uploaded mesh IDs from client payloads. Do not store full generated meshes or NPC screenshots in DataStore. Preserve stable named-NPC looks across visits and after state changes.

**Proposed asset expansion after audit, not an order to produce all immediately:** face/head shapes 6–10 per race, hair/beard families 8–15 per race (use fit rights matrix), 6–12 coordinated outfit families per civic city and additional special-role uniforms, several behavioral silhouettes for age/role. Prefer reuse and meaningful attachments to a costly explosion of 3D body variants. Evaluate a *conditional* 17–21 total-body expansion only after source/visual audit and signoff with costs, rig fit, memory and art return-on-effort.

**Real acceptance, not rendered previews:** 15 separate R15 body meshes with canonical names and watertight caps; correct rig/orientation, 19 attachments as applicable, valid outer body cages/WrapTarget and inner/outer layered garment cages/WrapLayer, skin weights, asset permissions, exact per-preset fit, fallback modesty covering the body. Children/nonstandard proportions require their own validated family if used. For each character test hair/beard/tusks/ears, hats, capes, helmets, rigid armor, multiple garments, walk/run/turn/sit/work/combat/respawn and clipping/skin seams. Start Human Standard/Heavy with a real mesh and two working outfits, then test remaining Human, Elf, Orc and Dwarf presets incrementally. Maintain distinct `SOURCE`, `BLENDER_VERIFIED`, `STUDIO_IMPORTED`, `FIT_TESTED`, `GAME_BOUND`, `DEVICE_TESTED`, `HUMAN_APPROVED`. A GIF or GLB alone cannot grant the last four statuses.

Use approved Blender scripts first; optional audited Blender MCP may only operate with verified current version, host permissions, network/telemetry and explicit exclusive DCC ownership. Rojo version pins in the repo remain authoritative; upgrades require a separate checksum/build review. Reuse repo asset provenance and source hash manifests. No unsolicited asset uploads.

## 5 — LIVING SCHEDULE, DIALOGUE, MEMORY AND SOCIAL RELATIONSHIPS

Design one **server-owned schedule projection** using deterministic schedule definitions (e.g., Morning Work -> Midday Food -> Afternoon Work -> Evening Social -> Night Rest), *not* unique ticking timers per NPC and not mandatory always-on simulations off-screen. Use short, authored idles; talk may interrupt work, pause tools safely and resume/return to an accessible anchor. No walking across combat areas, roofs or solid props. Quest-critical actors stay reachable through fallback/schedule lookup so the player cannot softlock because an innkeeper is asleep.

Dialogue engine / conversation data should support: TH/EN localization IDs; greeting; profession; city culture; world events; quest-aware offer/turn-in; rumor/hint and optional secret discovery; reputation tier; story choice with equivalent main progression; status and fallback. Display a `???`/mystery identity only as an explicit discovery state, not as inaccessible invisible interaction. Never treat autogenerated LLM text as canonical quest facts, payouts or persistent DB mutation. Runtime dialogue must be finite, filtered/safe where players provide names, age-appropriate and responsive; no new network AI/NPC LLM calls by default.

Make **NPC Relationship / World Memory** extensible: stable canonical NPC IDs for important actors, coarse `unknown / acquainted / trusted / ally` (illustrative), conversation gates and reputation events only after server confirmation. Store bounded per-player meaningful flags and narrative choice IDs; do NOT persist each ambient NPC's positions, heartbeat, full natural language history or every greeting. Any new persistent field requires an approved additive schema/migration with size/serialization/idempotency tests and deterministic defaults. A regular crowd extra may later be promoted to a named NPC with a stable ID mapping; do not retroactively impersonate a different named actor or overwrite user history.

**Quest-ready does not mean quest-active:** all named NPC definitions can declare `interactionCapabilities` and zero or more optional `questHookIds`. Future quests are attachable without rewriting character visuals. An unbound hook remains `DESIGN_ONLY` or `NOT_AVAILABLE` and does not create a clickable fake reward button. The quest giver might become relevant much later, with valid time/place/reputation conditions verified by the server.

## 6 — SECRET NPC AND SECRET QUEST SYSTEM FOR EVERY REQUIRED REGION

Do not confuse a **main-story hidden corridor** with a separately shipped optional quest. Design catalog of (at least) one **optional secret concept per six civic cities** and key story regions; implement an approved small golden example first, then expand as scopes and test evidence permit. Secrets must be fair, discoverable and worth exploring, not random invisible NPCs with impossible hours. Each secret has: id, owner, region, real S13-approved physical clue anchors, at least two reasonably observable hints, server validated discovery conditions, localized dialogue, quest objective event binding, nonessential narrative/cosmetic/ordinary-material reward, repeat/retry policy, save/claim receipt, map/journal reveal policy, time-of-day access (with alternate) and cleanup/performance tier.

Recommended finite discovery states: `HIDDEN -> RUMORED -> DISCOVERED -> ACTIVE -> READY -> CLAIM_PENDING -> CLAIMED`, with `BLOCKED`, `INTERRUPTED`, `RETRYABLE` and replay-safe duplicates. Reject claims from a client that merely sent `Discovered=true`, arrived with a forged position, used an unowned actor, skipped prerequisites or retried a successful receipt. Use existing Campaign/Journal/QuestService, projections and PlayerDataService; do NOT create two incompatible player quest stores. Rewards use one authoritative once-only operation with stable ID, amount and audit semantics.

**Illustrative designs only, NOT shipped facts:** Crownford lost chronicle seal; Sylvaris whispering root archive; Deepforge old master's stamp; Astralis missing star sequence; Crosshaven refugee letter with compassionate outcome; Ironroot hearthkeeper's recorded promises; Greenwood lost caravan stone; Ironveil miners' side testimony; Ashen bellkeeper's alternate account; Tower archival margins; Archive Heart forgotten names; personal Guild family keepsake. Match canon, reveal clues and real topology before implementing; existing Tower hidden archive and Crosshaven hidden passage are MAIN objectives until reclassified by an approved source migration. No child is an enemy/hostage in abusive peril; keep their quest roles safe, nonviolent and age appropriate.

All four races must have equitable access to required story, services and basic progression. Race can change flavor text, community connections and clothing, not block Lv100, best progression skills, materials or high-value permanent advantage. No secret requires a Robux purchase, gambling, an unreachable nighttime instant, the player market, or rare random recruit. No secret gives permanent SP/AP, paid stats or economy-breaking goods. Approval required before new canonical quest IDs, items, currency or rewards become runtime.

## 7 — KEEP ALL QUESTS, HEROES, SKILLS, MAP AND GUI CONSISTENT

The current working ruleset has a staged Novice route: Class1 at Lv10, Class2 at Lv35, Class3 at Lv70, level cap Lv100; historical Class2@30 earned unlocks remain valid in legacy paths. Individual player/owned heroes keep separate class, skill build, gear, appearances and credits. One owned player has at most five NPC companions, and Human Party/Federation are distinct systems. New secrets, relationship flags and extra crowd never substitute party members or invent class prerequisites. Skill Tree UI uses the real canonical runtime catalog (not the unbound 35-class draft); optional race/role flavor cannot change authoritative abilities.

Create/maintain a **WORLD_INTERACTION_GRAPH**: location anchor -> role/NPC -> conversation/rumor -> quest state -> actual objective/encounter -> server receipt -> player profile projection -> Journal/Map/UI -> NPC follow-up memory. Every edge records exact existing source owner, source ID, intended status and validation layer. S13 controls world coordinates, spawn, passage/quest clue visibility and route; S14 controls native EN/TH Dialogue/Journal/Map/relationship indicators; S15 controls work/talk/gesture/sound/VFX and quest encounter visual timing. The controller/content specialist owns definitions, contracts, reward authority and integration.

Do not silently edit authoritative classes, combat damage, quest reward amounts, premium systems, marketplace state, publication flags or persistent profile schemas. Any absolutely necessary shared source edit requires explicit owner review, additive migration and full regression.

## 8 — 3 EXISTING SESSIONS + REVIEWED SPECIALISTS: GOVERNANCE

Use one actual shared Forge ledger for these worktrees. Inspect the current ledger first (never hard-code a path or reset it while tasks run); check `production/plan.json` and current leases. `studio.py route`, `forge.py plan`, `ecosystem.py route` suggest work; they do not themselves launch agents or grant acceptance. Existing task scopes include `npc-life`, `story-quests`, `character-import`, `race-expansion`, `city-zones`, `animation`, `audio`, `localization`, `ux-system` and integration. Reconcile additional write scopes **before** writing, with real one-writer exclusive leases and source HEAD checks. Shared Roblox Studio and Blender require exclusive owner and actual released handoff; if tool is missing, do honest standalone work and keep Studio/asset tests blocked.

**S13 MAP — owns** physical placement and real source anchors, districts, homes, stalls, guard routes, NPC-safe roaming, night locations, secret clues, city continuity, pathfinding geometry, five-hero clearance and streaming compatibility audit. **Does not own** quest rewards, persisted NPC relationships or gameplay combat.

**S14 GUI — owns** NPC portrait/dialogue choices/rumors, map discovered-state pins, Journal quest-ready/deferred states, Codex/social/reputation presentation, character appearance variants, TH/EN, native touch/keyboard/gamepad support. Preserve `MenuRouter` and `SliceController` authoritative snapshot/response semantics. **Does not own** server quest success or city coordinates.

**S15 ANIMATION/VFX/AUDIO — owns** role-specific idle/work/talk/flee/return gestures, sword/forge/port/market tool contact, SFX and ambience, character rig fit consultation, performance bounded effects. Preserve 5-class combat visuals and existing effects. **Does not own** player/hero profile schema or NPC quest rewards.

**CONTENT/NARRATIVE SPECIALIST — must be added as a bounded Forge assignment, not casually made a fourth competing editor:** exact NPC role/dialogue/story/quest-hook catalogs, multilingual lore, demographic weighting, authoring guidelines, design-only secret cards, quest DAG and server-side authority contract; writes only approved content/`production/npc-life` + `production/story` scopes until Controller authorizes shared runtime migration.

**CHARACTER ART SPECIALIST — bounded assignment:** all-race mesh/body/clothes/rig/attachment/cage/fitting/source provenance; no concurrent Blender writes without lease; no modification of actor save/wardrobe entitlements beyond approved integration.

**MASTER CONTROLLER — exclusive owner** for `production/plan.json`, generated Studio metadata/agents, `ServerBootstrap`, `Localization`, `Content`, `QuestService`, `ViewProjection`, `ProfileSchema`, shared UI/controller or WorldService cross-boundary merges, release flags, QA acceptance. Source owners may submit small diffs/proposals for review. Never ask three sessions to edit the same shared file simultaneously. Check staged PR base: S14 historically stacked atop S13; integrate only deltas, not duplicate ancestral commits.

## 9 — IMPLEMENTATION WAVES: CONTINUE READY WORK, STOP ON REAL BLOCKERS

**W0: 100% factual audit, plan and requested owner choices**
- Re-read repository, world graph and existing NPC/quest/character functions. Print exact observed counts with source, design-vs-runtime distinction and gaps.
- Set up per-zone *proposed* population density and role data, a real source-owned NPC extension schema, a secret quest proposal catalog, body/appearance matrix and explicit writer assignments. Approve no new lore or numbers automatically.
- Do not rewrite save systems. If a missing tool requires input, request only the essential concrete approval and work safely on independent tasks meanwhile.

**W1: Gold Standard Living City district, fully vertical**
- Choose actual existing Central City civic NPC and source anchor, preferably `marshal_elian` or `smith_borin`; verify real tag, geometry and current service hooks.
- Make a busy-but-bounded reference street: market seller, guard, smith, courier, helper/elder, child playing safely, tavern worker and 1 optional secret *concept* using authored existing buildings. Use *approved* modular appearance or clearly labeled fallback. If first actual secret lacks signed-off quest/reward, keep its hint as a non-rewarding concept and do not falsely present a live quest.
- Test one real NPC schedule -> walk/work/interaction interrupt -> TH/EN dialogue -> existing actual quest -> map waypoint -> event -> one server-authoritative claim -> journal update -> rejoin/denial/cleanup. Test one accepted user+five-hero traverse without blocked doors and one ordinary quest action; record real evidence. Human review appearance/feel separately.
- Instrument NPC counts, path computations, frame times, memory, replication and LOD promotions. If a scenario fails, fix the narrow issue before cloning to cities.

**W2: Six-city character/civilization roll-out**
- Expand each civic city with distinct roles, trade/architecture, multiculture, optional side activities and named host/envoy integration. Physical NPC population is staged based on benchmarks. Keep mixed residents present in all six; link service interaction to existing market/tavern/craft rather than adding false market orders.
- One optional secret *proposal* per city, then sequentially implement approved quests through real service/receipt system. Verify no new lore overwrite of named existing cast, including Crosshaven Chapter05 continuity.

**W3: Regions & authored story continuity**
- Novice, Greenwood, Ironveil, Ashen, Tower floors/story courts, Chapter05 Crosshaven, Archive Heart, personal Guild islands and world events: add role/secret/hint coverage with actual source coordinates; don't overpopulate boss arenas, safe routes or a personal player's island. Match action/puzzle/escort/quest receiver to source events and tested return fallback. Crosshaven court/civic physical identity is a separate reviewed task.

**W4: Body variants, costumes, animation and ambience**
- Finish genuinely imported Human Standard/Heavy + two layered/rigid outfit families, per-role pose/sound, actual Studio/devices/human reviews; expand through remaining 13 prescribed body presets and outfits by fit family. Only propose new bodies after tests. Character actor/quest labels/footstep/camera must remain safe and performant.

**W5: Quest-ready future expansion**
- When approved, attach named person quests, optional hero memories, world reputation, seasonal civic events, Federation/territory/world event roles with reviewed identity and reward contracts. A quest-ready hook is *not* permission to switch on Federation, war, commerce, paid assets or unsanctioned world-altering story states. Keep GL-2.0 required systems and unresolved P0 decisions visible.

## 10 — DELIVERABLES REQUIRED FROM YOUR ACTUAL EXECUTION

Within reviewed, owned repo scopes, create/update only real necessary artifacts (proposed directories must be reconciled first):
1. `NPC_WORLD_SOURCE_AUDIT.md`: exact source-backed census vs design proposal, physical zones, existing cast, quest and appearance status, blockers.
2. `NPC_POPULATION_BUDGET.json` / role atlas: proposed per-zone registered and active budgets, per-time occupancy, explicit perf gate, server instance costs, role weights; all proposed numbers clearly labeled.
3. `NPC_IDENTITY_AND_LIFECYCLE.md` and typed Luau module *only after owner approval*: stable identity, lifecycle, deterministic schedule and quest-ready contract; no second network/profile authority.
4. `NPC_ROLE_AND_CULTURE_BIBLE.md`: six unique cities plus Central, role archetypes, mixed races, govt/lore decisions and safe family/child behavior.
5. `NPC_SECRET_QUEST_PROPOSALS.json`: region/clue/NPC/quest/reward proposals, all `DESIGN_ONLY` until approved and correctly bound, no fictional runtime IDs.
6. `APPEARANCE_VARIATION_AND_FIT_MATRIX`: 13 body presets, 4 races, role outfits, source IDs, asset/import/permission state, R6/R15 coexistence and devices.
7. `NPC_QUEST_WORLD_INTEGRATION_CONTRACT`: existing QuestService/Content/Journal/Nav/Population and responsive UI integration, exact signal authority, save/rejoin/uncertain write safety.
8. `NPC_WORLD_QA_MATRIX`: tests for speed/perf, schedules, disappearance, race/outfit/boss/quest, disabled/locked/claimed secrets and cross-session behavior; initially `NOT_RUN`.
9. `GOLDEN_CITY_SLICE`: source edits + actual deterministic local tests + supervised Studio evidence when connected; use standard PR review and real commit/tree/asset SHA.
10. Updated `MASTER_CONTROLLER_DASHBOARD` with S13/S14/S15 tasks, Forge ownership, blockers, evidence and next safe actions. No auto-merge.

For each area provide **PROPOSED / IMPLEMENTED / LOCAL_TESTED / STUDIO_TESTED / PHYSICAL_DEVICE_TESTED / HUMAN_ACCEPTED** independent booleans (or statuses) backed by actual evidence. Report measurable performance against an identified target device; do not claim a Roblox NPC hard limit from proposed roster sizes.

## 11 — TEST & QA GATES: WHAT PASS ACTUALLY MEANS

**Behavior and world:** server reaches NPC by canonical ID at real place/zone; actual prompt distance and owner safe-zone checks; NPC performs credible role animation, returns home after interrupted dialogue, does not duplicate while crossing portal, remains available for quests, no path stuck/fall. Player with FIVE owned heroes passes doors/bridges/markets; no crowd blockage or telegraph occlusion. `NpcId` stable over spawn/despawn and reconnect.

**Population:** deterministic distribution and anti-clone sampling; density adjustments do not change story NPC service or rewards; capped path calculations/animated rigs; switch between day states without visible teleport spam; pooled models clean owners/tags/connections; memory/instance trend stays bounded after 30–60 minute representative play, with actual measured time and platform logs.

**Quest/secret/security:** hidden hint -> discovery -> objective -> one reward; forged client discovery rejected; cancelled/out-of-range/foreign/prohibited/no-permission prompt rejected; duplicate receipt grants exactly once; interruption, disconnected player, save uncertain, rejoin and role-specific dialogue changes preserve progress. Cosmetic race does not gate mandatory story or valuable permanent combat points. Multiple players cannot claim each other's personal story/quest. No unpublished IDs are treated as usable sound/model/animation.

**Appearance:** all current/accepted presets show full coverage and correct rig; clothing/cages are real imported where asserted; expressions/hair/tusks/beards do not clip; no animation/hero weapon contact regression; no player equipment granted from an NPC model. Face and age presentation safe. Test in PC Studio (actual), device emulation (only layout/approximation), physical Android/iOS (separate evidence), four simulated clients same Studio server and distinct live servers only after scoped authorization.

**Code:** run `python tools/agentic/forge.py doctor`, `validate`, `plan`, `studio.py validate/verify`, current affected Luau tests, `tools/validate.ps1` and the complete source/boundary tests on the final merged candidate. Avoid claiming passing checks unless actually executed on that final commit. Use real accepted Forge lease and independent reviewer; never overwrite raw receipts. Tool exports/assets are not QA of game play.

**FAIL-CLOSED conditions:** stale or duplicate action, invalid source ID, unknown schedule anchor, model with missing body import/cage, unauthorized reward, missing right to use a third-party asset, unmatched head SHA, conflicting file ownership, Studio instance not verified, unbounded population spike or persistent state mutation risk. Stop only affected changes, report concrete blocker and safe fallback.

## 12 — INITIAL REPLY FORMAT TO THE OWNER & COORDINATOR

Give a concise but source-grounded plan before coding:

- `AUDIT SHA / BRANCH / WORKTREES / VERIFIED TOOL CAPABILITIES`
- `CURRENT REAL INVENTORY`: named NPCs vs world model count; actual zones, quests, four-race assets/imports, available GUI/animation contracts; **no invented counts**.
- `DESIGN BUDGET PROPOSAL`: per-zone roster, near-active budgets as experiments, proposed body additions with cost-vs-visual-benefit, role diversity and monarchy decisions requiring owner signoff.
- `TOP 10 GAPS`, with gameplay/security/perf priority and source owners.
- `WORKER ASSIGNMENTS S13/S14/S15 + Content/Character`, exclusive paths and actual Forge claims.
- `W1 GOLDEN CITY SLICE`: exact existing NPC ID, actual map anchor, existing quest, step-by-step test and evidence requirements.
- `APPROVAL REQUIRED`: only scope/lore/paid/import/other genuinely blocking decisions; choose safe defaults when not required.
- `NEXT ACTIONS`: start all dependency-ready local work; maintain honest task/evidence ledger and a reviewable PR, no merge/publication.

**START NOW** on the currently checked-out repository. Audit and reconcile first. Then implement a real small, complete and safe W1 increment; keep the long-term multi-city / multi-race / secret-content roadmap visible. Report what is source-backed, what is merely proposed, what was run, what failed and who owns the next integration step. Every NPC could eventually be a quest giver; today, only some have earned the right to ship a working quest.
