--!strict
return function(ui:any)
 return function(snapshot:any,busy:boolean)
  local data=snapshot and snapshot.data;local view=data and data.launchRewards
  local th=data and data.language=="th"
  local function L(en:string,thai:string):string return if th then thai else en end
  local head=ui.card(ui.scroll,L("Daily rewards","รางวัลรายวัน"));head.Name="LaunchRewards"
  if not view or not view.available then ui.text(head,L("Rewards are unavailable. Retry after your profile loads.","ยังไม่พร้อมรับรางวัล ลองใหม่เมื่อโหลดข้อมูลสำเร็จ"),15);return end
  local function item(r:any):string
   local def=snapshot.catalog and snapshot.catalog.Items[r.Id]
   return tostring(r.Quantity).." × "..ui.T(if def then def.Name else r.Id)
  end
  ui.text(head,L("Missing a day does not reset your rewards.","ขาดวันได้โดยไม่เสียลำดับรางวัล"),15)
  ui.text(head,item(view.daily.reward),16)
  ui.button(head,L("Claim daily reward","รับรางวัลรายวัน"),not busy and view.daily.claimable,function()ui.act("ClaimDailyReward",{})end)
  if not view.daily.claimable then ui.text(head,L("Claimed for today. The next day starts at 00:00 UTC.","รับของวันนี้แล้ว วันใหม่เริ่มเวลา 07:00 น. ไทย"),14)end
  local season=ui.card(ui.scroll,L("Preview season rewards","รางวัลซีซันทดลอง"))
  ui.text(season,L("Earn tiers by completing story chapters. Premium purchasing is unavailable in this preview.","ผ่านบทเนื้อเรื่องเพื่อปลดรางวัล ยังซื้อ Premium ในตัวอย่างนี้ไม่ได้"),15)
  for _,entry in ipairs(view.tiers)do
   local tier:any=entry
   local title=L("Reward tier ","รางวัลขั้นที่ ")..tostring(tier.tier)
   local campaign=snapshot.catalog and snapshot.catalog.CampaignChapter
   for _,chapterEntry in ipairs(if campaign then campaign.Chapters else {})do
    local chapter:any=chapterEntry
    if chapter.Id==tier.milestone then
     local localized=if th then chapter.Thai else chapter.Title
     if type(localized)=="string" and #localized>0 then title=localized end
     break
    end
   end
   local row=ui.card(ui.scroll,title)
   ui.text(row,L("Free: ","ฟรี: ")..item(tier.free),15)
   ui.button(row,if tier.freeClaimed then L("Claimed","รับแล้ว")else L("Claim free reward","รับรางวัลฟรี"),not busy and tier.earned and not tier.freeClaimed,function()ui.act("ClaimSeasonReward",{seasonId=view.seasonId,tier=tier.tier,track="free"})end)
   ui.text(row,L("Premium: ","Premium: ")..item(tier.premium),15)
   ui.button(row,if tier.premiumClaimed then L("Claimed","รับแล้ว")else L("Claim Premium reward","รับรางวัล Premium"),not busy and view.premiumAvailable and tier.earned and not tier.premiumClaimed,function()ui.act("ClaimSeasonReward",{seasonId=view.seasonId,tier=tier.tier,track="premium"})end)
  end
 end
end
