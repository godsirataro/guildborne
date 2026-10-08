--!strict
-- Isolated replicas outside Workspace: never conflicts with real prompt controllers.
return function():any
 local player=game.Players.LocalPlayer
 local folder=Instance.new("Folder");folder.Name="ResourceMarkerFixture";folder.Parent=game.ReplicatedStorage
 local function node(id:string,owner:number?,enabled:boolean?):ProximityPrompt
  local anchor=Instance.new("Part");anchor:SetAttribute("ResourceNodeId",id);anchor:SetAttribute("OwnerUserId",owner);anchor.Parent=folder
  local base=Instance.new("BillboardGui");base.Name="ResourceName";base.StudsOffset=Vector3.new(0,4,0);base.Parent=anchor
  local p=Instance.new("ProximityPrompt");p.Name="Gather";p.ActionText="Original gather";p.Enabled=enabled~=false;p.Parent=anchor;return p
 end
 local own=node("wood",player.UserId);local foreign=node("wood",player.UserId+1)
 local regional=node("greenwood_herbs",nil);local unowned=node("wood",nil);local disabled=node("wood",player.UserId,false)
 local unknown=node("missing",nil)
 local controller=require(player.PlayerScripts.Client.Controllers.ResourceNodeMarkers)(folder)
 local function marker(prompt:ProximityPrompt):BillboardGui?
  for _,gui in ipairs(player.PlayerGui:GetChildren())do if gui:IsA("BillboardGui") and gui.Name=="ResourceCooldown" and gui.Adornee==prompt.Parent then return gui end end
  return nil
 end
 local ok,result=pcall(function():any
  assert(not own.Enabled and not regional.Enabled and unknown.Enabled,"Loading or unknown prompt policy")
  local view:any={status="Active",serverTime=1000,data={language="th",expansion={gatherReady={wood=1003,greenwood_herbs=1001}}}}
  controller.Update(view)
  assert(not own.Enabled and not regional.Enabled and not foreign.Enabled and not unowned.Enabled and not disabled.Enabled)
  local ownGui=assert(marker(own));local regionalGui=assert(marker(regional));local foreignGui=assert(marker(foreign))
  assert(ownGui.Enabled and regionalGui.Enabled and not foreignGui.Enabled)
  local ownBase=assert(own.Parent):FindFirstChild("ResourceName") :: BillboardGui
  assert(not ownBase.Enabled and ownGui.StudsOffset==ownBase.StudsOffset)
  assert(ownGui:GetAttribute("RemainingSeconds")==3 and regionalGui:GetAttribute("RemainingSeconds")==1)
  local label=ownGui:FindFirstChildWhichIsA("TextLabel") :: TextLabel
  assert(label.Text:find("เก็บได้อีกใน 3 วินาที",1,true))
  task.wait(1.3);assert(regional.Enabled and not regionalGui.Enabled and not own.Enabled,"Countdown expiry")
  view.serverTime=1004;view.data.language="en";controller.Update(view)
  assert(own.Enabled and regional.Enabled and not foreign.Enabled and not disabled.Enabled)
  assert(ownBase.Enabled)
  assert(own.ActionText=="Gather")
  view.status="SavePending";controller.Update(view);assert(not own.Enabled and not ownGui.Enabled)
  view.status="Active";controller.Update(view);assert(own.Enabled)
  local extra=node("stone",player.UserId);task.wait(.25);assert(extra.Enabled and marker(extra))
  local extraGui=assert(marker(extra));extra:Destroy();assert(extraGui.Parent==nil,"Removed node marker leak")
  controller.Destroy();controller.Destroy()
  assert(own.Enabled and foreign.Enabled and regional.Enabled and unowned.Enabled and not disabled.Enabled)
  assert(tostring(own.ActionText)=="Original gather" and ownGui.Parent==nil and regionalGui.Parent==nil)
  return {loadingGated=true,unknownUntouched=true,foreignHidden=true,unownedGuildHidden=true,initialDisabledPreserved=true,countdownExpires=true,bilingual=true,recoveryGated=true,lateNode=true,removalCleanup=true,destroyRestores=true,profileWrites=0,synthetic=true}
 end)
 controller.Destroy();folder:Destroy();assert(ok,tostring(result));return result
end
