--!strict
local summary=require("../src/shared/Data/GuildIdentitySummary")
return function(test:any,eq:any)
 test("island identity projects only earned preset ids and valid Hall levels",function()
  local d:any={personalGuild={buildings={guildHall=11}},progression={campaign={claimed=6,choices={choose_crest="compass",choose_motto="together"}}},gold=999,paymentReference="private"}
  local r=summary.project(d);eq(r.hallLevel,11);eq(r.crestId,"compass");eq(r.mottoId,"together");eq(r.gold,nil);eq(r.paymentReference,nil)
  r.crestId="sun";eq(d.progression.campaign.choices.choose_crest,"compass")
  d.progression.campaign.claimed=5;eq(summary.project(d).crestId,nil)
  d.progression.campaign.claimed=6;d.progression.campaign.choices.choose_motto="custom text";eq(summary.project(d).crestId,nil)
  for _,hall in ipairs({0,21,1.5,math.huge,0/0})do d.personalGuild.buildings.guildHall=hall;eq(summary.project(d).hallLevel,nil)end
  eq(summary.project(nil).hallLevel,nil)
 end)
 test("all island identity combinations have fixed EN TH labels and native symbols",function()
  for _,crest in ipairs({"sun","oak","compass"})do for _,motto in ipairs({"together","courage","discovery"})do
   local en=summary.labels(crest,motto,"en");local th=summary.labels(crest,motto,"th")
   eq(en.symbol,"ui.guild_emblem."..crest);assert(en.crest~=th.crest and en.motto~=th.motto)
  end end
  eq(summary.labels("foreign","together","en"),nil);eq(summary.labels("sun","foreign","th"),nil)
 end)
end
