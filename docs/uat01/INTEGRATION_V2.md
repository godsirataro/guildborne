> Current instruction2026-10-03: continue local work until weekly Codex quota remaining reaches50%. Earlier15%pause notes below are historical. Current implementation evidence is in STATUS.md and WORK_CHECKLIST.md.

> Latest user clarification2026-10-02: expansion zones are quest-gated ROBUX purchases plus required materials, not unrestricted purchases or Gold-only expansion. See the final clarification in [launch scope](../LAUNCH_GUILD_ISLANDS.md). Material submission timing is proposed, not yet fixed. Planning only.

## First-release scope added — 2026-10-02

User approved [guild islands, visiting, plot expansion, free placement and paid mixable building themes](../LAUNCH_GUILD_ISLANDS.md) for the FIRST game release together. These are required launch work, not a post-launch theme update. Planning only; no runtime changes, purchases or publication. Development remains paused at15%quota. Older milestones are historical. Theme roster/prices and physical limits need specification; the all-player corridor/co-building/offline visits are not required by this decision. Previous chat40%estimate is not a measured completion figure and must not be reused for this expanded scope.

# Guildborne integration checkpoint — 2026-10-01

The latest user request authorizes continued local implementation, generation and Studio MCP work. Active stop boundary: 15% weekly Codex quota remaining. Reference documents are design input, not proof that their features exist.

## Reconciled source inventory

Read-only inspection of Guildborne_UXUI_Asset_Registry.xlsx found 239 planned asset slots, **65 screen records: 57 UAT01 + 8 future**, 48 components, 38 tokens, 46 copy entries and 40 acceptance cases. Original workbook remains unchanged. Full source rows and SHA256 are preserved in intake/registry-source.json. Progression input contains 35 class designs, 240 quest cards and 20 additional UI surface proposals. None of those counts establishes implementation.

Current implemented content remains 30 item definitions, 10 recipes, 15 Journal quests plus 3 timed expeditions, 15 generated PNG sheets/concepts, existing native UI and combat. Added here: ten original low-poly adventure props, 87 native parts / 1,044 Blender triangles total. The files include editable Blender, individual FBX and GLB, shared JSON definitions and a native Roblox module. Nine prop placements extend decorative islands from 154 to 223 parts. Playable region travel/combat is still pending.

## Merge decisions

| Proposal | Integration decision | Current gap |
| --- | --- | --- |
| 239 asset slots | Reuse generated atlases, native shapes and real model previews. Map to real IDs before generating missing pieces. | Placeholder bindings, crop/alpha review, Studio image permissions and acceptance |
| 57 UAT screens | Extend existing TitleView, SliceUI, InventoryView, ExpansionView, SettlementView, MarketView, SkillTreeView and BestiaryView. A surface can be a state/drawer in one view. | Full state coverage and physical-device validation; companion portraits/commands now implemented |
| 8 future screens | Keep in later backlog; no production Guild War/treasury/research promise. | Entire future implementation |
| 20 progression surfaces | Merge into class, skill, status, Hall and quest flows; avoid duplicate menus. | Novice route, stat allocator, respec preview and promotion trials |
| Class1 at 10; Class2 at 35; Class3 at 70 | Implement isolated v2 rules and migration audit before runtime cutover. | Existing Class1 at start and Class2 at 30; schema currently requires classless actors to be level 1 |
| Hall0 cap10; Hall1 cap20; Hall17 cap100 | Preserve all old levels, XP and Hall18–20 rights. Introduce a separately versioned ruleset. | Existing Hall*5 level derivation appears in schema, rewards and services |
| New recruits at level10 | New v2 recruitment after Class1 + free Hall story grant; retain existing owned heroes. | Current recruits start1; migration needs explicit XP/level reconciliation |
| 35 classes | Stable draft IDs stay in design namespace until real bindings and effects exist. | Draft `oracle` is tier3, existing `oracle` is tier2: never equate by name alone. Other renamed branches also differ. |
| 240 quests | Treat as a content library. First implement Chapters00–02 coherently; existing18 quests retain receipts and IDs. | All draft production IDs are null; prose objectives need server event bindings and balanced rewards |
| 99 SP /297 AP at100 | Per-entity budget, no paid/random/missable permanent points; repeated respec must conserve budget. | AP and expanded skill ranks/runes do not exist in runtime |
| 3D / VFX | Original native art available immediately; Blender exports are editable local sources. | Mesh/rig import, scale/material/retarget validation and production sprite review; Sentinel local rig/9clips now exported |

## Delivery order and acceptance

1. R0: source reconciliation, deterministic rules, copied-profile migration reports and fixtures. No save mutation from a preview.
2. R1: isolated new-player flow Lv1–10, solo Class1 trial, free Hall1, guaranteed selected first hero Lv10. Only enable after schema/replay/reconnect checks and solo route test.
3. R2: status points, skill ranks/runes, safe respec, three active slots and selected-companion controls. Server owns every spend/cast.
4. R3: playable Greenwood/Ironveil/Ashen routes, nine enemy archetypes, three bosses with readable patterns, quest chain through35. Decorative islands do not satisfy this.
5. R4: earned recruitment rotation, cosmetics simulation, class/quest content through70 then100, Player Guild cooperative play.
6. R5: fresh-account journey, two/four-client load, physical mobile performance, save/recovery, clean build and human UAT.

No release readiness is implied. Live commerce remains disabled. Local alpha work can proceed without another approval; publishing, external purchases and existing live-market release gates remain separate.

Read-only structural audit: intake/progression-audit.json verifies the240-quest prerequisite DAG,35-class parent/trial graph,105unique active concepts, Hall cap reachability and point budgets. Seven adversarial Python tests pass. No structural errors found; prose gates and all production bindings/numeric rewards remain incomplete.
