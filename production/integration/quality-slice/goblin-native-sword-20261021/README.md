# Goblin source sword and three R6 kits: native review, 2026-10-21

Status: native display demonstrated; sword combat fit and armor motion fit NOT accepted.
These are isolated, anchored Edit-mode fixtures in PartyPresentationLab, not a
live gameplay, saved/imported production asset, device test or final art approval.
Runtime asset IDs remain null. No original source/export was changed.

## What is visible

- `native-forward-idle.png`: original generated sword on the existing Warrior R6
  test body. Four real maps bound through native EditableImages/SurfaceAppearance.
- `native-identity-arm-overlap.png`: rejected grip with blade inside the arm.
- `native-forward-failed-windup.png`: rejected forward grip, synthetic Slash
  age .155, minimum sword vertex Y=-.11216414 against the diagnostic plane Y=0.
- `native-heavy-idle.png`, `native-heavy-windup.png`, `native-scout-idle.png`,
  `native-ritual-idle.png`: original locally authored block-style kit prototypes,
  six separate meshes each. These do not represent the visual quality of the
  original detailed provider outfits, which remain preserved in S18's source.
  The unresolved sword is hidden during armor captures.

## Verified source and native display

Sword: 983 vertices, 1,666 triangles, source scale 1. The already converted Roblox
axes are not converted again. Center subtraction is restored in MeshPart CFrame.
Per-corner normals and U,1-V are retained. Native readback of all four 1024x1024
RGBA maps exactly matched their frozen SHA256 values. These are reduced preview
derivatives of the preserved 2K maps, not proof of full-resolution fidelity.

Armor: heavy 3,080 vertices/5,964 triangles; scout 1,848/3,564; ritual 3,192/6,156.
All 18 exact source payload hashes and three packed JSON packets were independently
checked against S18's frozen sources. The three 128x16 palette maps (color,
roughness, metalness) passed actual native pixel SHA256 readback for each kit.
No normal map was invented. All six pieces follow the exact corresponding R6 limb
at scale 1. Nine strictly identified legacy armor overlays are hidden temporarily;
the actual body, hands and eyes remain visible. Cleanup restores transparency.

`source-preflight.json` identifies the exact HeroRig, ActionPose and ActionTimeline
source hashes. The source rig is the existing R6 Warrior; it is not the separate
new Human Standard appearance rig.

## Rejected sword candidates

The initial three fixed grips have 103 frames each. Additional recorded searches
have 18 pitch/roll/scale candidates x103, 30 wider-pitch candidates x103, and 24
forward/outward direction candidates x104 including exact contact time .24.
Every row and compressed native result is preserved. These are 75 candidates,
7,749 candidate-frame measurements, not 7,749 independent test passes.

Identity grip clears the floor but visibly embeds the blade in the arm. The
forward -90-degree grip dips below the reference plane. Reverse pitch +1.5 has
far fewer upper-vertex intrusions but points backward at idle, so it is rejected.
Outward candidates still have substantial body containment. There is no accepted
grip correction in this packet. Source geometry/export and gameplay are unchanged.

Containment is a point-in-opaque-body-OBB diagnostic for sword source Y>.5,
not semantic blade classification, triangle collision, actual hit contact or a
proof that zero counted vertices means collision-free. A grip origin at the hand
center likewise is not physical contact acceptance.

## Armor motion diagnostics

Each kit has 106 recorded poses: idle, 61 synthetic gait phases, 41 samples of the
existing Warrior Slash from 0 to .62, exact .24 contact time, and explicit forward
shoulder reaches at +65/+100 degrees. The latter rotate anchored shoulders and
their welded details; they are not recorded animations or live Mage/Priest casts.

| Kit | Rest vertices inside body | Maximum inside in one pose | Forward65/100 | Lowest armor Y |
| --- | ---: | ---: | ---: | ---: |
| Heavy | 0 | 278 | 16 / 16 | -0.14316899 |
| Scout | 0 | 276 | 0 / 0 | -0.14316899 |
| Ritual | 0 | 346 | 0 / 0 | -0.14316893 |

Maximum containment occurs at synthetic Warrior Slash age .31. Lowest Y occurs
at age .217. These are full-kit vertex containment diagnostics, including
cross-limb contact. The underlying bare-body pose must be compared before blaming
floor intrusion on an asset; the detailed failure packet records that comparison.
No armor-to-armor triangle collision, full physics gait or device acceptance is
asserted. `kit-heavy-initial104-*` preserves the earlier sweep before adding the
two forward poses; `kit-*-sweep*` is the expanded 106-frame evidence.

The focused native failure extraction confirms a source-pose contribution:
at age .217 the bare right leg already reaches Y=-.12633955, while the armor
reaches -.14316899, an additional -.01682943. At age .31 the bare right-arm
corner is inside the torso; the bare head and leg corners also intersect the
torso. Do not fix this by distorting all three outfits. These are corner tests,
not complete OBB intersection tests. Heavy forward reach is a separate asset
issue: eight vertices in each arm piece are inside the torso at both65/100,
while the core-body corner baseline reports no contained corners.

`kit-*-failure-detail.json` preserves actual native vertex IDs, incident triangles,
source-limb-local/world coordinates, intersected body identities and bare-limb
minimum heights for five selected poses per kit. `failure-summary.json` is the
compact handoff. `failure-source-index-reference.json` derives281 coordinate
references back to frozen source JSON indices at tolerance1e-5, retaining all
ambiguous matches; it never assumes native IDs equal source indices.

## Ownership, review and limitations

Root held exclusive Studio ownership and wrote only this new evidence directory.
S18 retained source asset ownership; no Blender or source asset rewrite occurred
here. `/root/local_actor_adapter` authored disposable helpers; `/root/r6_preflight`
independently reviewed the frozen helper/transport and source/palette packets.

Reviewed sword helper SHA256: 7bc3a552efd9d051780538e050cbea506ed561806e92b8d9d2076d217e766ac0.
Reviewed armor helper SHA256: 53b2596546a8a9d30af9e4d1d128e51039e9da053f84884f1a6b42ce9190c27b.
Reviewed armor transport SHA256: 3546cec6becd1fb85f7d453499ce10c16f2fd948c621f8cb51509b5d520643c3.

Helpers compile; author reports strict Roblox LSP checks passed. Native successful
construction, exact pixel readback, explicit cancellation and repeated cleanup
are recorded separately. A partial rig allocated inside HeroRig.Build before an
internal throw is not explicitly recoverable by the sword helper; that injected
failure was not tested. Deleting an individual armor MeshPart is detected on the
next manual Pose call, not immediately. Do not generalize the successful cleanup
to those untested cases.

Controller observations indicated that native screen_capture restored position
but changed camera orientation during inspection. Root explicitly sets CFrame,
Focus, FOV and Fixed camera type to its pre-inspection observation targets at final
cleanup. The original camera/lighting observation was not archived in this packet,
so equality to the original is not independently verifiable here. The final values
are preserved exactly. Original camera subject was not recorded or changed.
The inspection fill light and floor are owned children of the disposable fixture.

The root lease expired during this extended review. Writers paused and root's
expired own lease was explicitly released/reclaimed with no competing worker and
no active native execution. One derived kit-summary receipt was written in the
same batch as the failed lease check; it made no source or scene mutation.
The replacement lease covers remaining diagnostics, cleanup and evidence commit.

See final cleanup, transport closure, independent packet review and manifest
receipts for the exact final state. This packet remains review evidence, not a
whole-game acceptance or a promotion of pending production gates.

Actual final cleanup: all five kit constructions cleaned29 owned resources each,
including3 images/12 mesh allocations, and restored9 overlays without errors.
Sword cleanup destroyed10 resources including4 images/2 mesh allocations and
removed its owned collision group without errors. Repeated cleanup was harmless.
Workspace returned to2 children, only Default collision group remains, fixture
and runner are absent, HttpEnabled=false, Edit mode/PlaceId0/GameId0. Final camera
and lighting values match the controller's stated targets, with the missing
original-observation receipt limitation above. Three source hashes and all six original
script disabled states match their recorded values. Both loopback servers closed.

## Next owned work

S18 received the concrete failure packet and may produce separate frozen-v1-safe
v2 heavy arm-crown candidates under its asset/Blender leases. The proposed ritual
robe narrowing is held: S18's later local gait replay points to torso contact,
not opposing-leg contact. The five focused native frames here do not cover that
gait case. No new ritual dimensions are approved by this evidence. Fresh native
fit, full visual art review and source-pose corrections remain separate gates.
