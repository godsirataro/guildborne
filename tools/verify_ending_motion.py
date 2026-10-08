"""Blender reimport check of exported object-motion storyboards."""
from pathlib import Path
import bpy,json,struct,math
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/archive-ending-motion'
manifest=json.loads((OUT/'manifest.json').read_text(encoding='utf-8'));results=[]
for clip in manifest['clips']:
 path=OUT/clip['file'];raw=path.read_bytes();magic,version,length=struct.unpack_from('<III',raw)
 assert magic==0x46546c67 and version==2 and length==len(raw)
 n,kind=struct.unpack_from('<II',raw,12);assert kind==0x4e4f534a;gltf=json.loads(raw[20:20+n])
 assert len(gltf['animations'])==1
 animation=gltf['animations'][0];times=[gltf['accessors'][s['input']]for s in animation['samplers']]
 assert all(abs(a['min'][0])<1e-6 and abs(a['max'][0]-8)<1e-5 for a in times)
 bpy.ops.wm.read_factory_settings(use_empty=True);bpy.context.scene.render.fps=30
 bpy.ops.import_scene.gltf(filepath=str(path));scene=bpy.context.scene
 meshes=[o for o in scene.objects if o.type=='MESH'];assert len(meshes)==clip['parts']
 scene.frame_set(0);start={o.name:o.matrix_world.copy()for o in meshes}
 scene.frame_set(90)
 def delta(a,b):return max(abs(a[i][j]-b[i][j])for i in range(4)for j in range(4))
 moved=sum(delta(o.matrix_world,start[o.name])>1e-6 for o in meshes);assert moved==clip['animatedParts'],(clip['id'],moved)
 scene.frame_set(240);error=max(delta(o.matrix_world,start[o.name])for o in meshes);assert error<1e-5,error
 assert all(all(math.isfinite(v)for row in o.matrix_world for v in row)for o in meshes)
 triangles=sum(len(o.data.polygons)*2 for o in meshes) # Informational only; GLB triangulates.
 results.append(dict(id=clip['id'],meshes=len(meshes),animatedMeshes=moved,animations=1,seconds=8,endpointMaxError=error,channels=len(animation['channels']),reimportVerified=True))
(OUT/'roundtrip-report.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
print('ENDING_MOTION_ROUNDTRIP_PASS',results)
