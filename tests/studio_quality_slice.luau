--!strict
-- Exercised against the exact candidate gate extracted from ServerBootstrap.
return function(candidate:any)
 local count=0
 local function check(name:string,runtime:any,context:any,full:boolean,launch:boolean,expected:boolean)
  assert(candidate(runtime,context,full,launch)==expected,name)
  count+=1
 end
 local function runtime():any return {FullConnectedWorldCandidate=true,StudioPersistence="Memory",AllowedDataStoreUniverses={}} end
 local function context():any return {isStudio=true,placeId=0,gameId=0} end
 check("explicit isolated full route",runtime(),context(),true,false,true)
 for _,flag in ipairs({false,"true",1}) do local r=runtime();r.FullConnectedWorldCandidate=flag;check("exact opt-in",r,context(),true,false,false) end
 local absent=runtime();absent.FullConnectedWorldCandidate=nil;check("default absent",absent,context(),true,false,false)
 check("incomplete chapter chain",runtime(),context(),false,false,false)
 check("Lv35 release cannot join",runtime(),context(),true,true,false)
 for _,mode in ipairs({"DataStore","memory",""}) do local r=runtime();r.StudioPersistence=mode;check("persistence fence",r,context(),true,false,false) end
 for _,key in ipairs({"placeId","gameId"}) do
  for _,value in ipairs({1,-1,"0",math.huge,0/0}) do local c=context();c[key]=value;check("zero-ID fence",runtime(),c,true,false,false) end
  local c=context();c[key]=nil;check("missing ID",runtime(),c,true,false,false)
 end
 for _,value in ipairs({false,"true",1}) do local c=context();c.isStudio=value;check("Studio-only fence",runtime(),c,true,false,false) end
 local c=context();c.isStudio=nil;check("missing Studio",runtime(),c,true,false,false)
 for _,allowed in ipairs({{[1]="staging"},{[10768425213]="staging"},{[0]=false},false,""}) do
  local r=runtime();r.AllowedDataStoreUniverses=allowed;check("no configured universe",r,context(),true,false,false)
 end
 local missing=runtime();missing.AllowedDataStoreUniverses=nil;check("missing universe table",missing,context(),true,false,false)
 print(count.." full connected candidate isolation checks passed; not Studio or gameplay acceptance")
end
