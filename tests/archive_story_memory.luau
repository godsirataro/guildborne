--!strict
return function(test:any,eq:any)
 local memory=require("../src/shared/Data/ArchiveStoryMemory")
 local util=require("../src/shared/Util/TableUtil")
 test("archive recollections distinguish saved choices without rewriting them",function()
  local seen={}
  for _,branch in ipairs({"rescue","supplies"})do for _,timber in ipairs({"workers","town"})do for _,reconciliation in ipairs({"shared_table","joint_work"})do for _,warden in ipairs({"release","renew"})do
   local d={progression={novice={branch=branch},campaign={choices={allocate_timber=timber,choose_reconciliation=reconciliation,choose_warden_release=warden}}}}
   local before=util.copy(d);local key=""
   for _,kind in ipairs({"caravan","timber","reconciliation","warden"})do
    local copy=assert(memory(d,kind));assert(#copy[1]>20 and #copy[2]>20);key..=copy[1]
    copy[1]="edited";assert(assert(memory(d,kind))[1]~="edited","Shared copy mutated")
   end
   assert(not seen[key]);seen[key]=true;eq(d,before)
  end end end end
  local n=0;for _ in pairs(seen)do n+=1 end;eq(n,16)
 end)
 test("unknown history uses neutral copy and never invents a chosen branch",function()
  for _,kind in ipairs({"caravan","timber","reconciliation","warden"})do
   eq(memory(nil,kind),memory({progression={novice={branch="invalid"},campaign={choices={allocate_timber="invalid",choose_reconciliation="invalid",choose_warden_release="invalid"}}}},kind))
  end
  eq(memory(nil,"unknown"),nil)
 end)
end
