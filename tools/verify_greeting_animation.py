"""Validate the actual exported greeting, including return pose and motion."""
from pathlib import Path
import bpy,json,hashlib
OUT=Path(__file__).resolve().parents[1]/'assets/uat01/cosmetic-kit';p=OUT/'friendly_greeting_Animation.fbx'
bpy.ops.wm.read_factory_settings(use_empty=True);bpy.ops.import_scene.fbx(filepath=str(p))
rig=next(o for o in bpy.context.scene.objects if o.type=='ARMATURE');assert len(rig.data.bones)==16
start,end=rig.animation_data.action.frame_range;assert end-start==60
def pose(frame):
    bpy.context.scene.frame_set(frame);return {b.name:tuple(x for row in b.matrix for x in row) for b in rig.pose.bones}
first=pose(round(start));raised=pose(round(start+25));last=pose(round(end))
assert max(abs(a-b) for n in first for a,b in zip(first[n],last[n]))<1e-4
assert max(abs(a-b) for a,b in zip(first['Root'],raised['Root']))<1e-4
assert max(abs(a-b) for n in first for a,b in zip(first[n],raised[n]))>.5
bpy.context.scene.frame_set(round(start+25));rise=rig.pose.bones['RightHand'].matrix.translation.z-rig.pose.bones['RightUpperArm'].matrix.translation.z;assert rise>.6
(OUT/'greeting-roundtrip.json').write_text(json.dumps(dict(file=p.name,bones=16,frames=61,returnedToRest=True,rootStationary=True,raisedHandHeight=rise,sha256=hashlib.sha256(p.read_bytes()).hexdigest()),indent=2)+'\n');print('GREETING_ROUNDTRIP_PASS')
