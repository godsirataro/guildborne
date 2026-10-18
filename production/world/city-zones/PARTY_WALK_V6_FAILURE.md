# Native five-companion fixture: retained failure

Source9c34435 (game source d5d6557), candidate source packet
3cd03b3f2eb99301ffae0eb7cae40f08faa270b077b8afba56a7249d9384b946.
Studio155918dd, all385sources compared exactly before Play. The standalone
ContinuousPartyFixture.server.luau SHA256 is
9f2a039efccbeb7672148adb6605eedf482a62b66e33ca26e33d7f08e3ef8dca.
Normal ServerBootstrap and ClientBootstrap disabled; exactly one WorldService
was created. Synthetic Hall1/level10/five-roster/eligibility, real Roblox player
and Humanoid.MoveTo. This is not earned progression or Bootstrap-policy proof.

Result FAIL_NATIVE_FIXTURE at sample740, Greenwood landing, position approximately
(0,4.998,1515.38). All38outbound centerline nodes completed with five living
followers and RecoveryCount unchanged at1 each; maximum separation22.489studs.
CurrentZone correctly became Greenwood, but context incorrectly became
city_greenwood_west|Greenwood|City while the player continued inward toward1505.
The fixture asserted Wrong walking direction and retained the scene/report.
Return journey did not execute. No rewards were issued by fixture callbacks.

Source-grounded diagnosis sent to S17: global vector between entry centers does
not represent the final local approach. The route approaches Greenwood from the
south and continues toward decreasing Z; the global City-return axis also points
toward decreasing Z. An arrival latch using that axis misclassifies continued
forward walking as reversal. Require local incoming tangent/validated movement
and a regression with this actual hairpin endpoint, not just straight mock boxes.

During outbound walking, actual client WalkingRouteContext.read consumed38nodes
and live server projection, returning next bend19 at(-292,4.8,402). Mounted the
actual WaypointBeacon in a separately labeled native presentation fixture:
796x674 EN and TH each had all3visible TextLabels TextFits=true, with live compass.
Tool capture continuous_party_fixture_outbound shows actual engine output; no
PNG archive was saved. Full CityNavigation,320px/device and real quest guidance
remain unverified. Art imports were disabled; the pictured bare road/actors are
physics fixtures and do not constitute finished visual work.

Combined source baseline completed935tests,385strictfiles/build-boundary checks;
47focusedwalking/questtests also passed. Those passes did not predict this native
failure. Raw baseline: build/controller-walking-ui-v6-baseline.log.
Raw native report: PARTY_WALK_V6_FAILURE.json. S17 owns the requested correction.
S13 owns broader terrain art; S15 assigned Greenwood scout/captain native art and
server-clock motion; S14 source integrated. Quota last measured72%remaining.
