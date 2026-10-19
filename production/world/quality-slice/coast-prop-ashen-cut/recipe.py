"""Immutable-source replacement: cut the third road notch and close its new faces.

The existing bank is an open terrain surface, not a closed manifold. New cut
faces are closed down to its existing minimum Y=-40; no global watertight claim.
"""
from pathlib import Path
import copy,hashlib,json,math,collections
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/coast-prop-ashen-cut'
SOURCE=ROOT/'assets/production/world-slice/coast-prop-composition/scenery.mesh.json'
SOURCE_SHA='8743e160609a44e48b80e81b9ff0fe21b043bfb7e69fa216f2d164149c7f6760'
TARGET='coast_headland_banks__bounded_003'
# X636 overlaps the previously cleared city envelope (ending at X640).
# X918 is four studs beyond east landing. Z gives four studs around pad union.
RECT=(636.,918.,1489.,1523.)
FLOOR=-40.
def sha(b):return hashlib.sha256(b).hexdigest()
def record_sha(d):return sha(json.dumps(d,separators=(',',':'),sort_keys=True).encode())
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def normal(t):return cross([t[1][i]-t[0][i] for i in range(3)],[t[2][i]-t[0][i] for i in range(3)])
def area(t):return math.sqrt(sum(x*x for x in normal(t)))/2
def clip(poly,axis,bound,sign):
 out=[]
 for a,b in zip(poly,poly[1:]+poly[:1]):
  da=(a[axis]-bound)*sign;db=(b[axis]-bound)*sign
  if da>=0:out.append(a)
  if (da>=0)!=(db>=0):out.append([a[k]+da/(da-db)*(b[k]-a[k]) for k in range(3)])
 return out
def subtract(poly):
 rest=poly;outside=[]
 for axis,bound,sign in [(0,RECT[0],1),(0,RECT[1],-1),(2,RECT[2],1),(2,RECT[3],-1)]:
  piece=clip(rest,axis,bound,-sign)
  if len(piece)>2:outside.append(piece)
  rest=clip(rest,axis,bound,sign)
  if len(rest)<3:break
 return outside
def main():
 raw=SOURCE.read_bytes();assert sha(raw)==SOURCE_SHA
 data=json.loads(raw);before=copy.deepcopy(data);m=next(m for m in data['meshes'] if m['id']==TARGET);old=copy.deepcopy(m)
 vertices=[];triangles=[];facecolors=[];mapping=[];removed=[]
 def add(tri,color,source_face=None,cap=None):
  if area(tri)<1e-9:return
  start=len(vertices)+1;vertices.extend(tri);triangles.append([start,start+1,start+2]);facecolors.append(color)
  mapping.append(dict(outputFace=len(triangles),sourceFace=source_face,capSegment=cap))
 for fi,(face,color) in enumerate(zip(old['triangles'],old['faceColors']),1):
  tri=[old['vertices'][i-1] for i in face];inside=tri
  for axis,bound,sign in [(0,RECT[0],1),(0,RECT[1],-1),(2,RECT[2],1),(2,RECT[3],-1)]:inside=clip(inside,axis,bound,sign)
  cut_area=sum(area([inside[0],inside[i],inside[i+1]]) for i in range(1,len(inside)-1)) if inside else 0
  # Keep every nonintersecting source triangle literally, including triangulation.
  if cut_area<1e-9:
   add(tri,color,fi);continue
  removed.append(dict(sourceFace=fi,removedArea=cut_area,intersection=inside))
  for poly in subtract(tri):
   for i in range(1,len(poly)-1):add([poly[0],poly[i],poly[i+1]],color,fi)
 retained_count=len(triangles)
 # Select horizontal-extent edges on new notch planes. Vertical wall cuts have
 # no horizontal extent and are closed by adjoining new panels, not doubled.
 selected=[]
 for axis,bound,other,lo,hi,sign in [(0,RECT[0],2,RECT[2],RECT[3],1),(0,RECT[1],2,RECT[2],RECT[3],-1),(2,RECT[2],0,RECT[0],RECT[1],1),(2,RECT[3],0,RECT[0],RECT[1],-1)]:
  edges=[]
  for face in triangles:
   tri=[vertices[i-1] for i in face]
   for a,b in zip(tri,tri[1:]+tri[:1]):
    if abs(a[axis]-bound)<1e-6 and abs(b[axis]-bound)<1e-6 and abs(a[other]-b[other])>1e-7 and lo-1e-6<=(a[other]+b[other])/2<=hi+1e-6:edges.append((a,b))
  # Split collinear T-junctions before cancelling paired internal edges.
  split=collections.defaultdict(list)
  for a,b in edges:
   cuts=[0.,1.];v=[b[i]-a[i] for i in range(3)];vv=sum(x*x for x in v)
   for aa,bb in edges:
    for p in (aa,bb):
     t=sum((p[i]-a[i])*v[i] for i in range(3))/vv
     if 1e-8<t<1-1e-8 and sum((a[i]+t*v[i]-p[i])**2 for i in range(3))<1e-12:cuts.append(t)
   cuts=sorted(set(round(t,12) for t in cuts))
   for t0,t1 in zip(cuts,cuts[1:]):
    aa=[a[i]+v[i]*t0 for i in range(3)];bb=[a[i]+v[i]*t1 for i in range(3)]
    key=tuple(sorted(tuple(round(x,6) for x in p) for p in (aa,bb)));split[key].append((aa,bb))
  for uses in split.values():
   if len(uses)==1:
    a,b=uses[0]
    if max(a[1],b[1])>FLOOR+1e-7:selected.append(dict(a=a,b=b,axis=axis,bound=bound,inwardSign=sign))
 # Existing cool quarry-rock palette: original geometry/material lineage.
 palette=[[.28,.32,.33],[.40,.44,.44],[.46,.49,.47],[.37,.42,.43],[.50,.52,.48],[.43,.47,.47]]
 color_start=len(m['colors']);m['colors'].extend(palette)
 for index,s in enumerate(selected):
  a,b=s['a'],s['b'];poly=[a,b,[b[0],FLOOR,b[2]],[a[0],FLOOR,a[2]]];s['outputFaces']=[]
  for band,(low,high) in enumerate(zip([-40,0,12,26,42,60],[0,12,26,42,60,100])):
   p=clip(clip(poly,1,low,1),1,high,-1)
   for i in range(1,len(p)-1):
    tri=[p[0],p[i],p[i+1]]
    if normal(tri)[s['axis']]*s['inwardSign']<0:tri=[tri[0],tri[2],tri[1]]
    prior=len(triangles);add(tri,color_start+band+1,cap=index)
    if len(triangles)>prior:s['outputFaces'].append(len(triangles))
 m.update(vertices=vertices,triangles=triangles,faceColors=facecolors,bounds={'min':[min(v[k] for v in vertices) for k in range(3)],'max':[max(v[k] for v in vertices) for k in range(3)]})
 assert before['placements']==data['placements']
 unchanged={a['id']:record_sha(a) for a,b in zip(before['meshes'],data['meshes']) if a['id']!=TARGET and a==b}
 assert len(unchanged)==len(data['meshes'])-1
 OUT.mkdir(parents=True,exist_ok=True);payload=(json.dumps(data,separators=(',',':'))+'\n').encode();(OUT/'scenery.mesh.json').write_bytes(payload)
 evidence=dict(status='FILE_GENERATED_NOT_STUDIO_TESTED',sourceSha256=SOURCE_SHA,packetSha256=sha(payload),changedMeshIds=[TARGET],subtractXZ=RECT,capFloorY=FLOOR,capSegments=selected,faceMap=mapping,removedFaces=removed,retainedTriangleCount=retained_count,newTriangleCount=len(triangles),oldTriangleCount=len(old['triangles']),bounds=m['bounds'],unchangedMeshRecordHashes=unchanged,placementsRecordSha256=record_sha(data['placements']),placementsUnchanged=len(data['placements']),closureScope='New notch vertical faces only, down to existing bank minimum Y=-40. Original packet is open terrain, not globally watertight.',clearance='Z1493..1519 lane/pad union plus 4stud shoulders; X636 overlaps prior city clearance through X640. Native collision authority unchanged.')
 removed_points=[p for face in removed for p in face['intersection']]
 evidence['actualRemovedBounds']={'min':[min(p[k] for p in removed_points) for k in range(3)],'max':[max(p[k] for p in removed_points) for k in range(3)]}
 (HERE/'recipe-evidence.json').write_text(json.dumps(evidence,indent=2)+'\n',encoding='utf-8')
 provenance=dict(origin='Original Guildborne existing bank cut and quarry strata closure; all other reviewed packet geometry retained',source=SOURCE.relative_to(ROOT).as_posix(),sourceSha256=SOURCE_SHA,sourceProvenance='assets/production/world-slice/coast-prop-composition/provenance.json',recipe=Path(__file__).relative_to(ROOT).as_posix(),packetSha256=sha(payload),runtimeAssetIds=None,studioTested=False,downloads=False,spending=False,license='Retains source original Guildborne and reviewed CC0 provenance; new cut/caps original procedural geometry',replacementRequired=True,doNotLayerWithSource=True)
 (OUT/'provenance.json').write_text(json.dumps(provenance,indent=2)+'\n',encoding='utf-8')
 assert SOURCE.read_bytes()==raw
 print(json.dumps({k:v for k,v in evidence.items() if k not in ('capSegments','faceMap','removedFaces','unchangedMeshRecordHashes')}))
if __name__=='__main__':main()
