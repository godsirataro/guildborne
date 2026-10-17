# Implemented pure contract and integration limits

`src/shared/Config/NpcLifeDefinitions.luau` defines the sixteen existing IDs, proposed stationary daily phases and distance thresholds. `src/shared/Data/NpcLifeSchedule.luau` is a dependency-injected pure constructor, not a service or runtime scheduler:

```luau
local life, problem = make(definitions, friendlyNpcs, catalog)
local canonicalId = life.resolve(stableIdOrExactLegacyName)
local projection, problem = life.sample(identity, nowSeconds, distance, previousTier, interactUntil)
```

Pass the existing FriendlyNpcs and actual Journal catalog. The constructor validates names/coordinates and refuses duplicate or ambiguous aliases. Journal hooks derive from actual definitions; they are sorted immutable references, not accepted quests or rewards. Hosts currently have no hooks. Mira and City Herald are outside this sixteen-identity adapter and must continue through the existing legacy path.

Time is supplied by the authoritative integration owner in seconds, with a proposed 86,400-second cycle: Rest 00:00, Work 06:00, Social 18:00, Rest 22:00. These are activity labels at the current anchor, not sleeping/unavailable states or implemented travel. Do not invent a real-time/day-length promise from the proposal. A later configured world clock needs explicit integration review.

`interactUntil` represents an existing server-authorized conversation deadline; Interact overrides the schedule, followed by 0.6 seconds Recover, then the current phase. The pure function does not own player reservations, replicate dialogue or authenticate the deadline. The consumer must use the established server prompt/session checks and bounded conversation timeout; client input must never supply authority here.

Near enters at 50 studs/exits at 65; Far enters at 160/exits at 140. Proposed update intervals are 0.1/0.5/5 seconds. These are scheduling advice requiring profiling, not measured budgets. A caller supplies the previous tier for hysteresis. The module itself schedules nothing and performs no pathfinding or Roblox instance operations.

Every projection preserves the original X/Z anchor and `accessible=true`, even in Far/Rest. `backgroundEnabled=false` is permission to suppress optional visual work only, never to remove a quest station. All `routeEnabled` values remain false. `poseOwner="Borin"` means keep the existing Borin motion adapter; other actors remain under FriendlyNpcAnimator. Root orientation/Y/collision and prompt references stay with existing builders.

Neither module stores new profile data, changes cosmetic race, grants items, activates quests, or enables population spawning. Integration and Studio observation are required before asserting visible behavior. The source definition, local tests, runtime wiring, Studio, device and human acceptance statuses remain independent.
