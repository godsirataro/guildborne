# Central City

Phase 3 adds one shared, runtime-built city north of the personal guild promenade. It uses a radial crossroads plan in a 920 × 1020 stud walled site. Arrival is on the southern grand avenue; the gold guild sword monument marks the open central plaza and the twin towers close the northern vista.

| District | Centre X/Z | Purpose and landmark |
| --- | --- | --- |
| Guild Zone Warp | 0 / -680 | Gold and blue portal; return to the requesting player's own guild |
| Tavern | -140 / -820 | Hearth and Banner, tables, notice board and adventurers |
| Central Plaza | 0 / -1100 | Guild sword monument, gathering/event space and directional signs |
| Guild | -300 / -1100 | Blue/gold administration, courtyard, registry and ranking placeholders |
| Market/Craft | 300 / -1100 | Brass exchange, blacksmith, alchemist and merchant stalls |
| Tower Gate | 0 / -1510 | Cool stone twin towers, guards and sealed adventure gate |

Primary roads are 32 studs wide, secondary lanes 18, service paths 10. Required destinations never depend on alleys. At 16 studs/second, arrival to plaza is about 24 seconds, plaza to either east/west district 19 seconds and arrival to the tower about 50 seconds. Tables, signs and the monument are offset from through routes. Building doors are 16 studs wide. Height comes from roofs, the monument and tower silhouette rather than complicated stacked navigation.

The tavern is a social expansion. Authoritative recruitment stays in the Personal Guild. Existing journal and dispatch NPC entry points remain available; no second recruitment backend is created. Registry, rankings, exchange, crafting and gate prompts display localized future-phase messaging. Buildings do not enable trading or new economy commands.

The entire configured city rectangle is a safe zone. Combat additionally requires the owner's bounded personal camp. Decorative NPCs have no combat actor registration, collision or pathfinding loops. Player/player and hero/player collisions are disabled to prevent doorway blocking.

## Kit and performance

`CityKit` provides reusable house, arch, stall, wall, planter, gate tower and banner models, alongside the existing ArtKit trees, benches, lamps and notice board. Runtime hierarchy is under `Workspace.GuildborneWorld`; city district folders carry stable IDs. Eight lightweight ambience NPCs share existing hero rigs. New props have no individual scripts. Materials, timber, burgundy roofs, gold blade/diamond crests and restrained portal/gate neon continue Guildborne's art direction.

Streaming remains disabled. The existing follower ground queries assume available shared geometry; turning streaming on requires separate client arrival and follower validation. Two-player Studio testing is a functional check, not a mobile hardware or large-server performance certification. Future expansion should reuse district IDs and kit modules while keeping destinations server-owned. The sealed tower and market/guild interaction anchors reserve future space without implementing those systems.
