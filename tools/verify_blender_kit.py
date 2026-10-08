"""Round-trip local exports in Blender; does not upload or certify Roblox import."""
from pathlib import Path
import bpy
import json
import argparse,sys

root=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--kit',default='assets/uat01/adventure-kit')
options=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
folder=root/options.kit
expected=json.loads((folder/'export-report.json').read_text(encoding='utf-8'))
verified=[]
for item in expected:
    for extension in ['fbx','glb']:
        bpy.ops.wm.read_factory_settings(use_empty=True)
        path=folder/(item['id']+'.'+extension)
        if extension=='fbx': bpy.ops.import_scene.fbx(filepath=str(path))
        else: bpy.ops.import_scene.gltf(filepath=str(path))
        meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
        assert len(meshes)==1,(path.name,len(meshes))
        obj=meshes[0];obj.data.calc_loop_triangles()
        assert len(obj.data.loop_triangles)==item['triangles'],path.name
        assert (obj.location.length<.001),path.name
        assert max(abs(obj.dimensions[i]-item['bounds'][i]) for i in range(3))<.002,path.name
        assert not any(o.type in {'ARMATURE','CAMERA','LIGHT'} for o in bpy.context.scene.objects),path.name
        assert all(m and m.use_nodes for m in obj.data.materials),path.name
        verified.append({'file':path.name,'triangles':len(obj.data.loop_triangles),'originPreserved':True,'boundsPreserved':True})
(folder/'roundtrip-report.json').write_text(json.dumps(verified,indent=2)+'\n',encoding='utf-8')
print('ROUNDTRIP_PASS',len(verified),'exports; Roblox mesh import still pending')
