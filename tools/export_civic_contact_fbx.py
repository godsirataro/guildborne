"""Export the reviewed source rigs as baked FBX import candidates."""
from pathlib import Path
import bpy
R=Path(__file__).resolve().parents[1]
for folder,blend,stem in [('borin-forge-v2','Guildborne_Borin_Forge.blend','Borin_Forge'),('vaela-garden-v1','Guildborne_Vaela_Garden.blend','Vaela_Garden')]:
 o=R/'assets/uat01'/folder;bpy.ops.wm.open_mainfile(filepath=str(o/blend));bpy.context.scene.frame_set(0);bpy.ops.object.select_all(action='DESELECT')
 for obj in bpy.context.scene.objects:
  if obj.type in ['MESH','ARMATURE']:obj.select_set(True)
 bpy.context.view_layer.objects.active=next(obj for obj in bpy.context.selected_objects if obj.type=='ARMATURE')
 bpy.ops.export_scene.fbx(filepath=str(o/(stem+'.fbx')),use_selection=True,object_types={'ARMATURE','MESH'},add_leaf_bones=False,bake_anim=True,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,bake_anim_step=1,bake_anim_simplify_factor=0,axis_forward='-Z',axis_up='Y')
 print('CIVIC_FBX_EXPORTED',folder)
