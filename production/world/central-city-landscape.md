# Central City — natural landscape pass 01

2026-10-16. Status: **SOURCE_IMPLEMENTED / BLENDER_PREVIEW / LOCAL_CHECKS_PASS**.
This is an initial native landscape study, not the final art benchmark or all-map completion.

## Implemented

`CentralCityWorld` now assembles `CityLandscape` from a reproducible shared geometry recipe.
Removed the repeated avenue TreeA/TreeB and rectangular planter placements; retained street
lanterns, benches, buildings, services, roads, NPCs, spawn and portal identities.

The new landscape contains 87 branching trees in irregular groves, 394 understory shapes,
216 grounded flower tufts, 40 weathered rocks, six low solid grassy berms, a connected
ornamental spring with bank planting, and 22 curved-route flagstones. Total: 1,598 native
parts, 133 collidable/queryable. The generator and verifier enforce an 1,800-part authoring
ceiling. This ceiling is **not** measured mobile performance acceptance.

The original procedural recipe is shared by generated Luau and Blender. No third-party model,
upload, MeshId, public publish, global Terrain mutation or per-frame decoration loop was added.
Downloaded research packs remain available for a later import/art pass; acquisition is not
runtime integration.

## Local evidence

- `python tools/verify_city_landscape.py`: deterministic source match, full rotated footprints
  against 72 reserved rectangles, 1,141 independent route samples with six-stud horizontal
  radius; PASS. These samples check new geometry only, not Roblox humanoid/party physics.
- `tools/validate.ps1`: 890 tests; Rojo build; strict analysis; compilation; repository and
  built-place checks; PASS. Final three world module sources match the validated `.rbxlx`.
- Blender 5.2.1 LTS background render: both PNGs and editable `.blend` generated. The renderer
  uses exact new primitive dimensions, rotations and colors. Lighting is Blender preview
  lighting. Existing city buildings, NPCs and services are intentionally absent from these
  isolated landscape images; the existing ground is included as context.
- Independent read-only review by `/root/feature_audit`: no route blocker found. Fixed the
  review's floating flower and missing explicit part-budget findings. Reviewer reconfirmed
  1,598 parts / 133 solid / 87 trees; no new concrete blocker. This is source review only.
- Visual iteration corrected intersecting flagstones, disconnected water shapes and camera
  near-plane clipping. The current images remain an early art study, not human art signoff.

Artifacts: `assets/uat01/city-landscape/landscape.json`, `validation.json`,
`hearth-garden-preview.png`, `landscape-layout-preview.png`,
`Guildborne_Central_Landscape.blend`, raw local logs and `evidence-hashes.json`.

Private candidate: `build/Guildborne_IntegrationPreview.rbxlx`, built with the existing
Memory-only preview builder; staging Runtime source unchanged. No publishing performed.

## Reproduce

1. `python tools/build_city_landscape.py`
2. `python tools/verify_city_landscape.py`
3. `tools/validate.ps1`
4. `"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --python tools/render_city_landscape.py`
5. `python tools/build_integration_preview.py`

## Next art and gameplay gate

Studio MCP was unavailable in this session; Blender MCP was disconnected, so rendering used
an isolated local background Blender process. No new Studio screenshots or physics results
are claimed. The previous city-services Studio evidence predates this landscaping pass.

Next: inspect the complete city at player-eye level in Studio; walk player plus five companions
through tavern/forge/guild/market/tower and every return portal; check tree/berm grounding,
canopy occlusion, spring edge and building scale; refine ground transitions, architecture,
foliage mesh silhouettes and in-game lighting. Profile the complete city on target mobile
hardware before increasing detail. Obtain human art approval before multiplying the style
across six cities, campaign areas, guild islands and war maps. These are still pending.

Shared coordinator ledger: `build/agentic/launch-v22-ledger.sqlite3`; v21 had no active owners
when the existing city-services scope was extended. This working-tree report is REVIEW-only;
no clean release commit, formal Forge acceptance or public go-live approval is claimed.
