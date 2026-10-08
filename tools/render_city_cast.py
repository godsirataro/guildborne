"""Frame all six city characters without clipping the lowest row."""
from pathlib import Path
import bpy
from mathutils import Vector
out=Path(__file__).resolve().parents[1]/'assets/uat01/city-cast'
bpy.ops.wm.open_mainfile(filepath=str(out/'Guildborne_City_Cast.blend'))
scene=bpy.context.scene;cam=scene.camera
cam.location=(2,45,12);cam.rotation_euler=(Vector((0,0,9))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=25
scene.render.resolution_x=1500;scene.render.resolution_y=1600;scene.render.filepath=str(out/'preview.png')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(out/'Guildborne_City_Cast.blend'));bpy.ops.render.render(write_still=True)
