-- Explicit isolated art fixture, not a gameplay action or damage test.
return function(actor:any,review:any):any
 assert(#actor.bones==16 and #actor.data.triangles==2344)
 local function joint(name:string):Bone
  for _,b in ipairs(actor.bones)do if b.Name==name then return b end end;error(name)
 end
 local grip=nil;for _,p in ipairs(actor.data.parts)do if p.name=="Sword_0_Grip"then grip=p end end;assert(grip)
 local function vertex(index:number):Vector3
  local v=actor.data.vertices[index];local bind=CFrame.new(table.unpack(actor.data.bones[v[4]].bind));return actor.bones[v[4]].TransformedWorldCFrame:PointToWorldSpace(bind:PointToObjectSpace(Vector3.new(v[1],v[2],v[3])))
 end
 review:Frame(0);local fixed={};for _,name in ipairs({"Root","LeftFoot","RightFoot"})do fixed[name]=joint(name).TransformedWorldCFrame end
 local maximum=0
 for frame=0,180 do
  review:Frame((frame+.001)/30);local low=Vector3.one*math.huge;local high=-low
  for i=grip.firstVertex,grip.firstVertex+grip.vertices-1 do local p=vertex(i);low=low:Min(p);high=high:Max(p)end
  local err=((low+high)/2-joint("RightHand").TransformedWorldCFrame.Position).Magnitude;assert(err<.002);maximum=math.max(maximum,err)
  for name,cframe in pairs(fixed)do assert((joint(name).TransformedWorldCFrame.Position-cframe.Position).Magnitude<.002)end
 end
 review:Frame(.3)
 return {status="PASS",samples=181,bones=16,triangles=2344,maximumGripError=maximum,fixedRootFeet=true,gameplayBound=false,profileWrites=0,scope="Local isolated EditableMesh poses; no combat acceptance"}
end
