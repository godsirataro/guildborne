# Research and source provenance — Guildborne Living World (2026-10-17)

## Existing code / original owner decisions (do not treat as fresh completed acceptance)

- https://github.com/godsirataro/guildborne/blob/main/AGENTS.md — cooperative Forge/session and no-production mutation rules
- https://github.com/godsirataro/guildborne/blob/main/production/LATEST_GOALS.md — current first-public GL-2.0 goals, 10/35/70/100 progression, five heroes
- https://github.com/godsirataro/guildborne/blob/main/production/design/integration/FULL_GAME_GOLIVE_GL2_TH.md — full game before public, P0-P13, P8 final world/appearance gates
- https://github.com/godsirataro/guildborne/blob/main/src/shared/Config/FriendlyNpcs.luau — 16 named dialogue entries observed; not whole-world population
- https://github.com/godsirataro/guildborne/blob/main/src/server/Services/FriendlyCityNpcs.luau — current NPC prompts/tags, civic cast
- https://github.com/godsirataro/guildborne/blob/main/src/server/Services/CityCharacterKit.luau — existing specialized civic cast, not imported modular clones
- https://github.com/godsirataro/guildborne/blob/main/src/shared/Data/AppearanceCatalog.luau — 13 body preset IDs/20 palette design, planned assets
- https://github.com/godsirataro/guildborne/blob/main/src/shared/Presentation/ModularAppearance/Renderer.luau — placeholder rendering path, not complete multi-race import
- https://github.com/godsirataro/guildborne/blob/main/docs/CHARACTER_PIPELINE.md — skeleton/cages/real-game adapter and current gaps
- https://github.com/godsirataro/guildborne/blob/main/docs/CHARACTER_ASSET_STATUS.md — imported production IDs and full garment fit remain pending
- https://github.com/godsirataro/guildborne/blob/main/docs/uat01/CIVIC_ENVOYS.md — six civic representatives, optional tasks and historical limited Studio evidence
- https://github.com/godsirataro/guildborne/blob/main/docs/uat01/CITY_CAST.md — six profession rigs/animation studies, full-game integration remaining
- https://github.com/godsirataro/guildborne/blob/main/docs/uat01/intake/QUEST_CATALOG_DRAFT.json — 240 design-only quest cards, not 240 playable quests
- https://github.com/godsirataro/guildborne/blob/main/src/server/Config/ChapterFour.luau — canonical Tower main hidden passages, not separate optional shipped secrets
- https://github.com/godsirataro/guildborne/blob/main/src/server/Config/ChapterFive.luau — canonical Crosshaven Chapter05 main story, separate from civic-Crosshaven physical area
- https://github.com/godsirataro/guildborne/blob/main/production/design/HERO_BOND_DESIGN.md — hero stories and Bond planned, not complete runtime

## Official primary technical documentation — checked 2026-10-17

- **Roblox Improve Performance**, particularly humanoid state cost, animation-only controllers, pooling, distance-based activity, replication and microprofiler: https://create.roblox.com/docs/performance-optimization/improve
- **Roblox Character Body Specifications**, 15 core mesh parts, scale/caps, orientation, outer cages and attachments: https://create.roblox.com/docs/avatar/character-bodies/specifications
- **Roblox Layered Accessory Specifications**, genuine rigged mesh/inner+outer cages and garment fit: https://create.roblox.com/docs/avatar/layered-accessories/specifications
- **Roblox Character Bodies** architecture: https://create.roblox.com/docs/avatar/character-bodies
- **Roblox CollectionService**, managing shared behavior for tagged instances and replicated/streamed tag caveats: https://create.roblox.com/docs/reference/engine/classes/CollectionService
- **Roblox PathfindingService** and agent params: https://create.roblox.com/docs/reference/engine/classes/PathfindingService
- **Roblox Security at the Client-Server Boundary**, including malicious ProximityPrompt triggers and distance/role/rate validation: https://create.roblox.com/docs/scripting/security/client-server-boundary
- **Roblox DataStore Best Practices**, fixed stores/bounded keys, save in meaningful checkpoints and recovery rather than every NPC action: https://create.roblox.com/docs/cloud-services/data-stores/best-practices
- **Roblox Animator/AnimationController**, when NPCs only play cosmetic tracks (use `Animator:LoadAnimation`, not deprecated controller shortcut): https://create.roblox.com/docs/reference/engine/classes/AnimationController
- **Roblox MicroProfiler** for actual CPU/frame/animation costs: https://create.roblox.com/docs/performance-optimization/microprofiler/use-microprofiler
- **Rojo**, checked-in versions/build files are authoritative; no blind upgrade: https://github.com/rojo-rbx/rojo
- **Blender 3D**, use official docs for current authoring/export workflow (actual plugin/DCC version verified on host): https://docs.blender.org/manual/en/latest/

## Research-to-implementation decisions

- **Adopt:** relevance/LOD/pooling with measurement; shared NPC archetypes/tags; additive quest-ready metadata; real R15+garment cages; bounded persistent meaningful flags; backend-validated ProximityPrompt.
- **Evaluate separately:** instance streaming and provider-loaded modular assets, procedural NPC schedules across long sessions, new true body meshes, NPC ambient AI dialogue, paid/open-cloud content generation.
- **Reject as assumptions:** 410 simultaneous Humanoids, 410 fully persistent NPCs, 240 playable quests, 13 fully imported body rigs, all six towns being separate kingdoms, all quest hooks being live, demo screenshots or ZIP exports being real play acceptance.

**Provenance boundary:** These are design and implementation references, not model/image licensing grants. Audit each third-party tool, art library, imported sound, addon, network access, host permissions, commercial restrictions and attribution before adopting. Do not download/run external setup scripts without review.
