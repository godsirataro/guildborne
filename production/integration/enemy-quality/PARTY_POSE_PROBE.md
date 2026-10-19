# Bounded party motion evidence collector

This is controller-run observation tooling, not a gameplay script. Installation
alone must not start recording. No commands, profile grants, input injection,
camera changes, animation writes or VFX creation are authorized by this probe.
No result is artistic approval or an automatic animation PASS.

## Installation and explicit arm

Use a fresh isolated Studio place with PlaceId/GameId zero and actual Memory
runtime, empty allowed DataStore universes and normal game bootstraps. Preserve
the controller's existing source verification and earned progression procedure.
The earlier earned Memory player was discarded at Stop Play; do not assume that
Warrior and Mage remain available. Earn them again or label a separately approved
fixture as synthetic. This probe cannot prepare actors or progression.

Install the exact `party_pose_probe.luau` as a ModuleScript named PartyPoseProbe
under ReplicatedStorage in the disposable controller-owned place. It is outside
the default Rojo project mapping. Use one module instance per run/context.
The controller checks the server Runtime before arming either context. The client
cannot independently read ServerScriptService Runtime: its explicit
`memoryVerifiedByController=true` records that attestation, not a security proof.
The server additionally checks its actual Runtime. Do not enable any runtime flag.

The selector observes the current owner Character and owned GuildborneHero models
whose ClassId is Mage, not every class or enemy. Delayed discovery watches only
plausible hero models (Mage name or GuildborneHero tag attribute) and the owner's
Character. Limits are six actor instances, 64 joints per actor sample/384 unique
joints, 128 discovery candidates and 512 unique VFX objects per context/run.
Crossing a discovery limit is explicitly incomplete evidence, not scene failure.

When an earned Warrior and Mage are present and ready, the controller explicitly
calls the following in the SERVER context, substituting the actual user ID and
a unique run ID (do not copy the placeholders unchanged):

```lua
shared.PartyPoseServer = require(game.ReplicatedStorage.PartyPoseProbe).start({
    armed = true, runId = "controller-chosen-unique-run", ownerUserId = ACTUAL_USER_ID,
    duration = 30, maxRecords = 10000,
})
```

Then explicitly arm the CLIENT context with the same run ID and owner:

```lua
shared.PartyPoseClient = require(game.ReplicatedStorage.PartyPoseProbe).start({
    armed = true, runId = "controller-chosen-unique-run", ownerUserId = ACTUAL_USER_ID,
    duration = 30, maxRecords = 10000, memoryVerifiedByController = true,
})
```

These are immediate setup calls. Do not keep ExecuteLuau waiting through the
capture or cleanup boundary. Do not alter camera type to obtain a clean trace.
Inspect both metadata records for readiness and overlapping capture times before
the actual F/Q or UI input. Keep actors within 90 studs of the current camera
(HeroAnimator culls at 90; skill VFX at 100). Preserve reduced-motion/quality
settings in the report rather than silently overriding them.

## Minimal native run

1. Capture idle reference frames and the actual owned actor/joint inventory.
   Player joints may be Motor6D or AnimationConstraint. Mage's original rig uses
   six Motor6Ds: RootJoint, Neck, both Shoulders and both Hips. Missing joints are
   missing evidence; never treat an empty watch list as motion success.
2. Use the real combat UI/input to obtain one accepted Warrior Power Strike and
   one Mage Fireball. Record failures such as NoTarget or Cooldown separately.
   Server action/counter records are authoritative observations; client replicas
   and effects cannot certify damage or rewards.
3. Require both actions inside the common server/client interval. Retain frames
   before, during and after each cast. ActionPose uses windup to .10 seconds,
   contact .24 and recovery through .62. The player overlay is multiplied with
   Animator locomotion, whereas Mage RootJoint/Neck have identity locomotion base.
   Compare actual joint/limb motion and event age; any motion alone is insufficient.
4. Record effect additions, later family/stage metadata readiness, and removals
   by the same run-local instance ID. Mage.Fireball has Charge/Travel/Impact;
   Power Strike can create a trail under the actual RightHand/Right Arm. Neither
   anonymous Workspace effects nor temporal proximity prove actor ownership.

Objects present at arm are `vfx_existing`, not new effects. Leaving Workspace is
`vfx_removed`, not proof of destruction; reparenting back is `vfx_returned` with
the same ID. Only actual disappearance plus the desired lifecycle observations
supports the scoped cleanup claim. Joint reference paths and root-relative limb
frames are retained; unsupported properties are explicit `UNAVAILABLE` values.
5. Finish only after the requested actions and their recovery/cleanup are observed
   within the deadline. Missing events, gaps, overflow or attribution ambiguity
   stay inconclusive for the corresponding claim. Do not renew the deadline or
   reuse old timestamps. A fresh retry is a separately identified run.

The normal camp uses real Character/Mage instances. NoviceTrialCastVisual is only
a VFX proxy; it has no character motors. In trials the player pose still applies
to Character while reading the arena's ActionAt. This collector's intended next
test is normal party combat, not a substitute trial acceptance.

## Retrieval, stop and evidence

The handles expose `metadata()`, `chunk(offset,count)` and `stop(reason)`.
Offsets are zero-based; chunk count is 1..200. Start with small chunks (e.g. five
records) because joint snapshots are larger than action records. Tool transport
can truncate even a valid collector chunk: parse every returned envelope and
inner JSON; retry that same range with a smaller count if needed. Preserve the
failed/truncated raw response rather than replacing it.

After the deadline, retrieve terminal metadata, then every sequence exactly once
through `collection.count`, separately for server/client. `collection.stopped`
is the terminal flag. Record gaps, overflows, discovery limits, cleanup errors
and coverage start/end. Verify the count and sequence order after reconstruction.
`collection.complete` is only the collector's duration/clock/gap/buffer predicate;
it does not override `captureIssues` or `discoveryOverflow`, and never means that
either requested skill, motion, VFX or reward passed. Preserve server and client
roles and the common run ID; instance IDs are local to their context.

If interrupted, call `stop("controller_stop")` on each active handle before
removing its shared key. Retrieve the terminal packet first; then clear
`shared.PartyPoseServer` / `shared.PartyPoseClient` in their respective contexts.
Stop Play after archiving. The probe disconnects its own listeners and does not
tear down gameplay controllers, actors or effects. Stop Play still discards the
Memory session and clears game-owned resources.

## Local verification and limits

`party_pose_probe_check.py --luau <absolute-luau-executable>` extracts the actual
marked pure collector and tests bounded append, sequence reconstruction, immutable
snapshots, gaps, invalid clocks, terminal behavior and chunk limits. This does not
execute Roblox connections, inspect native joints or prove effect cleanup.

Twelve local checks passed, including actual extracted discovery rejection of a
detached Character and preservation of its identity on a real return. Initial
and terminal frame gaps and zero-frame collection are separately tested. The
pure collector hash at this checkpoint is
`bfa278f99b13ba58918704cac106ab3860a262e5ce988078d3508cd1e630aa30`.
Probe compilation passed. The unchanged game baseline at cf6f2e0 passed 970 tests,
Rojo build, analysis/compile and repository checks via tools/validate.ps1; existing
GUI analysis warnings remain in the raw log. That baseline does not run this
out-of-project ModuleScript in Studio. Record the final commit/tree and immutable
targeted check receipts in the handoff. The controller's native run is pending.
Audio IDs remain unchanged; no audible playback, human quality, five-companion,
physical-device, cross-server or durable-save claim follows from this collector.
