--!strict
-- Preset recognition art only; no user text, entitlements or gameplay stats.
local V=Vector3.new
local mottos={together={"Together we rise","เติบโตไปด้วยกัน"},courage={"Courage leads us","ก้าวไปด้วยความกล้า"},discovery={"Seek new horizons","ค้นหาขอบฟ้าใหม่"}}
local crests={sun=true,oak=true,compass=true}
return function(hall:Model,data:any)
 local s=data and data.progression and data.progression.campaign
 local choices=s and s.choices
 local language=if data and (data.language=="th"or (data.settings and data.settings.language=="th"))then "th"else "en"
 local valid=s and s.claimed>=6 and choices and crests[choices.choose_crest]and mottos[choices.choose_motto]
 local stamp=if valid then choices.choose_crest..":"..choices.choose_motto..":"..language else ""
 if hall:GetAttribute("GuildIdentityStamp")==stamp then return end
 hall:SetAttribute("GuildIdentityStamp",stamp)
 for _,banner in ipairs(hall:GetDescendants())do if banner:IsA("Model")and banner.Name=="GuildBanner"then
  local old=banner:FindFirstChild("RecognizedCrest");if old then old:Destroy()end
  local cloth=banner:FindFirstChild("Burgundy") :: BasePart?
  local priorText=cloth and cloth:FindFirstChild("GuildMotto");if priorText then priorText:Destroy()end
  for _,name in ipairs({"GuildDiamond","CrestBlade"})do local p=banner:FindFirstChild(name);if p and p:IsA("BasePart")then p.Transparency=if valid then 1 else 0 end end
  if not valid or not cloth then continue end
  local model=Instance.new("Model");model.Name="RecognizedCrest";model:SetAttribute("CrestId",choices.choose_crest);model.Parent=banner
  local scale=banner:GetScale();local cf=banner:GetPivot();local gold=Color3.fromRGB(232,192,99);local ink=Color3.fromRGB(29,48,65)
  local function part(name:string,size:Vector3,pos:Vector3,color:Color3,angle:number?,shape:Enum.PartType?):Part
   local p=Instance.new("Part");p.Name=name;p.Size=size*scale;p.CFrame=cf*CFrame.new(pos*scale)*CFrame.Angles(0,0,angle or 0)
   p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=model;return p
  end
  part("CrestBacking",V(1.9,1.9,.13),V(0,5.15,.2),ink,math.pi/4)
  local crest=choices.choose_crest
  if crest=="sun"then
   part("SunCore",V(.85,.85,.25),V(0,5.15,.34),gold,nil,Enum.PartType.Ball)
   for i=0,7 do local a=i*math.pi/4;part("SunRay",V(.17,.48,.15),V(math.sin(a)*.87,5.15+math.cos(a)*.87,.34),gold,-a)end
  elseif crest=="oak"then
   part("OakTrunk",V(.27,1.15,.15),V(0,4.88,.34),gold)
   for _,x in ipairs({-.43,0,.43})do part("OakLeaf",V(.78,.92,.2),V(x,5.52-math.abs(x)*.3,.34),Color3.fromRGB(108,197,148),if x==0 then 0 else x,nil)end
   part("OakRoots",V(.95,.16,.15),V(0,4.42,.34),gold)
  else
   for i=0,3 do local a=i*math.pi/2;part("CompassPoint",V(.25,.75,.15),V(math.sin(a)*.55,5.15+math.cos(a)*.55,.33),if i%2==0 then gold else Color3.fromRGB(109,201,218),-a)end
   part("CompassCenter",V(.44,.44,.2),V(0,5.15,.43),gold,math.pi/4)
  end
  local gui=Instance.new("SurfaceGui");gui.Name="GuildMotto";gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(250,380);gui.LightInfluence=.3;gui.Parent=cloth
  local label=Instance.new("TextLabel");label.Name="Motto";label.BackgroundTransparency=1;label.Position=UDim2.fromScale(.04,.73);label.Size=UDim2.fromScale(.92,.24)
  label.Text=mottos[choices.choose_motto][if language=="th"then 2 else 1];label.Font=Enum.Font.GothamMedium;label.TextSize=24;label.TextWrapped=true;label.TextColor3=Color3.fromRGB(255,238,193);label.Parent=gui
 end end
end
