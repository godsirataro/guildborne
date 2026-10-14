"""Original Human Standard/Heavy source candidates; never uploads or supplies cage/fit acceptance.

Run reviewed local Blender with --background --disable-autoexec --python-exit-code 2.
No external scripts, assets, fonts, textures or providers are used. Only this script's
scoped source/export paths are written; existing files are refused by default.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

import bpy
import bmesh
from mathutils import Vector, Matrix

ROOT = Path(__file__).resolve().parents[1]
NAMES = ["Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"]
PARENTS = {"LowerTorso": "HumanoidRootPart", "UpperTorso": "LowerTorso", "Head": "UpperTorso"}
for side in ("Left", "Right"):
    PARENTS.update({side+"UpperArm": "UpperTorso", side+"LowerArm": side+"UpperArm", side+"Hand": side+"LowerArm", side+"UpperLeg": "LowerTorso", side+"LowerLeg": side+"UpperLeg", side+"Foot": side+"LowerLeg"})
ATTACHMENTS = {"HairAttachment": ("Head", (0, 0, 5.14)), "HatAttachment": ("Head", (0, 0, 5.14)), "FaceFrontAttachment": ("Head", (0, -.47, 4.7)), "BodyFrontAttachment": ("UpperTorso", (0, -.42, 3.65)), "BodyBackAttachment": ("UpperTorso", (0, .42, 3.65)), "WaistCenterAttachment": ("LowerTorso", (0, 0, 2.5)), "LeftGripAttachment": ("LeftHand", (-1.33, -.03, 2.46)), "RightGripAttachment": ("RightHand", (1.33, -.03, 2.46)), "LeftFootAttachment": ("LeftFoot", (-.46, -.12, .15)), "RightFootAttachment": ("RightFoot", (.46, -.12, .15))}
parser = argparse.ArgumentParser()
parser.add_argument("--allow-rebuild", action="store_true", help="Deliberate replacement of this script's exact candidate paths only")
parser.add_argument("--inspect-source", type=Path, help="Read-only source inspection, renders and deformation measurements; no .blend saves")
parser.add_argument("--inspect-export", type=Path, help="Read-only reimport of this script's body FBX/GLB to verify exported meshes and rig")
parser.add_argument("--export-local-preview", action="store_true", help="Extract exact source geometry to deterministic Luau for isolated no-upload Studio mesh preview")
parser.add_argument("--export-local-rig", action="store_true", help="Read-only extraction of source bone bind frames, attachments and weights for isolated articulated preview")
args = parser.parse_args(sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else [])


def path(relative: str) -> Path:
    target = (ROOT / relative).resolve()
    if ROOT not in target.parents:
        raise ValueError("Output outside repository")
    target.parent.mkdir(parents=True, exist_ok=True)
    return target


def guard(target: Path):
    if target.exists() and not args.allow_rebuild:
        raise FileExistsError(f"Existing source/export protected: {target}")


def material(name: str, rgb: tuple[int, int, int]):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    def linear(value):
        value /= 255
        return value / 12.92 if value <= .04045 else ((value+.055)/1.055)**2.4
    mat.diffuse_color = (*map(linear, rgb), 1)
    mat.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = mat.diffuse_color
    mat.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = .8
    return mat


def move_to(obj, collection):
    for old in list(obj.users_collection):
        old.objects.unlink(obj)
    collection.objects.link(obj)


def rings(name, levels, mat, collection, count=8):
    """Closed elliptical faceted rings, independently selectable and capped."""
    vertices, faces = [], []
    for cx, cy, z, rx, ry in levels:
        for index in range(count):
            angle = 2*math.pi*index/count + math.pi/8
            vertices.append((cx+math.cos(angle)*rx, cy+math.sin(angle)*ry, z))
    for level in range(len(levels)-1):
        for index in range(count):
            a=level*count+index; b=level*count+(index+1)%count
            faces.append((a,b,b+count,a+count))
    faces.append(tuple(reversed(range(count))))
    faces.append(tuple((len(levels)-1)*count+i for i in range(count)))
    mesh=bpy.data.meshes.new(name+"Mesh");mesh.from_pydata(vertices,[],faces);mesh.update()
    obj=bpy.data.objects.new(name,mesh);collection.objects.link(obj);obj.data.materials.append(mat)
    bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=bm.faces);bm.to_mesh(mesh);bm.free()
    bpy.ops.object.select_all(action="DESELECT");obj.select_set(True);bpy.context.view_layer.objects.active=obj
    bpy.ops.object.mode_set(mode="EDIT");bpy.ops.mesh.select_all(action="SELECT");bpy.ops.uv.smart_project(island_margin=.02);bpy.ops.object.mode_set(mode="OBJECT")
    return obj


def bind(obj, bone, rig):
    group=obj.vertex_groups.new(name=bone);group.add(list(range(len(obj.data.vertices))),1,"REPLACE")
    modifier=obj.modifiers.new("R15Skin", "ARMATURE");modifier.object=rig;obj.parent=rig


def create_rig(width):
    bpy.ops.object.armature_add(enter_editmode=True)
    rig=bpy.context.object;rig.name="Guildborne_Human_R15_Candidate"
    rig.data.edit_bones.remove(rig.data.edit_bones[0])
    definitions={"HumanoidRootPart": ((0,0,2.5),(0,0,2.75)), "LowerTorso": ((0,0,2.48),(0,0,3.05)), "UpperTorso": ((0,0,3.05),(0,0,4.14)), "Head": ((0,0,4.14),(0,0,5.15))}
    for side,sign in (("Left",-1),("Right",1)):
        definitions.update({side+"UpperArm": ((sign*1.05*width,0,4.04),(sign*1.22*width,0,3.28)), side+"LowerArm": ((sign*1.22*width,0,3.28),(sign*1.32*width,0,2.65)), side+"Hand": ((sign*1.32*width,0,2.65),(sign*1.34*width,0,2.23)), side+"UpperLeg": ((sign*.46*width,0,2.49),(sign*.46*width,0,1.48)), side+"LowerLeg": ((sign*.46*width,0,1.48),(sign*.46*width,0,.43)), side+"Foot": ((sign*.46*width,0,.43),(sign*.46*width,-.44,.18))})
    for name in ["HumanoidRootPart"]+NAMES:
        bone=rig.data.edit_bones.new(name);bone.head=definitions[name][0];bone.tail=definitions[name][1]
    for name,parent in PARENTS.items():
        rig.data.edit_bones[name].parent=rig.data.edit_bones[parent]
    bpy.ops.object.mode_set(mode="OBJECT")
    return rig


def inventory(objects):
    result=[];deps=bpy.context.evaluated_depsgraph_get()
    for obj in objects:
        if obj.type!="MESH": continue
        evaluated=obj.evaluated_get(deps);mesh=evaluated.to_mesh();mesh.calc_loop_triangles()
        bm=bmesh.new();bm.from_mesh(mesh)
        bad_edges=sum(not edge.is_manifold for edge in bm.edges)
        normalization_errors=sum(abs(sum(g.weight for g in v.groups)-1)>1e-5 for v in obj.data.vertices)
        result.append({"name": obj.name, "vertices": len(mesh.vertices), "triangles": len(mesh.loop_triangles), "nonManifoldEdges": bad_edges, "uvLayers": len(mesh.uv_layers), "weightNormalizationErrors": normalization_errors, "maxInfluences": max((len(v.groups) for v in obj.data.vertices),default=0)})
        bm.free();evaluated.to_mesh_clear()
        assert bad_edges==0, obj.name+" not watertight"
        assert normalization_errors==0, obj.name+" invalid weights"
    return result


def export(objects, asset_id, category, rig, attachments):
    source=path(f"assets/{category}/source/{asset_id}.blend")
    fbx=path(f"assets/{category}/export/{asset_id}.fbx")
    glb=path(f"assets/{category}/export/{asset_id}.glb")
    for target in (source,fbx,glb): guard(target)
    selected=set(objects+[rig]+attachments)
    # Source preserves only this asset plus the shared rig/attachments; no downloaded blend code.
    for collection in bpy.data.collections:
        collection.hide_viewport=False
    bpy.ops.object.select_all(action="DESELECT")
    for obj in selected: obj.select_set(True)
    bpy.context.view_layer.objects.active=rig
    bpy.ops.export_scene.fbx(filepath=str(fbx),use_selection=True,object_types={"MESH","ARMATURE","EMPTY"},add_leaf_bones=False,bake_anim=False,axis_forward="-Z",axis_up="Y",apply_unit_scale=True,use_mesh_modifiers=True)
    bpy.ops.export_scene.gltf(filepath=str(glb),use_selection=True,export_format="GLB",export_animations=False,export_skins=True,export_yup=True)
    bpy.context.preferences.filepaths.save_version=0
    # The editable scene keeps body + outfit context for fit review. Asset collection identity is stored explicitly.
    bpy.context.scene["ActiveAssetId"]=asset_id
    bpy.context.scene["CageStatus"]="UNAVAILABLE_NO_ROBLOX_REFERENCE_TOPOLOGY_VALIDATION"
    bpy.ops.wm.save_as_mainfile(filepath=str(source))
    files=[]
    for target in (source,fbx,glb):
        files.append({"path": target.relative_to(ROOT).as_posix(), "bytes": target.stat().st_size, "sha256": hashlib.sha256(target.read_bytes()).hexdigest()})
    return {"assetId":asset_id,"status":"EXPORTED","robloxAssetId":None,"files":files,"meshes":inventory(objects),"cages":"UNAVAILABLE","studioImported":False,"studioTested":False,"fitStatus":"SOURCE_CANDIDATE_UNTESTED","humanArtApproval":"PENDING"}


def join_candidate(objects, name, collection):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects: obj.select_set(True)
    bpy.context.view_layer.objects.active=objects[0];bpy.ops.object.join()
    obj=bpy.context.object;obj.name=name;move_to(obj,collection);return obj


def clone_garment(body, names, collection, material_value, growth, asset_id, rig):
    objects=[]
    for name in names:
        source=body[name]
        duplicate=source.copy();duplicate.data=source.data.copy();collection.objects.link(duplicate)
        duplicate.name=asset_id+"_"+name
        duplicate.data.materials.clear();duplicate.data.materials.append(material_value)
        xs=[v.co.x for v in duplicate.data.vertices];ys=[v.co.y for v in duplicate.data.vertices];zs=[v.co.z for v in duplicate.data.vertices]
        center=Vector(((max(xs)+min(xs))/2,(max(ys)+min(ys))/2,(max(zs)+min(zs))/2))
        # Fit-specific rigid-bound shell; NOT a fake layered cage or universal fit.
        for vertex in duplicate.data.vertices:
            offset=vertex.co-center
            vertex.co=center+Vector((offset.x*(1+growth),offset.y*(1+growth),offset.z*(1+growth*.35)))
        duplicate["Technology"]="SKINNED_PRESET_SPECIFIC_FALLBACK_CANDIDATE"
        duplicate["Cages"]="UNAVAILABLE"
        objects.append(duplicate)
    return join_candidate(objects,asset_id+"_Geo",collection)


def build(preset):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene=bpy.context.scene;scene.unit_settings.system="NONE";scene.unit_settings.scale_length=1;scene.render.fps=30
    scene["CoordinateContract"]="Blender Z-up, forward -Y; FBX export forward -Z/up Y. Roblox 3D Importer conversion requires observed Studio verification."
    scene["Modesty"]="Opaque upper torso + pelvis + upper thighs are base material; normal tunic/trousers removable."
    body_collection=bpy.data.collections.new("Body");scene.collection.children.link(body_collection)
    clothes_collection=bpy.data.collections.new("ClothingCandidates");scene.collection.children.link(clothes_collection)
    accessories_collection=bpy.data.collections.new("RigidAccessories");scene.collection.children.link(accessories_collection)
    width=1.17 if preset=="HEAVY" else 1;depth=1.2 if preset=="HEAVY" else 1
    mats={"skin": material("SkinNeutralTintable",(198,141,96)), "modesty": material("OpaqueBaseCovering",(76,66,58)), "tunic": material("TravelerLinen",(203,185,153)), "trousers": material("TravelerLeather",(73,57,44)), "robe": material("MageCloth",(60,56,85)), "hair": material("HairDarkBrown",(66,43,31)), "hat": material("WizardHat",(43,43,60)), "eye": material("EyesUntinted",(28,25,23))}
    rig=create_rig(width)
    body={}
    def segment(name,levels,mat):
        obj=rings(name+"_Geo",[(x*width,y,z,rx*width,ry*depth) for x,y,z,rx,ry in levels],mats[mat],body_collection)
        bind(obj,name,rig);obj["CoreBodyPart"]=True;obj["TintableSkin"]=mat=="skin";body[name]=obj;return obj
    # Closed octagonal cross-sections form natural tapered anatomy rather than merged block limbs.
    segment("LowerTorso",[(0,0,2.42,.64,.37),(0,0,2.52,.76,.41),(0,0,2.85,.65,.39),(0,0,3.04,.62,.35)],"modesty")
    segment("UpperTorso",[(0,0,3.04,.62,.35),(0,0,3.35,.71,.4),(0,0,3.82,.89,.43),(0,0,4.02,.92,.37),(0,0,4.14,.39,.29)],"modesty")
    # Face silhouette includes jaw, cheek and forehead rings; eyes remain a separate removable detail.
    head=rings("Head_Geo",[(0,0,4.14,.3,.27),(0,-.015,4.24,.43,.36),(0,-.02,4.52,.53,.44),(0,-.035,4.76,.55,.465),(0,.005,5.04,.5,.43),(0,.01,5.16,.36,.34)],mats["skin"],body_collection)
    bind(head,"Head",rig);head["CoreBodyPart"]=True;head["TintableSkin"]=True;body["Head"]=head
    for side,sign in (("Left",-1),("Right",1)):
        segment(side+"UpperArm",[(sign*1.21,0,3.29,.245,.26),(sign*1.17,0,3.57,.31,.31),(sign*1.06,0,3.95,.34,.33),(sign*1.05,0,4.04,.29,.28)],"skin")
        segment(side+"LowerArm",[(sign*1.32,0,2.65,.19,.21),(sign*1.3,0,2.93,.24,.255),(sign*1.23,0,3.19,.27,.27),(sign*1.22,0,3.29,.23,.25)],"skin")
        segment(side+"Hand",[(sign*1.35,-.025,2.22,.19,.15),(sign*1.345,-.025,2.38,.245,.19),(sign*1.32,0,2.64,.185,.19)],"skin")
        segment(side+"UpperLeg",[(sign*.46,0,1.49,.275,.285),(sign*.46,0,1.78,.33,.34),(sign*.46,0,2.2,.38,.38),(sign*.46,0,2.44,.34,.36)],"modesty")
        segment(side+"LowerLeg",[(sign*.46,0,.44,.195,.21),(sign*.46,.01,.8,.265,.28),(sign*.46,0,1.18,.295,.29),(sign*.46,0,1.48,.255,.27)],"skin")
        segment(side+"Foot",[(sign*.46,-.17,.04,.27,.48),(sign*.46,-.16,.2,.285,.48),(sign*.46,-.025,.43,.205,.29)],"skin")
    attachments=[]
    for name,(bone_name,position) in ATTACHMENTS.items():
        obj=bpy.data.objects.new(name,None);scene.collection.objects.link(obj);obj.empty_display_type="PLAIN_AXES";obj.empty_display_size=.1
        obj.location=(position[0]*width,position[1],position[2]);obj.parent=rig;obj["RuntimeTarget"]=bone_name;attachments.append(obj)
    assert set(body)==set(NAMES)
    tunic=clone_garment(body,["UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm"],clothes_collection,mats["tunic"],.045,"CLO_TUNIC_TRAVELER_01",rig)
    trousers=clone_garment(body,["LowerTorso","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg"],clothes_collection,mats["trousers"],.07,"CLO_TROUSERS_TRAVELER_01",rig)
    robe=clone_garment(body,["UpperTorso","LowerTorso","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg"],clothes_collection,mats["robe"],.13,"CLO_ROBE_WIZARD_01",rig)
    hair=rings("ACC_HAIR_HUMAN_01_Geo",[(0,.03,4.91,.57,.48),(0,.04,5.13,.57,.46),(0,.04,5.33,.44,.38),(0,.02,5.39,.22,.24)],mats["hair"],accessories_collection)
    bind(hair,"Head",rig);hair["AttachmentName"]="HairAttachment"
    brim=rings("WizardHatBrim",[(0,0,5.31,.91,.78),(0,0,5.39,.91,.78)],mats["hat"],accessories_collection)
    crown=rings("WizardHatCrown",[(0,0,5.37,.48,.43),(0,.015,5.82,.36,.34),(.1,.04,6.15,.23,.24),(.14,.03,6.4,.03,.035)],mats["hat"],accessories_collection)
    bind(brim,"Head",rig);bind(crown,"Head",rig);hat=join_candidate([brim,crown],"CLO_HAT_WIZARD_01_Geo",accessories_collection);hat["AttachmentName"]="HatAttachment"
    # Export exactly the body meshes independently; outfit/rig candidates stay outside Body collection.
    records=[export(list(body.values()),f"CHR_BDY_HUMAN_{preset}_V01","characters",rig,attachments)]
    if preset=="STANDARD":
        for asset,obj,category in (("CLO_TUNIC_TRAVELER_01",tunic,"clothing"),("CLO_TROUSERS_TRAVELER_01",trousers,"clothing"),("CLO_ROBE_WIZARD_01",robe,"clothing"),("ACC_HAIR_HUMAN_01",hair,"accessories"),("CLO_HAT_WIZARD_01",hat,"clothing")):
            records.append(export([obj],asset,category,rig,attachments))
    for record in records:
        record["authoredPreset"]=f"HUMAN_{preset}"
        record["rigBones"]=[bone.name for bone in rig.data.bones]
        record["attachments"]=[obj.name for obj in attachments]
    return records


def inspect_source(source):
    source=source.resolve()
    allowed=(ROOT/"assets/characters/source").resolve()
    if source.parent!=allowed or source.name not in ("CHR_BDY_HUMAN_STANDARD_V01.blend","CHR_BDY_HUMAN_HEAVY_V01.blend"):
        raise ValueError("Inspection source outside this script's exact authored body candidates")
    before_hash=hashlib.sha256(source.read_bytes()).hexdigest()
    bpy.ops.wm.open_mainfile(filepath=str(source),use_scripts=False)
    scene=bpy.context.scene
    rig=bpy.data.objects["Guildborne_Human_R15_Candidate"]
    core=[bpy.data.objects[name+"_Geo"] for name in NAMES]
    metrics=inventory(core)
    # A CPU-measured deformation sweep is useful numeric evidence but not visual fit approval.
    bends={"LeftUpperArm": (0,0,.6),"LeftLowerArm": (0,-1.05,0),"RightUpperArm": (0,0,-.6),"RightLowerArm": (0,1.05,0),"LeftUpperLeg": (.6,0,0),"LeftLowerLeg": (-1.1,0,0),"RightUpperLeg": (-.4,0,0),"RightLowerLeg": (-.85,0,0)}
    sweep=[]
    deps=bpy.context.evaluated_depsgraph_get()
    original={obj.name:[vertex.co.copy() for vertex in obj.evaluated_get(deps).data.vertices] for obj in core}
    for name,rotation in bends.items():
        rig.pose.bones[name].rotation_mode="XYZ";rig.pose.bones[name].rotation_euler=rotation
    bpy.context.view_layer.update();deps=bpy.context.evaluated_depsgraph_get()
    for obj in core:
        evaluated=obj.evaluated_get(deps);mesh=evaluated.to_mesh()
        values=[(vertex.co-original[obj.name][index]).length for index,vertex in enumerate(mesh.vertices)]
        sweep.append({"name":obj.name,"maxVertexDisplacement":max(values),"allFinite":all(math.isfinite(value) for value in values)})
        assert all(math.isfinite(value) for value in values)
        evaluated.to_mesh_clear()
    for bone in rig.pose.bones:bone.rotation_euler=(0,0,0)
    bpy.context.view_layer.update()
    # Matte neutral reference sheet; no source/external art is composited or copied.
    for obj in scene.objects:
        obj.hide_render=obj.type in ("ARMATURE","EMPTY") or (obj.type=="MESH" and obj not in core and obj.name not in ("CLO_TUNIC_TRAVELER_01_Geo","CLO_TROUSERS_TRAVELER_01_Geo","ACC_HAIR_HUMAN_01_Geo"))
    bpy.ops.mesh.primitive_plane_add(size=200,location=(0,0,-.025));floor=bpy.context.object;floor.name="InspectionFloor"
    floor.data.materials.append(material("InspectionParchment",(209,199,179)))
    scene.world=bpy.data.worlds.new("InspectionWorld");scene.world.use_nodes=True
    scene.world.node_tree.nodes["Background"].inputs[0].default_value=(.34,.34,.34,1)
    for location,power,size in (((-5,-8,11),1400,7),((5,-2,8),900,5),((0,5,9),1600,5)):
        bpy.ops.object.light_add(type="AREA",location=location);light=bpy.context.object;light.data.energy=power;light.data.size=size
        light.rotation_euler=(Vector((0,0,3))-light.location).to_track_quat("-Z","Y").to_euler()
    bpy.ops.object.camera_add(location=(0,-12,3));camera=bpy.context.object;scene.camera=camera;camera.data.type="ORTHO";camera.data.ortho_scale=6.7
    scene.render.engine="BLENDER_EEVEE";scene.render.resolution_x=900;scene.render.resolution_y=1100;scene.render.resolution_percentage=100
    scene.render.image_settings.file_format="PNG";scene.view_settings.view_transform="Standard"
    images=[]
    for view,position in (("front",(0,-12,2.85)),("side",(12,0,2.85)),("back",(0,12,2.85))):
        camera.location=position;camera.rotation_euler=(Vector((0,0,2.65))-camera.location).to_track_quat("-Z","Y").to_euler()
        target=path(f"assets/characters/export/previews/{source.stem}_{view}.png");guard(target);scene.render.filepath=str(target);bpy.ops.render.render(write_still=True)
        images.append({"path":target.relative_to(ROOT).as_posix(),"sha256":hashlib.sha256(target.read_bytes()).hexdigest()})
    for obj in scene.objects:
        if obj.type=="MESH" and obj not in core and obj!=floor: obj.hide_render=True
    for obj in core:
        obj.modifiers.clear();obj.parent=None
        center=sum((vertex.co for vertex in obj.data.vertices),Vector())/len(obj.data.vertices)
        obj.location=Vector((center.x*.42,0,(center.z-2.65)*.17))
    camera.location=(8,-13,7);camera.rotation_euler=(Vector((0,0,2.65))-camera.location).to_track_quat("-Z","Y").to_euler();camera.data.ortho_scale=8.4
    target=path(f"assets/characters/export/previews/{source.stem}_exploded.png");guard(target);scene.render.filepath=str(target);bpy.ops.render.render(write_still=True)
    images.append({"path":target.relative_to(ROOT).as_posix(),"sha256":hashlib.sha256(target.read_bytes()).hexdigest()})
    after_hash=hashlib.sha256(source.read_bytes()).hexdigest();assert before_hash==after_hash,"Read-only inspection changed .blend"
    report={"source":source.relative_to(ROOT).as_posix(),"sourceSha256":before_hash,"sourceUnchanged":True,"blenderVersion":bpy.app.version_string,"geometry":metrics,"deformationSweep":sweep,"renderedImages":images,"claims":"LOCAL_GEOMETRY_AND_NUMERIC_DEFORMATION_ONLY","pending":["visual seam fit approval","garment cage/topology","Roblox import and motion","human art approval"],"studioTested":False}
    target=path(f"assets/characters/export/previews/{source.stem}_inspection.json");guard(target);target.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print("MODULAR_HUMAN_READ_ONLY_INSPECTION",json.dumps({"source":source.name,"images":len(images),"coreMeshes":len(core),"sourceUnchanged":True}))


def inspect_export(export_path):
    export_path=export_path.resolve()
    allowed=(ROOT/"assets/characters/export").resolve()
    if export_path.parent!=allowed or export_path.stem not in ("CHR_BDY_HUMAN_STANDARD_V01","CHR_BDY_HUMAN_HEAVY_V01") or export_path.suffix not in (".fbx",".glb"):
        raise ValueError("Export inspection outside this script's exact body files")
    file_hash=hashlib.sha256(export_path.read_bytes()).hexdigest()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if export_path.suffix==".fbx": bpy.ops.import_scene.fbx(filepath=str(export_path))
    else: bpy.ops.import_scene.gltf(filepath=str(export_path))
    rigs=[obj for obj in bpy.context.scene.objects if obj.type=="ARMATURE"]
    # Blender's glTF importer creates a display Icosphere as pose_bone.custom_shape.
    # This helper is not serialized source geometry. Exclude only actual bone shape references.
    custom_shapes={bone.custom_shape for rig in rigs for bone in rig.pose.bones if bone.custom_shape}
    meshes=[obj for obj in bpy.context.scene.objects if obj.type=="MESH" and obj not in custom_shapes]
    actual={obj.name for obj in meshes};expected={name+"_Geo" for name in NAMES}
    errors=[]
    if actual!=expected:errors.append("EXPORTED_CORE_NAMES_CHANGED")
    if len(rigs)!=1:errors.append("EXPORTED_ARMATURE_COUNT_CHANGED")
    elif {bone.name for bone in rigs[0].data.bones}!=set(NAMES+["HumanoidRootPart"]):errors.append("EXPORTED_BONE_NAMES_CHANGED")
    entries=[]
    for obj in meshes:
        obj.data.calc_loop_triangles()
        vertices=[obj.matrix_world@vertex.co for vertex in obj.data.vertices]
        finite=all(all(math.isfinite(component) for component in vertex) for vertex in vertices)
        if not finite:errors.append(obj.name+":NONFINITE_GEOMETRY")
        if not obj.data.uv_layers:errors.append(obj.name+":NO_EXPORTED_UV")
        unweighted=sum(not any(group.weight>0 for group in vertex.groups) for vertex in obj.data.vertices)
        if unweighted:errors.append(obj.name+":UNWEIGHTED_EXPORT")
        entries.append({"name":obj.name,"triangles":len(obj.data.loop_triangles),"vertices":len(vertices),"uvLayers":len(obj.data.uv_layers),"unweightedVertices":unweighted,"allWorldVerticesFinite":finite})
    if sum(entry["triangles"] for entry in entries)!=884:errors.append("EXPORTED_TRIANGLE_COUNT_CHANGED")
    assert file_hash==hashlib.sha256(export_path.read_bytes()).hexdigest()
    report={"file":export_path.relative_to(ROOT).as_posix(),"sha256":file_hash,"exportUnchanged":True,"blenderVersion":bpy.app.version_string,"status":"FAIL" if errors else "LOCAL_EXPORT_REIMPORT_CHECKS_PASS","meshes":entries,"importerBoneDisplayHelpers":[obj.name for obj in custom_shapes],"bones":[bone.name for rig in rigs for bone in rig.data.bones],"errors":errors,"studioImported":False,"pending":["actual Roblox importer axis/origin/joint interpretation","cages","deformation/fit approval"]}
    target=path(f"assets/characters/export/previews/{export_path.stem}_{export_path.suffix[1:]}_reimport.json");guard(target);target.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    if errors:raise RuntimeError("Export roundtrip failed: "+",".join(errors))
    print("MODULAR_HUMAN_EXPORT_REIMPORT",json.dumps({"file":export_path.name,"meshes":len(meshes),"triangles":sum(entry["triangles"] for entry in entries),"rigs":len(rigs),"status":report["status"]}))


def export_local_preview():
    """Extract the reviewed source, not a second approximate generator. No source files are saved."""
    source_report=json.loads((ROOT/"production/character-import/geometry-report.json").read_text(encoding="utf-8"))
    assets={}
    for record in source_report["assets"]:
        asset_id=record["assetId"]
        source=next(file for file in record["files"] if file["path"].endswith(".blend"))
        source_path=(ROOT/source["path"]).resolve()
        if ROOT not in source_path.parents or hashlib.sha256(source_path.read_bytes()).hexdigest()!=source["sha256"]:
            raise ValueError("Source hash changed: "+asset_id)
        bpy.ops.wm.open_mainfile(filepath=str(source_path),use_scripts=False)
        deps=bpy.context.evaluated_depsgraph_get()
        extracted=[]
        for inventory_row in record["meshes"]:
            obj=bpy.data.objects[inventory_row["name"]]
            evaluated=obj.evaluated_get(deps);mesh=evaluated.to_mesh();mesh.calc_loop_triangles()
            normal_transform=obj.matrix_world.to_3x3().inverted().transposed()
            def coordinate(value):return [round(value.x,9),round(value.z,9),round(-value.y,9)]
            vertices=[coordinate(obj.matrix_world@vertex.co) for vertex in mesh.vertices]
            triangles=[];uvs=[];normals=[];face_materials=[]
            for triangle in mesh.loop_triangles:
                triangles.append([index+1 for index in triangle.vertices])
                uvs.append([[round(mesh.uv_layers.active.data[index].uv.x,9),round(mesh.uv_layers.active.data[index].uv.y,9)] for index in triangle.loops])
                normals.append(coordinate((normal_transform@triangle.normal).normalized()))
                face_materials.append(triangle.material_index+1)
            def srgb(value):return round((12.92*value if value<=.0031308 else 1.055*value**(1/2.4)-.055)*255)
            materials=[{"name":mat.name,"colorRGB":[srgb(component) for component in mat.diffuse_color[:3]],"alpha":round(mat.diffuse_color[3],9)} for mat in mesh.materials]
            is_body=asset_id.startswith("CHR_BDY_")
            # Blender garment copies may retain custom Body flags; shared catalog category owns identity.
            extracted.append({"name":obj.name,"runtimePart":obj.name.removesuffix("_Geo"),"vertices":vertices,"triangles":triangles,"faceUVs":uvs,"faceNormals":normals,"faceMaterials":face_materials,"materials":materials,"skinTintable":is_body and bool(obj.get("TintableSkin",False)),"coreBodyPart":is_body and obj.name in {name+"_Geo" for name in NAMES}})
            assert len(triangles)==inventory_row["triangles"]
            evaluated.to_mesh_clear()
        assert hashlib.sha256(source_path.read_bytes()).hexdigest()==source["sha256"],"Extraction changed source"
        assets[asset_id]={"sourcePath":source["path"],"sourceSha256":source["sha256"],"authoredPreset":record["authoredPreset"],"meshes":extracted,"triangleCount":sum(len(mesh["triangles"]) for mesh in extracted),"status":"LOCAL_SOURCE_GEOMETRY_PREVIEW_ONLY","robloxAssetId":None}
    def luau(value):
        if value is None:return "nil"
        if value is True:return "true"
        if value is False:return "false"
        if isinstance(value,str):return json.dumps(value,ensure_ascii=True)
        if isinstance(value,(int,float)):return json.dumps(value,allow_nan=False)
        if isinstance(value,list):return "{"+",".join(luau(item) for item in value)+"}"
        return "{"+",".join("["+luau(key)+"]="+luau(value[key]) for key in sorted(value))+"}"
    content=["--!strict","-- GENERATED from exact reviewed .blend files by tools/blender_modular_human.py.","-- Local no-upload static geometry only. Not registered, rigged, caged or production imported.","-- Coordinates: Blender (x,y,z) -> Roblox (x,z,-y); triangle winding preserved.","local Geometry: any = {",'\tVersion=1, CoordinateMapping="x,z,-y", Status="LOCAL_SOURCE_GEOMETRY_PREVIEW_ONLY",',"\tAssets={"]
    for asset_id in sorted(assets):content.append("\t\t["+luau(asset_id)+"]="+luau(assets[asset_id])+",")
    content.extend(["\t},","}","local function freeze(value: any)","\tfor _,child in pairs(value) do if type(child)==\"table\" then freeze(child) end end","\ttable.freeze(value)","end","freeze(Geometry)","return Geometry",""])
    target=path("src/shared/Presentation/ModularAppearance/GeneratedGeometry.luau");guard(target);target.write_text("\n".join(content),encoding="utf-8",newline="\n")
    print("MODULAR_HUMAN_LOCAL_GEOMETRY_EXTRACTED",json.dumps({"assets":len(assets),"triangles":{asset_id:asset["triangleCount"] for asset_id,asset in assets.items()},"output":target.relative_to(ROOT).as_posix(),"sha256":hashlib.sha256(target.read_bytes()).hexdigest(),"sourceFilesUnchanged":True}))


def export_local_rig():
    source_report=json.loads((ROOT/"production/character-import/geometry-report.json").read_text(encoding="utf-8"))
    coordinate=Matrix(((1,0,0,0),(0,0,1,0),(0,-1,0,0),(0,0,0,1)))
    assets={}
    def vector(value):return [round(value.x,9),round(value.z,9),round(-value.y,9)]
    def frame(value):
        transformed=coordinate@value@coordinate.inverted()
        return [round(transformed[index][3],9) for index in range(3)]+[round(transformed[row][column],9) for row in range(3) for column in range(3)]
    for record in source_report["assets"]:
        asset_id=record["assetId"]
        source=next(file for file in record["files"] if file["path"].endswith(".blend"))
        source_path=(ROOT/source["path"]).resolve()
        if ROOT not in source_path.parents or hashlib.sha256(source_path.read_bytes()).hexdigest()!=source["sha256"]:
            raise ValueError("Source hash changed: "+asset_id)
        bpy.ops.wm.open_mainfile(filepath=str(source_path),use_scripts=False)
        rig=bpy.data.objects["Guildborne_Human_R15_Candidate"]
        bones=[]
        def bone_record(bone):
            bones.append({"name":bone.name,"parent":bone.parent.name if bone.parent else "","head":vector(rig.matrix_world@bone.head_local),"tail":vector(rig.matrix_world@bone.tail_local),"bindFrame":frame(rig.matrix_world@bone.matrix_local)})
            for child in sorted(bone.children,key=lambda item:item.name):bone_record(child)
        for bone in sorted((bone for bone in rig.data.bones if not bone.parent),key=lambda item:item.name):bone_record(bone)
        assert {bone["name"] for bone in bones}==set(NAMES+["HumanoidRootPart"])
        attachments=[]
        for name in sorted(record["attachments"]):
            obj=bpy.data.objects[name]
            attachments.append({"name":name,"target":obj["RuntimeTarget"],"bindFrame":frame(obj.matrix_world)})
        meshes=[]
        for inventory_row in record["meshes"]:
            obj=bpy.data.objects[inventory_row["name"]]
            weights=[]
            for vertex in obj.data.vertices:
                memberships=[{"bone":obj.vertex_groups[group.group].name,"weight":round(group.weight,9)} for group in vertex.groups if group.weight>0]
                assert memberships and abs(sum(group["weight"] for group in memberships)-1)<1e-5
                weights.append(memberships)
            meshes.append({"name":obj.name,"vertexCount":len(obj.data.vertices),"vertexWeights":weights})
        assets[asset_id]={"sourcePath":source["path"],"sourceSha256":source["sha256"],"authoredPreset":record["authoredPreset"],"bones":bones,"attachments":attachments,"meshes":meshes,"status":"LOCAL_SOURCE_RIG_DATA_ONLY"}
        assert hashlib.sha256(source_path.read_bytes()).hexdigest()==source["sha256"],"Rig extraction changed source"
    def luau(value):
        if value is None:return "nil"
        if value is True:return "true"
        if value is False:return "false"
        if isinstance(value,str):return json.dumps(value,ensure_ascii=True)
        if isinstance(value,(int,float)):return json.dumps(value,allow_nan=False)
        if isinstance(value,list):return "{"+",".join(luau(item) for item in value)+"}"
        return "{"+",".join("["+luau(key)+"]="+luau(value[key]) for key in sorted(value))+"}"
    content=["--!strict","-- GENERATED from actual reviewed .blend source armatures, attachments and vertex groups.","-- Source coordinate conversion x,z,-y; bind frames are Q * BlenderFrame * Q^-1.","-- No Studio animation, garment fit, cage, upload or production import acceptance is implied.","local RigData: any = {Version=1,Assets={"]
    for asset_id in sorted(assets):content.append("\t["+luau(asset_id)+"]="+luau(assets[asset_id])+",")
    content.extend(["}}","local function freeze(value: any)","\tfor _,child in pairs(value) do if type(child)==\"table\" then freeze(child) end end","\ttable.freeze(value)","end","freeze(RigData)","return RigData",""])
    target=path("src/shared/Presentation/ModularAppearance/GeneratedRig.luau");guard(target);target.write_text("\n".join(content),encoding="utf-8",newline="\n")
    print("MODULAR_HUMAN_LOCAL_RIG_EXTRACTED",json.dumps({"assets":len(assets),"bodyBoneCounts":{asset_id:len(asset["bones"]) for asset_id,asset in assets.items() if asset_id.startswith("CHR_BDY_")},"attachmentCounts":{asset_id:len(asset["attachments"]) for asset_id,asset in assets.items() if asset_id.startswith("CHR_BDY_")},"output":target.relative_to(ROOT).as_posix(),"sha256":hashlib.sha256(target.read_bytes()).hexdigest(),"sourceFilesUnchanged":True}))


if args.export_local_rig:
    export_local_rig()
elif args.export_local_preview:
    export_local_preview()
elif args.inspect_export:
    inspect_export(args.inspect_export)
elif args.inspect_source:
    inspect_source(args.inspect_source)
else:
    records=build("STANDARD")+build("HEAVY")
    report={"schemaVersion":1,"generator":"tools/blender_modular_human.py","origin":"ORIGINAL_LOCAL_PROCEDURAL_CANDIDATE_FROM_USER_ART_DIRECTION","blenderVersion":bpy.app.version_string,"assets":records,"sourceGeometryChecks":"15 separate closed weighted UV meshes per body; numeric metrics are evaluated in Blender","coordinateContract":"Z-up/-Y forward source; FBX -Z forward/Y up conversion; actual Roblox import orientation PENDING","cages":"UNAVAILABLE_NO_ROBLOX_REFERENCE_TOPOLOGY_VALIDATION","clothingTechnology":"PRESET_SPECIFIC_SKINNED_FALLBACK_CANDIDATE_NOT_VALIDATED_LAYERED_CLOTHING","studioImported":False,"studioTested":False,"robloxAssetIds":None,"pending":["body outer cages","garment inner/outer cages and UV correspondence","Studio MeshPart import and axes","R15 joint and attachment import","deformation and seam/clipping poses","Standard/Heavy garment fit","rigid accessory fitting","human art review","device performance"]}
    target=path("production/character-import/geometry-report.json");guard(target);target.write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
    print("MODULAR_HUMAN_CANDIDATE_EXPORTS",json.dumps({"assets":len(records),"version":bpy.app.version_string,"coreTriangles":{row["assetId"]:sum(part["triangles"] for part in row["meshes"]) for row in records if row["assetId"].startswith("CHR_BDY")},"cages":"UNAVAILABLE","studioTested":False}))
