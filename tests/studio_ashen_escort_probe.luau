--!strict
-- Physical route fixture with synthetic owner following the actor; no player movement.
return function():any
 local services=game.ServerScriptService.Server.Services
 local art=require(services.AshenCourtArt)(102,2);art.model.Parent=workspace
 local cast=require(services.AshenCharacterKit)(true);cast.Parent=art.model
 local make=require(services.EscortActor);local callbacks=0;local routes=0;local lengths={}
 local ok,result=pcall(function():any
  for _,choice in ipairs({"gatekeeper","sheltered","direct"})do
   local name=if choice=="gatekeeper"then "gatekeeper"else "bridgewright"
   local actor=cast:FindFirstChild(name) :: Model
   local scene=art.scenes[if choice=="gatekeeper"then "caravan_checkpoint"else "ash_bridge"]
   local o=scene:GetPivot().Position;local x=if choice=="sheltered"then -20 else 20
   local route=if choice=="gatekeeper"then {o+Vector3.new(-12,0,-8),o+Vector3.new(-12,0,0),o}else {o+Vector3.new(0,0,14),o+Vector3.new(0,0,19),o+Vector3.new(x,0,19),o+Vector3.new(x,0,13)}
   local run=make(actor,route,{scene},function()return {current=true,alive=true,npcAlive=true,position=actor:GetPivot().Position+Vector3.new(0,3,0)}end,function()callbacks+=1 end,true)
   for _=1,500 do local state=run.Step(.1);if state.status=="Completed"or state.status=="Failed"then break end end
   local state=run.Snapshot();assert(state.status=="Completed",choice.." "..tostring(state.reason));assert((actor:GetPivot().Position-route[#route]).Magnitude<.01)
   for _=1,5 do run.Step(.1)end;routes+=1;assert(callbacks==routes,"Duplicate route completion")
   table.insert(lengths,state.length);run.Destroy()
  end
  return {physicalRoutes=routes,completionCallbacks=callbacks,lengths=lengths,actualPlayerEscort=false,syntheticOwnerEvidence=true,profileWrites=0}
 end)
 art.model:Destroy();if not ok then error(result)end;return result
end
