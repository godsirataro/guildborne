"""Re-import every regional enemy rest/animation export, checking actual rig data."""
from pathlib import Path
import bpy,json,hashlib,sys,argparse
parser=argparse.ArgumentParser();parser.add_argument('--kit',default='assets/uat01/enemy-kit');parser.add_argument('--count',type=int,default=12);parser.add_argument('--bosses',type=int,default=3)
options=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
folder=Path(__file__).resolve().parents[1]/options.kit;manifest=json.loads((folder/'manifest.json').read_text(encoding='utf-8'));report=[]
assert len(manifest['assets'])==options.count and sum(a['role']=='Boss' for a in manifest['assets'])==options.bosses
for asset in manifest['assets']:
    entries=[{'file':f} for f in asset['restFiles']]+asset['clips']
    for entry in entries:
        bpy.ops.wm.read_factory_settings(use_empty=True);path=folder/entry['file']
        if path.suffix=='.fbx':bpy.ops.import_scene.fbx(filepath=str(path))
        else:bpy.ops.import_scene.gltf(filepath=str(path))
        rigs=[o for o in bpy.context.scene.objects if o.type=='ARMATURE'];assert len(rigs)==1,path.name
        rig=rigs[0];shapes={p.custom_shape for p in rig.pose.bones if p.custom_shape};meshes=[o for o in bpy.context.scene.objects if o.type=='MESH' and o not in shapes];assert len(meshes)==1,path.name
        mesh=meshes[0];mesh.data.calc_loop_triangles();assert len(mesh.data.loop_triangles)==asset['triangles'],path.name;assert len(rig.data.bones)==asset['bones'],path.name
        assert any(m.type=='ARMATURE' and m.object==rig for m in mesh.modifiers),path.name
        for v in mesh.data.vertices:
            assert v.groups and abs(sum(g.weight for g in v.groups)-1)<1e-5,path.name
            assert all(mesh.vertex_groups[g.group].name in rig.data.bones for g in v.groups),path.name
        record={'file':path.name,'asset':asset['id'],'triangles':asset['triangles'],'bones':asset['bones'],'weightsNormalized':True,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        if 'frames' in entry:
            assert rig.animation_data and rig.animation_data.action,path.name
            start,end=map(float,rig.animation_data.action.frame_range);assert abs(end-start-entry['frames']+1)<.1,path.name
            def pose(frame):
                bpy.context.scene.frame_set(round(frame));return {p.name:tuple(v for row in p.matrix for v in row) for p in rig.pose.bones}
            first=pose(start);quarter=pose(start+(end-start)*.25);last=pose(end)
            delta=max(abs(a-b) for name in first for a,b in zip(first[name],quarter[name]));assert delta>.001,(path.name,'static clip')
            for p in (quarter,last):assert max(abs(a-b) for a,b in zip(first['Root'],p['Root']))<.001,(path.name,'moving root')
            if entry['loop']:assert max(abs(a-b) for name in first for a,b in zip(first[name],last[name]))<.001,(path.name,'loop seam')
            record.update(frames=entry['frames'],sampledMotion=delta,rootStationary=True,loopSeamVerified=entry['loop'])
        report.append(record)
(folder/'roundtrip-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('ENEMY_RIG_ROUNDTRIP_PASS',len(report),'exports; Studio import and behavior still pending')
