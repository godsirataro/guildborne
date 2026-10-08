# Offline regional combat — 2026-10-03

The full offline build now binds the three regional maps to personal four-enemy encounters for a selected player class. Activation requires Studio, PlaceId=0, GameId=0, memory persistence and the server-injected reward adapter. Staging/live activation remains off. Map geometry is shared; owned encounter actors and telegraphs are private presentation, with independent server ownership checks. Cooperative/shared-boss policy and real multiplayer acceptance remain unfinished.

City portals and arrival docks are safe. Combat bounds end before local Z=90; returning through a portal suspends the existing encounter rather than recreating its death ledger. Re-entering resumes it. Camp/Tower enemies remain separate, and the companion combat walk/retreat and downed-player recovery use regional destinations. Region membership does not by itself authorize damage: the session must be explicitly enabled and both entities must be inside its combat bounds.

The regional bridge uses the existing damage/targeting path, including defense, owner, active state, line of sight and participation. Threat, taunt and slow are supported by the regional brain. Grounded movement and asynchronous detours feed the authored boss telegraphs. Regional art is still a native blockout/rig-import work item, not finished animation.

The reward adapter stores a bounded slot per enemy and retains the exact command after uncertain results. Before/after-write failures and an exception after successful commit were tested against the real domain harness, including an intervening language mutation. Gold/materials were awarded once. An old session/epoch cannot replay a pending ticket into a new session. Known no-write preflight rejections may refresh an unsubmitted revision; uncertain writes never do.

## Actual offline play evidence

All gameplay mutations below used visible UI/keyboard controls. Server character repositioning shortened movement between prompts and the target; it did not grant items, health, damage, XP or Gold.

1. Selected Warrior (revision1), entered Greenwood through E portal (revision2). Four owned regional enemies spawned. Combat buttons were hidden on the arrival dock.
2. F damaged the Scout135→129 through the ordinary combat remote. The initial player/Rowan team subsequently lost; player recovered at the Greenwood safe landing. This flags an onboarding/balance concern, not a passing difficulty verdict.
3. Recruited Rowan, saved party, completed the actual Trail Watch timed expedition (revision7):30Gold,20RowanXP, training sword and2herbs. Recruited Sage for20Gold (revision8) and saved Rowan+Sage party (revision9).
4. Actual F/Q actions plus companion AI defeated Greenwood Scout. Server logged CombatReward at revision10,3Gold with reason `encounter:greenwood_scout`. Replicated state confirmed Gold13, playerXP3, RowanXP23, SageXP3. Enemy state became Rewarded; no direct grants were used.
5. Returned to City through E. The regional combat attribute cleared and the encounter was suspended out of Workspace.
6. Entered Ironveil and Ashen through their actual portals. Each spawned its four owned actors and hid combat buttons on the safe arrival dock. A brief player/companion attack reduced Quarry Raider210→191 and Arcane Sentinel260→241; each retreat and E return reached City. Neither enemy was defeated, so these are activation/damage/return checks, not regional victory/reward acceptance. Final travel revision15; no runtime exceptions appeared.

Validation at this checkpoint:436domain tests,5,000market orders with zero invariant violations; strict analysis, compile, repository and full offline build pass with182runtime Luau files. Earlier isolated bridge checks verified defense, foreign-owner rejection, wall blocking, one reward and cleared participation on respawn. Two synthetic owners shared a single unmodified terrain model with8actors and no duplicated floors. This does not substitute for a real two-client test.

Outstanding: actual Ironveil/Ashen fight and reward acceptance, regional death/re-entry stress, all12enemy/two-phase boss live acceptance, native articulation/retarget and localized enemy labels, player guide/balance, regional quests/bestiary, real multiplayer/device/performance/save acceptance, Staging activation review and human UAT. No publication or paid-product activation occurred.

## Subsequent native and presentation checks

The manager fixture passed with two synthetic parties across all3regions: foreign-party damage blocked, safe docks excluded, travel reused the same enemy records, one party's suspension left the other active, and Tower state restored camp enemies. It used actual map geometry but no player profiles. The actual client visibility controller hid foreign actors and late-added telegraph parts, preserved authored transparency and remained correct after reparenting.

All12regional models now attach to the existing six-joint cosmetic enemy animator using authored BindBone metadata. Front quadruped legs map to the front joint pair, rear legs to the rear pair. Their334art pieces and72motors passed909native checks, including idempotency, pivot preservation, noncolliding assemblies and tag registration. The real client animator visibly changed Scout and Boar joint transforms while their authoritative roots stayed fixed; the temporary camera and fixtures were restored. This is a6joint runtime adaptation, not completion of16bone retargeting/blended imported clips.

Thai display names cover all12enemies and9regional attack names. These additions remove native articulation/localized-label binding from the outstanding list above; motion polish, imported-clip retargeting and all12visual action reviews remain open. The source compile/strict/repository/offline build remains182runtime files.

## Regional guide checkpoint

All12 enemies are exposed in three selectable regional guide pages in EN/TH. Stats come from AdventureStats shared with the combat bridge, rewards from the authoritative reward definitions, and loot entries are copied. Actual UI selected Ironveil/Ashen and displayed Thai Arcane Warden:1100HP,35Attack,3Defense,24stud range,2second interval,24Gold,20XP per credited member,3herbs. Screenshot inspection confirmed legible Thai text within the scrolling card. This completes basic regional bestiary binding; touch/controller acceptance remains open.437domain tests passed, including guide/catalog agreement and copy isolation. Strict analysis (two existing warnings), compile, repository validation and full offline build passed at184runtime files. Staging source unchanged.

## Contracts and shared-damage matrix

Six provisional Ghar contracts progress from two Greenwood Scouts to Forest Captain, two Quarry Raiders, Quarry Guardian, two Arcane Sentinels and Arcane Warden. The first requires claimed A Company Takes Shape. New acceptance fails closed when regional combat is unavailable; NPC offers/tracker exclude unavailable contracts and journal buttons explain availability. Existing active/claimed tasks remain readable. Definitions add25journal tasks total, retaining the original19IDs; no profile schema replacement. EN/TH descriptions and ordinary NPC proximity checks apply.

The complete six-contract chain passed with committed matching kills only, no pre-acceptance credit, before-refresh isolation, repeated callback/claim protection and rejoin. Actual UI displayed all6prerequisite locks and the first contract description/reward. Player completion is still pending. Domain439PASS with5,000orders/0invariant violations; strict/build/compile/repository/offline checks pass184runtime files.

The new native damage matrix passed all12actors through AdventureCombatBridge/CombatDamage, including defense, Crystal Shaman healing, both phases of all3bosses and exactly12reward tickets. It uses synthetic heroes with large test health/attack and no player profiles, so it does not establish player difficulty or replace live boss victory acceptance. Evidence: validation-regional-damage-matrix.json.

## Actual Greenwood contract and boss loop

All new gameplay mutations used actual E/click/keyboard actions in memory-only Studio. Rowan/Sage, Trail Watch, city_gate and company_reinforcement were completed normally. Ghar dialogue showed both old and new contracts; accepting its second link committed at14. Two actual Scout defeats (F/Q with party) committed3Gold each at16/17 across natural respawn and advanced the journal1/2→2/2. Ghar ready contract moved to the first dialogue slot. Claim at19 granted20Gold and unlocked Forest Captain. Knight/Mage recruitment and four-companion party were paid normally.

First Captain attempt: player stood close, was downed, returned safely; boss reset. Second attempt started farther away with Knight in front, used actual W/S movement and Focus plus attacks; Captain650HP reached0, player remained30HP at final check. Reward at25:12Gold+2Timber. Ghar claim at27:35Gold; Ironveil contract accepted28. This is one successful party configuration, not a balanced-difficulty verdict. Debug character reposition only shortened travel/initial approach; no health, damage, loot or XP grants. The console contains an MCP/CoreGUI mouse-position warning from setup, no observed gameplay runtime exception. Evidence: validation-regional-contract-victory-console.json and validation-forest-captain-victory-console.json.

## Ironveil contracts and companion evasion

Actual party combat defeated two Quarry Raiders, committing5Gold at revisions30/31. Ghar turn-in at34 committed30Gold; Guardian contract accepted35. One setup assertion checked City before asynchronous travel finished; travel subsequently committed, then normal E return/turn-in succeeded. Evidence: validation-ironveil-raiders-victory-console.json.

Earned Gold bought Guardian Plate for Knight, Woven Robes+Vitality Charm for Priest, Iron Sword for Warrior; their existing Knight/Mage/Priest weapons were equipped through Inventory. Initial Guardian attempt still downed the frontline/player. Companions standing in committed telegraphs prompted regional evasion work; Guardian victory is not claimed.

AdventureEvasion picks a nearby safe endpoint with body clearance against overlapping Circle/Line/Cone/Ring warnings. RegionalEvasion checks the complete straight corridor using existing ground/slope/support/swept collision queries and region bounds. CombatService walks there using Humanoid MoveTo, invalidates stale navigation, holds until impact, and bypasses follower recovery teleport. Explicit Regroup/Retreat orders retain priority. No player auto-dodge or immunity is added.

442domain tests pass. Native3region geometry queries and nonquery-wall R15 escape pass15checks (~1.16ms for3initial selections); standard R15 walked8.18studs before1.4second Hammer Fall. A separate full CombatService synthetic-party fixture observed13Evade ticks,8.00studs physical motion and40HP retained at impact. No real profiles touched. Strict analysis (two pre-existing warnings), compile, repository and both builds pass186runtime files. Real party/boss difficulty and device/multiplayer acceptance remain open.

## Complete six-contract live chain on evasion build

A fresh memory-only profile repeated normal recruitment, expedition, prerequisite claims and the complete six-contract chain through actual UI/E/keyboard. Movement-only debug reposition shortened travel/initial encounter approach. Player lateral dodges used ordinary A/D input in response to observed telegraph attributes; companions used server evasion. No damage/health/item/XP/Gold grants were used.

Greenwood2Scout receipts16/17, quest19; Captain receipt29 (12Gold+2Timber), quest31 (35Gold). Ironveil2Raider receipts34/39, quest41 (30Gold); Guardian receipt48 (18Gold+2Iron Ore), quest50 (50Gold). Ashen2Sentinel receipts53/54, quest56 (40Gold); Warden receipt63 (24Gold+3Herbs), quest65 (70Gold). All purchases/equipment assignments are in validation-regional-chain-live-console.json.

Final read-only snapshot: revision65, all6regional contracts Claimed, Gold172, playerXP226/level5, materials timber2/herb5/iron_ore2. Party Knight/Mage/Priest/Warrior. Guardian live samples show16evasion observations and phase2; its subsequent inspection found a respawned actor, with receipt/journal proving the prior victory. Warden34samples show11evasion observations, both attack names, phase2,0HP/Rewarded and player53HP. Forest post-evasion sample also captured0HP/Rewarded/player30HP.

Quarry setup had a failed standing-in-warning attempt before evasion. The final successful chain uses the improved behavior. Tool-side assertions from checking travel too early and a CoreGUI setup click warning remain in the raw console; subsequent ordinary E retries and state reads confirmed committed travel. Delaying input after debug reposition improved prompt reliability. No gameplay exception was observed. This proves a single offline party path, not balance for every class/device or multiplayer acceptance.

## All twelve enemy live rewards

Continuing the same earned/equipped party after six contracts: Greenwood Archer receipt67=4Gold, Boar68=4Gold+1Herb; Crystal Shaman71=6Gold, Stone Guard72=6Gold+1Stone; Rune Caster75/76=8Gold each and Rune Hound77/78=8Gold each. Runes naturally respawned during tool/model pauses and were defeated again; these totals do not imply a single death per type. Final City return79. Captures for each of the six additional types show0HP/Rewarded; Boar/Caster/Hound also show companion Evade observations.

The full console contains receipts for all12distinct IDs. Live victory/reward acceptance is now covered for this one offline party. It does not replace native support-heal checks, full simultaneous encounter stress, all-class balance, visuals/device/multiplayer/save acceptance or human review. All progression still used visible UI/keyboard; debug reposition shortened travel/initial approach only. Evidence validation-twelve-enemies-live.json and validation-twelve-enemies-console.json.


## Presentation and equipment follow-through

Five-member HUD now preserves explicit name/HP lines on short viewports;10EN/TH size cases plus actual full-party capture passed. Regional countdown timestamps and audio cues use separate attributes, so Line/Cone/Ring never invoke the old circular warning effect. Native12enemy matrix validates timestamps/impact cleanup; client fixture validates owner visibility, once-only and stale-cue suppression and cleanup. Audio IDs remain blank: this verifies cue routing, not audible playback. Evidence: validation-regional-presentation-native.json;442domain tests/186runtime files passed.

Fresh-profile UI then completed Trail Watch→Rowan weapon and normal Sage recruitment→staff assignment using new Party→Inventory links. Shared hint projection distinguishes earned/owned/missing weapons and preserves player fallback kits. No economic rules changed. See validation-party-equipment-flow.json.
