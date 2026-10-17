"""Original worn arch forecourt and irregular trail shoulders, native Y2 only.
Reuses reviewed arch/ivy composition. No new props or gameplay geometry.
"""
import math

ROADS=[(-9,9,1300,1462),(-69,-51,1365,1455),(51,69,1365,1455),
       (-69,69,1441,1459),(-69,69,1366,1384)]
EXCLUSIONS=ROADS+[(-48,48,1305,1355),(-10,10,1355,1380),
                  (-41,-29,1449,1461),(29,41,1449,1461)]

def make_central():
    grass=(74/255,117/255,72/255);sand=(180/255,153/255,108/255)
    soil=(.47,.43,.31);slate=(.43,.46,.39)
    def distance(x,z,box):
        a,b,c,d=box
        return math.hypot(max(a-x,0,x-b),max(c-z,0,z-d))
    def mix(a,b,t):return tuple(x*(1-t)+y*t for x,y in zip(a,b))
    def field(x,z):
        d=min(distance(x,z,r) for r in ROADS[1:])
        width=22+4*math.sin(x*.055+z*.04)+3*math.sin(z*.095-x*.025)
        shoulder=max(0,1-d/width);shoulder=shoulder*shoulder*(3-2*shoulder)
        radius=math.sqrt((x/37)**2+((z-1386)/30)**2)
        court=.83*math.exp(-radius**4)
        lane=.63*math.exp(-((abs(x)-9)/14)**2)*math.exp(-((z-1411)/44)**4)
        lodge=.6*math.exp(-((x+88)/24)**2-((z-1392)/24)**2)
        rgb=mix(grass,soil,max(court,lane,lodge,.16*math.exp(-((abs(x)-87)/24)**2)))
        rgb=mix(rgb,sand,shoulder)
        # Low-contrast broken stone crescents are blended into the forecourt,
        # never selected as a different hard palette region.
        ring=math.sqrt(((abs(x)-25)/10)**2+((z-1391)/12)**2)
        motif=.22*math.exp(-((ring-.85)/.18)**2)*math.exp(-((z-1392)/12)**4)
        rgb=mix(rgb,slate,motif*(1-shoulder))
        if z>=1459:
            lane=.94*math.exp(-((abs(x)-9)/18)**2)
            west=.96*math.exp(-((x+39)/29)**2-((z-1492)/29)**2)
            east=.93*math.exp(-((x-35)/27)**2-((z-1480)/23)**2)
            strength=1-(1-lane)*(1-west)*(1-east)
            strength+=.045*math.sin(x*.19+z*.13)*math.sin(z*.21-x*.08)
            rgb=mix(grass,(.465,.365,.245),max(0,min(1,strength)))
        return tuple(round(max(0,min(1,v))*128)/128 for v in rgb)
    xs=sorted({-110,0,110,*range(-108,110,8),*[v for b in EXCLUSIONS for v in b[:2]],-35,-31,-27,-23,-19,-15,15,19,23,27,31,35})
    zs=sorted({1300,1462,*range(1304,1462,8),*[v for b in EXCLUSIONS for v in b[2:]],1386,1390,1394,1398,1402})
    result=[]
    for side in ('west','east'):
        m=dict(id='terrain_forest_'+side,vertices=[],triangles=[],faceColors=[],colors=[])
        lookup={};color_lookup={}
        for a,b in zip(xs,xs[1:]):
            if side=='west' and b>0 or side=='east' and a<0:continue
            for c,d in zip(zs,zs[1:]):
                x,z=(a+b)/2,(c+d)/2
                if not 1300<=c<d<=1462 or any(r[0]<x<r[1] and r[2]<z<r[3] for r in EXCLUSIONS):continue
                points=[(a,2.02,c),(a,2.02,d),(b,2.02,d),(b,2.02,c)]
                faces=((0,1,2),(0,2,3))
                if 1384<=c<d<=1441 and (b-a)*(d-c)>20:
                    points.append((x,2.02,z));faces=((0,1,4),(1,2,4),(2,3,4),(3,0,4))
                for ids in faces:
                    xx=sum(points[i][0] for i in ids)/3;zz=sum(points[i][2] for i in ids)/3
                    rgb=field(xx,zz)
                    if rgb not in color_lookup:color_lookup[rgb]=len(m['colors'])+1;m['colors'].append(list(rgb))
                    color=color_lookup[rgb]
                    face=[]
                    for i in ids:
                        p=points[i]
                        if p not in lookup:lookup[p]=len(m['vertices']);m['vertices'].append(p)
                        face.append(lookup[p])
                    m['triangles'].append(face);m['faceColors'].append(color)
        assert len(m['triangles'])<=2000,(m['id'],len(m['triangles']))
        result.append(m)
    return result
