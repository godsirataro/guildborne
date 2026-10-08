# Five Disciplines trial court

Original local 3D kit: 81 box parts / 972 triangles. Four editable assembled groups: Court, Pillars, Sentinel, Patient. The 96×96-stud court has a flat collision floor; pillars stand outside the 45-stud trial radius. Floor inlays, sentinel and patient are noncollidable. Patient is visible only in Priest trials. No mesh or animation has been uploaded to Roblox.

`Guildborne_Trial_Arena.blend` contains the editable scene. Ten FBX/GLB exports comprise the four groups plus combined court. One modeling unit corresponds to one stud; Roblox XYZ maps to Blender X,-Z,Y. Group origins remain the court origin, so imports assemble together. `geometry.json` is the deterministic source shared by the native `NoviceTrialArt` module and Blender exporter.

Regenerate with `python tools/generate_trial_arena.py`, then Blender background `tools/blender_trial_arena.py`. Check exports with `tools/verify_blender_kit.py -- --kit assets/uat01/trial-arena`. The preview is a Blender render, not proof of cloud import. AI concept and final prompt are in `assets/uat01/generated/guildborne-five-disciplines-v1.png` and `assets/uat01/FIVE_DISCIPLINES_PROMPT.md`.

Bound locally to the isolated native trial adapter. Full Chapter 00 course, saved-profile trial selection and production release remain unbound. Sentinel poses and battle effects are still pending; this kit is static geometry.
