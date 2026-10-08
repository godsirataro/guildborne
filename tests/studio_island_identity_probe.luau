--!strict
-- Fake owners; directory projection only. Never moves an avatar or writes a profile.
return function(make:any):any
 local fixture=Instance.new("Folder");fixture.Name="IslandIdentityProbe";fixture.Parent=workspace
 local a:any={UserId=-8101,Name="SyntheticA",DisplayName="Synthetic owner A"}
 local b:any={UserId=-8102,Name="SyntheticB",DisplayName="Synthetic owner B"}
 local service=make({},{});local checks=0
 local function check(value:boolean)assert(value);checks+=1 end
 local ok,result=pcall(function():any
  for _,owner in ipairs({a,b})do local entry=Instance.new("Part");entry.Anchored=true;entry.CanCollide=false;entry.Parent=fixture;service.add(owner,entry)end
  local data={personalGuild={buildings={guildHall=11}},guildLand={accessMode="Public"},progression={campaign={claimed=24,choices={choose_crest="compass",choose_motto="together"}}},gold=1234}
  service.update(a,data,true);service.update(b,{guildLand={accessMode="Private"}},true)
  local rows=service.directory(b);check(#rows==2)
  local own=nil;for _,row in ipairs(rows)do if row.ownerId==tostring(a.UserId)then own=row end end
  check(own~=nil);check(own.hallLevel==11 and own.crestId=="compass"and own.mottoId=="together");check(own.gold==nil)
  own.crestId="sun";own.hallLevel=1
  for _,row in ipairs(service.directory(b))do if row.ownerId==tostring(a.UserId)then check(row.crestId=="compass"and row.hallLevel==11)end end
  service.update(a,data,false);check(#service.directory(b)==1)
  service.update(a,{guildLand={accessMode="Public"}},true)
  for _,row in ipairs(service.directory(b))do if row.ownerId==tostring(a.UserId)then check(row.crestId==nil and row.hallLevel==nil)end end
  service.remove(a);check(#service.directory(b)==1)
  return {checks=checks,syntheticOwners=2,profileWrites=0,avatarMoves=0,friendApiCalls=0}
 end)
 service.destroy();fixture:Destroy();assert(ok,result);return result
end
