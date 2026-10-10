# Shared Contract v1 — Guildborne Modular Characters

This document is the *single source of agreement* between Blender work and Codex Astra implementation. The JSON manifest is the machine-readable catalog. **This repository kit is a specification, not a generated 3D character pack.**

## Species IDs and available jobs

Biological `raceId`: `HUMAN`, `ELF`, `ORC`, `DWARF`.

Every race may select `KNIGHT`, `WARRIOR`, `ARCHER`, `MAGE`, `PRIEST`. Class specialization, unlock level and skill tree never depend on the cosmetic race or body. `WIZARD` = Human appearance bundle, not a race or gameplay class.

## Core R15 visible geometry — exactly 15

| Order | Roblox Blender/source mesh name | Roblox runtime part | Purpose |
|---:|---|---|---|
| 1 | `Head_Geo` | `Head` | Head geometry |
| 2 | `UpperTorso_Geo` | `UpperTorso` | Chest/shoulders |
| 3 | `LowerTorso_Geo` | `LowerTorso` | Abdomen/pelvis |
| 4 | `LeftUpperArm_Geo` | `LeftUpperArm` | Left upper arm |
| 5 | `LeftLowerArm_Geo` | `LeftLowerArm` | Left forearm |
| 6 | `LeftHand_Geo` | `LeftHand` | Left hand |
| 7 | `RightUpperArm_Geo` | `RightUpperArm` | Right upper arm |
| 8 | `RightLowerArm_Geo` | `RightLowerArm` | Right forearm |
| 9 | `RightHand_Geo` | `RightHand` | Right hand |
| 10 | `LeftUpperLeg_Geo` | `LeftUpperLeg` | Left thigh |
| 11 | `LeftLowerLeg_Geo` | `LeftLowerLeg` | Left shin |
| 12 | `LeftFoot_Geo` | `LeftFoot` | Left foot |
| 13 | `RightUpperLeg_Geo` | `RightUpperLeg` | Right thigh |
| 14 | `RightLowerLeg_Geo` | `RightLowerLeg` | Right shin |
| 15 | `RightFoot_Geo` | `RightFoot` | Right foot |

The invisible rig `HumanoidRootPart` is not one of the 15 visible body meshes. Hair, brows, elf ears, orc tusks, dwarf beard, armor, cosmetics, glasses, hats, robes, shoes and gloves must be removable **outside** these 15 core meshes. Body caps and compliant anatomical coverage are required.

## Two clothing technologies

**Flexible layered garments**: custom mesh, compatible skeleton/skin where necessary, inner and outer cages, Studio `WrapLayer`, body `WrapTarget`, verified UV correspondence, ordered layering. Useful for shirts, pants, dresses, robes, fitted cloth. The term 'one item fits all' is NOT assumed until tested for every preset. See Roblox character appearance and clothing specifications.

**Rigid accessories**: separately attached gear: helmets, hair, pauldrons, armor plates, rings, weapons, tusks, ears as appropriate. Use correct attachment names, transforms and collision/safety rules; no clothing asset modifies body geometry in place.

`fitProfile` determines item compatibility:
`FAMILY_HUMANOID`, `FAMILY_ORC`, `FAMILY_DWARF`, or `PRESET_SPECIFIC`. A generic humanoid garment can list human/elf presets **only after** tests; never infer that fit is universal. Rigid armor may require different offsets/scales across presets.

## Body variants

Exact variants are in `manifest/body_presets.json`: 4 Human, 3 Elf, 3 Orc, 3 Dwarf = **13 planned visual body presets**. These are independent authored/derived body geometry packages. Do not assume Blender shape keys become Roblox runtime body morphs automatically. Arbitrary sliders not planned for first pass. Wizard uses Human body, not a 14th race preset.

## Skin palettes

`manifest/skin_palettes.json` has **five options per race** (20 palette values) as configuration IDs, not 20 separately modeled bodies. Prefer neutral texture maps + tested `SurfaceAppearance.Color` or verified MeshPart-tint workflow. Ensure face, neck, hand and body seams maintain consistent skin coloring and variants remain visible in daylight/nighttime lighting. Palette names are aesthetic only: no racial attributes or stat bonuses.

## Required runtime appearance schema

```json
{
  "appearanceVersion": 1,
  "raceId": "HUMAN",
  "bodyPresetId": "HUMAN_STANDARD",
  "skinPaletteId": "SKIN_HUMAN_03",
  "headPresetId": "CHR_HEAD_HUMAN_01",
  "hairAssetId": "ACC_HAIR_HUMAN_01",
  "hairColorId": "HAIR_DARK_BROWN",
  "beardAssetId": null,
  "raceFeatures": {},
  "outfitSlots": {
    "INNER_TOP": "CLO_TUNIC_TRAVELER_01",
    "INNER_BOTTOM": "CLO_TROUSERS_TRAVELER_01"
  }
}
```

IDs are stable. Save IDs/color choices only; assets remain in server-controlled libraries. Server validates ownership, fit profiles, slot conflicts, entitlement and changes. Never trust an arbitrary client-provided Roblox asset ID.

## Clothing slots / stacking

`INNER_TOP`, `INNER_BOTTOM`, `OUTER_TOP`, `OUTER_BOTTOM`, `CHEST_ARMOR`, `SHOULDERS`, `GLOVES`, `BOOTS`, `BELT`, `CAPE`, `HEADWEAR`, `HAIR`, `BEARD`, `RACE_FEATURE`, `WEAPON`.

`INNER_TOP`/`INNER_BOTTOM` removable garments are NOT the always-on non-exposing modesty covering. Always-on modesty is part of the in-game safety rendering path; hidden body surfaces must never leave naked patches when clothes come off.

Keep layered ordering and rigid attachment order deterministic. On appearance re-render, do not duplicate accessories or permanently alter inventory.

## Paths and ID conventions

IDs use uppercase ASCII snake case. Files use lowercase folders and exact `asset_id` basenames to minimize collisions. Source path examples:

- `assets/characters/source/CHR_BDY_HUMAN_STANDARD_V01.blend`
- `assets/characters/export/CHR_BDY_HUMAN_STANDARD_V01.fbx`
- `assets/clothing/source/CLO_TUNIC_TRAVELER_01.blend`
- `assets/clothing/export/CLO_TUNIC_TRAVELER_01.fbx`
- `assets/accessories/source/ACC_HAIR_HUMAN_01.blend`

`StudioPath` is a target library path, not evidence it exists. Asset IDs default to `null` until actually imported. Never auto publish or upload to Roblox Marketplace.

## Fairness/performance

Visual stature is cosmetic. Validate camera, navigation, accessories, PvE/PvP hit registration, collision, follower formation. Keep game-authoritative combat hitboxes consistent and fair irrespective of visuals. Performance must be profiled in a busy 4-player/20-companion scene on simulated mobile; physical device UAT remains a separate gate.

## Evidence and status

Allowed `status`: `PLANNED`, `IN_PROGRESS`, `EXPORTED`, `IMPORTED`, `TESTED`, `ACCEPTED`. Do not mark TESTED based on concept images. Only the importing/Studio-testing party may attach real Roblox asset IDs and proof.

## Documentation baseline

Official Roblox docs (verify latest before import/implementation):
- https://create.roblox.com/docs/avatar/character-bodies/specifications
- https://create.roblox.com/docs/avatar-setup
- https://create.roblox.com/docs/characters/appearance
- https://create.roblox.com/docs/art/accessories/layered-clothing
- https://create.roblox.com/docs/art/accessories/clothing-specifications
- https://create.roblox.com/docs/avatar/character-bodies/import

## v2 integration clarification

The sample head ID now uses the canonical catalog ID. Earlier HEAD_*_01 examples resolve only through aliases.json; aliases do not confer ownership. Cosmetic raceId remains separate from the legacy combat ancestry field; do not pass uppercase IDs straight into Expansion.Races. Existing ancestry bonuses and saved unlocks need a reviewed migration, not silent deletion.
