# Phase 2.3 — Studio acceptance evidence

Tested 2026-09-28 through Roblox Studio MCP in staging place `86788611613035`, universe `10768425213`. All mutations used isolated `GB_Player_phase23_migration_staging` and matching audit namespace. The original staging profile was not opened or reset. No publishing occurred.

## Observed checks

| Check | Result |
| --- | --- |
| Real legacy migration | Built a genuine schema-v2 profile with the prior runtime: revision 39, Gold 30, Hall 2, five heroes, chosen Warrior, active q:10. New runtime loaded schema 3 with unchanged legacy data after excluding only the two added fields. |
| Active expedition transfer | Moved Iron Sword from the away Warrior to the player; q:10 retained its starting snapshot and claimed normally. |
| Native UI purchase/sale | Clicked Leather Vest purchase and equip. Sold the unassigned Training Sword through first-click confirmation and second-click commit; Gold increased 7→13 and the instance disappeared. DataStore acknowledgments may arrive after the immediate click inspection. |
| Three-slot round trip | Iron Sword, Leather Vest and Bronze Ring moved player→Warrior→player. Player final HP/Attack/Defense 34/11/6; unequipped level-3 Warrior 36/8/4. Visual definition attributes matched. |
| Equipped combat | Assisted-position sampler sent real Basic/Ability intents. Five basic attacks, two abilities, 81 damage and player XP 0→6 observed. This isolates combat from navigation and is not a movement acceptance test. |
| HP conservation | Removing armor clamped 34 HP to 30; re-equipping restored max HP 34 while current HP remained 30. |
| Mobile simulation | Galaxy A06: Thai portrait 359×718 and English landscape 705×338. Scrolling loadout/item views inspected; portrait buttons met minimum 48 pixels and fit content width. This is viewport simulation, not physical touch hardware. |
| Exact rejoin | After allowing pending combat rewards to settle, restarted Play. Schema 3, revision 63 and complete saved data matched exactly, including Gold 37, seven equipment instances, assignments, sequence 3, player XP 10 and five-member party. |

Evidence: [migration](evidence/phase23-migration.json), [transfer stats](evidence/phase23-transfers.json), [combat/HP](evidence/phase23-combat.json), [checkpoint](evidence/phase23-checkpoint.json), [exact rejoin](evidence/phase23-rejoin.json), [Thai loadout](evidence/phase23-mobile-th.png), [English item](evidence/phase23-mobile-en.png).

Studio was stopped and all 50 runtime sources compared with disk after restoring the normal staging bootstrap. Device simulation was stopped. No critical runtime error was observed. Published-client, physical-device and two-player isolation acceptance remain deferred.
