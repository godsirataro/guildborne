--!strict
-- Per-player cooldown presentation only; the server still validates every gather.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Shared=game.ReplicatedStorage.Shared
local Rules=require(Shared.Data.Expansion)
local Locale=require(Shared.Config.Localization)
local MenuRouter=require(script.Parent.Parent.UI.MenuRouter)
return function(scope:Instance?)
 local root=scope or workspace;local player=Players.LocalPlayer;local playerGui=player:WaitForChild("PlayerGui")
 local entries:{[ProximityPrompt]:any}={};local snapshot:any=nil;local receivedAt=0;local closed=false
 local function owned(anchor:Instance,regional:boolean):boolean
  local current:Instance?=anchor
  while current and current~=workspace do
   local owner=current:GetAttribute("OwnerUserId")
   if owner~=nil then return owner==player.UserId end
   current=current.Parent
  end
  return regional
 end
 local function refresh(prompt:ProximityPrompt,entry:any)
  local allowed=owned(entry.anchor,entry.regional)
  local active=snapshot and snapshot.status=="Active" and snapshot.data and snapshot.data.expansion
  local now=if snapshot then (snapshot.serverTime or 0)+os.clock()-receivedAt else 0
  local ready=if active then active.gatherReady[entry.id] or 0 else 0
  local seconds=math.max(0,math.ceil(ready-now));local blocked=MenuRouter.isBlocking()
  prompt.Enabled=entry.enabled and allowed and active~=nil and active~=false and seconds==0 and not blocked
  local language=if snapshot and snapshot.data then snapshot.data.language or "en" else "en"
  prompt.ActionText=Locale.translate(language,"Gather")
  entry.gui.Enabled=entry.enabled and allowed and active~=nil and active~=false and seconds>0 and not blocked
  entry.label.Text=Locale.translate(language,entry.name).."\n"..Locale.translate(language,"Gather again in {seconds}s",{seconds=seconds})
  if entry.baseGui and entry.baseGui.Parent then entry.baseGui.Enabled=entry.baseEnabled and not entry.gui.Enabled end
  entry.gui:SetAttribute("RemainingSeconds",seconds)
 end
 local function remove(prompt:ProximityPrompt)
  local entry=entries[prompt];if not entry then return end
  entries[prompt]=nil;entry.gui:Destroy()
  if entry.baseGui and entry.baseGui.Parent then entry.baseGui.Enabled=entry.baseEnabled end
  if prompt.Parent then prompt.Enabled=entry.enabled;prompt.ActionText=entry.actionText end
 end
 local function add(value:Instance)
  if closed or not value:IsA("ProximityPrompt") or entries[value] or value.Name~="Gather" then return end
  local anchor=value.Parent;if not anchor or not anchor:IsA("BasePart") then return end
  local id=anchor:GetAttribute("ResourceNodeId");local def=type(id)=="string" and Rules.Nodes[id]
  if not def then return end
  local baseGui=anchor:FindFirstChildOfClass("BillboardGui")
  local gui=Instance.new("BillboardGui");gui.Name="ResourceCooldown";gui.Adornee=anchor;gui.Size=UDim2.fromOffset(210,50)
  gui.StudsOffsetWorldSpace=if baseGui then baseGui.StudsOffsetWorldSpace else Vector3.new(0,4,0)
  if baseGui then gui.StudsOffset=baseGui.StudsOffset end
  gui.MaxDistance=24;gui.AlwaysOnTop=false;gui.Enabled=false;gui.Parent=playerGui
  local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundColor3=Color3.fromRGB(25,32,45);label.BackgroundTransparency=.15;label.BorderSizePixel=0
  label.TextColor3=Color3.fromRGB(230,203,144);label.TextSize=14;label.Font=Enum.Font.GothamMedium;label.TextWrapped=true;label.Parent=gui
  local round=Instance.new("UICorner");round.CornerRadius=UDim.new(0,6);round.Parent=label
  entries[value]={id=id,anchor=anchor,regional=def.Region~=nil,gui=gui,label=label,enabled=value.Enabled,actionText=value.ActionText,
   name=({timber="Timber",stone="Stone",iron_ore="Iron Ore",herb="Herb"})[def.Item],baseGui=baseGui,baseEnabled=if baseGui then baseGui.Enabled else false}
  refresh(value,entries[value])
 end
 local added=root.DescendantAdded:Connect(add)
 local removed=root.DescendantRemoving:Connect(function(value:Instance)if value:IsA("ProximityPrompt")then remove(value)end end)
 for _,value in ipairs(root:GetDescendants())do add(value)end
 local elapsed=0;local heartbeat=Run.Heartbeat:Connect(function(dt:number)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  for prompt,entry in pairs(entries)do refresh(prompt,entry)end
 end)
 return {
  Update=function(view:any)snapshot=view;receivedAt=os.clock();for prompt,entry in pairs(entries)do refresh(prompt,entry)end end,
  Destroy=function()if closed then return end;closed=true;added:Disconnect();removed:Disconnect();heartbeat:Disconnect();for prompt in pairs(entries)do remove(prompt)end end,
 }
end
