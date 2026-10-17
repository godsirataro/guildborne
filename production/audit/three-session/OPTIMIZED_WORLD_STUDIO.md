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
