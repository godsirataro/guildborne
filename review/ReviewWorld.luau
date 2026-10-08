--!strict
-- Standalone review-world builder. No player data or ownership systems.
local services=game.ServerScriptService.Server.Services
local createEncounter=require(services.AdventureEncounterPreview)
local heroKit=require(services.HeroVisualKit)
local cosmeticKit=require(services.CosmeticVisualKit)
local interiorKit=require(services.CityInteriorKit)
local item=require(game.ReplicatedStorage.Shared.Data.ItemVisuals)
local V=Vector3.new
return function(offset:Vector3?):any
    local origin=offset or V(0,0,0)
    local root=Instance.new("Folder");root.Name="GuildborneArtReview";root.Parent=workspace
    local links={};local scenes={};local demos={};local disposed=false
    local function part(name:string,pos:Vector3,size:Vector3,color:Color3,collide:boolean?):Part
        local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=origin+pos;p.Color=color;p.Anchored=true
        p.CanCollide=collide==true;p.CanQuery=p.CanCollide;p.CanTouch=false;p.Parent=root;return p
    end
    local function label(anchor:BasePart,text:string)
        local gui=Instance.new("BillboardGui");gui.Name="ReviewLabel";gui.Size=UDim2.fromOffset(260,54);gui.StudsOffset=V(0,2,0);gui.MaxDistance=45;gui.Parent=anchor
        local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=.15;t.BackgroundColor3=Color3.fromRGB(25,35,49)
        t.TextColor3=Color3.fromRGB(239,225,190);t.Font=Enum.Font.GothamMedium;t.TextSize=14;t.TextWrapped=true;t.Text=text;t.Parent=gui
    end
    local function portal(name:string,pos:Vector3,target:Vector3?,demo:number?)
        local pad=part(name,pos,V(5,.4,5),Color3.fromRGB(83,165,181));label(pad,name)
        local prompt=Instance.new("ProximityPrompt");prompt.ActionText=if demo then "Run 18s demo" else "Travel";prompt.ObjectText=name
        prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=pad
        table.insert(links,{prompt=prompt,target=target,demo=demo,part=pad})
    end
    part("ReviewFloor",V(45,-.5,0),V(240,1,145),Color3.fromRGB(49,62,79),true)
    local spawn=Instance.new("SpawnLocation");spawn.Name="ReviewSpawn";spawn.Size=V(8,1,8);spawn.Position=origin+V(0,.5,45);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=root
    label(spawn,"GUILDBORNE · ART REVIEW\nNo saves, rewards or purchases")
    local function display(model:Model,pos:Vector3,title:string,scale:number?)
        if scale then model:ScaleTo(scale) end
        local cf,size=model:GetBoundingBox();local pivot=model:GetPivot();local bottom=cf.Position.Y-size.Y/2
        model:PivotTo(CFrame.new(origin+pos+V(0,pivot.Position.Y-bottom+.8,0)));model.Parent=root
        local p=part("DisplayPlinth",pos,V(6,.6,6),Color3.fromRGB(76,88,104),true);label(p,title)
    end
    local heroes=heroKit(false)
    for col,class in ipairs({"knight","warrior","archer","mage","priest"}) do
        for row=1,3 do
            local id=class.."_0"..row;local model=heroes:FindFirstChild(id) :: Model
            display(model,V(-42+(col-1)*14,0,15-(row-1)*17),id,1)
        end
    end
    heroes:Destroy()
    local cosmetics=cosmeticKit()
    for index,entry in ipairs(cosmetics:GetChildren()) do
        display(entry :: Model,V(-42+((index-1)%4)*17,0,-48-math.floor((index-1)/4)*14),entry.Name,.75)
    end
    cosmetics:Destroy()
    local interiors=interiorKit()
    for index,entry in ipairs(interiors:GetChildren()) do
        local room=entry :: Model;local pos=V(-80+(index-1)*75,0,-210)
        room:PivotTo(CFrame.new(origin+pos));room.Parent=root
        part("RoomFloor",pos+V(0,-.5,0),V(60,1,56),Color3.fromRGB(124,124,110),true)
        part("RoomRear",pos+V(0,10,-22),V(60,20,1),Color3.fromRGB(113,85,60),true)
        for _,side in ipairs({-1,1}) do part("RoomSide",pos+V(side*30,10,0),V(1,20,45),Color3.fromRGB(113,85,60),true) end
        portal(room:GetAttribute("BuildingName") :: string,V(52+(index-1)*22,.2,65),origin+pos+V(0,4,22))
        portal("Return to gallery",pos+V(0,.2,25),spawn.Position+V(0,4,0))
    end
    interiors:Destroy()
    local landmarks=require(script.Parent.CityLandmarkKit)()
    part("LandmarkGalleryFloor",V(0,-.5,-550),V(250,1,190),Color3.fromRGB(72,86,91),true)
    for index,entry in ipairs(landmarks:GetChildren()) do
        local model=entry :: Model;local pos=V(-70+((index-1)%3)*70,0,-510-math.floor((index-1)/3)*80)
        model:PivotTo(CFrame.new(origin+pos));model.Parent=root
        local sign=part("LandmarkSign",pos+V(0,.2,24),V(3,.4,3),Color3.fromRGB(83,165,181))
        label(sign,tostring(model:GetAttribute("CityIdentity")).." · architecture prototype")
    end
    landmarks:Destroy()
    portal("Six city landmarks",V(-44,.2,65),origin+V(0,4,-470))
    portal("Return to gallery",V(0,.2,-465),spawn.Position+V(0,4,0))
    local districts=require(script.Parent.CityDistrictKit)(require(script.Parent.CityLandmarkKit))
    local civicCast=require(services.CityCharacterKit)(false)
    local civicRoles={
        Crownford={"marshal_elian","QuestHall","Elian · Charter marshal"},
        Sylvaris={"arborist_vaela","Market","Vaela · Garden keeper"},
        Deepforge={"smith_borin","Forge","Borin · Forge steward"},
        Astralis={"cartographer_nyra","QuestHall","Nyra · Astral cartographer"},
        Crosshaven={"harbormaster_sela","Market","Sela · Harbormaster"},
        Ironroot={"steward_roka","Tavern","Roka · Friendly Orc community steward"},
    }
    for _,entry in ipairs(districts:GetChildren()) do
        local model=entry :: Model;local index=model:GetAttribute("CityIndex") :: number
        local pos=V(2000+((index-1)%3)*330,0,-math.floor((index-1)/3)*400)
        model:PivotTo(CFrame.new(origin+pos));model.Parent=root
        local cast=civicRoles[model.Name]
        local npc=civicCast:FindFirstChild(cast[1]) :: Model
        local serviceMarker=model:FindFirstChild(cast[2]) :: BasePart
        local npcPosition=Vector3.new(serviceMarker.Position.X+6,origin.Y+.3,serviceMarker.Position.Z-2)
        npc:PivotTo(CFrame.new(npcPosition)*CFrame.Angles(0,math.pi,0));npc:SetAttribute("CityId",model.Name);npc:SetAttribute("ReviewOnly",true);npc.Parent=model
        local sign=part("CivicCastLabel",npcPosition-origin+V(0,6.5,0),V(.1,.1,.1),Color3.new(1,1,1));sign.Transparency=1
        label(sign,cast[3].."\nAppearance review · service unbound")
        portal(model.Name.." city layout",V(-64,.2,45-(index-1)*20),origin+pos+V(0,4,108))
        portal("Return to gallery",pos+V(0,.2,116),spawn.Position+V(0,4,0))
    end
    districts:Destroy()
    civicCast:Destroy()
    local road=require(script.Parent.NoviceRoadKit)();local roadOrigin=V(0,0,-1200)
    road:PivotTo(CFrame.new(origin+roadOrigin));road.Parent=root
    portal("Crown Road chapter layout",V(-64,.2,65),origin+roadOrigin+V(0,4,214))
    portal("Return to gallery",roadOrigin+V(10,.2,214),spawn.Position+V(0,4,0))
    local ids={"stone","timber","iron_ore","iron_ingot","herb","training_sword","short_bow","apprentice_staff","iron_sword","knight_sword","mage_staff","leather_vest","guardian_plate","woven_robes","bronze_ring","vitality_charm","watchblade","oathblade","yew_longbow","tide_staff","dawn_crozier","scout_coat","runewoven_mantle","harbor_mail","vanguard_harness","pilgrim_robes","sentinel_seal","hunters_token","focus_prism","wardstone"}
    for index,id in ipairs(ids) do
        local model=item(id);assert(model,id);display(model,V(50+((index-1)%6)*14,0,22-math.floor((index-1)/6)*17),id)
    end
    for index,region in ipairs({"Greenwood","Ironveil","Ashen"}) do
        local location=origin+V(400+(index-1)*350,0,0);local scene=createEncounter(region,location,-9876);assert(scene)
        scene.model.Parent=root;table.insert(scenes,scene)
        local markers=scene.model:FindFirstChild("EncounterMarkers") :: Folder
        local arrival=markers:FindFirstChild("Arrival") :: BasePart
        portal(region,V(-22+(index-1)*22,.2,65),arrival.Position+V(0,4,0))
        portal("Return to gallery",arrival.Position-origin+V(8,.1,0),spawn.Position+V(0,4,0))
        local boss=nil;for _,a in ipairs(scene.actors) do if a.role=="Boss" then boss=a end;a.active=false end
        assert(boss)
        portal(region.." combat prototype",V(boss.home.x-origin.X+20,boss.home.y-origin.Y+.1,boss.home.z-origin.Z),nil,index)
    end
    local api={model=root,spawn=spawn,links=links,scenes=scenes}
    function api.StartDemo(index:number,now:number):boolean
        if disposed or demos[index] or not scenes[index] then return false end
        local scene=scenes[index];local targets={};local bodies={}
        for _,a in ipairs(scene.actors) do
            a.active=true;a.health=if a.role=="Boss" then a.maxHealth*.5 else a.maxHealth
            a.position=table.clone(a.home);a.nextAttack=0;a.nextPattern=0;a.patternCount=0;a.pendingPattern=nil
            a.model:PivotTo(CFrame.new(a.home.x,a.home.y,a.home.z))
            local z=a.home.z+math.min(8,a.range-1);local target={id="echo:"..a.id,owner=-9876,active=true,health=100000,maxHealth=100000,position={x=a.home.x,y=a.home.y,z=z}}
            table.insert(targets,target)
            local body=part("SyntheticTarget",V(a.home.x-origin.X,a.home.y-origin.Y+1.75,z-origin.Z),V(1.8,3.5,1.1),Color3.fromRGB(201,205,210));label(body,"Training echo · no player damage");table.insert(bodies,body)
        end
        demos[index]={targets=targets,bodies=bodies,ends=now+18};return true
    end
    function api.Step(now:number,dt:number)
        if disposed then return end
        for index,demo in pairs(demos) do
            local scene=scenes[index]
            if now>=demo.ends then
                for _,body in ipairs(demo.bodies) do body:Destroy() end
                for _,a in ipairs(scene.actors) do a.active=false end
                scene.Step({},now,dt);demos[index]=nil
            else scene.Step(demo.targets,now,dt) end
        end
    end
    function api.Destroy()
        if disposed then return end;disposed=true
        for _,scene in ipairs(scenes) do scene.Destroy() end
        root:Destroy();table.clear(demos)
    end
    return api
end
