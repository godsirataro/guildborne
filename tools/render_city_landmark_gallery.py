"""Arrange the editable landmark gallery in six readable cells; exports stay untouched."""
from pathlib import Path
import bpy,json,math
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/city-landmarks'
bpy.ops.wm.open_mainfile(filepath=str(OUT/'Guildborne_City_Landmarks.blend'))
scene=bpy.context.scene
for o in list(scene.objects):
 if o.type=='FONT':bpy.data.objects.remove(o,do_unlink=True)
assets=json.loads((OUT/'kit.json').read_text())['assets']
for i,a in enumerate(assets):
 o=bpy.data.objects[a['id']];bounds=[o.matrix_world@Vector(v) for v in o.bound_box]
 center=sum(bounds,Vector())/8;x=(1-i%3)*4.8;z=(1-i//3)*5.4
 o.location+=Vector((x,0,z))-center
 for value,dz,size in [(a['city'].upper(),-2.45,.23),(a['name'].upper(),-2.82,.14)]:
  bpy.ops.object.text_add(location=(x,5,z+dz),rotation=(math.pi/2,0,math.pi))
  label=bpy.context.object;label.data.body=value;label.data.align_x='CENTER';label.data.size=size;label.data.materials.append(bpy.data.materials['ivory'])
camera=scene.camera;camera.location=(0,35,2.7);camera.rotation_euler=(Vector((0,0,2.7))-camera.location).to_track_quat('-Z','Y').to_euler();camera.data.ortho_scale=18
scene.render.resolution_x=1800;scene.render.resolution_y=1200;scene.render.filepath=str(OUT/'preview.png')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_City_Landmarks.blend'))
bpy.ops.render.render(write_still=True)
print('SIX_CITY_GALLERY_COMPLETE')
