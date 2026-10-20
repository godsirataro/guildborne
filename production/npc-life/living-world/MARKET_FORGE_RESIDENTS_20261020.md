# Market stock runner and forge inspector — bounded review candidate

Base `ff81a4811edff84199fde495ae1e891e59ec98db`. Controller authorized up to
two ambient residents in the existing S17 file scope. Shared ledger v10 task
`living-world-npc-slice`, owner `s17-market-forge`. The earlier single-Adventurer
task brief is historical scope; this explicit continuation expands it by two
visual-only residents. No quest identity, reward, inventory or save writes.

## Distinct roles and source placement

| Resident | Appearance and visible job | Route/support |
| --- | --- | --- |
| Tavin Reed | Existing Archer R6 body, quiver/arrows removed, tan cloth bundle with straps and a held tally slate. Carries stock to the back of a stall, checks the slate during the endpoint wait, then returns to rest. Bundle is scenery throughout, not a delivered inventory item. | (340,-1080) → (340,-1070) → (330,-1070), reverse; endpoint faces (330,-1060). Market courtyard top Y=0.7. |
| Edda Flint | Existing Warrior R6 body with plate/pauldrons/ridge removed, cloth-colored torso, dark cap, apron, held steel sample and sliding gauge. Eight seconds measuring/looking down, six resting; no walking loop. | Fixed (370,-1040), facing north toward the workshop. Grass top Y=0.3. |

Names were checked against current source. Internal activity attributes
`MarketStockRun` and `ForgeInspection` select presentation; no debug GUI or new
interaction prompt is added. Neither actor receives NpcId, GuildborneHero, Tool,
quest/service registration or a reward path. Existing Adventurer and all named
quest actors retain their prior definitions and interaction positions.

Source survey: Market courtyard bounds X[245,355], Z[-1150,-1050]. Stall counter
at (330,-1060) spans X[324,336], Z[-1062.5,-1057.5], leaving 4.5 studs from the
endpoint radius-3 envelope. Exchange approach X=300 and forge approach X=410 are
outside this route. Inspector is 11 studs south of the rotated forge foundation
edge Z=-1029, with 8 studs between the radius-3 envelope and that edge. No new
ground furniture is placed. These are source-derived bounds, not native clearance.

Source references: CentralCityWorld ground, roads, courtyards, stalls and existing
actors; CityKit house/stall dimensions; CityLandscapeData; FriendlyNpcs anchors;
HeroRig body/joint/hand dimensions. Existing Merchant, Sela, Vaela, Rukk, Borin and
Craftsperson are untouched. Controller still owns native scene verification.

## Runtime behavior and limits

The existing resident runner now accepts per-resident anchors/support height and
derives its broadphase region from them. It retains measured foot offset/body
height, radius 3 plus 0.5 reserved for gait, bounded turns/speed/tick, blocker wait,
distance relevance and deterministic teardown. All visible town parts include
resident peers regardless of CanQuery/CanCollide. Players and heroes still use
whole-model bounds with a margin. No actor pushes a player or hero.

The pure station reducer shares the walking reducer's API and accepted simulation
clock. Blocked, irrelevant, invalid and destroyed ticks do not advance this clock.
Each actor has independent state. The inspector's jaw/head animation uses that
clock only while Inspect; legs/root stay fixed. Existing client culling and
Reduced Motion restore authored base joints, including the gauge jaw. Held-arm
base poses remain safe/static when motion is disabled. Failed startup validation
destroys a new resident, preventing an uninitialized model at the origin.

This remains three bounded resident controllers, each with a registry and sampled
heartbeat. It is not an optimized 410-NPC population scheduler. Real CPU/network,
streaming and physical-device budgets are unmeasured in this wave.

## Provenance and local evidence

All bodies derive from existing original `src/server/Services/HeroRig.luau`.
New bundle, straps, slate, apron, sample and gauge are original primitive geometry
authored in CentralCityWorld. No generated/downloaded asset, font, external mesh,
runtime asset ID, Blender job, paid provider or import is introduced. These are
legacy procedural R6 civilian studies; no claim of new modular R15 preset or fit
approval is made, and all 13 planned cosmetic presets remain unchanged.

`tests/run_city_resident_route.luau` runs 14 pure checks: eight previous route
checks plus station input/isolation, cycle, pause/resume, clock/destroy, market
route and six-actor supplied-bound obstruction. These mocks do not execute Roblox
instance collection, welding or rendering.

`python production/npc-life/living-world/check_resident_geometry.py` runs three
source-bound analytic checks for hand/gait radius, readable slate face and gauge
jaw/sample separation. It binds dimensions/angles from the actual source and
includes a failing-control horizontal arm angle, which would exceed radius 3.
This caught the startup silhouette issue before handoff. It does not substitute
for a native rig/assembly test. Full baseline and immutable receipt identity are
reported separately with the final candidate.

Independent review required lowering the original horizontal grip and moving
the slate marks from its underside. Both were corrected. Local scope checks were
renewed after expired own leases with workers stopped; no competing writer or
interactive session was taken over. Final handoff releases the current lease.

## Pending native acceptance — NOT_RUN by S17

- Both new residents actually construct at their assigned anchors, with matching
  custom silhouettes and safe tool/hand contact; no origin stray, floating prop,
  detached hand or gauge/sample intersection. Inspect the full cycle and all
  headings, not just a still image.
- Tavin completes a carry/check/return/rest cycle with feet on Y=0.7; Edda's feet
  remain on Y=0.3 across Inspect/Rest. Verify original Adventurer regression.
- Actual scene blockers, including query-false furniture and peers, pause/resume
  correctly. Test real earned player+five heroes, a second party, crossings and
  spawn/despawn. Supplied-box tests are not party or multiplayer acceptance.
- Actual Reduced Motion UI, camera cull/return, absence of all nearby players,
  streaming, respawn, actor/town removal and rebuild restore joints and clean up
  connections without replaying elapsed work or leaking instances.
- Existing quest actors/prompts/navigation remain available; ordinary earned
  gameplay and no duplicate reward regression. Measure performance separately.

Controller owns Studio, integration and native acceptance. No Studio/Blender,
provider, upload, publishing, PR, push or merge performed by S17 in this wave.
