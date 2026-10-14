# Blender ⇄ Astra Production Handoff / Do Not Work on Same Files

## Two-lane production

**Blender lane (geometry owner)**: modeling, 15 R15 body geometry meshes, clean topology, modesty body base, rig/bones, outer cages, clothing inner/outer cages, textures and tint masks, FBX/glTF exports, front/side/back images, mesh audits.

**Astra lane (gameplay owner)**: manifest ingestion, asset importing where supported, ServerStorage model library, runtime character assembly, Humanoid/attachments, body/skin/clothing selection, save/rejoin, UI, security, multiplayer replication, Studio MCP regression tests.

Both lanes read `03_SHARED_CONTRACT.md` and `manifest/asset_registry.json`. **Only the Blender lane changes source `.blend`**, **only Astra changes Roblox source code and Studio assembly**; approved changes to registry are reviewed and coordinated. Keep all generated exports in Git LFS/asset storage if large and use checksums/versioned commits; do not assume Roblox asset IDs are derivable from filenames.

## Real deliverable acceptance per Blender asset

1. Actual binary `.blend` with separated/selectable objects.
2. Actual `.fbx`/`.gltf` exports with correct parts; Blender script log is not a substitute for validated mesh.
3. Actual textures + material assignments and verified skin tint workflow.
4. Actual rig/cage inventory and mesh triangle counts.
5. Front/side/back assembled screenshots and separate exploded-preview.
6. Written compatible fit-profile intent (`PRESET_SPECIFIC` if necessary).
7. `EXPORTED` status only after files exist and export was checked.

## Art production priorities

**P0**: Human Standard base, Human Heavy (fit contrast), 3 tested skin swatches, traveler tunic + trousers, basic rigid hair. Real Studio confirmation before batch producing other races.

**P1**: Elf Graceful, Orc Standard, Dwarf Compact; one representative garment/armor per family; race-specific ears/tusks/beards; common class gear reference.

**P2**: Remaining shapes, hairs, heads and cosmetic wardrobe. Most should reuse compatible rig/cage templates and materials while retaining visible identity.

## Nonuniform avatars

Dwarf short arms/legs and Orc width stress clothing/animation/camera. Layered clothing may need new cage/fit profiles. Never silently resize mesh-only clothes by a raw scale until deformation proven. A fallback fit-specific export is acceptable and must be declared. Never change combat stats or reach to account for body geometry.

## Fitting QA matrix

`manifest/fit_qa_matrix.csv` enumerates 65 sample combinations. `NOT_TESTED` must remain until Astra verifies actual Studio screenshots/bending and the cloth does not clip. Extend the matrix to every released outfit and every allowed body preset before launch.

## Official technical reading

- https://create.roblox.com/docs/avatar/character-bodies/specifications
- https://create.roblox.com/docs/avatar/character-bodies/export
- https://create.roblox.com/docs/avatar-setup
- https://create.roblox.com/docs/art/accessories/clothing-specifications
- https://create.roblox.com/docs/characters/appearance
