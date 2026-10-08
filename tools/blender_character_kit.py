"""Original low-poly custom NPC rig and nine separate baked animation candidates.
Run with Blender --background --python tools/blender_character_kit.py.
Not a certified Roblox avatar: no face rig, cages or published animation IDs.
"""
from pathlib import Path
import bpy, json, math
from mathutils import Vector

OUT=Path(__file__).resolve().parents[1]/'assets/uat01/character-kit'
OUT.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;scene.render.fps=30
palette={'stone':(79,91,112),'steel':(135,155,174),'gold':(192,153,79),'cloth':(73,59,98),'skin':(159,177,176),'eye':(128,210,219)}
materials={}
for name,rgb in palette.items():
    m=bpy.data.materials.new(name);m.use_nodes=True
    def linear(v):
        v/=255
        return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
    m.diffuse_color=(*map(linear,rgb),1)
    m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=m.diffuse_color
    m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=.78
    materials[name]=m

bpy.ops.object.armature_add(enter_editmode=True)
rig=bpy.context.object;rig.name='Guildborne_Sentinel_Rig'
rig.data.edit_bones.remove(rig.data.edit_bones[0])
bones={}
def bone(name,head,tail,parent=None):
    b=rig.data.edit_bones.new(name);b.head=head;b.tail=tail
    if parent:b.parent=bones[parent]
    bones[name]=b
bone('Root',(0,0,0),(0,0,.5))
bone('LowerTorso',(0,0,2.15),(0,0,2.8),'Root')
bone('UpperTorso',(0,0,2.8),(0,0,3.75),'LowerTorso')
bone('Head',(0,0,3.75),(0,0,4.85),'UpperTorso')
for side,x in [('Left',-1),('Right',1)]:
    bone(side+'UpperArm',(x*1.05,0,3.65),(x*1.15,0,2.85),'UpperTorso')
    bone(side+'LowerArm',(x*1.15,0,2.85),(x*1.18,0,2.2),side+'UpperArm')
    bone(side+'Hand',(x*1.18,0,2.2),(x*1.18,0,1.9),side+'LowerArm')
    bone(side+'UpperLeg',(x*.48,0,2.15),(x*.48,0,1.15),'LowerTorso')
    bone(side+'LowerLeg',(x*.48,0,1.15),(x*.48,0,.35),side+'UpperLeg')
    bone(side+'Foot',(x*.48,0,.35),(x*.48,-.6,.2),side+'LowerLeg')
bpy.ops.object.mode_set(mode='OBJECT')
parts=[]
def box(name,location,size,color,bind):
    bpy.ops.mesh.primitive_cube_add(size=1,location=location)
    o=bpy.context.object;o.name=name;o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(materials[color])
    o.vertex_groups.new(name=bind).add(list(range(len(o.data.vertices))),1,'REPLACE');parts.append(o)
box('Waist',(0,0,2.45),(1.45,.78,.6),'cloth','LowerTorso')
box('Chest',(0,0,3.22),(1.7,.95,.85),'stone','UpperTorso')
box('Breastplate',(0,-.51,3.22),(1.25,.13,.65),'steel','UpperTorso')
box('Rune',(0,-.6,3.25),(.2,.08,.45),'gold','UpperTorso')
box('Belt',(0,0,2.35),(1.58,.86,.2),'gold','LowerTorso')
box('Head',(0,0,4.35),(1.32,1.12,1.1),'skin','Head')
box('Helm',(0,.06,4.86),(1.48,1.22,.24),'stone','Head')
box('Brow',(0,-.59,4.62),(1.48,.13,.18),'steel','Head')
for side,x in [('Left',-1),('Right',1)]:
    box(side+'Eye',(x*.3,-.576,4.42),(.2,.05,.14),'eye','Head')
    box(side+'UpperArm',(x*1.12,0,3.25),(.56,.64,.72),'stone',side+'UpperArm')
    box(side+'Shoulder',(x*1.12,0,3.57),(.85,.9,.35),'gold',side+'UpperArm')
    box(side+'LowerArm',(x*1.17,0,2.54),(.51,.59,.56),'steel',side+'LowerArm')
    box(side+'Hand',(x*1.18,0,2.02),(.49,.56,.35),'skin',side+'Hand')
    box(side+'UpperLeg',(x*.48,0,1.68),(.61,.68,.86),'cloth',side+'UpperLeg')
    box(side+'LowerLeg',(x*.48,0,.75),(.59,.66,.7),'steel',side+'LowerLeg')
    box(side+'Boot',(x*.48,-.18,.23),(.72,1,.42),'stone',side+'Foot')
bpy.ops.object.select_all(action='DESELECT')
for p in parts:p.select_set(True)
bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join()
mesh=bpy.context.object;mesh.name='Guildborne_Sentinel_Mesh'
bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
modifier=mesh.modifiers.new('SentinelSkin','ARMATURE');modifier.object=rig;mesh.parent=rig
mesh.data.calc_loop_triangles();triangles=len(mesh.data.loop_triangles)
assert triangles<1000
assert all(len(v.groups)==1 and abs(v.groups[0].weight-1)<1e-6 for v in mesh.data.vertices)
for p in rig.pose.bones:p.rotation_mode='XYZ'
def select_export():
    bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=rig
def export_fbx(name,animated):
    select_export()
    bpy.ops.export_scene.fbx(filepath=str(OUT/name),use_selection=True,object_types={'MESH','ARMATURE'},add_leaf_bones=False,
        bake_anim=animated,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,bake_anim_step=1,bake_anim_simplify_factor=0,
        axis_forward='-Z',axis_up='Y')
export_fbx('Guildborne_Sentinel_Rest.fbx',False)
select_export();bpy.ops.export_scene.gltf(filepath=str(OUT/'Guildborne_Sentinel_Rest.glb'),use_selection=True,export_format='GLB',export_animations=False)
clips=[('Idle',2,True),('Walk',1,True),('Run',.8,True),('Slash',1,False),('Cast',1.5,False),('Dodge',.8,False),('Hit',.5,False),('Down',1,False),('Recover',1.2,False)]
records=[];actions={}
for name,seconds,loop in clips:
    rig.animation_data_clear()
    frames=round(seconds*30)+1;scene.frame_start=1;scene.frame_end=frames
    for frame in range(1,frames+1):
        t=(frame-1)/(frames-1);phase=t*2*math.pi
        for p in rig.pose.bones:p.location=(0,0,0);p.rotation_euler=(0,0,0);p.scale=(1,1,1)
        def rx(b,v):rig.pose.bones[b].rotation_euler.x=v
        if name=='Idle':
            rig.pose.bones['UpperTorso'].scale.y=1+.012*math.sin(phase)
            rx('Head',.025*math.sin(phase))
        elif name in ('Walk','Run'):
            amp=.43 if name=='Walk' else .72
            for side,sign in [('Left',1),('Right',-1)]:
                wave=math.sin(phase)*sign
                rx(side+'UpperLeg',amp*wave);rx(side+'LowerLeg',max(0,-wave)*amp*.8)
                rx(side+'UpperArm',-amp*wave*.8);rx(side+'LowerArm',-.2 if name=='Walk' else -.7)
            rx('UpperTorso',.05 if name=='Walk' else .13)
        elif name=='Slash':
            swing=math.sin(math.pi*t)
            rx('RightUpperArm',-1.5*swing);rig.pose.bones['UpperTorso'].rotation_euler.z=.35*math.sin(2*math.pi*t)
            rx('RightLowerArm',-.55*swing)
        elif name=='Cast':
            lift=math.sin(math.pi*t)
            for side in ('Left','Right'):rx(side+'UpperArm',-1.3*lift);rx(side+'LowerArm',-.5*lift)
            rx('Head',-.15*lift)
        elif name=='Dodge':
            lean=math.sin(math.pi*t);rig.pose.bones['UpperTorso'].rotation_euler.z=.6*lean
            for side in ('Left','Right'):rx(side+'UpperLeg',-.5*lean);rx(side+'LowerLeg',.75*lean)
        elif name=='Hit':rx('UpperTorso',-.3*math.sin(math.pi*t));rx('Head',-.15*math.sin(math.pi*t))
        elif name in ('Down','Recover'):
            a=t if name=='Down' else 1-t;a=a*a*(3-2*a)
            rx('UpperTorso',.9*a);rx('Head',.35*a)
            for side in ('Left','Right'):rx(side+'UpperLeg',-.85*a);rx(side+'LowerLeg',1.45*a)
        for p in rig.pose.bones:
            for field in ('rotation_euler','location','scale'):p.keyframe_insert(data_path=field,frame=frame,group=p.name)
    action=rig.animation_data.action;action.name='GB_'+name;action.use_fake_user=True;actions[name]=action
    export_fbx('GB_'+name+'.fbx',True)
    records.append({'name':name,'file':'GB_'+name+'.fbx','frames':frames,'fps':30,'seconds':seconds,'loop':loop,'rootMotion':False,'robloxAnimationId':None,'status':'LOCAL_CANDIDATE'})

rig.animation_data_clear();rig.animation_data_create();rig.animation_data.action=actions['Idle']
scene.frame_start=1;scene.frame_end=61;scene.frame_set(1)
# Contact sheet of representative poses, evaluated into display meshes only.
for index,(name,_,_) in enumerate(clips):
    rig.animation_data.action=actions[name];scene.frame_set(round(records[index]['frames']*.5))
    deps=bpy.context.evaluated_depsgraph_get();evaluated=mesh.evaluated_get(deps)
    copy=bpy.data.objects.new('Preview_'+name,bpy.data.meshes.new_from_object(evaluated));scene.collection.objects.link(copy)
    copy.location=((index%5-2)*4.3,(index//5)*6,0)
    bpy.ops.object.text_add(location=(copy.location.x-1.2,copy.location.y-1.25,.03))
    label=bpy.context.object;label.name='Label_'+name;label.data.body=name.upper();label.data.size=.34;label.data.extrude=.002;label.data.materials.append(materials['gold'])
rig.animation_data.action=actions['Idle'];scene.frame_set(1)
rig.hide_render=True;mesh.hide_render=True
bpy.ops.mesh.primitive_plane_add(size=100,location=(0,0,-.03));bpy.context.object.data.materials.append(materials['cloth'])
for loc,power,size in [((0,-5,18),6500,14),((-12,6,12),4000,12)]:
    bpy.ops.object.light_add(type='AREA',location=loc);light=bpy.context.object;light.data.energy=power;light.data.shape='DISK';light.data.size=size
    light.rotation_euler=(Vector((0,3,2))-light.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(15,-22,20));cam=bpy.context.object
cam.rotation_euler=(Vector((0,3,2))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=26;scene.camera=cam
scene.world=bpy.data.worlds.new('StudioWorld');scene.world.color=(.18,.18,.18)
scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1600;scene.render.resolution_y=1000;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard';scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/'preview.png')
(OUT/'manifest.json').write_text(json.dumps({'rig':'Guildborne_Sentinel_Rig','bones':len(rig.data.bones),'triangles':triangles,'vertices':len(mesh.data.vertices),'weightsPerVertex':1,'clips':records,'studioImportVerified':False,'avatarCertified':False},indent=2)+'\n',encoding='utf-8')
bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'Guildborne_Sentinel_Animation_Kit.blend'))
bpy.ops.render.render(write_still=True)
print('CHARACTER_KIT_COMPLETE',triangles,'triangles',len(rig.data.bones),'bones',len(records),'clips')
