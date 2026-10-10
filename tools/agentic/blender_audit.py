"""Read-only Blender body audit. Run with --disable-autoexec and --python-exit-code 2."""
import argparse
import json
from pathlib import Path
import sys


def main():
    import bpy
    import bmesh
    p=argparse.ArgumentParser()
    p.add_argument('--collection',required=True)
    p.add_argument('--report',required=True,type=Path)
    a=p.parse_args(sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else [])
    names=['Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand','RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot','RightUpperLeg','RightLowerLeg','RightFoot']
    collection=bpy.data.collections.get(a.collection)
    if not collection: raise ValueError('Body collection not found')
    body={o.name:o for o in collection.all_objects if o.type=='MESH' and o.name.endswith('_Geo')}
    expected={n+'_Geo' for n in names}
    errors=[]
    if set(body)!=expected: errors.append('Expected exactly the 15 named core _Geo body meshes; accessories belong outside this body collection')
    report=[]
    deps=bpy.context.evaluated_depsgraph_get()
    for name,obj in sorted(body.items()):
        evaluated=obj.evaluated_get(deps)
        mesh=evaluated.to_mesh()
        bm=bmesh.new()
        try:
            mesh.calc_loop_triangles()
            bm.from_mesh(mesh)
            boundary=sum(not e.is_manifold for e in bm.edges)
            if boundary: errors.append(name+': open/non-manifold body segment')
            if not mesh.uv_layers: errors.append(name+': no UV layer')
            unweighted=sum(not any(g.weight>0 for g in v.groups) for v in obj.data.vertices)
            max_influences=max((sum(g.weight>0 for g in v.groups) for v in obj.data.vertices),default=0)
            armatures=[m.object for m in obj.modifiers if m.type=='ARMATURE' and m.object]
            if not armatures: errors.append(name+': missing armature modifier (rig inspection required)')
            if unweighted: errors.append(name+': unweighted vertices')
            if max_influences>4: errors.append(name+': exceeds project four-influence skinning profile')
            report.append({'name':name,'triangles':len(mesh.loop_triangles),'nonManifoldEdges':boundary,'unweightedVertices':unweighted,'maxInfluences':max_influences,'materials':len(mesh.materials)})
        finally:
            bm.free();evaluated.to_mesh_clear()
    result={'schemaVersion':1,'blenderVersion':bpy.app.version_string,'source':bpy.data.filepath,'status':'FAIL' if errors else 'LOCAL_GEOMETRY_CHECKS_PASS','parts':report,'errors':errors,'pending':['joint placement','weight deformation','cage UV/topology correspondence','modesty coverage','Studio import','clothing fit per preset','actual animation playback','mobile device performance'],'studioTested':False}
    a.report.parent.mkdir(parents=True,exist_ok=True)
    a.report.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    if errors: raise RuntimeError('Body audit failed; see report')


if __name__=='__main__': main()
