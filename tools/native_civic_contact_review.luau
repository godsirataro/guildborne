-- Local Edit-mode art review only. No inventory, profile, paid or publishing APIs.
local AssetService=game:GetService("AssetService")
local Http=game:GetService("HttpService")
local M={actors={},meshes={}}
local folder=Instance.new("Folder");folder.Name="CivicContactArtReview";folder:SetAttribute("ReviewOnly",true);folder.Parent=workspace;M.folder=folder
local function cf(v)return CFrame.new(table.unpack(v))end
local function vec(v)return Vector3.new(v[1],v[2],v[3])end
function M:Add(id,origin,data)
 local d=data or Http:JSONDecode(Http:GetAsync("http://127.0.0.1:8769/"..id..".json"))
 local mesh=assert(AssetService:CreateEditableMesh(),"No editable mesh memory")
 table.insert(self.meshes,mesh)
 local bones={}
 for i,b in ipairs(d.bones)do
  local options={Name=b.name,CFrame=cf(b.bind),Virtual=false}
  if b.parent>0 then options.ParentId=bones[b.parent]end
  bones[i]=mesh:AddBone(options)
 end
 local vertices={}
 for i,v in ipairs(d.vertices)do
  local vertex=mesh:AddVertex(vec(v));vertices[i]=vertex
  mesh:SetVertexBones(vertex,{bones[v[4]]});mesh:SetVertexBoneWeights(vertex,{1})
 end
 local colors={}for i,c in ipairs(d.colors)do colors[i]=mesh:AddColor(Color3.new(c[1],c[2],c[3]),1)end
 local normals={}for i,n in ipairs(d.normals)do normals[i]=mesh:AddNormal(vec(n))end
 for _,f in ipairs(d.triangles)do
  local face=mesh:AddTriangle(vertices[f[1]],vertices[f[2]],vertices[f[3]])
  mesh:SetFaceColors(face,{colors[f[4]],colors[f[4]],colors[f[4]]})
  mesh:SetFaceNormals(face,{normals[f[5]],normals[f[6]],normals[f[7]]})
 end
 local part=AssetService:CreateMeshPartAsync(Content.fromObject(mesh))
 part.Name=id;part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
 part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic;part.CFrame=CFrame.new(origin);part.Parent=folder
 local instances={}
 for i,b in ipairs(d.bones)do
  local bone=Instance.new("Bone");bone.Name=b.name;bone.CFrame=cf(b.localBind);bone.Parent=if b.parent>0 then instances[b.parent]else part;instances[i]=bone
 end
 local actor={id=id,mesh=mesh,part=part,bones=instances,data=d};table.insert(self.actors,actor)
 self:Frame(0)
 return {id=id,vertices=#d.vertices,triangles=#d.triangles,bones=#instances,size=tostring(part.Size),meshCenter=tostring(mesh:GetCenter())}
end
function M:Frame(seconds)
 for _,a in ipairs(self.actors)do
  local index=math.floor(seconds*a.data.fps)%180+1
  local frame=a.data.frames[index]
  for i,bone in ipairs(a.bones)do bone.Transform=cf(frame[i])end
  if a.data.visibility then a.part.Transparency=if a.data.visibility[index]then 0 else 1 end
 end
end
function M:Destroy()
 if self.connection then self.connection:Disconnect();self.connection=nil end
 folder:Destroy();for _,mesh in ipairs(self.meshes)do mesh:Destroy()end
 table.clear(self.actors);table.clear(self.meshes)
end
return M
