# Building storage and fine placement — 2026-10-03

Warehouse, Hero Quarters and Blacksmith can now be stored and restored through the Base UI. Storage retains the original building ID, coordinates, orientation and housing upgrade level. It does not refund construction costs or charge them again. Stored buildings do not provide active benefits. Housing cannot be stored while more than five heroes are recruited. Dismantling remains a separate confirmed action.

The optional expansion.storage map is validated alongside placed buildings: a building ID and kind cannot exist twice, total ownership remains bounded, and malformed IDs, levels and coordinates fail validation. Existing profiles without storage remain valid. StoreBuilding and RestoreBuilding use the normal candidate/save/replay path and existing owned-island spatial checks. Restoration rechecks current land rights, bounds, overlap and walking access before moving the same record from storage back into the world.

Build mode now switches between 8-stud and 2-stud movement. Coordinates retain the original 8-stud unit and use exact quarter values for fine adjustment, avoiding a conversion of old saves. Only bounded quarter-grid coordinates are accepted for placement/movement/restoration. Rotation, material quantities and other integer commands remain integral. Expanded-area route checks already operate at 2 studs.

## Verification

- 379 domain tests pass, including storage/rejoin/upgrade identity, no extra material charges, duplicate ownership rejection, locked/overlapping restore rejection, before/after-save uncertainty and fine-coordinate reload. Housing overflow storage rejection is included in the existing capacity test.
- Actual offline UI gathered 8 Timber and 4 Stone, constructed warehouse b:1, stored it and restored it at a new position rotated90°. World model removal/recreation and capacity200→100→200 were verified. Revisions7/8/9 identify construction/storage/restoration. Only construction generated material debit events. Debug positioning between resource nodes was used; no cloud profile or paid state was changed.
- An isolated Thai BuildView fixture used actual pointer inputs to select2studs, move right/down, rotate and place a stored building. It emitted RestoreBuilding with b:1, x6.25, z-3.75, rotation1. Labels fit at750×362 viewport, and GUI/ghost were removed on close. The callback captured the command; it did not alter the live profile.

## Editable layout slots

Three saved layout slots now capture placed utility-building IDs, coordinates and rotation. Applying a layout rearranges existing owned records and stores extra buildings without material charges or lost upgrades. Every footprint and land permission is validated before the candidate replaces the current layout. Missing/dismantled buildings reject the entire application; no replacement is granted. Housing capacity is checked before storing omitted quarters. Saving an occupied slot and deleting a slot require a second UI click.

385 domain tests now pass, including layout switching, rejoin, stale building IDs, invalid client payloads, bounds, housing capacity and uncertain save/apply/delete outcomes. An actual offline UI journey constructed b:1, saved slot1 at revision8, moved it by2studs and rotated90° at revision9, then restored the original position/orientation through ApplyBuildLayout at revision10. Delete confirmation produced revision11 and disabled Apply for the empty slot. Only construction consumed materials. Initial construction correctly rejected an insufficient-material attempt before the remaining wood was gathered. MCP debug repositioning and scroll placement were used; real persistence and human UAT are not implied.

Hall relocation and utility theme ownership/application were implemented subsequently; see HALL_MOVEMENT_IMPLEMENTATION.md and BUILDING_THEMES_IMPLEMENTATION.md. Outdoor furniture crafting/placement/storage/recycling and new layout capture are now implemented; see [furniture](FURNITURE_IMPLEMENTATION.md). This implementation covers the three existing utility buildings. Physical mobile/controller acceptance and real persistent reconnect acceptance remain pending.
