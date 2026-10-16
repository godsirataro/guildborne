--!strict
-- Combat decoration consumes replicated values; it never issues combat commands.
local Theme=require(script.Parent.Parent.DesignSystem.Theme)
local QualityAsset=require(script.Parent.QualityAsset)
local C=Theme.Colors
local Chrome={}
function Chrome.surface(root:GuiObject):UIStroke
 root.BorderSizePixel=0
 local rim=Instance.new("UIStroke");rim.Name="CombatRim";rim.Color=C.GoldShadow;rim.Thickness=1;rim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;rim.Parent=root
 local shade=Instance.new("UIGradient");shade.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(158,174,199));shade.Rotation=90;shade.Parent=root
 QualityAsset.create(root,"panelBorder",UDim2.fromScale(1,1))
 return rim
end
function Chrome.health(parent:GuiObject)
 local track=Instance.new("Frame");track.Name="HealthTrack";track.Position=UDim2.new(0,7,1,-8);track.Size=UDim2.new(1,-14,0,4)
 track.BorderSizePixel=0;track.BackgroundColor3=C.Background;track.Active=false;track.Parent=parent
 local fill=Instance.new("Frame");fill.Name="CurrentHealth";fill.Size=UDim2.fromScale(0,1);fill.BorderSizePixel=0;fill.BackgroundColor3=Color3.fromRGB(125,172,136);fill.Parent=track
 return {update=function(health:any,maximum:any)
  local valid=type(health)=="number" and type(maximum)=="number" and maximum>0 and health==health and maximum==maximum
  track.Visible=valid
  local ratio=if valid then math.clamp(health/maximum,0,1) else 0
  fill.Size=UDim2.fromScale(ratio,1)
  fill.BackgroundColor3=if ratio<.25 then C.Primary:Lerp(C.Text,.2) else Color3.fromRGB(125,172,136)
  track:SetAttribute("Health",if valid then health else nil);track:SetAttribute("Maximum",if valid then maximum else nil)
 end}
end
function Chrome.actor(card:TextButton)
 local rim=Chrome.surface(card)
 local bar=Chrome.health(card)
 local rail=Instance.new("Frame");rail.Name="SelectedActorRail";rail.Size=UDim2.new(0,3,1,-10);rail.Position=UDim2.fromOffset(0,5)
 rail.BorderSizePixel=0;rail.BackgroundColor3=C.Gold;rail.Parent=card
 local number=Instance.new("TextLabel");number.Name="ActorSlot";number.BackgroundColor3=C.Background;number.BorderSizePixel=0
 number.Position=UDim2.fromOffset(3,3);number.Size=UDim2.fromOffset(15,15);number.Font=Theme.Fonts.Body;number.TextSize=10;number.TextColor3=C.Gold;number.ZIndex=3;number.Parent=card
 return {update=function(chosen:boolean,slot:number,health:any,maximum:any)
  rim.Color=if chosen then C.Gold else C.GoldShadow;rim.Thickness=if chosen then 2 else 1
  rail.Visible=chosen;number.Text=tostring(slot);bar.update(health,maximum)
  card:SetAttribute("SelectedActor",chosen)
 end}
end
function Chrome.skill(button:TextButton,slot:number)
 local rim=Chrome.surface(button)
 local ordinal=Instance.new("TextLabel");ordinal.Name="SkillSlot";ordinal.Size=UDim2.fromOffset(16,16);ordinal.Position=UDim2.fromOffset(3,2)
 ordinal.BackgroundTransparency=1;ordinal.Font=Theme.Fonts.Body;ordinal.TextSize=10;ordinal.TextColor3=C.Gold;ordinal.Text=if slot==0 then "A" else tostring(slot);ordinal.Parent=button
 local state=Instance.new("Frame");state.Name="SkillStateLine";state.Size=UDim2.new(1,-12,0,2);state.Position=UDim2.new(0,6,1,-4);state.BorderSizePixel=0;state.Parent=button
 local cooldown=Instance.new("TextLabel");cooldown.Name="CooldownValue";cooldown.AnchorPoint=Vector2.new(1,0);cooldown.Position=UDim2.new(1,-3,0,2)
 cooldown.Size=UDim2.fromOffset(34,14);cooldown.BackgroundColor3=C.Background;cooldown.BorderSizePixel=0
 cooldown.Font=Theme.Fonts.Body;cooldown.TextSize=10;cooldown.TextColor3=C.Text;cooldown.Parent=button
 local padding=Instance.new("UIPadding");padding.PaddingTop=UDim.new(0,12);padding.PaddingBottom=UDim.new(0,6);padding.PaddingLeft=UDim.new(0,5);padding.PaddingRight=UDim.new(0,5);padding.Parent=button
 return {update=function(enabled:boolean,remaining:number,learned:boolean)
  cooldown.Visible=learned and remaining>0;cooldown.Text=string.format("%.1fs",remaining)
  rim.Color=if enabled then C.Gold else C.GoldShadow
  state.BackgroundColor3=if enabled then C.Gold else if learned then C.Focus else C.Border
  button:SetAttribute("CooldownRemaining",remaining);button:SetAttribute("LearnedSlot",learned)
 end}
end
return Chrome
