"""Render an original 4x4 shockwave texture with deterministic tile footprints.
The entire RGBA atlas is rendered directly from Blender geometry, not cropped from concept art.
"""
from pathlib import Path
import bpy,math,json,random
OUT=Path(__file__).resolve().parents[1]/'assets/uat01/vfx-native';OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene
def material(name,opacity):
    m=bpy.data.materials.new(name);m.use_nodes=True
    n=m.node_tree.nodes;n.clear();out=n.new('ShaderNodeOutputMaterial');mix=n.new('ShaderNodeMixShader')
    trans=n.new('ShaderNodeBsdfTransparent');em=n.new('ShaderNodeEmission');em.inputs['Color'].default_value=(1,1,1,1);em.inputs['Strength'].default_value=1
    mix.inputs[0].default_value=opacity
    m.node_tree.links.new(trans.outputs[0],mix.inputs[1]);m.node_tree.links.new(em.outputs[0],mix.inputs[2]);m.node_tree.links.new(mix.outputs[0],out.inputs[0])
    return m
records=[]
for index in range(16):
    t=index/15;cx=-9+(index%4)*6;cy=9-(index//4)*6
    radius=.18+1.95*(1-(1-t)**1.5);opacity=(1-t)**1.2
    # Final frame is deliberately almost transparent, retaining a measurable edge for validation.
    opacity=max(.01,opacity)
    ringmat=material(f'Frame{index:02}_Ring',opacity*.75)
    bpy.ops.mesh.primitive_torus_add(major_radius=radius,minor_radius=.095*(1-t)+.016,major_segments=96,minor_segments=8,location=(cx,cy,0))
    ring=bpy.context.object;ring.name=f'Frame{index:02}_Wave';ring.data.materials.append(ringmat)
    core=material(f'Frame{index:02}_Core',max(.005,(1-t)**2))
    # Eight tapered shards radiate out; fixed angular identity makes motion coherent.
    rng=random.Random(801)
    for shard in range(8):
        angle=shard*math.pi/4+rng.uniform(-.08,.08);r=.12+t*1.5
        length=(.48+.3*rng.random())*(1-.8*t);width=.07*(1-t)+.015
        direction=(math.cos(angle),math.sin(angle));cross=(-direction[1],direction[0])
        points=[(cx+direction[0]*(r+length),cy+direction[1]*(r+length),.16),
                (cx+direction[0]*r+cross[0]*width,cy+direction[1]*r+cross[1]*width,.16),
                (cx+direction[0]*(r-.15),cy+direction[1]*(r-.15),.16),
                (cx+direction[0]*r-cross[0]*width,cy+direction[1]*r-cross[1]*width,.16)]
        mesh=bpy.data.meshes.new(f'Shard{index:02}_{shard}');mesh.from_pydata(points,[],[(0,1,2,3)]);mesh.materials.append(core)
        obj=bpy.data.objects.new(mesh.name,mesh);scene.collection.objects.link(obj)
    records.append({'frame':index,'row':index//4,'column':index%4,'rectXYXY':[(index%4)*512,(index//4)*512,(index%4+1)*512,(index//4+1)*512],
        'radiusAuthoringUnits':radius,'ringOpacity':opacity*.75})
bpy.ops.object.camera_add(location=(0,0,30));cam=bpy.context.object;cam.rotation_euler=(0,0,0);cam.data.type='ORTHO';cam.data.ortho_scale=24;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.transparent_max_bounces=16
scene.render.film_transparent=True;scene.view_settings.view_transform='Standard';scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA'
scene.render.resolution_x=2048;scene.render.resolution_y=2048;scene.render.resolution_percentage=100
scene.render.filepath=str(OUT/'guildborne-shockwave-4x4-v1.png')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Shockwave_Flipbook.blend'))
bpy.ops.render.render(write_still=True)
(OUT/'layout.json').write_text(json.dumps({'generator':'original Blender procedural geometry','layout':'Grid4x4','frames':records,
    'size':[2048,2048],'tileSize':[512,512],'suggestedMode':'OneShot','suggestedLifetimeSeconds':.45,'robloxAssetId':None,'studioImportVerified':False},indent=2)+'\n',encoding='utf-8')
print('FLIPBOOK_RENDER_COMPLETE 16 frames,2048 square,RGBA')
