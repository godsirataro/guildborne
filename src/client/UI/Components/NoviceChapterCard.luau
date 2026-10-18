--!strict
-- Presentation adapter: the existing view retains every claim/confirmation handler.
local Describe=require(game.ReplicatedStorage.Shared.Data.NoviceJourneyViewState)
local Legacy=require(script.Parent.Parent.NoviceJourneyView)
local Theme=require(script.Parent.Parent.DesignSystem.Theme)
local Button=require(script.Parent.GuildborneButton)
local C=Theme.Colors
local stories={
 MAIN_00_01={"A courier needs help along the training path. Learn to read danger, then lend a hand.","คนส่งสารต้องการความช่วยเหลือบนเส้นทางฝึก เรียนรู้สัญญาณอันตราย แล้วเข้าไปช่วยเขา"},
 MAIN_00_02={"A borrowed weapon is a beginning. Practice your attack, evade danger, and bring the captive to safety.","อาวุธที่ยืมมาคือจุดเริ่มต้น ฝึกโจมตี หลบอันตราย และช่วยตัวประกันให้ปลอดภัย"},
 MAIN_00_03={"Follow the caravan's tracks. Choose what to save, then return for what was left behind.","ตามรอยขบวนเกวียน เลือกสิ่งที่จะช่วยไว้ แล้วกลับไปช่วยสิ่งที่ยังเหลืออยู่"},
 MAIN_00_04={"Face the keeper at the crossroads. Free the captive and uncover the meaning of the false crest.","เผชิญหน้าผู้คุมทางแยก ปล่อยตัวผู้ถูกจับ และตรวจสอบความหมายของตราปลอม"},
 MAIN_00_05={"Try each discipline before you take your oath. Your first class begins with an informed choice.","ทดลองฝึกทุกสายก่อนให้คำสาบาน อาชีพแรกของคุณเริ่มจากการเลือกด้วยความเข้าใจ"},
 MAIN_00_06={"Pass your class trial and prepare a home for your company. A guild begins with the people beside you.","ผ่านบททดสอบอาชีพและเตรียมบ้านให้พวกพ้อง กิลด์เริ่มต้นจากผู้คนที่ยืนเคียงข้างคุณ"},
}
local function flow(parent:Instance,gap:number,pad:number?)
 local list=Instance.new("UIListLayout");list.SortOrder=Enum.SortOrder.LayoutOrder;list.Padding=UDim.new(0,gap);list.Parent=parent
 if pad then local p=Instance.new("UIPadding");p.PaddingTop=UDim.new(0,pad);p.PaddingBottom=p.PaddingTop;p.PaddingLeft=p.PaddingTop;p.PaddingRight=p.PaddingTop;p.Parent=parent end
end
local function box(parent:Instance,name:string,color:Color3):Frame
 local frame=Instance.new("Frame");frame.Name=name;frame.Size=UDim2.new(1,0,0,0);frame.AutomaticSize=Enum.AutomaticSize.Y;frame.BackgroundColor3=color;frame.BorderSizePixel=0;frame.Parent=parent;return frame
end
local function label(parent:Instance,value:string,size:number,color:Color3,order:number):TextLabel
 local item=Instance.new("TextLabel");item.Size=UDim2.new(1,0,0,size+6);item.AutomaticSize=Enum.AutomaticSize.Y;item.BackgroundTransparency=1
 item.Text=value;item.TextSize=size;item.TextColor3=color;item.Font=Theme.Fonts.Body;item.TextWrapped=true;item.TextXAlignment=Enum.TextXAlignment.Left;item.TextYAlignment=Enum.TextYAlignment.Top;item.LayoutOrder=order;item.Parent=parent;return item
end
return function(ui:any)
 local state:any;local data:any;local catalog:any;local busy=false
 local body:Frame;local badge:TextLabel;local titleLabel:TextLabel;local root:Frame
 local actionOrder=100
 local function copy(en:string,th:string):string return if data.language=="th" then th else en end
 local adapter={scroll=ui.scroll,T=ui.T,act=ui.act,render=ui.render}
 adapter.card=function(parent:Instance,_title:string):Frame
  root=box(parent,"NoviceChapterCard",C.Background);root.Size=UDim2.new(1,-4,0,0);flow(root,0)
  root:SetAttribute("ChapterId",state.chapterId);root:SetAttribute("Stage",state.stage)
  local rim=Instance.new("UIStroke");rim.Color=C.GoldShadow;rim.Thickness=1;rim.Parent=root
  local header=box(root,"ChapterHeader",C.Background);header.LayoutOrder=1;flow(header,8,16)
  local eyebrow=label(header,copy("THE FIRST CHRONICLE","บันทึกการเดินทางแรก"),13,C.Gold,0);eyebrow.Name="ChronicleHeading"
  badge=label(header,if state.index then ui.T("Chapter {current} / 6",{current=state.index}) else copy("Your first adventure","การผจญภัยครั้งแรก"),14,C.Muted,1);badge.Name="ChapterNumber"
  titleLabel=label(header,state.title or (if state.stage=="Complete" then copy("A guild of your own","กิลด์ของคุณ") else copy("Your first adventure","การผจญภัยครั้งแรก")),28,C.Text,2);titleLabel.Name="ChapterTitle"
  titleLabel.Font=if data.language=="th" then Theme.Fonts.Body else Theme.Fonts.Heading
  local story=stories[state.chapterId]
  if story then label(header,story[if data.language=="th" then 2 else 1],16,C.Muted,3).Name="ChapterStory" end
  local trail=Instance.new("Frame");trail.Name="ChapterTrail";trail.Size=UDim2.new(1,0,0,28);trail.BackgroundTransparency=1;trail.LayoutOrder=4;trail.Parent=header
  local claimed=if data.progression and data.progression.novice then data.progression.novice.claimed else 0
  for i=1,6 do
   local step=Instance.new("TextLabel");step.Name="ChapterStep"..i;step.Position=UDim2.new((i-1)/6,0,0,0);step.Size=UDim2.new(1/6,-4,1,0);step.BorderSizePixel=0
   step.BackgroundColor3=if i<=claimed then C.GoldShadow elseif i==state.index then C.Primary else C.Surface
   step.TextColor3=if i<=claimed or i==state.index then C.Text else C.Muted;step.Font=Theme.Fonts.Body;step.TextSize=13
   step.Text=(if i<=claimed then "✓ " else "")..tostring(i);step:SetAttribute("ChapterState",if i<=claimed then "Claimed" elseif i==state.index then "Current" else "Upcoming");step.Parent=trail
  end
  body=box(root,"ChapterBody",C.Text);body.LayoutOrder=2;flow(body,10,16)
  local status=if busy then copy("Waiting for the server…","กำลังรอเซิร์ฟเวอร์…") elseif state.stage=="Complete" then copy("Journey claimed · 6 / 6","รับรางวัลครบแล้ว · 6 / 6") elseif state.stage=="Quest" and state.canClaim then copy("Chapter complete · Ready to claim","จบบทแล้ว · รับรางวัลได้") elseif state.stage=="Quest" and state.ready then copy("Objectives complete · Level required","เป้าหมายครบแล้ว · ต้องมีเลเวลถึงกำหนด") elseif state.stage=="Class" then copy("Trial passed · Choose your class","ผ่านบททดสอบ · เลือกอาชีพ") elseif state.stage=="Foundation" and state.canFound then copy("Ready to found your guild","พร้อมตั้งกิลด์ของคุณ") else copy("Your next steps","ก้าวต่อไปของคุณ")
  label(body,status,17,C.Primary,-10).Name="ChapterState"
  if state.stage=="Quest" or state.stage=="Foundation" then
   local done=0;for _,row in ipairs(state.objectives) do if row.done then done+=1 end end
   label(body,copy("OBJECTIVES","เป้าหมาย").."  "..done.." / "..#state.objectives,13,C.Background,-9).Name="ObjectiveCount"
   local track=Instance.new("Frame");track.Name="ChapterProgress";track.Size=UDim2.new(1,0,0,4);track.BackgroundColor3=C.GoldShadow;track.BackgroundTransparency=.75;track.BorderSizePixel=0;track.LayoutOrder=-8;track.Parent=body
   local fill=Instance.new("Frame");fill.Name="CompletedObjectives";fill.Size=UDim2.fromScale(done/math.max(1,#state.objectives),1);fill.BackgroundColor3=C.Primary;fill.BorderSizePixel=0;fill.Parent=track
  end
  if state.stage=="Quest" then
   label(body,copy("On completion","เมื่อจบบท").."  ·  "..tostring(state.xp).." XP",16,C.Primary,80).Name="ChapterReward"
   local def=catalog.NoviceChapter.Chapters[state.index]
   if state.ready and not busy and data.character.level<def.Level then label(body,copy("Required level: ","เลเวลที่ต้องการ: ")..def.Level,15,C.Background,81).Name="ChapterLevelRequirement" end
  end
  local cardRoot,cardTitle=root,titleLabel
  local function resize() cardTitle.TextSize=if cardRoot.AbsoluteSize.X<480 then 24 else 28 end
  local connection=cardRoot:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
  cardRoot.Destroying:Connect(function() connection:Disconnect() end);resize()
  return body
 end
 adapter.text=function(parent:Instance,value:string,size:number?,_color:Color3?):TextLabel
  if state.index and value==ui.T("Chapter {current} / 6",{current=state.index}) then return badge end
  for i,row in ipairs(state.objectives) do
   if value==(if row.done then "✓ " else "○ ")..row.text then
    local result=label(parent,value,16,if row.done then C.Border else C.Background,20+i)
    result:SetAttribute("ObjectiveComplete",row.done);result:SetAttribute("ObjectiveId",row.id)
    return result
   end
  end
  return label(parent,ui.T(value),size or 16,C.Background,10)
 end
 adapter.button=function(parent:Instance,value:string,enabled:boolean,callback:()->()):TextButton
  local isClaim=parent==body and state.stage=="Quest"
  local text=if isClaim and busy then copy("Waiting for the server…","กำลังรอเซิร์ฟเวอร์…") elseif isClaim and not state.ready then copy("Complete the objectives first","ทำเป้าหมายให้ครบก่อน") elseif isClaim and not enabled then copy("Reach the required level","เพิ่มเลเวลให้ถึงกำหนด") else ui.T(value)
  local handle:any
  handle=Button.create(parent,{text=text,primary=enabled and parent==body,onActivated=function()
   if busy then return end
   handle.setPending(true)
   if isClaim then handle.button.Text=copy("Waiting for the server…","กำลังรอเซิร์ฟเวอร์…") end
   callback()
  end})
  if parent~=body then (parent :: GuiObject).LayoutOrder=90 end
  handle.button.Size=UDim2.new(1,0,0,if isClaim and not enabled then 44 else 52)
  handle.button.LayoutOrder=actionOrder;actionOrder+=1
  handle.setDisabled(not enabled);handle.setPending(busy)
  return handle.button
 end
 local draw=Legacy(adapter)
 return function(nextData:any,nextCatalog:any,nextBusy:boolean)
  data=nextData or {};catalog=nextCatalog;busy=nextBusy;state=Describe(data,catalog,busy);actionOrder=100
  draw(data,catalog,busy)
  if state.stage~="Unavailable" and ui.explore then
   label(body,copy("Explore to continue. Open Guild menu to return to this chapter.","ออกสำรวจเพื่อเดินทางต่อ เปิดเมนูกิลด์เพื่อกลับมาดูบทนี้"),14,C.Border,190).Name="ExploreContext"
   local explore=Button.create(body,{name="NoviceExplore",text=ui.T("Explore"),onActivated=function() if not busy then ui.explore() end end})
   explore.button.LayoutOrder=200;explore.setDisabled(busy)
  end
 end
end
