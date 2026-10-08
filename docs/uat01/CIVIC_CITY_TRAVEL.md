# Civic city exploration — 2026-10-06

Six 200×250stud district blockouts now connect to the game through earned envoy charters. Complete and claim the corresponding Central City community task to travel: Elian→Crownford, Vaela→Sylvaris, Borin→Deepforge, Nyra→Astralis, Sela→Crosshaven and Roka→Ironroot. The server checks the claimed task; clients cannot submit a coordinate or bypass the condition through a travel request.

Each district has a Central City exit and a guild-island portal, including the existing island visitor directory. Fixed primary/fallback landings, respawn assignment, travel cooldown and boundary recovery use the existing travel service. Six departure gates line the north arrival edge of Central City. Safe-zone labels and local music routes are configured; music asset IDs remain blank.

The district geometry is copied from the separately reviewed city blockouts. Runtime copies are CivicDistrictKit/CivicLandmarkKit; the review originals remain unchanged. These districts provide exploration and landmarks. Their service buildings still direct players to Central City; local shops, workers, city-specific stories, terrain and final architecture remain unfinished.

671 domain tests pass, including six prerequisite/reward-state gates and separated finite bounds. Native geometry verified 42 no-jump routes, 12 clear landings and 18 prompts. Actual fresh ordinary-input play rejected a locked Crownford gate, completed city_gate and elian_charter, entered Crownford at revision10/25Gold, visited four service interiors and the landmark, then returned to the guild island. No profile grants or injected gameplay requests were used.

The tool host disconnected during the later return/reentry/exit sequence; its outcome is unknown. After reconnection MCP reported no Studio instances. Direct city exit acceptance, remaining five actual unlock journeys, fresh banner rendering and multi-client/device checks remain pending. Evidence: [actual observations](validation-civic-cities-live.json), [domain tests](validation-civic-cities-domain.txt), [strict analysis](validation-civic-cities-types.txt).

Quota changed externally from 69%used/31%remaining to 0%used/100%remaining after the tool disconnect. No quota reset was requested by this agent. The user threshold remains 25%remaining; no shutdown was issued.

## Fresh return acceptance after reconnect

The newly built offline file was reopened in Studio aac5e826-8894-42b8-938f-607baa57a9e1. An ordinary-input fresh character completed both prerequisite tasks again, entered Crownford at revision10/25Gold, displayed Crownford · Safe zone, then used the direct Central City exit. Returned at revision11/25Gold near (0,3.698,-720), both tasks still Claimed. Console clean; Play stopped. No source hotpatch or profile grants. [Evidence](validation-civic-city-fresh-return.json). This resolves the earlier interrupted exit and banner checks; other cities' actual journeys remain pending.

## Civic maps

All six cities now expose an N-key/touch map with landmark, Central City and guild-island waypoints, a local player dot and world direction feedback. Quest guidance while inside a civic city first leads to its Central City exit. The existing menu focus router handles exclusivity. The map is a location guide; roads and local service interiors are not rendered. Native isolated UI:36cases/108text bounds at240,640,704px in EN/TH; no overlaps. Actual mouse clicks on the Thai Ironroot fixture captured all three expected world coordinates, without travel or profile writes. [Evidence](validation-civic-map-native.json). Full map interaction while physically in each city and physical device acceptance remain pending.

## City welcome hosts

Crownford has Archivist Iven, Sylvaris Gardener Leth, Deepforge Foreman Durn, Astralis Observer Tavi, Crosshaven Dockkeeper Nessa and Ironroot Hearthkeeper Ugra. Each offers original EN/TH orientation dialogue through the existing portrait/conversation UI, using a shared city rig and work loop; distinct final character art is pending. They grant no rewards. Maps now include the welcome guide as a fourth target. Updated native checks:48paths/12landings/24prompts and36UIviews/144text bounds. Fresh ordinary play again earned Crownford access, opened N-map, clicked Welcome guide, saw98stud direction feedback, walked to Iven and opened his dialogue; revision10/25Gold unchanged. Initial E from behind the camera did not trigger; walking to the visible side worked. Other five actual host conversations remain pending. [Evidence](validation-civic-hosts-native.json).672domain tests pass.
