# Combined V8 native check and timed stop checkpoint

Recorded 2026-10-19, Asia/Bangkok, approximately 10:20. User requests stop at
11:00, save all work, then `shutdown.exe /s /t 1000`. Automation
`guildborne-11-00` is ACTIVE with a one-occurrence 11:00 schedule. Shutdown has
NOT been executed. All four workers were told to stop/save by 10:55; their
delivered source is integrated through pushed controller commit 8d8c3e5.

## Verified source baseline

Controller branch: codex/three-session-integration, repository
C:/Work/MySelf/Guildborne-controller. Shared ledger remains
C:/Work/MySelf/Guildborne/build/agentic/four-session-v8.sqlite3.
Fresh full validation on clean 8d8c3e5 passed 968 tests and build/LSP/compile
checks. Run: build/agentic/checks/31bfdfaa617a4eb1b4c6ee156122ede6,
sourceUnchanged=true. This is local evidence, not native or device acceptance.
Reviewed integrations include ore-yard 7a9694c, inventory aac6267, Class3 C
21a6acd/1698852 and cue endpoint barrier fefe3d8. Class3 stays default-off.

## Actual Studio result: combined art FAILED

Place/Game IDs 0/0, isolated Memory candidate. Original candidate SHA256:
1a55d05140c9b24df671a624d8f749fdd2ca066f707972bc43308039a5f05b69.
Studio c0ba2bbe-cd29-4138-9f92-8dd09d3379a2.
Dataset1/2/3 imported (116/72/17 placements); Dataset4 failed at fixed-mesh
allocation because of EditableMesh memory capacity. Raw import and console
responses are retained unchanged inside their tool-response JSON envelopes.

Dock probe: 84/84 full-width world-supported rays and 22/22 engine paths passed.
The narrower original route-only rays are 28/30, with misses at indices6/10,
offset -11.5. Do not erase these misses or report all ray checks passing.
These are engine floor/path results, not actual player/five-hero traversal.

Reviewed compaction attempt adds RemoveUnused before fixed copy and verifies
FixedSize and source vertex/face counts, with mesh ID in failure diagnostics.
All four source datasets have no unused vertices. Build passed. Independent
ore_yard_review found no source correctness blocker and diff whitespace passed.
Native candidate SHA256:
358868c4abecbe9df3d3cc9e24ef672a43b6b2571b5b47b11004f8813918d30a.
Studio c45f4f76-20c1-4931-b45f-ce30d679fb1b.
Dataset4 still FAILED, now localized to cart__000. Earlier datasets still pass.
Compaction is not a capacity fix. Future work can share identical mesh resources
across datasets with explicit lifetime ownership; do not remove datasets or
destroy live backing meshes and claim combined success. Both Play runs stopped.

## Save checkpoint and unresolved shutdown dependency

Original user Studio was saved through its native Save As dialog to:
build/shutdown-20261019/TwoRoute_Studio_Checkpoint.rbxl (1,295,587 bytes), SHA256
089dde8cfc4aa81994e2c95df27af4f2b90a3be859477bd239553191eb9b2dc9.
It then closed from its already-pending close request. Original pre-save file
is also preserved as TwoRoute_before_save.rbxlx, SHA256
14574e7194ed9832fa555bbc19f317df90a7552b74b22760dfa0cb2acbbb4720.

Blender PID36236/window134610 still has an unsaved scene. Native Save As and
menu attempts have not produced a verifiable saved .blend. Some captures do
not refresh the app content reliably. Do NOT claim this scene saved and do
NOT force shutdown until it is preserved. Reinspect the actual UI at the stop
checkpoint; preserve the user's scene rather than replacing it with a new one.
Rojo/Blender bridges previously verified are no longer running; old connection
evidence must not be presented as a current connection.

Cue06 and inventory before/after native fixtures are built, not yet tested.
Latest measured account quota is 14% remaining at 10:15. Full game/cities,
Lv100/tower, final art fidelity, audible assets, earned native Class3 and
physical-device acceptance remain open. At 11:00 pause the active goal because
the user explicitly requested the stop; do not mark it complete.
