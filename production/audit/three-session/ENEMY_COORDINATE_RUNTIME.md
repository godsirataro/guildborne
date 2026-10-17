# Enemy coordinate runtime probe — 2026-10-17

Actual isolated Client a7b4b3ce-3996-4a25-9480-912e61bffc22, PlaceId0/GameId0.
Used packaged Enemy1/Enemy2 Data and NativeEnemyPreview, one disposable handle at
a time, origin CFrame(310,25,1710)*yaw90. No server state, gameplay actor, rewards
or original earned session was changed. Both handles destroyed after measurement.

| Metric | Greenwood scout | Forest captain |
| --- | --- | --- |
| Fixed EditableMesh center | 0,0,0 | 0,0,0 |
| Part.Size minus MeshSize magnitude | 0 | 0 |
| Bones compared against origin * recommendedYaw * sourceBind | 43 | 43 |
| Maximum bone world-position discrepancy, studs | 0.00012584166 | 0.00012584166 |
| Maximum relative rotation, radians | 0 | 0 |
| Finite Walk samples over three clip periods | 91 | 91 |
| Death evaluated at duration+10 | succeeded | succeeded |

This shows no chunk-center-scale displacement analogous to the former world
importer bug. The suggested 1e-4 position tolerance is slightly exceeded at this
translated origin; report the actual error rather than claiming that strict
tolerance passed. Numeric samples were stepped quickly, not watched as three
real-time walk cycles. They do not certify smooth looping, planted feet, visual
silhouette, live binding turns, death replication, respawn or physical devices.

S15 source audit found endpoint vertex seam approximately0.147707/0.264953stud
for Walk and maximum LowerArm.R rotation seam6.899degrees; that remains a
separate visual-quality question, not a coordinate failure or approved clip fix.
