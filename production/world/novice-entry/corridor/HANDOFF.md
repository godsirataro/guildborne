# Novice arrival–training–caravan corridor

Bounded S13 delivery on `codex/regional-arrival-art`, base `ef4868b`. Despite the worktree/branch name, this changes only the existing **Novice course**. It does not claim the dependency-blocked city-zones task, modify Greenwood's 116-placement pipeline or add Ironveil/Ashen content.

## Source changes

The canonical `review/NoviceRoadKit.luau` factory now frames the route with six staggered woodland groups, varied tree heights/crowns, layered outer banks and six background saplings. Shallow road shoulders touch the visual road edges while leaving crossings clear. The training yard gains a rear apron, original navy/gold standards, practice shields and a spear rack. The existing caravan cart gains wooden cargo slats, circular wheels and hubs within its original collision boxes; dropped bound supplies on the west verge provide a restrained rescue-story cue.

All additions are original native Roblox geometry authored in this worktree. No imported asset, texture, generator, font, mesh ID, paid service or upload was used. Materials are native engine materials. Blender is a review/export-of-source tool here; no Blender export is required by runtime.

The pipeline remains review factory → `tools/sync_novice_road_art.py` → `src/server/Services/NoviceRoadArt.luau`. Runtime remains Atomic. No gameplay service, progression, actor placement, warning or reward logic changed.

## Measured budgets and invariants

| Measure | Base | Candidate |
| --- | ---: | ---: |
| Authored BaseParts, including markers/proxies | 408 | 564 |
| Colliders | 61 | 61 |
| Direct route markers | 15 | 15 |
| Added presentation parts | — | 156 |
| Static art parts across all 8 owner slots | 3,264 | 4,512 |

Every collider transform, size, material, color and physics flag is unchanged. The six original cart parts become invisible proxies covered by 18 decorative parts entirely inside their existing bounds. Other original geometry and appearance remain unchanged. Added parts are anchored, noncolliding, nonqueryable and non-touchable. All rotated corners remain within local X±150 / Z±225; the 400-stud owner spacing is unchanged. Counts exclude runtime NPCs and service-created parts. The extra 1,248 parts for eight owners require measurement; no performance improvement is claimed.

`check_geometry.py` checks exact collider/marker equality and review/runtime parity, allowed visibility-only changes, owner bounds, road/crosspath volumes, six-stud margins around static warning rectangles, courier dodge radius34, actor/marker approaches and a radius24 exclusion around the controller-observed training warning center (62.6,94.5). Low ground decals and high overhead geometry are handled separately. Cart-contained visual replacements are an explicit geometric exception, not a blanket exemption for caravan props.

## Evidence

- `before.json`: baseline factory at `ef4868b`, 408 parts.
- `after.json` / `runtime.json`: current source factories evaluated with the existing limited standalone Luau geometry adapter, 564 parts each.
- `geometry-check.json` / `check-receipts.json`: scoped source invariants, exact sync, Luau compilation, Roblox-aware type analysis and diff checks. Raw stdout/stderr retained, including empty streams.
- `before-render` and `after-render`: four matched Blender views each: arrival player-eye, training player-eye, caravan player-eye and corridor overview. The `render-receipt.json` files record local cameras, 32 mm lens and resolution. They are **source previews, not Studio screenshots**; runtime NPCs, prompt labels and dynamic warnings are omitted. Material shading and primitive tessellation are approximate.
- `REVIEW.md`: independent review of this bounded candidate. `manifest.json`: source and evidence SHA-256 identities, validated against staged Git bytes.

Previous-wave evidence under the parent `novice-entry` folder is historical and remains untouched except the shared renderer, which gained optional `--view-set corridor`. This subfolder is the current wave's evidence packet.

## Reproduction

From this worktree:

```powershell
python tools/sync_novice_road_art.py --check
python production/world/novice-entry/capture_geometry.py --git-ref ef4868b --output production/world/novice-entry/corridor/before.json
python production/world/novice-entry/capture_geometry.py --source review/NoviceRoadKit.luau --output production/world/novice-entry/corridor/after.json
python production/world/novice-entry/capture_geometry.py --source src/server/Services/NoviceRoadArt.luau --output production/world/novice-entry/corridor/runtime.json
python production/world/novice-entry/corridor/run_checks.py
& 'C:/Program Files/Blender Foundation/Blender 5.2/blender.exe' --background --disable-autoexec --python-exit-code 2 --python tools/blender_crown_road.py -- --geometry production/world/novice-entry/corridor/after.json --output production/world/novice-entry/corridor/after-render --view-set corridor
```

Use `before` instead of `after` for baseline renders. First candidate render logs are retained as `after-render-attempt1.*`; final images reflect the 564-part version. The offline adapter only supports operations used by the inspected factory. It does not emulate physics, navigation, replication or all Roblox property validation.

## Controller handoff and pending gates

The controller reported Chapter 1/2 interactions and 16 engine paths passing on the **previous integrated 408-part course**. That is regression context, not evidence for this new candidate. S13 made no Studio calls or mutations in this wave.

The updated read-only probe requires an explicit runtime model or positive owner UserId. It retains all original checks and adds connected Courier→Training→PracticeCaptive, Training→CaravanTracks→Rescue/Supplies→Rejoin routes, plus adjacent approaches to CaravanHelper and dwarf_traveler. Expected runtime total is **25 path queries** (22 for a review model), not 25 executed passes. It checks exact actor/marker pivots, warning footprints/colors, 61 colliders and a 650-part art cap. It does not activate E or grant/claim objectives.

Controller owns integration, combined baseline and Studio: preserve earned progress, create/review the new factory snapshot through the established Memory workflow, run the probe, play both caravan branches, inspect the dynamic training dodge and captive prompt from player camera, then test player plus five companions and owner isolation. Existing course instances do not rebuild merely because the module source changes.

Studio navigation, ordinary interactions on this candidate, companion movement, eight-owner/device performance and human art acceptance remain **NOT_RUN/PENDING**. Large parts of the course still use flat rectangular courts/roads; keeper, disciplines and hall remain earlier blockouts. Edge banks are decorative silhouettes, not walkable terrain. This wave improves the corridor's composition and destination readability but does not finish the full island or either world-building round. No push, PR, merge, publish or spending is part of this delivery.
