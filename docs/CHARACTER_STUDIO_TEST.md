# Character validation record — 2026-10-11

Baseline domain suite: 672 passed. Baseline Rojo build passed after approved local
execution resolved sandbox file canonicalization denial. Integration results and
exact source hashes will be appended after actual checks.

MCP discovery initially returned no connected Studio. A subsequent bridge session
was listed but get_studio_state and execute_luau returned `Place is not open`.
That response is connection evidence only; no gameplay or screenshot PASS follows.

Use the generated local `build/Guildborne_CharacterPreview.rbxlx` with Memory and
an empty cloud allowlist. Inspect place0/universe0 and current module identity
before starting. Run `tests/studio_modular_character_probe.luau` only in this
isolated candidate. Reject staging/persistent sessions before creating fixtures.

Required live checks: Standard/Heavy, all five Human palettes, 15 core names,
R15 joints, repeated clothes/hair/hat removal, base coverage, collision/query
preservation, existing gear, actual command Apply/Cancel/rejection/replay and
respawn. Inspect Output and capture front/side/back and movement/combat images.
Run PC and simulated phone portrait/landscape separately. No physical touch claim.

Production golden-path acceptance requires genuine MeshParts, valid body cages
and flexible garment cages, bends, all requested animations, five companions,
doors/stairs/camera, two real clients and persistent reconnect. A successful
placeholder test cannot pass these geometry and platform gates.

## Observed implementation tests

Main was fetched and fast-forwarded to `4cc9a82`; the implementation remains an
uncommitted private candidate. The shared archive master prompt was read fully,
and the original shared contract/catalog intake is retained with its archive hash.

| Check actually run | Result and limit |
| --- | --- |
| Domain regression suite | 714 passed, including 42 appearance cases; deterministic market conservation/load checks included |
| Catalog regeneration | 89 assets, 13 bodies, 20 palettes and aliases match; IDs remain null |
| Source/build checks | final strict src/tests analysis, 329 Luau compilations, Rojo build/sourcemap boundaries and repository checks pass |
| Blender | 7 candidates, 21 hashed files, 2 body audits, 4 FBX/GLB body roundtrips; source geometry/art are candidates |
| Studio structural fixture | 14 cases: Standard/Heavy x5 palettes plus rebuild/clear; 15 core Parts/15 joints, modesty, equipment/root preservation and ancestry visual isolation |
| Local mesh inspection | 35 actual EditableMesh MeshParts from the 7 Blender sources; 15 core meshes/body and matching triangles; resources released to zero; static only |
| Actual player command path | native PC Apply saved Standard; remote Heavy, 3 palettes, robe/hat/hair changes/removal saved; respawn restored Heavy/skin/revision |
| Rejection/replay | unowned actor, stale actor/profile and forged asset rejected; committed request replay returned AlreadyCommitted without revision increase |
| UI fixture | 4 native client cases: uncertain SavePending, unrelated rejection, correlated denial, matching late save; fixture sent no network writes |
| Native input | Heavy preview changed draft only; Cancel showed warning/discard and left revision0; Apply committed once and released pending |
| UI layout | PC1366x768; iPhone17Pro simulator landscape874x402 and portrait402x874, EN/TH screenshots; compact choices116px, viewport80px, actions44px |

The first tool-mediated source sync was truncated and failed startup. Opening an
exact rebuilt local file fixed it; final candidate startup had no game error.
A later analyzer run caught UI callback compatibility and fixture typing errors;
both were repaired and full analysis rerun successfully. Failed logs are retained.
The initial GLB checker counted a Blender importer helper; the corrected checker
passed and its original failure remains in the handoff. None is hidden as a PASS.

Movement input produced 34.50 studs of displacement and Running/Jumping/Freefall/
Landed states, with native Walk/Run/Jump/Fall tracks observed. The sampled joint
rotation was zero, and one existing idle asset had Length0. This does not establish
animation deformation or garment fit. A portrait Side-button input probe did not
change the camera; full orbit/zoom/touch-input acceptance remains pending.

Screenshots are real Studio captures, retained under production/character-import:
[local meshes](../production/character-import/studio-local-mesh-preview.png),
[desktop](../production/character-import/studio-ui-desktop.png),
[phone landscape](../production/character-import/studio-ui-phone-landscape.png),
[Thai portrait](../production/character-import/studio-ui-phone-portrait-th.png).
[Raw observations](../production/character-import/studio-observations.json) and
[Blender handoff](../production/character-import/blender-handoff.md) keep scopes
separate. Source/screenshot hashes accompany the candidate; this is REVIEW-only.

Studio was stopped and reset to default viewport/landscape. No production
DataStore writes, asset uploads, publishing or spending were performed.
Production cage/import/animation fitting, persistent reconnect, two/four clients,
five-companion scene/performance and physical-device/human acceptance are pending.

## Source-derived rig and NPC continuation — 2026-10-11

Fresh isolated Studio `14f90567-42a7-4805-a448-1ccd40bb9768` opened the rebuilt
`Guildborne_CharacterPreview_NpcRig.rbxlx`; place0/game0, Memory persistence and
the empty cloud allowlist were asserted. The compact mesh fix was synchronized
as one bounded, complete 10KB module and fresh Play reset the module cache.
The final source is also retained in the rebuilt local preview.

- The structural fixture now has 17 cases, adding Standard/Heavy NPC builder
  preservation and civic rejection to the original14. It uses actual
  `HeroRig.Build`/`CityNpcAppearance`, but the prompt is synthetic and the models
  live in ServerStorage. Props, original welds, root, Humanoid and prompt identity
  survive apply/reapply/clear. `CityCharacterKit` fails before mutation. This
  does not test spawned world dialogue, quests, work animation or streaming.
- The first mesh fixture incorrectly treated `Catalog.Defaults.HUMAN` as a
  selection table; it is a preset ID. Correcting the fixture exposed a genuine
  client `EDITABLE_MESH_MEMORY_UNAVAILABLE` failure. Both failed results remain
  in the raw receipts. Compact fixed-size clones resolved the actual client
  build failure; no dynamic mesh creator remains retained after successful build.
- Both real Blender-derived bodies built on the Play Client with15 core
  MeshParts and15 source-positioned Motor6Ds each. A 60-degree elbow transform
  moved the hand0.8592/0.8625 studs; both returned to the bind position with zero
  measured error. Roots are invisible/anchored, body visuals non-colliding.
- A native Animator played a2-second temporary local joint-sweep clip on both
  bodies:13 joints/body had nonzero sampled rotation, including neck, shoulders,
  elbows, wrists, hips, knees and ankles. Root/waist were intentionally neutral.
  This is an isolated calibration clip, not idle/walk/run/jump/combat acceptance.
  The provider returned a local hash token; no animation was uploaded/published.
- Four actual rigid hair/hat attachment pairs remained connected within0.001
  studs. Tunic/trousers/robe were explicitly omitted from articulated rigs as
  unskinned/no-cage assets. Their fit remains pending on Standard and Heavy.
- Destruction released all34 fixed EditableMesh resources to zero and removed
  the fixture. Camera/UI inspection overrides and the temporary module were
  removed; Studio was stopped. Initial screenshot framing was reset by the MCP
  camera action, then a bounded late-render fixture captured the actual models.

[Actual articulated mesh capture](../production/character-import/studio-local-articulated-mesh.png)
shows rough source geometry and always-on modesty, not layered garments or final
face/hand art. [New raw receipts](../production/character-import/studio-npc-rig-observations.json)
retain failed probes and successful retests separately from the earlier sessions.
The local regression run passed714 domain tests and331 strict Luau/build checks.
An independent read-only review found no concrete NPC visibility regression;
full NPC-world, clothing, production import, device and human acceptance remain
pending. No publishing, asset upload, spending or persistent profile writes occurred.
