# Six-city service architecture — 2026-10-06

All six exploration cities now instantiate separate market and tavern architecture instead of the shared planning shells. Existing service markers, earned travel rules, market/recruitment handlers and server economy remain unchanged. Architecture derives from the original city reference's colors and silhouettes, with shared accessible interior dimensions. It is a local art study, not a claim of final island fidelity.

| City | Visual vocabulary | Market parts | Tavern parts |
| --- | --- | --- | --- |
| Crownford | Ivory stone, crimson gables, exposed timber, awnings | 300 | 285 |
| Sylvaris | Sweeping green roof, branch supports, leaf crest, lancet accents | 318 | 305 |
| Deepforge | Dark stone, copper roof, buttresses, twin exhaust stacks | 327 | 312 |
| Astralis | Steep blue roof, turret spires, star/compass accents | 321 | 306 |
| Crosshaven | Tiered teal dome, arcade columns, harbor banners | 302 | 287 |
| Ironroot | Warm hide-roof profile, heavy wood, welcoming horn ornaments | 310 | 297 |

Each `assets/uat01/<city>-services-v1/` folder has kit.json, an editable Blender scene, Market/Tavern GLB+FBX exports, exterior/interior renders, source geometry and four clean reimport reports. Twelve buildings / 24 exports verify object bounds, triangle totals and collision metadata. Final Sylvaris/Ironroot cosmetic branch/horn segments overlap to avoid disconnected tips; their exports were regenerated and rechecked. Native art does not require uploaded mesh IDs.

The common interior has eight-stud entry/aisle widths, ten-stud door clearance, .3-stud floor step, stocked shelving, counters, flooring, wall trim and lanterns. Markets add produce bins; taverns add tables, benches, food and hearths. Roofs and ornament are cosmetic. Shared floor plans and repeated furniture still need further city-specific art refinement and mobile budgeting.

## Native evidence

The updated six-city fixture has 4,274 parts and passes all 48 arrival-to-destination paths (radius2, height5, jumping disabled). This is synthetic path evidence, not actual quest progression.

`build/Guildborne_CivicArchitectureReview.rbxlx` is an isolated, profile-free walk viewer. Normal UI city buttons move the preview avatar to each city's market approach; WASD then enters the market, returns outdoors, walks around the side and enters the tavern. Crownford was tested separately in its original viewer; the other five cities passed both entries in the six-city viewer, each within one stud of its service marker at the end, health100. Console remained empty and Play was stopped. See `validation-civic-architecture-walk.json` and the Crownford walk screenshots. The viewer camera resets direction after city selection and has obstruction handling; wheel/orbit input is not yet verified.

Main and Memory-only offline builds include the native kits. Strict checks/compile/repository checks cover 315 runtime sources. The 672-test domain suite passed earlier in this architecture batch; the later five visual variants do not alter game rules. Repeated full-game service transactions, earned journeys through the other cities, multiplayer/device performance, complete island architecture, final likeness and human approval remain pending. The six new NPC contact-art models are still separate studies; current gameplay NPC rigs remain in use.

Generators: `tools/build_crownford_services.py`, `tools/build_civic_service_variants.py`, `tools/blender_crownford_services.py -- --city <City>`, `tools/verify_crownford_services.py -- --city <City>`. Build the walkthrough with `python tools/build_civic_architecture_review.py`.
