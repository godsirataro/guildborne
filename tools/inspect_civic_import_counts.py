from pathlib import Path
import bpy,json,struct
O=Path(__file__).resolve().parents[1]/'assets/uat01/borin-forge-v2'
sets={}
for kind in ['glb','fbx']:
 bpy.ops.wm.read_factory_settings(use_empty=True)
 if kind=='glb':bpy.ops.import_scene.gltf(filepath=str(O/'Borin_Forge.glb'))
 else:bpy.ops.import_scene.fbx(filepath=str(O/'Borin_Forge.fbx'))
 sets[kind]={o.name for o in bpy.data.objects if o.type=='MESH'}
print('GLB_ONLY',sets['glb']-sets['fbx']);print('FBX_ONLY',sets['fbx']-sets['glb'])
raw=(O/'Borin_Forge.glb').read_bytes();length=struct.unpack_from('<I',raw,12)[0];d=json.loads(raw[20:20+length]);print('GLB_FILE_TRIANGLES',sum(d['accessors'][p['indices']]['count']//3 for m in d['meshes']for p in m['primitives']))
