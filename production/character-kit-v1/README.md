# Modular Character Kit v1 — reviewed intake

This folder incorporates the supplied kit's **89 planned asset entries, 13 body presets and 20 skin palettes** in [catalog.json](catalog.json), alongside its original [Shared Contract](SHARED_CONTRACT.md). This is a specification and production queue, not 89 generated meshes or imported Roblox assets.

`assetColumns` defines the compact asset-row field order. IDs, categories, race, variant, slot, fit profile, technology and priority are preserved from the supplied manifest. Preset and palette records are preserved as data. Source/export target paths and the original workbook are available through the verified full-archive intake below; target paths are not proof that source models exist.

## Exact original archive

Reviewed file: `Guildborne_Modular_Character_Kit_v1.zip`.

SHA256: `476e5a53755bac952e0adfa9ecee038c013e911852ee9bcefc95f2822320cb23`.

The binary ZIP/workbook is deliberately not duplicated in this PR. To preserve every original file on the workstation, place that supplied ZIP outside the repository and run from the repository root:

```powershell
python tools/agentic/import_character_kit.py "C:\Downloads\Guildborne_Modular_Character_Kit_v1.zip"
```

The importer validates the pinned archive hash, expanded size, entry count, path traversal, symlinks, duplicate paths and expected manifest counts. It writes `original/Guildborne_Character_Pipeline_v1/` plus an intake receipt. It does **not** run bundled scripts, install anything, overwrite an existing intake, generate meshes, upload assets or modify player data. A different archive requires deliberate review, not bypassing the checksum.

The original kit's `manifest/...` references inside SHARED_CONTRACT.md refer to that original archive layout. For the normalized current copy, use catalog.json instead. Preserve the existing runtime ID naming during integration; map kit IDs explicitly rather than renaming working game data.

## Golden path and body fitting

Human Standard -> Human Heavy -> one removable shirt/trousers set -> actual R15 animation probes -> Studio import -> skin tint -> equipment -> UI -> save/rejoin. Only then expand all four races. Wizard uses a Human body plus appearance pieces.

Fifteen visible body parts remain separate; hair, beard, ears, tusks, clothing, armor and weapons are additional removable pieces. A common joint hierarchy does not imply identical bone positions, automatic body morph export, or universal outfit fit. Flexible garments need valid cages/rigging and per-preset review; rigid armor needs attachment offsets and collision checks. Always-on non-exposing coverage remains independent of removable garments.

New source candidates can be checked without editing the .blend with the project's audit script:

```powershell
blender --background --disable-autoexec "assets/characters/source/approved_candidate.blend" --python-exit-code 2 --python tools/agentic/blender_audit.py -- --collection "Body" --report "build/agentic/body-audit.json"
```

Verify these CLI flags against the installed Blender `--help`. A local geometry PASS is not a cage, deformation, clothing, Studio, physical-device or human-art approval. The script writes a report and does not export/publish or save over the source model.
