# Read-only native party walking observer

Execute `capture.luau` once in the server MCP evaluator of the ready, owned,
unsaved Studio Memory party lab. It reads the actual player and exactly five
existing HeroService companions, sorted by AdventurerId; it creates no actors.
It uses the owned PersonalGuild/ Heroes folder directly, accepts exactly five
direct children, and fences the folder, actor objects, IDs and classes. GetChildren
allocates that folder's child list before checking its count; there is no world
descendant scan. The expected fixture has exactly five children.
It writes only the result table `_G.GuildborneWalkCapture` and maintains observer
connections. It does not move actors, call remotes, change attributes, profiles,
health, progression, rewards or gameplay state.

The result has version, scope, status, startedAt/endedAt, limits, ownerUserId,
threeRoadWalk, roster, events and samples. Each sample has server time `t`, zone,
walking context, respawn path and `actors` keyed by `player` or AdventurerId.
Actor records contain position `p`, assembly velocity `v`, anchored state,
Humanoid/Combat health, hero/combat states, RecoveryCount and ground evidence.
Vectors are three-element XYZ arrays. Missing attributes remain absent, never
invented zeroes. Ground evidence includes hit, vertical root-to-hit distance,
position, normal and instance path. Rays start three studs above each root and
extend 35 down, exclude all six actors and respect CanCollide. A hit can be a
collidable prop or roof: it is not automatically a valid walkable floor.

One initial sample is followed by at most 5 Hz sampling (no catch-up bursts),
for at most 1200 seconds and 6001 samples. First death/downing, actor identity
change, owner loss, lab invalidation, sampling error or a limit ends capture and
disconnects every observer connection. Events are terminal and therefore bounded
(at most six actor-down events plus one completion event). Stop Play also discards
the in-memory result. Export bounded pages before stopping. No instances or
connections are placed in the export table. Existing captures are refused; after
export and confirmed terminal status the controller may explicitly clear the
global to start another independent capture. To finish early and freeze export,
call `_G.GuildborneWalkStop()` from the server evaluator. This observer-only
function disconnects the observer, records MANUAL_STOP and removes its own global
handle; the serializable capture remains intact. It changes no gameplay state.

This is synthetic level-10 eligibility, not earned campaign admission. Recovery
counter increases confirm HeroService recovery. A position discontinuity without
that counter evidence has unknown cause (possibly portal/correction); it must not
be called proven recovery or continuous walking. A continuous trace, successful route arrival and five
followers are separate observations; none alone proves whole-game acceptance.
The observer cannot measure client rendering, physical-device performance,
human approval or cross-server behavior.
