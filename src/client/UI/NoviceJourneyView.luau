--!strict
local describe=require(game.ReplicatedStorage.Shared.Data.NoviceJourneyViewState)
return function(ui:any)
 local selected="Warrior";local confirmation:string?=nil;local previous:string?=nil
 return function(data:any,catalog:any,busy:boolean)
  local state=describe(data,catalog,busy);local T=ui.T
  local key=tostring(state.chapterId)..":"..state.stage..":"..tostring(state.trialClass)
  if previous~=key then confirmation=nil;previous=key end
  local head=ui.card(ui.scroll,state.title or "Your first adventure");head.Name="NoviceJourney"
  if state.stage=="Unavailable" then ui.text(head,"This journey is not available in this world.");return end
  if state.stage=="Complete" then ui.text(head,"Your guild is founded. Your first companion is ready.");return end
  ui.text(head,T("Chapter {current} / 6",{current=state.index}),15)
  if state.stage=="Trial" then
   ui.text(head,"Complete a solo class trial to choose that class.",16)
  elseif state.stage=="Class" then
   ui.text(head,T("Trial passed: {class}",{class=T(state.trialClass)}),16)
   ui.text(head,"Confirm your first class. You receive its starter weapon.",15)
   ui.button(head,if confirmation==state.trialClass then "Confirm first class" else "Choose this class",state.canSelect,function()
    if not state.canSelect then return end
    if confirmation==state.trialClass then confirmation=nil;ui.act("SelectPlayerClass",{classId=state.trialClass})
    else confirmation=state.trialClass;ui.render() end
   end).Name="NoviceSelectClass"
  else
   if state.stage=="Quest" then
    ui.button(head,T("Claim {xp} XP",{xp=state.xp}),state.canClaim,function()if state.canClaim then ui.act("ClaimNoviceChapter",{chapterId=state.chapterId})end end).Name="NoviceClaim"
   elseif state.stage=="Foundation" and state.ready then
    ui.text(head,"Choose a free level-10 companion. No Gold or Robux required.",15)
    local choices=Instance.new("Frame");choices.Name="NoviceHeroChoices";choices.BackgroundTransparency=1;choices.Parent=head
    local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(8,8);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=choices
    local function resize()
     local columns=if choices.AbsoluteSize.X>=560 then 5 else 2
     grid.FillDirectionMaxCells=columns;grid.CellSize=UDim2.fromOffset(math.max(1,math.floor((choices.AbsoluteSize.X-8*(columns-1))/columns)),52)
     choices.Size=UDim2.new(1,0,0,math.ceil(#catalog.AdventurerOrder/columns)*60-8)
    end
    choices:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
    for _,id in ipairs(catalog.AdventurerOrder) do
     ui.button(choices,(if selected==id then "✓ " else "")..T(id),not busy,function()
      if busy then return end;selected=id;confirmation=nil;ui.render()
     end).Name="NoviceHero_"..id
    end
    ui.button(head,if confirmation==selected then "Confirm free guild founding" else T("Found guild with {class}",{class=T(selected)}),state.canFound,function()
     if not state.canFound then return end
     if confirmation==selected then confirmation=nil;ui.act("FoundNoviceGuild",{heroClass=selected})
     else confirmation=selected;ui.render() end
    end).Name="NoviceFound"
   end
   for _,row in ipairs(state.objectives) do
    ui.text(head,(if row.done then "✓ " else "○ ")..row.text,16).Name="Objective_"..row.id
   end
  end
  if (state.stage=="Class" or state.stage=="Foundation") and not state.room then ui.text(head,"Free an equipment slot for your starter weapon.",15) end
 end
end
