# Central route Studio execution — 2026-10-16

Source commit: `5973ad360ff9c4992367f3e4e141352927465c32` (runtime/test code unchanged
since the recorded local checks at `e842d009385158f3b48e4d02af0fc0d961735cbf`).
User explicitly authorized the separate Memory test file. No publication or cloud
store operation was performed. This is bounded route/service evidence, not full
Round 1, visual acceptance, earned progression or release acceptance.

## Candidate and initial failures

Initial `offline.project.json` artifact SHA-256
`f0063b98f40075879530a954a4892a073e801af3b755963c67927e3afce73d2e`
matched its 359 packaged sources, but its stale explicit Config list omitted
ReleaseContent. ServerBootstrap failed before creating GuildborneWorld. The
service/party attempts therefore did not run successfully. See sourceCheck.json,
services.json and initialConsole.json. This failure was not repaired in the
tracked legacy project manifest during this verification slice.

Used the existing `python tools/build_integration_preview.py` to package current
Config files automatically with offline/Runtime.luau. A direct Edit-source sync
attempt hit Studio's 200,000-character Source assignment limit; that attempt was
abandoned and the newly built file was opened directly in another Studio instance.
See correctedSourceCheck.json for the preserved failure, not a successful check.

Successful candidate: `build/Guildborne_IntegrationPreview.rbxlx`, also copied to
the requested `build/Guildborne_WorldConnectivity.rbxlx` on disk. SHA-256:
`50d988e63c8ee21968aa78414b9744adf4c1850a84a39ea4673596896d67e2fe`.
The successful session was `b31f1200-2395-43cd-b2bf-7dd1581fa169`.
All 379 packaged source entries matched loaded Edit source exactly after CRLF/LF
normalization; PlaceId=0, GameId=0, Memory, empty allowed DataStore universes,
StreamingEnabled=false. Additional packaged art from the existing builder is
preview-only. Test modules were then inserted separately in ServerStorage.
Localhost HTTP was enabled only during fixture transfer and restored before Play.

## Observed results

| Check | Result | Scope |
|---|---|---|
| ExpansionWorld city service fixture | 29 assertions PASS; cleanup true | Synthetic actor/plot exercising actual spatial implementation |
| HeroService walk | 20 segments PASS; 1,277 samples; maximum separation 20.428361892700195 studs | Synthetic leader/profile, actual five class companions and Roblox physics |
| Door interiors | All five entered and exited Tavern, Blacksmith and Exchange; six building snapshots | Current authored doors/floors, not all body presets |
| Recovery and rewards | All RecoveryCount values remained at initial 1 (setup Travel); zero additional recoveries, zero reward callbacks, no death/fall | No earned recruitment or rewards claimed |
| Player input | Clicked Continue; normal-speed MCP character navigation to island City gate; E traveled to City; walked to Plaza | One actual local player, automation controls |
| Player services | Walked Forge/Exchange interiors and exits; Forge E opened Crafting; Tavern E opened Tavern | Existing requirements remained; no craft/hire transaction executed |
| Cleanup | Party and service fixtures removed; Play stopped; temporary probe modules removed in both local previews; HTTP disabled | No persistent game mutation |

The actual player visited Forge, Exchange, Plaza and Tavern in that order after
arrival; the synthetic five-hero test executed the requested Plaza → Tavern →
Forge → Exchange → Plaza loop. Character navigation tool success is distinct
from manually controlled keyboard traversal or physical touch evidence.

The first Tavern E attempt was beyond prompt reach and did not open Tavern;
walking nearer the station then opened it. Both observations are retained in
playerTavern.json and playerTavernFinal.json. No currency was supplied to bypass
crafting/recruitment requirements. `profile_saved` in the console refers to the
verified Memory session.

## Captures and limits

[Plaza](plaza.png), [Crafting at the city forge](forge.png), [Tavern](tavern.png)
are actual Studio captures from this run. They do not approve art quality.
The final console retains Roblox CorePackages FoundationProvider warnings and
asset-type warnings for rbxassetid://203785492. No Guildborne runtime exception
appears in the successful candidate's captured console; it is not warning-free.

Other zones, civic charters, earned crafting/recruitment, save/rejoin, physical
devices, multiplayer, performance profiling and human art/UAT remain pending.
Use the dynamic Memory builder for continuation; the stale offline.project.json
Config list remains a known tooling issue requiring its own scoped fix.
