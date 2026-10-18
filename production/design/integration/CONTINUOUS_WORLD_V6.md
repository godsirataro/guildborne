# City–Greenwood walking integration contract

Status: server walking implementation integrated at ac8cd25; geometry and GUI
follow-ups pending. Not Studio accepted.
Full objective remains all connected cities/Lv1-100/tower/party and custom art.

Shared ledger: C:/Work/MySelf/Guildborne/build/agentic/four-session-v6.sqlite3.
Audit and registry independently ACCEPTED at fa9ea00 by catalog_audit; packets
build/agentic/evidence/audit-v6.json and registry-v6.json retain raw receipts.
Audit verified3005files/70tasks/98generatedfiles/fresh912tests; registry664rows,
402filehashes and575asset/screen statuses unchanged. These are local gates only.
v5 is historical with no active/review leases. Do not reuse old controller tokens.

S13 owns world-quality-slice and Blender in a fresh fa9ea00 worktree. S17 owns
continuous-world-travel after claim in a separate fresh worktree. Controller owns
expansion-integration (WorldService/Bootstrap/main runner). No overlapping writes.
S14/S15 latest source integrated; their next waves await dependency-ready scope.

## Geometry interface

S13 supplies a server-created descriptor:

```luau
{
 id = "city_greenwood_west", fromZone = "City", toZone = "Greenwood",
 geometry = routeModel, -- descendant of GuildborneWorld
 volumes = { {cframe = segmentFrame, size = segmentSize} },
 entries = {City = cityOBB, Greenwood = greenwoodOBB},
 safeRecovery = {City = citySafeCFrame, Greenwood = greenwoodSafeCFrame},
 isReady = function() ... end,
}
```

OBBs use finite positive bounded dimensions including Y. Entries overlap legal
source zone and corridor; recoveries remain source-side with real floor/headroom.
No giant region rectangle. Controller validates geometry/readiness and passes it.
Existing anchors and private guild/course/campaign spaces remain isolated.

City south wall Z-625 needs an actual opening nearX0; avenue reachesZ-680.
Route bends west ofX-180 around private guild plots then approaches Greenwood
from southZ>1526, landing(0,2,1518). Avoid lodge/combat platforms. Existing City
Greenwood portal(0,5.5,-1450) is not the geographic endpoint. Preserve portals.
24stud clear lane is proposed, with wider bends/restareas and authored coastal,
cliff/lookout and woodland sections. S13 verifies/revises coordinates before build.

## Runtime interface

TravelService(city,plots,heroes,localTravel?,platform?,walking?) retains existing
argument semantics. Optional walking={Routes,Session,Gate,Notify?}; absent option
preserves current behavior. Gate(player,session,fromZone,toZone) returns problem
or nil synchronously, no yielding or mutations. No client-controlled crossing API.
Controller binds heroes.SetWalkingContext(travel.CanFollowWalking). Predicate is
true only for admitted server corridor context, not arbitrary geometry membership.

Admission requires tracked source zone, observed entry crossing, live session/
character and valid gate. Latch session object/epoch/token, character, direction.
Keep CurrentZone/respawn at source through transit. Recheck at destination entry,
then update zone/respawn in place. Never call arrive()/heroes.Travel() for ordinary
crossing: they teleport/reset follower history. Existing Regional.Sync handles
zone combat change; no new reward scene or duplicate combat ownership.

Root Bootstrap composes live Player/Data session identity, Active/notclosing/
notbusy, novice, Release.problem, tower, existing civic charter, mentor/private
activity eligibility. Fail closed on invalid callbacks. Never invoke mutation
commands/Settlement.apply/receipts merely to walk. No release flag loosening.

Bounded source-side recovery is an explicit exceptional correction for denied
entry, revoked gate, missing geometry or fall; validate floor/headroom first.
Character/session replacement invalidates old context without moving replacement.
Death uses source respawn mid-route, destination aftercommit. Portal/Visit/local
travel/Remove clear transit. Shared-local snapshot handling retains priority.

## Verification still required

Focused regressions: bidirectional no-pivot/no-velocity-reset crossing, exactzone/
respawn, entryjitter/skips/farjump/Ybounds, gates/identity, failure/recovery/death,
local/portal coexistence and follower continuity. Real fivehero walking, streaming,
combat transitions, graphics/performance and fullworld completion remain pending.

Earned Studio def49833 is preserved at The First Guest/HallLv1.62789207 Chapter3
also preserved. Disposable155918dd and7d1529ee stopped. No baseline process live.
Latest measured quota75%remaining; stop new waves near5%, no reset requested.

## Integration checkpoint, 2026-10-18

Root scaffold011fb22 uses explicit ContinuousWorldCandidate plus launchEnabled;
build with `python tools/build_integration_preview.py --launch --continuous-world`
only after geometry dependencies are integrated. Ordinary launch does not enable
the new seam. Canonical staging Runtime is unchanged. Bootstrap eligibility was
executed with frozen profile dependencies:23cases passed. Recursive private-arena
lookup covers nested TowerLesson models. Optional runtime flag uses the existing
explicit dynamic-field pattern following independent review.

S17 source6bbead1 integrated asac8cd25. Root reran17actual-service platform groups
successfully and added the suite to tests/run.luau. Combined baseline completed
with exit0:929tests, Rojo build, analysis/compile,384strict files and built-place
boundaries passed; existing lint warnings remain. Raw log is
build/controller-walking-v6-baseline.log. Local tests do not prove physics or
five-follower behavior. Documentation changed during the run; this is ordinary
local validation, not a clean-commit Forge acceptance packet.

S17 follow-up projection: single character attribute WalkingRouteContext is
exactly city_greenwood_west|City|Greenwood or the reverse zone pair, nil outside
admitted transit. Clear immediately on recovery, including blocked recovery,
and every completion/travel/death/replacement cleanup. Presentation only; server
authorization never consumes this attribute. Follow-up implementation pending.

S13 geometry metadata agreed: NavigationNodes folder containing ordered
Vector3Value nodes001..038 with Index, generated from the same floor centerline.
Model attributes RouteId,FromZone,ToZone,WalkWidth=24,
NavigationPointKind=FloorCenter,NavigationBelowFloor=4,NavigationAboveFloor=14.
Final source and names require handoff verification. S14 assigned fresh worktree
and v6gameplay-ui-quality for read-only consumption of these contracts: actual
curve navigation, neutral transit name, Walk instructions, no false quest claim,
and clearing stale markers on geometry/context loss.

Full objective and goal-tool text limitation: [MASTER_GOAL.md](MASTER_GOAL.md).

Controller visually inspected S13 cliffbridge.png: corridor is still sparse and
flat with an exposed floating strip and repeated scenery. Functional route art
is not final visual acceptance. Broader terrain/coast, landmarks and authored
transitions remain required after the native seam is proven.
