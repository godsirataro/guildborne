# Blender asset backlog

Phase 1.5 establishes scale and silhouettes; none of these procedural models are final production art. Coordinates use studs and a ground-level origin. Export axes/units must be verified with a 5–6 stud Roblox avatar and one test import. Triangle targets below are proposed authoring budgets, not measured renderer totals. Use few material slots, simple collision hulls and shared palette atlases only when they improve the result.

| Asset | Category | Priority | Approximate scale (studs) | Purpose | Target triangles | Materials | Rig / animation | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guild Hall Lv1 | HERO ASSET / REPLACE WITH BLENDER | P0 | 23 × 15 × 20 | Primary landmark | 3,000–5,000 | Wood, burgundy roof, stone, brass | None | Ground pivot; preserve entry and footprint |
| Guild Hall Lv2 | HERO ASSET / REPLACE WITH BLENDER | P0 | 29 × 18 × 21 | Visible earned progression | 4,000–7,000 | Same as Lv1 | None | Evolve the same building; porch, reinforced stone, banners |
| Guild Banner | HERO ASSET / REPLACE WITH BLENDER | P0 | 3 × 7 × 0.3 | Guild identity | 150–400 | Burgundy cloth, brass, wood | Optional later cloth bones | Sword/diamond crest; no baked text |
| Iron Sword | REPLACE WITH BLENDER | P0 | 1.5 × 4.7 × 0.4 | Starter equipment silhouette | 250–500 | Iron, brass, leather/wood | None; future attachment pivot | Keep catalog iron_sword ID |
| Training Bow | REPLACE WITH BLENDER | P0 | 1.4 × 4.2 × 0.3 | Archer starter equipment | 250–500 | Wood, string | None in Phase 1.5 | Visual name; catalog remains short_bow |
| Priest Staff | REPLACE WITH BLENDER | P0 | 1.2 × 5.2 × 0.7 | Priest starter equipment | 250–600 | Wood, brass, muted cyan | None in Phase 1.5 | Catalog remains apprentice_staff; no new item |
| Goblin Scout | HERO ASSET / REPLACE WITH BLENDER | P0 | 3 × 4.3 × 1.4 | Single enemy reference | 1,000–2,000 | Green skin, brown tunic, brass | Future simple humanoid rig | Static study display now; no combat or AI |
| Quest Board | TEMPORARY / REPLACE WITH BLENDER | P1 | 8 × 7.3 × 1.6 | Primary quest affordance | 500–900 | Wood, burgundy, parchment | None | Keep three notices readable; text stays in UI |
| Training Dummy | KEEP AS ROBLOX / PROCEDURAL | P1 | 4 × 5.3 × 2 | Training area identity | 150–300 if replaced | Wood, straw | None | Display only; no damage/training mechanic |
| Iron Ore Node | TEMPORARY / REPLACE WITH BLENDER | P1 | 4 × 3.2 × 3.5 | Quarry resource reference | 150–350 | Warm stone, iron | None | No harvest script |
| Timber Logs | KEEP AS ROBLOX / PROCEDURAL | P1 | 3 × 2.3 × 4 | Timber delivery reference | 150–300 if replaced | Wood end grain, bark | None | No harvest script |
| Supply Crate | KEEP AS ROBLOX / PROCEDURAL | P1 | 3.2 × 2.9 × 3.3 | Quest supply / inventory | 100–200 if replaced | Wood, brass, parchment | None | Reuse wooden crate construction |
| Tree A / B / C | TEMPORARY / REPLACE WITH BLENDER | P2 | 8–10 × 10–16 × 8 | Perimeter framing | 200–500 each | Wood, two greens | None initially | Broadleaf, tiered evergreen, light broadleaf |
| Rock A / B / C | KEEP AS ROBLOX / PROCEDURAL | P2 | 3–5 × 2–3 × 3–4 | Perimeter rhythm | 24–80 each if replaced | Warm stone | None | Replace only if silhouette improves |
| Fence segment | KEEP AS ROBLOX / PROCEDURAL | P2 | 6.5 × 3 × 0.5 | Route framing | 48–100 if replaced | Dark/light wood | None | 6-stud modular span |
| Barrel | TEMPORARY / REPLACE WITH BLENDER | P2 | 2.3 × 3 × 2.3 | Supply corner silhouette | 120–240 | Wood, iron | None | Faceted staves preferred eventually |
| Wooden Crate | KEEP AS ROBLOX / PROCEDURAL | P2 | 3.2 × 2.9 × 3.3 | Reusable storage prop | 80–150 if replaced | Wood | None | Broad brace, no tiny nails |
| Table / Bench | KEEP AS ROBLOX / PROCEDURAL | P2 | 5 × 2.8 × 3 / 5 × 1.5 × 1.2 | Adventurer gathering area | 80–200 each if replaced | Wood | None | Not Seat instances; avoid unintended sitting |
| Lantern | KEEP AS ROBLOX / PROCEDURAL | P2 | 1.5 × 5.2 × 0.9 | Warm route accent | 100–200 if replaced | Wood, brass, warm glass | None | No real lights or particles |
| Signpost | KEEP AS ROBLOX / PROCEDURAL | P2 | 3.5 × 4 × 0.4 | Bilingual local directions | 24–80 if replaced | Wood | None | Text rendered by Roblox, never baked |

Exactly 25 templates including tree/rock variants and both Hall levels. Paths, foundations, edging, rack and plinth are scene construction primitives, not additional unique asset families. Three weapon visuals are display references: equipping remains the accepted management/stat system. The existing Training Sword item is not removed or renamed.

Before replacing a model, compare both languages, walk every station route, measure part/triangle/draw counts, verify Hall swaps do not move interaction anchors, and run the accepted Phase 1 route. Do not bundle gameplay, crafting, enemy combat or animation systems with art replacement.
