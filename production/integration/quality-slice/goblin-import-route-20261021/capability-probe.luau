local A=game:GetService("AssetService")
local H=game:GetService("HttpService")
assert(game.PlaceId==0 and game.GameId==0,"LOCAL_LAB_REQUIRED")
local resources={}
local function keep(o) assert(o,"ALLOCATION_FAILED");table.insert(resources,o);return o end
local report={scope="DISPOSABLE_API_CAPABILITY_ONLY",workspaceBefore=#workspace:GetChildren(),published=false}
local ok,err=xpcall(function()
 local mesh=keep(A:CreateEditableMesh())
 local a=mesh:AddVertex(Vector3.new(0,0,0))
 local b=mesh:AddVertex(Vector3.new(1,0,0))
 local c=mesh:AddVertex(Vector3.new(0,1,0))
 local f=mesh:AddTriangle(a,b,c)
 mesh:SetFaceUVs(f,{mesh:AddUV(Vector2.new(0,0)),mesh:AddUV(Vector2.new(1,0)),mesh:AddUV(Vector2.new(0,1))})
 local part=keep(A:CreateMeshPartAsync(Content.fromObject(mesh)))
 local maps={}
 for _,entry in ipairs({{"ColorMap",{160,90,30,255}},{"NormalMap",{128,128,255,255}},{"RoughnessMap",{128,128,128,255}},{"MetalnessMap",{180,180,180,255}}}) do
  local im=keep(A:CreateEditableImage({Size=Vector2.new(4,4)}))
  local pixels=buffer.create(64)
  for p=0,15 do for k=1,4 do buffer.writeu8(pixels,p*4+k-1,entry[2][k]) end end
  im:WritePixelsBuffer(Vector2.zero,Vector2.new(4,4),pixels)
  assert(buffer.tostring(im:ReadPixelsBuffer(Vector2.zero,Vector2.new(4,4)))==buffer.tostring(pixels),"PIXEL_READBACK_FAILED")
  maps[entry[1]]=Content.fromObject(im)
 end
 local appearance=keep(A:CreateSurfaceAppearanceAsync(maps))
 appearance.Parent=part
 report.meshPartClass=part.ClassName
 report.appearanceClass=appearance.ClassName
 report.faces=#mesh:GetFaces()
 report.uvs=#mesh:GetUVs()
 report.maps={}
 for _,name in ipairs({"ColorMapContent","NormalMapContent","RoughnessMapContent","MetalnessMapContent"}) do report.maps[name]=tostring(appearance[name]) end
 report.pixelReadbackVerified=4
 report.parentedIntoDataModel=false
end,debug.traceback)
report.success=ok
report.error=if ok then nil else tostring(err)
local cleanupErrors={}
local count=#resources
for i=#resources,1,-1 do local good,e=pcall(function() resources[i]:Destroy() end);if not good then table.insert(cleanupErrors,tostring(e)) end;resources[i]=nil end
report.createdResources=count
report.cleanupErrors=cleanupErrors
report.remainingTrackedResources=#resources
report.workspaceAfter=#workspace:GetChildren()
return H:JSONEncode(report)
