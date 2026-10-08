"""Reflow the saved hero overview into three rows of five without regenerating exports."""
from pathlib import Path
import bpy
OUT=Path(__file__).resolve().parents[1]/'assets/uat01/hero-kit'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'Guildborne_Hero_Gallery.blend'))
classes=['knight','warrior','archer','mage','priest']
for col,cls in enumerate(classes):
    for row in range(3):
        id=f'{cls}_{row+1:02}';rig=bpy.data.objects.get(id+'_Rig');assert rig
        rig.location=((2-col)*7,0,(2-row)*7.4)
        label=next(o for o in bpy.context.scene.objects if o.type=='FONT' and o.data.body==id.replace('_',' ').upper())
        label.location=(rig.location.x+2.8,.3,rig.location.z-.65)
bpy.context.scene.camera.data.ortho_scale=40;bpy.context.scene.render.filepath=str(OUT/'preview.png');bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Hero_Gallery.blend'));bpy.ops.render.render(write_still=True)
