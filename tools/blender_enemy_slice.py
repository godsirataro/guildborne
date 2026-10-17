"""Run with exclusive Blender lease: blender --background --factory-startup --disable-autoexec --python THIS.

Imports reviewed CC0 glTF only. Exports real weighted geometry and sampled source
actions for local Studio review; never uploads or assigns Roblox asset IDs.
"""
from pathlib import Path
import bpy, json, math, hashlib, sys
from mathutils import Matrix, Vector, Quaternion

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/production/enemy-slice'
C = Matrix(((1,0,0,0),(0,0,1,0),(0,-1,0,0),(0,0,0,1)))
CI = C.inverted()
FPS = 30
CLIPS = ('Idle', 'Walk', 'Run', 'Weapon', 'Punch', 'HitReact', 'Death')

def rounded(values):
    result = [round(float(v), 7) for v in values]
    assert all(math.isfinite(v) for v in result)
    return result

def cf(matrix, scale=1):
    m = C @ matrix @ CI
    return rounded([*(m.translation * scale), *[m[i][j] for i in range(3) for j in range(3)]])

def vector(v):
    return rounded((v.x, v.z, -v.y))

def select_action(rig, action):
    rig.animation_data_create()
    for track in rig.animation_data.nla_tracks:
        track.mute = True
    rig.animation_data.action = action
    if action.slots:
        rig.animation_data.action_slot = action.slots[0]

def aim(obj, point):
    obj.rotation_euler = (Vector(point)-obj.location).to_track_quat('-Z', 'Y').to_euler()

def correct_walk(rig, source):
    """Author only the right forearm seam on a copy; preserve the CC0 action."""
    select_action(rig, source)
    bone = rig.pose.bones['LowerArm.R']
    assert bone.rotation_mode == 'QUATERNION'
    samples = {}
    for frame in (0, 1, 23, 24):
        bpy.context.scene.frame_set(frame)
        samples[frame] = bone.rotation_quaternion.copy().normalized()
    start, end = samples[24], samples[0]
    # Spherical Bezier controls preserve the incoming/outgoing one-frame
    # angular tangents. Six intervals / three is the cubic control distance.
    def power(q, factor):
        q = q.normalized()
        if q.w < 0: q.negate()
        return Quaternion(q.axis, q.angle * factor)
    a = start @ power(samples[23].conjugated() @ start, 2)
    b = end @ power(end.conjugated() @ samples[1], -2)
    authored = source.copy()
    authored.name = 'Guildborne_Walk_ForearmLoop'
    authored.use_fake_user = True
    source.use_fake_user = True
    select_action(rig, authored)
    for frame in range(25, 31):
        t = (frame - 24) / 6
        p, q, r = start.slerp(a, t), a.slerp(b, t), b.slerp(end, t)
        rotation = p.slerp(q, t).slerp(q.slerp(r, t), t).normalized()
        bpy.context.scene.frame_set(frame)
        bone.rotation_quaternion = end if frame == 30 else rotation
        bone.keyframe_insert(data_path='rotation_quaternion', frame=frame, group=bone.name)
    # Source uses LINEAR channels; retain that sampling convention in the copy.
    channelbag = authored.layers[0].strips[0].channelbag(rig.animation_data.action_slot)
    for curve in channelbag.fcurves:
        if curve.data_path == 'pose.bones["LowerArm.R"].rotation_quaternion':
            for key in curve.keyframe_points: key.interpolation = 'LINEAR'
    return authored

def build(asset):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.context.scene.render.fps = FPS
    bpy.context.scene.render.fps_base = 1
    bpy.ops.import_scene.gltf(filepath=str(OUT / asset['sourceFile']))
    scene = bpy.context.scene
    scene.render.fps = FPS
    rigs = [o for o in scene.objects if o.type == 'ARMATURE']
    assert len(rigs) == 1
    rig = rigs[0]
    # glTF importer also creates unskinned custom bone-display shapes.
    meshes = [o for o in scene.objects if o.type == 'MESH' and
              any(m.type == 'ARMATURE' and m.object == rig for m in o.modifiers)]
    assert len(meshes) == 1
    bones = list(rig.data.bones)
    assert len(bones) == 43
    indices = {b.name:i+1 for i,b in enumerate(bones)}
    actions = {a.name:a for a in bpy.data.actions}
    assert all(name in actions for name in CLIPS), list(actions)
    source_walk = actions['Walk']
    actions['Walk'] = correct_walk(rig, actions['Walk'])
    select_action(rig, actions['Idle'])
    scene.frame_set(0)
    # Bind geometry is original topology, never an evaluated pose baked into rest.
    points = [o.matrix_world @ v.co for o in meshes for v in o.data.vertices]
    low = Vector(tuple(min(p[i] for p in points) for i in range(3)))
    high = Vector(tuple(max(p[i] for p in points) for i in range(3)))
    height = high.z-low.z
    assert height > 0.1
    target_height = 5 if asset['id'] == 'greenwood_scout' else 7
    scale = target_height / height
    shift = Vector((0,0,-low.z))
    def world(m):
        result = m.copy(); result.translation += shift
        return result
    bone_data = []
    for b in bones:
        bind = world(rig.matrix_world @ b.matrix_local)
        local = b.parent.matrix_local.inverted() @ b.matrix_local if b.parent else bind
        bone_data.append(dict(name=b.name,parent=indices[b.parent.name] if b.parent else 0,
                              bind=cf(bind,scale),localBind=cf(local,scale)))
    vertices, weights, triangles, uvs = [], [], [], []
    for obj in meshes:
        groups = {g.index:g.name for g in obj.vertex_groups}
        start = len(vertices)
        for vertex in obj.data.vertices:
            vertices.append(vector((obj.matrix_world @ vertex.co + shift)*scale))
            influences = [(indices[groups[g.group]],g.weight) for g in vertex.groups
                          if groups[g.group] in indices and g.weight > 0]
            assert influences and len(influences) <= 4, (obj.name,vertex.index,[(groups[g.group],g.weight) for g in vertex.groups],list(indices))
            total = sum(w for _,w in influences)
            assert abs(total-1) < .001
            weights.append([[i,round(w/total,8)] for i,w in influences])
        obj.data.calc_loop_triangles()
        uv = obj.data.uv_layers.active
        assert uv
        for tri in obj.data.loop_triangles:
            triangles.append([start+i+1 for i in tri.vertices])
            uvs.append([rounded(uv.data[i].uv) for i in tri.loops])
    assert len(triangles) == asset['triangles']
    clips = {}
    diagnostics = {}
    folder = OUT / 'review' / asset['id']; folder.mkdir(parents=True,exist_ok=True)
    for name in CLIPS:
        action = actions[name]
        select_action(rig, action)
        duration = next(c['seconds'] for c in asset['clips'] if c['name'] == name)
        assert abs(action.frame_range[0]) < .01 and abs(action.frame_range[1]-duration*FPS) < .01, (name, list(action.frame_range),duration)
        frames = []
        bounds = []
        for frame in range(round(duration*FPS)+1):
            source_transforms = []
            if name == 'Walk':
                # Keep untouched exported channels byte-identical. Recomputing
                # child-local matrices under the corrected parent introduces
                # sub-microstud inverse-matrix roundoff in finger descendants.
                select_action(rig, source_walk)
                scene.frame_set(frame); bpy.context.view_layer.update()
                for b in bones:
                    p = rig.pose.bones[b.name]
                    rest = b.parent.matrix_local.inverted() @ b.matrix_local if b.parent else world(rig.matrix_world @ b.matrix_local)
                    pose = rig.pose.bones[b.parent.name].matrix.inverted() @ p.matrix if b.parent else world(rig.matrix_world @ p.matrix)
                    source_transforms.append(cf(rest.inverted() @ pose, scale))
                select_action(rig, action)
            scene.frame_set(frame); bpy.context.view_layer.update()
            transforms = []
            for bone_index, b in enumerate(bones):
                p = rig.pose.bones[b.name]
                rest = b.parent.matrix_local.inverted() @ b.matrix_local if b.parent else world(rig.matrix_world @ b.matrix_local)
                pose = rig.pose.bones[b.parent.name].matrix.inverted() @ p.matrix if b.parent else world(rig.matrix_world @ p.matrix)
                value = cf(rest.inverted() @ pose,scale)
                if name == 'Walk':
                    original = source_transforms[bone_index]
                    # Do not hide a real unowned change behind canonicalization.
                    unchanged = 3 if b.name == 'LowerArm.R' and frame > 24 else 12
                    assert max(abs(value[i]-original[i]) for i in range(unchanged)) < .000002, (frame, b.name, 'unexpected unowned pose change')
                    value = original[:3] + value[3:] if b.name == 'LowerArm.R' and frame > 24 else original
                transforms.append(value)
            frames.append(transforms)
            if name == 'Walk' or frame in (0,round(duration*FPS/2),round(duration*FPS)):
                evaluated_points = []
                graph = bpy.context.evaluated_depsgraph_get()
                for obj in meshes:
                    evaluated = obj.evaluated_get(graph)
                    mesh = evaluated.to_mesh()
                    evaluated_points.extend((evaluated.matrix_world @ v.co + shift)*scale for v in mesh.vertices)
                    evaluated.to_mesh_clear()
                bounds.append({'frame':frame,'min':rounded(min(p[i] for p in evaluated_points) for i in range(3)),
                               'max':rounded(max(p[i] for p in evaluated_points) for i in range(3))})
        assert any(frames[i] != frames[0] for i in range(1,len(frames))), name
        clips[name] = {'fps':FPS,'seconds':duration,'looped':name in ('Idle','Walk','Run'),'frames':frames}
        diagnostics[name] = {'sampledFrames':len(frames),'evaluatedBoundsBlenderAxes':bounds}
    image = bpy.data.images.load(str(OUT/'source/Atlas_Monsters.png'),check_existing=True)
    width, height_px = image.size
    pixels = list(image.pixels)
    colors, face_colors, palette = [], [], {}
    for corners in uvs:
        u,v = (sum(c[i] for c in corners)/3 for i in (0,1))
        x,y = min(width-1,max(0,int(u*width))),min(height_px-1,max(0,int(v*height_px)))
        color = tuple(round(c,6) for c in pixels[(y*width+x)*4:(y*width+x)*4+3])
        if color not in palette:
            palette[color]=len(colors)+1; colors.append(color)
        face_colors.append(palette[color])
    result = {'schemaVersion':1,'id':asset['id'],'status':'BLENDER_EXPORTED_NOT_STUDIO_IMPORTED',
              'sourceSha256':asset['sha256'],'units':'stud','height':target_height,
              'coordinates':'Roblox X,Y-up,Z; triangle indices 1-based',
              'sourceForward':'+Z','recommendedRootYawDegrees':180,
              'bones':bone_data,'vertices':vertices,'weights':weights,'triangles':triangles,'cornerUV':uvs,
              'colors':colors,'faceColors':face_colors,'colorMethod':'Atlas sampled at each triangle UV centroid; texture UVs retained for full-fidelity import',
              'texture':'../../source/Atlas_Monsters.png','clips':clips,'runtimeAssetId':None,
              'contactMarkers':None}
    (folder/'weighted-mesh.json').write_text(json.dumps(result,separators=(',',':'))+'\n',encoding='utf-8')
    (folder/'inspection.json').write_text(json.dumps({'blender':bpy.app.version_string,'sourceBounds':{'min':list(low),'max':list(high)},'scaleToStud':scale,'actions':list(actions),'diagnostics':diagnostics},indent=2)+'\n',encoding='utf-8')
    # Render source mesh at its original scale with actual sampled action poses.
    scene.render.engine = 'CYCLES'; scene.cycles.samples = 24
    scene.render.resolution_x = 640; scene.render.resolution_y = 640
    scene.render.resolution_percentage = 100
    scene.world = bpy.data.worlds.new('EnemyReviewWorld'); scene.world.use_nodes = True
    scene.world.node_tree.nodes['Background'].inputs[0].default_value = (.09,.12,.16,1)
    scene.world.node_tree.nodes['Background'].inputs[1].default_value = .5
    # Fit the union of evaluated action bounds, including the fallen pose.
    review_low = Vector(tuple(min(b['min'][i] for d in diagnostics.values() for b in d['evaluatedBoundsBlenderAxes'])/scale-shift[i] for i in range(3)))
    review_high = Vector(tuple(max(b['max'][i] for d in diagnostics.values() for b in d['evaluatedBoundsBlenderAxes'])/scale-shift[i] for i in range(3)))
    center = (review_low+review_high)/2
    bpy.ops.object.camera_add(location=center+Vector((height*1.4,-height*2,height*.8)))
    camera=bpy.context.object; aim(camera,center); camera.data.type='ORTHO'; camera.data.ortho_scale=(review_high-review_low).length*1.12; scene.camera=camera
    for label,offset,power,size in [('Key',(-2,-3,4),500,3),('Rim',(2,2,3),700,2)]:
        bpy.ops.object.light_add(type='AREA',location=center+Vector(offset)*height)
        light=bpy.context.object; light.name=label; light.data.energy=power*height*height; light.data.shape='DISK'; light.data.size=size*height; aim(light,center)
    for name in (() if '--export-only' in sys.argv else ('Idle','Walk','Weapon','HitReact','Death')):
        select_action(rig,actions[name])
        for fraction in (0,.5,1):
            frame=round(clips[name]['seconds']*FPS*fraction)
            scene.frame_set(frame)
            scene.render.filepath=str(folder/f'{name}-{frame:03d}.png')
            bpy.ops.render.render(write_still=True)
    select_action(rig,actions['Idle']); scene.frame_set(0)
    bpy.context.preferences.filepaths.save_version = 0
    bpy.ops.wm.save_as_mainfile(filepath=str(folder/'source-review.blend'))
    hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(folder.iterdir()) if p.is_file() and p.name != 'hashes.json'}
    (folder/'hashes.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')
    print('ENEMY_BLENDER_EXPORTED',asset['id'],len(vertices),len(triangles),flush=True)

if __name__ == '__main__':
    manifest=json.loads((OUT/'intake.json').read_text(encoding='utf-8'))
    for asset in manifest['assets']:
        build(asset)
