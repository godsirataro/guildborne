"""Export existing Blender geometry/poses for local EditableMesh review only."""
from pathlib import Path
import bpy,json,sys
from mathutils import Matrix,Vector
R=Path(__file__).resolve().parents[1];OUT=R/'build/civic-native-review';OUT.mkdir(parents=True,exist_ok=True)
jobs=[('borin','borin-forge-v2','Guildborne_Borin_Forge.blend'),('vaela','vaela-garden-v1','Guildborne_Vaela_Garden.blend'),('roka','roka-hearth-v1','Guildborne_Roka_Hearth.blend')]+[(n,n+'-desk-v1','Guildborne_'+n.title()+'_Desk.blend')for n in ['elian','nyra','sela']]
if '--sword'in sys.argv:
 jobs=[('sword','sword-contact-v1','Guildborne_Sword_Contact.blend')];OUT=R/'build/sword-native-review';OUT.mkdir(parents=True,exist_ok=True)
C=Matrix(((1,0,0,0),(0,0,1,0),(0,-1,0,0),(0,0,0,1)));Ci=C.inverted()
def cf(m):
 m=C@m@Ci;return [round(v,7)for v in [*m.translation,*[m[i][j]for i in range(3)for j in range(3)]]]
def vec(v):return [round(v.x,6),round(v.z,6),round(-v.y,6)]
def srgb(v):return v*12.92 if v<=.0031308 else 1.055*v**(1/2.4)-.055
for identity,folder,blend in jobs:
 bpy.ops.wm.open_mainfile(filepath=str(R/'assets/uat01'/folder/blend));s=bpy.context.scene;s.frame_set(0);rig=next(o for o in s.objects if o.type=='ARMATURE');bone_list=list(rig.data.bones);indices={b.name:i+1 for i,b in enumerate(bone_list)}
 bones=[dict(name=b.name,parent=indices[b.parent.name]if b.parent else 0,bind=cf(b.matrix_local),localBind=cf(b.parent.matrix_local.inverted()@b.matrix_local if b.parent else b.matrix_local))for b in bone_list]
 vertices=[];triangles=[];normals=[];colors=[];color_map={};parts=[]
 for o in s.objects:
  if o.type!='MESH'or o.name.startswith(('ContactSpark','WaterDrop','Steam_','StampedSeal')):continue
  base=len(vertices);mat=o.data.materials[0];rgb=mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value[:3]
  key=tuple(round(srgb(v),5)for v in rgb)
  if key not in color_map:color_map[key]=len(colors)+1;colors.append(key)
  color=color_map[key];groups={g.index:g.name for g in o.vertex_groups};skinned=any(m.type=='ARMATURE'for m in o.modifiers)
  for v in o.data.vertices:
   bone=indices[groups[v.groups[0].group]]if skinned and v.groups else indices['Root'];vertices.append([*vec(o.matrix_world@v.co),bone])
  o.data.calc_loop_triangles();normal_matrix=o.matrix_world.to_3x3().inverted().transposed()
  for tri in o.data.loop_triangles:
   corners=[]
   for i in tri.vertices:
    normal=o.data.vertices[i].normal if o.data.polygons[tri.polygon_index].use_smooth else tri.normal;normals.append(vec((normal_matrix@normal).normalized()));corners.append(len(normals))
   triangles.append([*[base+i+1 for i in tri.vertices],color,*corners])
  parts.append(dict(name=o.name,firstVertex=base+1,vertices=len(o.data.vertices)))
 frames=[]
 for frame in range(181):
  s.frame_set(frame);bpy.context.view_layer.update();pose=[]
  for b in bone_list:
   p=rig.pose.bones[b.name];rest_local=b.parent.matrix_local.inverted()@b.matrix_local if b.parent else b.matrix_local;pose_local=rig.pose.bones[b.parent.name].matrix.inverted()@p.matrix if b.parent else p.matrix;pose.append(cf(rest_local.inverted()@pose_local))
  frames.append(pose)
 result=dict(id=identity,source=folder+'/'+blend,units='stud',bones=bones,vertices=vertices,triangles=triangles,normals=normals,colors=colors,parts=parts,frames=frames,fps=30,seconds=6,excluded='Cosmetic water/sparks/steam/seal object motion; native particle binding pending',status='LOCAL_EDITABLEMESH_REVIEW_NOT_PUBLISHED')
 (OUT/(identity+'.json')).write_text(json.dumps(result,separators=(',',':'))+'\n',encoding='utf-8');print('NATIVE_REVIEW_EXPORT',identity,len(vertices),len(triangles))
