--!strict
-- Fixed per-arena budget. No per-sender allocation and no client outcome payloads.
return function(owner:number)
 local tokens=8;local last:number?=nil
 return function(sender:number,action:any,now:number,extra:number):(boolean,string)
  if sender~=owner then return false,"ForeignTrial"end
  if extra~=0 or type(action)~="string"or (action~="Basic"and action~="Ability"and action~="Return")then return false,"InvalidAction"end
  if type(now)~="number"or now~=now or math.abs(now)==math.huge or now<0 or (last and now<last)then return false,"InvalidClock"end
  if last then tokens=math.min(8,tokens+(now-last)*6)end;last=now
  if tokens<1 then return false,"RateLimited"end
  tokens-=1;return true,"OK"
 end
end
