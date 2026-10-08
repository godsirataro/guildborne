"""Frame the four editable course rigs as a compact model review, not gameplay."""
from pathlib import Path
import bpy
from mathutils import Vector
out=Path(__file__).resolve().parents[1]/'assets/uat01/course-characters'
bpy.ops.wm.open_mainfile(filepath=str(out/'Guildborne_Crown_Road_Cast.blend'))
scene=bpy.context.scene;cam=scene.camera
cam.location=(3,45,20);cam.rotation_euler=(Vector((0,0,17))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=30
scene.render.resolution_x=1600;scene.render.resolution_y=500;scene.render.filepath=str(out/'preview.png')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(out/'Guildborne_Crown_Road_Cast.blend'));bpy.ops.render.render(write_still=True)
