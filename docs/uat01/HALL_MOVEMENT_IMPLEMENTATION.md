# Hall movement — local implementation, 2026-10-03

The existing Guild Hall can be moved, rotated and positioned at2-stud increments through Base → Move Guild Hall. A32×24stud footprint reserves space for both current Hall model variants, so upgrading does not enlarge the reserved build area. No second Hall is created, and moving does not charge materials or alter Hall level. The original site remains permanently reserved and can always be selected as a return location.

Placement supports the starter eastern build area and opened western plots. Static tavern/training/camp/core decoration areas are not freely editable yet. Hall and utility buildings share overlap and expanded-area entrance-route validation. Paid plot gates remain unchanged. This is not a claim that every point of the island can now be built on.

The Hall's interaction anchor follows its position and rotation. Upgrades clone the appropriate visual model at the saved location; the bilingual sign now shows the actual level even when levels3–20 reuse the level2 model. Spawn/visit landing areas stay reserved. New saved layouts include Hall placement; older layouts without Hall metadata preserve the current location. Hall is never placed in storage or dismantled.

## Evidence

- 398 domain tests pass. Added cases cover maximum footprint, overlap, locked land, rotated entrances, upgrade/rejoin, save uncertainty, layout compatibility and malformed state. Existing integer building coordinates remain valid. A fine-grid regression that permitted placement within part of the central8-stud access lane was fixed and covered.
- Actual offline UI moved Hall Lv1 to(64,1,-20), with interaction point(64,4,-7). E at the new location opened the Guild menu. Rotating90° produced Hall(60,1,-16) and interaction(73,4,-16). Selecting Original Hall site restored(0,1,-24). No resources or purchase rights were granted.
- Pathfinding from the actual spawn to the relocated eastern Hall returned Success with19waypoints, radius2/height5 and jumping disabled. This is engine path evidence, not manual walking acceptance.
- Disposable native fixture passed317checks: both model variants at all four rotations fit their reserved footprints; eight no-jump entrance paths succeeded; upgrade/restoration retained position and the level9 label was correct. Fixture was removed, with zero profile writes.

A disposable clone of the actual island passed475checks: spawn-to-Hall paths succeeded for all three western plots at four rotations (12routes), using radius2/height5 and no jumping. Plot opening existed only in the disposable fixture; zero profile writes or purchase grants. Templates and scene were destroyed.

New starter-area edits now check building entrances and routes as well as overlap. Historical layouts remain loadable through schema validation; new edits must satisfy the stricter route checks. A blocked Hall entrance regression is covered.

Exhaustive route acceptance for arbitrary layouts and all static core obstacles, furnishings, Hall themes, physical devices, multiplayer persistence and human UAT remain pending. Ordinary Staging saves were not opened or migrated.
