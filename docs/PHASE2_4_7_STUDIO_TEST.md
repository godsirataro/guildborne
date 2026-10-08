# Phase 2.4–2.7 Studio verification

Testing on 2026-09-28 through Roblox Studio MCP in Guildborne staging, place `86788611613035`, universe `10768425213`. All progression uses isolated `GB_Player_phase27_staging` and matching audit storage. A genuine v3 record from the previous isolated QA namespace was copied into this test store; the original player staging store is untouched.

## Recorded results

- v3→v4 migration: complete legacy `data` matched after removing the one new `expansion` field. Schema changed from 3 to 4 without resetting any legacy progression or equipment.
- Native resource intents: distant requests rejected; owned nearby nodes awarded materials with saved cooldowns. Assisted positioning was used to test authorization separately from traversal.
- Native UI: opened Base, previewed Warehouse, rotated it, and placed it through actual mouse input. Created Quarters and Blacksmith with earned materials through the public command remote; moved Quarters without additional cost; rejected a placement over the access lane; crafted an Iron Ingot.
- All five heroes and the player advanced to Class 2. Hero active attributes showed Duelist, Guardian, Sniper, Elementalist and Cleric arts. Elf choice changed player stats and rendered ear attachments.
- Floors 1–5 cleared through real combat with the assisted-position sampler. Tower 5 unlocked checkpoint 5 and Class 3. Warlord, Sword Saint, Rune Knight, Archmage and Bard unlock/learn/equip commands succeeded.
- First floor-6 attempt failed after a damage-focused tank loadout let ranged enemies focus the player. Failed state retained checkpoint 5 without a clear reward. The retry uses Ward, Guardian Plate and the Knight's selectable starter taunt. Bard/Commander support is explicitly party-wide and separately tested for ownership/range/downed exclusions.
- A rapid Studio restart encountered the previous lease still closing. Normal RetryLoad waited for expiry; no lease or profile reset was used to bypass ownership.

An assisted-position sampler is not a normal-movement or physical-device acceptance test. No published-client or multiplayer pass is claimed.

## Final acceptance observations

- Defensive retry cleared floors 6–10, including the floor-10 boss, using ordinary server damage and reward commits. Highest floor 10 and checkpoint 5 persisted. Shadow Dancer advanced, learned and equipped through public intents after the earned unlock; a repeat floor recorded its native ability casts.
- Real DataStore Stop/Play restored the entire saved data plus schema version and revision exactly at revision 204. This includes three buildings, gather flags, six separate builds, player ancestry, all inventories/assignments, currencies/XP and completed tower progress. No lease bypass was used.
- TH portrait Skills inspected at 359×718 with TouchEnabled true: content scrolls and every expansion action button measured 52 pixels high. EN landscape Base also rendered. Navigation for these viewport inspections was triggered by the existing server view-navigation field; this is layout inspection, not a claim that MCP mouse input reproduces physical touch.
- R6 and R15 model component checks applied Human/Elf/Dwarf and armor/accessory visuals: Human has no ancestry ornaments, Elf/Dwarf have two welded non-colliding/non-touching/non-queryable ornaments each. Temporary test models were destroyed.
- Six isolated effect component checks produced Physical 1, Area 2, Guard 1, Heal 2, Drain 1 and Slow 1 local parts; all expired, leaving zero. Actual tower sampling across 600 observations peaked at 10 simultaneous effect parts and 560 world BaseParts in this solo scene. These are scene observations, not an FPS or physical-device benchmark.
- Restarted Studio output was clean: profile loaded revision 204 and server/client ready, with no runtime errors.

## Evidence

- [Automated gates](evidence/phase27-validation.txt) — 108 tests, strict Roblox analysis, compile, Rojo build and repository checks.
- [Legacy profile](evidence/phase27legacy.json), [migrated profile](evidence/phase27migrated.json), [base actions](evidence/phase27base.json), [failure](evidence/phase27failure.json), [floor 6–10 telemetry](evidence/phase27final.json).
- [Rejoin and presentation checks](evidence/phase27-final-checks.json).
- [Tower combat screenshot](evidence/phase27-tower.png), [Thai portrait Skills](evidence/phase27mobileSkills.png), [English landscape Base](evidence/phase27mobileBase.png).

These are functional procedural motions/effects and prototype prefab geometry. Bespoke animation clips, final sound/art, physical touch/FPS testing and published multiplayer acceptance remain later production/validation work.

## Final cleanup

A temporary hero cosmetic component check confirmed joint motion changes for Area/Heal/Drain/Guard actions, then destroyed the clone. All 57 runtime sources match disk after final synchronization; no QA probe is in the runtime tree. Studio Play is stopped, device simulation is off, and the normal Bootstrap store prefixes are restored. Isolated QA data remains separate from the original staging profile.
