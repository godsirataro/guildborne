--!strict
-- Isolated UI; synthetic inventories, captured callbacks, no gameplay requests.
return function():any
 local player=game.Players.LocalPlayer;local draw=require(player.PlayerScripts.Client.UI.ExpansionView)
 local locale=require(game.ReplicatedStorage.Shared.Config.Localization);local rules=require(game.ReplicatedStorage.Shared.Data.Expansion)
 local describe=require(game.ReplicatedStorage.Shared.Data.CraftingViewState)
 local snapshot:any=nil;local c=game.ReplicatedStorage.GuildborneRemotes.State.OnClientEvent:Connect(function(v)snapshot=v end)
 local t=os.clock();repeat task.wait(.1)until snapshot or os.clock()-t>7;c:Disconnect();assert(snapshot)
 local catalog=snapshot.catalog;assert(catalog.StackLimit)
 local gui=Instance.new("ScreenGui");gui.Name="CraftingFixture";gui.Parent=player.PlayerGui
 local host=Instance.new("Frame");host.Size=UDim2.fromOffset(240,800);host.Parent=gui
 local views=0;local recipes=0;local previews=0;local callbacksChecked=0
 local ok,result=pcall(function():any
  for _,height in ipairs({160,800}) do for _,width in ipairs({240,640}) do for _,language in ipairs({"en","th"}) do
   host.Size=UDim2.fromOffset(width,height)
   local callbacks:{[Instance]:any}={};local actions:{any}={}
   local function T(s:string,p:any?):string return locale.translate(language,s,p) end
   local function text(parent:Instance,s:string,size:number?):TextLabel
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y;l.TextWrapped=true;l.Font=Enum.Font.Gotham;l.TextSize=size or 18;l.Text=T(s);l.Parent=parent;return l
   end
   local function card(parent:Instance,title:string):Frame
    local f=Instance.new("Frame");f.Size=UDim2.new(1,-4,0,0);f.AutomaticSize=Enum.AutomaticSize.Y;f.Parent=parent
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,12);pad.PaddingRight=UDim.new(0,12);pad.Parent=f
    local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,10);layout.Parent=f;text(f,title,20);return f
   end
   local function button(parent:Instance,s:string,active:boolean,callback:any):TextButton
    local b=Instance.new("TextButton");b.Size=UDim2.new(1,0,0,52);b.Font=Enum.Font.GothamMedium;b.TextSize=17;b.TextWrapped=true;b.Text=T(s);b.Active=active;b.Selectable=active;b.Parent=parent;callbacks[b]=callback;return b
   end
   local render=draw({scroll=host,T=T,text=text,card=card,button=button,act=function(action,args)table.insert(actions,{action=action,args=args})end})
   for _,mode in ipairs({"ready","forge","hall","materials","equipment","stack","sequence","busy"}) do
    host:ClearAllChildren();table.clear(callbacks);table.clear(actions)
    local data:any={hallLevel=3,adventurers={},inventory={stacks={},equipment={},nextEquipmentSequence=1},expansion={buildings={forge={kind="forge",x=6,z=-4,rotation=0}},storage={}}}
    for _,id in ipairs({"timber","stone","iron_ore","iron_ingot","herb"}) do data.inventory.stacks[id]=1000 end
    if mode=="forge"then data.expansion.buildings={}
    elseif mode=="hall"then data.hallLevel=1
    elseif mode=="materials"then data.inventory.stacks={}
    elseif mode=="equipment"then for i=1,catalog.EquipmentLimit do data.inventory.equipment[tostring(i)]={} end
    elseif mode=="stack"then data.inventory.stacks.iron_ingot=catalog.StackLimit
    elseif mode=="sequence"then data.inventory.nextEquipmentSequence=1000000000 end
    render("Base",data,catalog,mode=="busy");task.wait(.06)
    for _,id in ipairs(rules.RecipeOrder) do
     local state=describe(data,catalog,rules,id,mode=="busy")
     local f=assert(host:FindFirstChild("Recipe_"..id,true));local b=assert(f:FindFirstChild("Craft_"..id)) :: TextButton
     assert(b.Active==state.canCraft and b.Selectable==b.Active,"Craft readiness "..id)
     if state.problem then assert(b.Text==T(state.problem,state.params),"Localized reason") end
     local view=assert(f:FindFirstChild("ItemPreview",true)) :: ViewportFrame;assert(view.CurrentCamera and view:GetAttribute("ItemId")==state.itemId);previews+=1
     for _,material in ipairs(state.materials) do
      local label=assert(f:FindFirstChild("Material_"..material.id,true)) :: TextLabel
      assert(label.Text==T("{item}: {owned}/{needed}",{item=T(catalog.Items[material.id].Name),owned=material.owned,needed=material.needed}))
     end
     if mode=="ready"then callbacks[b]();local a=actions[#actions];assert(a.action=="CraftItem" and a.args.recipeId==id);callbacksChecked+=1 end
     recipes+=1
    end
    for _,l in ipairs(host:GetDescendants()) do if l:IsA("TextLabel")or l:IsA("TextButton")then
     assert(l.TextBounds.X<=l.AbsoluteSize.X+1 and l.TextBounds.Y<=l.AbsoluteSize.Y+1,"Clipped "..l.Name.." "..language.." "..width.." "..l.Text)
    end end
    views+=1
   end
  end end end
  return {views=views,recipes=recipes,previews=previews,callbacks=callbacksChecked,languages={"en","th"},widths={240,640},heights={160,800},profileWrites=0}
 end)
 gui:Destroy();assert(ok,tostring(result));return result
end
