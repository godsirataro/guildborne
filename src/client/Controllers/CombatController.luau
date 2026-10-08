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
	local effect=require(script.Parent.SkillEffects)()
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
		entities[m]={bar=bar,label=label,fill=fill}
	end
	for _,v in ipairs(workspace:GetDescendants()) do add(v) end
	connect(workspace.DescendantAdded,add)
	connect(workspace.DescendantRemoving,function(m) if m:IsA("Model") and entities[m] then entities[m].bar:Destroy(); entities[m]=nil end end)
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
			local hp,max=m:GetAttribute("CombatHealth") :: number?,m:GetAttribute("CombatMaxHealth") :: number?
			local own=m:GetAttribute("OwnerUserId")==player.UserId
			local hero=m:GetAttribute("GuildborneHero")==true
			local following=m:GetAttribute("HeroState")=="Following"
			e.bar.Adornee=m.PrimaryPart; e.bar.Enabled=own and hp~=nil and max~=nil and max>0 and not m:GetAttribute("GuildbornePlayer") and (not hero or (following and m:GetAttribute("CombatState")~="Follow" and m:GetAttribute("CombatState")~="ReturnToLeader"))
			if hp and max then
				local actionAt=m:GetAttribute("ActionAt")
				if own and actionAt and actionAt~=e.lastAction then
					e.lastAction=actionAt
					if workspace:GetServerTimeNow()-(actionAt :: number)<.6 then
						effect(m);Audio.Play(AudioConfig.actionCue(tostring(m:GetAttribute("ClassId")),tostring(m:GetAttribute("ActionEffect"))),m:GetPivot().Position)
					end
				end
				local telegraph=m:GetAttribute("TelegraphAt")
				if own and telegraph and telegraph~=e.telegraph then e.telegraph=telegraph;if workspace:GetServerTimeNow()-telegraph<(m:GetAttribute("TelegraphDuration") or 1.2) then effect(m,true);Audio.Play("enemy_warning",m:GetPivot().Position) end end
				local impactAt=m:GetAttribute("BossImpactAt")
				local regionalAt=m:GetAttribute("RegionalTelegraphAt")
				local regionalUntil=m:GetAttribute("RegionalTelegraphUntil") :: number?
				if own and regionalAt and regionalAt~=e.regionalTelegraph then
					e.regionalTelegraph=regionalAt
					if regionalUntil and regionalUntil>workspace:GetServerTimeNow() then Audio.Play("enemy_warning",m:GetPivot().Position) end
				end
				local regionalImpact=m:GetAttribute("RegionalImpactAt")
				if own and regionalImpact and regionalImpact~=e.regionalImpact then
					e.regionalImpact=regionalImpact
					if workspace:GetServerTimeNow()-regionalImpact<.5 then Audio.Play(if m:GetAttribute("BossPhase") then "boss_slam" else "melee_hit",m:GetPivot().Position) end
				end
				if own and impactAt and impactAt~=e.impact then e.impact=impactAt;if workspace:GetServerTimeNow()-impactAt<.5 then effect(m,false,true);Audio.Play("boss_slam",m:GetPivot().Position) end end
				if own and e.lastHealth and hp<e.lastHealth then
					local ranged=m:GetAttribute("DamageCue")=="arrow_hit" and workspace:GetServerTimeNow()-(m:GetAttribute("DamageCueAt") or 0)<.6
					Audio.Play(if hp<=0 and m:GetAttribute("GuildborneEnemy") then "enemy_defeat" elseif ranged then "arrow_hit" else "melee_hit",m:GetPivot().Position)
				end
				e.lastHealth=hp
				local state=tostring(m:GetAttribute("CombatState") or "Idle")
				local feedback=if workspace:GetServerTimeNow()-(m:GetAttribute("FeedbackAt") or 0)<.8 then tostring(m:GetAttribute("Feedback") or "") else ""
				local action=if workspace:GetServerTimeNow()-(m:GetAttribute("ActionAt") or 0)<.8 then T(tostring(m:GetAttribute("Action") or "")) else T(if state=="Windup" then tostring(m:GetAttribute("TelegraphName") or state) else state)
				if state=="Windup" and regionalUntil then action..=string.format(" · %.1fs",math.max(0,regionalUntil-workspace:GetServerTimeNow())) end
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
		for _,entity in pairs(entities) do entity.bar:Destroy() end;table.clear(entities)
	end
	gui.Destroying:Connect(cleanup)
	return {Destroy=function() cleanup();gui:Destroy() end}
end
