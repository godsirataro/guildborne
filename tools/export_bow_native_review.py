"""Preserve actual bow, string and arrow geometry using native review bones."""
from pathlib import Path
import bpy,json
from mathutils import Matrix,Vector
R=Path(__file__).resolve().parents[1];O=R/'build/bow-native-review';O.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.open_mainfile(filepath=str(R/'assets/uat01/bow-contact-v1/Guildborne_Bow_Contact.blend'));scene=bpy.context.scene;rig=next(o for o in scene.objects if o.type=='ARMATURE')
C=Matrix(((1,0,0,0),(0,0,1,0),(0,-1,0,0),(0,0,0,1)));Ci=C.inverted()
def cf(m):
 m=C@m@Ci;return [round(v,7)for v in [*m.translation,*[m[i][j]for i in range(3)for j in range(3)]]]
def vec(v):return [round(v.x,6),round(v.z,6),round(-v.y,6)]
def srgb(v):return v*12.92 if v<=.0031308 else 1.055*v**(1/2.4)-.055
for identity in ['bow','StringUpper','StringLower','Arrow']:
 scene.frame_set(0);bpy.context.view_layer.update();body=identity=='bow';strings=identity.startswith('String')
 objects=[o for o in scene.objects if o.type=='MESH'and o.name not in ['StringUpper','StringLower','Arrow']]if body else[bpy.data.objects[identity]]
 if body:
  bone_list=list(rig.data.bones);indices={b.name:i+1 for i,b in enumerate(bone_list)}
  bones=[dict(name=b.name,parent=indices[b.parent.name]if b.parent else 0,bind=cf(b.matrix_local),localBind=cf(b.parent.matrix_local.inverted()@b.matrix_local if b.parent else b.matrix_local))for b in bone_list]
 elif strings:
  obj=objects[0];ends=[min(v.co.z for v in obj.data.vertices),max(v.co.z for v in obj.data.vertices)];rest=[Matrix.Translation(Vector((0,0,z)))for z in ends]
  bones=[dict(name='End'+str(i),parent=0,bind=cf(m),localBind=cf(m))for i,m in enumerate(rest)]
 else:bones=[dict(name='ArrowRoot',parent=0,bind=cf(Matrix.Identity(4)),localBind=cf(Matrix.Identity(4)))]
 vertices=[];triangles=[];normals=[];colors=[];color_map={};parts=[]
 for obj in objects:
  base=len(vertices);world=obj.matrix_world if body else Matrix.Identity(4);groups={g.index:g.name for g in obj.vertex_groups};skinned=any(m.type=='ARMATURE'for m in obj.modifiers)
  for v in obj.data.vertices:
   bone=indices[groups[v.groups[0].group]]if body and skinned else (2 if strings and v.co.z>0 else 1)
   vertices.append([*vec(world@v.co),bone])
  obj.data.calc_loop_triangles();normal_matrix=world.to_3x3().inverted().transposed()
  for tri in obj.data.loop_triangles:
   mat=obj.data.materials[obj.data.polygons[tri.polygon_index].material_index];rgb=mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value[:3];key=tuple(round(srgb(v),5)for v in rgb)
   if key not in color_map:color_map[key]=len(colors)+1;colors.append(key)
   corners=[]
   for i in tri.vertices:
    normal=obj.data.vertices[i].normal if obj.data.polygons[tri.polygon_index].use_smooth else tri.normal;normals.append(vec((normal_matrix@normal).normalized()));corners.append(len(normals))
   triangles.append([*[base+i+1 for i in tri.vertices],color_map[key],*corners])
  parts.append(dict(name=obj.name,firstVertex=base+1,vertices=len(obj.data.vertices)))
 frames=[];visibility=[]
 for frame in range(181):
  scene.frame_set(frame);bpy.context.view_layer.update();pose=[]
  if body:
   for b in bone_list:
    p=rig.pose.bones[b.name];rest_local=b.parent.matrix_local.inverted()@b.matrix_local if b.parent else b.matrix_local;pose_local=rig.pose.bones[b.parent.name].matrix.inverted()@p.matrix if b.parent else p.matrix;pose.append(cf(rest_local.inverted()@pose_local))
  else:
   obj=objects[0];rotation=obj.matrix_world.to_quaternion().to_matrix().to_4x4()
   if strings:
    for i,z in enumerate(ends):pose.append(cf(rest[i].inverted()@Matrix.Translation(obj.matrix_world@Vector((0,0,z)))@rotation))
   else:pose=[cf(Matrix.Translation(obj.matrix_world.translation)@rotation)];visibility.append(obj.scale.x>.5)
  frames.append(pose)
 result=dict(id=identity,source='bow-contact-v1/Guildborne_Bow_Contact.blend',bones=bones,vertices=vertices,triangles=triangles,normals=normals,colors=colors,parts=parts,frames=frames,fps=30,seconds=6,status='LOCAL_EDITABLEMESH_REVIEW_NOT_PUBLISHED')
 if identity=='Arrow':result['visibility']=visibility
 (O/(identity+'.json')).write_text(json.dumps(result,separators=(',',':'))+'\n');print('BOW_NATIVE_EXPORT',identity,len(bones),len(vertices),len(triangles))
