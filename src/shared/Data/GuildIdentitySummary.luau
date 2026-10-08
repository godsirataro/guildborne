--!strict
-- Fixed preset identity only; never project custom text, balances or purchase receipts.
local crests={sun={"Sun","ดวงอาทิตย์"},oak={"Oak","ต้นโอ๊ก"},compass={"Compass","เข็มทิศ"}}
local mottos={together={"Stronger together","ร่วมแรงแข็งแกร่ง"},courage={"Stand with courage","ยืนหยัดด้วยความกล้า"},discovery={"Seek new horizons","ค้นหาขอบฟ้าใหม่"}}
local S={}
function S.project(data:any):any
 local result={};if type(data)~="table"then return result end
 local hall=data.personalGuild and data.personalGuild.buildings and data.personalGuild.buildings.guildHall
 if type(hall)=="number"and hall==hall and hall%1==0 and hall>=1 and hall<=20 then result.hallLevel=hall end
 local campaign=data.progression and data.progression.campaign
 if campaign and type(campaign.claimed)=="number"and campaign.claimed>=6 and campaign.choices then
  local crest,motto=campaign.choices.choose_crest,campaign.choices.choose_motto
  if crests[crest]and mottos[motto]then result.crestId=crest;result.mottoId=motto end
 end
 return result
end
function S.labels(crest:string?,motto:string?,language:string):any?
 local c=crest and crests[crest];local m=motto and mottos[motto]
 if not c or not m then return nil end
 local i=if language=="th"then 2 else 1
 return {crest=c[i],motto=m[i],symbol="ui.guild_emblem."..(crest :: string)}
end
return S
