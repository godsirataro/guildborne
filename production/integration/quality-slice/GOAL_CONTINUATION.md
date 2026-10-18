# Active production goal — continuation update

Updated 2026-10-18 at the user's explicit request to update and retain the goal.
Goal status: ACTIVE. Canonical full scope: ../../design/integration/MASTER_GOAL.md.
The goal API currently permits status changes only; its older starter-slice wording
must not narrow the user's requested outcome or be marked complete prematurely.

Deliver the full original, polished Guildborne RPG through coordinated S13 Map,
S14 native GUI, S15 Animation/VFX/SFX and S17 NPC/Quest/Character work. Connect all
cities and open-world routes, monster/quest progression through level 100, tower
content, and the player with up to five hero companions. Follow available visual
references and use reviewed catalog assets and verified Blender/Rojo/Studio work.
Inspect local material and research decisions autonomously. Server owns outcomes.

The first connected corridor is an intermediate acceptance gate. Require real
quest selection, navigation, companion combat, skills, confirmed audiovisual
feedback and reward/status presentation. Local checks, Blender validation,
native import, Studio tests, physical-device tests and human approval remain
separate evidence states; unfinished content cannot be called 100% complete.

## Current continuation pointers

- Controller worktree: C:/Work/MySelf/Guildborne-controller.
- Branch: codex/three-session-integration; last observed HEAD 3cb51fc.
- Last recorded pushed checkpoint: a8cb9f7. Later changes need reviewed push.
- Shared ledger: C:/Work/MySelf/Guildborne/build/agentic/four-session-v6.sqlite3.
- Full source and task details: V6_ART_RUNTIME_CHECKPOINT.md and preserved raw
  LANDFORM_V6_IMPORT_FAILURE.json in this directory.
- S17 hairpin fix integrated as 8b38847; native five-companion outward/return
  fixture completed PASS_NATIVE_FIXTURE. See PARTY_WALK_V6_PASS.md and raw JSON
  for 1488 samples, 79 segments and limits of synthetic eligibility.
- S13 broader landforms failed native mesh import at the 2048-stud extent limit.
  Spatial partition correction remains required before visual acceptance.
- S15 Greenwood presentation integrated as f46fb8c; the running party fixture
  predates it. Its separate native presentation/combat verification is pending.
- Post-integration baseline handle 50947 completed exit 0 with 936 tests;
  retained log: build/controller-greenwood-motion-v6-baseline.log.
- Preserve earned Studio sessions; do not replace them with synthetic fixtures.
- Enforce exclusive write/Studio/Blender ownership, independently review changes,
  commit and normal-push. No new PR, merge, force-push, publishing, spending or
  production DataStore writes.

## Usage stop condition

Fresh account read for this update reports 31% used / 69% remaining in the Codex
weekly window. Continue dependency-ready work until the requested outcome is
complete or reported remaining usage reaches approximately 5%. Check between
bounded work waves; save progress and handoff at the threshold. Do not redeem
resets. This percentage is a timestamped observation, not a completion estimate.
