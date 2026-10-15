# Optional shared combat coordinator — Stage B

Status: source implemented; eight focused pure coordinator checks passed. Independent policy review reran all eight checks and found no remaining actionable blocker in this scope. Runtime integration, actual rigs, multiplayer movement, and human acceptance remain pending. This does not enable a zone or award shared rewards.

## Injection and ownership

HeroService accepts a seventh optional argument:

```luau
{
 Scene = {plot = sceneModel, origin = originVector3, enemies = {serverScout}},
 Session = function(player) -- exact existing PDS session, stable identity
  -- Must first verify this original Player is still the current connected player.
  -- Return only this player's actual server session; never build a new view table.
  if Players:GetPlayerByUserId(player.UserId)~=player then return nil end
  return Data.Sessions[player.UserId]
 end,
 ContainsPosition = function(position) -- explicit trusted candidate geometry
  local p = boundsCFrame:PointToObjectSpace(position)
  return math.abs(p.X)<=halfSize.X and math.abs(p.Y)<=halfSize.Y and math.abs(p.Z)<=halfSize.Z
 end,
 Observe = nonyieldEligibilitySink, -- optional, never storage/network IO
 Recover = nonyieldRecoverySink, -- optional; distinguish enemy reset from hero recovery
 Status = function(status,reason) -- optional, nonyield logging/status
 end,
}
```

The caller supplies the existing Data service and Players dependency; this example follows the current Data.Sessions lookup. No default injection or region-name permission exists. The context checks explicit geometry and registry identity. CombatSpace remains responsible for LOS. Current Stage A movement uses Scene.origin with X +/-34 and Z +49..112 (Y +3); align the candidate floor, scout and geometry with those existing bounds. Session must retain exact reference, token, epoch, nonclosing record and Active/Saving/Degraded state. Saving/Degraded retain physical following only for a valid committed session and physically alive owner; mentor/tower/geometry exits still detach. Network command gates are unchanged.

Coordinator owns one registry encounter and registers the external scene enemies. It never assigns them to personal `s.enemies`, awards rewards, respawns scouts or destroys the supplied scene models. The outer scene owner must destroy the scene only after `HeroService.CloseShared()`. `SharedStatus()` exposes Ready, Closed or a fault reason. Plot `SharedCombatStatus` reflects per-owner preparation status.

Every heartbeat prepares all owners, reconciles registry attachment, performs one shared enemy phase, each owner phase, then follower movement. Personal combat steps are suppressed while claimed. Camp models are temporarily unparented; regional encounters are suspended without destroying receipt state and restored on exit. A fault revokes proofs and keeps in-bounds owners claimed; it never silently replays personal combat. Capacity is a provisional fixture bound of 16 owners / 96 actors, not a public population claim.

## Incarnations and recovery

Session, token, epoch, character, root, roster identity and slot changes revoke registration and phase capabilities before fresh shallow wrappers replace player/hero combat actors. HP, cooldowns, attack times, downed and tactic scalars survive; cooldown maps are copied, target/allies/taunt/evasion links cleared. Existing rig/model refs remain. Current prepared actors are sorted for stable registration. Missing profile heroes are removed only with this optional integration enabled. Character/travel/mentor/remove detach before their pose mutations. Owner removal cannot destroy shared scout models.

Command and tick mutation locks reject reentrant preparation; an Observe callback may revoke proof but cannot clone an actor before the ability finishes publishing its spent cooldown. Sinks must only update nonyield eligibility state; defer settlement IO to an external coordinator.

## Verification

- `tests/run_shared_combat_coordinator.luau`: eight pure checks using actual identity registry, encounter runtime and fenced phases; CombatService hydration is mocked, so this is not a real-rig acceptance result.
- Coverage: two repeated-ID owners with five companions each; once-only scout tick; Saving/Degraded beyond grace; inactive Active rejected; epoch/roster/character replacement; old Player removal; mentor/death detach; fault latch; reentrant manual callback; seven owners with full companion rosters; close leaves external scene models intact.
- Scoped Luau LSP: `build/shared-coordinator-analysis.log`.
- Compile log: `build/shared-coordinator-compile.log`.
- Focused raw test log: `build/shared-coordinator-tests.log`.

Next acceptance: inject only in isolated Memory candidate geometry, create two real player/hero rigs, verify shared scout damage/LOS, five-companion movement, saving-state following, death/travel/mentor transitions, individual owner disconnect and full teardown. Actual clients and device performance remain separate gates. No new profile schema, reward grant, remote action, cloud write or publish is included.


## GL-2.0 P1 follower stale-path repair - 2026-10-15

Local source change, not P1 or Studio acceptance. `HeroService.recover` previously
cleared an installed path but left the generation captured by a yielding
`ComputeAsync` valid. Its later completion could restore waypoints from before
the recovery. The same gap existed in character replacement, invalid-owner
parking, history resets/teleports, arrival and clear-line walking.

These transitions now use one local invalidation helper, also used by existing
Sync, Travel and BeginMentor invalidations. Recovery cancels the old Humanoid
MoveTo and records the recovered position. The pending request retains ownership
of `computing` until completion, so invalidation cannot open parallel requests.
Session removal, shared detach, combat evasion and manual combat control already
invalidate their generations. EndMentor is protected by BeginMentor invalidation
and suspended mentor heartbeats.

Observed checks on the dirty working source:

- Eight existing pure coordinator checks pass; these do not execute HeroService.
- Ten separate source-harness checks execute extracted, unmodified HeroService
  movement/character/reset/parking closures with coroutine-controlled
  ComputeAsync, mock vectors, rays, humanoid and model. They cover accepted
  current completion, recovery plus serialized retry, distance recovery,
  arrival, clear LOS, character replacement without shared mode, invalid-owner
  parking, history reset, owner teleport and dead-session completion rejection.
- Removing only recovery's invalidation from the generated harness makes the
  recovery regression fail (exit 1). No runtime source was changed for that
  negative control.
- Scoped Roblox-aware Luau analysis and compilation pass for HeroService and
  the two focused test files. Analysis reports only the CLI file-watch warning.
- HeroService SHA256 at this check:
  `9524acc7dea1ceabd87911ad1742f169e0162ccf93a37a454d6c5ec27e72aae6`.

Local raw stdout/stderr pairs (empty streams retained) are under
`build/agentic/gl2_hero_path{,_analysis,_compile,_mutant}.{stdout,stderr}.log`.
Run `python build/agentic/gl2_hero_path_harness.py` to regenerate and rerun the
source harness while this local build directory is available. The ordinary
`tests/run_shared_combat_coordinator.luau` entrypoint still runs only its eight
coordinator checks; it returns an optional harness entrypoint for the ten path
checks. The standard standalone invocation does not run those ten path checks.

For a clean checkout, recreate the local harness using the following Python,
run from the repository root. Production closures are extracted; the mocks and
assertions live in the scoped test file.

```python
from pathlib import Path
import subprocess

root = Path.cwd()
text = (root / 'src/server/Services/HeroService.luau').read_text(encoding='utf-8')
def between(start, end):
    assert text.count(start) == 1, start
    return text.split(start, 1)[1].split(end, 1)[0]
invalidate = 'local function invalidatePath' + between('local function invalidatePath', 'local function appearance')
movement = '\tlocal function recover' + between('\tlocal function recover', '\tlocal elapsed=0')
character = '\tfunction service.Character' + between('\tfunction service.Character', '\tlocal function makeHero')
reset = '\t\t\t\tif s.reset or ' + between('\t\t\t\tif s.reset or ', '\n\t\t\t\tif #s.history==0')
park = between('\t\t\t\t\tif not valid then\n', '\n\t\t\t\t\telse')
program = '''local run=require("../../tests/run_shared_combat_coordinator")
run(function(env)
local V,Vector3,CFrame,Enum,workspace,Pathfinding,task=env.V,env.Vector3,env.CFrame,env.Enum,env.workspace,env.Pathfinding,env.task
local s,h,root,sessions=env.s,env.h,env.root,env.sessions
local destroyed,shared=false,nil
local service={}
local function appearance()end
''' + invalidate + character + movement + '''
return {walk=walk,recover=recover,character=service.Character,reset=function()
''' + reset + '''
end,park=function()
''' + park + '''
end}
end)
'''
output = root / 'build/agentic/gl2_hero_path_harness.luau'
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(program, encoding='utf-8')
result = subprocess.run([str(root / '.tools/luau/luau.exe'), str(output)], capture_output=True)
(output.parent / 'gl2_hero_path.stdout.log').write_bytes(result.stdout)
(output.parent / 'gl2_hero_path.stderr.log').write_bytes(result.stderr)
print(result.stdout.decode(), end='')
print(result.stderr.decode(), end='')
raise SystemExit(result.returncode)
```

Pending actual Studio acceptance: induce delayed/obstructed path computation,
then recover, respawn, deactivate/reactivate, change floors and travel while five
real companions follow; confirm no return to old waypoints, no extra active path
requests and natural formation/door/stair movement. The local harness does not
exercise Roblox scheduling, real PathfindingService, full Heartbeat integration,
collision, animation, multiplayer load or physical-device performance. No Studio
was connected for this repair; the full baseline is coordinated separately.
