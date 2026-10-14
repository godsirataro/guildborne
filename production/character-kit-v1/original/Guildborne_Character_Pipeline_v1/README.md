# Guildborne — Modular Characters + Clothing Production Kit v1

**This package contains a production plan, engineering prompts, file contracts, and asset catalog. It does NOT yet contain generated 3D bodies/rigged meshes/clothes or verified Roblox asset IDs.**

## User goals

Create natural-looking, class-independent playable races with multiple body types and skin tones, real separated R15 limbs, separate removable garments, hair/beard/ears/tusks, hero reuse, and a robust Roblox character editor with persistence.

## What to copy into Guildborne repository

Copy the entire folder `Guildborne_Character_Pipeline_v1` to the existing Git/Rojo Guildborne project root. Keep filenames/folder name unchanged.

## Which prompt to send Astra

In the existing Codex Astra session with Roblox Studio MCP connected:

```text
Read Guildborne_Character_Pipeline_v1/01_ASTRA_MASTER_PROMPT.md fully.
Also read 03_SHARED_CONTRACT.md, all manifests and QA docs referenced there.
This is an implementation authorization only for the modular character/appearance
vertical slice, not a public release or full game redesign.
Inspect existing Guildborne code/assets/saves before changing anything.
Run tests before and after implementation. Use Roblox Studio MCP for actual
validation. Start with the Human Standard golden path, fix integration issues,
then expand races only after rig + clothing compatibility passes.
Coordinate with the Blender production lane via the shared registry.
Do not claim planned assets exist until actual exported/imported files and
Studio tests prove it. Do not publish, spend Robux or modify market release flags.
Begin now.
```

## Which prompt to send the Blender worker

Give the artist/Blender automation **`02_BLENDER_PARTNER_PROMPT.md`** and **`03_SHARED_CONTRACT.md`** along with manifest files. Start only with `CHR_BDY_HUMAN_STANDARD_V01`, a tunic, trousers and rigid hair. Iterate from Studio feedback. Do NOT ask a visual-image model to produce .blend or .fbx; a rendered concept image is not editable geometry.

## Included documents

| Path | Role |
|---|---|
| `01_ASTRA_MASTER_PROMPT.md` | Full Roblox engineering, UI, security, migration and MCP test instructions |
| `02_BLENDER_PARTNER_PROMPT.md` | Full Blender production instructions |
| `03_SHARED_CONTRACT.md` | Canonical R15 mesh names, garment types, IDs, schema, safety and ownership |
| `04_ASSET_REGISTRY.md` | Human-readable full 89-item planned asset table |
| `manifest/asset_registry.json` | Machine-readable 89-item registry |
| `manifest/asset_registry.csv` | Spreadsheet-ready registry |
| `manifest/body_presets.json` | 13 proposed body presets across 4 races |
| `manifest/skin_palettes.json` | 20 tint palette entries, not 20 body meshes |
| `manifest/fit_qa_matrix.csv` | 65 cross-preset/garment test slots, all NOT_TESTED |
| `docs/BLENDER_PARTNER_BRIEF.md` | Producer handoffs and actual production priorities |
| `docs/QA_ACCEPTANCE.md` | Test and human UAT checklist |
| `tools/validate_manifest.py` | Standard-library manifest validation script |
| `tools/build_registry.py` | Generates manifest files from specification (do not run after manual production status updates without merging!) |

## Critical rule

Astra and Blender share **IDs** but do not overwrite each other's files. Blender exports 3D; Astra implements Roblox runtime and captures actual Studio evidence. Reference drawings are NOT rigged body assets. All assets are PLANNED until the real work occurs.

## Authoritative technical reference

https://create.roblox.com/docs/avatar/character-bodies/specifications
https://create.roblox.com/docs/characters/appearance
https://create.roblox.com/docs/art/accessories/layered-clothing
https://create.roblox.com/docs/avatar-setup
