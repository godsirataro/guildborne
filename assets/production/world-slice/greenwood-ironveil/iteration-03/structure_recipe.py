"""Original bounded bridge stonework and timber members; no external assets."""
import math
def make_structures(ground):
    meshes=[];solids=[];line=ground['walkCenterline']
    def center(x,y,offset):
        for a,b in zip(line,line[1:]):
            if a[0]<=x<=b[0]:
                t=(x-a[0])/(b[0]-a[0]);z=a[2]+t*(b[2]-a[2]);dx,dz=b[0]-a[0],b[2]-a[2];n=math.hypot(dx,dz)
                return [x-dz/n*offset,y,z+dx/n*offset]
        raise ValueError(x)
    def new(mid,colors):
        m=dict(id=mid,vertices=[],triangles=[],colors=colors,faceColors=[]);meshes.append(m);return m
    def beam(m,name,a,b,width,depth,color):
        # Local X longitudinal, Y chosen near-up, Z lateral. Closed box.
        direction=[b[k]-a[k] for k in range(3)];length=math.sqrt(sum(v*v for v in direction));u=[v/length for v in direction]
        side=[-u[2],0,u[0]];n=math.sqrt(sum(v*v for v in side));side=[v/n for v in side]
        up=[side[1]*u[2]-side[2]*u[1],side[2]*u[0]-side[0]*u[2],side[0]*u[1]-side[1]*u[0]]
        c=[(a[k]+b[k])/2 for k in range(3)];v=[]
        for sx,sy,sz in [(-1,-1,-1),(1,-1,-1),(1,-1,1),(-1,-1,1),(-1,1,-1),(1,1,-1),(1,1,1),(-1,1,1)]:
            v.append([c[k]+sx*u[k]*length/2+sy*up[k]*depth/2+sz*side[k]*width/2 for k in range(3)])
        start=len(m['vertices']);m['vertices'].extend(v)
        for f in [(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]:
            for t in [(f[0],f[1],f[2]),(f[0],f[2],f[3])]:m['triangles'].append([start+j+1 for j in t]);m['faceColors'].append(color)
        solids.append(dict(meshId=m['id'],name=name,firstVertex=start+1,vertices=8,firstTriangle=len(m['triangles'])-11,triangles=12,center=c))
    stone=new('gi_original_stone_edges',[[.39,.40,.36],[.48,.47,.41],[.35,.37,.35]])
    for i,x in enumerate(range(114,377,9)):
        for side in (-1,1):
            height=1.0 if x<200 else 2.7
            beam(stone,f'curb_{i}_{side}',center(x-4.2,1.9+height/2,side*15),center(x+4.2,1.9+height/2,side*15),1.8,height,1+i%3)
    for x in (112,198,288,377):
        for side in (-1,1):beam(stone,f'cap_{x}_{side}',center(x-1.8,3.9,side*15),center(x+1.8,3.9,side*15),3.2,4.0,2)
    arch=new('gi_original_open_arches',[[.35,.36,.33],[.42,.41,.37],[.30,.32,.30]])
    for span,(start,end) in enumerate([(110,200),(200,290),(290,380)]):
        for side in (-1,1):
            for i in range(12):
                def p(j):
                    t=j/12;return center(start+(end-start)*t,-9+9.1*math.sin(math.pi*t),side*15)
                beam(arch,f'arch_{span}_{side}_{i}',p(i),p(i+1),3.0,1.5,1+i%3)
    for x in (112,200,290,378):
        for side in (-1,1):beam(arch,f'pier_{x}_{side}',center(x-2.0,-4.6,side*15),center(x+2.0,-4.6,side*15),4.8,12.0,2)
    timber=new('gi_original_woodland_rails',[[.29,.20,.12],[.42,.31,.19]])
    for side in (-1,1):
        for x in range(118,195,12):beam(timber,f'post_{x}_{side}',center(x-.5,4,side*15),center(x+.5,4,side*15),1.0,4.2,1)
        for start,end in [(118,145),(145,180),(180,194)]:
            for y in (3.6,5.5):beam(timber,f'rail_{start}_{side}_{y}',center(start,y,side*15),center(end,y,side*15),.65,.65,2)
    for m in meshes:
        m['bounds']={key:[fn(v[k] for v in m['vertices']) for k in range(3)] for key,fn in [('min',min),('max',max)]}
        assert len(m['triangles'])<=2000
    return meshes,solids
