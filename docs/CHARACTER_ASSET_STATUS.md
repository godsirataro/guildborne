# Character asset evidence

The original 89-entry manifest remains PLANNED and all Roblox asset IDs remain
null. `AppearanceAssetRegistry` starts with no imported templates. User-supplied
concept images are artistic references, not geometry evidence.

| Layer | Actual status |
| --- | --- |
| Original archive/specification | hash-verified intake retained; bundled scripts not executed |
| Runtime catalog | manifest IDs mapped to local Luau; production imports absent |
| Native candidate visuals | labeled 15-Part test substitutes; not accepted MeshParts |
| Blender Standard/Heavy | seven original candidates: 21 hashed blend/FBX/GLB files; two body audits and four body reimports passed |
| Local mesh inspection | 35 genuine EditableMesh MeshParts created from Blender triangles; 15 core meshes per body; static inspection only |
| Local articulated body inspection | Standard/Heavy each 15 true MeshParts/15 source-derived Motor6Ds; native temporary joint-sweep moves 13 joints/body; 4 rigid hair/hat anchors retained; flexible garments omitted |
| Layered cages | unavailable; production fit pending |
| Roblox import | pending; runtime IDs null |
| Studio/game/device/human | separately recorded; no blanket completion claim |

Source/export targets follow exact contract basenames in assets/characters,
assets/clothing and assets/accessories. See production/character-import for
observed Blender reports. The shared specification is preserved under
production/character-kit-v1/original/Guildborne_Character_Pipeline_v1.

Both bodies have 884 evaluated triangles. Eight actual Blender renders and
numeric bend inspections are retained. Faces/hands and overall art still need
human review. Clothes are authored against Standard; Heavy fitting is pending.
The local MeshParts have empty MeshId values and register no Roblox asset IDs.
They do not replace the runtime Parts renderer. See the [Studio record](CHARACTER_STUDIO_TEST.md).

The additional articulated screenshot is a real Studio capture of the rough
source candidates in a local joint-sweep pose. It does not show layered clothing:
the dark torso/pelvis/thigh material is the retained body modesty coverage.
The temporary animation provider token is local clip registration, not a
published Roblox animation asset ID. All catalog/runtime import IDs stay null.
