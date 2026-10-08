"""Clean GLB and FBX imports compared with authored geometry, not importer helpers."""
import bpy,json,sys,argparse
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('--city',default='Crownford');parser.add_argument('--set',choices=['services','institutions'],default='services');args=parser.parse_args(sys.argv[sys.argv.index('--')+1:]if '--'in sys.argv else[])
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01'/f'{args.city.lower()}-{args.set}-v1';expected=json.loads((O/'export-geometry.json').read_text());report=[]
for kind,source in expected.items():
 for ext in ['glb','fbx']:
  bpy.ops.wm.read_factory_settings(use_empty=True)
  if ext=='glb':bpy.ops.import_scene.gltf(filepath=str(O/(kind+'.glb')))
  else:bpy.ops.import_scene.fbx(filepath=str(O/(kind+'.fbx')))
  objects={o.name:o for o in bpy.data.objects if o.type=='MESH'};assert objects.keys()==source.keys(),(kind,ext,len(objects),len(source))
  error=0;triangles=0
  for name,o in objects.items():
   points=[o.matrix_world@v.co for v in o.data.vertices];ref=source[name]
   for label,op in [('min',min),('max',max)]:
    for i in range(3):error=max(error,abs(op(p[i]for p in points)-ref[label][i]))
   n=sum(len(p.vertices)-2 for p in o.data.polygons);assert n==ref['triangles'],name;triangles+=n
   assert bool(o.get('Collision'))==ref['collision'],name
  assert error<.0001,(kind,ext,error)
  report.append(dict(building=kind,format=ext,meshObjects=len(objects),triangles=triangles,maxBoundsError=error,collisionMetadataPreserved=True,status='PASS'))
(O/'roundtrip-report.json').write_text(json.dumps(report,indent=2)+'\n');print('CROWNFORD_ROUNDTRIP',json.dumps(report))
