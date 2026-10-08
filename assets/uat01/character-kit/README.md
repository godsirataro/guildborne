# Guildborne Sentinel — original custom rig and motion candidates

Created locally in Blender 5.2.1. The editable `.blend` contains one original block-style Sentinel with 16 bones, 288 triangles and one normalized bone influence per vertex. The display-stage meshes are pose previews, separate from the rig.

`Guildborne_Sentinel_Rest.fbx` and `.glb` contain the mesh and skeleton. Nine separate FBXs contain Idle, Walk, Run, Slash, Cast, Dodge, Hit, Down and Recover at 30 fps. Durations, loop flags and intentionally empty Roblox animation IDs are in `manifest.json`. All clips keep the Root bone stationary. They do not provide movement, invulnerability or hit timing in gameplay.

![Representative motion poses](preview.png)

[Animated contact sheet](motion-preview.gif) shows all nine motions normalized to a two-second preview loop (24 frames). It is a visual comparison, not the original clip timing; use manifest durations for import. `render_character_motion.py` renders the authored bones and `assemble_character_preview.py` encodes the resulting frames.

Rebuild using `tools/blender_character_kit.py`; verify with `tools/verify_character_kit.py`, both from Blender background mode with `--python-exit-code 1`. `roundtrip-report.json` records SHA-256, triangle/bone counts, normalized weights, sampled motion, stationary root and loop seams for all 11 exports. Blender's glTF importer creates its own bone-display Icosphere; that helper is excluded from asset mesh counts.

The rig is a **custom NPC candidate**, not an approved Roblox avatar or an installed replacement for player characters. It has no facial rig, cages or clothing attachments. Inspect movement, foot sliding, held-weapon alignment and scale in Studio before use. The reference mesh is intentionally simple; character art and motion polish remain pending.

Roblox documents FBX/glTF character import and separate animation-file import through its animation tools: [character import](https://create.roblox.com/docs/art/characters/import), [custom character animation](https://create.roblox.com/docs/resources/beyond-the-dark/custom-characters), [mesh specifications](https://create.roblox.com/docs/art/modeling/specifications). Export flags follow the [Blender export API](https://docs.blender.org/api/main/bpy.ops.export_scene.html). Studio import, skeleton mapping/retargeting, approved animation IDs, runtime blending and physical-device performance have **not** been verified. Nothing was uploaded or published.
