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
 rail.BorderSizePixel=0;rail.BackgroundColor3=C.Gold;rail.ZIndex=4;rail.Active=false;rail.Parent=card
 local ribbon=Instance.new("Frame");ribbon.Name="SelectedActorRibbon";ribbon.Size=UDim2.new(1,-8,0,2);ribbon.Position=UDim2.fromOffset(4,1)
 ribbon.BorderSizePixel=0;ribbon.BackgroundColor3=C.Primary;ribbon.ZIndex=4;ribbon.Active=false;ribbon.Parent=card
 local frame=Instance.new("Frame");frame.Name="PortraitMount";frame.BackgroundColor3=C.Background;frame.BorderSizePixel=0;frame.ZIndex=2;frame.Active=false;frame.Parent=card
 local portraitRim=Instance.new("UIStroke");portraitRim.Color=C.GoldShadow;portraitRim.Thickness=1;portraitRim.Parent=frame
 local number=Instance.new("TextLabel");number.Name="ActorSlot";number.BackgroundColor3=C.Background;number.BorderSizePixel=0
 number.Size=UDim2.fromOffset(12,12);number.Font=Theme.Fonts.Body;number.TextSize=10;number.TextColor3=C.Gold;number.ZIndex=5;number.Parent=card
 local gem=Instance.new("Frame");gem.Name="SelectedActorGem";gem.Size=UDim2.fromOffset(5,5);gem.Rotation=45
 gem.BackgroundColor3=C.Focus;gem.BorderSizePixel=0;gem.ZIndex=5;gem.Active=false;gem.Parent=card
 local gemRim=Instance.new("UIStroke");gemRim.Color=C.Gold;gemRim.Thickness=1;gemRim.Parent=gem
 local name=Instance.new("TextLabel");name.Name="ActorLabel";name.BackgroundTransparency=1;name.TextColor3=C.Text
 name.Font=Theme.Fonts.Body;name.TextXAlignment=Enum.TextXAlignment.Left;name.TextWrapped=false;name.TextTruncate=Enum.TextTruncate.AtEnd;name.ZIndex=4;name.Parent=card
 local healthText=Instance.new("TextLabel");healthText.Name="ActorHealth";healthText.BackgroundTransparency=1;healthText.TextColor3=C.Muted
 healthText.Font=Theme.Fonts.Body;healthText.TextSize=10;healthText.TextXAlignment=Enum.TextXAlignment.Left;healthText.TextTruncate=Enum.TextTruncate.AtEnd;healthText.ZIndex=4;healthText.Parent=card
 local function layout(width:number,height:number)
  local large=height>44;local portraitSize=if large then 48 else if width<110 then 26 else 32
  local tall=height>=68
  frame.Position=UDim2.fromOffset(3,2);frame.Size=UDim2.fromOffset(portraitSize+2,portraitSize+2)
  number.Position=UDim2.fromOffset(4,portraitSize-9);gem.Position=UDim2.fromOffset(portraitSize-1,portraitSize-2)
  name.TextWrapped=tall
  name.Position=UDim2.fromOffset(portraitSize+9,if tall then 4 elseif large then 7 else 2)
  name.Size=UDim2.new(1,-portraitSize-14,0,if tall then 34 elseif large then 22 else 19);name.TextSize=if width<110 then 12 else 13
  healthText.TextSize=if tall then 12 else 10
  healthText.Position=UDim2.fromOffset(portraitSize+9,if tall then 42 elseif large then 30 else 21)
  healthText.Size=UDim2.new(1,-portraitSize-14,0,if large then 16 else 13)
 end
 layout(138,44)
 return {name=name,layout=layout,update=function(chosen:boolean,slot:number,health:any,maximum:any)
  rim.Color=if chosen then C.Gold else C.GoldShadow;rim.Thickness=if chosen then 2 else 1
  portraitRim.Color=if chosen then C.GoldLight else C.GoldShadow
  rail.Visible=chosen;ribbon.Visible=chosen;gem.Visible=chosen;number.Text=tostring(slot);bar.update(health,maximum)
  healthText.Text=tostring(health or "–").." HP"
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
