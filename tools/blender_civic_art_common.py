"""Small reusable authoring primitives for local civic contact studies."""
import bpy,math
from mathutils import Vector,Matrix
class CivicArt:
 def __init__(self,name,colors,bones):
  bpy.ops.wm.read_factory_settings(use_empty=True);self.scene=bpy.context.scene;self.scene.render.fps=30;self.scene.frame_start=0;self.scene.frame_end=180;self.objects=[];self.materials={}
  for label,rgb in colors.items():
   c=tuple(v/12.92 if v<=.04045 else((v+.055)/1.055)**2.4 for v in rgb);m=bpy.data.materials.new(label);m.use_nodes=True;m.diffuse_color=(*c,1);bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=(*c,1);bs.inputs['Roughness'].default_value=.65;self.materials[label]=m
  self.data=bpy.data.armatures.new(name+'Skeleton');self.rig=bpy.data.objects.new(name+'_Rig',self.data);self.scene.collection.objects.link(self.rig);bpy.context.view_layer.objects.active=self.rig;self.rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
  for label,h,t,parent in bones:
   b=self.data.edit_bones.new(label);b.head=h;b.tail=t
   if parent:b.parent=self.data.edit_bones[parent]
  bpy.ops.object.mode_set(mode='OBJECT');self.rig.select_set(False)
 def finish(self,o,name,mat,bone=None):
  o.name=name;o.data.materials.append(self.materials[mat]);self.objects.append(o)
  if bone:
   g=o.vertex_groups.new(name=bone);g.add(list(range(len(o.data.vertices))),1,'REPLACE');m=o.modifiers.new('CivicSkin','ARMATURE');m.object=self.rig;o.parent=self.rig
  return o
 def box(self,name,pos,size,mat,bone=None):
  bpy.ops.mesh.primitive_cube_add(size=1,location=pos);o=bpy.context.object;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);m=o.modifiers.new('SoftEdges','BEVEL');m.width=.04;m.segments=2;bpy.ops.object.modifier_apply(modifier=m.name);return self.finish(o,name,mat,bone)
 def oval(self,name,pos,size,mat,bone=None):
  bpy.ops.mesh.primitive_uv_sphere_add(segments=12,ring_count=8,radius=1,location=pos);o=bpy.context.object;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
  for f in o.data.polygons:f.use_smooth=True
  return self.finish(o,name,mat,bone)
 def rod(self,name,a,b,r,mat,bone=None):
  a=Vector(a);b=Vector(b);bpy.ops.mesh.primitive_cylinder_add(vertices=10,radius=r,depth=(b-a).length,location=(a+b)/2);o=bpy.context.object;o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();return self.finish(o,name,mat,bone)
 def ring(self,name,pos,major,minor,mat,bone=None):
  bpy.ops.mesh.primitive_torus_add(major_segments=16,minor_segments=6,major_radius=major,minor_radius=minor,location=pos);return self.finish(bpy.context.object,name,mat,bone)
 def pose_segment(self,name,a,b):
  p=self.rig.pose.bones[name];p.rotation_mode='QUATERNION';p.matrix=Matrix.Translation(Vector(a))@(Vector(b)-Vector(a)).to_track_quat('Y','Z').to_matrix().to_4x4();self.key(p)
 def key(self,p):
  bpy.context.view_layer.update();p.keyframe_insert('location');p.keyframe_insert('rotation_quaternion');p.keyframe_insert('scale')
 def arm(self,side,wrist):
  a=self.data.bones[side+'UpperArm'];b=self.data.bones[side+'LowerArm'];head=Vector(a.head_local);w=Vector(wrist);elbow=solve_elbow(head,w,a.length,b.length,1 if side=='Right' else -1)
  self.pose_segment(side+'UpperArm',head,elbow);self.pose_segment(side+'LowerArm',elbow,w);p=self.rig.pose.bones[side+'Hand'];p.rotation_mode='QUATERNION';p.matrix=Matrix.Translation(w)@self.data.bones[side+'Hand'].matrix_local.to_3x3().to_4x4();self.key(p)
 def export(self,out,stem,view=(8,-13,8),target=(0,-.4,2.7),frame=90):
  out.mkdir(parents=True,exist_ok=True);s=self.scene
  for action in bpy.data.actions:
   for layer in action.layers:
    for strip in layer.strips:
     for bag in strip.channelbags:
      for curve in bag.fcurves:
       for key in curve.keyframe_points:key.interpolation='LINEAR'
  s.world=bpy.data.worlds.new('CivicStudio');s.world.color=(.12,.12,.12)
  for loc,power in [((4,-6,8),1100),((-4,-3,7),800),((0,4,7),1100)]:
   bpy.ops.object.light_add(type='AREA',location=loc);o=bpy.context.object;o.data.energy=power;o.data.size=5;o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()
  bpy.ops.object.camera_add(location=view);cam=bpy.context.object;cam.rotation_euler=(Vector(target)-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=7.4;s.camera=cam
  s.render.engine='CYCLES';s.cycles.samples=16;s.render.resolution_x=1200;s.render.resolution_y=1200;s.render.resolution_percentage=100;s.view_settings.view_transform='AgX';s.frame_set(frame);bpy.context.preferences.filepaths.save_version=0
  bpy.ops.wm.save_as_mainfile(filepath=str(out/('Guildborne_'+stem+'.blend')));bpy.ops.object.select_all(action='DESELECT');self.rig.select_set(True)
  for o in self.objects:o.select_set(True)
  bpy.context.view_layer.objects.active=self.rig
  bpy.ops.export_scene.gltf(filepath=str(out/(stem+'.glb')),use_selection=True,export_format='GLB',export_animations=True,export_animation_mode='SCENE',export_anim_scene_split_object=False,export_frame_range=True,export_force_sampling=True)
  bpy.ops.export_scene.fbx(filepath=str(out/(stem+'.fbx')),use_selection=True,object_types={'ARMATURE','MESH'},add_leaf_bones=False,bake_anim=True,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,bake_anim_step=1,bake_anim_simplify_factor=0,axis_forward='-Z',axis_up='Y')
  s.render.filepath=str(out/'preview.png');bpy.ops.render.render(write_still=True)
def solve_elbow(head,wrist,l1,l2,sign):
 head=Vector(head);wrist=Vector(wrist);distance=(wrist-head).length;assert abs(l1-l2)<distance<l1+l2
 direction=(wrist-head).normalized();normal=Vector((sign,0,0));normal=(normal-direction*normal.dot(direction)).normalized();u=(l1*l1-l2*l2+distance*distance)/(2*distance);return head+direction*u+normal*math.sqrt(max(0,l1*l1-u*u))
