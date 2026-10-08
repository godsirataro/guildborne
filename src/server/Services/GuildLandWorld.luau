--!strict
-- Only committed opened plots create solid ground. Locked outlines are not land.
local Layout=require(game.ReplicatedStorage.Shared.Config.GuildIslandLayout)
local Catalog=require(script.Parent.Parent.Config.GuildLand)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local Kit=require(script.Parent.ArtKit)
local V=Vector3.new
local S={}
local function piece(parent:Instance,name:string,size:Vector3,position:Vector3,color:Color3,solid:boolean):Part
    local part=Kit.Part(parent,name,size,position,color,Enum.Material.SmoothPlastic,solid)
    part.CanTouch=false;return part
end
function S.sync(plot:any,data:any)
    if not data.guildLand then return end
    local folder=plot.model:FindFirstChild("GuildLand")
    if not folder then folder=Instance.new("Folder");folder.Name="GuildLand";folder.Parent=plot.model end
    for id,layout in pairs(Layout.Plots) do
        -- World.Update receives the server's safe UI projection, not payment records.
        local state=data.guildLand.plots[id];local opened=state~=nil and (state.opened==true or state.status=="Buildable")
        local existing=folder:FindFirstChild(id)
        if existing and existing:GetAttribute("Opened")==opened then continue end
        if existing then existing:Destroy() end
        local model=Instance.new("Model");model.Name=id;model:SetAttribute("Opened",opened);model:SetAttribute("OwnerUserId",plot.model:GetAttribute("OwnerUserId"));model.Parent=folder
        local origin=plot.origin
        if opened then
            local ground=piece(model,"Ground",V(layout.width,2,layout.depth),origin+V(layout.x,-1,layout.z),Color3.fromRGB(104,135,89),true)
            ground.Material=if id=="quarry" then Enum.Material.Slate else Enum.Material.Grass
            if id=="quarry" then ground.Color=Color3.fromRGB(131,135,123) end
            piece(model,"EarthSkirt",V(layout.width-2,4,layout.depth-2),origin+V(layout.x,-4,layout.z),Color3.fromRGB(111,91,67),true)
            local bridge=piece(model,"AccessBridge",V(16,.3,8),origin+V(-40,.15,layout.bridgeZ),Color3.fromRGB(164,141,104),true)
            bridge.Material=Enum.Material.WoodPlanks
        end
        local color=if opened then Color3.fromRGB(152,194,129) else Color3.fromRGB(185,164,103)
        for _,side in ipairs({-1,1}) do
            local edge=piece(model,"PlotBoundary",V(.2,.2,layout.depth),origin+V(layout.x+side*layout.width/2,.25,layout.z),color,false);edge.Material=Enum.Material.Neon
            local endEdge=piece(model,"PlotBoundary",V(layout.width,.2,.2),origin+V(layout.x,.25,layout.z+side*layout.depth/2),color,false);endEdge.Material=Enum.Material.Neon
        end
        local marker=piece(model,"PlotMarker",V(.2,.2,.2),origin+V(-38,2,layout.bridgeZ),color,false);marker.Transparency=1
        local name=Catalog[id].name
        local label=Kit.Label(marker,name..(if opened then " · Open" else " · Locked"),Locale.translate("th",name)..(if opened then " · เปิดแล้ว" else " · ยังไม่เปิด"),3)
        local billboard=label.Parent :: BillboardGui;billboard.Size=UDim2.fromOffset(220,64)
    end
end
return S
