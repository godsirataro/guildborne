# City, Guild Zone and remote teams

> Current decision (2026-09-29): Phase 2 is closed under the user-selected implementation/polish scope. Class 2 unlocks at level 30, Class 3 at 70; no Class 4. Actor cap is 100, unlocked at Guild Hall 20 (five levels per Hall). Existing quest/tower/path prerequisites still apply. Large shared city hub is the next Phase 3 priority. See [closure](PHASE2_CLOSURE.md).

Updated 2026-09-28. Implemented in source and staging Studio; not published. This is the current specification, superseding earlier five-hero/Hall-2 limits. Content `slice-3.0-city`, schema v5, 63 runtime sources. See [verification](PHASE3_CITY_STUDIO_TEST.md).

## Play loop
Spawn in the city. Talk to the Herald, Mira or Expedition Master, or take the portal to Guild Zone. Same-server players receive separate islands on one public promenade; bridges connect each island. Visitors may walk around, but gathering, building and equipment mutations use the requesting player's own profile and plot. Departing owners release their island slot; visitors on the removed island return to the Guild lobby. This is server-local presence, not a global server browser or co-op combat system.

## Hall, housing and recruitment
Hall levels 1–10 allow actor levels 5–50: max level = Hall × 5. Excess XP stays banked and is applied on upgrade. Existing v4 profiles retain XP, gear, class paths and tower clears; migration raises their Hall floor only when necessary to preserve existing levels.

Roster capacity = min(50, Hall × 5, 5 + Quarters level × 5), with Quarters level 0 if absent. One Quarters building can be upgraded through level 9. Hall 1 holds 5; Hall 2 plus Quarters 1 holds 10; Hall 3 plus Quarters 2 holds 15. Housing upgrade from level L costs 60L Gold, 8L timber, 6L stone and requires Hall ≥ L+2. Occupied housing cannot be dismantled when roster exceeds 5. Dismantling returns half the original prefab materials, not upgrade costs.

Keep duplicate classes, each with a unique hero ID, XP, rank, skills and equipment assignment. Field party remains five heroes **in addition to the player**. Starter tutorial recruitment remains available; tavern candidates extend the roster.

Tavern levels 1–5 cannot exceed Hall level. Upgrade from level L costs 100L Gold, 5L timber, 3L stone. Scout for 20 earned Gold; class is equally likely among five starter classes. The candidate and rank are saved before hiring. Hiring costs 30 + 10 × rank offset (F offset 0). Replacing an existing candidate requires confirmation and another scout fee.

| Tavern | F | E | D | C | B | A | S | SS | SSS |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 60% | 25% | 10% | 4% | 0.9% | 0.1% | 0% | 0% | 0% |
| 2 | 40% | 30% | 18% | 8% | 3% | 0.9% | 0.1% | 0% | 0% |
| 3 | 25% | 28% | 25% | 14% | 5.5% | 2% | 0.45% | 0.05% | 0% |
| 4 | 15% | 20% | 26% | 21% | 11% | 5% | 1.7% | 0.29% | 0.01% |
| 5 | 5% | 12% | 20% | 25% | 20% | 12% | 4.5% | 1.4% | 0.1% |

Rank adds 2 HP and 1 attack per offset, plus floor(offset/3) defense. Rank F–SSS is independent of Class 1/2/3 and Epic/Legendary/Secret class paths.

## Journal and map
Main: visit Guild Zone, then defeat three Goblins. Side: gather wood four times after acceptance. NPC: deliver six herbs to Mira, with server-checked proximity at acceptance and claim. Journal rewards are one-time and saved atomically. The original three timed quests remain a separate feature.

Map Overview offers three dispatch-only jobs. Choose 1–5 healthy heroes outside the field party. At most three concurrent jobs; a hero cannot occupy multiple teams or be equipped/rebuilt while away. Main quests and NPC conversations cannot be automated.

Power = sum(hero level + rank offset). Success = clamp(base + power × modifier, 5, 100). Chance, outcome, casualties, reward and completion timestamp are committed once at departure. Client views omit hidden outcomes. Offline time counts; the player resolves the job after its deadline. Rejoining or retrying a save cannot reroll it or duplicate rewards.

| Job | Time | Base + power | Success reward | Death / injury if failed, per hero |
| --- | --- | --- | --- | --- |
| Woodlands | 3 min | 90 + power | 8 Gold, 10 XP, 6 timber | 0% / 0% |
| Quarry | 5 min | 45 + 2×power | 30 Gold, 30 XP, 10 stone, 5 ore | 5% / 45% |
| Ruins | 10 min | 30 + 2×power | 65 Gold, 50 XP, 3 ingots, 8 herbs | 10% / 60% |

XP goes to dispatched heroes. Failed jobs give no reward. Overall death risk = failure probability × conditional death probability, displayed before confirmation. Injury lasts 15 minutes from resolution; dead heroes retain identity, items and progression but cannot fight or dispatch until revived. This death model currently applies to remote jobs; realtime combat retains its downed/recovery rules.

## Elixir
One Elixir revives one hero. Earned-currency price: **1,000 Gold**. Optional Developer Product target: **49 Robux**, a provisional small purchase near the user's requested budget, not a guaranteed 19 THB conversion. Roblox controls regional/storefront pricing and purchase confirmation.

Product ID remains **0**, so the Robux button and receipt binding are disabled. No product or live charge was created. When a real product is configured, the server grants Elixir and stores PurchaseId together before acknowledging receipt. Repeated receipts return already committed. Inventory cap 99; receipt ledger cap 1,000 fails closed pending a future retention design.

Gold scouting is currently earned-currency only. Selling Gold later would require revisiting Roblox paid-random-item restrictions and eligibility. See [Developer Products](https://create.roblox.com/docs/production/monetization/developer-products) and [paid random items](https://create.roblox.com/docs/production/monetization/paid-random-items). Fixed-item Elixir is separate from random recruitment.

## Delivery limits and next work
The city, map nodes and housing use procedural prototype art. Hall levels above 2 currently reuse the level-2 silhouette. Existing full-body action poses and bounded skill VFX remain enabled. More authored city/map artwork, unique higher-tier buildings and animation assets are future polish.

Next: two-client island isolation/owner-leave QA, then published staging phone/reconnect checks; create and configure the real Elixir product and test receipt delivery before enabling sales. Co-op, global presence, guild war and marketplace remain later roadmap work.
