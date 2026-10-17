"""Original hand-composed rock foundations and woodland waymarkers.
World Y-up units, same export interface as terrain_recipe. No collision or light.
"""
import math

def make_silhouette():
    palette=[[.27,.29,.265],[.34,.36,.32],[.40,.405,.34],[.44,.43,.36],
             [.29,.36,.23],[.36,.44,.26],[.24,.34,.20],[.45,.54,.38],
             [.32,.48,.46],[.46,.62,.54],[.28,.23,.17]]
    def mesh(name):return dict(id='silhouette_'+name,vertices=[],triangles=[],faceColors=[],colors=palette)
    def tri(m,a,b,c,color):
        i=len(m['vertices']);m['vertices'] += [a,b,c]
        m['triangles'].append([i,i+1,i+2]);m['faceColors'].append(color)
    def shell(m,rings,colors,close=True):
        n=len(rings[0])
        for k in range(len(rings)-1):
            for i in range(n):
                j=(i+1)%n
                a,b,c,d=rings[k][i],rings[k][j],rings[k+1][j],rings[k+1][i]
                tri(m,a,b,c,colors[k][i%len(colors[k])]);tri(m,a,c,d,colors[k][i%len(colors[k])])
        if close:
            ring=rings[-1];center=tuple(sum(v[j] for v in ring)/n for j in range(3))
            for i in range(n):tri(m,center,ring[i],ring[(i+1)%n],1)
    cliff=mesh('rooted_cliff')
    # Clockwise seen from above; bands taper into a deep fractured foundation.
    outline=[]
    for i in range(10):outline.append((-110.04+i*22.008,1299.96))
    for i in range(10):outline.append((110.04,1299.96+i*20.008))
    for i in range(10):outline.append((110.04-i*22.008,1500.04))
    for i in range(10):outline.append((-110.04,1500.04-i*20.008))
    rings=[]
    for level in range(4):
        ring=[]
        for i,(x,z) in enumerate(outline):
            dz=z-1400
            if level==0:xx,zz,y=x,z,1.90
            elif level==1:
                scale=1.025+.025*(.5+.5*math.sin(i*2.31))
                xx,zz,y=x*scale,1400+dz*scale,-6.5-2*math.sin(i*1.7)**2
            elif level==2:
                scale=.91+.055*math.sin(i*1.41)
                xx,zz,y=x*scale,1400+dz*scale,-18-4*math.sin(i*1.13)**2
            else:
                scale=.69+.08*math.sin(i*1.81)
                xx,zz,y=x*scale,1400+dz*scale,-28-7*math.sin(i*1.37)**2
            ring.append((xx,y,zz))
        rings.append(ring)
    shell(cliff,rings,[[4,3,5,3,4],[2,3,2,1,3],[1,2,1,2]])
    # Existing landing and stable-apron undersides get matching supported profiles.
    for x0,x1,z0,z1,top,bottom in [(-14,14,1500,1526,1.9,-15),(-62,-18,1500,1520,1.8,-13)]:
        corners=[(x0,z0),(x1,z0),(x1,z1),(x0,z1)];cx=(x0+x1)/2;cz=(z0+z1)/2
        shell(cliff,[[(x,top,z) for x,z in corners],
                     [(cx+(x-cx)*.94,-5,cz+(z-cz)*.94) for x,z in corners],
                     [(cx+(x-cx)*.55,bottom,cz+(z-cz)*.55) for x,z in corners]],[[3,4],[2,1]])
    def stone(m,cx,cz,rx,rz,height,y=2,phase=0,color=2):
        n=7;rings=[]
        for level,scale in enumerate((.76,1,.68,.23)):
            ring=[]
            for i in range(n):
                angle=2*math.pi*i/n+phase
                uneven=1+.10*math.sin(i*2.5+phase)
                ring.append((cx+math.cos(angle)*rx*scale*uneven,
                             y+height*(0,.33,.80,1)[level],
                             cz+math.sin(angle)*rz*scale*uneven))
            rings.append(ring)
        # Top-to-bottom order keeps the exterior faces outward.
        shell(m,list(reversed(rings)),[[color,3,4],[color,3],[1,color]],False)
        top=rings[-1];center=(cx,y+height,cz)
        for i in range(n):tri(m,center,top[(i+1)%n],top[i],color+1)
    rocks=mesh('fern_rocks')
    stone(rocks,-1.5,1410,2.8,2.5,5,phase=.2)
    stone(rocks,2.2,1411,2.2,2,3.1,phase=1.4)
    stone(rocks,1.3,1407.5,1.4,1.5,2,phase=.9)
    # Original broad fern fronds cluster around the stone foot; double-sided.
    for cx,cz in [(-3.6,1408),(3.7,1412),(.2,1413.5)]:
        for i in range(7):
            angle=i*2*math.pi/7;dx=math.cos(angle);dz=math.sin(angle)
            a=(cx,2.08,cz);b=(cx+dx*1.35-dz*.4,3.5,cz+dz*1.35+dx*.4)
            c=(cx+dx*2.1,2.6,cz+dz*2.1);d=(cx+dx*1.35+dz*.4,3.5,cz+dz*1.35-dx*.4)
            for aa,bb,cc in [(a,b,c),(a,c,d)]:tri(rocks,aa,bb,cc,6+i%2);tri(rocks,cc,bb,aa,6+i%2)
    beacon=mesh('ruined_waymarker')
    stone(beacon,0,1410,2.6,2.5,1.1,phase=.5,color=3)
    stone(beacon,-.25,1410,1.45,1.35,4.4,y=2.6,phase=.2,color=2)
    stone(beacon,.1,1410,1.85,1.65,.8,y=6.6,phase=.4,color=3)
    # A pale jade stone, not a runtime light or unlicensed symbol.
    stone(beacon,.1,1410,.75,.75,2.1,y=7.1,phase=.7,color=8)
    stone(beacon,2.1,1411.5,.7,.85,.65,phase=.8,color=2)
    result=[cliff,rocks,beacon]
    for item in result:
        unique=[];mapping={};ids=[]
        for p in item['vertices']:
            key=tuple(round(v,5) for v in p)
            if key not in mapping:mapping[key]=len(unique);unique.append(key)
            ids.append(mapping[key])
        item['vertices']=unique;item['triangles']=[[ids[i] for i in t] for t in item['triangles']]
        assert len(item['triangles'])<=2000
    return result

PLACEMENTS=[('silhouette_rooted_cliff','Rooted_Foundation',0,1410,0),
            ('silhouette_fern_rocks','West_Arrival_RockGrove',-100,1480,0),
            ('silhouette_fern_rocks','East_Arrival_RockGrove',100,1480,160),
            ('silhouette_fern_rocks','West_Forest_RockGrove',-100,1340,50),
            ('silhouette_fern_rocks','East_Forest_RockGrove',100,1340,220),
            ('silhouette_ruined_waymarker','West_Arrival_Waymarker',-76,1486,0),
            ('silhouette_ruined_waymarker','East_Arrival_Waymarker',76,1486,180)]
