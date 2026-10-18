--!nocheck
-- Actual adapter, legacy handlers, catalog and view state. Geometry is not glyph fit.
local View=require(UI.Components.NoviceChapterCard)
local Config=require(NoviceConfig)
local Locale=require(game.ReplicatedStorage.Shared.Config.Localization)
local passed=0
local function test(name,run) run();passed+=1;print("PASS novice chapter "..name) end
local function find(parent,name)
 if parent.destroyed then return nil end
 if parent.Name==name then return parent end
 for _,child in ipairs(parent:GetChildren()) do local found=find(child,name);if found then return found end end
end
local function fixture(index,language,ready)
 local data={language=language or "en",hallLevel=0,adventurers={},inventory={equipment={}},character={level=10},progression={novice={claimed=index-1,objectives={}}}}
 if ready then for _,id in ipairs(Config.Chapters[index].Objectives) do data.progression.novice.objectives[id]=true end end
 local f={data=data,catalog={NoviceChapter=Config,EquipmentLimit=50,AdventurerOrder={"Warrior","Knight","Archer","Mage","Priest"}},host=Instance.new("Frame"),actions={},explored=0,busy=false}
 local draw
 function f.render()
  for _,child in ipairs(f.host:GetChildren()) do child:Destroy() end
  f.host.children={} -- narrow simulator does not unlink destroyed instances
  draw(f.data,f.catalog,f.busy)
 end
 draw=View({scroll=f.host,T=function(s,p)return Locale.translate(f.data.language,s,p)end,
  act=function(action,args)table.insert(f.actions,{action=action,args=args})end,
  render=f.render,explore=function()f.explored+=1 end})
 function f.get(name)return assert(find(f.host,name),name)end
 function f.click(name)f.get(name).Activated:Fire()end
 function f.destroy()f.host:Destroy()end
 f.render();return f
end
test("incomplete chapter puts canonical objectives ahead of disabled action",function()
 local f=fixture(3,"en",false)
 local claim=f.get("NoviceClaim")
 assert(not claim.Active and claim.Text=="Complete the objectives first" and claim.Size[4]==44)
 assert(f.get("ChapterTitle").Text==Config.Chapters[3].Title)
 for _,id in ipairs(Config.Chapters[3].Objectives) do
  local objective=f.get("Objective_"..id)
  assert(objective.LayoutOrder<claim.LayoutOrder and objective:GetAttribute("ObjectiveId")==id and not objective:GetAttribute("ObjectiveComplete"))
 end
 assert(f.get("ChapterReward").Text=="On completion  ·  100 XP")
 f.click("NoviceClaim");assert(#f.actions==0)
 f.data.progression.novice.objectives.follow_tracks=true;f.render()
 assert(f.get("CompletedObjectives").Size[1]==1/3 and f.get("Objective_follow_tracks"):GetAttribute("ObjectiveComplete"))
 f.click("NoviceExplore");assert(f.explored==1 and #f.actions==0)
 f.destroy()
end)
test("ready reward dispatches canonical intent once and awaits server",function()
 local f=fixture(3,"en",true);local claim=f.get("NoviceClaim")
 assert(claim.Active and claim.Text=="Claim 100 XP" and claim.Size[4]==52)
 f.click("NoviceClaim");f.click("NoviceClaim")
 assert(#f.actions==1 and f.actions[1].action=="ClaimNoviceChapter" and f.actions[1].args.chapterId=="MAIN_00_03")
 assert(claim:GetAttribute("Pending") and claim.Text=="Waiting for the server…")
 assert(f.data.progression.novice.claimed==2 and f.get("ChapterStep3"):GetAttribute("ChapterState")=="Current")
 f.destroy()
end)
test("ready underlevel is not eligible and shows actual level requirement",function()
 local f=fixture(3,"en",true);f.data.character.level=4;f.render()
 assert(not f.get("NoviceClaim").Active and f.get("ChapterLevelRequirement").Text=="Required level: 5")
 f.click("NoviceClaim");assert(#f.actions==0);f.destroy()
end)
test("busy state blocks reward and explore without pretending it was claimed",function()
 local f=fixture(1,"th",true);f.busy=true;f.render()
 assert(f.get("NoviceClaim"):GetAttribute("Pending") and not f.get("NoviceExplore").Active)
 assert(f.get("ChapterState").Text=="กำลังรอเซิร์ฟเวอร์…")
 f.click("NoviceClaim");f.click("NoviceExplore");assert(#f.actions==0 and f.explored==0)
 f.destroy()
end)
test("chapter rewards and server confirmed trail do not invent progression",function()
 local f=fixture(5,"th",true)
 assert(f.get("ChapterReward").Text=="เมื่อจบบท  ·  50 XP")
 f.click("NoviceClaim");assert(f.data.progression.novice.claimed==4)
 f.data.progression.novice.claimed=5;f.data.progression.novice.objectives={};f.render()
 assert(f.get("ChapterStep5"):GetAttribute("ChapterState")=="Claimed" and not find(f.host,"NoviceClaim") and not find(f.host,"ChapterReward"))
 assert(f.get("NoviceChapterCard"):GetAttribute("Stage")=="Trial")
 f.data.progression.novice.claimed=6;f.render()
 assert(f.get("ChapterState").Text=="รับรางวัลครบแล้ว · 6 / 6" and not find(f.host,"NoviceClaim"))
 f.destroy()
end)
test("class selection retains original two step confirmation and equipment gate",function()
 local f=fixture(6,"en",false);f.data.progression.novice.trialClass="Mage";f.render()
 f.click("NoviceSelectClass");assert(#f.actions==0)
 assert(f.get("NoviceSelectClass").Text=="Confirm first class")
 f.click("NoviceSelectClass");assert(#f.actions==1 and f.actions[1].action=="SelectPlayerClass" and f.actions[1].args.classId=="Mage")
 for i=1,50 do f.data.inventory.equipment[tostring(i)]={} end;f.render()
 assert(not f.get("NoviceSelectClass").Active);f.click("NoviceSelectClass");assert(#f.actions==1)
 f.destroy()
end)
test("founding confirmation resets when companion changes and never awards locally",function()
 local f=fixture(6,"th",true);f.data.character.classId="Mage";f.data.progression.novice.trialClass="Mage";f.render()
 f.click("NoviceFound");assert(#f.actions==0)
 f.click("NoviceHero_Priest");assert(#f.actions==0)
 f.click("NoviceFound");assert(#f.actions==0)
 f.click("NoviceFound");assert(#f.actions==1 and f.actions[1].action=="FoundNoviceGuild" and f.actions[1].args.heroClass=="Priest")
 assert(f.data.hallLevel==0 and next(f.data.adventurers)==nil)
 f.busy=true;f.render();f.click("NoviceHero_Warrior");f.click("NoviceFound");assert(#f.actions==1)
 f.destroy()
end)
test("responsive hierarchy keeps Thai text live and releases resize and action listeners",function()
 local f=fixture(2,"th",true);local card=f.get("NoviceChapterCard");local title=f.get("ChapterTitle")
 for _,w in ipairs({240,320,390,640,728}) do
  card.AbsoluteSize={X=w,Y=500};card:GetPropertyChangedSignal("AbsoluteSize"):Fire()
  assert(title.Text==Config.Chapters[2].Thai and title.TextWrapped and title.TextSize==(if w<480 then 24 else 28))
  for i=1,6 do
   local step=f.get("ChapterStep"..i)
   assert(step.Position[1]*w+step.Size[1]*w+step.Size[2]<=w)
  end
 end
 local claim=f.get("NoviceClaim");f.destroy();title.TextSize=99
 card:GetPropertyChangedSignal("AbsoluteSize"):Fire();claim.Activated:Fire()
 assert(title.TextSize==99 and #f.actions==0)
end)
test("foundation capacity and changed class trial retain their original confirmation gates",function()
 local f=fixture(6,"en",true);f.data.character.classId="Mage";f.data.progression.novice.trialClass="Mage"
 for i=1,50 do f.data.inventory.equipment[tostring(i)]={} end;f.render()
 assert(not f.get("NoviceFound").Active);f.click("NoviceFound");assert(#f.actions==0)
 f.data.character.classId=nil;f.data.inventory.equipment={};f.render()
 f.click("NoviceSelectClass");assert(#f.actions==0)
 f.data.progression.novice.trialClass="Warrior";f.render()
 assert(f.get("NoviceSelectClass").Text=="Choose this class")
 f.click("NoviceSelectClass");assert(#f.actions==0)
 f.click("NoviceSelectClass");assert(#f.actions==1 and f.actions[1].args.classId=="Warrior")
 f.destroy()
end)
test("unavailable snapshot exposes no progression or explore action",function()
 local f=fixture(1,"en",false);f.data.progression.novice=nil;f.render()
 assert(f.get("NoviceChapterCard"):GetAttribute("Stage")=="Unavailable")
 assert(not find(f.host,"NoviceClaim") and not find(f.host,"NoviceExplore"));f.destroy()
end)
print(passed.." novice chapter behavior cases passed (simulation only).")
