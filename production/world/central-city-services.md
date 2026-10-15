# P1 Central City services — 2026-10-15

Status: IMPLEMENTED; automated/local Studio checks PASS; scoped independent source/evidence review PASS.
This is a bounded P1 slice, not completion of P1, P0, or GL-2.0 Public readiness.

## Behavior

- The Hearth and Banner has an interior recruitment prompt opening the existing Tavern view.
- Blacksmith has an interior Crafting prompt and dedicated recipe view, without island building controls.
- Only CraftItem gains access at the trusted server forge within 14 studs. The exact original world/city/district/building/station hierarchy must remain intact. Live actor, Humanoid, finite positive combat health and no combat are required.
- Existing transaction rules still require a placed owned forge, recipe Hall level, materials, capacity and completed Novice journey where applicable. No economy/schema/market rule was relaxed.
- Pass, Hall, Tavern and plot actions retain island-only spatial validation; their former CraftItem aliases now use PlaceBuilding validation.
- Native crafting readiness refreshes on movement. Nearby city readiness works when the distant island model is absent. Missing station disables it. Thai and English show localized distance reasons.
- Tavern scout/hire readiness now reflects the server Novice gate. Candidate level uses a server projection: legacy Lv1, Novice Lv10.

## Candidate identity

Local standalone Memory place; PlaceId=0, GameId=0. Analytics and permanent passes disabled; allowed DataStore universe list empty. No publishing, production writes, asset uploads, spending or real market actions occurred.

Initial candidate SHA-256: `c73721b9de239393f747272dedb4efd1d6a313a4ccf9f94f88ed479682e5f57b`.
Final candidate SHA-256: `9862fdf20249c2c65945a1bebea55bd4688c3e91ac3e0539f36ee484050e5aaf`.

377 loaded source instances matched SHA-256 in both Edit and Server. The final candidate differs only in SliceUI's streaming/health readiness fix; all server/shared source hashes used by the initial station and five-companion runs are unchanged. Final native UI and neutral interior-walk checks ran after exact source sync and restart. `build-receipt.json` records every repository source hash and the Memory Runtime hash.

This preview retains the existing internal Lv1–35 content gate. Its filename LaunchPreview does not make it a full GL-2.0 release build.

## Observed checks

| Check | Observed result | Limits |
|---|---|---|
| `tools/validate.ps1` | 890 tests; Rojo build/sourcemap; Roblox-aware analysis; compile; repository and whitespace checks PASS | Local baseline, not player acceptance |
| Real ExpansionWorld station fixture | 29 checks PASS: radius boundary, forbidden actions, missing plot/station/root/Humanoid, dead actor, invalid health, combat, moved/removed station, nonfinite position, island access retained | Synthetic actor/plot; actual spatial implementation. WorldService alias mappings independently source-reviewed, not exercised by this fixture |
| Five companions | Knight/Warrior/Archer/Mage/Priest followed a synthetic leader through plaza, tavern and forge: 13 segments, all five entered and exited both buildings; 867 samples; maximum separation 21.1783 studs; zero reward callbacks | Actual HeroService and Roblox physics, synthetic profile/leader. Initial setup Travel accounts for RecoveryCount=1; every count stayed unchanged throughout walking. No earned recruitment or ordinary player input proof |
| Decorated interiors | 5 buildings, 169 furnishing parts; 31 central corridor samples per building clear at width8 | Geometry only |
| Neutral R15 | Entered/exited all 5 interiors at WalkSpeed16, auto-jump disabled | One neutral rig, not all13 cosmetic bodies or stairs |
| Native crafting UI | 12 assertions PASS: dedicated view; enable/disable/restore via Tick; absent island; missing/restored station; exact English/Thai location reasons; zero outgoing commands | Actual UI with copied synthetic display state; local reparenting simulates streaming absence, not streaming qualification. No touch/device or earned transaction proof |
| Production metadata | Studio validate/verify PASS:58 tasks,33 roles,10 workflows,98 generated files; GL2 validator PASS | P0 remains false with10 open decisions; publicReady=false |

Initial validation attempt passed890 gameplay tests but failed analysis on the test fixture's mixed-type array. That fixture annotation was fixed; the complete validation was rerun successfully. Initial UI fixture checked a Thai disabled state while its island was still absent and observed ActorNotReady; the final fixture restores the island and asserts the exact localized distance reason. Both original outputs are retained.

Studio Output includes Roblox CorePackages UIBlox FoundationProvider warnings. No Guildborne runtime exception was observed in the captured final output. This is not a claim that the Studio/plugin console is warning-free.

## Evidence and next gates

Raw tool outputs, original validation logs, fixture source and build hashes: `production/design/integration/p1-city/`.
Regression fixtures: `tests/studio_central_city_services_probe.luau`, `tests/studio_city_party_walk_probe.luau`, existing city-interior probes, plus readiness/projection tests.

Play was stopped after restoring temporary UI geometry and destroying fixture actors/services. This is REVIEW evidence, not formal Forge acceptance; the shared checkout contains unrelated pre-existing work and is not a clean reviewed release commit.

Independent reviewer `/root/gl2_inventory` found no remaining blocker after the streaming and five-companion exit fixes. The reviewer checked the recorded counts, all377 manifest entries, all359 current repository source hashes and28 evidence hashes. This was read-only source/evidence review, not an independent replay of Studio. Review receipt: `production/design/integration/p1-city/independent-review.json`.

Still required: normal-input earned recruitment/crafting and save/rejoin journey; natural NPC routines/tool grip and visual scale review; complete lighting/audio/art direction; 13 body/clothing/animation fits; physical Android/iOS; real multiplayer/cross-server; and human art/UAT signoff. Lv100/Class3/Federation/war/territory/player market remain mandatory for first Public. No opening date is claimed.

Tooling: Rojo7.7.0 local plugin installed earlier; existing Blender5.2 found. No additional third-party plugins were needed for this implementation.
