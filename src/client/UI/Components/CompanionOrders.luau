--!strict
-- Presentation only: every action and selected state comes from the existing controller.
local Theme=require(script.Parent.Parent.DesignSystem.Theme)
local Bindings=require(game.ReplicatedStorage.Shared.Config.CombatBindings)
local C=Theme.Colors
local actions={"Focus","Regroup","Retreat","Hold","TacticBalanced","TacticDefensive"}
return function(parent:Instance,onAction:(string)->())
 local root=Instance.new("Frame");root.Name="CompanionOrders";root.BackgroundTransparency=1
 root.BorderSizePixel=0;root.Active=true;root.Visible=false;root.Parent=parent
 local buttons:{TextButton}={};local hints:{TextLabel}={};local labels:{TextLabel}={};local rails:{Frame}={}
 local connections:{RBXScriptConnection}={};local destroyed=false
 local function connect(signal:RBXScriptSignal,callback:any) table.insert(connections,signal:Connect(callback)) end
 for index,action in ipairs(actions) do
  local b=Instance.new("TextButton");b.Name=action;b.Text="";b.BorderSizePixel=0;b.BackgroundColor3=C.Surface
  b.TextColor3=C.Text;b.Font=Theme.Fonts.Body;b.TextSize=14;b.TextWrapped=true;b.TextScaled=true
  b.Active=false;b.Selectable=false;b.AutoButtonColor=false;b.Parent=root
  local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,4);corner.Parent=b
  local label=Instance.new("TextLabel");label.Name="OrderLabel";label.BackgroundTransparency=1;label.Active=false
  label.Position=UDim2.fromOffset(3,4);label.Font=Theme.Fonts.Body;label.TextSize=14;label.TextWrapped=true;label.TextScaled=true;label.Parent=b
  local fit=Instance.new("UITextSizeConstraint");fit.MinTextSize=10;fit.MaxTextSize=14;fit.Parent=label
  local rim=Instance.new("UIStroke");rim.Name="OrderRim";rim.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;rim.Thickness=1;rim.Parent=b
  local rail=Instance.new("Frame");rail.Name="SelectedOrder";rail.Size=UDim2.new(1,-12,0,3);rail.Position=UDim2.fromOffset(6,1)
  rail.BackgroundColor3=C.Gold;rail.BorderSizePixel=0;rail.Active=false;rail.Visible=false;rail.Parent=b
  local hint=Instance.new("TextLabel");hint.Name="BindingHint";hint.AnchorPoint=Vector2.new(0,1)
  hint.Position=UDim2.new(0,0,1,-2);hint.Size=UDim2.new(1,0,0,12);hint.BackgroundTransparency=1
  hint.Font=Theme.Fonts.Body;hint.TextSize=10;hint.TextColor3=C.Gold;hint.Active=false;hint.Parent=b
  local focused=false
  local function style()
   rim.Color=if focused then C.Focus elseif b:GetAttribute("SelectedOrder") then C.Gold elseif index<=4 then C.GoldShadow else C.Border
   rim.Thickness=if focused or b:GetAttribute("SelectedOrder") then 2 else 1
  end
  connect(b.SelectionGained,function()focused=true;style()end)
  connect(b.SelectionLost,function()focused=false;style()end)
  connect(b:GetAttributeChangedSignal("SelectedOrder"),style)
  connect(b.Activated,function() if not destroyed and root.Visible and b.Active then onAction(action) end end)
  table.insert(buttons,b);table.insert(hints,hint);table.insert(labels,label);table.insert(rails,rail);style()
 end
 local function update(layout:any,T:(string)->string,mode:string,enabled:boolean,order:string?,preset:string?)
  if destroyed then return end
  local r=layout.ordersRect;local columns=layout.orderColumns;local rows=math.ceil(#actions/columns)
  root.Position=UDim2.fromOffset(r.x,r.y);root.Size=UDim2.fromOffset(r.w,r.h)
  local width=(r.w-4*(columns-1))/columns;local height=(r.h-4*(rows-1))/rows
  for index,b in ipairs(buttons) do
   local col=(index-1)%columns;local row=math.floor((index-1)/columns)
   b.Position=UDim2.fromOffset(col*(width+4),row*(height+4));b.Size=UDim2.fromOffset(width,height)
   local chosen=order==b.Name or "Tactic"..tostring(preset)==b.Name
   b:SetAttribute("SelectedOrder",chosen);rails[index].Visible=chosen
   b.Active=enabled;b.Selectable=enabled;b.AutoButtonColor=enabled
   b.BackgroundColor3=if chosen then C.Primary else C.Surface;labels[index].TextColor3=if enabled then C.Text else C.Muted
   labels[index].Text=T(b.Name);hints[index].Text=Bindings.hint(b.Name,mode);hints[index].Visible=hints[index].Text~=""
   labels[index].Size=UDim2.new(1,-6,1,if hints[index].Visible then -19 else -8)
   -- Explicit neighbours survive a change from a row to a grid without scrolling.
   -- The checked-in API types omit nil for these nullable Instance references.
   -- Nil at an outer edge restores native navigation to the surrounding HUD.
   b.NextSelectionLeft=(if col>0 then buttons[index-1] else nil) :: any
   b.NextSelectionRight=(if col<columns-1 and index<#buttons then buttons[index+1] else nil) :: any
   b.NextSelectionUp=(if row>0 then buttons[index-columns] else nil) :: any
   b.NextSelectionDown=(if index+columns<=#buttons then buttons[index+columns] else nil) :: any
  end
 end
 local function cleanup()
  if destroyed then return end;destroyed=true
  for _,connection in ipairs(connections) do connection:Disconnect() end;table.clear(connections)
 end
 root.Destroying:Connect(cleanup)
 return {frame=root,buttons=buttons,update=update,Destroy=function()cleanup();root:Destroy()end}
end
