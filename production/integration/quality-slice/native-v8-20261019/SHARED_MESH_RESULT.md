# Shared mesh retry

2026-10-19 approximately10:29 Bangkok. Importer exact structural geometry cache
and refcount ownership independently reviewed;18 actual-source mocked cases,
focused Roblox-aware LSP, compile and whitespace checks passed. The mocks are
not Studio evidence. All geometry arrays/colors/normals/transforms are retained.

Actual isolated Memory Studio b32224b1-772b-4d03-b2fb-bfb136e36eb5, candidate
1fd93fbe258dce4af2a5babd1c1262b38d4f29c561c5f954640c6627aa8aaeb8,
importer e8f11e5b0c3b5bfeace1a5dfac4fa3523e9daeebcb28b38264b3b492f603a93c.
All4 datasets READY_LOCAL_ONLY:116+72+17+13=218 placements. World collision ready.
Original failed and compaction-only failed evidence remains unchanged.

This resolves the observed combined allocation failure, not final visual/game
acceptance. Native title Continue and menu input worked. Player was explicitly
repositioned to450,7,1475 for synthetic art inspection; no earned travel claim.
Actual player view sees the authored receiving building, but elevated approach
cameras are occluded by large coast geometry. At500,48,1535 the camera lies in
coast_headland_banks__bounded_003's bounding box (position187.50018,19,1595,
size1445,118,1350). A bounding box alone does not prove triangle intersection;
subsequent independent triangle review confirmed real intersections: triangle26
crosses eye410,28,1450 to weighhouse436,8,1468 at t0.37852; triangle32 crosses
eye500,48,1535 to that weighhouse at t0.15311. Source scenery.mesh.json SHA256
f31077a0847a4a5db7a5918a411ee9b9ba22cdb0ac18ec686bc18859e10fc4e9.
S13 owns the bounded coast/Ironveil repair. Both actual screenshots retained. Do not hide the
coast dataset and label combined visuals accepted. Play stopped after capture.
