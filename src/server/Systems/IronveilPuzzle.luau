--!strict
-- Ephemeral server-only puzzle progress. The world adapter owns distance/session gates.
return function(sequence:{string}):any
 assert(#sequence>=2 and #sequence<=8,"Invalid puzzle length")
 local order={};local seen={}
 for i,id in ipairs(sequence)do assert(type(id)=="string"and #id<=32 and not seen[id],"Invalid puzzle symbol");order[i]=id;seen[id]=true end
 local index=1;local attempts=0;local last=-math.huge;local cancelled=false
 local S={}
 function S.snapshot():any return {complete=index>#order,progress=index-1,total=#order,attempts=attempts,cancelled=cancelled}end
 function S.press(id:string,now:number):(boolean,string)
  if cancelled then return false,"Cancelled"end
  if index>#order then return false,"AlreadyComplete"end
  if type(now)~="number"or now~=now or now==math.huge or now<0 or now<last then return false,"InvalidTime"end
  if not seen[id]then return false,"UnknownSymbol"end
  if now-last<.3 then return false,"Cooling"end
  last=now
  if id~=order[index]then index=1;attempts+=1;return false,"TrySequenceAgain"end
  index+=1;return true,if index>#order then "Complete"else "Continue"
 end
 function S.cancel()cancelled=true end
 return S
end
