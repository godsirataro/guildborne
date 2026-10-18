# City–Greenwood continuous travel source candidate

Base: fa9ea00. Shared v6 audit/registry gates accepted by the controller before
implementation. This is one optional walking seam, not completion of the connected
Lv1–100 world or Studio acceptance. No release flags, profiles or rewards changed.

## Integration contract

Append `walking` as the sixth argument to
`TravelService(city,plots,heroes,localTravel?,platform?,walking?)`. Existing callers
and the fifth platform-test argument retain their meanings. Controller owns
WorldService/Bootstrap wiring and must call
`heroes.SetWalkingContext(travel.CanFollowWalking)` after construction.

`walking={Routes={descriptor},Session=...,Gate=...,Notify=...}`:

- `Session(player)` returns the exact live Data session after current Player checks.
- `Gate(player,session,fromZone,toZone)` returns nil or a rejection string. Controller
  composes current Player/session, novice, enabled release policy, tower, civic
  charter, mentor and private course/trial/campaign restrictions. It must not call
  persistence commands or Settlement.apply. The service additionally checks
  Active/not-closing/not-busy, live/not-downed character and plot combat/tower.
- Optional `Notify(player,code)` is rate-limited to once per two seconds per player.
  All supplied callbacks run synchronously through a fail-closed no-yield wrapper.
- Descriptor fields are `id/fromZone/toZone/geometry/volumes/entries/safeRecovery/
  isReady`. Only City↔Greenwood is supported in this increment. Geometry lives under
  GuildborneWorld and its readiness is controller-validated. OBBs are
  `{cframe=CFrame,size=Vector3}`, with finite positive dimensions, X/Z ≤4096 and
  Y ≤128; volumes are a bounded list of 1–128 segments. Entries are keyed City and
  Greenwood and overlap the physical legal source footprint. `isReady()` returns
  true only while the source geometry is usable. No broad City.Bounds/region or
  regionCombat expansion is used to classify the corridor.
- `safeRecovery` holds avatar-root CFrames keyed by source zone, 2–6 studs above
  supported floor with a clear 4×5×4 box. Recovery checks source town/region AND
  surviving corridor geometry for floor and obstruction, including source-side
  landings supported by the existing town rather than the route mesh.

## Behavior and authority

Two consecutive samples of the same session/epoch/token/character are required;
only the latest sample must be inside source entry. The previous sample may be
on the approach, so walking does not require a pause. A regression traverses a
ten-stud entry at eight studs per half-second, with exactly one inside sample.
At WalkSpeed 16 the legal-source overlap must exceed eight studs along approach;
to cover every allowed sample displacement, provide at least 35 studs INSIDE the
source footprint (not merely a wide OBB extending beyond the zone boundary).
A wholly skipped entrance intentionally fails admission. The sampler allows at most 35 studs
between observations and no gap over two seconds. These conservative first-seam
limits require route entries wide enough for normal walking and are not a general
movement anti-cheat. Short traversed segments are checked every ≤2 studs through
the OBB union so bends do not authorize straight shortcuts through private plots.

The source CurrentZone and respawn remain latched throughout transit. At the
destination entry, live identity and gates are rechecked, then only the tracked
zone, CurrentZone attribute and respawn change. There is no player pivot, velocity
reset or `heroes.Travel` call. Existing RegionalCombat.Sync consumes CurrentZone
on its normal CombatService step; scene ownership/reward adapters are unchanged.

HeroService extends its existing leader inWorld predicate only through admitted
`CanFollowWalking`. Trail, path and combat data are retained on ordinary crossing.
The existing follower >45-stud/stuck recovery is unchanged and remains a separate
runtime risk; no claim that five real followers never recover is made here.

Denied entry, revoked gate, invalid step, route failure or vertical escape uses
only a checked source safe point as an exceptional correction; this may invoke
the existing follower reset. If no valid floor/headroom exists, correction is
withheld and no destination is granted; recovery retries while the same context
remains current. Stale session/character contexts are discarded without moving
the replacement from that snapshot. Death leaves the latched source respawn;
normal Respawn owns later repositioning. Portal, visit, accepted local travel,
respawn and Remove clear transit. Existing shared-local snapshots take priority.

## Evidence and remaining acceptance

`tests/run_continuous_world_travel.luau` exercises the actual TravelService through
platform injection, including bidirectional zero-pivot/zero-velocity-write and
zero-follower-reset crossings, OBB rotation/height/invalid values, gates, stale
identity, rejected jumps/gaps, verified and blocked recovery, lifecycle cleanup,
local travel coexistence and optional compatibility. The existing
`tests/run_shared_local_travel.luau` remains the local-travel regression runner.
Controller owns main-runner integration; this change does not edit tests/run.luau.

Independent review found a source-floor recovery-filter issue; corrected by
including both source and surviving route geometry, with a dedicated regression.
Scoped compile/type checks and recorded test runs are local command evidence,
not real physics, networking, prompt traversal or progression acceptance.

Controller must verify both walking directions with one player plus five actual
followers, entry sampling at normal speed, real S13 geometry floor/clearance,
denied novice/release/private activity, source/destination respawn, safe recovery,
unchanged portal/charter/local-return paths, personal regional combat transition
and unchanged reward ownership. Streaming, multiplayer, stalls, performance and
human art approval remain pending. No Studio or Blender mutation was performed
by this source worker; no push, merge, release, purchase or production data write.
