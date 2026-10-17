# Four-session runtime checkpoint — 2026-10-17

Controller source before changes: ccf1ed6, pushed to integration branch. Full
tools/validate.ps1 completed exit 0 (raw local build/wave5-baseline.log): domain
tests, Rojo, analysis, compilation and built-place boundary checks. This is local
code evidence, not gameplay acceptance. S15 c33751d integrated as b763d19; cursor,
action timeline and server ability checks rerun successfully.

## Observed Studio failure

Standalone instance 04084a7d-b461-47ee-bc6a-9592dd718ff3,
Guildborne_QualityPreview.rbxlx, PlaceId=0, GameId=0, Memory persistence.
Candidate SHA256 326dcaa1dc7868cdd47a4fd5bd34dea79f37b8085247409dc77757043bf5d968.
Launch preview, world collision disabled, local enemy binding enabled.

Actual client Dataset1 result: FAILED after 7.3936653 seconds, error
NativeAssetPreview:53: Fixed mesh budget unavailable. Source mesh hash
a6fed50575aa16a4572c8904bc312af9a0de64aa6332b9d532b548fbf9463d7d,
45 chunks, 74,380 triangles, 103 placements. Images: four READY_LOCAL_ONLY.
Follow-up client enumeration found zero remaining BaseParts with SourceMeshId;
failed constructor cleaned its imported geometry. This is not a device benchmark.
S13 received the measured failure for targeted geometry optimization.

## Integration repair

Read-only review confirmed server cannot inspect client-only imported geometry;
the previous bootstrap additionally used the wrong art parent/name. S13 owns
server collider separation. Controller pairs exactly one mesh dataset with the
collision manifest hash at build and checks it again on server startup. Client
validates imported mesh identity/transforms before hiding native decorations.
Independent review checked all 103 expected transforms (maximum center error
0.0000652 studs) and generated contract compilation. Its cleanup findings were
fixed: post-import rejection destroys geometry, and collision teardown restores
native presentation and destroys replacement geometry.

17 packaging tests pass, including absent/duplicate/unrelated dataset rejection
and stale generated collision hash. Preview scripts compile. Runtime validation
of the repaired collision flow is still pending S13 delivery and mesh budget fix.
S14 tracker repair and S17 registry/schedule implementation remain separate active
workstreams. No publishing, uploads, production persistence or main merge.
