"""Render a normalized two-second contact-sheet animation from the authored rig."""
from pathlib import Path
import bpy,json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/character-kit'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'Guildborne_Sentinel_Animation_Kit.blend'))
scene=bpy.context.scene;source=bpy.data.objects['Guildborne_Sentinel_Rig'];mesh=bpy.data.objects['Guildborne_Sentinel_Mesh']
records=json.loads((OUT/'manifest.json').read_text(encoding='utf-8'))['clips']
for o in list(scene.objects):
    if o.name.startswith('Preview_'):bpy.data.objects.remove(o,do_unlink=True)
previews=[]
for index,clip in enumerate(records):
    rig=source.copy();rig.data=source.data.copy();rig.animation_data_clear();scene.collection.objects.link(rig)
    rig.name='Motion_'+clip['name'];rig.location=((index%5-2)*4.3,(index//5)*6,0);rig.hide_render=False
    skin=mesh.copy();skin.data=mesh.data.copy();scene.collection.objects.link(skin);skin.parent=rig;skin.hide_render=False
    skin.modifiers['SentinelSkin'].object=rig
    previews.append((rig,clip))
scene.render.resolution_x=960;scene.render.resolution_y=600;scene.cycles.samples=8
frames=ROOT/'build/character-motion-frames';frames.mkdir(parents=True,exist_ok=True)
for index in range(24):
    phase=index/24
    for rig,clip in previews:
        source.animation_data.action=bpy.data.actions['GB_'+clip['name']]
        scene.frame_set(round(1+phase*(clip['frames']-1)))
        for bone in rig.pose.bones:bone.matrix_basis=source.pose.bones[bone.name].matrix_basis.copy()
    bpy.context.view_layer.update();scene.render.filepath=str(frames/f'{index:03}.png')
    bpy.ops.render.render(write_still=True)
print('MOTION_FRAMES_COMPLETE',24)
