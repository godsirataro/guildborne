"""Round-trip the five local weapon exports without claiming Studio import."""
from pathlib import Path
import bpy, json, hashlib
folder=Path(__file__).resolve().parents[1]/'assets/uat01/weapon-kit'
records=json.loads((folder/'export-report.json').read_text(encoding='utf-8'))
verified=[]
for item in records:
    for extension in ('fbx','glb'):
        bpy.ops.wm.read_factory_settings(use_empty=True)
        path=folder/(item['id']+'.'+extension)
        if extension=='fbx': bpy.ops.import_scene.fbx(filepath=str(path))
        else: bpy.ops.import_scene.gltf(filepath=str(path))
        meshes=[o for o in bpy.context.scene.objects if o.type=='MESH']
        assert len(meshes)==1,path.name
        obj=meshes[0];obj.data.calc_loop_triangles()
        assert len(obj.data.loop_triangles)==item['triangles'],path.name
        assert obj.location.length<.001,path.name
        assert max(abs(obj.dimensions[i]-item['bounds'][i]) for i in range(3))<.002,path.name
        assert all(m and m.use_nodes for m in obj.data.materials),path.name
        assert not any(o.type in {'ARMATURE','CAMERA','LIGHT'} for o in bpy.context.scene.objects),path.name
        verified.append({'file':path.name,'triangles':item['triangles'],'gripOriginPreserved':True,'boundsPreserved':True,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
(folder/'roundtrip-report.json').write_text(json.dumps(verified,indent=2)+'\n',encoding='utf-8')
print('WEAPON_ROUNDTRIP_PASS',len(verified),'exports')
