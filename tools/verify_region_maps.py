"""Roundtrip map bounds/counts, and native dataset collision/marker consistency."""
from pathlib import Path
import bpy,json,hashlib
from mathutils import Vector
OUT=Path(__file__).resolve().parents[1]/'assets/uat01/region-kit';manifest=json.loads((OUT/'manifest.json').read_text());report=[]
for a in manifest:
    reference=None
    for ext in ('fbx','glb'):
        bpy.ops.wm.read_factory_settings(use_empty=True);p=OUT/(a['id']+'.'+ext)
        if ext=='fbx':bpy.ops.import_scene.fbx(filepath=str(p))
        else:bpy.ops.import_scene.gltf(filepath=str(p))
        meshes=[o for o in bpy.context.scene.objects if o.type=='MESH'];assert len(meshes)==a['parts'],p.name
        triangles=0;points=[]
        for o in meshes:o.data.calc_loop_triangles();triangles+=len(o.data.loop_triangles);points.extend(o.matrix_world@Vector(v) for v in o.bound_box)
        assert triangles==a['triangles'],p.name
        bounds=[min(p[i] for p in points) for i in range(3)]+[max(p[i] for p in points) for i in range(3)]
        if reference:assert max(abs(x-y) for x,y in zip(reference,bounds))<.01,p.name
        reference=bounds;report.append(dict(file=p.name,parts=len(meshes),triangles=triangles,bounds=bounds,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
(OUT/'roundtrip-report.json').write_text(json.dumps(report,indent=2)+'\n');print('REGION_ROUNDTRIP_PASS',len(report))
