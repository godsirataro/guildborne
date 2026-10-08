# Guildborne — game design

> Launch scope decision — 2026-10-02: The user requires personal guild islands, portals in every launch city, public/friend visits, quest-gated Robux plot purchases with required material contributions, freely positioned buildings and purchasable permanent mixable building themes together in the FIRST public game release. See [authoritative scope and acceptance](LAUNCH_GUILD_ISLANDS.md). This supersedes older deferral of these specific systems, including theme monetization to Phase9; other release gates remain. Development resumed by the user on2026-10-03. Earlier15%quota pause is superseded; current evidence and remaining launch work are recorded in [the implementation checklist](uat01/WORK_CHECKLIST.md).

Status: Phase 1 accepted for solo handoff; Art Phase 1.5 closed by user approval. [Phase 1.6](PHASE1_6_IMPLEMENTATION.md) adds five visible hero followers/classes and ten items. [Phase 2.1](PHASE2_1_IMPLEMENTATION.md) implements companion PvE combat, five starter abilities and secure camp rewards, Studio-verified and not published. The [expansion plan](EXPANSION_PLAN.md) records the user's new direction: playable leader classes, tiered advancement/skill trees, shared inventory with separate equipment, resource-funded base building, a ten-floor tower and distinct fantasy races. Phase 2.2 now implements the player starter-class foundation, with independent XP, PC/touch combat, Human/Class 1 references and safe migration. Phase 2.3 inventory/equipment is also implemented; see [its report](PHASE2_3_IMPLEMENTATION.md). Remaining expansion systems are planned, not implemented. See [the delivery report](PHASE2_2_IMPLEMENTATION.md). The [roadmap](ROADMAP.md) controls delivery scope.

## Player promise

Updated direction: an isekai fantasy guild leader who fights alongside up to five AI heroes and develops a personal base. Explore/gather/climb the tower → earn XP, materials, equipment and blueprints → develop player/team/base → tackle harder encounters. Race is separate from combat class; Class 1/2/3 advancement is separate from Epic/Legendary prestige and Secret unlock routes. Existing owned heroes and progression must survive these additions. See the expansion plan for the proposed branches, special-class catalog, facilities and first race set.

Build. Trade. Conquer. Start as the master of a small adventurer company, make useful decisions about its people and equipment, and eventually cooperate with real players to shape a contested world. Progress should come from preparation, class synergy, production, and strategy as well as time invested.

A **Personal Guild** is one player's base and NPC adventurer roster. A **Player Guild** is an organization of real players, with shared governance and later military objectives. They use distinct IDs, screens, permissions, and progression. A new player never needs a Player Guild to finish the introductory experience.

## Loops and pacing

| Horizon | Decisions and rewards | Purpose |
| --- | --- | --- |
| First session | Tutorial → recruit → form party → quest → equip → improve hall → save/rejoin | Establish trust and comprehension; target 10–15 minutes, to be playtested |
| Short session | Choose quest or resource route → adjust party → resolve encounter → allocate rewards | Give useful choices in 3–10 minute sessions |
| Medium term | Gather → craft → equip or sell → upgrade buildings → unlock regions | Make materials and professions useful |
| Social | Join Player Guild → cooperate on dungeon/boss → fund shared research | Reward coordination without mandatory daily attendance |
| Endgame | Prepare war → contest objectives → hold territory → alter resource production → trade | Connect strategy to supply and demand |
| Seasonal | Optional objectives, rankings, territorial contest, cosmetic recognition | Renew competition while retaining permanent progression |

Loss costs time and preparation before it costs irreplaceable progress. No permanent adventurer death or forced full-loot PvP is planned. Recovery routes must remain available when the player has little Gold. Returning players get a clear next action, not a wall of expired obligations.

## Personal Guild and adventurers

| Facility | Long-term purpose | Introduction |
| --- | --- | --- |
| Guild Hall | Progression tier and base identity | Phase 1, levels 1–2 only |
| Tavern | Recruitment and roster management | Phase 1 as a menu, no building upgrade |
| Quest Board | Available quests and active run | Phase 1 as a menu |
| Warehouse | Inventory and later capacity | Phase 1 inventory menu |
| Blacksmith / Alchemy | Equipment / consumable crafting | After inventory/build foundation; bounded Phase 2.7 work |
| Barracks / Training Ground | Roster capacity / training choices | Later personal progression |
| Research | Specialization choices with costs | Later progression, after balance evidence |
| Market | Gold trading access | Phase 4 |
| Portal | Group activity travel | Phase 3 |

Future combat classes: Warrior, Knight, Archer, Mage, Priest, Assassin, Paladin, Necromancer. Future professions: Miner, Gatherer, Blacksmith, Alchemist, Merchant. Profession identity is separate from combat class so economic players need not sacrifice all combat usefulness.

An adventurer has stable identity, class, level/XP, base stats, unlocked skills, traits, equipment references, profession/job progression, and later element affinities. Runtime stats are derived from versioned content. Design counters and situational strengths: a common Priest can outvalue a rare damage dealer in a sustained encounter. Rarity describes scarcity or option breadth; it is not an unconditional multiplier ladder. Recruitment is a known choice in Phase 1, with no paid randomness.

## World and combat direction

Historical Phase 1 uses server-timed expeditions; Phase 1.6 expands the NPC party to five. Phase 2.1 now runs real-time companion PvE with server-authoritative attacks and abilities. Phase 2.2 adds the leader's own playable class and combat controls; Phase 2.3 now implements three-slot player/hero equipment, shared storage, a Gold shop and comparison/filter UI. Phase 2.4 adds a bounded gathering/building slice and Phase 2.6 a ten-floor tower; a full open world is not required for either. Real-time avatar-controlled PvP remains a later decision gate requiring its own prototype; a 30v30 promise has not been performance-proven.

| Region concept | Resource identity / challenge |
| --- | --- |
| Greenwood | Timber, herbs, introductory threats |
| Goblin Valley | Common salvage and iron routes |
| Iron Mountain | Ore concentration and armored foes |
| Undead Kingdom | Alchemy reagents and sustained encounters |
| Frozen Continent | Cold-adapted materials and attrition |
| Dragon Valley | Rare crafting components and coordinated bosses |
| Demon Realm | Endgame encounters and specialized preparation |

Quests, gathering, dungeons, raids, rare enemies, world bosses, and events reuse encounter/reward contracts but are unlocked in separate phases. Content modules declare IDs, prerequisites, encounter definitions, reward tables, duration, and revision. A new region should usually require content and art rather than service rewrites.

## Economy, social systems, and fairness

Gold and items belong to the game economy. XP is nontransferable progression. Crafting connects common inputs to useful gear, upgrades, consumables, and guild construction. The [economy](ECONOMY.md) specifies faucets and sinks; the [market](MARKETPLACE.md) offers understandable Buy now / Sell now and advanced target-price orders.

Co-op begins with presence, invitations, party membership, one dungeon, and one boss. Use platform text chat and supported communication permissions when introduced; filter displayed user-written guild names/descriptions. Guild membership is not permission to access another player's Personal Guild inventory. See [official text chat overview](https://create.roblox.com/docs/chat/in-experience-text-chat).

Wars are objective-based competitions with tank, DPS, support, siege, scout, and commander roles. Territory can increase production of a resource, but cannot exclusively lock basic progression materials behind one organization. Territorial effects change supply or costs; no system commands players to trade at a particular market price.

Dragon Invasion, Great War, Plague, and Drought are future configurable events. Each has a schedule, affected regions, encounter/resource modifiers, objectives, and a content revision. Cap stacked modifiers, announce duration, and preserve baseline routes. They influence demand and supply without directly setting traded prices.

Seasons may reset rankings, season objectives, and territory ownership. Adventurers, normal inventory, Gold, Personal Guild upgrades, and paid entitlements remain permanent by default. Any future exception requires a separate explicit design decision and player communication.

Cosmetics, skins, mounts without combat advantages, decorations, effects, and emotes are preferred monetization. VIP, season passes, inventory convenience, and additional market slots need fairness review; no paid combat stats, production multipliers, lower trading fees, or purchased siege advantages. Purchased cosmetics are account-bound. Monetization is deferred to Phase 9 and platform rules must be rechecked then. No player cash-out, external item trading, currency conversion, gambling, cryptocurrency, or settlement implementation is in scope.

## Mobile-first UX

Use four primary destinations: Guild, Party, Quests, Inventory. Market and Player Guild destinations appear only when those features exist. Show one primary action per panel, readable resource costs, confirmation for irreversible spending, and an explicit Saving / Saved / Retry state. Never present an uncommitted reward as saved.

Project targets, not Roblox limits: minimum 48×48 logical-pixel touch targets, default body text near 18px, readable contrast, scalable layouts at 360×640 and 640×360, safe-area handling, and no hover-only instructions or drag-only equipment actions. Provide tap-to-equip, large back controls, reduced motion, labels beyond color, and scrolling without horizontal text clipping. PC supports mouse, keyboard navigation, and the same core flow. Keep UI localization-ready and avoid text embedded in art.

Target 30 FPS on a selected low-end mobile test device and 60 FPS on the chosen desktop baseline. Document actual device and scene load before claiming these targets passed. Pool effects later only if profiling shows a need; avoid per-frame work for management screens.

## Exact Phase 1 scope

One Personal Guild; three fixed recruitable adventurers (Warrior, Archer, Priest); one party with up to three members; three quests in Greenwood; one enemy definition, Goblin Scout; Gold and adventurer XP; eight item definitions; one weapon slot per adventurer; Guild Hall level 1→2; save/load; and minimal functional UI. The starter recruit is free and the next two are earned through quests. All three quests remain completable without a paid or rare recruit.

| Quest | Planned encounter | First-clear rewards; repeat policy |
| --- | --- | --- |
| Trail Watch | One Goblin Scout, 15 seconds base | 30 Gold, 20 XP per assigned member, Training Sword ×1, Herb ×2; repeat gives 10 Gold, 5 XP, Timber ×1, Herb ×1 |
| Timber Escort | Two Goblin Scouts, 25 seconds base | 40 Gold, 30 XP per assigned member, Timber ×6, Iron Ingot ×1; repeat gives 12 Gold, 8 XP, Timber ×2, Iron Ingot ×1 |
| Quarry Patrol | Three Goblin Scouts, 35 seconds base | 60 Gold, 40 XP per assigned member, Iron Ore ×6, Iron Sword ×1; repeat gives 15 Gold, 10 XP, Iron Ore ×2 |

These implemented initial values still require balance playtesting. Eight items: Timber, Iron Ore, Iron Ingot, Herb, Training Sword, Short Bow, Apprentice Staff, Iron Sword. Ingot/Herb are Hall inputs; Iron Sword is a stronger Warrior weapon. This gives all eight items utility without crafting or consumables. The Warrior can complete the introduction with baseline stats; Archer/Priest recruitment grants one compatible starting weapon from the same catalog. Every 50 accumulated XP adds a level, capped at 10. Equipped attack shortens future timers, minimum 10 seconds; encounter counts are presentation data until later combat work.

Tutorial flow: join/load → welcome → recruit Warrior → create party → Trail Watch → claim and equip Training Sword → recruit Archer for 20 Gold → Timber Escort → recruit Priest for 20 Gold → Quarry Patrol → upgrade Hall for 80 Gold + 6 Timber + 6 Iron Ore + 1 Iron Ingot + 2 Herbs → leave → rejoin. First-clear Gold totals 130; recruitment plus Hall costs 120, leaving 10. The values demonstrate feasibility without forcing that exact order. Repeat quests recover materials or missed choices. Hall level 2 grants a visible milestone and cosmetic hall change only.

An active quest persists its run ID, selected party snapshot, reward revision, and server deadline. Rejoining can resume or claim that single existing run; it never starts unattended chains or regenerates rewards. No cooldown skipping, player trading, crafting, full building simulation, dungeon, multiplayer party, or battle input is added in this slice.

Success: a new tester completes the full flow unaided, sees no critical Studio errors, and retains committed progression after rejoining. Malicious client requests cannot grant Gold, XP, items, or completion. Failure/retry screens and full inventory handling are part of the slice, not polish to postpone.
