# Six-city civic cast — 2026-10-06

Six original civic outfits use the project's editable friendly humanoid skeletons. Native Roblox geometry and Blender exports are local prototypes; no uploaded mesh or animation IDs are assigned.

| City | Character | Identity and visual role | Review location |
| --- | --- | --- | --- |
| Crownford | Marshal Elian | Human charter marshal; sash, civic seal and charter case | Quest Hall |
| Sylvaris | Arborist Vaela | Elf garden keeper; seed pouch, pruning tool and seedlings | Market |
| Deepforge | Smith Borin | Dwarf forge steward; apron, hammer and tongs | Forge |
| Astralis | Cartographer Nyra | Human astral cartographer; star chart and survey prism | Quest Hall |
| Crosshaven | Harbormaster Sela | Human harbor official; cargo ledger and signal flag | Market |
| Ironroot | Steward Roka | Friendly Orc community steward; shared bread and ladle | Tavern |

The six rigs contain 226 visible parts, 2712 triangles and 16 bones each. Each has four baked clips: Idle, Walk, Greet and Work, totaling 24 animation candidates. Thirty-six FBX/GLB exports pass reimport checks for geometry, bones, weights, sampled motion, stationary root and loop seams. These checks do not certify Roblox import, retargeting or device performance.

Editable sources, six portraits, manifests and a framed six-character overview are in `assets/uat01/city-cast/`. The overview was visually reviewed after correcting the initial camera framing that cropped the bottom row. The generated native module is `src/server/Services/CityCharacterKit.luau`; it is not part of main-game city service spawning.

Native Studio fixture verifies all six local rigs, 90 Motor6D joints, 24 moving limbs, stopped-walk restoration and destruction cleanup. The animator now accepts an optional isolated tag provider; normal gameplay still defaults to CollectionService. The first fixture run did not animate because the old factory ignored the injected provider. After the change, the isolated fixture passed.

Standalone Art Review places one static, collision-free friendly NPC in each city, with correct race/city metadata and faces toward service entrances. Ironroot was visually checked in Studio; the first placement faced the counter and was corrected for all six. Review labels explicitly indicate unbound services. This does not add shops, quests, schedules or recruitment to the playable cities.

Evidence: `validation-city-cast-native.json`, `validation-city-cast-placement.json`, `validation-city-cast-roundtrip.txt`, and `assets/uat01/city-cast/roundtrip-report.json`. The review build contains 22 scripts/modules and no persistence, commerce or remote endpoints.

Remaining: authored dialogue, service and quest bindings, animation-specific prop handling, natural schedules, filtered player-facing names where needed, Roblox imports, mobile/multiplayer performance and human visual acceptance. Work clips are generic candidates, not complete profession-specific gameplay animations.
