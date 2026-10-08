# Six-city layout prototypes — 2026-10-03

The standalone Art Review now contains six walkable city planning districts: Crownford, Sylvaris, Deepforge, Astralis, Crosshaven and Ironroot. Each is200×250studs with an18stud main avenue,12stud cross streets, a civic landmark, four service shells and two reserved travel pads. All six together contain570anchored parts, including the192landmark parts. The common service layout is deliberately provisional; each city's final terrain, street plan and neighborhood identity still need development.

| Destination from city arrival | Native path distance | Current behavior |
| --- | --- | --- |
| Market / Forge |100studs | Walkable shell; no shop actions |
| Tavern / Quest Hall |148–149studs | Walkable shell; no recruitment or quest actions |
| Civic landmark |178studs | Original architectural model |
| Guild island / Regional gate |61studs | Reserved pad; no gameplay teleport |
| Central avenue marker |96studs | Orientation point |

At the standard16stud/s walking speed these distances imply approximately4–11seconds of uninterrupted travel. This estimate excludes interactions, crowds and final terrain. The six pads are separate review specimens, not islands linked by a finished ocean or public map.

`review/CityDistrictKit.luau` builds the geometry. `review/ReviewWorld.luau` supplies actual review-only arrival/return portals. The dedicated project allowlist includes20scripts/modules and excludes persistence, commerce, main-game bootstrap and remote endpoints. Nothing here changes existing player saves or unlocks.

Validation: strict analysis and compilation passed; all48PathfindingService routes passed with radius2,height5 and jumping disabled. Actual standalone Play joined successfully with33prompts and no startup console messages. Actual keyboard E entered Crownford. Character navigation at normal speed reached all four service interiors, the landmark and guild pad, with position readbacks and100health. Other cities currently have native pathfinding coverage, not actual player traversal coverage.

Evidence: validation-city-districts-native.json; validation-city-districts-live.json; validation-review-build.json; assets/uat01/city-landmarks/city-layout-studio.png. The latter is an unedited Studio capture, not an AI-generated source image.

Remaining first-release work: differentiated city streets and terrain, NPC schedules/dialogue and quests, services bound to authoritative systems, city unlock conditions, actual guild island and regional travel, spatial streaming, multi-client/device performance, imported art and human acceptance. Friendly Orc identity remains a planned civilized city role; the placeholder district does not add hostile Orc factions.
## Latest revision — 2026-10-06

Six200×250stud review districts now use different avenue shapes, service positions, ground palettes and perimeter dressing: Crownford formal avenue, Sylvaris garden promenade, Deepforge foundry avenue, Astralis diamond walk, Crosshaven harbor loop, Ironroot communal lanes.712native parts include54hidden destination markers;658visible mesh parts total7896triangles. These remain flat planning blockouts with placeholder services; finished terrain, differentiated building architecture and gameplay binding are still required.

All48no-jump routes pass (radius2/height5). Actual normal-speed player traversal in Sylvaris and Ironroot reaches all4service interiors, landmark and guild pad,12destinations total with100HP retained. SixFBX/sixGLB files reimport with matching part/triangle counts and bounds within0.01m. Editable source: assets/uat01/city-districts/Guildborne_City_Districts_v2.blend; native-layouts-v2.json retains Roblox local transforms and9markers/city; manifest documents0.1m/stud conversion. Preview visually reviewed. Evidence: validation-city-districts-v2-live.json and assets/uat01/city-districts/roundtrip-report.json. Earlier570part counts below are historical.

