# Optimized Greenwood combined import — 2026-10-17

Candidate SHA256 e69a918e2e9cbabc9e8584c228efaf55339e417421fdbf7b3edab363b126757e,
copied without modification to Guildborne_QualityOptimized.rbxlx and opened in
Studio a6d25956-416f-4c3b-96bd-8a471f6f9819. Unsaved PlaceId/GameId zero,
Memory persistence. Source geometry commit dbe051e (S13 0e3b07f), mesh SHA256
b570f259106d314de6ca73562967afdebaec7fb322f1f6e4970ee01424601d79.

Actual normal combined bootstrap: Dataset1 READY_LOCAL_ONLY, 85 placements,
37,074 triangles, LoadSeconds=5.3456141. Four images and enemy binding READY_LOCAL_ONLY.
WorldCollisionReady=true with matching source hash. Client enumeration confirms
85 imported art parts, 413 server collision parts and 48 direct native tree
parts hidden using LocalTransparencyModifier. No memory-budget failure this run.
This duration is one local Studio observation, not a physical-device benchmark.

Screenshot optimized-world-first.jpg, camera (105,94,1545) looking at
(0,8,1410), shows roof gaps on the left stable and rear sawmill. Visual acceptance
therefore FAIL/pending correction despite successful loading. S13 received the
image and targeted face/winding repair request. Walking, follower traversal,
quest travel and combined combat remain untested for this revision.

GUI was temporarily hidden for capture and original Enabled states restored.
Build boundary tests rerun: 17 PASS; expected placement count updated to 85.

Coordination correction: a batched shell command continued to cherry-pick after
the controller lease check expired. No competing owner was present; controller
explicitly released its expired integration lease and reclaimed it before Studio
mutation. Subsequent checks and dependent mutations must use separate calls or
explicit failure gating. Audit lease was likewise renewed before evidence writes.

## Roof correction 634a: actual Studio rejection

Opened a second isolated instance a7b4b3ce-3996-4a25-9480-912e61bffc22,
Guildborne_RoofCorrected.rbxlx, preserving the original gameplay session.
Copied build hash 923f93bb80badf14a75717bc58618c64b4d6eafe941b1738ab44c05c34565764.
Verified Edit PlaceId0/GameId0, Runtime Memory, empty AllowedDataStoreUniverses,
Dataset1 hash634a1067f4291d324f09b7b8d7cdcbb2aea748e251701ce6f57dfbc00c37a26d.
Actual Play import: READY_LOCAL_ONLY,5.0064458s,85placements,37074triangles;
WorldQualityCollision413children; four images READY_LOCAL_ONLY.

Screen capture roof-corrected-greenwood from (105,94,1545) looking at (0,8,1410)
still visibly shows missing strips/triangles in the left stable teal roof and
fragmented brown roof surfaces at the rear sawmill. Front/right house roof looks
continuous in this view. ScreenGui layers were temporarily disabled for the
capture and restored afterward. Inline tool capture was visually inspected;
no separately saved screenshot file is asserted here.

REJECTED for roof visual acceptance. Blender/source reconstruction success and
successful local import do not establish correct runtime appearance. S13 has
been dispatched to investigate actual import topology/winding/index handling
and author a scoped correction; importer edits remain coordinator-owned. No
publishing, runtime IDs, production persistence or geometry acceptance inferred.
