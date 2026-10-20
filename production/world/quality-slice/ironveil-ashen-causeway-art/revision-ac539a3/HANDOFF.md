# Ironveil–Ashen causeway art candidate

Base `ff81a48`; separate branch `codex/ironveil-ashen-causeway-art`. New additive decorative packet only. Both new directories are named `ironveil-ashen-causeway-art` under assets/production/world-slice and production/world/quality-slice. No source, tests, configuration, corridor ground, descriptor, old mesh packet or shore-cut variant is modified.

## Design and integration

Two continuous twelve-bay side trusses span X616..904 at Z1491.5 and Z1520.5. Warm dark iron at the Ironveil half changes to charcoal toward Ashen. Four tapered/stepped stone abutment and bearing-cap solids anchor to the two existing native island ends. Seven crossgirders tie the sides below the walking deck; no intermediate pier falsely terminates in empty space. Long side members give the road a structural silhouette without new overhead portals or scattered props. Node plates follow the truss rhythm.

Packet `assets/production/world-slice/ironveil-ashen-causeway-art/scenery.mesh.json`: five resources/placements, 1068 triangles, 89 solids. SHA256 `99ceb74508c2e693957a5601960f2a2897fc85b55eabf17d1dbf0eb5ca471c1e`. Budget is below 3000 triangles / 60 placements. All placements are decorative with collision, query and touch disabled; runtime IDs remain null. Add to a separate scenery container, never the physical corridor model whose readiness requires exact collider membership.

The existing walk top remains Y2.1. Underdeck seats reach Y1.73, deliberately overlapping the existing deck underside Y1.70 by 0.03 rather than lying in a coincident plane. The entire main lane X624..886/Z1493..1517 and pads X596..624, X886..914/Z1493..1519 are reserved above the floor. Upper side chords center at Y7.3, outside these reserves. These decorative sides are not fall protection or collision proof.

Use with the exact six-part ground and existing `coast-prop-ashen-cut` replacement. Do not import the obstructing original coast alongside its replacement. The original floor and replacement remain authoritative inputs, not outputs of this art recipe. Source hashes are recorded in provenance.

## Evidence boundaries

Geometry/contact review and Blender render evidence are separate from native testing. Contact with native island boxes is visual anchoring, not a structural engineering simulation. Readiness and traversal still belong to the controller's actual corridor. No physics, five-hero movement, device performance or human art acceptance can be inferred from these offline views.

Matched render inputs include the current cut coast and six-part ground in BOTH variants, existing Greenwood–Ironveil art and ore yard, and 91 source-reconstructed native region/portal pieces. Only after adds this packet. Views include two player-height approaches, overview, and an intentional underdeck inspection from inside the cleared notch. The underside camera is not a playable position. Dynamic actors, resources, private pockets, GUI, Roblox materials/lighting and distant scene content are omitted.

## Coordination disclosure

The geometry worker's initial combined lease-check/write command continued after a failed check on an expired lease. Parent stopped all workers, explicitly released and reclaimed after confirmations, then checked the fresh lease and regenerated identical geometry before further work. See coordination-exception.json. The failed check was not treated as authorization; subsequent mutation commands terminate on lease-check failure.

No Studio or interactive Blender change, provider call, paid upload, publish, production persistence, push, PR or merge is part of this wave.

## Completed offline review

Independent geometry run02 passed: 1068 triangles, five placements, 89 closed convex solids, 153 declared contacts independently confirmed and 292 positive SAT overlaps. Every solid connects to existing native island roots. All six clearance prisms remain clear. All 796 checked base files, including 30 existing mesh packets, are unchanged. Run01's Windows text-decoding failure and raw streams are retained alongside the successful run02.

Before and after Blender runs both completed with exit 0 and four matched PNGs each. Independent review inspected all eight actual images. Side trusses improve route-edge readability; underside crossgirders give the slab a bridge silhouette. The span remains visually thin/repetitive, the deck plain and the cut banks flat/banded. Foreground shore partly obscures the overview; endpoint stone anchors are not clearly legible in these views. This is a bounded art improvement, not final world art acceptance.

Native retest remains pending for player camera appearance, backfaces/shadows, endpoint contact visibility and traversal with companions. Rails are decorative and do not stop falls. No runtime or device test was executed in this art-only wave.
