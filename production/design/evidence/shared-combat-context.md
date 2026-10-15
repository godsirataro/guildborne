# Shared combat context — Stage A

Optional source API only. HeroService remains unwired, and no existing region switches combat mode. No cloud, settlement/profile payouts, public activation or multiplayer acceptance.

## Constructor and capabilities

Existing CombatService constructor accepts an optional sixth argument:

```luau
local context = {
    SceneToken = {}, -- opaque server scene incarnation
    EncounterToken = registryEncounter,
    Scene = {plot = sceneFolder, origin = origin, enemies = registeredScouts},
    Policy = registry.policy(),
    Contains = function(actor) return serverGeometryContains(actor.root.Position) end,
    IsCurrent = function(ownerId, attachmentSession) return currentAttachment(ownerId, attachmentSession) end,
    Observe = function(event, source, target, value) -- optional synchronous eligibility sink
    end,
    Recover = function(actor, actualHPIncrease) -- optional synchronous neutral recovery sink
    end,
}
local shared = CombatService(templates, nil, nil, nil, combatObserver, context)
```

SceneToken and EncounterToken must remain the exact captured objects. Contains and IsCurrent are guarded nonyield predicates. IsCurrent represents exact live connection/attachment ownership, including revocation for replacement, travel and mentor entry; a transient same-session save must not itself replace the membership. Network authority still governs whether requests may be sent. Observe/Recover are synchronous nonyield server sinks, separate from deferred analytics combatObserver. They may update an in-memory ledger or freeze a result, never perform storage I/O. A yielding/throwing sink or predicate faults the context closed; partial effects are not replayed. The caller must surface returned failures and explicitly close/reset the candidate.

A shared instance exposes:

- PrepareSharedOwner(player, ownerState, leaderRoot, valid, stamp, walk, attachmentSession) -> handle, ownActors; failure -> nil, reason.
- RegisterSharedOwner(handle) -> boolean, reason.
- StepSharedEnemies(stamp) -> boolean, reason.
- StepSharedOwner(handle) -> boolean, reason.
- FinishSharedOwner(handle) -> boolean, reason.
- DetachSharedOwner(ownerId, exactAttachmentSession), CloseShared().
- Existing PlayerAction(ownerState, action, now, actorId) retains its owned-companion command checks and adds current shared proof/bounds. No client coordinates, targets, membership tokens or phase handles.

Preparation is preflighted before hydration: stale/replayed stamps or phase execution reject before touching owner state. Successful preparation hydrates existing actors/stats/build/root and copies an own roster; it deliberately does not require prior registration. The external coordinator then joins those exact actor objects through SharedEncounterRuntime/registry before RegisterSharedOwner. Registration validates one owner registration token, exact encounter, prepared identities and the literal player plus at most five companions. Call preparation and registration for all current owners before one enemy phase, followed by each owner phase and finish. Every handle binds owner, attachment session, scene/encounter and stamp; phase consumption precedes callback execution. A global callback lock rejects reentrant or concurrent preparation/registration/phases and manual actions; detach/close remain available to revoke. An old yielded callback cannot regain access through a newer attachment.

## Isolation and behavior

The optional instance owns separate strict Target/Damage/Abilities closures. Both actors must satisfy registry proof, scene bounds and current owner attachment for hostility or healing; Damage rechecks the strict policy at effect time. Own group heal primary selection and actor.allies stay inside the owning six. Single-target heal may choose from up to96 registered shared actors. These are fixture safety bounds, not measured production capacity.

Shared mode skips Regional.Sync/Step/Dodge, legacy participation/reward callbacks, tower completion and automatic respawn. Add/TowerSync/ordinary Step do no shared work; use the phase API. OwnerState.enemies is never replaced. Shared scout models belong to the scene/coordinator and are not destroyed by shared Remove. HeroService.Remove is unchanged and must not receive shared enemies until a later reviewed coordinator integration separates scene ownership.

Only ordinary non-template, non-boss, non-tower EnemyService scouts are accepted for this stage. Their enemy AI and model publication run once per stamp. Corpse hiding remains; no shared respawn or payouts happen. Hero movement/commands retain existing logic with shared scene origin for combat movement bounds. Shared downed player recovery does not teleport to a legacy personal plot. Passive, downed and enemy home-reset HP increases report their actual positive delta once to Recover. The sink receives actor.kind and must route enemy resets separately from hero-only participation recovery; do not blindly feed enemy actors to a hero-only ledger. Leftover towerPosition does not trigger a shared-mode teleport.

Preparation preserves existing HP/cooldowns (stats may clamp HP to a lower maximum as before). This stage does not create actor wrappers or own registry detach. The future coordinator must revoke registry and phase memberships before creating fresh wrappers on roster/session/scene incarnations, preserve HP/cooldowns, clear stale targets, and never revive old registered actor objects.

## Studio fixture recipe for root

1. Use an isolated local candidate with existing GuildborneWorld geometry and real HeroRig/player character models. Keep the running production HeroService out of the synthetic rigs; one pose/controller owns each rig.
2. Create one scene folder/origin and ordinary EnemyService.create scouts with owner0. Create an identity registry encounter and register all scouts. Context.Contains must check the candidate's actual XYZ boundary, not CurrentZone alone. Use current server attachment tokens in IsCurrent.
3. Construct two server-only owner states shaped like existing HeroService sessions: plot/origin/heroes, characterData, playerLoadout, playerBuild, extra, active/alive and raycast params; each hero has the normal model/root/humanoid/movement fields. CombatService.Sync populates each hero combat record using existing committed-style descriptors. PrepareSharedOwner hydrates the player. Provide a walk callback that operates only that owner's rigs.
4. Prepare both owners for stamp1; register returned actor objects using the registry or Runtime.Join; RegisterSharedOwner both handles. Then StepSharedEnemies(1), StepSharedOwner/FinishSharedOwner once per handle. Assert all returns and counts. A repeat enemy/owner/finish phase must reject.
5. Exercise PlayerAction for owned player/companion, foreign actor rejection, group versus single healing, shared threat with repeated local IDs, boundary exit, LOS wall, one owner detach and stale handle. Verify the other owner/scouts remain present and HP/cooldowns never refill on preparation.
6. CloseShared plus registry/runtime Close, destroy only fixture-owned models and connections. Report fixture as synthetic actual rigs, never as two real clients.

## Evidence

build/shared-context-tests.log:11 pure phase checks passed using real identity/targeting/damage and group ability modules. Covers prepare-before-register, consume-once order, shared/own candidates, effect-time bounds, session/stamp/scene invalidation, incomplete/mixed registration,96 support bound, callback failure/yield/reentry, nonyield predicates/sinks, and group heal cap.

build/shared-context-analysis.log: scoped Roblox-aware Luau analysis passed. build/shared-context-compile.log: four scoped modules/tests compiled. Root owns full baseline and actual Studio fixture. HeroService scheduling, fresh-wrapper coordinator, production activation and multiplayer/cloud/device acceptance remain pending.

## Draft executable fixture (not yet run)

Root may materialize this in its integration scope. It uses two synthetic owner objects and real rigs, not network clients. No grants or saved progression are involved.

```luau
assert(game.PlaceId==0 and game.GameId==0)
local server=game.ServerScriptService.Server
assert(require(server.Config.Runtime).StudioPersistence=="Memory")
local world=workspace.GuildborneWorld
local Rig=require(server.Services.HeroRig)
local Identity=require(server.Systems.SharedEncounterIdentity)
local templates=game.ServerStorage.GuildborneArtKit
local root,shared,registry,encounter
local result={synthetic=true,profileWrites=0,owners=2,companionsPerOwner=5}
local ok,problem=pcall(function()
 root=Instance.new("Model");root.Name="SharedCombatContextFixture";root.Parent=world
 local origin=Vector3.new(5000,0,5000)
 local ground=Instance.new("Part");ground.Anchored=true;ground.Size=Vector3.new(100,2,150);ground.Position=origin+Vector3.new(0,-1,70);ground.Parent=root
 registry=Identity();encounter=assert(registry.create())
 local enemyFactory=require(server.Services.EnemyService)(templates)
 local spawned=enemyFactory.create(root,origin,0)
 local scout=spawned[1];for i=2,#spawned do spawned[i].model:Destroy()end
 scout.plot=root;scout.home=origin+Vector3.new(0,3,80);scout.model:PivotTo(CFrame.new(scout.home))
 assert(registry.addEnemy(encounter,scout))
 local scene={plot=root,origin=origin,enemies={scout},alive=true}
 local live,owners={},{}
 local recovered,observed=0,0
 local context={SceneToken={},EncounterToken=encounter,Scene=scene,Policy=registry.policy(),
  Contains=function(actor)
   local p=actor.root.Position-origin
   return actor.model.Parent~=nil and math.abs(p.X)<45 and p.Y>0 and p.Y<40 and p.Z>45 and p.Z<115
  end,
  IsCurrent=function(id,session)return live[id]==session end,
  Observe=function()observed+=1 end,
  Recover=function(actor,amount)assert(amount>0);if actor.kind=="Hero"then recovered+=amount end end}
 shared=require(server.Services.CombatService)(templates,function()error("Legacy reward called")end,function()error("Tower reward called")end,nil,nil,context)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={ground}
 local classes={"Warrior","Knight","Archer","Mage","Priest"}
 for index=1,2 do
  local id=-91900-index;local char=Rig.Build("Warrior");char.Parent=root;char:PivotTo(CFrame.new(origin+Vector3.new((index-1)*4,3,70)))
  local player={UserId=id,Character=char,GetAttribute=function()return nil end,SetAttribute=function()end}
  local state={origin=origin,plot=root,params=params,alive=true,active=true,heroes={},enemies={},characterData={classId="Warrior",level=10,xp=0,raceId="Human"},playerBuild={tier=1,skills={}},playerLoadout={}}
  for slot,class in ipairs(classes)do
   local model=Rig.Build(class);model.Parent=root;model:PivotTo(CFrame.new(origin+Vector3.new((index-1)*10+slot,3,68)))
   local hero={model=model,root=model.PrimaryPart,humanoid=model:FindFirstChildOfClass("Humanoid"),state="Following",slot=slot,generation=0,home=model:GetPivot()}
   state.heroes["a:"..class]=hero
   shared.Sync(hero,{id="a:"..class,class=class,level=10,state="Following",build={tier=1,skills={}}},player,state)
  end
  local session={};live[id]=session;owners[index]={player=player,state=state,session=session}
 end
 local function walk(_state,hero,goal)hero.humanoid:MoveTo(goal)end
 local stamp=os.clock()
 for _,o in ipairs(owners)do
  local handle,actors=shared.PrepareSharedOwner(o.player,o.state,o.player.Character.PrimaryPart,true,stamp,walk,o.session)
  assert(handle,tostring(actors));o.handle=handle;o.actors=actors;assert(#actors==6)
  o.registration=assert(registry.addOwner(encounter,o.player.UserId))
  for _,actor in ipairs(actors)do assert(registry.addActor(encounter,o.registration,actor))end
  assert(shared.RegisterSharedOwner(handle))
  for _,hero in pairs(o.state.heroes)do hero.combat.order="Hold";hero.combat.holdPoint=hero.root.Position end
 end
 assert(owners[1].actors[1]~=owners[2].actors[1])
 assert(shared.StepSharedEnemies(stamp));assert(not shared.StepSharedEnemies(stamp))
 for _,o in ipairs(owners)do assert(shared.StepSharedOwner(o.handle));assert(not shared.StepSharedOwner(o.handle));assert(shared.FinishSharedOwner(o.handle));assert(not shared.FinishSharedOwner(o.handle));assert(#o.state.enemies==0)end
 result.oncePerStamp=true
 local first=owners[1];local actor=first.state.heroes["a:Warrior"].combat
 actor.health=actor.stats.MaxHealth-7;actor.cooldowns.power_strike=stamp+100
 local hp=actor.health
 local nextHandle=assert(shared.PrepareSharedOwner(first.player,first.state,first.player.Character.PrimaryPart,true,stamp+1,walk,first.session))
 assert(actor.health==hp and actor.cooldowns.power_strike==stamp+100)
 assert(not shared.StepSharedOwner(first.handle));assert(shared.RegisterSharedOwner(nextHandle))
 result.preserveHealthCooldowns=true
 local accepted=shared.PlayerAction(first.state,"Hold",stamp+1,"a:Warrior");assert(accepted)
 first.player.Character:PivotTo(CFrame.new(origin+Vector3.new(100,3,70)))
 assert(not shared.PlayerAction(first.state,"Hold",stamp+1,"a:Warrior"));first.player.Character:PivotTo(CFrame.new(origin+Vector3.new(0,3,70)))
 live[first.player.UserId]=nil
 assert(not shared.PlayerAction(first.state,"Hold",stamp+1,"a:Warrior"))
 shared.DetachSharedOwner(first.player.UserId,first.session);registry.removeOwner(first.registration)
 assert(not shared.StepSharedOwner(nextHandle));assert(scout.model.Parent==root)
 assert(shared.PlayerAction(owners[2].state,"Hold",stamp+1,"a:Warrior"))
 result.detachRetainsOtherOwner=true;result.boundsAndCurrentFence=true
 result.observedEvents=observed;result.neutralHeroRecovery=recovered
end)
if shared then shared.CloseShared()end
if registry and encounter then registry.close(encounter)end
if root then root:Destroy()end
result.ok=ok;result.problem=if ok then nil else tostring(problem)
result.cleanup=world:FindFirstChild("SharedCombatContextFixture")==nil
return result
```

The fixture uses Registry signatures `create() -> encounter`, `addOwner(encounter, userId) -> ownerToken`, `addActor(encounter, ownerToken, actor)`, `addEnemy(encounter, actor)`, `removeOwner(ownerToken)`, `close(encounter)`. Identity actor wrappers must be fresh if a detached owner is reattached. Movement dependencies are invoked through a nonyield guard; stale proof after an Observe/Recover detach stops later movement and model publication.

## Shared downed recovery before terminal corpse cleanup

A source review of the observed single-enemy death fault found that terminal completion must not stop existing owner recovery: a domain-downed leader has movement set to zero until normal recovery runs. Shared CombatService now defers corpse hiding while gathered registered support contains any actor with health <= 0. The existing recovery remains authoritative and unchanged. After recovery raises HP, the next enemy phase can hide the corpse; the same tick's owner phase restores movement before Coordinator completes. Private/default combat retains its original two-second cleanup. Detached registrations are absent from support and cannot hold cleanup open.

Local evidence: 12 phase checks PASS, including actual membership support retaining domain-downed/inactive actors and excluding retired owners; 10 reward/coordinator-binding and 8 coordinator checks PASS. All four changed source/test files compile and pass scoped Roblox-aware analysis. No engine claim: downed leader >10-second recovery, physical WalkSpeed/Jump restoration before Completed, normal two-second cleanup and earned-team replay remain parent Studio acceptance gates. Independent review pending.
Independent policy_review source review PASS; reviewer independently reran all 12 phase, 10 reward-binding and 8 coordinator checks. CombatService SHA256 `9ff6a0b6c99defc93961f965a0eff88b28f5b30d441da0cd6fe253aaaca7a5d7`. Engine recovery remains pending.
