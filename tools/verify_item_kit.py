"""Blender export round-trip verification for the complete inventory display kit."""
from pathlib import Path
import bpy,json,hashlib,sys,argparse
parser=argparse.ArgumentParser();parser.add_argument('--kit',default='assets/uat01/item-kit');options=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
folder=Path(__file__).resolve().parents[1]/options.kit;report=[]
for item in json.loads((folder/'export-report.json').read_text(encoding='utf-8')):
    for extension in ('fbx','glb'):
        bpy.ops.wm.read_factory_settings(use_empty=True);path=folder/(item['id']+'.'+extension)
        if extension=='fbx':bpy.ops.import_scene.fbx(filepath=str(path))
        else:bpy.ops.import_scene.gltf(filepath=str(path))
        models=[o for o in bpy.context.scene.objects if o.type=='MESH'];assert len(models)==1,path.name
        o=models[0];o.data.calc_loop_triangles();assert len(o.data.loop_triangles)==item['triangles'],path.name
        assert o.location.length<.001 and max(abs(o.dimensions[i]-item['bounds'][i]) for i in range(3))<.002,path.name
        assert all(m and m.use_nodes for m in o.data.materials),path.name
        report.append({'file':path.name,'triangles':item['triangles'],'boundsAndOriginPreserved':True,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
(folder/'roundtrip-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('ITEM_ROUNDTRIP_PASS',len(report),'exports')
