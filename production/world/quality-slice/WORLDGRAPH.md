# Connected world: topology and art handoff

Source base f768d9a, controller ancestry 4cf9bcb. This proposal does not remap saved IDs, add destinations, open release locks or enable Streaming. Art geometry is an explicit local preview; controller owns actual import/placement acceptance.

## Starter slice

An inhabited slate-roof caravan street transitions to a mossed stone arch and an older forest crossing. House/Stable/Sawmill geometry is real Quaternius Village mesh; ruins, trees and stag use real Ruins mesh. New authorship is selection, scale, composition, material treatment and render. The CC0 foliage FBX diffuse channel was white; the derivative supplies a small leaf/bark palette from face height rather than claiming missing texture bindings. Path source is uniformly scaled to 18 studs wide. Arch and imported decorations never replace gameplay colliders. Preview stream/plinth are render-only primitives, excluded from model/mesh exports.

JSON instances are placed around Greenwood origin offset (0,2,1410); actual RegionalWorld model origin remains (0,0,1400), landing (0,7,1505), return portal (0,7,1517). This artbench intentionally needs controller comparison against existing encounter telegraphs, roads and props before adoption. Bounds, source data and hashes are provided; no screen or collision test is claimed.

## Typed worldgraph, covering existing world identities

| Nodes | Existing connection | Required next gate |
|---|---|---|
| Central City Plaza/Tavern/Forge/Market and city exits | walk; existing source/probe routes | mesh dressing must preserve all anchors and path clearance |
| City <-> Guild / PersonalGuild per owner | TravelZone portal, MarketDistrict remembered return; slot*280 origin | owner identity, safe landing, five companions; preserve tested route |
| PersonalGuild -> Goblin Camp -> promenade | walk on existing island/expansion ground | earned quest/combat integration independent of art |
| City <-> Greenwood | portal at (0,5.5,-1450), arrival (0,7,1505) | shared visual gateway language; keep portal edge explicit |
| Greenwood landing -> resource trails / encounter / boss rise | local walk | inspect proposed meshes against ground, attack warnings and five-follower paths |
| City <-> Ironveil / Ashen | existing RegionalWorld portals, origins (500,0,1400)/(1000,0,1400) | authored regional meshes not produced in this batch |
| Ashen -> private Chapter04 annex | owner-admitted existing pocket, region annex X1835..2165/Z1235..1565 | no relabeling as public seamless road |
| City <-> Crownford / Sylvaris / Deepforge / Astralis / Crosshaven / Ironroot | gated civic travel; X0/400/800/1200/1600/2000, Z-4000 | preserve charter/quest prerequisites and each service anchor |
| Tower / Novice / Chapter00-06 encounter pockets | existing progression-owned entries, not open-world roads | preserve chapter/session gates, earned progression and current IDs |

The regional and civic offsets are layout coordinates, not proof of walkable links. Do not draw a continuous ~2955-stud roadway from city Greenwood gate to its landing: that corridor crosses unrelated owner-island space and would need a separate zone/authority design. Use `walk`, `portal`, and `private-session` edges. A future seamless corridor is a separate candidate requiring explicit geometry bounds, safe recovery/respawn, server zone transitions, release eligibility and companion handoff tests. Keep old portal routes until that evidence exists.

## Level 1–100 coverage gaps

The all-world graph retains current nodes; it does not assign invented level bands to them. Existing progression/quest catalog remains authoritative. This batch supplies one authored forest-threshold art set only. Ironveil, Ashen, six civic cities, island interiors, tower and late-chapter pockets still require equivalent mesh selection/composition, native lighting/audio, quest-connected traversal and visual review. A Lv1–100 content promise is not established by importing these 15 sources. No change to class gates, Hall caps or production flags is included.
