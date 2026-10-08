--!strict
-- At most two active track keys. Retargeting retains the louder existing track.
return function(duration:number)
 assert(duration>0 and duration<30)
 local tracks:any={};local target:string?=nil;local started=0;local latest=-math.huge
 local S={}
 local function valid(now:number):boolean return now==now and math.abs(now)<1e12 and now>=latest end
 function S.Step(now:number):any
  if not valid(now) then return nil end;latest=now
  local alpha=math.clamp((now-started)/duration,0,1);local result={}
  for key,track in pairs(tracks)do
   track.gain=track.from+((if key==target then 1 else 0)-track.from)*alpha
   if alpha==1 and key~=target then tracks[key]=nil else result[key]=track.gain end
  end
  return result
 end
 function S.Set(key:string?,now:number):boolean
  if not valid(now)then return false end
  S.Step(now)
  if key==target then return true end
  if key and not tracks[key] then
   local keep:string?=nil;local gain=-1
   for id,t in pairs(tracks)do if t.gain>gain or (t.gain==gain and (keep==nil or id<keep))then keep=id;gain=t.gain end end
   for id in pairs(tracks)do if id~=keep then tracks[id]=nil end end
   tracks[key]={gain=0,from=0}
  end
  for _,t in pairs(tracks)do t.from=t.gain end
  target=key;started=now;return true
 end
 function S.Clear()table.clear(tracks);target=nil;started=0;latest=-math.huge end
 return S
end
