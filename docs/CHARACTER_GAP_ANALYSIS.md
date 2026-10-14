# Character source audit — 2026-10-11

The full original master prompt, shared contract and manifests were read from the
user's archive. The checksum-pinned importer retained all 17 original files without
executing bundled scripts. The archive is a specification: 89 planned assets,
13 body presets and 20 palettes. The six supplied character sheets are visual
references, not generated meshes or import evidence.

`HeroRig` creates existing six-joint R6 companions. `HeroAppearance` fits original
visual pieces to these proxies. Player combat uses the existing Roblox character,
`HeroRig.Equip`, `WardrobeVisuals` and server stats. The Sentinel Blender kit is a
custom NPC candidate with no clothing cages; it is not an accepted modular avatar.
These working systems are retained rather than replaced.

`ProfileSchema`, `Commands`, `PlayerDataService`, `Protocol`, `ViewProjection` and
`SliceUI` already own persistence, transactions, bounded networking and native UI.
The new appearance extension integrates at these boundaries. Uppercase cosmetic
race IDs are distinct from legacy `character.raceId` ancestry and its combat math.

The production plan's suggested `CharacterAppearance` scope did not cover these
actual callers. The coordinator reconciled explicit source/test/document scopes
and changed `character-import` into a local source-integration task. This does
not accept the separate Human geometry or clothing-fit tasks. The previous ledger
had no running workers; after scope extension the coordinator released its own
lease and moved all workers to one shared ledger in `build/agentic/`.

Baseline: 672 domain tests passed before integration. The sandbox initially denied
Rojo canonicalization; the same local build succeeded with approved execution.
Historical UAT reports are reference evidence only. Current integration checks are
recorded separately in CHARACTER_STUDIO_TEST.md.

Initial Studio MCP discovery returned no studios, then a connected home session
with no place open. Blender 5.2.1 was found at its installed workstation path even
though Forge doctor only searched PATH. Mesh import, cages, deformation, live
multiplayer, physical touch and human art approval require separate evidence.
