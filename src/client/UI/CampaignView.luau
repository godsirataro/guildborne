--!strict
local memory=require(game.ReplicatedStorage.Shared.Data.ArchiveStoryMemory)
local drawEnding=require(script.Parent.ArchiveEndingView)
local describe=require(game.ReplicatedStorage.Shared.Data.CampaignViewState)
return function(ui:any)
 local selected="Warrior";local confirmation:string?=nil;local previous:string?=nil
 return function(data:any,catalog:any,busy:boolean)
  local s=describe(data,catalog,busy);if s.stage=="Unavailable"then return end
  local th=data.language=="th";local function L(en:string,thai:string):string return if th then thai else en end
  if previous~=s.chapterId then previous=s.chapterId;confirmation=nil end
  local head=ui.card(ui.scroll,s.title or L("A home with a name","บ้านที่มีชื่อ"));head.Name="CampaignJourney"
  if s.stage=="Complete"then
   ui.text(head,L("Completed chapters: ","บทที่สำเร็จ: ")..s.total.." / "..s.total,16)
   ui.text(head,if s.finale then L("Your alliance's story is recorded. Every name has a place in its future.","บันทึกเรื่องราวของพันธมิตรแล้ว ทุกชื่อมีที่ยืนในอนาคต")else L("You have completed the chapters available in this preview.","คุณผ่านบททั้งหมดที่เปิดให้เล่นในตัวอย่างนี้แล้ว"),16)
   if (s.hallPermit or 0)>(data.hallLevel or 0)then ui.text(head,L("Return to your island to use your earned Hall upgrade permit. Materials and Gold are still required.","กลับเกาะเพื่อใช้สิทธิ์อัปเกรดหอที่ได้รับ โดยยังต้องใช้วัสดุและ Gold"),16)end
   if s.finale then
    drawEnding(ui,head,(data.progression.campaign.choices or {}).choose_tower_future,data.language)
    for _,kind in ipairs({"caravan","timber","reconciliation","warden"})do
     local line=memory(data,kind);if line then ui.text(head,line[if th then 2 else 1],15).Name="CampaignMemory_"..kind end
    end
   end
   ui.text(head,L("Next: visit your guild island, review your skills, or choose an available task in the Journal.","ทำต่อได้: เยี่ยมเกาะกิลด์ ตรวจสกิล หรือเลือกงานที่เปิดอยู่ในสมุดเควส"),16)
   local choices=data.progression.campaign.choices or {}
   local motto=({together={"Together we rise","เติบโตไปด้วยกัน"},courage={"Courage leads us","ก้าวไปด้วยความกล้า"},discovery={"Seek new horizons","ค้นหาขอบฟ้าใหม่"}})[choices.choose_motto]
   local crest=({sun={"Sun","ดวงอาทิตย์"},oak={"Oak","ต้นโอ๊ก"},compass={"Compass","เข็มทิศ"}})[choices.choose_crest]
   if motto then ui.text(head,L("Motto: ","คำขวัญ: ")..motto[if th then 2 else 1],16)end
   if crest then ui.text(head,L("Crest: ","ตรากิลด์: ")..crest[if th then 2 else 1],16)end
   return
  end
  ui.text(head,L("Guild chapter ","บทกิลด์ ")..s.index.." / "..s.total.." · Lv"..s.level,15)
  ui.text(head,L("Reward: ","รางวัล: ")..s.xp.." XP · "..s.gold.." Gold",16)
  if s.hallPermit then ui.text(head,L("Reward: permission to upgrade to Hall ","รางวัล: สิทธิ์อัปเกรด Hall ")..s.hallPermit..L(". Materials and Gold are still required."," โดยยังต้องใช้วัสดุและ Gold ตามราคา"),16)end
  if not s.hallReady then ui.text(head,L("Return to your guild island and upgrade Hall to level ","กลับเกาะกิลด์ แล้วอัปเกรดหอเป็นระดับ ")..s.hall..L(" to continue."," เพื่อไปต่อ"),16)end
  if s.guidance then ui.text(head,s.guidance,16).Name="CampaignGuidance"end
  if s.stage=="Recruit"and s.ready then
   ui.text(head,L("Choose one free level-10 companion. Add them to your party after recruiting.","เลือกเพื่อนเลเวล 10 ฟรีหนึ่งคน แล้วเพิ่มเข้าทีมหลังรับตัว"),15)
   local choices=Instance.new("Frame");choices.Name="CampaignHeroChoices";choices.BackgroundTransparency=1;choices.Parent=head
   local grid=Instance.new("UIGridLayout");grid.CellPadding=UDim2.fromOffset(8,8);grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=choices
   local function resize()
    local columns=if choices.AbsoluteSize.X>=560 then 5 else 2
    grid.FillDirectionMaxCells=columns;grid.CellSize=UDim2.fromOffset(math.max(1,math.floor((choices.AbsoluteSize.X-8*(columns-1))/columns)),52)
    choices.Size=UDim2.new(1,0,0,math.ceil(#catalog.AdventurerOrder/columns)*60-8)
   end
   choices:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
   for _,id in ipairs(catalog.AdventurerOrder)do
    ui.button(choices,(if selected==id then "✓ "else "")..ui.T(id),not busy,function()
     if busy then return end;selected=id;confirmation=nil;ui.render()
    end).Name="CampaignHero_"..id
   end
  end
  local label=if s.stage=="Recruit"then (if confirmation==selected then L("Confirm companion: ","ยืนยันรับเพื่อน: ")else L("Recruit: ","รับเพื่อน: "))..ui.T(selected)else L("Claim chapter rewards","รับรางวัลบทนี้")
  ui.button(head,label,s.canClaim,function()
   if not s.canClaim then return end
   if s.stage=="Recruit"then
    if confirmation==selected then confirmation=nil;ui.act("ClaimCampaignRecruit",{chapterId=s.chapterId,heroClass=selected})
    else confirmation=selected;ui.render()end
   else ui.act("ClaimCampaignChapter",{chapterId=s.chapterId})end
  end).Name="CampaignClaim"
  if not s.levelReady then ui.text(head,L("Reach the required level to continue.","เพิ่มเลเวลให้ถึงเงื่อนไขเพื่อไปต่อ"),15)end
  if not s.room then ui.text(head,L("Free a roster slot and an equipment slot for your companion.","เว้นช่องสมาชิกและช่องอุปกรณ์สำหรับเพื่อนคนใหม่"),15)end
  if s.traveling then ui.text(head,L("Finish your expedition or tower run before claiming.","จบการสำรวจหรือหอคอยก่อนรับรางวัล"),15)end
  for _,row in ipairs(s.objectives)do ui.text(head,(if row.done then "✓ "else "○ ")..row.text,16).Name="CampaignObjective_"..row.id end
 end
end
