"""Original offline ribbon tessellation. No Roblox or Blender acceptance implied."""
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent

def add(a,b): return [x+y for x,y in zip(a,b)]
def sub(a,b): return [x-y for x,y in zip(a,b)]
def mul(a,k): return [x*k for x in a]
def dot(a,b): return sum(x*y for x,y in zip(a,b))
def cross(a,b): return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def length(a): return math.sqrt(dot(a,a))
def unit(a): return mul(a,1/length(a))
def area(t): return length(cross(sub(t[1],t[0]),sub(t[2],t[0])))/2
def xzarea(t): return abs(cross(sub(t[1],t[0]),sub(t[2],t[0]))[1])/2

def clip(poly, triangle):
    # Convex 2D clipping; projected triangles are CCW in X/Z.
    def signed(a,b,p): return (b[0]-a[0])*(p[1]-a[1])-(b[1]-a[1])*(p[0]-a[0])
    if signed(*triangle)<0: triangle=list(reversed(triangle))
    for a,b in zip(triangle,triangle[1:]+triangle[:1]):
        out=[]
        for p,q in zip(poly,poly[1:]+poly[:1]):
            sp,sq=signed(a,b,p),signed(a,b,q)
            if sp>=-1e-9: out.append(p)
            if (sp>0 and sq<0) or (sp<0 and sq>0):
                k=sp/(sp-sq);out.append([p[i]+k*(q[i]-p[i]) for i in range(2)])
        poly=out
        if not poly: break
    return abs(sum(p[0]*q[1]-p[1]*q[0] for p,q in zip(poly,poly[1:]+poly[:1])))/2

def main():
    d=json.loads((HERE/'descriptor.json').read_text())
    original=d['centerline']; points=[]; widths=[]
    def width(p):
        return d['shoulderWidth']
    for a,b in zip(original,original[1:]):
        n=math.ceil(length(sub(b,a))/40)
        for j in range(n):
            p=add(a,mul(sub(b,a),j/n));points.append(p);widths.append(width(p))
    points.append(original[-1]);widths.append(width(points[-1]))
    dirs=[unit([b[0]-a[0],0,b[2]-a[2]]) for a,b in zip(points,points[1:])]
    offsets=[]
    for i,p in enumerate(points):
        before=dirs[max(0,i-1)];after=dirs[min(i,len(dirs)-1)]
        n1=[before[2],0,-before[0]];n2=[after[2],0,-after[0]]
        m=unit(add(n1,n2)); offsets.append(mul(m,1/dot(m,n2)))
    road=[];outer=[]
    for p,o,w in zip(points,offsets,widths):
        road.append([add(p,mul(o,-12)),add(p,mul(o,12))])
        outer.append([add(add(p,[0,-.2,0]),mul(o,-w/2)),add(add(p,[0,-.2,0]),mul(o,w/2))])
    tops=[];parts=[];max_error=0;min_dimension=1000
    def emit(t,solid,label):
        nonlocal max_error,min_dimension
        if cross(sub(t[1],t[0]),sub(t[2],t[0]))[1]<0:t=[t[0],t[2],t[1]]
        assert area(t)>1e-6
        tops.append({'vertices':t,'collision':solid,'group':label})
        # Longest edge ensures the altitude foot lies inside the base.
        i=max(range(3),key=lambda k:length(sub(t[(k+1)%3],t[(k+2)%3])))
        a,b,c=t[i],t[(i+1)%3],t[(i+2)%3]
        bc=sub(c,b);f=add(b,mul(bc,dot(sub(a,b),bc)/dot(bc,bc)))
        normal=unit(cross(sub(b,a),sub(c,a)))
        assert normal[1]>0
        for e in (b,c):
            h=length(sub(a,f));l=length(sub(f,e))
            if l<1e-8:continue
            y=unit(sub(a,f));z=unit(sub(f,e));x=cross(y,z)
            # X can point up or down: both are valid right-handed frames.
            # The upper broad face is selected by dot(X, upwardNormal).
            thickness=.4;center=sub(mul(add(a,e),.5),mul(normal,thickness/2))
            rotation=[x[0],y[0],z[0],x[1],y[1],z[1],x[2],y[2],z[2]]
            side=1 if dot(x,normal)>0 else -1
            reconstructed=[]
            for yy,zz in ((-h/2,-l/2),(-h/2,l/2),(h/2,l/2)):
                reconstructed.append(add(add(add(center,mul(x,side*thickness/2)),mul(y,yy)),mul(z,zz)))
            max_error=max(max_error,max(length(sub(v,w)) for v,w in zip(reconstructed,(e,f,a))))
            assert abs(dot(x,cross(y,z))-1)<1e-8
            min_dimension=min(min_dimension,thickness,h,l)
            blend=max(0,min(1,(center[0]-135)/220))
            color=[a+(b-a)*blend for a,b in zip([.58,.51,.36] if solid else [.31,.42,.25],[.48,.47,.43] if solid else [.39,.41,.31])]
            parts.append({'name':f'{label}_{len(parts):03d}','className':'WedgePart','position':center,'size':[thickness,h,l],
              'rotation':rotation,'color':color,
              'material':'Ground' if solid else 'Grass','collision':solid,'query':solid,
              'touch':False,'anchored':True,'castShadow':False})
    def quad(a,b,c,e,solid,label):
        emit([a,b,c],solid,label);emit([a,c,e],solid,label)
    for i in range(len(points)-1):
        quad(road[i][0],road[i+1][0],road[i+1][1],road[i][1],True,'Road')
        # Shoulders are separate ribbons, not a broad overlapping road layer.
        for side in (0,1):
            inner0=add(road[i][side],[0,-.2,0]);inner1=add(road[i+1][side],[0,-.2,0])
            quad(inner0,inner1,outer[i+1][side],outer[i][side],False,'Shoulder')
    collision_tops=[v['vertices'] for v in tops if v['collision']]
    max_overlap=0
    for i,a in enumerate(collision_tops):
        pa=[[v[0],v[2]] for v in a]
        for b in collision_tops[i+1:]:
            pb=[[v[0],v[2]] for v in b]
            max_overlap=max(max_overlap,clip(pa,pb))
    assert max_overlap<1e-5,("Road self-overlap",max_overlap)
    max_all_overlap=0
    for i,a in enumerate(tops):
        pa=[[v[0],v[2]] for v in a['vertices']]
        for b in tops[i+1:]:
            pb=[[v[0],v[2]] for v in b['vertices']]
            max_all_overlap=max(max_all_overlap,clip(pa,pb))
    assert max_all_overlap<1e-5,("Road/shoulder overlap",max_all_overlap)
    assert max_error<1e-8 and min_dimension>=.001
    private=[v for t in tops for v in t['vertices'] if -72<=v[2]<=118]
    assert not private, "Second route must remain entirely outside private belt"
    result={'evidence':'OFFLINE_SOURCE_GEOMETRY_NOT_STUDIO','parts':parts,'topTriangles':tops,
      'walkCenterline':points,'crosssections':[{'center':p,'road':r,'shoulder':s,'shoulderWidth':w} for p,r,s,w in zip(points,road,outer,widths)]}
    report={'evidence':result['evidence'],'parts':len(parts),'colliders':sum(p['collision'] for p in parts),
      'sections':len(points),'roadTriangles':len(collision_tops),'allTopTriangles':len(tops),'roadArea3D':sum(area(t) for t in collision_tops),
      'roadProjectedArea':sum(xzarea(t) for t in collision_tops),'maximumRoadPairOverlapArea':max_overlap,
      'maximumAllTopPairProjectedOverlapArea':max_all_overlap,
      'maximumNativeVertexReconstructionError':max_error,'minimumNativeDimension':min_dimension,
      'maximumSegmentLength':max(length(sub(a,b)) for a,b in zip(points,points[1:])),
      'maximumCenterlineSlope':max(abs(b[1]-a[1])/math.hypot(b[0]-a[0],b[2]-a[2]) for a,b in zip(points,points[1:])),
      'privateBeltVertices':len(private),
      'seams':'Exact shared cross-section vertices. Endpoint floors overlap existing region floors; native float/path verification pending.',
      'basis':'Columns X=cross(Y,Z), Y=altitude, Z=foot-endpoint; determinant+1. Offset center down upward normal; either signed broad X face reconstructs original triangle.',
      'bounds':{'min':[min(v[k] for t in tops for v in t['vertices']) for k in range(3)],'max':[max(v[k] for t in tops for v in t['vertices']) for k in range(3)]}}
    for name,data in [('ground.json',result),('geometry-report.json',report)]:
        (HERE/name).write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__':main()
