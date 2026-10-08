# Phase 3 Studio test record

Date: 2026-09-29. Place: Guildborne - Staging, 86788611613035. Tool: Roblox Studio MCP. All gameplay runs use temporary Memory mode so existing saved profiles remain untouched. Not published.

## Baseline

Read existing documentation including PHASE2_CLOSURE; inspected runtime generation, personal plots, followers, combat, UI and travel. The previous 123 tests passed before changes. Ran class selection, recruitment, party formation, all three timed quests and five-member recruitment. Camp combat produced basic attacks, abilities, healing and downed behavior. See [baseline Output](evidence/phase3-baseline-output.txt). Initial single-client captures showed a blank 3D view behind the HUD; separate multiplayer clients subsequently rendered the world.

## Two-player session

Started with StudioTestService.ExecuteMultiplayerTestAsync(2). Two actual clients (Player1/-1 and Player2/-2) joined the same server, independently completed three quests and recruited all five roles via public RemoteEvents. Both reached Central City with five Following heroes. Each client replicated both players and all ten owner-tagged heroes. Full projected progression was equal before and after travel.

Three round trips per player returned Player1 to X=0 and Player2 to X=180 at their own guild spawn, then both to city Z=-720. These repetitions used server positioning at the portal followed by real client travel commands; they are not claims of manually walking the entire return route. See [round-trip responses](evidence/phase3-roundtrips.json) and [server Output](evidence/phase3-two-player-output.txt).

City respawn originally exposed an engine placement race. A delayed, character-identity-guarded respawn pivot fixed it; the multiplayer retest returned to 0/5/-720. A fall below Y=-15 recovered to city spawn. Player/player collision was false, and coincident portal arrivals did not displace/block either player. Foreign hero selection returned InvalidParty; distant travel returned VisitStation; city Basic attack returned EnterCamp. Camp combat outside the city still produced attacks, all five class abilities and healing.

Walking through MCP character navigation passed portal→plaza, plaza→guild, plaza→market, plaza→tower, and plaza→tavern via the garden walk. Five followers remained owned and Following. Some path recovery counts increased on guild approaches and deliberately assisted long-distance moves; no claim of zero recovery or polished crowd motion is made.

## Final four-player acceptance

Started a separate actual four-client Studio session. Each client completed the normal timed quest/recruitment loop and selected all five roles. All four clients reported four players and five heroes for each of the four owner IDs; projected progression matched the post-recruitment snapshot after travel and checks. See [replication snapshots](evidence/phase3-four-client-replication.json).

The final streetscape added repeated frontage and distinct council/tavern/forge silhouettes. The garden path was moved beside the tavern rather than through its footprint; the live geometry was updated to match and walked. With all five heroes, the player passed the garden corner, tavern door and shallow foundation step while two other players occupied the doorway. At the interior checkpoint, followers remained Following at distances of approximately 7.5–17.5 studs. The final plaza→tower→plaza route passed by walking, without teleport. At the tower checkpoint all five heroes had zero attacks and Follow combat state. Recovery counters were 2 for four heroes and 6 for the Warrior; these counters include prior quest/position changes, not a measured rate of city path failure.

Obstructing the main city spawn with a temporary solid block sent Player2 to Z=-750. Obstructing both candidates returned TravelUnavailable without moving the player. Removing the test blocks restored normal travel. City respawn and a subsequent Y=-20 fall both recovered to Z=-720. Player4 leaving removed that player and its five heroes, while the remaining three players and fifteen heroes stayed present. A native E-key interaction at Guild Registry opened the localized CityFuture placeholder. See [final checks and sample](evidence/phase3-final-checks.json).

### Requested Studio checks

| Checks | Observed result |
| --- | --- |
| A–C: guild spawn, city travel, five companions | Passed; four distinct personal spawns and shared city arrival |
| D–I: plaza, tavern, guild, market, tower, return | MCP walking passed; final tower→plaza return used no teleport |
| J: map | N-key open/close exercised; live gold marker and six localized districts inspected |
| K–L: return and repeated travel | Three round trips for both clients; own guild origins preserved |
| M–N: respawn/fall | Retested after fixing spawn timing; city destination preserved |
| O: companion navigation | Garden corner, tavern doorway/step, plaza/avenues, portal; earlier guild bridge approach required segmented waypoints |
| P: safe zone | Client attack rejected EnterCamp; followers acquired no city targets; outside camp combat still ran |
| Q–U: TH/EN, portrait, landscape, PC | Captured and inspected; responsive landscape map corrected after initial clipping/scroll review |
| V–W: multiplayer and parties | Two then four real Studio clients; ten then twenty correctly owned replicated heroes |
| X: blocking | Overlapping portal arrivals and occupied tavern doorway did not block passage |
| Y: Output | Inspected server and client Output; no game errors in final run |

### Mobile and interaction limitations

Galaxy A06 simulation used portrait (360 × 719 camera viewport) and landscape (706 × 339). StarterGui uses Sensor orientation; CityNavigation uses CoreUISafeInsets. The map/close targets are at least 48 pixels high and the map button is separated from the companion HUD. Thai and English labels fit; the compact landscape layout displays all six districts. Desktop was also inspected at 1096 × 653.

MCP mouse commands reported success but did not reliably activate map/close buttons, on either the simulated phone or desktop. Keyboard N did activate the map; the E proximity prompt worked. Therefore this report verifies mobile layout and keyboard navigation, **not physical touch activation**. Device hardware testing and a human unaided wayfinding session remain useful follow-ups. An initial single-client blank capture was avoided by separate multiplayer clients. Long-range overview images temporarily used graphics quality 21; low automatic quality culled distant geometry, so these screenshots are not evidence that all landmarks remain visible at minimum quality. Local signs and the map provide the fallback.

### Performance and layout review

The final city contains 1,728 BaseParts, eight ambience rigs and zero Light instances. Four plots/parties brought the sampled workspace to 3,658 parts. A short 120-heartbeat server sample averaged 16.67 ms, p95 18.08 ms, maximum 19.27 ms. This is one desktop Studio sample, not CPU cost per city system, sustained profiling or a real mobile FPS claim. Streaming remains disabled pending a dedicated streaming test.

The arrival avenue leads directly to the gold monument/plaza; tavern roofs/chimney branch west near arrival; blue/gold guild administration and orange exchange bracket the plaza; twin stone towers mark north; the southern portal and localized map identify the return route. Primary roads comfortably accommodate five followers. Approximate important walks are 19–50 seconds at normal speed. Building silhouettes and colors are distinct, although the modular art remains deliberately simple. Open outer garden areas remain for expansion; no advanced crowd simulation is included. Guildborne timber/burgundy/gold motifs are reused rather than imported unrelated assets. These are agent visual/layout judgments, not a new-player usability study.

### Screenshots

| View | Evidence |
| --- | --- |
| City entrance | [Entrance](evidence/phase3-entrance.jpg) |
| Central Plaza | [Plaza](evidence/phase3-plaza.jpg) |
| Guild District | [Guild](evidence/phase3-guild.jpg) |
| Tavern | [Tavern](evidence/phase3-tavern.jpg) |
| Market/Craft | [Market](evidence/phase3-market.jpg) |
| Tower Gate | [Tower](evidence/phase3-tower.jpg) |
| Guild Zone Warp | [Warp](evidence/phase3-warp.jpg) |
| Aerial overview | [Aerial](evidence/phase3-aerial.jpg) |
| Mobile English/Thai | [English portrait](evidence/phase3-mobile-en.jpg), [Thai portrait](evidence/phase3-mobile-th.jpg), [Thai landscape](evidence/phase3-mobile-landscape.jpg) |
| Multiplayer | [Four players with twenty heroes](evidence/phase3-multiplayer.jpg) |

District images use a temporary evidence camera. Multiplayer subjects were positioned together for the photo after travel/replication validation. The aerial image precedes the small final garden-path lateral adjustment; district/building layout is otherwise the final layout. No screenshots are fabricated or concept renders.

## Handoff decision

The requested **Studio implementation definition of done is met**, with the explicit input-tool, real-device, low-quality draw-distance and usability limitations above. No known critical game runtime error remains from these tests. All 136 automated tests and the build/type/compile/repository gate pass. Existing Class 2 at 30, Class 3 at 70, level 100 maximum, Hall 20, +5 cap increments and never-demote regressions remain intact.

Normal DataStore configuration and the exact original bootstrap were restored in Studio; temporary fixtures, blockers, camera bindings and test clients were removed by ending the session. Studio is stopped in Edit mode and reset to the default viewport. Existing saved profiles were not reset or used for destructive tests. No publication and no Phase 4 implementation. Await explicit approval before beginning Phase 4.

Final artifacts: [validation log](evidence/phase3-validation.txt), [server Output](evidence/phase3-final-output.txt), and [exact normalized source equality for fifteen disk/Studio runtime files](evidence/phase3-source-sync.json).
