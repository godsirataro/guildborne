# Actual Ironveil geometry and cast fixtures — 2026-10-18

Environment: isolated Memory Studioff7a40bb-42b8-4c63-b908-f5c7869ea77e, qualitybuild939a0471e34735693d89e587310a47680c3a79232e3f5df1d526371b2757b9da. Existing committed probes were inspected before execution. No source rewrite, player relocation, profile/grant mutation or remote invocation.

Server executed tests/studio_ironveil_mine_probe.luau against actualServer.Services.IronveilMineArt. Created temporaryowner101 assembly, checked entry/marker overlaps with agent dimensions and used actualPathfindingService fromentry. Result:
```json
{"actualPlayerWalk":false,"worldBinding":false,"pathsFromEntry":29,"markers":29,"scenes":6}
```
Fixture and wrapperModuleScript independentlyconfirmedremoved. This establishes geometry/pathfinder coverage, not ordinarywalking, followerbehavior, questbinding or activeprotection input.

Client executed tests/studio_ironveil_cast_probe.luau with exactsourcecopy IronveilCharacterKit and actualloaded FriendlyNpcAnimator fromcombinedbuild. Isolatedcollectionprovider limitedanimationtofixture; realnpccontrollers not replaced. Result:
```json
{"visibleParts":114,"profileWrites":0,"rigs":3,"destroyRestored":true,"walkingLimbs":12,"walkStopRestored":true,"motors":45}
```
Fixture and allwrappermodules independentlyconfirmedremoved. This detects movement/stop/cleanup regression foractualnativeIronveil rigs, not foot-contact quality, humanmotionapproval orrealacceptedNPCinteraction. No audio/device/multiplayerclaim.
