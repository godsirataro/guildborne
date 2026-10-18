# Chapter03/04 campaign navigation — 2026-10-18

Review candidate on `codex/later-campaign-navigation`, based on `ef4868b`.
Local implementation and source validation only. Controller owns Studio and the
full baseline; this worker did not invoke Studio or publish/push anything.

## Implemented

- `QuestRoute` recognizes all 36 existing Ashen/Tower prompt objectives and the
  two Ashen surface victories. Exact action-part names come from `AshenWorld`
  and `TowerWorld`; no translated-label guessing or new world coordinates.
- `CampaignRouteContext` reads actual replicated owned courts, floor height and
  bounds, enabled prompts, living owned encounter actors, escort/protection
  state and Tower lesson/trial state on every update. CityNavigation integrates
  this disposable context with its existing server-snapshot quest selection.
- Both chapters travel through the existing Ashen gate. Tower's court is the
  Ashen annex, not the combat Tower. Surface/owned floor/foreign vertical slots
  remain distinct. Missing/disabled/foreign markers stay unavailable.
- Multiple markers are nonfinal objective areas, including all narrative choices
  and sequences. Only the server-enabled Tower bypass remains eligible; navigation
  does not solve puzzles, submit choices or infer intermediate progress.
- Active Tower lessons/trials and its escort use instructions. Ashen escorts use
  replicated current position/exit; protection uses a still-live warning only.
  Ashen combat first exits the court, then requires the actual owned living enemy.
- Claim-ready state remains instructions without coordinates. Earned Hall return
  exits the owned court before the existing surface/city/island route. Player Y
  is captured even when the entire world root is absent, preventing false surface
  directions during streaming.
- Region/court guidance remains explicitly bearing-only; no safe-path claim or
  fabricated world beacon. Server logic, canonical IDs, rewards and flags unchanged.

## Checks actually run

| Check | Result |
|---|---|
| Forge doctor, validate, plan; reconciliation; character contract | PASS local contracts; no tool/device acceptance |
| `tests/gui/run_campaign_routes.luau` | PASS 35 cases: current route/tracker tests including 10 new later-campaign cases; one covers all 36 prompt objectives |
| Scoped Roblox luau-lsp analysis | PASS QuestRoute, CityNavigation, CampaignRouteContext, city_waypoint tests, targeted runner and native probe |
| Luau compilation of those six files | PASS |
| Rojo isolated probe build, explicit `--rojo` override | PASS; XML one LocalScript, zero server Scripts/remotes |
| `git diff --check` | PASS |
| Independent source review | Reviewed by separate `campaign_contract` agent; missing-world height edge corrected and regression added |
| Native probe's 12 runtime cases | **NOT_RUN**; controller Studio handoff |
| Live quest/prompt/streaming, EN/TH native input, physical device | **NOT_RUN** |

Targeted run (existing binaries, no installation):

```powershell
.tools/luau/luau.exe tests/gui/run_campaign_routes.luau
python tests/gui/build_campaign_route_probe.py --rojo C:/Work/MySelf/Guildborne-controller/.tools/rojo/rojo.exe
```

Generated probe:
`build/campaign-route-probe/GuildborneCampaignRouteProbe.rbxlx`

SHA256: `00b629e755e1b7eff57aa2c2cc61319873a2d136fd65543170ae0b0c4b953112`.

Open the probe in a disposable Studio tab and Play. It creates synthetic native
Instances, executes the actual collector and route modules, and reports
`CAMPAIGN_ROUTE_NATIVE_RESULT`; ScreenGui `CampaignRouteProbe` exposes `Passed`
and `Failed`. Expected 12/0, **not observed yet**. It does not load game services,
issue remotes or mutate profiles. This is a collector/route probe, not a full
campaign or actual streaming test.

## Controller acceptance still needed

Run ordinary Chapter03/04 travel and enabled prompts on the integrated source;
verify surface -> owner court -> objective, each choice/bypass branch, active
activities, court exit for combat/Hall, ready claims, absent/reappearing streamed
anchors and owner isolation. Ashen's existing floor has a narrow outer fringe
outside `City.region`; that fringe stays conservatively unavailable. No canonical
geometry change is included. Full baseline and human/device gates remain separate.
