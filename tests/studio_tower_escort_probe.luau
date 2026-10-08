--!strict
-- Physical echo route, synthetic owner following; no real player movement.
return function():any
 local services=game.ServerScriptService.Server.Services
 local art=require(services.TowerCourtArt)(-102,2);art.model.Parent=workspace
 local cast=require(services.TowerCharacterKit)(true);cast.Parent=art.model
 local run:any=nil;local callbacks=0
 local ok,result=pcall(function():any
  local actor=cast:FindFirstChild("bookbinder") :: Model;local scene=art.scenes.memory_chamber
  local o=scene:GetPivot().Position;local route={o+Vector3.new(16,0,12),o+Vector3.new(0,0,12),o+Vector3.new(0,0,6)}
  run=require(services.EscortActor)(actor,route,{scene},function()return {current=true,alive=true,npcAlive=true,position=actor:GetPivot().Position+Vector3.new(0,3,0)}end,function()callbacks+=1 end,true)
  for _=1,500 do local state=run.Step(.1);if state.status=="Completed"or state.status=="Failed"then break end end
  local state=run.Snapshot();assert(state.status=="Completed",tostring(state.reason));assert((actor:GetPivot().Position-route[#route]).Magnitude<.01)
  for _=1,5 do run.Step(.1)end;assert(callbacks==1)
  return {physicalRoutes=1,completionCallbacks=callbacks,length=state.length,actualPlayerEscort=false,syntheticOwnerEvidence=true,profileWrites=0}
 end)
 if run then run.Destroy()end;art.model:Destroy();if not ok then error(result)end;return result
end
