"""Original arrival ground continuity and carved woodland charter marker.
Uses existing ground at Y2; no collision, navigation, light or service changes.
"""
import math

def make_arrival():
    result=[]
    grass=(74/255,117/255,72/255);soil=(.465,.365,.245)
    colors=[]
    for i in range(33):
        t=i/32
        for shade in (-.012,0,.012):colors.append([round(max(0,min(1,a*(1-t)+b*t+shade)),5) for a,b in zip(grass,soil)])
    def mesh(name,palette):return dict(id=name,vertices=[],triangles=[],faceColors=[],colors=palette)
    def triangle(m,a,b,c,color):
        i=len(m['vertices']);m['vertices'] += [a,b,c];m['triangles'].append([i,i+1,i+2]);m['faceColors'].append(color)
    def support(x,z):
        return (-110<=x<=110 and 1462<=z<=1500) or (-62<=x<=-18 and 1500<=z<=1520) or (-14<=x<=14 and 1500<=z<=1526)
    def color_at(x,z):
        lane=.94*math.exp(-((abs(x)-9)/18)**2)
        west=.96*math.exp(-((x+39)/29)**2-((z-1492)/29)**2)
        east=.93*math.exp(-((x-35)/27)**2-((z-1480)/23)**2)
        strength=1-(1-lane)*(1-west)*(1-east)
        strength+=.045*math.sin(x*.19+z*.13)*math.sin(z*.21-x*.08)
        if z>=1500 and abs(x)<=14:strength=max(.88,strength)
        shade=1 if math.sin(x*1.3+z*.7)>.5 else -1 if math.sin(x*.8-z*.9)<-.6 else 0
        return round(max(0,min(1,strength))*32)*3+shade+2
    critical_x={-110,-62,-18,-14,-9,9,14,110}
    critical_z={1462,1500,1520,1526}
    xs=sorted(critical_x|{-110+2.5*i for i in range(89)})
    zs=sorted(critical_z|{1462+2.5*i for i in range(26)})
    def vertex(x,z):
        # Shared deterministic slight offsets break the regular square palette
        # lattice while all support/road boundary vertices stay exact.
        xx=x if x in critical_x else x+.16*math.sin(x*.7+z*.8)
        zz=z if z in critical_z else z+.16*math.sin(x*.9-z*.6)
        return (round(xx,5),2.02,round(zz,5))
    for side in ('west','east'):
        m=mesh('terrain_arrival_'+side,colors)
        for a,b in zip(xs,xs[1:]):
            if side=='west' and b>-9 or side=='east' and a<9:continue
            for c,d in zip(zs,zs[1:]):
                x,z=(a+b)/2,(c+d)/2
                if not support(x,z):continue
                points=[vertex(a,c),vertex(a,d),vertex(b,d),vertex(b,c)]
                for ids in ((0,1,2),(0,2,3)):
                    t=[points[i] for i in ids];xx=sum(v[0] for v in t)/3;zz=sum(v[2] for v in t)/3
                    triangle(m,*t,color_at(xx,zz))
        result.append(m)
    palette=[[.25,.16,.095],[.36,.25,.13],[.16,.25,.19],[.24,.39,.28],
             [.72,.59,.32],[.85,.69,.36],[.18,.20,.18],[.87,.52,.20]]
    sign=mesh('arrival_charter_sign',palette)
    def box(cx,cy,cz,sx,sy,sz,color):
        v=[(cx+x*sx/2,cy+y*sy/2,1410+cz+z*sz/2) for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
        for f in [(0,3,2,1),(4,5,6,7),(0,4,7,3),(1,2,6,5),(3,7,6,2),(0,1,5,4)]:
            triangle(sign,v[f[0]],v[f[1]],v[f[2]],color);triangle(sign,v[f[0]],v[f[2]],v[f[3]],color)
    box(0,6.3,0,.48,8.6,.48,1)
    box(0,9.9,0,5.2,.32,.48,2)
    box(0,2.25,0,.80,.5,.80,7)
    # Shaped shield, not a rectangular texture panel. Front faces toward arrival.
    outline=[(-2.1,9.5),(0,10.4),(2.1,9.5),(1.8,7.0),(0,6.3),(-1.8,7.0)]
    for z,color,reverse in [(.30,4,False),(-.30,3,True)]:
        center=(0,8.5,1410+z)
        for i,(x,y) in enumerate(outline):
            xx,yy=outline[(i+1)%len(outline)];a=(x,y,1410+z);b=(xx,yy,1410+z)
            triangle(sign,center,a,b,color) if reverse else triangle(sign,center,b,a,color)
    for i,(x,y) in enumerate(outline):
        xx,yy=outline[(i+1)%len(outline)]
        triangle(sign,(x,y,1410-.3),(x,y,1410+.3),(xx,yy,1410+.3),2)
        triangle(sign,(x,y,1410-.3),(xx,yy,1410+.3),(xx,yy,1410-.3),2)
    # Original geometric pine relief, with narrow trunk and three gold branches.
    box(0,7.8,.38,.18,1.9,.08,5)
    for y,width in [(7.65,1.3),(8.3,1.05),(8.9,.72)]:
        triangle(sign,(-width,y,1410.45),(width,y,1410.45),(0,y+1.15,1410.45),6)
    box(2.1,8.8,0,.12,1.8,.12,7)
    box(2.1,7.8,0,.7,.85,.65,8)
    box(2.1,8.27,0,.86,.14,.80,7);box(2.1,7.31,0,.86,.14,.80,7)
    for x in (1.78,2.42):box(x,7.8,.34,.08,.85,.08,7)
    result.append(sign)
    for m in result:
        unique=[];indices=[];lookup={}
        for p in m['vertices']:
            if p not in lookup:lookup[p]=len(unique);unique.append(p)
            indices.append(lookup[p])
        m['vertices']=unique;m['triangles']=[[indices[i] for i in t] for t in m['triangles']]
        assert len(m['triangles'])<=2000,(m['id'],len(m['triangles']))
    return result
