"""Original Greenwood surface composition, in world studs; no collision changes.

Flat color regions follow continuous authored fields, not random scatter.
The existing island/rise determines every elevation. Roads and resources remain
exposed. Blender conversion is owned by blender_world_slice.py.
"""
import math

ROADS = [(-12,12,1317,1512),(-18,18,1496,1530),
         (-72,-48,1362,1458),(48,72,1362,1458),
         (-72,72,1438,1462),(-72,72,1363,1387),
         (-41,-29,1449,1461),(29,41,1449,1461)]

def make_terrain():
    result=[]
    grass=(74/255,117/255,72/255)
    earth=(.47,.375,.255)
    leaf=(.355,.365,.225)
    rock=(.33,.325,.265)
    palette=[]
    for target in (earth,leaf,rock):
        for i in range(13):
            t=i/12
            palette.append([round(a*(1-t)+b*t,5) for a,b in zip(grass,target)])
    native_rise=(100/255,78/255,56/255)
    for i in range(13):
        t=i/12
        palette.append([round(a*(1-t)+b*t,5) for a,b in zip(native_rise,leaf)])

    def field(x,z,boss=False):
        # Broad overlapping courts join building entrances to the central road.
        # A winding leaf-floor band gathers existing woodland into one place.
        if z>=1438:
            center=1485+3*math.sin(x*.075)
            court=math.exp(-((z-center)/19)**4)
            court*=max(math.exp(-((x+39)/40)**4),math.exp(-((x-38)/37)**4))
            threshold=math.exp(-((z-1495)/12)**2)*math.exp(-(x/53)**4)
            return 0,min(1,max(court,threshold))
        pathx=77+9*math.sin((z-1300)*.045)
        band=math.exp(-((abs(x)-pathx)/32)**4)
        north=math.exp(-((z-1327)/39)**4)
        lodge=math.exp(-((x+88)/30)**4-((z-1392)/27)**4)
        clearing=math.exp(-(x/44)**4-((z-1410)/28)**4)
        strength=max(band*.82,north*.75,lodge*.9,clearing*.43)
        if boss:return 3,.52+.16*math.sin(x*.08+z*.05)
        return 1,max(0,min(1,strength))

    def mesh(name):
        return dict(id='terrain_'+name,vertices=[],triangles=[],faceColors=[],colors=palette)

    def triangle(m,points,color):
        i=len(m['vertices']);m['vertices'].extend(points)
        m['triangles'].append([i,i+1,i+2]);m['faceColors'].append(color)

    def excluded(x,z,boss):
        if any(a<x<b and c<z<d for a,b,c,d in ROADS):return True
        if not boss and -48<x<48 and 1305<z<1355:return True
        if not boss and -10<x<10 and 1355<z<1380:return True
        return False

    def grid(name,x0,x1,z0,z1,height,boss=False):
        m=mesh(name)
        # Exact native boundary vertices prevent triangles spanning a road/rise.
        step=4 if name.startswith('arrival') else 8
        xs=sorted({x0,x1,*[v for v in range(-108,110,step) if x0<v<x1],
                   *[v for v in (-72,-48,-41,-29,-18,-12,-10,10,12,18,29,41,48,72) if x0<v<x1]})
        zs=sorted({z0,z1,*[v for v in range(1304,1500,step) if z0<v<z1],
                   *[v for v in (1305,1317,1355,1362,1363,1380,1387,1438,1449,1458,1461,1462,1496) if z0<v<z1]})
        for a,b in zip(xs,xs[1:]):
            for c,d in zip(zs,zs[1:]):
                if excluded((a+b)/2,(c+d)/2,boss):continue
                points=[(a,height,c),(a,height,d),(b,height,d),(b,height,c)]
                for ids in ((0,1,2),(0,2,3)):
                    tri=[points[i] for i in ids]
                    x=sum(v[0] for v in tri)/3;z=sum(v[2] for v in tri)/3
                    target,strength=field(x,z,boss)
                    # Fade into native grass at protected road/resource cutouts.
                    distance=min(math.hypot(max(a-x,0,x-b),max(c-z,0,z-d)) for a,b,c,d in ROADS)
                    strength*=min(1,distance/10)
                    triangle(m,tri,target*13+round(strength*12)+1)
        result.append(m)

    for side,a,b in [('west',-110,0),('east',0,110)]:
        grid('arrival_'+side,a,b,1462,1500,2.02)
        grid('forest_'+side,a,b,1300,1462,2.02)
    grid('boss_floor',-48,48,1305,1355,6.02,True)
    m=mesh('embankments')
    def wall(a,b,bottom,top,outward):
        length=math.hypot(b[0]-a[0],b[1]-a[1]);n=math.ceil(length/8)
        for i in range(n):
            t=i/n;u=(i+1)/n
            x=a[0]+(b[0]-a[0])*t;z=a[1]+(b[1]-a[1])*t
            xx=a[0]+(b[0]-a[0])*u;zz=a[1]+(b[1]-a[1])*u
            # Three strata describe soil over weathered rock without fake relief.
            for lo,hi,base in ((bottom,bottom+(top-bottom)*.36,32),
                               (bottom+(top-bottom)*.36,top-.45,35),
                               (top-.45,top,21)):
                points=[(x,lo,z),(xx,lo,zz),(xx,hi,zz),(x,hi,z)]
                for ids in ((0,1,2),(0,2,3)):
                    tri=[points[j] for j in ids]
                    av,bv,cv=tri
                    nx=(bv[1]-av[1])*(cv[2]-av[2])-(bv[2]-av[2])*(cv[1]-av[1])
                    nz=(bv[0]-av[0])*(cv[1]-av[1])-(bv[1]-av[1])*(cv[0]-av[0])
                    if nx*outward[0]+nz*outward[1]<0:tri.reverse()
                    triangle(m,tri,base+(i%2))
    # Existing rise perimeter, leaving the central ramp mouth unobstructed.
    wall((-48.02,1305),(-48.02,1355),2.02,5.98,(-1,0))
    wall((48.02,1305),(48.02,1355),2.02,5.98,(1,0))
    wall((-48,1304.98),(48,1304.98),2.02,5.98,(0,-1))
    wall((-48,1355.02),(-12,1355.02),2.02,5.98,(0,1))
    wall((12,1355.02),(48,1355.02),2.02,5.98,(0,1))
    # Skin existing island sides, leaving landing/apron attachment mouths clear.
    wall((-110.02,1300),(-110.02,1500),-1.98,1.98,(-1,0))
    wall((110.02,1300),(110.02,1500),-1.98,1.98,(1,0))
    wall((-110,1299.98),(110,1299.98),-1.98,1.98,(0,-1))
    wall((-110,1500.02),(-62,1500.02),-1.98,1.98,(0,1))
    wall((-18,1500.02),(-14,1500.02),-1.98,1.98,(0,1))
    wall((14,1500.02),(110,1500.02),-1.98,1.98,(0,1))
    result.append(m)
    for item in result:
        unique=[];remap={};indices=[]
        for point in item['vertices']:
            key=tuple(round(v,5) for v in point)
            if key not in remap:remap[key]=len(unique);unique.append(key)
            indices.append(remap[key])
        item['vertices']=unique
        item['triangles']=[[indices[i] for i in face] for face in item['triangles']]
    assert len(result)<=6 and all(len(m['triangles'])<=2000 for m in result)
    assert sum(len(m['triangles']) for m in result)<=12000
    return result
