# Novice entrance and courier courtyard

Candidate based on `9ae9662`, branch `codex/novice-entry-art`. This is the bounded S13 novice-entry-art delivery, not completion of both world-building rounds. Controller owns Studio and combined game regression.

## Changed behavior

The existing Crown Road factory now builds a stone-and-timber entrance with layered pitched roofs, closed stone gables and timber trusses and original navy/gold heraldry. The courier shelter has a pitched roof, upper braces, cloth hems, mail on its counter, an elliptical courtyard and low paving. Eight original tree anchors now have clustered crowns and branches; four restrained rock/plant groups frame the entrance. All art is native geometry. No external assets, generated asset IDs, mesh uploads or purchases were used.

The factory remains `review/NoviceRoadKit.luau`; `tools/sync_novice_road_art.py` generates `src/server/Services/NoviceRoadArt.luau` with Atomic streaming mode. The sync command now rejects missing/duplicate integration anchors and supports nonmutating `--check`. Source geometry is unchanged by the review/runtime substitutions.

## Measured source budget

| Measure | Before | Candidate |
| --- | ---: | ---: |
| Static authored BaseParts, including markers/proxies | 119 | 408 |
| Colliders | 61 | 61 |
| Direct route markers | 15 | 15 |
| Added noncolliding, nonqueryable parts | — | 289 |
| Maximum static art parts across 8 course owners | 952 | 3,264 |

Every original collision transform, size, material and physics flag matches the baseline. Selected original blocks become invisible collision proxies; decorative geometry covers them. Their original box collisions remain intentional, including the overhead shelter slab. No original marker moves. Other chapter-stage geometry is unchanged. All rotated bounding corners remain within local X±150 / Z±225; existing 400-stud owner spacing is unchanged. This is an art-only count: do not compare it directly with the controller's earlier 321-part runtime model, which also included NPCs and other runtime instances.

## Evidence and reproduction

- `before.json`, `after.json`, `runtime.json`: actual Luau factories evaluated with the limited offline geometry adapter, not a hand-maintained parallel geometry model.
- `geometry-check.json`: exact baseline collider/marker checks, other-stage equality, review/runtime parity, plot bounds, new-part flags and conservative travel-volume exclusions.
- `check-receipts.json` and matching raw stdout/stderr: sync, geometry invariants, compiler, Roblox-aware Luau type analysis and whitespace checks, all exited 0. Type analysis has no sourcemap because these factories/probe have no imports.
- `before-render` / `after-render`: matched entry, courier and overview PNGs plus editable Blender scenes. They are Blender source previews, **not Studio screenshots**. They omit runtime NPCs, BillboardGui labels and runtime-only objects; materials use approximate uniform roughness and primitive tessellation.
- `manifest.json`: source/evidence SHA-256 identities. Raw empty streams are retained.

Run from this worktree:

```powershell
python tools/sync_novice_road_art.py --check
python production/world/novice-entry/capture_geometry.py --git-ref 9ae9662 --output production/world/novice-entry/before.json
python production/world/novice-entry/capture_geometry.py --source review/NoviceRoadKit.luau --output production/world/novice-entry/after.json
python production/world/novice-entry/capture_geometry.py --source src/server/Services/NoviceRoadArt.luau --output production/world/novice-entry/runtime.json
python production/world/novice-entry/run_checks.py
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --disable-autoexec --python-exit-code 2 --python tools/blender_crown_road.py -- --geometry production/world/novice-entry/after.json --output production/world/novice-entry/after-render
```

Replace `after` with `before` for the matched baseline render. Cameras derive from controller runtime positions minus origin (-4500,0,0): entry local eye (30,22,244), target (-15,10,165); courier eye (-34,18,182), target (-65,6,149). Lens is 32 mm for both source previews; this does not assert parity with Studio FOV. Initial baseline render used a relative Blender output path and wrote three PNGs under C:/production; those exact generated files were moved into this packet, then the fixed absolute-path renderer regenerated the baseline. Initial raw logs remain in `before-render-attempt1.*`.

The adapter supports only the inspected factory's geometry operations. It does not emulate Roblox enum/property validation, physics, navigation or replication. Compiler/type analysis adds source validation; only Studio can establish runtime acceptance.

## Controller integration and remaining gates

1. Integrate this local commit into the combined candidate and run the controller's combined baseline. No push/PR/merge was performed by S13.
2. Preserve the earned Chapter 3 session. The user approved the older Memory file `build/Guildborne_WorldConnectivity.rbxlx`, but that late answer does not require replacing the currently owned Studio session. S13 performed no Studio mutation/playtest in this wave.
3. Sync the generated module using the controller's established isolated Memory review workflow; capture before/after with matching runtime cameras when safe. Existing course instances are factory snapshots: changing the ModuleScript alone does not rebuild an already-created course. Use the established controller course creation/review flow without resetting earned progress.
4. Execute `tests/studio_novice_road_probe.luau` with an explicit runtime Model (preferred, including local Studio test owners) or a positive owner UserId. It checks 15 exact art markers, invisible collider inventory, rotated bounds, Atomic mode, 14 arrival-to-marker paths, actual courier approach and the runtime courier walk marker. Agent radius2/height5/no jump; each path must be <700 studs. It validates the courier host at local (-65,3,149), prompt radius12 and no LOS requirement. It does **not** activate the prompt or claim quest completion.
5. Verify actual courier interaction/readability, player plus five companions, collision feel, all route paths, owner isolation, rendering/material quality and device performance. These are **NOT_RUN** by this delivery. The additional 289 parts per owner require measured acceptance; no performance improvement is claimed.

Independent source and visual review is recorded separately in `REVIEW.md`. Human art/UAT signoff, real Studio pathfinding, device acceptance and release remain pending.
