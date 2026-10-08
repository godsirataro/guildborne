# Guildborne art direction

> Phase 3 city extends this kit with timber street frontages, district banners, a gold guild-sword monument, a blue/gold council spire and cool stone twin gate towers. Burgundy tavern roofs/chimney and orange exchange awnings distinguish districts. The walled crossroads retains wide routes for five companions, restrained portal neon, and eight lightweight ambience rigs. See [city design](CENTRAL_CITY.md) and [screenshots](PHASE3_STUDIO_TEST.md).

Art Phase 1.5, 2026-09-28. A replaceable visual prototype for the accepted Phase 1 solo slice; no new gameplay systems.

## Identity and composition

A small medieval adventurer guild in warm daylight. Chunky timber construction, burgundy pitched roofs, brass guild crests and muted green foliage establish a welcoming low-poly fantasy vocabulary. The Hall is the tallest built landmark; the roof and sword-in-diamond banner identify the guild. The notice board has three parchment notices and a burgundy cap. Decoration frames routes rather than occupying them.

The 80 × 88 stud personal plot has a north Hall, west adventurer table, east quest board, central paved plaza, southwest training display and southeast inventory/supplies. An exit sign directs players to the existing expedition menu; it is not a new travel system. Spawn faces the Hall. Routes are 6–9 studs wide; essential stations are within approximately 41 walking studs of spawn. The 104-stud plot grid preserves separate personal plots.

## Shapes and scale

Use block, wedge and cylinder silhouettes, broad roof planes, thick posts, large window recesses and simple readable props. One Roblox character is the scale reference, approximately 5–6 studs tall. Hall 1 has a 21-stud wall width, 17-stud foundation depth and approximately 15-stud roof crest. Hall 2 retains the roof language and entry, widening the facade to 25 studs and adding stone buttresses, a porch, chimney, banners and gold ridge. Doors have a roughly 5.5-stud clear width. Tables are 2.6 studs high, benches 1.3, weapons 4–5, goblin 4.3 and trees 10–16.

Avoid tiny scattered details, high-frequency grunge, realistic PBR, neon edging, modern simulator pads, oversized magical weapons and toy-like architecture. A broad cloth banner fits; dozens of glowing particles do not. A simple brass collar fits; a highly engraved 50,000-triangle sword does not.

## Palette and materials

The authoritative presentation constants are [Art.luau](../src/shared/Config/Art.luau). Do not duplicate progression values in this configuration.

| Role | RGB | Application |
| --- | --- | --- |
| Dark wood | 101, 67, 46 | Frames, posts, bindings |
| Timber | 151, 108, 67 | Wall infill, furniture |
| Stone | 132, 131, 117 | Foundations, buttresses, rocks |
| Light stone | 169, 162, 141 | Plaza, thresholds |
| Burgundy | 112, 46, 51 | Roofs, guild cloth |
| Brass | 202, 161, 77 | Crests, ridge, modest equipment trim |
| Nature | 62, 102, 66 / 99, 131, 70 | Foliage variants |
| Parchment | 233, 217, 177 | Notices and banner symbol |
| Quest amber | 235, 185, 76 | Board seals and lantern glass |
| Muted cyan | 109, 190, 195 | Small staff focus only |

Use built-in Wood, Slate, Grass, Fabric and Metal sparingly, with SmoothPlastic for clean staging surfaces. No downloaded textures, unions, external mesh dependencies or per-prop scripts. Lanterns use warm colored geometry without dynamic lights. Material variation supports silhouette, rather than simulating every physical surface.

## Lighting

10:30 warm daylight, brightness 2, balanced ambient fill, visible shadows and mild warm color grading. No bloom, depth of field, particles or visibility-reducing fog. Lighting is initialized once by WorldService, not once per plot. All gameplay positions must remain readable on low graphics settings. Desktop Studio measurements are not certification of low-end mobile FPS.

## UI and language

Retain the existing four-tab architecture and navigation. Charcoal/olive panels, parchment text, brass borders and a high-contrast gold selected tab carry the world palette into UI. Buttons remain 48–52 logical pixels high. Wrapped Thai/English copy, automatic card heights, vertical scrolling, compact landscape guidance and existing safe-area handling remain in place.

All new UI copy belongs in Localization with a Thai entry. World labels and prompts show both languages simultaneously so players can navigate regardless of preference. Do not bake language into meshes or images. Keep the persisted language command and profile schema unchanged. Signs should supplement physical silhouettes and stay away from the face of important assets.

## Mobile and production constraints

Budget: at most 650 BaseParts per personal plot, including Hall 2. Current evidence and actual counts are recorded in [implementation](PHASE1_5_IMPLEMENTATION.md). Reuse the 25 templates held once in ServerStorage; only placed clones replicate. Decorations are anchored with collision, touch and query disabled. Ground, Hall structural walls and foundations use simple box collision. No scripts inside any art template. Rebuild a Hall only when its level changes, not at each network poll.

More players multiply scene instances: the solo prototype does not certify multiplayer scale. Profile visible plots on representative phones before increasing server capacity. Future mesh replacement should preserve template names, floor pivots, extents, door clearance and station positions.
