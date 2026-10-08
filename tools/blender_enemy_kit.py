"""Twelve original custom NPC rigs, 48 baked clips, rest meshes and portraits."""
from pathlib import Path
import bpy,json,math,sys,argparse
from mathutils import Vector,Matrix
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser();parser.add_argument('--kit',default='assets/uat01/enemy-kit');parser.add_argument('--gallery',default='Guildborne_Enemy_Gallery');parser.add_argument('--friendly',action='store_true')
options=parser.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
OUT=ROOT/options.kit
data=json.loads((OUT/'kit.json').read_text(encoding='utf-8'));records=[]
convert=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def render_setup():
    scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=16;scene.cycles.use_denoising=True
    scene.render.resolution_x=512;scene.render.resolution_y=512;scene.render.resolution_percentage=100
    scene.render.film_transparent=True;scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA';scene.view_settings.view_transform='Standard'
    scene.world=bpy.data.worlds.new('EnemyStudio');scene.world.use_nodes=True;scene.world.node_tree.nodes['Background'].inputs[0].default_value=(.5,.5,.5,1);scene.world.node_tree.nodes['Background'].inputs[1].default_value=.8
    return scene
def light(pos,target,power,size):
    bpy.ops.object.light_add(type='AREA',location=pos);o=bpy.context.object;o.data.energy=power;o.data.size=size;o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()
for a in data['assets']:
    bpy.ops.wm.read_factory_settings(use_empty=True);scene=render_setup();scene.render.fps=30
    materials={}
    for name,rgb in data['palette'].items():
        def linear(v):
            v/=255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
        m=bpy.data.materials.new(name);m.use_nodes=True;m.diffuse_color=(*map(linear,rgb),1);shader=m.node_tree.nodes['Principled BSDF'];shader.inputs['Base Color'].default_value=m.diffuse_color;shader.inputs['Roughness'].default_value=.7;materials[name]=m
    bpy.ops.object.armature_add(enter_editmode=True);rig=bpy.context.object;rig.name=a['id']+'_Rig';rig.data.edit_bones.remove(rig.data.edit_bones[0]);bones={}
    for b in a['bones']:
        bone=rig.data.edit_bones.new(b['name']);bone.head=convert@Vector(b['head']);bone.tail=convert@Vector(b['tail'])
        if b['parent']:bone.parent=bones[b['parent']]
        bones[b['name']]=bone
    bpy.ops.object.mode_set(mode='OBJECT');parts=[]
    for p in a['parts']:
        bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.name=p['name'];o.location=convert@Vector(p['position']);o.scale=(p['size'][0],p['size'][2],p['size'][1])
        rx,ry,rz=map(math.radians,p['rotation']);rotation=Matrix.Rotation(rx,3,'X')@Matrix.Rotation(ry,3,'Y')@Matrix.Rotation(rz,3,'Z');o.rotation_euler=(convert@rotation@convert.inverted()).to_euler()
        bpy.ops.object.transform_apply(location=False,rotation=True,scale=True);o.data.materials.append(materials[p['color']]);o.vertex_groups.new(name=p['bone']).add(list(range(len(o.data.vertices))),1,'REPLACE');parts.append(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in parts:o.select_set(True)
    bpy.context.view_layer.objects.active=parts[0];bpy.ops.object.join();mesh=bpy.context.object;mesh.name=a['id']+'_Mesh';scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
    modifier=mesh.modifiers.new('OriginalSkin','ARMATURE');modifier.object=rig;mesh.parent=rig;mesh.data.calc_loop_triangles();triangles=len(mesh.data.loop_triangles)
    assert triangles<1000 and all(len(v.groups)==1 and abs(v.groups[0].weight-1)<1e-6 for v in mesh.data.vertices)
    def select():
        bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);mesh.select_set(True);bpy.context.view_layer.objects.active=rig
    def fbx(path,animated):
        select();bpy.ops.export_scene.fbx(filepath=str(path),use_selection=True,object_types={'MESH','ARMATURE'},add_leaf_bones=False,bake_anim=animated,bake_anim_use_all_actions=False,bake_anim_use_nla_strips=False,bake_anim_step=1,bake_anim_simplify_factor=0,axis_forward='-Z',axis_up='Y')
    fbx(OUT/(a['id']+'_Rest.fbx'),False);select();bpy.ops.export_scene.gltf(filepath=str(OUT/(a['id']+'_Rest.glb')),use_selection=True,export_format='GLB',export_animations=False)
    clips=[];actions={};quad=a['rigType']=='Quadruped'
    clip_specs=[('Idle',2,True),('Walk',1,True),('Greet',1.8,False),('Work',2,True)] if a.get('friendly',options.friendly) else [('Idle',2,True),('Walk',1,True),('Attack',1.2,False),('Hit',.5,False)]
    for name,seconds,loop in clip_specs:
        rig.animation_data_clear();frames=round(seconds*30)+1;scene.frame_start=1;scene.frame_end=frames
        for frame in range(1,frames+1):
            t=(frame-1)/(frames-1);phase=t*2*math.pi;lift=math.sin(math.pi*t)
            for p in rig.pose.bones:p.rotation_mode='XYZ';p.rotation_euler=(0,0,0);p.location=(0,0,0);p.scale=(1,1,1)
            main=rig.pose.bones['Body' if quad else 'UpperTorso']
            if name=='Idle':main.rotation_euler.x=.025*math.sin(phase);rig.pose.bones['Head'].rotation_euler.z=.035*math.sin(phase)
            elif name=='Walk':
                if quad:
                    for end in ('Front','Rear'):
                        for side,sign in [('Left',1),('Right',-1)]:
                            wave=math.sin(phase)*sign*(1 if end=='Front' else -1);rig.pose.bones[end+side+'UpperLeg'].rotation_euler.x=.5*wave;rig.pose.bones[end+side+'LowerLeg'].rotation_euler.x=max(0,-wave)*.4
                    rig.pose.bones['Tail'].rotation_euler.z=.18*math.sin(phase)
                else:
                    for side,sign in [('Left',1),('Right',-1)]:
                        wave=math.sin(phase)*sign;rig.pose.bones[side+'UpperLeg'].rotation_euler.x=.43*wave;rig.pose.bones[side+'LowerLeg'].rotation_euler.x=max(0,-wave)*.35;rig.pose.bones[side+'UpperArm'].rotation_euler.x=-.3*wave
            elif name=='Greet':
                rig.pose.bones['RightUpperArm'].rotation_euler.z=-1.4*lift
                rig.pose.bones['RightLowerArm'].rotation_euler.z=-.35*math.sin(phase*2)*lift
                rig.pose.bones['Head'].rotation_euler.x=.06*lift
            elif name=='Work':
                rig.pose.bones['RightUpperArm'].rotation_euler.x=-.55+.25*math.sin(phase)
                rig.pose.bones['RightLowerArm'].rotation_euler.x=-.4+.18*math.sin(phase)
                main.rotation_euler.x=.04*math.sin(phase)
            elif name=='Attack':
                if quad:rig.pose.bones['Head'].rotation_euler.x=.5*lift;main.rotation_euler.x=-.12*lift
                else:
                    both=a['role'] in ('Boss','Support','Spell','Ranged')
                    for side in (('Left','Right') if both else ('Right',)):
                        rig.pose.bones[side+'UpperArm'].rotation_euler.x=-1.25*lift;rig.pose.bones[side+'LowerArm'].rotation_euler.x=-.45*lift
                    main.rotation_euler.z=.2*math.sin(2*math.pi*t)
            else:main.rotation_euler.x=-.25*lift;rig.pose.bones['Head'].rotation_euler.x=-.12*lift
            for p in rig.pose.bones:
                for field in ('rotation_euler','location','scale'):p.keyframe_insert(data_path=field,frame=frame,group=p.name)
        action=rig.animation_data.action;action.name=a['id']+'_'+name;action.use_fake_user=True;actions[name]=action
        file=a['id']+'_'+name+'.fbx';fbx(OUT/file,True);clips.append({'name':name,'file':file,'frames':frames,'seconds':seconds,'loop':loop,'rootMotion':False,'robloxAnimationId':None})
    rig.animation_data.action=actions['Idle'];scene.frame_start=1;scene.frame_end=61;scene.frame_set(1)
    points=[mesh.matrix_world@Vector(v) for v in mesh.bound_box];center=sum(points,Vector())/8;radius=max((v-center).length for v in points)
    light((4,6,12),center,1800,8);light((-6,1,8),center,900,7)
    bpy.ops.object.camera_add();cam=bpy.context.object;cam.location=center+Vector((1.2,3,.7)).normalized()*20;cam.rotation_euler=(center-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=radius*2.35;scene.camera=cam
    scene.render.filepath=str(OUT/(a['id']+'.png'));bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/(a['id']+'.blend')));bpy.ops.render.render(write_still=True)
    records.append({'id':a['id'],'rigType':a['rigType'],'region':a['region'],'role':a['role'],'bones':len(rig.data.bones),'triangles':triangles,'vertices':len(mesh.data.vertices),'restFiles':[a['id']+'_Rest.fbx',a['id']+'_Rest.glb'],'clips':clips,'studioImported':False,'liveEncounterBound':False})
(OUT/'manifest.json').write_text(json.dumps({'schema':1,'fps':30,'assets':records},indent=2)+'\n',encoding='utf-8')
# Overview uses rest imports; each individual .blend keeps its editable rig/actions.
bpy.ops.wm.read_factory_settings(use_empty=True);scene=render_setup()
for i,a in enumerate(records):
    before=set(scene.objects);bpy.ops.import_scene.gltf(filepath=str(OUT/(a['id']+'_Rest.glb')));new=set(scene.objects)-before
    rig=next(o for o in new if o.type=='ARMATURE');shapes={p.custom_shape for p in rig.pose.bones if p.custom_shape};mesh=next(o for o in new if o.type=='MESH' and o not in shapes)
    columns=2 if options.friendly else (5 if len(records)>12 else 4)
    scale=(5.7 if a['role']=='Boss' else 4.4)/mesh.dimensions.z;rig.scale=(scale,scale,scale);rig.location=(((columns-1)/2-i%columns)*7,0,(2-i//columns)*7.4)
    bpy.ops.object.text_add(location=(rig.location.x+2.8,.3,rig.location.z-.65),rotation=(math.pi/2,0,math.pi));label=bpy.context.object;label.data.body=a['id'].replace('_',' ').upper();label.data.size=.22
    m=bpy.data.materials.new('Label');m.use_nodes=True;m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(.9,.8,.6,1);label.data.materials.append(m)
light((0,18,22),(0,0,9),7500,30)
bpy.ops.object.camera_add(location=(6,45,18));cam=bpy.context.object;cam.rotation_euler=(Vector((0,0,11.1 if options.friendly else 9))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=21 if options.friendly else (40 if len(records)>12 else 32);scene.camera=cam
scene.render.resolution_x=1600;scene.render.resolution_y=1400;scene.render.filepath=str(OUT/'preview.png');bpy.context.preferences.filepaths.save_version=0;bpy.ops.wm.save_as_mainfile(filepath=str(OUT/(options.gallery+'.blend')));bpy.ops.render.render(write_still=True)
print('ENEMY_RIG_KIT_COMPLETE',len(records),'rigs',sum(a['triangles'] for a in records),'triangles',sum(len(a['clips']) for a in records),'clips')
