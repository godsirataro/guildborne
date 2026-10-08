# Phase 2.2 — Studio verification

Date: 2026-09-28. Guildborne staging place `86788611613035`, universe `10768425213`, official Roblox Studio MCP. Final-source verification passed; publishing was not requested.

## Data safety and exact migration

Before changing runtime code, the Phase 2.1 build created an isolated **v1** fixture by running the full onboarding and five-hero probes against `GB_Player_phase22_migration_staging` and its matching audit store. Final legacy state: revision 33, Gold 10, Hall 2, five equipped heroes, Thai, seven claimed expeditions. The normal staging profile was not used.

The new build loaded that actual backend record and added the unselected Human character. All legacy projected data compared exactly equal; revision remained 33. See [migration evidence](evidence/phase22-migration.json). Populated active-quest preservation is additionally tested at the schema and service levels in the automated suite.

After selecting Warrior and fighting alongside five companions, exact Stop/Play rejoin passed at revision 57, Gold 79, player XP 12; all hero progression/gear/inventory remained equal. See [checkpoint](evidence/phase22-warrior-checkpoint.json) and [rejoin comparison](evidence/phase22-rejoin.json). Later QA changed party/language in the same isolated namespace. Final-source rejoin passed exactly at **revision 76, Gold 127, Warrior XP 22**, with all five companion records, gear and inventory equal. See [final checkpoint](evidence/phase22-final-checkpoint.json) and [final comparison](evidence/phase22-final-rejoin.json).

## Runtime coverage

| Scenario | Result / evidence |
| --- | --- |
| Class choice | Actual desktop UI chose Warrior and confirmed it; selection saved. All five choices also exercised through normal public commands in separate memory Play sessions. |
| Five starter abilities | Warrior Power Strike, Knight Taunt, Archer Piercing Shot, Mage Fireball and Priest Heal observed on actual player avatars. Priest recorded 40 HP healed across three casts. [Knight](evidence/phase22-knight.json), [Archer](evidence/phase22-archer.json), [Mage](evidence/phase22-mage.json), [Priest](evidence/phase22-priest.json). |
| PC input | Virtual keyboard F and Q with down/up generated Basic/Ability server intents, a basic attack and Taunt with a 9-second cooldown. Instantaneous tool keyPress was unreliable; held key events verified the actual handlers. |
| On-screen buttons | Actual BasicAttack/ClassSkill Activated events observed in the mobile simulator; Power Strike applied damage and a 6-second cooldown. Studio virtual-input coordinates required calibration; this is simulated pointer activation, not a physical touchscreen test. |
| Player plus five companions | Real camp damage/heal/rewards, separate player XP, five unchanged party slots. QA driver uses positioning assistance; ordinary camp navigation was separately exercised through MCP character navigation. |
| Downed/avatar reset | Zero HP locked movement; avatar was reloaded while downed and retained zero domain HP/timer. After ten seconds it recovered at guild, then regenerated. [24-second sample](evidence/phase22-downed-respawn.json). |
| Security | 100 simultaneous Basic intents yielded four responses; forged reward rejected, repeated class choice rejected; Gold/revision unchanged. [Evidence](evidence/phase22-security.json). |
| Solo mode | Selected player can save an empty hero party; heroes rest and player remains targetable in camp. Empty expeditions still rejected by automated tests. |

## Mobile inspection

Device discovered from Studio's current presets: Samsung Galaxy A06. StarterGui orientation Sensor; actual TouchEnabled true. Portrait viewport 359×718, landscape 705×338. Class selection scrolls vertically with readable 52-pixel buttons. Player HP moved above portrait movement/jump controls; landscape controls use 48-pixel buttons above jump. Redundant local-player world HP label is hidden; resting/following companion labels are reduced to keep the view readable. TH/EN inspected.

- [Thai class selection](evidence/phase22-class-selection.png)
- [Thai portrait player HUD](evidence/phase22-mobile-th.png)
- [Final English landscape HUD](evidence/phase22-mobile-en-landscape.png) and [measured bounds](evidence/phase22-mobile-bounds.json): skill ends at Y=168, jump begins Y=190; player HP ends at X≈515, jump begins X=610.

Physical-device performance, two-player isolation, published Player rejoin and bespoke animation/audio acceptance remain unrun. Memory class smoke sessions test abilities, not persistence; backend claims refer only to the isolated real DataStore sessions. [Final Studio output](evidence/phase22-final-output.txt) has no runtime errors. Studio is stopped, device simulation reset to default, normal staging configuration restored and runtime source parity verified. The normal staging profile was never opened by these QA sessions. Per-kill storage and NPC ownership retain the bounded-camp limits described in [combat rules](COMBAT.md).
