--!strict
-- Disposable CLIENT observer. Real EnemyAnimator; no health, combat or event writes.
-- Install as a LocalScript in StarterPlayerScripts AFTER disabling ClientBootstrap
-- in this fresh unsaved place. Pair with GreenwoodCombatFixture.server.luau.
local Run=game:GetService("RunService")
assert(Run:IsStudio() and Run:IsClient() and game.PlaceId==0 and game.GameId==0,"Unsaved CLIENT only")
local player=game.Players.LocalPlayer
local scripts=player:WaitForChild("PlayerScripts",20);assert(scripts,"No PlayerScripts")
local client=scripts:WaitForChild("Client",20);assert(client,"Missing exact client source tree")
local bootstrap=client:FindFirstChild("ClientBootstrap")
assert(bootstrap and bootstrap:IsA("LocalScript") and bootstrap.Disabled,"Disable normal ClientBootstrap before Play")
assert(not workspace:FindFirstChild("GreenwoodCombatClientReport"),"Existing client observer/report; use a fresh Play")
local fixture=workspace:WaitForChild("GreenwoodCombatFixture",30);assert(fixture,"Server fixture missing")
local remote=fixture:WaitForChild("ClientStatus",10);assert(remote and remote:IsA("RemoteEvent"),"Missing scoped handshake")
local captainRef=fixture:WaitForChild("Captain",10);assert(captainRef and captainRef:IsA("ObjectValue"))
local victimRef=fixture:WaitForChild("Victim",10);assert(victimRef and victimRef:IsA("ObjectValue"))
local report=Instance.new("StringValue");report.Name="GreenwoodCombatClientReport";report.Parent=workspace
local Http=game:GetService("HttpService")
local camera=assert(workspace.CurrentCamera)
local oldType,oldFrame,oldFocus=camera.CameraType,camera.CFrame,camera.Focus
local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local oldReduced=workspace:GetAttribute(config.ReducedMotionAttribute)
local result:any={status="STARTING",scope="CLIENT_OBSERVATIONS_NOT_DAMAGE_AUTHORITY",samples={},warnings={},impacts={},
    serverCombatAccepted=false,visualApproval=false,physicalDeviceTested=false,droppedSamples=0}
local animator:any=nil
local connection:RBXScriptConnection?=nil
local cameraSide=false
local failure:string?=nil
local function round(n:number):number return math.round(n*10000)/10000 end
local function number(m:Instance,key:string):number
    local v=m:GetAttribute(key)
    return if type(v)=="number" and v==v and math.abs(v)<math.huge then v else 0
end
local function pose(m:Model):{number}
    local values={}
    local folder=m:FindFirstChild("EnemyJoints")
    for _,name in ipairs({"RootJoint","Right Shoulder","Left Shoulder","Neck"}) do
        local j=folder and folder:FindFirstChild(name)
        if j and j:IsA("Motor6D") then
            local x,y,z=j.Transform:ToOrientation()
            for _,v in ipairs({x,y,z}) do assert(v==v and math.abs(v)<math.huge,"Nonfinite real joint pose");table.insert(values,round(v)) end
        end
    end
    assert(#values==12,"Missing replicated production joints")
    return values
end
local ok,problem=xpcall(function()
    local deadline=os.clock()+30
    repeat task.wait(.05) until (fixture:GetAttribute("Ready")==true and captainRef.Value~=nil and victimRef.Value~=nil) or os.clock()>deadline
    assert(fixture:GetAttribute("Ready")==true,"Server did not become ready")
    assert(fixture:GetAttribute("OwnerUserId")==player.UserId,"Wrong synthetic owner")
    local captain=captainRef.Value;local victim=victimRef.Value
    assert(captain and captain:IsA("Model") and victim and victim:IsA("Model"),"Missing real actor references")
    assert(victim==player.Character and captain:GetAttribute("EncounterId")=="forest_captain","Wrong actors")
    assert(captain:GetAttribute("EnemyVisualStyle")=="GreenwoodForgedV1","Wrong source art")
    assert(captain:GetAttribute("OwnerUserId")==player.UserId,"Foreign encounter")
    local jointDeadline=os.clock()+8
    repeat task.wait(.05) until captain:FindFirstChild("EnemyJoints") and #captain.EnemyJoints:GetChildren()>=12 or os.clock()>jointDeadline
    pose(captain)
    local controllers=assert(client:FindFirstChild("Controllers"))
    animator=require(assert(controllers:FindFirstChild("EnemyAnimator")))()
    workspace:SetAttribute(config.ReducedMotionAttribute,true)
    camera.CameraType=Enum.CameraType.Scriptable
    local lastSample=0;local lastWarning=0;local lastImpact=0
    local started=os.clock()
    local footprints:{[string]:boolean}={}
    local function capture()
        assert(player.Character==victim and captain.Parent,"Actor replaced/removed before Finished")
        local now=workspace:GetServerTimeNow()
        local at,untilAt=number(captain,"RegionalTelegraphAt"),number(captain,"RegionalTelegraphUntil")
        local impact=number(captain,"RegionalImpactAt")
        local phase=tostring(fixture:GetAttribute("Phase"))
        local position=captain:GetPivot().Position
        cameraSide=phase=="PhaseTwo"
        camera.CFrame=CFrame.lookAt(position+(if cameraSide then Vector3.new(18,10,-8) else Vector3.new(10,9,-20)),position+Vector3.new(0,4,0))
        camera.Focus=CFrame.new(position+Vector3.new(0,4,0))
        local warningName=tostring(captain:GetAttribute("TelegraphName") or "")
        local shape="";local edges=0
        local scene=captain.Parent and captain.Parent.Parent
        if scene then
            for _,child in ipairs(scene:GetChildren()) do
                if child.Name=="AdventureTelegraph" and child:GetAttribute("PatternName")==warningName then
                    shape=tostring(child:GetAttribute("Shape"));edges+=#child:GetChildren()
                end
            end
        end
        if edges>0 then footprints[warningName]=true end
        if at>0 and at~=lastWarning and untilAt>now then
            lastWarning=at
            table.insert(result.warnings,{observed=now,start=at,untilAt=untilAt,name=warningName,phase=phase})
        end
        if impact>0 and impact~=lastImpact then
            lastImpact=impact
            table.insert(result.impacts,{observed=now,stamp=impact,phase=phase,victimHP=number(victim,"CombatHealth"),victimCue=number(victim,"DamageCueAt")})
        end
        local active=untilAt>now or (impact>0 and now-impact>=0 and now-impact<.6)
        if now-lastSample<(if active then .1 else .5) then return end
        lastSample=now
        if #result.samples>=1200 then result.droppedSamples+=1;return end
        -- Row schema documented below. No os.clock is mixed into replicated timestamps.
        table.insert(result.samples,{round(now),phase,tostring(captain:GetAttribute("CombatState")),warningName,round(at),round(untilAt),
            round(impact),number(captain,"CombatHealth"),number(victim,"CombatHealth"),round(number(victim,"DamageCueAt")),shape,edges,pose(captain)})
    end
    connection=Run.Heartbeat:Connect(function()
        if failure or fixture:GetAttribute("Phase")=="Finished" then return end
        local sampled,err=pcall(capture);if not sampled then failure=tostring(err) end
    end)
    capture();result.status="OBSERVING";remote:FireServer("Ready")
    repeat task.wait(.1) until fixture:GetAttribute("Phase")=="Finished" or failure or not fixture.Parent or os.clock()-started>180
    assert(not failure,failure)
    assert(fixture.Parent and fixture:GetAttribute("Phase")=="Finished","Fixture ended without bounded Finished handshake")
    assert(footprints["Antler Cleave"] and footprints["Root Burst"],"Did not observe both actual replicated footprints")
    assert(#result.impacts>=3,"Missing replicated impact observations")
    result.status="OBSERVED_NATIVE_CLIENT"
    result.warningCount=#result.warnings;result.impactCount=#result.impacts
    result.sampleSchema={"serverTime","phase","combatState","warningName","warningStart","warningUntil","impactAt","captainHP","victimHP","victimDamageCueAt","shape","warningEdges","jointEulerXYZ:Root/RightShoulder/LeftShoulder/Neck"}
end,debug.traceback)
if connection then connection:Disconnect() end
if animator then animator.Destroy() end
workspace:SetAttribute(config.ReducedMotionAttribute,oldReduced)
camera.CameraType=oldType;camera.CFrame=oldFrame;camera.Focus=oldFocus
if not ok then result.status="FAIL_CLIENT_OBSERVER";result.error=tostring(problem) end
local encoded=Http:JSONEncode(result)
if #encoded>500000 then
    result.samples={};result.status="FAIL_CLIENT_REPORT_BUDGET";encoded=Http:JSONEncode(result)
end
report.Value=encoded
if remote.Parent then remote:FireServer("Finished",encoded) end
print("GREENWOOD_COMBAT_CLIENT",result.status,"samples",#result.samples)
