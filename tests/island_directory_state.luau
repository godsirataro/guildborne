--!strict
local project=require("../src/shared/Data/IslandDirectoryState")
return function(test:any,eq:any)
 local rows={
  {ownerId="2",name="Beta",displayName="B",mode="Public",visitors=8,capacity=8},
  {ownerId="1",name="Owner",displayName="Z",mode="Private",visitors=8,capacity=8},
  {ownerId="3",name="Friend",displayName="A",mode="Friends",visitors=0,capacity=8},
  {ownerId="4",name="Public",displayName="A",mode="Public",visitors=1,capacity=8}}
 test("island directory prioritizes own island and open capacity without mutating input",function()
  local r=project(rows,"1","","All");eq(#r,4);eq(r[1].entry.ownerId,"1");eq(r[1].full,false);eq(r[2].entry.ownerId,"3");eq(r[4].entry.ownerId,"2");eq(r[4].full,true);eq(rows[1].ownerId,"2")
 end)
 test("island filters are literal searchable presentation not friendship authorization",function()
  eq(#project(rows,"1","  PUBLIC  ","Public"),1);eq(#project(rows,"1","%","All"),0)
  eq(#project(rows,"1","","Friends"),1);eq(project(rows,"1","","Mine")[1].entry.ownerId,"1")
  eq(#project(rows,"1","","unknown"),0);eq(#project({},"1","","All"),0)
 end)
end
