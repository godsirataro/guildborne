--!strict
-- Physical routes with synthetic following evidence, not a player acceptance run.
return function():any
 local services=game.ServerScriptService.Server.Services
 local art=require(services.ArchiveHeartCourtArt)(-102,2);art.model.Parent=workspace
 local cast=require(services.CityCharacterKit)(true);cast.Parent=art.model
 local run:any=nil;local results={}
 local ok,result=pcall(function():any
  for _,def in ipairs({{scene="three_gates",actor="cartographer_nyra",points={"stealth_step_1","stealth_step_2","stealth_step_3"}},{scene="supply_court",actor="harbormaster_sela",points={"escort_start","escort_turn","escort_exit"}}})do
   local actor=assert(cast:FindFirstChild(def.actor)) :: Model;local scene=art.scenes[def.scene]
   local route={};for _,id in ipairs(def.points)do local pos=art.markers[def.scene.."/"..id].Position;table.insert(route,Vector3.new(pos.X,art.origin.Y,pos.Z))end
   local callbacks=0
   run=require(services.EscortActor)(actor,route,{scene},function()return {current=true,alive=true,npcAlive=true,position=actor:GetPivot().Position+Vector3.new(0,3,0)}end,function()callbacks+=1 end,true)
   for _=1,1200 do local state=run.Step(.1);if state.status=="Completed"or state.status=="Failed"then break end end
   local state=run.Snapshot();assert(state.status=="Completed",def.scene..":"..tostring(state.reason));assert((actor:GetPivot().Position-route[#route]).Magnitude<.01)
   for _=1,5 do run.Step(.1)end;assert(callbacks==1)
   table.insert(results,{scene=def.scene,length=state.length,completionCallbacks=callbacks});run.Destroy();run=nil
  end
  return {routes=results,actualPlayerEscort=false,syntheticOwnerEvidence=true,profileWrites=0}
 end)
 if run then run.Destroy()end;art.model:Destroy();if not ok then error(result)end;return result
end
