--!strict
-- Actual ExpansionView and StatusPointView, UI primitives doubled. No layout claims.
return function(source:string,statusSource:string,env:any,availabilitySource:string)
 return function(test:any,eq:any,api:any)
  local imports:any={Expansion=api.Rules,ClassAdvancementCopy=api.Copy,StatusPoints=api.Points,
   SkillTreeView=function()end,ClassBadge=function()end,ItemViewport=function()end,SymbolIcon=function()end,
   CraftingViewState=function()error("Outside this test")end,FurnitureView=function()return function()end end}
  env.game={ReplicatedStorage={Shared={Data={Expansion="Expansion",CraftingViewState="CraftingViewState",StatusPoints="StatusPoints"},Config={ClassAdvancementCopy="ClassAdvancementCopy"}}}}
  local parent={SkillTreeView="SkillTreeView",SkillAvailability="SkillAvailability",ClassBadge="ClassBadge",ItemViewport="ItemViewport",FurnitureView="FurnitureView",StatusPointView="StatusPointView",SymbolIcon="SymbolIcon"}
  env.script={Parent=parent};env.require=function(key:any)return assert(imports[key],"Missing "..tostring(key))end
  local availabilityChunk=assert(loadstring(availabilitySource));setfenv(availabilityChunk,env);imports.SkillAvailability=availabilityChunk()
  local statusChunk=assert(loadstring(statusSource));setfenv(statusChunk,env);imports.StatusPointView=statusChunk()
  local chunk=assert(loadstring(source));setfenv(chunk,env);local make=chunk()
  local function fixture(lang:string?):any
   local r=api.fixture();r.data.settings.language=lang or "en"
   local h:any={record=r,actions={},objects={},busy=false,tab="Skills"}
   local function node(kind:string,parentNode:any,label:string):any
    local n=env.Instance.new(kind);n.Parent=parentNode;n.Text=label
    function n:FindFirstChildOfClass(class:string):any for _,child in ipairs(self:GetChildren())do if child.ClassName==class then return child end end;return nil end
    table.insert(h.objects,n);return n
   end
   local ui:any={scroll=env.Instance.new("Frame")}
   ui.T=function(key:string,values:any?):string return api.Localization.translate(lang or "en",key,values)end
   ui.card=function(p:any,key:string)return node("Frame",p,ui.T(key))end
   ui.text=function(p:any,key:string)return node("TextLabel",p,ui.T(key))end
   ui.button=function(p:any,key:string,enabled:boolean,fn:any)local n=node("TextButton",p,ui.T(key));n.Enabled=enabled;n.callback=fn;return n end
   ui.act=function(action:string,args:any)table.insert(h.actions,{action=action,args=args})end
   ui.navigate=function(tab:string)h.tab=tab end
   local draw=make(ui)
   function h.render()
    h.objects={};local v=api.project(h.record,api.bundle);h.data=v.data
    if h.adjust then h.adjust(v)end
    v.catalog.Character={Classes={Warrior={SkillId="power_strike"}}};v.catalog.StatusAllocationAvailable=true
    draw(h.tab,v.data,v.catalog,h.busy)
   end
   ui.render=h.render
   function h.find(name:string):any for _,n in ipairs(h.objects)do if n.Name==name then return n end end;return nil end
   function h.click(name:string)local n=assert(h.find(name),"Missing "..name);assert(n.Enabled,"Disabled "..name);n.callback()end
   function h.contains(value:string):boolean for _,n in ipairs(h.objects)do if n.Text==value then return true end end;return false end
   h.render();return h
  end
  test("Class3 native view requires explicit path and sends only selected actual actor intent",function()
   local h=fixture();eq(h.find("StartClass3Trial"),nil)
   eq(h.find("Advance_warlord").Enabled,false)
   h.click("SelectClass3_warlord");h.click("StartClass3Trial")
   eq(h.actions,{{action="StartClass3Trial",args={actorId="player",pathId="warlord"}}})
   h.click("SkillActor");eq(h.find("StartClass3Trial"),nil)
   h.click("SelectClass3_commander");h.click("StartClass3Trial")
   eq(h.actions[2],{action="StartClass3Trial",args={actorId="h:1",pathId="commander"}})
  end)
  test("Class3 native view resets selection when parent path or owned actor disappears",function()
   local h=fixture();h.click("SkillActor");h.click("SelectClass3_warlord")
   h.record.data.expansion.actors["h:1"].path="duelist";h.render()
   eq(h.find("StartClass3Trial"),nil);eq(h.find("SelectClass3_warlord"),nil)
   h.click("SelectClass3_sword_saint");h.record.data.adventurers["h:1"]=nil;h.render()
   eq(h.find("StartClass3Trial"),nil);assert(h.find("SelectClass3_warlord"))
  end)
  test("Class3 native view saved proof enables separate confirmed promotion only for that actor",function()
   local h=fixture();h.record.data.expansion.actors.player.class3Proof={version=1,actorId="player",pathId="warlord",trialId="saved",sourceKind="actor_mastery"};h.render()
   h.click("SelectClass3_warlord");eq(h.find("StartClass3Trial").Enabled,false)
   h.click("Advance_warlord");eq(#h.actions,0);h.click("Advance_warlord")
   eq(h.actions,{{action="AdvanceClass",args={actorId="player",pathId="warlord"}}})
   h.click("SkillActor");eq(h.find("Advance_warlord").Enabled,false)
  end)
  test("Class3 native view Saving and request pending block mutation without claiming proof",function()
   local h=fixture();h.click("SelectClass3_warlord")
   h.adjust=function(v:any)v.data.class3Session={actorId="h:2",pathId="commander",status="Saving"}end;h.render()
   assert(h.find("Class3Session"));eq(h.find("CancelClass3Trial").Enabled,false);eq(h.find("StartClass3Trial").Enabled,false)
   eq(h.find("Advance_warlord").Enabled,false);eq(h.data.class3Proofs.player.warlord.proven,false)
   h.click("SkillActor");assert(h.find("Class3Session"));eq(h.find("Advance_warlord").Enabled,false)
   h.tab="Status";h.render();eq(h.find("Allocate_VIT").Enabled,false);eq(h.find("ResetBuildPoints").Enabled,false)
   h.tab="Skills";h.adjust=nil;h.busy=true;h.render();eq(h.find("SkillActor").Enabled,false)
   eq(h.find("SelectClass3_warlord").Enabled,false);eq(#h.actions,0)
  end)
  test("Class3 native view Active cancel is separate from inspected actor and refuses while pending",function()
   local h=fixture();h.adjust=function(v:any)v.data.class3Session={actorId="h:2",pathId="commander",status="Active"}end;h.render()
   h.click("CancelClass3Trial");eq(h.actions,{{action="CancelClass3Trial",args={}}})
   h.busy=true;h.render();eq(h.find("CancelClass3Trial").Enabled,false)
  end)
  test("Class3 native view refuses route and release blocks without optimistic proof",function()
   local h=fixture();h.adjust=function(v:any)v.data.class3Proofs.player.warlord.trialProblem="ReturnToCrosshaven"end;h.render()
   h.click("SelectClass3_warlord");eq(h.find("StartClass3Trial").Enabled,false)
   assert(h.contains(api.Localization.translate("en","ReturnToCrosshaven")))
   h.adjust=function(v:any)v.data.releaseAdvancementProblems={player={warlord="ReleaseContentUnavailable"}}end;h.render()
   eq(h.find("StartClass3Trial").Enabled,false);eq(h.find("Advance_warlord").Enabled,false);eq(#h.actions,0)
  end)
  test("Class3 native view feature absent leaves existing advancement and no new controls",function()
   local h=fixture();h.adjust=function(v:any)v.data.class3Proofs=nil end;h.render()
   eq(h.find("Class3Qualification"),nil);eq(h.find("SelectClass3_warlord"),nil);eq(h.find("Advance_warlord").Enabled,true)
  end)
  test("Class3 bilingual native copy distinguishes player Guard dodge lessons from hero lessons",function()
   for _,lang in ipairs({"en","th"})do
    local h=fixture(lang);assert(h.contains(api.Localization.translate(lang,"Class3PlayerLesson")))
    h.click("SkillActor");assert(h.contains(api.Localization.translate(lang,"Class3HeroLesson")))
    assert(not h.contains(api.Localization.translate(lang,"Class3PlayerLesson")))
    for _,key in ipairs({"Class3Qualification","Class3Saving","Class3ProofRequired","Class3ActorChanged","Class3AlreadyProven","Class3CampaignUnavailable","ReturnToCrosshaven","Class3TrialUnavailable","Class3SavePending","Class3ReceiptHistoryUnavailable"})do
     local value=api.Localization.translate(lang,key);assert(value~=key,lang.." missing "..key)
    end
   end
   local lesson=api.Localization.translate("en","Class3PlayerLesson");assert(lesson:find("Guard",1,true) and lesson:find("incoming hit",1,true) and lesson:find("Dodge twice",1,true))
  end)
 end
end
