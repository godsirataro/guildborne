# One existing resident route — review candidate

Base: `cf6f2e0`. Ledger: shared `four-session-v10.sqlite3`, task
`living-world-npc-slice`, owner `s17-resident-route`. This is a bounded runtime
slice, not completion of the Living World population proposal.

The existing nonquest R6 Mage named Adventurer starts at (-110,-830), walks
through (-110,-828) to (-184,-828), looks toward the board at (-190,-830), waits
six seconds, and returns along the exact reverse path. Home rest is eight
seconds. No named quest actor, stable quest ID, save, reward, population count,
appearance preset or progression rule changes.

CentralCityWorld owns one heartbeat connection and tears down its registries
and listeners when the actor/town is destroyed or removed. It advances at most
0.1 seconds per sampled heartbeat, discards stall debt, moves at most 3 studs/s,
and turns at most 90 degrees/s without translation during turns. No player
within 160 studs pauses both travel and route time before geometry work.

Collision uses conservative swept expanded world bounds, including visible
noncollidable/nonqueryable town parts and full model bounds of players and
GuildborneHero models. It does not rely on overlap query eligibility. Dynamic
roots are not used to discard remote accessories. Invalid geometry, excessive
counts, missing character roots and unsupported ground pause the route. Limits:
100 players, 500 hero registry entries, 16,384 town parts, 400 static blocker
boxes and 512 total boxes. The current hero service sets its identifying
attribute before parenting; changing that contract requires a collector update.

The reviewed support surface is Y=0.7. Root height is measured from actual R6
legs/boots; body height includes the hat. A 3-stud horizontal envelope includes
0.5 studs reserved for the local gait, and a changed larger rig fails startup.
Flat support is checked at both ends of every short step. This is a deliberately
conservative single courtyard route, not a general navigation system.

FriendlyNpcAnimator owns the R6 joint presentation. It interpolates only travel
already observed from the server, with a bounded render-time increment. Blocked
actors stop the gait immediately. Leg/boot corner bounds determine a small
vertical hip correction to avoid dipping below the reviewed floor. Reduced
Motion and distance culling restore base C0, and the controller's existing
removal cleanup restores motors. This is not a claim of foot planting, imported
animation quality or physical-device performance.

## Local verification

The standalone `tests/run_city_resident_route.luau` exercises eight cases:
input ownership and validation; corrected versus obstructed corridor; swept
and turning blockers; malformed geometry; blocked/relevance pause and resume;
proposal immutability and dt clamp; exact reverse/endpoints/speed/turn limits;
invalid dt and destruction. These are pure reducer tests with supplied boxes,
not tests of native world collection or rendering. The normal full repository
baseline must also pass on the clean candidate. Exact commit/tree and immutable
receipt are supplied separately in the Controller handoff.

Independent review identified discrete gait updates and insufficient dynamic
center validation. Both were corrected before the candidate handoff. Review
is not task acceptance.

## Pending Controller native acceptance — NOT_RUN by S17

- Observe a complete outbound/look/wait/reverse/home cycle on ordinary travel.
  Record actual root/foot positions, bounded displacement/turn, hat clearance,
  visible gait quality and board facing. No synthetic relocation as travel proof.
- Place a visible CanQuery=false/CanCollide=false blocker in the route, including
  a turn envelope and overhead obstruction. Confirm exact wait and bounded resume
  after removal, no teleport, no furniture penetration, and support-loss stop.
- Walk the route with a real player plus five earned heroes; include another
  player's party, crossing/interception, nonqueryable limbs and nearby spawns.
  Check all party bounds and prompt/navigation usability, not just root clearance.
- Move all players beyond relevance range and return. Verify route timers freeze,
  no catch-up jump, and no geometry work while irrelevant. Measure runtime cost
  at the normal town population and with the party; local counts are not profiling.
- Use the actual Reduced Motion setting and normal camera distance transitions.
  Confirm base C0 restoration and stable feet, then smooth recovery. Check actor
  streaming/removal, player respawn, hero spawn/despawn and town/actor destruction
  for stale listeners, residual gait or errors.
- Confirm all 16 named quest actors remain stationary/available and a genuine
  existing offered quest can be accepted/turned in without duplicate rewards.

No Studio, Blender, Roblox publication, paid import, production DataStore write,
push or merge was performed by this slice. Controller owns native acceptance and
integration. Source implementation and local test results remain separate facts.
