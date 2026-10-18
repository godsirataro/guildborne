"""Original polygon union / ear clipping; NumPy accelerates distance checks. Offline evidence only."""
from pathlib import Path
import json,math,hashlib,argparse
import numpy as np
HERE=Path(__file__).resolve().parent
SOURCE=HERE.parent/'settlement/after.json'
NAMES={'Settlement_'+n for n in ('ConnectedRoad','RoadJoin','TrainingClearing','TrainingEquipmentApron','CaravanClearing','WagonApron')}
def sub(a,b):return (a[0]-b[0],a[1]-b[1])
def cross(a,b):return a[0]*b[1]-a[1]*b[0]
def orient(a,b,c):return cross(sub(b,a),sub(c,a))
def area(p):return sum(cross(a,b) for a,b in zip(p,p[1:]+p[:1]))/2
def at(a,b,t):return (a[0]+(b[0]-a[0])*t,a[1]+(b[1]-a[1])*t)
def dist(a,b):return math.hypot(*sub(a,b))
def pointdist(p,a,b):
 d=sub(b,a);s=d[0]**2+d[1]**2
 t=max(0,min(1,((p[0]-a[0])*d[0]+(p[1]-a[1])*d[1])/s)) if s else 0
 return dist(p,at(a,b,t))
def inside(p,poly):
 for a,b in zip(poly,poly[1:]+poly[:1]):
  if pointdist(p,a,b)<1e-7:return True
 hit=False
 for a,b in zip(poly,poly[1:]+poly[:1]):
  if (a[1]>p[1])!=(b[1]>p[1]) and p[0]<(b[0]-a[0])*(p[1]-a[1])/(b[1]-a[1])+a[0]:hit=not hit
 return hit
def cuts(a,b,c,d):
 r=sub(b,a);s=sub(d,c);den=cross(r,s);q=sub(c,a)
 if abs(den)>1e-10:
  t=cross(q,s)/den;u=cross(q,r)/den
  return [max(0,min(1,t))] if -1e-9<=t<=1+1e-9 and -1e-9<=u<=1+1e-9 else []
 if abs(cross(q,r))>1e-8:return []
 rr=r[0]**2+r[1]**2
 return [max(0,min(1,t)) for p in (c,d) if -1e-9<=(t:=((p[0]-a[0])*r[0]+(p[1]-a[1])*r[1])/rr)<=1+1e-9]
def simple(p):
 n=len(p)
 for i in range(n):
  for j in range(i+1,n):
   if j==i+1 or (i==0 and j==n-1):continue
   if cuts(p[i],p[(i+1)%n],p[j],p[(j+1)%n]):return False
 return True
def triangulate(p):
 ids=list(range(len(p)));result=[]
 while len(ids)>3:
  for k,b in enumerate(ids):
   a=ids[k-1];c=ids[(k+1)%len(ids)]
   if orient(p[a],p[b],p[c])<=1e-9:continue
   if any(j not in (a,b,c) and all(v>=-1e-9 for v in (orient(p[a],p[b],p[j]),orient(p[b],p[c],p[j]),orient(p[c],p[a],p[j]))) for j in ids):continue
   result.append([a,b,c]);ids.pop(k);break
  else:raise AssertionError('Ear clipping stalled')
 result.append(ids);return result
def clip(poly,tri):
 for a,b in zip(tri,tri[1:]+tri[:1]):
  out=[]
  if not poly:return []
  for p,q in zip(poly,poly[1:]+poly[:1]):
   op=orient(a,b,p);oq=orient(a,b,q)
   if op>=-1e-10:out.append(p)
   if (op>0 and oq<0) or (op<0 and oq>0):out.append(at(p,q,op/(op-oq)))
  poly=out
 return poly
def projected(part):
 x,y,z=part['size'];r=part['rotation'];pos=part['position']
 if part['shape']=='Cylinder':local=[(0,math.cos(i*math.pi/8)*y/2,math.sin(i*math.pi/8)*z/2) for i in range(16)]
 else:local=[(-x/2,0,-z/2),(x/2,0,-z/2),(x/2,0,z/2),(-x/2,0,z/2)]
 p=[(pos[0]+r[0]*a+r[1]*b+r[2]*c,pos[2]+r[6]*a+r[7]*b+r[8]*c) for a,b,c in local]
 return p if area(p)>0 else p[::-1]
def union(polys):
 edges=[(a,b) for p in polys for a,b in zip(p,p[1:]+p[:1])];boundary=set()
 for a,b in edges:
  ts=sorted(set(round(t,10) for c,d in edges for t in cuts(a,b,c,d))|{0.,1.})
  for t,u in zip(ts,ts[1:]):
   if u-t<1e-9:continue
   aa=at(a,b,t);bb=at(a,b,u);mid=at(aa,bb,.5);dx,dz=sub(bb,aa);ln=math.hypot(dx,dz)
   left=(mid[0]-dz/ln*1e-5,mid[1]+dx/ln*1e-5);right=(mid[0]+dz/ln*1e-5,mid[1]-dx/ln*1e-5)
   if any(inside(left,p) for p in polys) and not any(inside(right,p) for p in polys):boundary.add((tuple(round(v,6) for v in aa),tuple(round(v,6) for v in bb)))
 links={}
 for a,b in boundary:
  assert a not in links,('Boundary branch',a)
  links[a]=b
 start=min(links);loop=[start];nxt=links[start]
 while nxt!=start:
  assert nxt not in loop and nxt in links,'Broken boundary';loop.append(nxt);nxt=links[nxt]
 assert len(loop)==len(links),'Multiple boundaries or holes'
 return loop
def sampled_boundary(poly,step=.5):
 return [at(a,b,i/n) for a,b in zip(poly,poly[1:]+poly[:1]) for n in [max(1,math.ceil(dist(a,b)/step))] for i in range(n)]
def boundary_error(points,poly):
 p=np.asarray(points);a=np.asarray(poly);d=np.roll(a,-1,axis=0)-a
 v=p[:,None,:]-a[None,:,:];t=np.clip(np.sum(v*d,axis=2)/np.sum(d*d,axis=1),0,1)
 return float(np.sqrt(np.sum((v-t[:,:,None]*d)**2,axis=2)).min(axis=1).max())
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--input',type=Path,default=HERE/'before.json' if (HERE/'before.json').exists() else SOURCE);args=parser.parse_args()
 raw=args.input.read_bytes();data=json.loads(raw);parts=[p for p in data['parts'] if p['name'] in NAMES];assert len(parts)==32
 polys=[projected(p) for p in parts];original=union(polys);assert area(original)>0 and simple(original)
 original_samples=sampled_boundary(original)
 protected=[(x,z) for x in (-12,0,12) for z in range(-5,217,2)]
 protected +=[(-12,216),(12,216)]
 protected +=[(p['position'][0],p['position'][2]) for p in data['parts'] if p.get('marker') and inside((p['position'][0],p['position'][2]),original)]
 protected +=[(-65,149),(-79,31),(-87,25),(80,86),(-65,53)]
 assert all(inside(p,original) for p in protected),'Initial footprint does not cover requested samples'
 poly=original[:]
 while len(poly)>43:
  candidates=sorted(range(len(poly)),key=lambda i:pointdist(poly[i],poly[i-1],poly[(i+1)%len(poly)]))
  accepted=False
  for i in candidates:
   for offset in (0,.25,.5,1,1.5):
    proposal=poly[:i]+poly[i+1:]
    if offset:
     left=(i-1)%len(proposal);right=i%len(proposal);dx,dz=sub(proposal[right],proposal[left]);length=math.hypot(dx,dz)
     for j in (left,right):proposal[j]=(proposal[j][0]+dz/length*offset,proposal[j][1]-dx/length*offset)
    if not simple(proposal) or not all(inside(p,proposal) for p in protected):continue
    if boundary_error(original_samples,proposal)>1.95:continue
    if boundary_error(sampled_boundary(proposal,1),original)>1.95:continue
    poly=proposal;accepted=True;break
   if accepted:break
  if not accepted:raise AssertionError(('Cannot meet vertex budget',len(poly)))
 tris=triangulate(poly);oldtris=triangulate(original)
 tt=[[poly[j] for j in t] for t in tris];ot=[[original[j] for j in t] for t in oldtris]
 overlap=sum(abs(area(q)) if len(q:=clip(a,b))>=3 else 0 for i,a in enumerate(tt) for b in tt[i+1:])
 intersection=sum(abs(area(q)) if len(q:=clip(a,b))>=3 else 0 for a in tt for b in ot)
 origarea=area(original);newarea=area(poly);trianglearea=sum(area(t) for t in tt)
 assert overlap<1e-6 and abs(trianglearea-newarea)<1e-6
 assert intersection<=min(origarea,newarea)+1e-5
 loss=origarea-intersection;gain=newarea-intersection
 assert loss/origarea<.03 and gain/origarea<.03
 forward=boundary_error(sampled_boundary(original,.1),poly);reverse=boundary_error(sampled_boundary(poly,.1),original)
 # Distance-to-boundary is 1-Lipschitz: .1-spaced samples bound unsampled
 # positions by reported maximum plus .05 stud.
 assert max(forward,reverse)+.05<=2
 lane=[(-12,-5),(12,-5),(12,216),(-12,216)]
 lanearea=sum(abs(area(q)) if len(q:=clip(t,lane))>=3 else 0 for t in tt)
 assert abs(lanearea-24*221)<1e-6,'Central lane rectangle coverage'
 dimensions=[]
 for t in tt:
  lengths=[dist(t[j],t[(j+1)%3]) for j in range(3)];j=max(range(3),key=lambda k:lengths[k])
  a,b,c=t[j],t[(j+1)%3],t[(j+2)%3];length=lengths[j];axis=sub(b,a)
  projection=sum((c[k]-a[k])*axis[k] for k in range(2))/length
  height=abs(orient(a,b,c))/length
  dimensions.append([projection,length-projection,height])
 assert min(min(row) for row in dimensions)>=.02,'Thin right-triangle decomposition'
 payload=dict(verticesXZ=poly,triangles=tris,indexBase=0,sourceSha256=hashlib.sha256(raw).hexdigest())
 (HERE/'ground-union.json').write_text(json.dumps(payload,indent=2)+'\n')
 report=dict(status='OFFLINE_UNION_PASS_NOT_STUDIO',sourceSha256=payload['sourceSha256'],sourcePieces=32,sourceSummedArea=sum(area(p) for p in polys),exactPolygonUnionArea=origarea,simplifiedArea=newarea,intersectionArea=intersection,coverageLostArea=loss,coverageAddedArea=gain,originalBoundaryVertices=len(original),simplifiedVertices=len(poly),triangles=len(tris),maxNativeWedges=2*len(tris),pairwiseTriangleOverlapArea=overlap,triangleArea=trianglearea,connectedBoundaryCount=1,holes=0,protectedSamples=len(protected),protectedAllCovered=True,boundarySampleStep=.1,bidirectionalSampleError=[forward,reverse],conservativeBoundaryDistanceUpperBound=max(forward,reverse)+.05,centralLaneRectangle=[-12,12,-5,216],centralLaneCoveredArea=lanearea,minimumDecomposedWedgeDimension=min(min(row) for row in dimensions),triangleWinding='CCW in XZ; geometric normal points negative Y',boundsXZ=[min(p[0] for p in poly),max(p[0] for p in poly),min(p[1] for p in poly),max(p[1] for p in poly)],limits='Exact area arithmetic up to floating point for 16-segment projected ellipses. Simplification changes footprint; boundary bound is sample distance plus Lipschitz allowance. Full central lane rectangle covered; other protected route/marker checks are finite samples. No Studio evidence.')
 (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
if __name__=='__main__':main()
