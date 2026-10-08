--!strict
local Players=game:GetService("Players")
local Rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
local Art=require(game.ReplicatedStorage.Shared.Config.Art)
local Layout=require(game.ReplicatedStorage.Shared.Config.GuildIslandLayout)
local canPlace=require(game.ReplicatedStorage.Shared.Data.LandBuildingPlacement)(Rules,require(game.ReplicatedStorage.Shared.Data.IslandPlacement),Layout)
return function(send: any,T: any,closed: any)
	local player=Players.LocalPlayer;local gui: ScreenGui?=nil;local ghost: Part?=nil
	local x,z,rotation=6,-4,0;local kind="warehouse";local moving: string?=nil;local data: any=nil
	local restoring=false
	local hallMode=false
	local furnitureMode=false
	local step=1;local stepButton:TextButton?=nil
	local label: TextLabel?=nil;local place: TextButton?=nil
	local area="starter";local areas:{string}={"starter"};local areaButton:TextButton?=nil
	local function bounds(): (number,number,number,number)
		if area=="hall-home" then return -2,-2,-4.5,-4.5 end
		local def=Rules.footprint(kind);local w,d=def.Width,def.Depth;if rotation%2==1 then w,d=d,w end
		local plot=Layout.Plots[area]
		if not plot then return 6,12-w,-4,5-d end
		return (plot.x-plot.width/2)/8,(plot.x+plot.width/2)/8-w,(plot.z-plot.depth/2)/8,(plot.z+plot.depth/2)/8-d
	end
	local function stop()
		if workspace.CurrentCamera then workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end
		if ghost then ghost:Destroy();ghost=nil end;if gui then gui:Destroy();gui=nil end;closed()
	end
	local function update()
		if not ghost or not data then return end
		local plot: Instance?=nil;for _,p in ipairs(workspace.GuildborneWorld:GetChildren()) do if p:GetAttribute("OwnerUserId")==player.UserId then plot=p;break end end
		if not plot then return end
		local origin=plot:GetAttribute("PlotOrigin") :: Vector3
		local def=Rules.footprint(kind);local w,d=def.Width,def.Depth;if rotation%2==1 then w,d=d,w end
		ghost.CFrame=CFrame.new(origin+Vector3.new((x+w/2)*8,if furnitureMode then math.max(.2,def.Height)/2 elseif hallMode then 7 else 4,(z+d/2)*8))*CFrame.Angles(0,rotation*math.pi/2,0)
		local valid,reason=canPlace(data,kind,x,z,rotation,if restoring then nil else moving)
		ghost.Color=if valid then Color3.fromRGB(105,205,145) else Color3.fromRGB(226,100,86)
		if label then label.Text=T(def.Name).." · "..x..","..z.." · "..rotation*90 .."°\n"..T(if valid then "Placement ready" else ({PlotLocked="Plot quests required",ReservedAccess="Blocked or reserved path",BuildingOverlap="Blocked or reserved path",EntranceBlocked="Keep the entrance clear",AccessBlocked="Keep a walking route open"})[reason] or "Blocked or reserved path") end
		if areaButton then areaButton.Text=T("Build area")..": "..T(if area=="starter" then "Starter plot" elseif area=="hall-home" then "Original Hall site" else ({grove="Grove Terrace",quarry="Quarry Terrace",summit="Summit Terrace"})[area]) end
		if place then place.Active=valid;place.BackgroundColor3=if valid then Art.UI.Button else Art.UI.Card end
		if stepButton then stepButton.Text=T(if step==1 then "Move step: 8 studs" else "Move step: 2 studs") end
	end
	local B={}
	function B.open(snapshot: any,buildingKind: string,id: string?)
		if gui then stop() end;data=snapshot;kind=buildingKind;moving=id
		hallMode=kind=="guildHall"
		furnitureMode=Rules.Furniture[kind]~=nil
		local furniture=id and data.expansion.furniture and data.expansion.furniture[id]
		restoring=if furnitureMode then furniture~=nil and furniture.stored else id~=nil and data.expansion.storage~=nil and data.expansion.storage[id]~=nil
		local b=if furnitureMode then furniture elseif hallMode then data.expansion.hallPosition or {x=-2,z=-4.5,rotation=0} else id and (if restoring then data.expansion.storage[id] else data.expansion.buildings[id]);x=if b then b.x else 6;z=if b then b.z else -4;rotation=if b then b.rotation else 0
		if furnitureMode then step=.25 end
		areas={"starter"};area="starter"
		if hallMode then table.insert(areas,1,"hall-home");if not data.expansion.hallPosition then area="hall-home" end end
		for _,plotId in ipairs({"grove","quarry","summit"}) do
			local state=data.guildLand and data.guildLand.plots[plotId]
			if state and state.status=="Buildable" then
				table.insert(areas,plotId);local d=Layout.Plots[plotId]
				if b and b.x<0 and b.z*8>=d.z-d.depth/2 and b.z*8<d.z+d.depth/2 then area=plotId end
			end
		end
		local screen=Instance.new("ScreenGui");screen.Name="GuildborneBuildMode";screen.ResetOnSpawn=false;screen.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;screen.Parent=player.PlayerGui;gui=screen
		local def=Rules.footprint(kind)
		local preview=Instance.new("Part");preview.Name="BuildingPreview";preview.Size=Vector3.new(def.Width*8-(if furnitureMode then .2 else 2),if furnitureMode then math.max(.2,def.Height) elseif hallMode then 14 else 8,def.Depth*8-(if furnitureMode then .2 else 2));preview.Anchored=true;preview.CanCollide=false;preview.CanTouch=false;preview.CanQuery=false;preview.Transparency=.55;preview.Material=Enum.Material.SmoothPlastic;preview.Parent=workspace;ghost=preview
		local outline=Instance.new("SelectionBox");outline.Adornee=preview;outline.LineThickness=.06;outline.Color3=Color3.fromRGB(189,240,200);outline.Parent=preview
		local frame=Instance.new("Frame");frame.AnchorPoint=Vector2.new(.5,1);frame.Position=UDim2.new(.5,0,1,-8);frame.Size=UDim2.new(1,-16,0,228);frame.BackgroundColor3=Art.UI.Background;frame.Parent=gui
		local max=Instance.new("UISizeConstraint");max.MaxSize=Vector2.new(600,228);max.Parent=frame
		local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,60);title.BackgroundTransparency=1;title.TextColor3=Art.UI.Text;title.TextWrapped=true;title.TextSize=16;title.Font=Enum.Font.GothamMedium;title.Parent=frame;label=title
		local function button(name: string,column: number,row: number,fn: any): TextButton
			local p=Instance.new("TextButton");p.Name=name;p.Size=UDim2.new(.25,-5,0,48);p.Position=UDim2.new(column*.25,2,0,64+row*54);p.BackgroundColor3=Art.UI.Button;p.TextColor3=Art.UI.Text;p.Font=Enum.Font.GothamMedium;p.TextSize=15;p.TextWrapped=true;p.Text=T(name);p.Parent=frame
			p.Activated:Connect(function() if p.Active then fn();update() end end);return p
		end
		button("←",0,0,function() local lo=bounds();x=math.max(lo,x-step) end);button("→",1,0,function() local _,hi=bounds();x=math.min(hi,x+step) end)
		button("↑",2,0,function() local _,_,lo=bounds();z=math.max(lo,z-step) end);button("↓",3,0,function() local _,_,_,hi=bounds();z=math.min(hi,z+step) end)
		button("Rotate",0,1,function() rotation=if area=="hall-home" then 0 else (rotation+1)%4 end)
		place=button("Place",1,1,function()
			if not canPlace(data,kind,x,z,rotation,if restoring then nil else moving) then return end
			local args: any={x=x,z=z,rotation=rotation};if furnitureMode then args.furnitureId=moving elseif not hallMode then if moving then args.buildingId=moving else args.kind=kind end end
			send(if furnitureMode then "PlaceFurniture" elseif hallMode then "MoveGuildHall" elseif restoring then "RestoreBuilding" elseif moving then "MoveBuilding" else "PlaceBuilding",args);stop()
		end)
		button("Cancel",2,1,stop)
		areaButton=button("Build area",3,1,function()
			local index=table.find(areas,area) or 1;area=areas[index%#areas+1]
			if area=="hall-home" then rotation=0 end
			local lo,_,top=bounds();local padding=if area=="starter" or area=="hall-home" then 0 elseif hallMode then 1 else 2
			x=lo+padding;z=top+padding;update()
			if ghost and workspace.CurrentCamera then workspace.CurrentCamera.CFrame=CFrame.lookAt(ghost.Position+Vector3.new(0,55,42),ghost.Position) end
		end)
		local movementStep=button("Move step: 8 studs",0,2,function()step=if step==1 then .25 else 1 end)
		movementStep.Size=UDim2.new(.5,-5,0,48);stepButton=movementStep
		update()
		if workspace.CurrentCamera and ghost then workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable;workspace.CurrentCamera.CFrame=CFrame.lookAt(ghost.Position+Vector3.new(0,65,48),ghost.Position) end
	end
	function B.update(snapshot: any) data=snapshot;update() end
	player.CharacterRemoving:Connect(function() if gui then stop() end end)
	return B
end
