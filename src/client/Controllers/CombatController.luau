--!strict
-- Replicated attributes are presentation only. This controller sends no combat requests.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Localization=require(ReplicatedStorage.Shared.Config.Localization)
local Art=require(ReplicatedStorage.Shared.Config.Art)
local MenuRouter=require(script.Parent.Parent.UI.MenuRouter)
local Audio=require(script.Parent.AudioController)
local AudioConfig=require(ReplicatedStorage.Shared.Config.AudioConfig)
local Cue=require(ReplicatedStorage.Shared.Presentation.CombatCueEvents)
local VFXConfig=require(ReplicatedStorage.Shared.Config.VFXConfig)
local regionalPatterns={ ["Antler Cleave"]=true,["Root Burst"]=true,["Hammer Fall"]=true,["Fault Line"]=true,
    ["Rune Lance"]=true,["Hollow Nova"]=true,["Boar Rush"]=true,["Rune Pounce"]=true,["Rune Flare"]=true }
local function position(value:any):boolean
    return typeof(value)=="Vector3" and Cue.finite(value.X) and Cue.finite(value.Y) and Cue.finite(value.Z)
end
return function()
	local connections: {RBXScriptConnection}={}
	local function connect(signal: RBXScriptSignal,callback: any) table.insert(connections,signal:Connect(callback)) end
	local player=Players.LocalPlayer
	local language="en"
	local gui=Instance.new("ScreenGui"); gui.Name="GuildborneCombatUI"; gui.ResetOnSpawn=false
	gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.Parent=player:WaitForChild("PlayerGui")
	local panel=Instance.new("Frame"); panel.Name="PartyHealth"; panel.Position=UDim2.fromOffset(8,64)
	panel.Size=UDim2.fromOffset(180,166); panel.BackgroundColor3=Art.UI.Background; panel.BackgroundTransparency=.12; panel.Parent=gui
	local corner=Instance.new("UICorner"); corner.Parent=panel
	local rows={}
	for i=1,6 do
		local row=Instance.new("TextLabel"); row.Name="Member"..i; row.Position=UDim2.fromOffset(6,(i-1)*27)
		row.Size=UDim2.new(1,-12,0,27); row.BackgroundTransparency=1; row.TextColor3=Art.UI.Text
		row.Font=Enum.Font.GothamMedium; row.TextSize=13; row.TextXAlignment=Enum.TextXAlignment.Left; row.Parent=panel
		table.insert(rows,row)
	end
	local entities: {[Model]:any}={}
	-- Streaming/reparenting the same instance must not renew consumed event stamps.
	local cursors=setmetatable({} :: {[Model]:any},{__mode="k"})
	local stampChannels={ActionAt="action",TelegraphAt="tower",TelegraphDuration="tower",RegionalTelegraphAt="regional",RegionalTelegraphUntil="regional",BossImpactAt="towerImpact",RegionalImpactAt="regionalImpact",DamageCueAt="damage"}
	local effect=require(script.Parent.SkillEffects)()
	local function stopWarning(e:any)
		if e.warningStop then e.warningStop();e.warningStop=nil end
		e.warningStamp=nil;e.warningKind=nil;e.warningName=nil;e.warningUntil=nil
	end
	local function warningCurrent(m:Model,e:any):boolean
		if not m:IsDescendantOf(workspace) or m:GetAttribute("OwnerUserId")~=player.UserId then return false end
		local hp=m:GetAttribute("CombatHealth")
		if not Cue.finite(hp) or hp<=0 then return false end
		local regional=e.warningKind=="regional"
		local stamp=m:GetAttribute(if regional then "RegionalTelegraphAt" else "TelegraphAt")
		local duration=m:GetAttribute("TelegraphDuration")
		local untilAt=if regional then m:GetAttribute("RegionalTelegraphUntil") elseif Cue.finite(stamp) and Cue.finite(duration) then (stamp :: number)+(duration :: number) else nil
		return stamp==e.warningStamp and untilAt==e.warningUntil and m:GetAttribute("TelegraphName")==e.warningName and (not regional or regionalPatterns[tostring(m:GetAttribute("TelegraphName"))]==true)
			and Cue.warningValid(stamp,untilAt,workspace:GetServerTimeNow(),m:GetAttribute("CombatState"))
	end
	local function remove(m:Model)
		local e=entities[m];if not e then return end
		for key in pairs(e.cues) do Cue.discard(e.cues,key,nil,workspace:GetServerTimeNow()) end
		stopWarning(e);e.attributes:Disconnect();e.bar:Destroy();entities[m]=nil
	end
	local function add(m: Instance)
		if not m:IsA("Model") or entities[m] or not (m:GetAttribute("GuildborneHero") or m:GetAttribute("GuildborneEnemy") or m:GetAttribute("GuildbornePlayer")) then return end
		local bar=Instance.new("BillboardGui"); bar.Name="CombatHealthBar"; if m.PrimaryPart then bar.Adornee=m.PrimaryPart end
		bar.Size=UDim2.fromOffset(156,50); bar.StudsOffsetWorldSpace=Vector3.new(0,4.4,0); bar.MaxDistance=65; bar.AlwaysOnTop=false; bar.Parent=m
		local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundColor3=Art.UI.Background
		label.BackgroundTransparency=.2; label.TextColor3=Art.UI.Text; label.Font=Enum.Font.GothamMedium; label.TextSize=13
		label.TextWrapped=true; label.Parent=bar
		local fill=Instance.new("Frame"); fill.Name="HealthFill"; fill.Position=UDim2.new(0,0,1,-4); fill.Size=UDim2.new(1,0,0,4)
		fill.BackgroundColor3=if m:GetAttribute("GuildborneEnemy") then Color3.fromRGB(205,95,73) else Color3.fromRGB(118,187,120)
		fill.BorderSizePixel=0; fill.Parent=bar
		local history=cursors[m] or Cue.new();cursors[m]=history
		local e:any={bar=bar,label=label,fill=fill,cues=history};entities[m]=e
		e.attributes=m.AttributeChanged:Connect(function(attribute:string)
			local channel=stampChannels[attribute]
			if channel and m:GetAttribute(attribute)==nil then Cue.discard(e.cues,channel,nil,workspace:GetServerTimeNow()) end
			if attribute=="CombatHealth" or attribute=="OwnerUserId" then
				local health=m:GetAttribute("CombatHealth")
				if not Cue.finite(health) or health<=0 or m:GetAttribute("OwnerUserId")~=player.UserId then
					-- A lethal HP update may follow a pending damage timestamp.
					-- Preserve that channel on death; ownership loss cancels all.
					for key in pairs(e.cues) do
						if key~="damage" or m:GetAttribute("OwnerUserId")~=player.UserId then
							Cue.discard(e.cues,key,nil,workspace:GetServerTimeNow())
						end
					end
				end
			end
			if e.warningStamp and not warningCurrent(m,e) then stopWarning(e) end
		end)
	end
	for _,v in ipairs(workspace:GetDescendants()) do add(v) end
	connect(workspace.DescendantAdded,add)
	connect(workspace.DescendantRemoving,function(m) if m:IsA("Model") then remove(m) end end)
	local remotes=ReplicatedStorage:WaitForChild("GuildborneRemotes");
	connect((remotes:WaitForChild("State") :: RemoteEvent).OnClientEvent,function(view) if view.data then language=view.data.language or "en" end end)
	local elapsed=0
	connect(RunService.Heartbeat,function(dt)
		elapsed+=dt; if elapsed<.1 then return end; elapsed=0
		local function T(key: string): string return Localization.translate(language,key) end
		local party={}
		if player.Character then add(player.Character) end
		local rowHeight=if workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y<450 then 18 else 27
		for i,row in ipairs(rows) do row.Position=UDim2.fromOffset(6,(i-1)*rowHeight); row.Size=UDim2.new(1,-12,0,rowHeight) end
		for m,e in pairs(entities) do
			local hp:any=m:GetAttribute("CombatHealth");local max:any=m:GetAttribute("CombatMaxHealth")
			local own=m:GetAttribute("OwnerUserId")==player.UserId
			local hero=m:GetAttribute("GuildborneHero")==true
			local following=m:GetAttribute("HeroState")=="Following"
			e.bar.Adornee=m.PrimaryPart; e.bar.Enabled=own and Cue.finite(hp) and Cue.finite(max) and max>0 and not m:GetAttribute("GuildbornePlayer") and (not hero or (following and m:GetAttribute("CombatState")~="Follow" and m:GetAttribute("CombatState")~="ReturnToLeader"))
			local now=workspace:GetServerTimeNow()
			if e.warningStamp and not warningCurrent(m,e) then stopWarning(e) end
			if Cue.finite(hp) and Cue.finite(max) and max>0 then
				local living=own and hp>0 and m:IsDescendantOf(workspace)
				local root=m.PrimaryPart
				local target=m:GetAttribute("ActionTargetPosition")
				local camera=workspace.CurrentCamera
				local targetReady=root~=nil and position(target) and camera~=nil
					and type(m:GetAttribute("ClassId"))=="string" and type(m:GetAttribute("ActionEffect"))=="string"
				local actionAt=m:GetAttribute("ActionAt")
				if not living then Cue.discard(e.cues,"action",actionAt,now)
				elseif Cue.admit(e.cues,"action",actionAt,now,Cue.ActionTTL,targetReady) then
					-- Consume once even when culled; coming closer cannot replay an old cast.
					if root and camera and (camera.CFrame.Position-root.Position).Magnitude<=VFXConfig.Distance.Cull then
						effect(m);Audio.PlayFor(m,AudioConfig.actionCue(tostring(m:GetAttribute("ClassId")),tostring(m:GetAttribute("ActionEffect"))),root.Position)
					end
				end
				local telegraph=m:GetAttribute("TelegraphAt")
				local regionalAt=m:GetAttribute("RegionalTelegraphAt")
				local regionalUntil=m:GetAttribute("RegionalTelegraphUntil")
				local duration=m:GetAttribute("TelegraphDuration")
				local towerUntil=if Cue.finite(telegraph) and Cue.finite(duration) then (telegraph :: number)+(duration :: number) else nil
				local combatState=m:GetAttribute("CombatState")
				local function warning(kind:string,stamp:any,untilAt:any,ready:boolean)
					if not living then Cue.discard(e.cues,kind,stamp,now);return end
					local valid=ready and root~=nil and Cue.warningValid(stamp,untilAt,now,combatState)
					-- An interval can arrive after its stamp. Do not expire pending metadata at age zero.
					local ttl=if Cue.finite(stamp) and Cue.finite(untilAt) then untilAt-stamp else 10
					if Cue.admit(e.cues,kind,stamp,now,ttl,valid) then
						stopWarning(e);e.warningKind=kind;e.warningStamp=stamp;e.warningName=m:GetAttribute("TelegraphName");e.warningUntil=untilAt
						if kind=="tower" then effect(m,true) end
						e.warningStop=Audio.PlayOwned(m,"enemy_warning",(root :: BasePart).Position)
					end
				end
				warning("regional",regionalAt,regionalUntil,regionalPatterns[tostring(m:GetAttribute("TelegraphName"))]==true)
				warning("tower",telegraph,towerUntil,position(target))
				local regionalImpact=m:GetAttribute("RegionalImpactAt")
				if not living then Cue.discard(e.cues,"regionalImpact",regionalImpact,now)
				elseif Cue.admit(e.cues,"regionalImpact",regionalImpact,now,.5,root~=nil) then
					-- A resolved attack can miss. This is a world release cue, not damage confirmation.
					Audio.PlayFor(m,if m:GetAttribute("BossPhase") then "boss_slam" else "sword_swing",(root :: BasePart).Position)
				end
				local impactAt=m:GetAttribute("BossImpactAt")
				if not living then Cue.discard(e.cues,"towerImpact",impactAt,now)
				elseif Cue.admit(e.cues,"towerImpact",impactAt,now,.5,root~=nil and position(target)) then
					effect(m,false,true);Audio.PlayFor(m,"boss_slam",(root :: BasePart).Position)
				end
				local damageAt=m:GetAttribute("DamageCueAt")
				-- Retain a recent HP decrease across attribute replication order, never infer a hit from a release.
				if own and e.lastHealth and hp<e.lastHealth then e.damageObservedAt=now end
				local decreased=e.damageObservedAt and now-e.damageObservedAt>=0 and now-e.damageObservedAt<.6
				if not own then Cue.discard(e.cues,"damage",damageAt,now)
				elseif Cue.admit(e.cues,"damage",damageAt,now,.6,root~=nil and decreased==true) then
					e.damageObservedAt=nil
					local key=if hp<=0 and m:GetAttribute("GuildborneEnemy") then "enemy_defeat" elseif m:GetAttribute("DamageCue")=="arrow_hit" then "arrow_hit" else "melee_hit"
					Audio.PlayFor(m,key,(root :: BasePart).Position)
				end
				e.lastHealth=hp
				local state=tostring(m:GetAttribute("CombatState") or "Idle")
				local feedback=if Cue.recent(m:GetAttribute("FeedbackAt"),now,.8) then tostring(m:GetAttribute("Feedback") or "") else ""
				local action=if Cue.recent(m:GetAttribute("ActionAt"),now,.8) then T(tostring(m:GetAttribute("Action") or "")) else T(if state=="Windup" then tostring(m:GetAttribute("TelegraphName") or state) else state)
				if state=="Windup" and Cue.finite(regionalUntil) then action..=string.format(" · %.1fs",math.max(0,regionalUntil-workspace:GetServerTimeNow())) end
				local phase=m:GetAttribute("BossPhase")
				e.label.Text=T(if hero then m.Name elseif m:GetAttribute("GuildbornePlayer") then "Your character" else tostring(m:GetAttribute("EnemyTitle") or "Goblin Scout")).."  "..hp.."/"..max.."\n"..(if phase then T("Phase").." "..tostring(phase).." · " else "")..action.." "..feedback
				e.fill.Size=UDim2.new(math.clamp(hp/math.max(1,max),0,1),0,0,4)
				if own and hero and following then table.insert(party,m) end
			end
		end
		table.sort(party,function(a,b) return (a:GetAttribute("PartySlot") or 0)<(b:GetAttribute("PartySlot") or 0) end)
		panel.Visible=#party>0 and not MenuRouter.isBlocking() and player.PlayerGui:FindFirstChild("GuildbornePlayerCombatUI")==nil
		rows[1].Text=T("Party health")
		for i=1,5 do
			local m=party[i]; local row=rows[i+1]
			if m then
				local cooldown=(m:GetAttribute("Cooldown") or 0) :: number
				row.Text=T(m.Name).." "..tostring(m:GetAttribute("CombatHealth")).."/"..tostring(m:GetAttribute("CombatMaxHealth")).." · "..(if m:GetAttribute("CombatHealth")==0 then T("Downed") elseif cooldown>0 then cooldown.."s" else T("Ready"))
				row.TextColor3=if m:GetAttribute("CombatHealth")==0 then Color3.fromRGB(245,141,105) else Art.UI.Text
			else row.Text="" end
		end
		panel.Size=UDim2.fromOffset(180,rowHeight*(#party+1)+4)
	end)
	local function cleanup()
		for _,connection in ipairs(connections) do connection:Disconnect() end;table.clear(connections)
		for m in pairs(entities) do remove(m) end;table.clear(entities)
	end
	gui.Destroying:Connect(cleanup)
	return {Destroy=function() cleanup();gui:Destroy() end}
end
