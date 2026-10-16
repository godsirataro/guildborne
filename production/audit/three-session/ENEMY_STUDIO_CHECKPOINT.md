# Enemy source art and binding review

Local Memory candidate Guildborne_QualityEnemy1.rbxlx, Studio instance
b2d3d79a-8ab8-44d8-a207-ad47ba5fe4fc, PlaceId/GameId zero. All 415 built script
entries and preview attributes matched before Play. The binding module was then
executed explicitly from the controller source in the local client for inspection.

Both weighted source actors constructed successfully: 43 native Bones and 43
EditableMesh bones each after FixedSize conversion. Construction took 0.316 and
0.252 seconds in this local run, not a device benchmark. Rest, Walk at 0.5 sec
and final Death were visually inspected in the actual client. Seven source clips
per actor produced finite bone transforms; Death at 100/101 seconds held the
same endpoint. Screenshots enemy-studio-rest/walk/death.jpg use review cameras.
These actors were positioned manually for art inspection, not gameplay acceptance.

Immediate and during-yield cancellation retained zero resources; explicit destroy
removed both review actors. See enemy-preview-lifecycle.json.

## Actual server models

The player chose and confirmed Warrior through ordinary GUI input, recruited Rowan
and saved the party. Region entry and subsequent combat proximity were scripted
local fixtures, not proof of ordinary travel. Existing server code created the
four Greenwood encounters. The opt-in binding replaced only Scout/Captain art:
27/35 authored native visual parts hidden locally; roots remained unchanged.
The imported mesh sits outside the source rig, preserving native Motors, health
UI, collision and warning geometry. Maximum two constructed/pending imports.

Real server combat then produced Idle, Approach, Attack and damage observations;
the binding selected Idle, Moving, ConfirmedImpact and Hit, with sampled positional
follow error zero. Actual Q input reduced Scout health by 13 in the observation
window. See enemy-bound-combat.json; do not infer a complete kill/reward test.
Unknown weapon contact timing remains unbound; confirmed impact does not fabricate
an anticipation clip. Actual source art screenshot: enemy-bound-scout.jpg.

Client-side suspension restored hidden parts, removed the handle and rebound with
a fresh generation after return. A separate explicitly synthetic cloned-model
fixture exercised corpse tilt and respawn. It verified that Death preserves the
last live basis instead of combining the authored pose with the server's native
90-degree corpse tilt/lift; source corpse stayed unchanged, position error zero,
respawn used fresh state, and teardown restored native art. Already-dead models
retain native presentation until alive. See enemy-bound-death-respawn.json.

## Remaining

This proves local source-art construction and bounded presentation integration,
not uploaded runtime assets, full contact synchronization, multiplayer isolation,
physical-device performance, final art approval or release. S13 is correcting
world overlap/normals/collision; S14's revised HUD/Journal is still awaiting combined
visual verification. No public/private publishing, spending or production writes.
