"""Render fixed perspective comparisons from saved artifacts, without saving scenes.
Blender --background --disable-autoexec --python-exit-code 2 --python this_file.
These are source-art renders, not Roblox screenshots.
"""
from pathlib import Path
import bpy,json,hashlib,sys
from mathutils import Vector
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
VIEWS={'overview':((105,94,1545),(0,4,1410)),
       'arch':((40,22,1435),(0,7,1380))}
records=[]
if '--after-only' in sys.argv:
    records=[r for r in json.loads((HERE/'central-renders.json').read_text(encoding='utf-8'))['views'] if r['revision']=='before']
def point(v):return Vector((v[0],1410-v[2],v[1]-2))
for revision,source in [('before',HERE/'central-before.blend'),
                        ('after',ROOT/'assets/production/world-slice/woodland-threshold.blend')]:
    if revision=='before' and '--after-only' in sys.argv:continue
    bpy.ops.wm.open_mainfile(filepath=str(source),use_scripts=False)
    stage=bpy.data.collections['Preview_Only_Stage']
    # Normalize both previews to the same native base geometry/color.
    stream=bpy.data.objects.get('PREVIEW_ONLY_Stream')
    if stream:bpy.data.objects.remove(stream,do_unlink=True)
    boss=bpy.data.objects['PREVIEW_ONLY_BossCourt']
    boss.data.materials[0].node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(.1274,.0762,.0395,1)
    def cube(name,loc,size):
        if bpy.data.objects.get(name):return
        bpy.ops.mesh.primitive_cube_add(size=1,location=loc);obj=bpy.context.object;obj.name=name;obj.scale=size
        for coll in list(obj.users_collection):coll.objects.unlink(obj)
        stage.objects.link(obj)
        mat=bpy.data.materials.new(name);mat.use_nodes=True
        mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(.4564,.3185,.15,1)
        mat.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.9
        obj.data.materials.append(mat)
    for x in (-60,60):cube('PREVIEW_ONLY_Loop'+str(x),(x,-10,-1.95),(18,90,4))
    for z in (1450,1375):cube('PREVIEW_ONLY_Cross'+str(z),(0,1410-z,-1.94),(138,18,4))
    scene=bpy.context.scene;camera=scene.camera
    camera.data.type='PERSP';camera.data.lens=35;camera.data.clip_end=2000
    scene.render.resolution_x=1100;scene.render.resolution_y=800
    scene.render.resolution_percentage=100;scene.cycles.samples=24
    for label,(eye,target) in VIEWS.items():
        camera.location=point(eye);camera.rotation_euler=(point(target)-camera.location).to_track_quat('-Z','Y').to_euler()
        output=HERE/f'central-{label}-{revision}.png';scene.render.filepath=str(output)
        bpy.ops.render.render(write_still=True)
        records.append(dict(revision=revision,view=label,cameraWorld=eye,targetWorld=target,lensMm=35,
                            source=str(source.relative_to(ROOT)).replace('\\','/'),
                            sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                            image=output.name,sha256=hashlib.sha256(output.read_bytes()).hexdigest()))
(HERE/'central-renders.json').write_text(json.dumps(dict(status='BLENDER_COMPARISON_NOT_STUDIO',views=records),indent=2)+'\n',encoding='utf-8')
print('TERRAIN_COMPARISONS_COMPLETE',len(records),flush=True)
