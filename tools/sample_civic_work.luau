--!strict
-- Export the exact runtime sampler for offline Blender review, no profile access.
local M=require("../src/shared/Presentation/CivicWorkMotion")
local ids={"marshal_elian","arborist_vaela","smith_borin","cartographer_nyra","harbormaster_sela","steward_roka"}
local assets={}
for _,id in ipairs(ids)do
 local frames={}
 for i=0,240 do
  local bones={};for name,v in pairs(M.sample(id,i/30,false))do table.insert(bones,string.format('"%s":[%.10f,%.10f,%.10f]',name,v[1],v[2],v[3]))end
  table.sort(bones);table.insert(frames,"{"..table.concat(bones,",").."}")
 end
 table.insert(assets,'"'..id..'":['..table.concat(frames,",")..']')
end
print('{"fps":30,"seconds":8,"frames":{'..table.concat(assets,",")..'}}')
