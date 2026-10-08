# Six civic contact-art studies — 2026-10-06

All six professions now have editable Blender scenes, GLB and FBX exports, 16-bone rigs and six-second activity clips. These are local stylized studies. Final reference likeness, platform asset import, main-world binding, sound listening, mobile performance and human approval remain pending.

| NPC | Source folder under assets/uat01 | Contact behavior | Export triangles |
| --- | --- | --- | --- |
| Elian | elian-desk-v1 | Stamp meets charter at 3 seconds; seal follows contact | 6180 |
| Vaela | vaela-garden-v1 | Tilted can spout sends water into open soil pot | 9728 |
| Borin | borin-forge-v2 | Hammer strikes held workpiece at 1, 3 and 5 seconds; anticipation and rebound | 14304 |
| Nyra | nyra-desk-v1 | Stylus follows a five-point star on the chart | 8208 |
| Sela | sela-desk-v1 | Pen writes three rows with lifted return strokes | 8720 |
| Roka | roka-hearth-v1 | Ladle circles inside bowl held by the other hand | 9484 |

Each folder contains a manifest and separate clean GLB/FBX reimport reports. Tests cover relevant tool contact/clearance, stationary support and feet, skin and loop seams. The GLB importer creates an 80-triangle Icosphere bone control; current counts exclude that importer helper, correcting earlier inflated counts. Export triangles include authored scene cosmetics.

## Actual Studio review

`build/Guildborne_CivicContactArtReview.rbxlx` is a standalone local viewer. Build with `python tools/build_civic_contact_preview.py`. It packages all six source datasets; HTTP is disabled and no profile, purchases or gameplay rewards are present. EditableMesh creates 27,356 vertices and 52,892 triangles plus 96 native Bone instances. Review-only effects add water, forge sparks, food steam, a stamp seal and prism light. These cosmetic equivalents are not final particle art or uploaded assets.

Read-only native probes passed 52 sampled contact poses and 12 cosmetic timing samples. Evidence: `validation-civic-contact-native.json`, `validation-civic-contact-native-effects.json` and `evidence/civic-contact-native-motion.gif`. That GIF predates the review effects. Native render screenshots are in the same evidence directory.

Fresh standalone Play loaded all six rigs with no avatar and HTTP disabled. Ordinary mouse input tested Pause (label becomes Play), Reset while paused (0.00 seconds), selecting Borin (only Borin visible), All six (six visible) and Resume (time advanced to 0.68). Console was empty. Viewport framing reserves room for controls; selecting a character hides the other models/effects. Orbit, wheel zoom, keyboard and other device sizes are not yet acceptance-tested. Play was stopped after the check.

There are now 37 original synthesized WAV files across the project and 35 AI-generated images; Blender renders do not increment the AI-image count. New activity audio has cue/peak/sample-format checks, but listening and platform import remain pending. The standalone viewer is silent.

## Next production work

City service architecture now covers 24 native buildings; see `CIVIC_INSTITUTIONS.md`. The separate walkable six-cast fixture passed ordinary walking, local pause/resume and distance-culling checks; see `CIVIC_CAST_SCENE.md`. Refine reference likeness with front/side comparison and bind reviewed models plus polished activity interruption to existing full-game dialogue hosts. Preserve existing earned travel, market and recruitment rules. Combat weapon/skill clips remain a separate scope: the bow contact/reload study in `BOW_CONTACT_STUDY.md` is locally verified, with gameplay retargeting still pending.
