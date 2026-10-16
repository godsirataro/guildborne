# S13 wave 1 â€” owner-island route probe

Status: SOURCE / LOCAL REVIEW only. Studio NOT_RUN on this revision. No runtime source changed, no earned roster/reward, remote authorization, combat, persistence, device or human acceptance asserted.

## Controller contract

Reviewed revision 1, controller commit a483a7c, SHA256 `a9d5d586b4ae235f7436c862f491bf979fe9a8ea4eba63137a3f6aa629566fb9`. Accept its authority and shared-boundary rules. Source correction: its statement that QuestRoute resolves owner-island return must be treated as intended behavior, not delivered behavior. `src/shared/Data/QuestRoute.luau` returns nil outside City/known regions; in-city UpgradeGuildHall selects nearest Guild portal, while `src/client/Controllers/CityNavigation.luau` renders its projected target. Existing native island Goblin Camp guidance is not established by these modules. No WorldInteraction/QuestNavigation named modules or new schema were added. UI owner/controller must retain this gap in integrated acceptance.

## Invocation and fixture

Controller owns Studio. In the isolated PlaceId=0/GameId=0 Memory candidate with empty DataStore allowlist, start through Title and load a real player's island. Load the reviewed test source as a temporary server ModuleScript named `S13CityPartyProbe` under ServerStorage using the existing controlled fixture loader. Then execute in server context:

```luau
local player = assert(game:GetService("Players"):GetPlayers()[1], "Load one player first")
local result = require(game.ServerStorage.S13CityPartyProbe)({islandOwnerUserId=player.UserId})
print(game:GetService("HttpService"):JSONEncode(result))
```

Explicitly select the intended player if multiple clients exist; do not guess an owner. Call without options to retain the original city-only route. The loader/module itself is external fixture setup and must be removed by controller afterward. Do not put this module in runtime source or publish it.

The actor UserId -93901 and five level-10 Knight/Warrior/Archer/Mage/Priest followers are synthetic. HeroService, travel validation, raycasts and movement use actual runtime implementations. The supplied user's existing PersonalGuild geometry is borrowed read-only; the probe's synthetic owner-to-plot map is deliberately injected, so this is not proof that the real Dispatcher/session authorizes ownership. Combat origin remains (7000,0,6000), with overlapping island X strips rejected. Real profile, island ownership attributes, enemies, quests and inventories are not edited. Reward callbacks must remain zero. Use a quiet island with no ongoing real-player combat/tower state; rejection is preserved if these gates are active.

## Existing anchors and route

- City district route remains Plaza -> Tavern -> Forge -> Guildborne Exchange. Market district and MarketDistrict stop are distinct identifiers.
- Existing tagged MarketDistrict gate: (300,6,-1080), TravelDestination Guild. TravelService.Validate checks distant/invalid requests, validates landing and enforces cooldown before Travel. Native E prompt has 10-stud activation and 14-stud server callback distance; TravelRules allows at most 16. This fixture calls services directly, so ordinary-input activation is a separate controller gate.
- Owner island is selected by PersonalGuild.OwnerUserId. Origin is Environment.Nature.Ground.Position + (0,1,0), checked against PersonalGuildSpawn; canonical origin is (slot*280,1,0). Guild primary landing origin+(0,5,23), fallback +(0,5,14).
- Walk local Z23 -> 36 -> CampPath Z62 -> CampClearing Z91, X0. CampClearing center is origin+(0,.1,91), size58x.15x42. All five followers must enter its X/Z footprint. Goblin1..3 belong to real combat; decorative GoblinScout is not a substituted enemy. No combat/reward assertion here.
- Walk back Z62 -> 36 -> 23 -> 4, then ReservedAccess X64/Z4, BuildGround X64/Z-34, actual IslandBridge center (origin.X+64,0,-49), promenade Z-65 and Central City gate approach (-36,4,-65), within 10 studs of the gate (-44,6,-65). No manual reposition on the extended route. Obstruction, fall, death, lag or automatic recovery fails with activeSegment and last hero evidence.
- Validate City return before Travel; check CurrentZone, RespawnLocation and remembered MarketDistrict landing (300,5,-1068), fallback (300,5,-1060). A generic central-arrival fallback does not pass this remembered-stop check. Return to avenue and Plaza.

Walking speed14, no autojump, gap<35, living leader/followers above Y-5. Each deliberate Travel must increment every follower's recovery counter exactly once immediately; continuously sample settling and all walking without accepting further recovery. Cleanup disconnects the probe TravelService Heartbeat, removes its owner state, destroys HeroService and fixture even after route assertion failure. Returned cleanup also checks the captured connection is disconnected. Original world geometry is retained.

## Validation and handoff

`checks.json` records commands, exact return codes, probe SHA256 and losslessly base64-encoded stdout/stderr (including empty streams). Trusted primary .tools executables are used by absolute path; no junction, install or download. Focused compile/analyze cover both city probes. City source geometry audit checks the existing city route, not the added island physics. Full baseline/market soak was not rerun because changes are fixture/docs only; earlier baseline is historical, not this revision's fresh gameplay acceptance.

Independent read-only review caught and fixed recovery-baseline masking and combat-isolation overlap. Controller requested the complete walking return; final probe uses existing expansion ground/bridge geometry. Real Studio results, screenshots, integrated quest navigation, accepted/rejected Power Strike and earned rewards remain controller gates. Other Round 1 areas, Round 2 polish and device/human acceptance remain incomplete.

## Return-gate correction — 2026-10-16

Controller reported the first integrated Studio run FAILED at `Promenade to Central City gate`: leader (-37.8785,4,-64.996), five followers alive, recovery count 2 unchanged, all reached camp, 1498 samples, maximum gap 23.88, rewardCalls 0, cleanup true; preceding 32 segments passed. These are controller-reported observations; original raw failure evidence remains with the controller and is not replaced by this source correction.

CityWorld creates solid portal pillars at gate X +/-5, size (1,12,2). Walking west directly to gate center (-44,6,-65) crosses the east pillar at X=-39. The corrected goal is gate.X+8 at Y4, Z=gate.Z, namely (-36,4,-65), on the existing promenade before the pillar. A new actual 3D-distance assertion requires <=10 studs, matching native prompt reach (server callback <=14; TravelRules <=16). Validate/Travel, normal walking, deadlines, five-follower health/gap/recovery checks and cleanup are unchanged. No runtime geometry or source changed, and no manual teleport was added.

Corrected Studio run: NOT_RUN. The initial checks.json belongs to the previous probe SHA; fresh focused correction receipts appear below. No full gameplay baseline/soak rerun for this fixture-only correction. Native input activation remains separate from this service fixture. Both failed evidence and the corrected source must be retained for the controller's rerun.

```json
{
  "utc": "2026-10-16T07:30:52.097898+00:00",
  "status": "LOCAL_ONLY_REVIEW",
  "studio": "NOT_RUN",
  "probeSha256": "83bcbca2799492988eeb0c6da9216ec9a9568f4399679cd202515fd97dbcf0ca",
  "checks": [
    {
      "name": "compile",
      "command": [
        "C:/Work/MySelf/Guildborne/.tools/luau/luau-compile.exe",
        "--null",
        "tests\\studio_city_party_walk_probe.luau"
      ],
      "exitCode": 0,
      "stdoutBase64": "Q29tcGlsZWQgMCBLTE9DIGludG8gMTggS0IgYnl0ZWNvZGUgKHJlYWQgMC4wMXMsIHBhcnNlIDAuMDBzLCBjb21waWxlIDAuMDBzKQ0K",
      "stderrBase64": ""
    },
    {
      "name": "analyze",
      "command": [
        "C:/Work/MySelf/Guildborne/.tools/luau-lsp/luau-lsp.exe",
        "analyze",
        "--platform=roblox",
        "--sourcemap=build/sourcemap.json",
        "--definitions=C:/Work/MySelf/Guildborne/.tools/luau-lsp/globalTypes.d.luau",
        "tests\\studio_city_party_walk_probe.luau"
      ],
      "exitCode": 0,
      "stdoutBase64": "",
      "stderrBase64": "W0lORk9dIExvYWRpbmcgZGVmaW5pdGlvbnMgZmlsZTogQHJvYmxveCAtIEM6L1dvcmsvTXlTZWxmL0d1aWxkYm9ybmUvLnRvb2xzL2x1YXUtbHNwL2dsb2JhbFR5cGVzLmQubHVhdQ0KW1dBUk5dIGNsaWVudCBkb2VzIG5vdCBhbGxvdyBkaWRDaGFuZ2VXYXRjaGVkRmlsZXMgcmVnaXN0cmF0aW9uIC0gYXV0b21hdGljIHVwZGF0aW5nIG9uIHNvdXJjZW1hcCBjaGFuZ2VzIGRpc2FibGVkDQo="
    },
    {
      "name": "diff-check",
      "command": [
        "git",
        "diff",
        "--check"
      ],
      "exitCode": 0,
      "stdoutBase64": "",
      "stderrBase64": ""
    }
  ]
}
```
