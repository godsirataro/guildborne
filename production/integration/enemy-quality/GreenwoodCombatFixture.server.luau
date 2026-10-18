--!strict
-- Disposable unsaved Studio server only; install beside the real Server modules.
-- Disable both normal bootstraps BEFORE Play and install the paired client observer.
-- Synthetic Knight/empty roster, controlled placement, actual service damage.
-- No earned progression, reward persistence, walking, device or release acceptance.
-- Stop Play is REQUIRED final teardown: TravelService has no complete Destroy API;
-- collision groups and cosmetic character changes belong to this disposable session.
local Run=game:GetService("RunService")
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Lighting=game:GetService("Lighting")
assert(Run:IsServer() and Run:IsStudio() and game.PlaceId==0 and game.GameId==0,"Disposable unsaved Studio server only")
local server=game.ServerScriptService:WaitForChild("Server")
local bootstrap=server:FindFirstChild("ServerBootstrap")
assert(bootstrap and bootstrap:IsA("Script") and bootstrap.Disabled,"Disable normal ServerBootstrap before Play")
local runtime=require(server.Config.Runtime)
assert(runtime.StudioPersistence=="Memory" and next(runtime.AllowedDataStoreUniverses)==nil,"Memory with no allowed DataStore universes required")
assert(not workspace:FindFirstChild("GuildborneWorld") and not workspace:FindFirstChild("GreenwoodCombatFixture"),"Existing world/fixture refused")
assert(not game:GetService("ServerStorage"):FindFirstChild("GuildborneArtKit"),"Existing art/runtime refused")
local fixture=Instance.new("Folder");fixture.Name="GreenwoodCombatFixture";fixture.Parent=workspace
local report=Instance.new("StringValue");report.Name="Report";report.Parent=fixture
local status=Instance.new("RemoteEvent");status.Name="ClientStatus";status.Parent=fixture
local result:any={status="RUNNING",scope="SYNTHETIC_REAL_SERVICE_COMBAT",roster={},rewardCalls={},scenarios={},commands={},samples={},clientEvidence="PENDING"}
local function save()report.Value=Http:JSONEncode(result)end
local function phase(name:string)fixture:SetAttribute("Phase",name);save()end
local function waitFor(label:string,seconds:number,predicate:()->boolean)
    local deadline=os.clock()+seconds
    repeat if predicate() then return end;task.wait(.02) until os.clock()>deadline
    error("TIMEOUT: "..label)
end
local owner:Player?=nil
local world:any=nil
local constructionStarted=false
local character:Model?=nil
local root:BasePart?=nil
local originalPivot:CFrame?=nil
local originalAnchored=false
local originalZone:any=nil
local originalSpawn:SpawnLocation?=nil
local connection:RBXScriptConnection?=nil
local ready=false;local finished=false
local oldLighting:any={}
for _,key in ipairs({"ClockTime","Brightness","Ambient","OutdoorAmbient","ColorShift_Top","GlobalShadows","EnvironmentDiffuseScale","EnvironmentSpecularScale"}) do oldLighting[key]=(Lighting :: any)[key] end
local oldStorage:{[Instance]:boolean}={}
for _,item in ipairs(game.ServerStorage:GetChildren()) do oldStorage[item]=true end
local oldLightChildren:{[Instance]:boolean}={}
for _,item in ipairs(Lighting:GetChildren()) do oldLightChildren[item]=true end
save()
local ok,problem=xpcall(function()
    waitFor("single local player",20,function()return #Players:GetPlayers()>0 end)
    assert(#Players:GetPlayers()==1,"Exactly one disposable player required")
    local player=Players:GetPlayers()[1];owner=player
    fixture:SetAttribute("OwnerUserId",player.UserId)
    waitFor("character",20,function()return player.Character~=nil and player.Character:FindFirstChild("HumanoidRootPart")~=nil end)
    local c=player.Character :: Model;character=c
    local r=c:FindFirstChild("HumanoidRootPart") :: BasePart;root=r
    local humanoid=c:FindFirstChildOfClass("Humanoid") :: Humanoid
    assert(humanoid and humanoid.Health>0,"Live disposable character required")
    assert(c:GetAttribute("GuildbornePlayer")==nil and c:GetAttribute("CombatHealth")==nil and c:GetAttribute("ClassId")==nil,"Existing earned/runtime character refused")
    assert(player:GetAttribute("CurrentZone")==nil,"Existing travel/session refused")
    originalPivot=c:GetPivot();originalAnchored=r.Anchored;originalZone=player:GetAttribute("CurrentZone");originalSpawn=player.RespawnLocation
    connection=status.OnServerEvent:Connect(function(sender:Player,kind:any,payload:any)
        if sender~=player then return end
        if kind=="Ready" and fixture:GetAttribute("Ready")==true then ready=true
        elseif not finished and kind=="Finished" and fixture:GetAttribute("Phase")=="Finished" and type(payload)=="string" and #payload<=512000 then
            local value=Instance.new("StringValue");value.Name="UntrustedClientReport";value.Value=payload;value.Parent=fixture
            finished=true;result.clientEvidence="RECEIVED_UNTRUSTED_COSMETIC_ONLY"
        end
    end)
    local shared=game.ReplicatedStorage.Shared
    local content=require(server.Config.Content)
    local expansion=require(shared.Data.Expansion)
    local gear=require(shared.Data.Equipment)(content,expansion)
    local schema=require(server.Systems.ProfileSchema)(content,require(shared.Util.TableUtil),gear,expansion)
    local data=schema.new(player.UserId,1).data
    data.character.classId="Knight";data.character.level=60;data.character.xp=0
    data.party.adventurerIds={};data.adventurers={}
    data.personalGuild.buildings.guildHall=9 -- approved cap formula: 20+5*(9-1)=60
    result.syntheticProfile={class="Knight",level=60,hall=9,companions=0,earned=false}
    local function unexpectedReward()error("Unexpected camp/tower reward in isolated fixture")end
    constructionStarted=true
    world=require(server.Services.WorldService).new(function()end,unexpectedReward,unexpectedReward,function()end,function(p:Player)
        assert(p==player)
        return function(ticket:any)
            table.insert(result.rewardCalls,{deathId=tostring(ticket.deathId),recordedOnly=true})
            -- Explicit synthetic rejection; no adapter/persistence acceptance claimed.
            return "Rejected"
        end
    end)
    world.Add(player);task.wait(1)
    world.Update(player,9,data,true)
    world.IntentCommitted(player,"TravelZone",{zone="Greenwood"})
    waitFor("real regional scene",10,function()return player:GetAttribute("RegionalCombatEnabled")=="Greenwood" end)
    local scene=workspace:FindFirstChild("RegionalEncounter_"..player.UserId.."_Greenwood")
    assert(scene,"Missing real regional bridge scene")
    assert(scene:GetAttribute("AdventureSceneOwner")==player.UserId,"Regional owner mismatch")
    local captain:Model?=nil
    for _,v in ipairs(scene:GetDescendants()) do if v:IsA("Model") and v:GetAttribute("EncounterId")=="forest_captain" then captain=v;break end end
    local boss=assert(captain,"Missing real captain")
    local bossRoot=assert(boss.PrimaryPart)
    local home=bossRoot.Position
    r.Anchored=true
    local function place(offset:Vector3)
        assert(player.Character==c and humanoid.Health>0,"Fixture character lost")
        c:PivotTo(CFrame.lookAt(home+offset,home));r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
    end
    place(Vector3.new(55,0,0))
    for name,value in pairs({Captain=boss,Victim=c}) do local ref=Instance.new("ObjectValue");ref.Name=name;ref.Value=value;ref.Parent=fixture end
    local function sample(label:string):any
        local value={label=label,serverClock=os.clock(),workspaceClock=workspace:GetServerTimeNow(),health=c:GetAttribute("CombatHealth"),damageCueAt=c:GetAttribute("DamageCueAt"),bossHealth=boss:GetAttribute("CombatHealth"),state=boss:GetAttribute("CombatState"),warning=boss:GetAttribute("RegionalTelegraphAt"),untilAt=boss:GetAttribute("RegionalTelegraphUntil"),impact=boss:GetAttribute("RegionalImpactAt"),pattern=boss:GetAttribute("TelegraphName")}
        table.insert(result.samples,value);save();return value
    end
    fixture:SetAttribute("Ready",true);phase("AwaitClient")
    waitFor("paired observer ready",20,function()return ready end)
    local function warning(label:string):number
        phase(label)
        local old=boss:GetAttribute("RegionalTelegraphAt")
        place(Vector3.new(0,0,6))
        waitFor("fresh "..label.." warning",8,function()return boss:GetAttribute("CombatState")=="Windup" and boss:GetAttribute("RegionalTelegraphAt")~=old end)
        assert(boss:GetAttribute("TelegraphName")=="Antler Cleave","Expected phase-one cleave")
        local stamp=boss:GetAttribute("RegionalTelegraphAt") :: number
        local untilAt=boss:GetAttribute("RegionalTelegraphUntil") :: number
        assert(math.abs(untilAt-stamp-1.1)<.001,"Actual cleave duration changed")
        assert(workspace:GetServerTimeNow()<untilAt-.55,"INCONCLUSIVE_STUDIO_STALL: warning observed too late")
        sample(label.."Warning");return untilAt
    end
    local function released(previous:any)
        waitFor("real impact",3,function()
            if workspace:GetServerTimeNow()<previous.untilAt-.05 then
                assert(boss:GetAttribute("RegionalImpactAt")==previous.impact,"Impact preceded real warning deadline")
                assert((c:GetAttribute("CombatHealth") :: number)>=previous.health and c:GetAttribute("DamageCueAt")==previous.damageCueAt,"Damage preceded real warning deadline")
            end
            return boss:GetAttribute("RegionalImpactAt")~=previous.impact
        end)
        local at=boss:GetAttribute("RegionalImpactAt") :: number
        assert(at>=previous.untilAt-.03,"Impact timestamp preceded warning deadline")
        assert(at<=previous.untilAt+.5,"INCONCLUSIVE_STUDIO_STALL: release exceeded .5s bound")
        -- Actual scheduler is .2s; this records quantization, not an exact-frame promise.
        result.lastReleaseLateness=at-previous.untilAt
        task.wait(.05)
    end
    warning("HitCleave")
    local before=sample("HitBefore");released(before)
    local after=sample("HitAfter")
    assert(after.health<before.health and after.damageCueAt~=before.damageCueAt,"Actual cleave did not damage victim")
    table.insert(result.scenarios,{name="HitCleave",status="PASS",delta=before.health-after.health})
    warning("EvadeCleave")
    before=sample("EvadeBefore");place(Vector3.new(0,0,14));released(before)
    after=sample("EvadeAfter")
    assert(after.health==before.health and after.damageCueAt==before.damageCueAt,"Evaded footprint still damaged victim")
    table.insert(result.scenarios,{name="EvadeCleave",status="PASS",released=true})
    local cancelledDue=warning("CancelCleave")
    before=sample("CancelBefore");place(Vector3.new(55,0,0))
    waitFor("true no-target cancellation",.7,function()return boss:GetAttribute("RegionalTelegraphUntil")==nil and boss:GetAttribute("CombatState")~="Windup" end)
    assert(workspace:GetServerTimeNow()<cancelledDue,"INCONCLUSIVE_STUDIO_STALL: cancellation not observed before due")
    waitFor("cancelled release boundary",3,function()return workspace:GetServerTimeNow()>cancelledDue+.4 end)
    after=sample("CancelAfter")
    assert(after.impact==before.impact and after.health>=before.health and after.damageCueAt==before.damageCueAt,"Cancelled cast released or damaged")
    table.insert(result.scenarios,{name="CancelCleave",status="PASS",naturalRecovery=after.health-before.health})
    phase("PhaseTwo");place(Vector3.new(0,0,4))
    local commandDeadline=os.clock()+65
    repeat
        local hp=boss:GetAttribute("CombatHealth") :: number
        if hp<=(boss:GetAttribute("CombatMaxHealth") :: number)*.5 then break end
        local accepted,reason=world.PlayerAction(player,"Basic")
        table.insert(result.commands,{serverClock=os.clock(),workspaceClock=workspace:GetServerTimeNow(),accepted=accepted,reason=reason,bossHealthBefore=hp,bossHealthAfter=boss:GetAttribute("CombatHealth")})
        assert(accepted or reason=="Cooldown","PlayerAction rejected: "..tostring(reason))
        assert((c:GetAttribute("CombatHealth") :: number)>0,"Fixture victim downed")
        task.wait(.3)
    until os.clock()>commandDeadline
    assert((boss:GetAttribute("CombatHealth") :: number)>0 and (boss:GetAttribute("CombatHealth") :: number)<=(boss:GetAttribute("CombatMaxHealth") :: number)*.5,"Real Basic commands did not reach living phase two")
    waitFor("phase-two Root Burst",12,function()return boss:GetAttribute("BossPhase")==2 and boss:GetAttribute("TelegraphName")=="Root Burst" and boss:GetAttribute("CombatState")=="Windup" end)
    before=sample("RootBurstWarning")
    assert(math.abs(before.untilAt-before.warning-1.5)<.001,"Actual root burst duration changed")
    assert(workspace:GetServerTimeNow()<before.untilAt-.55,"INCONCLUSIVE_STUDIO_STALL: Root Burst observed too late")
    released(before);after=sample("RootBurstImpact")
    assert(after.health<before.health and after.damageCueAt~=before.damageCueAt,"Phase-two Root Burst did not damage victim")
    table.insert(result.scenarios,{name="PhaseTwoRootBurst",status="PASS",delta=before.health-after.health})
    assert(#result.rewardCalls==0,"Unexpected death/reward path: not a reward acceptance test")
    place(Vector3.new(55,0,0))
end,debug.traceback)
result.status=if ok then "PASS_SERVER_FIXTURE" else "FAIL_SERVER_FIXTURE"
result.error=if ok then nil else tostring(problem)
phase("Finished")
if ready then
    local deadline=os.clock()+20
    repeat task.wait(.05) until finished or os.clock()>deadline
    if not finished then result.clientEvidence="MISSING_FINISHED_ACK" end
end
if connection then connection:Disconnect() end
local cleanupOk,cleanupError=pcall(function()
    if world then if owner then world.Remove(owner) end;world.DestroyHeroRuntime() end
    local scene=workspace:FindFirstChild("GuildborneWorld");if constructionStarted and scene then scene:Destroy() end
    if constructionStarted then
        for _,item in ipairs(game.ServerStorage:GetChildren()) do if not oldStorage[item] then item:Destroy() end end
        for _,item in ipairs(Lighting:GetChildren()) do if not oldLightChildren[item] then item:Destroy() end end
        for key,value in pairs(oldLighting) do (Lighting :: any)[key]=value end
    end
    if root and root.Parent then root.Anchored=originalAnchored end
    if owner then owner:SetAttribute("CurrentZone",originalZone);(owner :: any).RespawnLocation=originalSpawn end
    if character and character.Parent and originalPivot then character:PivotTo(originalPivot) end
end)
result.cleanup={ok=cleanupOk,stopPlayRequired=true,reusable=false,residual="TravelService connections, collision groups and synthetic character cosmetics require Stop Play",error=if cleanupOk then nil else tostring(cleanupError)}
if not cleanupOk then result.status="FAIL_CLEANUP" end
save()
