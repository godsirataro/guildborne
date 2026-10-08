--!strict
-- Client-only frozen contact sheet sampled from the real effect factory.
return function():ScreenGui
 local player=game.Players.LocalPlayer
 local oldGui=player.PlayerGui:FindFirstChild("PathVFXGallery");if oldGui then oldGui:Destroy() end
 local gui=Instance.new("ScreenGui");gui.Name="PathVFXGallery";gui.IgnoreGuiInset=true;gui.DisplayOrder=10000;gui.Parent=player.PlayerGui
 local backdrop=Instance.new("Frame");backdrop.Size=UDim2.fromScale(1,1);backdrop.BackgroundColor3=Color3.fromRGB(13,20,31);backdrop.Parent=gui
 local title=Instance.new("TextLabel");title.Size=UDim2.new(1,0,0,36);title.BackgroundTransparency=1;title.Text="GUILDBORNE · ADVANCED ARTS · FROZEN PREVIEW";title.TextSize=16;title.TextColor3=Color3.fromRGB(234,207,151);title.Parent=backdrop
 local expansion=require(game.ReplicatedStorage.Shared.Data.Expansion)
 local factory=require(player.PlayerScripts.Client.Controllers.SkillEffects)
 local config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
 local oldQuality=workspace:GetAttribute(config.QualityAttribute);workspace:SetAttribute(config.QualityAttribute,"High")
 local active:Model?=nil;local spawned:{BasePart}={}
 local connection=workspace.ChildAdded:Connect(function(p:Instance)if p:IsA("BasePart") and p.Name=="GuildborneSkillEffect" then table.insert(spawned,p) end end)
 local ok,problem=pcall(function()
  for i,id in ipairs({"cleave_master","volley_master","bulwark_master","nova_master","renewal_master","judgment_master"}) do
   local origin=(workspace.CurrentCamera :: Camera).CFrame:PointToWorldSpace(Vector3.new(0,0,-14))
   local model=Instance.new("Model");active=model;model.Name="FrozenArtFixture"
   local root=Instance.new("Part");root.Anchored=true;root.CanCollide=false;root.CanQuery=false;root.CanTouch=false;root.Transparency=1;root.CFrame=CFrame.new(origin);root.Parent=model;model.PrimaryPart=root;model.Parent=workspace
   local ability=expansion.Abilities[id];model:SetAttribute("ClassId",ability.Class);model:SetAttribute("ActionEffect",ability.Effect);model:SetAttribute("ActionAbilityId",id);model:SetAttribute("ActionTargetPosition",origin+Vector3.new(0,0,-4))
   table.clear(spawned);factory()(model);task.wait(.18)
   local cell=Instance.new("Frame");cell.Position=UDim2.new(((i-1)%3)/3,4,math.floor((i-1)/3)*.44,40);cell.Size=UDim2.new(1/3,-8,.44,-6);cell.BackgroundColor3=Color3.fromRGB(26,36,50);cell.Parent=backdrop
   local viewport=Instance.new("ViewportFrame");viewport.Size=UDim2.new(1,0,1,-24);viewport.BackgroundTransparency=1;viewport.Ambient=Color3.new(1,1,1);viewport.LightColor=Color3.new(.6,.6,.6);viewport.Parent=cell
   local world=Instance.new("WorldModel");world.Parent=viewport
   for _,p in ipairs(spawned)do if p.Parent then local clone=p:Clone();clone.Parent=world end end
   for _,at in ipairs({origin,origin+Vector3.new(0,0,-4)})do
    local body=Instance.new("Part");body.Size=Vector3.new(.8,2,.6);body.Position=at;body.Anchored=true;body.Color=Color3.fromRGB(83,93,109);body.Parent=world
    local head=Instance.new("Part");head.Shape=Enum.PartType.Ball;head.Size=Vector3.new(.7,.7,.7);head.Position=at+Vector3.new(0,1.4,0);head.Anchored=true;head.Color=body.Color;head.Parent=world
   end
   local camera=Instance.new("Camera");camera.CFrame=CFrame.lookAt(origin+Vector3.new(8,7,10),origin+Vector3.new(0,0,-2));camera.FieldOfView=46;camera.Parent=viewport;viewport.CurrentCamera=camera
   local label=Instance.new("TextLabel");label.Size=UDim2.new(1,0,0,24);label.Position=UDim2.new(0,0,1,-24);label.BackgroundTransparency=1;label.Text=ability.Name;label.TextSize=14;label.TextColor3=Color3.fromRGB(240,222,184);label.Parent=cell
   model:Destroy();active=nil;task.wait(.9)
  end
 end)
 connection:Disconnect();if active then active:Destroy() end;for _,p in ipairs(spawned)do p:Destroy()end
 workspace:SetAttribute(config.QualityAttribute,oldQuality)
 if not ok then gui:Destroy();error(tostring(problem)) end
 return gui
end

