"""Re-import each rig/animation candidate, validating weights and sampled motion."""
from pathlib import Path
import bpy,json,math,hashlib
folder=Path(__file__).resolve().parents[1]/'assets/uat01/character-kit'
manifest=json.loads((folder/'manifest.json').read_text(encoding='utf-8'))
report=[]
entries=[{'file':'Guildborne_Sentinel_Rest.fbx'},{'file':'Guildborne_Sentinel_Rest.glb'}]+manifest['clips']
for entry in entries:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    file=folder/entry['file']
    if file.suffix=='.fbx':bpy.ops.import_scene.fbx(filepath=str(file))
    else:bpy.ops.import_scene.gltf(filepath=str(file))
    rigs=[o for o in bpy.context.scene.objects if o.type=='ARMATURE']
    # glTF importer creates an Icosphere used only as the bones' viewport shape.
    shapes={p.custom_shape for r in rigs for p in r.pose.bones if p.custom_shape}
    meshes=[o for o in bpy.context.scene.objects if o.type=='MESH' and o not in shapes]
    assert len(meshes)==1 and len(rigs)==1,file.name
    mesh,rig=meshes[0],rigs[0];mesh.data.calc_loop_triangles()
    assert len(mesh.data.loop_triangles)==manifest['triangles'],file.name
    assert len(rig.data.bones)==manifest['bones'],file.name
    assert mesh.modifiers and any(m.type=='ARMATURE' and m.object==rig for m in mesh.modifiers),file.name
    for v in mesh.data.vertices:
        assert v.groups and abs(sum(g.weight for g in v.groups)-1)<1e-5,file.name
        assert all(mesh.vertex_groups[g.group].name in rig.data.bones for g in v.groups),file.name
    record={'file':file.name,'triangles':len(mesh.data.loop_triangles),'bones':len(rig.data.bones),'normalizedWeights':True,
        'sha256':hashlib.sha256(file.read_bytes()).hexdigest()}
    if 'frames' in entry:
        assert rig.animation_data and rig.animation_data.action,file.name
        action=rig.animation_data.action
        start,end=map(float,action.frame_range)
        assert abs((end-start)-(entry['frames']-1))<.1,(file.name,start,end,entry['frames'])
        def pose(frame):
            bpy.context.scene.frame_set(round(frame))
            return {b.name:tuple(v for row in b.matrix for v in row) for b in rig.pose.bones}
        first=pose(start);quarter=pose(start+(end-start)*.25);last=pose(end)
        delta=max(abs(a-b) for name in first for a,b in zip(first[name],quarter[name]))
        assert delta>.001,(file.name,'no sampled motion',delta)
        for other in (quarter,last):assert max(abs(a-b) for a,b in zip(first['Root'],other['Root']))<.001,(file.name,'root motion')
        if entry['loop']:
            assert max(abs(a-b) for name in first for a,b in zip(first[name],last[name]))<.001,(file.name,'loop seam')
        record.update(animationPresent=True,frames=entry['frames'],sampledMotion=delta,loopSeamVerified=entry['loop'],rootStationary=True)
    report.append(record)
(folder/'roundtrip-report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('CHARACTER_ROUNDTRIP_PASS',len(report),'files; Roblox import and retarget still pending')
