--!strict
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Replicated=game:GetService("ReplicatedStorage")
local pose=require(script.Parent.ActionPose)
local Art=require(Replicated.Shared.Config.Art)
local Localization=require(Replicated.Shared.Config.Localization)
local Bindings=require(Replicated.Shared.Config.CombatBindings)
local City=require(Replicated.Shared.Config.City)
local MenuRouter=require(script.Parent.Parent.UI.MenuRouter)
local MakePortrait=require(script.Parent.Parent.UI.ActorPortrait)
local Layout=require(Replicated.Shared.Data.CombatHudLayout)
return function()
	local connections: {RBXScriptConnection}={}
	local function connect(signal: RBXScriptSignal,callback: any) table.insert(connections,signal:Connect(callback)) end
	local player=Players.LocalPlayer
	local remotes=Replicated:WaitForChild("GuildborneRemotes")
	local remote=remotes:WaitForChild("CombatIntent") :: RemoteEvent
	local language="en"
	local status=""; local statusUntil=0
	local gui=Instance.new("ScreenGui"); gui.Name="GuildbornePlayerCombatUI"; gui.ResetOnSpawn=false
	gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.Parent=player:WaitForChild("PlayerGui")
	local health=Instance.new("TextLabel"); health.Name="PlayerHealth"; health.AnchorPoint=Vector2.new(.5,1)
	health.Position=UDim2.new(.5,0,1,-8); health.Size=UDim2.new(.6,0,0,44)
	health.BackgroundColor3=Art.UI.Background; health.TextColor3=Art.UI.Text; health.Font=Enum.Font.GothamMedium
	health.TextSize=13; health.TextWrapped=true; health.Parent=gui
	local corner=Instance.new("UICorner"); corner.Parent=health
	local selectedId="player"
	local companions: {[Model]: boolean}={}
	local function observe(instance: Instance)
		if instance:IsA("Model") and instance:GetAttribute("GuildborneHero") then companions[instance]=true end
	end
	for _,instance in ipairs(workspace:GetDescendants()) do observe(instance) end
	connect(workspace.DescendantAdded,observe)
	connect(workspace.DescendantRemoving,function(instance) if instance:IsA("Model") then companions[instance]=nil end end)
	local function members(): {Model}
		local list={}
		for model in pairs(companions) do
			if model:IsDescendantOf(workspace) and model:GetAttribute("OwnerUserId")==player.UserId and model:GetAttribute("HeroState")=="Following" then table.insert(list,model) end
		end
		table.sort(list,function(a,b) return (a:GetAttribute("PartySlot") or 99)<(b:GetAttribute("PartySlot") or 99) end)
		while #list>5 do table.remove(list) end
		return list
	end
	local function selected(): Model?
		if selectedId=="player" then return player.Character end
		for _,model in ipairs(members()) do if model:GetAttribute("AdventurerId")==selectedId then return model end end
		selectedId="player"; return player.Character
	end
	local selection=Instance.new("Frame");selection.Name="CompanionSelection";selection.BackgroundTransparency=1
	selection.Position=UDim2.fromOffset(8,64);selection.Size=UDim2.fromOffset(138,288);selection.Parent=gui
	local cards: {TextButton}={}
	local portraits: {any}={}
	local cardLabels: {TextLabel}={}
	for index=1,6 do
		local card=Instance.new("TextButton");card.Name="Actor"..index;card.Size=UDim2.fromOffset(138,44)
		card.Position=UDim2.fromOffset(0,(index-1)*48);card.Font=Enum.Font.GothamMedium;card.TextSize=12;card.TextWrapped=true
		card.TextColor3=Art.UI.Text;card.BackgroundColor3=Art.UI.Card;card.Parent=selection
		Instance.new("UICorner",card)
		card.Text="";table.insert(portraits,MakePortrait(card))
		local label=Instance.new("TextLabel");label.Name="ActorLabel";label.BackgroundTransparency=1
		label.Position=UDim2.fromOffset(44,0);label.Size=UDim2.new(1,-47,1,0);label.TextColor3=Art.UI.Text
		label.Font=Enum.Font.GothamMedium;label.TextSize=11;label.TextWrapped=true;label.Parent=card;table.insert(cardLabels,label)
		connect(card.Activated,function()
			local id=card:GetAttribute("ActorId");if type(id)=="string" then selectedId=id end
		end)
		table.insert(cards,card)
	end
	local function cycle()
		if MenuRouter.isBlocking() or Input:GetFocusedTextBox() then return end
		local ids={"player"};for _,model in ipairs(members()) do table.insert(ids,tostring(model:GetAttribute("AdventurerId"))) end
		selectedId=ids[(table.find(ids,selectedId) or 1)%#ids+1]
	end
	local nextActor=Instance.new("TextButton");nextActor.Name="CycleActor";nextActor.Size=UDim2.fromOffset(96,44)
	nextActor.Position=UDim2.fromOffset(0,48);nextActor.BackgroundColor3=Art.UI.Card;nextActor.TextColor3=Art.UI.Text
	nextActor.Font=Enum.Font.GothamMedium;nextActor.TextSize=12;nextActor.TextWrapped=true;nextActor.Parent=selection
	Instance.new("UICorner",nextActor);connect(nextActor.Activated,cycle)
	connect(player.CharacterRemoving,function() selectedId="player" end)
	local buttons=Instance.new("Frame"); buttons.Name="CombatButtons"; buttons.AnchorPoint=Vector2.new(1,.5)
	buttons.Position=UDim2.new(1,-8,.5,0); buttons.Size=UDim2.fromOffset(116,112); buttons.BackgroundTransparency=1; buttons.Parent=gui
	local function menuOpen(): boolean
		return MenuRouter.isBlocking()
	end
	local function send(action: string)
		if menuOpen() or Input:GetFocusedTextBox() or player:GetAttribute("NoviceTrialHUDActive")==true then return end
		local c=selected()
		if not c or not c:GetAttribute("ClassId") or (c:GetAttribute("CombatHealth") or 0)<=0 then return end
		remote:FireServer({action=action,actorId=selectedId})
	end
	local function button(name: string,y: number,action: string): TextButton
		local b=Instance.new("TextButton"); b.Name=name; b.Position=UDim2.fromOffset(0,y); b.Size=UDim2.fromOffset(116,52)
		b.BackgroundColor3=Art.UI.Button; b.TextColor3=Art.UI.Text; b.Font=Enum.Font.GothamBold; b.TextSize=14; b.TextWrapped=true; b.Parent=buttons
		local round=Instance.new("UICorner"); round.Parent=b
		connect(b.Activated,function() send(action) end)
		return b
	end
	local basic=button("BasicAttack",0,"Basic")
	local skills={button("Skill1",60,"Ability1"),button("Skill2",120,"Ability2"),button("Skill3",180,"Ability3")}
	local orders=Instance.new("Frame");orders.Name="CompanionOrders";orders.AnchorPoint=Vector2.new(.5,1)
	orders.Size=UDim2.new(.9,0,0,44);orders.BackgroundTransparency=1;orders.Parent=gui
	local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(360,44);limit.Parent=orders
	local orderButtons: {TextButton}={}
	for index,action in ipairs({"Focus","Regroup","Retreat"}) do
		local b=Instance.new("TextButton");b.Name=action;b.Size=UDim2.new(1/3,-4,1,0);b.Position=UDim2.new((index-1)/3,2,0,0)
		b.Font=Enum.Font.GothamMedium;b.TextSize=12;b.TextWrapped=true;b.TextColor3=Art.UI.Text;b.Parent=orders;Instance.new("UICorner",b)
		local padding=Instance.new("UIPadding");padding.PaddingLeft=UDim.new(0,26);padding.PaddingRight=UDim.new(0,3);padding.Parent=b
		local icon=require(script.Parent.Parent.UI.SymbolIcon)(b,"ui.combat."..(if action=="Focus" then "focus_target" else string.lower(action)),18,Art.UI.Accent)
		if icon then icon.Position=UDim2.new(0,-21,.5,-9) end
		connect(b.Activated,function() send(action) end);table.insert(orderButtons,b)
	end
	connect(Input.InputBegan,function(key,processed)
		if processed then return end
		local action=Bindings.action(key.KeyCode.Name,key.UserInputType.Name)
		if action=="Cycle" then
			cycle()
		elseif action then send(action) end
	end)
	connect(remote.OnClientEvent,function(code: string)
		if code~="OK" then status=code; statusUntil=os.clock()+1.5 end
	end);
	connect((remotes:WaitForChild("State") :: RemoteEvent).OnClientEvent,function(view)
		if view.data then language=view.data.language or "en" end
	end)
	local animated: Model?=nil
	local joints: {Motor6D | AnimationConstraint}={}
	local bases: {[Motor6D | AnimationConstraint]: CFrame}={}
	local function transform(joint: Motor6D | AnimationConstraint,value: CFrame)
		if joint:IsA("Motor6D") then joint.Transform=value
		elseif joint:IsA("AnimationConstraint") then joint.Transform=value end
	end
	-- Remove last frame's overlay before Animator evaluates locomotion.
	connect(Run.PreAnimation,function()
		for joint,base in pairs(bases) do if joint.Parent then transform(joint,base) end end
		table.clear(bases)
	end)
	local elapsed=0
	connect(Run.PreSimulation,function(dt)
		local c=player.Character
		if c~=animated or #joints==0 then
			animated=c; table.clear(joints)
			if c then for _,v in ipairs(c:GetDescendants()) do
				if (v:IsA("Motor6D") or v:IsA("AnimationConstraint")) and (v.Name:find("Shoulder") or v.Name:find("Hip") or v.Name:find("Elbow") or v.Name=="RootJoint" or v.Name=="Waist" or v.Name=="Neck") then table.insert(joints,v) end
			end end
		end
		-- Animator refreshes locomotion before PreSimulation; overlay a complete cast phrase.
		if c then
			local trial=workspace:FindFirstChild("NoviceTrial_"..player.UserId)
			local archive=workspace:FindFirstChild("ArchiveEncounter_"..player.UserId)
			local source=if archive and archive:GetAttribute("ArchiveHeartArena")==true and archive:GetAttribute("OwnerUserId")==player.UserId then archive elseif trial and trial:GetAttribute("NoviceTrialArena")==true and trial:GetAttribute("OwnerUserId")==player.UserId then trial else c
			local age=workspace:GetServerTimeNow()-(source:GetAttribute("ActionAt") or 0)
			for _,joint in ipairs(joints) do
				local action=pose(tostring(source:GetAttribute("ClassId")),tostring(source:GetAttribute("ActionEffect")),age,joint.Name)
				if action then bases[joint]=joint.Transform;transform(joint,action*joint.Transform) end
			end
		end
		elapsed+=dt; if elapsed<.1 then return end; elapsed=0
		local function T(key: string): string return Localization.translate(language,key) end
		-- Animation remains on the player's body. Only commands/HUD follow selection.
		c=selected()
		local viewport=gui.AbsoluteSize
		local layout=Layout(viewport.X,viewport.Y)
		local compact=layout.compact
		-- Short viewports use a two-column pad; tall ones retain a narrow side rail.
		buttons.AnchorPoint=Vector2.new(1,if layout.topAligned then 0 else .5)
		buttons.Position=if layout.topAligned then UDim2.new(1,-8,0,64) else UDim2.new(1,-8,.5,0)
		buttons.Size=UDim2.fromOffset(layout.padWidth,layout.padHeight)
		local controls={basic,skills[1],skills[2],skills[3]}
		for index,b in ipairs(controls) do
			b.Size=UDim2.fromOffset(layout.buttonWidth,52)
			b.Position=if compact then UDim2.fromOffset(((index-1)%2)*(layout.buttonWidth+8),math.floor((index-1)/2)*56) else UDim2.fromOffset(0,(index-1)*60)
		end
		health.Position=UDim2.new(.5,0,1,-layout.healthBottom)
		health.Size=UDim2.new(layout.healthScale,0,0,layout.healthHeight)
		local playerRoot=player.Character and player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local regional=player:GetAttribute("RegionalCombatEnabled")
		local inCity=playerRoot~=nil and (City.contains(playerRoot.Position.X,playerRoot.Position.Z) or
			(City.region(playerRoot.Position.X,playerRoot.Position.Z)~=nil and not (type(regional)=="string" and City.regionCombat(regional,playerRoot.Position.X,playerRoot.Position.Y,playerRoot.Position.Z))))
		local visible=not menuOpen() and player:GetAttribute("NoviceTrialHUDActive")~=true and workspace:FindFirstChild("NoviceCourse_"..player.UserId)==nil; health.Visible=visible; buttons.Visible=visible and not inCity and c~=nil and c:GetAttribute("ClassId")~=nil
		selection.Visible=visible
		local grid=layout.grid
		selection.Size=UDim2.fromOffset(layout.selectionWidth,layout.selectionHeight)
		local party=members()
		local inputMode=Bindings.mode(Input:GetLastInputType().Name)
		nextActor.Visible=layout.collapsed and #party>0
		nextActor.Text=T("Next hero")..Bindings.hint("Cycle",inputMode)
		orders.Position=UDim2.new(.5,0,1,-layout.ordersBottom)
		orders.Visible=visible and not inCity and selectedId~="player" and c~=nil
		for _,b in ipairs(orderButtons) do
			b.Text=T(b.Name)..Bindings.hint(b.Name,inputMode)
			b.Active=c~=nil and (c:GetAttribute("CombatHealth") or 0)>0;b.Selectable=b.Active
			b.BackgroundColor3=if c and c:GetAttribute("CompanionOrder")==b.Name then Art.UI.Button else Art.UI.Card
		end
		for index,card in ipairs(cards) do
			card.Size=UDim2.fromOffset(layout.cardWidth,44)
			card.Position=if layout.collapsed then UDim2.fromOffset(0,0) elseif grid then UDim2.fromOffset(((index-1)%layout.columns)*(layout.cardWidth+6),math.floor((index-1)/layout.columns)*48) else UDim2.fromOffset(0,(index-1)*48)
			local actor=if index==1 then player.Character else party[index-1]
			local id=if index==1 then "player" elseif actor then actor:GetAttribute("AdventurerId") else nil
			card.Visible=actor~=nil and (not layout.collapsed or id==selectedId);card:SetAttribute("ActorId",id)
			card.BackgroundColor3=if id==selectedId then Art.UI.Button else Art.UI.Card
			-- Preserve two readable lines even in the three-column short-screen roster.
			local narrow=layout.cardWidth<110
			local portrait=card:FindFirstChildWhichIsA("ViewportFrame")
			if portrait then portrait.Size=UDim2.fromOffset(if narrow then 26 else 38,if narrow then 26 else 38);portrait.Position=UDim2.fromOffset(3,if narrow then 9 else 3) end
			cardLabels[index].Position=UDim2.fromOffset(if narrow then 32 else 44,0)
			cardLabels[index].Size=UDim2.new(1,if narrow then -35 else -47,1,0)
			if visible and card.Visible then portraits[index].update(actor) end
			cardLabels[index].Text=(if index==1 then T("Player") else T(tostring(actor and actor:GetAttribute("ClassId") or "")))
				.."\n"..tostring(actor and actor:GetAttribute("CombatHealth") or "–").." HP"
		end
		basic.Text=T("Attack")..Bindings.hint("Basic",inputMode)
		local alive=c~=nil and c:GetAttribute("ClassId")~=nil and (c:GetAttribute("CombatHealth") or 0)>0
		basic.Active=alive;basic.Selectable=alive;basic.AutoButtonColor=alive
		for slot,b in ipairs(skills) do
			local name=c and c:GetAttribute("Skill"..slot.."Name")
			local cd=if c then c:GetAttribute("Skill"..slot.."Cooldown") or 0 else 0
			b.Text=if name then T(tostring(name))..(if cd>0 then " "..cd.."s" else Bindings.hint("Ability"..slot,inputMode)) else T(if slot==2 then (if c and c:GetAttribute("NoParentArt") then "No art in this slot" else "Unlock path art") elseif slot==3 then "Unlock master art" else "Starter skill")
			b.Active=alive and name~=nil and cd==0; b.Selectable=b.Active; b.AutoButtonColor=b.Active
			b.BackgroundColor3=if b.Active then Art.UI.Button else Art.UI.Card
			b.TextColor3=if name then Art.UI.Text else Art.UI.Muted
		end
		if c and c:GetAttribute("ClassId") then
			health.Text=T(tostring(c:GetAttribute("ClassPath") or c:GetAttribute("ClassId"))).." · Lv"..tostring(c:GetAttribute("Level")).." · HP "..tostring(c:GetAttribute("CombatHealth")).."/"..tostring(c:GetAttribute("CombatMaxHealth"))
				.."\n"..(if os.clock()<statusUntil then T(status) elseif c:GetAttribute("CombatState")=="Downed" then T("Downed").." · "..T("Recovering at guild") elseif selectedId~="player" then T("Companion command · shared AI cooldown") else tostring(c:GetAttribute("XP")).." XP"..(if #party>0 and inputMode~="Touch" then " · "..T("Next hero")..Bindings.hint("Cycle",inputMode) else ""))
		else health.Text=T("Select a class in Guild") end
	end)
	local function cleanup()
		for _,connection in ipairs(connections) do connection:Disconnect() end;table.clear(connections)
		for joint,base in pairs(bases) do if joint.Parent then transform(joint,base) end end
		table.clear(bases);table.clear(joints);table.clear(companions)
	end
	gui.Destroying:Connect(cleanup)
	return {Destroy=function() cleanup();gui:Destroy() end}
end
