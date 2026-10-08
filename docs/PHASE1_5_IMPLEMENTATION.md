# Art Phase 1.5 implementation

2026-09-28. **Art Phase 1.5 closed by the user: “งั้นจบ 1.5 เลย แล้วทำ 1.6 ได้เลย”.** Definition of Done met for the solo Studio visual prototype. Actual Play tests, TH/EN mobile views, geometry checks, Output inspection and real DataStore rejoin passed. Not published. This report preserves Phase 1.5 evidence; subsequent work is recorded in [Phase 1.6](PHASE1_6_IMPLEMENTATION.md). Phase 2 has not started.

## Delivered changes

- Central [Art configuration](../src/shared/Config/Art.luau) supplies world/UI palette, plot spacing and a 650-part per-plot budget.
- [ArtKit](../src/server/Services/ArtKit.luau) creates 25 reusable templates once in ServerStorage. Models have ground pivots and no executable scripts. All geometry is procedural Roblox parts, constructed from versioned source and instantiated/verified through Studio MCP. No generative mesh/material service, Creator Store asset, external texture or uploaded asset ID is required.
- [WorldService](../src/server/Services/WorldService.luau) composes a compact hub, keeps the existing four owner/distance-checked prompts, spawns facing the Hall and swaps Hall models only on level change. Paths, plaza, gathering table, training display, inventory rack and supplies reinforce existing navigation.
- Hall 1 has a wood facade, pitched burgundy roof, open entry and guild crest. Hall 2 widens the same facade and adds stone reinforcement, porch, chimney, banners and gold ridge. Existing level data drives the change; no upgrade cost/reward changes.
- UI retains four tabs, responsive scrolling, tutorial and save states. A shared charcoal/olive/parchment/brass palette, borders and gold selected tab establish hierarchy. Claim buttons visually distinguish waiting from ready.
- New Hall-success text is translated into Thai; world signs/prompts show TH/EN together. Persisted language selection and all content IDs are unchanged.
- Warm 10:30 daylight with restrained color correction; no bloom, particles, fog or local lights.

## Assets and hierarchy

Exactly 25 templates: Guild Hall Lv1/Lv2, Quest Board, Training Dummy, Guild Banner, Iron Sword, Training Bow, Priest Staff, Goblin Scout, Trees A/B/C, Rocks A/B/C, Fence, Barrel, Wooden Crate, Table, Bench, Iron Ore Node, Timber Logs, Supply Crate, Lantern and Signpost. Paths/edging/plinth/rack are composition primitives, not extra unique asset families.

```text
ServerStorage/GuildborneArtKit/<25 templates>
Workspace/GuildborneWorld/PersonalGuild [OwnerUserId, ArtPartCount]
  GuildSpawn
  Environment
    Buildings
    Props
    Nature
    Resources
    Gameplay
```

Goblin Scout is a static study display matching the sole existing encounter archetype. Weapons are display references beside inventory. They do not add avatar combat, new catalog items or an NPC equipment/animation system. Training and resource props do not grant rewards or harvesting actions. The southern expedition sign points to the existing board; it does not open an additional world.

## Verification and evidence

Roblox Studio MCP connected to Guildborne - Staging, place 86788611613035. Existing source/hierarchy, Output and pre-art screenshots were inspected. The existing persistent profile initially returned ProfileInUse; it was not reset or force-unlocked. Fresh-loop tests used a temporary Studio-only Memory edit; repository Runtime remains DataStore. No publication was performed.

- Baseline: complete native RemoteEvent onboarding loop plus invalid inputs, early/duplicate claims, replay/conflict, equipment and Hall checks passed. [Baseline log](evidence/art15-baseline.txt). Pre-art screenshots were captured inline in the chat as Art15_Baseline and Art15_Baseline_World.
- Post-art: the same loop passed with Hall 2, 10 Gold, Warrior XP 90, all three first-clears/recruits and Thai selected. [Gameplay log](evidence/art15-gameplay.txt). These are actual running client/server tests with real timers, not standalone mocks or direct reward edits.
- After the final sign/gable refinement, a fresh full native loop passed again: [final gameplay](evidence/art15-final-gameplay.txt). Both Hall levels passed the [geometry probe](evidence/art15-geometry.txt): 272/288 parts, 10/12 colliding parts, four prompts, nine clear route sweeps and zero lights/particles. A later color-only claim-button state adjustment was checked in a fresh persistent session.
- DataStore: loaded the user's existing revision 39 without resetting it, checkpointed the same Thai preference at revision 40, stopped and restarted Play, then asserted exact equality of every projected data field and revision. [Persistent rejoin](evidence/art15-persistent-rejoin.txt) records `GBPERSIST EXACT REJOIN MATCH 40 th`: Hall 2, 65 Gold, equipped weapons, roster, tutorial, materials and the existing q:9 Quarry Patrol run were retained. The pending quest was not claimed by the art test.
- Real movement and E prompts: walked between all four stations through MCP character navigation; Quests, Guild, Party and Inventory each returned the correct navigate field and opened management. The root reached each target within approximately one stud.
- [Native art probe](../tests/studio_art_probe.luau) verifies 25 templates, no embedded scripts, anchored/non-touching art, exactly four bilingual prompts, no lights/particles, budget accounting and nine avatar-width route sweeps through the main path, cross-path, training path and Hall entrance.
- Mobile: Studio Sensor orientation / CoreUISafeInsets; custom 640×360 device rotated to portrait. Actual camera viewports were 359×619 portrait and 639×339 landscape (Studio simulator chrome/scaling). Native mouse click switched EN to TH; screenshots show wrapped text, retained four tabs and vertical scrolling. Active quest countdown was observed after rotation. Galaxy A06 preset was also inspected in portrait/landscape. No physical-device FPS claim is made.
- Native scroll input on the final persistent mobile session moved Content.CanvasPosition from 0 to 183 (canvas height 283, visible height 100), reaching the lower Guild actions. The simulator was stopped and Studio returned to Edit/default viewport after verification.
- Final automated gate: 37 domain/localization tests, compilation, Roblox-aware strict analysis, Rojo build/source map, 16 required documents and local-link/boundary/whitespace validation passed. The LSP watcher warning is informational; there were no source diagnostics or new game runtime errors. Game Output was inspected through MCP. Source remained authoritative; changed modules were mirrored through MCP into their existing Rojo paths because no live Rojo server was running.

### Captured final-source views

| View | Evidence |
| --- | --- |
| Spawn-facing Hall / route | [Spawn](evidence/art15-spawn.png) |
| Guild Hall Lv1 | [Hall 1](evidence/art15-hall1.png) |
| Guild Hall Lv2 after real upgrade | [Hall 2](evidence/art15-hall2.png) |
| Quest Board | [Board](evidence/art15-quest-board.png) |
| Training area / Goblin | [Training](evidence/art15-training.png) |
| Overall starter hub | [Hub](evidence/art15-hub.png) |
| Three weapons / supplies | [Weapons](evidence/art15-weapons.png) |
| Mobile English | [EN portrait](evidence/art15-mobile-en.png) |
| Mobile Thai | [TH portrait](evidence/art15-mobile-th.png) |
| Active quest landscape | [TH landscape](evidence/art15-mobile-landscape.png) |
| Persistent Thai rejoin / lower actions | [Rejoin and scroll](evidence/art15-rejoin.png) |

## Performance and limitations

Final counts are 272 parts at Hall 1 and 288 at Hall 2, below the 650-part budget. Templates are stored once on the server. Only ground/skirt/foundation/structural Hall geometry collides; props are decorative and can be walked through. This favors mobile movement and avoids detailed collision hulls. One low-cost color grade is the only added post effect.

A sampled Hall-1 spawn view in desktop Studio reported 8,386 opaque triangles / 9 opaque draws; total excluding shadows was 8,580 triangles / 17 draws (including UI, sky and post processing). This is one view, not a phone benchmark. Per-player plots multiply draw/instance load; multiplayer load remains unverified and the prior two-player deferral remains in force.

The overall Hall-2 hub sample reported 9,296 opaque triangles / 13 opaque draws, or 9,664 triangles / 24 draws excluding shadows across all reported passes. These SceneAnalysisService readings include the avatar and visible Roblox/UI rendering; they are not Blender mesh triangle counts.

The world remains a bounded personal plot with visible sky beyond its edges. Perimeter fencing is decorative; walking off the plot uses normal Roblox respawn. Hall interior is intentionally unfurnished. Static weapon/goblin models and simple foliage are scale/silhouette prototypes, not production rigs. Small landscape screens require scrolling to reach lower actions. Published-client and physical phone regression checks are separate from Studio simulation.

## Regressions and production handoff

No gameplay or persistence logic was changed. The old Hall-success copy described a gold roof; it now describes stonework, banners and porch in both languages. Visual review reduced world sign size and filled front gables. Failed loading with ProfileInUse existed before the art change and preserved data as designed.

[Art direction](ART_DIRECTION.md) defines the visual language. [Blender backlog](BLENDER_ASSET_BACKLOG.md) identifies P0 Hall/banner/weapons/goblin, P1 resource/board improvements and P2 foliage/background work, with dimensions, material and triangle targets. No Phase 2 work is authorized by this handoff.

## Exact remaining items

- User closure approval is now recorded above. Publication remains pending; the staged published experience was not updated by this phase.
- Art-specific physical-phone FPS/touch and published-client checks have not been rerun. Studio simulation and real staging DataStore are verified separately.
- Multi-player plot isolation/load remains deferred from Phase 1; this task does not mark it passed.
- Production replacements, rigging, cloth motion, finished interiors and hiding the bounded plot horizon are future art work, not implemented systems.

All requested Phase 1.5 prototype assets, bilingual presentation, handoff documents, Studio screenshots and regression gates are delivered. Stop here for review; do not begin Phase 2 without explicit approval.
