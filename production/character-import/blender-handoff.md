# Human source candidates and runtime adapter

Actual local production on 2026-10-11 (Asia/Bangkok), using Blender **5.2.1 LTS**
build `9e2066aef7ef`. These are original procedural geometry candidates derived
from the user's faceted fantasy visual direction. No competitor assets, external
mesh packages, textures or fonts were copied. Human art acceptance is pending.

## Shared IDs and existing source

The reviewed original manifests under
`production/character-kit-v1/original/Guildborne_Character_Pipeline_v1/manifest`
provide the exact IDs. Existing `tools/blender_character_kit.py` was reviewed;
the Sentinel NPC source/export was preserved. The new generator does not join
the 15 biological body sections into one body mesh.

| Canonical asset | Actual mesh objects in export | Evaluated triangles | Authored body |
| --- | ---: | ---: | --- |
| CHR_BDY_HUMAN_STANDARD_V01 | 15 | 884 | HUMAN_STANDARD |
| CHR_BDY_HUMAN_HEAVY_V01 | 15 | 884 | HUMAN_HEAVY |
| CLO_TUNIC_TRAVELER_01 | 1 removable garment | 256 | HUMAN_STANDARD candidate |
| CLO_TROUSERS_TRAVELER_01 | 1 removable garment | 300 | HUMAN_STANDARD candidate |
| CLO_ROBE_WIZARD_01 | 1 removable garment | 376 | HUMAN_STANDARD candidate |
| ACC_HAIR_HUMAN_01 | 1 rigid hairstyle | 60 | HUMAN_STANDARD candidate |
| CLO_HAT_WIZARD_01 | 1 rigid headwear | 88 | HUMAN_STANDARD candidate |

Each row has an authentic `.blend`, `.fbx` and `.glb` at its original manifest
source/export directory. The hat belongs to `assets/clothing` per the supplied
manifest. No helmet ID exists in that manifest. Editable `.blend` scenes retain
body and outfit context; export selections contain only the selected canonical
asset, shared armature and attachment empties. The `Body` collection contains
exactly the 15 `_Geo` meshes; garments and hair are outside it.

`geometry-report.json` records the 21 files' SHA256 values and actual mesh metrics.
All 21 recorded hashes were rechecked after rendering and import inspection.
Statuses are **EXPORTED** in this local delivery report. The supplied planned
catalog and server import map are unchanged **PLANNED** facts with null Roblox
IDs and no registered template references. Local exports do not imply import.

## Rig, materials and clothing limits

The armature contains the 15 named body bones plus an invisible
`HumanoidRootPart` bone, with conventional torso/arm/leg parent hierarchy. All
vertices are weighted and normalized; these intentionally simple source
candidates use one influence per vertex. Closed ring meshes include end caps and
UV layers. Body upper torso, pelvis and thighs carry opaque base coverage
independent of tunic/trousers/robe. Exposed body surfaces use one neutral skin
material; hair and garments have separate materials. Detailed face/finger art,
joint seams and artistic quality need review.

Source coordinates are Blender Z up and forward -Y. FBX conversion uses the
existing project's -Z forward/Y up export profile; glTF uses its Y-up export.
Reimport into Blender preserves mesh names, bone names, weights and geometry.
This does not validate Roblox 3D Importer interpretation, axes, joint placements
or attachment orientation. Studio's actual import workflow remains the next gate.

**Cages are UNAVAILABLE.** No body outer cage or garment inner/outer cage has been
validated against Roblox reference topology/UV correspondence. No dummy
`WrapLayer`/`WrapTarget` is manufactured. Tunic, trousers and robe are separate
skinned, fit-specific fallback source candidates, not proven flexible layered
clothing. They are authored against Standard only; Heavy fit is untested, and
other races are unsupported. The robe keeps biological legs separate. Hair and
hat declare `HairAttachment`/`HatAttachment` targets; visual fitting is pending.

Current official references checked during implementation:
[layered accessories](https://create.roblox.com/docs/avatar/layered-accessories),
[WrapLayer](https://create.roblox.com/docs/reference/engine/classes/WrapLayer),
[Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D).
Layered accessories require actual cage meshes and a rigged visual mesh; the
runtime structural checker does not certify UV correspondence or fit.

## Real local checks

Generation used `--background --disable-autoexec --python-exit-code 2` with the
reviewed local `tools/blender_modular_human.py`. No network provider or external
model execution was used. Blender attempted an optional thumbnail write outside
the repository, which the host denied; source/export saves succeeded. The raw
generation log retains that nonfatal diagnostic.

- Existing `tools/agentic/blender_audit.py`: both bodies passed local geometry
  checks with exactly 15 expected names, zero non-manifold edges, UVs, armature
  modifiers and zero unweighted vertices.
- Body FBX and GLB reimport: all four exports passed 15-mesh, 884-triangle,
  16-bone, UV, weighted and finite-coordinate checks. The original GLB checker
  counted Blender's importer-created `Icosphere` bone-display helper as exported
  geometry and failed. Its failure log remains intact. The raw GLB JSON showed
  exactly 15 serialized meshes; the corrected checker excludes only actual
  `pose_bone.custom_shape` references and passed. This is a checker correction,
  not evidence that an extra mesh was removed from the export.
- Source inspection measured shoulder/elbow/hip/knee poses on both bodies.
  Evaluated vertex displacement was finite and moved the expected limbs; this
  numerical sweep does not establish seam, clothing or animation acceptance.
- Both sources have actual front/side/back/exploded Blender renders at
  `assets/characters/export/previews`, with image hashes in each inspection JSON.
  Original source hashes remained unchanged. These are Blender renders, not
  Roblox screenshots.
- The scoped runtime files passed Luau compilation and Roblox-targeted static
  analysis with the installed definitions. Full game verification and live
  Studio evidence belong to the integration coordinator.

Raw logs and read-only body audits are under `build/agentic/modular-human-*`.
Export reimport reports, source inspection metrics and images are beside the
body exports in `previews`. Reports retain actual version and pending gates.

## Runtime API for the integration coordinator

`Shared.Presentation.ModularAppearance.Renderer` exposes:

```lua
Renderer.Validate(selection) -- boolean, optional error
Renderer.Build(selection) -- local preview Model; invalid selection raises
Renderer.apply(existingCharacter, selection) -- boolean, optional error
Renderer.clear(existingCharacter) -- remove visual overlay and restore prior visibility
```

`Server.Services.CharacterAppearance.RigAssemblyService` exposes `Build`,
`Apply`/`apply`, `Clear`, `Validate`. Supported runtime selections are Human
Standard/Heavy, the five canonical Human skin palettes, canonical Human head 01,
hair 01, catalog hair colors, tunic/trousers 01, Wizard robe 01 and Wizard hat 01.
The server service remains responsible for selection ownership and persistence.

The runtime representation is explicitly **PLACEHOLDER**, with exactly 15 core
`Part` objects. These are not `MeshPart` assets and do not use the exported body
meshes yet. Existing R15 joints drive segment overlays; existing R6 hero proxies
drive grouped segments and cannot independently animate elbows/knees. Attributes
state this limitation. Decorative pieces cannot collide, query or touch and are
massless. Original root, humanoid, joints, combat proxies and equipped gear stay
intact. Legacy cosmetic visibility is reversible. Render failures leave the old
overlay intact; repeated identical selection avoids duplicate rebuilds.

`AppearanceAssetRegistry.ValidateLayeredTemplate` checks a real imported garment
handle, cage references and the 15 body MeshParts' WrapTargets. It performs
structural checks only. No import is registered by this work.

## Next acceptance owner

The Studio integration coordinator must import into the explicitly identified
private test place only when authorized by the actual importer, review axes,
origins, R15 joints, material tint and attachments, then test Standard/Heavy
movement/combat/garment removal and weapon preservation. Keep all Roblox IDs
null until observed import. Source art needs face/hands/seam review. Cages,
per-preset clothing fit, true R15 animations, Studio screenshots, reconnect,
multiplayer and physical-device acceptance remain pending. No publishing or
Robux spending was performed.

## Isolated local mesh preview extension

`GeneratedGeometry.luau` contains evaluated vertices, triangles, corner UVs,
flat normals and actual source material colors extracted from all seven hashed
`.blend` files. Source coordinates map `(x,y,z)` to Roblox `(x,z,-y)` with triangle
winding preserved. Source files remain unchanged. Garment identity follows the
shared catalog category, rather than inherited Blender custom body flags.

`LocalGeometryPreview.luau` creates genuine `EditableMesh`-backed MeshParts from
that geometry using `AssetService` and `Content.fromObject`; this does not upload,
register an asset ID, or populate the production import registry. Its guard
requires Studio plus PlaceId0/GameId0. It returns static, anchored, non-colliding
models for isolated inspection and attaches nothing to existing actors.

API: `Build(selection)` and `BuildAsset(canonicalId, options)` return a model or
an error; `Destroy(model)` releases retained EditableMesh resources;
`ResourceCount(model?)` exposes current lifecycle counts. Model destruction also
releases resources. Bodies retain exactly15 core mesh names, removable garments
stay separate, exposed skin uses the chosen palette and garments/modesty retain
their source colors. This local preview does not establish cage, R15 articulation,
production import, outfit fit or gameplay acceptance. The ordinary Renderer,
server import registry and runtime flags are unchanged by this extension.
