"""Original receiving yard geometry. Offline generation; no upload/runtime activation."""
from pathlib import Path
import json,math,random,hashlib
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/ironveil-ore-yard'
SOURCE=ROOT/'assets/production/world-slice/world-slice.mesh.json'
random.seed(1937);meshes=[];solids=[];groups={}
COLORS=[[.36,.40,.40],[.48,.49,.45],[.58,.55,.46],[.26,.29,.30],[.27,.16,.09],[.43,.28,.15],[.58,.40,.22],[.17,.25,.31],[.23,.33,.40],[.30,.39,.43],[.64,.34,.16],[.82,.53,.25],[.27,.44,.40],[.70,.65,.52],[.15,.19,.20]]
def add(a,b):return [a[i]+b[i] for i in range(3)]
def sub(a,b):return [a[i]-b[i] for i in range(3)]
def mul(a,k):return [x*k for x in a]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def unit(v):return mul(v,1/math.sqrt(dot(v,v)))
def solid(group,name,vertices,faces,color):
    count=sum(len(f)-2 for f in faces)
    m=groups.get(group)
    if m is None or len(m['triangles'])+count>1900:
        m=dict(id=f'oreyard_{group}_{sum(x["id"].startswith("oreyard_"+group+"_") for x in meshes):02d}',vertices=[],triangles=[],colors=COLORS,faceColors=[]);meshes.append(m);groups[group]=m
    center=[sum(v[k] for v in vertices)/len(vertices) for k in range(3)];start=len(m['vertices']);first=len(m['triangles'])+1;m['vertices'].extend(vertices)
    for face in faces:
        for i in range(1,len(face)-1):
            ids=[face[0],face[i],face[i+1]];a,b,c=[vertices[j] for j in ids]
            normal=cross(sub(b,a),sub(c,a));out=sub(mul(add(add(a,b),c),1/3),center)
            if dot(normal,out)<0:ids.reverse()
            assert dot(normal,normal)>1e-14,name
            m['triangles'].append([start+j+1 for j in ids]);m['faceColors'].append(color)
    solids.append(dict(name=name,meshId=m['id'],firstVertex=start+1,vertexCount=len(vertices),firstTriangle=first,triangleCount=count,center=center))
BOXF=[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]
SIGNS=[(-1,-1,-1),(1,-1,-1),(1,-1,1),(-1,-1,1),(-1,1,-1),(1,1,-1),(1,1,1),(-1,1,1)]
def box(group,name,c,size,color,yaw=0):
    co,si=math.cos(yaw),math.sin(yaw);verts=[]
    for a,b,d in SIGNS:
        x,y,z=a*size[0]/2,b*size[1]/2,d*size[2]/2;verts.append([c[0]+co*x+si*z,c[1]+y,c[2]-si*x+co*z])
    solid(group,name,verts,BOXF,color)
def beam(group,name,a,b,width,depth,color):
    u=unit(sub(b,a));guide=[0,1,0] if abs(u[1])<.95 else [0,0,1];side=unit(cross(u,guide));up=unit(cross(side,u));length=math.sqrt(dot(sub(b,a),sub(b,a)));c=mul(add(a,b),.5)
    solid(group,name,[add(c,add(mul(u,x*length/2),add(mul(up,y*depth/2),mul(side,z*width/2)))) for x,y,z in SIGNS],BOXF,color)
def cylinder(group,name,c,r,h,color,n=12,top=None):
    top=r if top is None else top;v=[]
    for y,rr in [(-h/2,r),(h/2,top)]:v.extend([[c[0]+rr*math.cos(i*2*math.pi/n),c[1]+y,c[2]+rr*math.sin(i*2*math.pi/n)] for i in range(n)])
    faces=[tuple(range(n-1,-1,-1)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    solid(group,name,v,faces,color)
def rock(group,name,c,size,color,seed):
    # Convex eight-sided irregular layered outcrop; top/bottom caps are nonplanar
    # fans around their centers, every resulting triangle wound outward.
    rng=random.Random(seed);n=7;verts=[]
    phases=[rng.uniform(.85,1.12) for _ in range(n)]
    for yy,scale,shift in [(-.5,.76,0),(.05,1,.09),(.5,.58,-.05)]:
        for i in range(n):
            angle=i*2*math.pi/n;rr=phases[i]*scale;verts.append([c[0]+size[0]*.5*rr*math.cos(angle)+size[0]*shift,c[1]+size[1]*yy,c[2]+size[2]*.5*rr*math.sin(angle)])
    faces=[tuple(range(n-1,-1,-1)),tuple(range(2*n,3*n))]
    for ring in range(2):
        for i in range(n):faces.append((ring*n+i,ring*n+(i+1)%n,(ring+1)*n+(i+1)%n,(ring+1)*n+i))
    solid(group,name,verts,faces,color)
def build():
    # Foundation and plaster panels: all geometry stays in frozen off-lane envelope.
    for course in range(3):
        for j in range(6):
            x=426+j*4
            for z in (1459,1477):box('masonry',f'house_course_{course}_{j}_{z}',[x,2.5+course, z],[3.82,.94,1.2],1+(j+course)%3)
        for x in (425.5,446.5):
            for j,z in enumerate((1461,1465,1469,1473,1475.5)):
                box('masonry',f'plinth_end_{x}_{course}_{j}',[x,2.5+course,z],[1.2,.94,3.85 if j<4 else 1.2],1+(j+course)%3)
    box('house','east_endwall',[446.5,9,1468],[1,10,16],14)
    for z in (1461.5,1474.5):box('house',f'westdoor_panel{z}',[425.5,9,z],[1,10,5],14)
    box('house','westdoor_header',[425.5,13.2,1468],[1,1.6,8],14)
    # The approach-facing loading door is a real separate timber assembly.
    for j in range(8):box('timber',f'loading_door_plank{j}',[424.9,8.7,1464.5+j],[.35,7.2,.92],5+j%2)
    for z in (1464,1472):beam('timber',f'loading_door_jamb{z}',[424.5,4.8,z],[424.5,12.7,z],.5,.55,6)
    beam('timber','loading_door_lintel',[424.5,12.7,1463.8],[424.5,12.7,1472.2],.6,.6,6)
    for y in (6,11):beam('copper',f'door_strap{y}',[424.65,y,1464.7],[424.65,y,1471.3],.08,.18,11)
    beam('timber','door_diagonal',[424.5,5.6,1464.7],[424.5,11.9,1471.3],.25,.28,6)
    box('house','backwall',[436,9,1459],[20,10,1],14)
    # Front opening and two windows expressed as actual gaps, no opaque window painting.
    for x,w in [(427.2,3.4),(436,3.4),(444.8,3.4)]:box('house',f'frontpanel{x}',[x,8,1477],[w,8,1],14)
    for x in (431.6,440.4):
        box('house',f'window_sill{x}',[x,5.5,1477.3],[5,1,1.7],2)
        box('house',f'window_top{x}',[x,12.5,1477],[5,3,1],14)
        box('timber',f'window_dark{x}',[x,8.5,1476.55],[4.8,5,.12],15)
        for dx in (-2.1,0,2.1):box('timber',f'window_bar{x}_{dx}',[x+dx,8.5,1477.6],[.22,5,.4],6)
        box('timber',f'window_cross{x}',[x,8.5,1477.6],[4.6,.22,.4],6)
    for x in (425,436,447):
        for z in (1459,1477):box('timber',f'post{x}_{z}',[x,8.5,z],[.85,13,.85],5)
    for y in (4,13.7):
        for z in (1459,1477):beam('timber',f'longbeam{y}_{z}',[424.7,y,z],[447.3,y,z],.85,.8,6)
    for x in (425,447):
        beam('timber',f'endbrace{x}',[x,4.4,1459.5],[x,13.2,1476.5],.6,.7,5)
        # Original solid gable triangle, split by king post.
        solid('house',f'gable{x}',[[x-.3,14,1458.5],[x-.3,14,1477.5],[x-.3,23,1468],[x+.3,14,1458.5],[x+.3,14,1477.5],[x+.3,23,1468]],[(0,1,2),(3,5,4),(0,3,4,1),(1,4,5,2),(2,5,3,0)],14)
        for z in (1458,1478):beam('timber',f'rafter{x}_{z}',[x,14,z],[x,23.5,1468],.7,.7,5)
        beam('timber',f'king{x}',[x,14,1468],[x,23.4,1468],.65,.65,5)
    # Individually layered slate slabs, real exported colors/geometry.
    for side in (-1,1):
        for row in range(6):
            z0=1468+side*(row*1.7);z1=1468+side*((row+1)*1.7+.15)
            y0=23.3-abs(z0-1468)*.9;y1=23.3-abs(z1-1468)*.9
            for col in range(10):
                x0=423.7+col*2.45;x1=x0+2.5
                v=[[x0,y0,z0],[x1,y0,z0],[x1,y1,z1],[x0,y1,z1]];v+= [[x,y-.3,z] for x,y,z in v]
                solid('slate',f'tile{side}_{row}_{col}',v,BOXF,8+(row+col*2)%3)
    for j in range(10):box('slate',f'ridge{j}',[424.8+j*2.35,23.5,1468],[2.3,.55,1.25],8+j%3)
    box('timber','west_loft_recess',[424.65,17,1468],[.1,3.6,3.6],15)
    for z in (1466.1,1468,1469.9):beam('copper',f'loft_bar{z}',[424.4,15.1,z],[424.4,18.9,z],.16,.16,11)
    for y in (15.1,17,18.9):beam('timber',f'loft_cross{y}',[424.4,y,1466.1],[424.4,y,1469.9],.3,.3,6)
    # Ashlar chimney and copper hood.
    for course in range(10):box('masonry',f'chimney{course}',[428,17.4+course,1463],[2.9,.94,2.8],1+course%3)
    box('copper','chimney_cap',[428,27.1,1463],[3.6,.45,3.5],11)
    # Copper receiving balance on the right facade; no fonts/external texture.
    beam('copper','balance_stand',[443,5.5,1478],[443,12.5,1478],.38,.38,11)
    beam('copper','balance_arm',[440,11.3,1478],[446,11.7,1478],.24,.24,12)
    for x,y in [(440.3,11.3),(445.7,11.7)]:
        cylinder('copper',f'chain{x}',[x,y-1.6,1478],.07,3.1,11,8)
        cylinder('copper',f'pan{x}',[x,y-3.3,1478],.65,.4,12,12,1.05)
    box('timber','counter',[441.8,5.2,1477.9],[9,.6,1.0],6)
    # Ore sorting ledge and original hand tools establish the building's purpose.
    box('timber','sorting_ledge',[431.6,6.1,1477.85],[4.8,.35,1.1],6)
    for j in range(5):rock('ore',f'weigh_sample{j}',[430+j*.7,6.65,1477.8],[.7,.7,.7],15 if j%2 else 11,600+j)
    beam('copper','sorting_tongs',[429.8,6.4,1477.8],[431.5,6.4,1477.8],.1,.1,11)
    for z in (1462.5,1465):
        box('bins',f'house_crate{z}',[447.1,3.15,z],[1.8,2.3,2.0],6)
        for y in (2.3,4):box('copper',f'crate_band{z}_{y}',[447.1,y,z],[1.84,.15,2.04],11)
    # Receiving bays: timber bins, dark ore with warm iron faces.
    for i,cx in enumerate((552,563,572)):
        w=7 if i<2 else 5
        box('bins',f'bin_base{i}',[cx,2.25,1470],[w,.5,11],5)
        for side in (-1,1):
            for course in range(4):box('bins',f'binrail{i}_{side}_{course}',[cx+side*w/2,2.8+course*.8,1470],[.4,.65,11],6)
        box('bins',f'binback{i}',[cx,3.8,1464.7],[w,3.6,.5],5)
        for j in range(7):rock('ore',f'ore{i}_{j}',[cx+random.uniform(-w*.3,w*.3),3.5+random.uniform(0,.9),1467+random.uniform(-1,4)],[2.2,2,2.6],1 if j%2 else 15,500+i*10+j)
    # Cart bay side timbers stay north of arrival lane, no new collision floor.
    for x in (472,484):beam('bins',f'bayrail{x}',[x,2.35,1465],[x,2.35,1479],.5,.5,6)
    for x in (472,484):
        box('timber',f'orehoist_post{x}',[x,7.5,1465],[.8,11,.8],5)
        beam('timber',f'hoist_brace{x}',[x,9.0,1465],[x+(2 if x<480 else -2),12.8,1465],.6,.6,6)
    beam('timber','hoist_lintel',[471.5,13,1465],[484.5,13,1465],1,1,5)
    cylinder('copper','orehoist_chain',[478,10,1465],.09,5.5,11,8)
    box('copper','orehoist_hook',[478,7.2,1465],[.6,.25,.6],11)
    box('bins','cart_orecrate',[482,3,1477],[2.5,2,2.4],6)
    for j in range(3):rock('ore',f'cart_load{j}',[481.5+j*.5,4.2,1477],[.8,.7,.9],1+j%3,650+j)
    # Low retaining courses cover only existing vertical terrace face, never walk surface.
    for start,end in [(391,420),(476,487),(514,609)]:
        for row in range(3):
            x=start+2
            while x<end-2:
                w=min(6.2,end-x);box('retaining',f'frontstone{x}_{row}',[x,2.65+row*1.0,1450.45],[w-.18,.94,.85],1+(int(x)+row)%3);x+=6.4
    # Layered, faceted island bedrock, below the native floor and beyond outer edges.
    for side in (-1,1):
        for j,z in enumerate(range(1303,1503,18)):
            rock('cliff',f'edge{side}_{j}',[500+side*119,-9-(j%3),z],[14,21+(j%3)*2,24],1+j%3,900+j+(0 if side<0 else 50))
    for j,x in enumerate(range(397,612,20)):
        # Leave the existing dock seam/open route clear; all top vertices <=1.7.
        rock('cliff',f'south{j}',[x,-11,1508],[26,25,13],1+j%3,1000+j)
    # Foreground rock terraces sit below floor; no raised rocks in protected yard.
    for j,x in enumerate(range(405,610,22)):
        if 480<x<520:continue
        rock('cliff',f'north{j}',[x,-10,1292],[27,23,14],1+j%3,1100+j)
    # Visible stratified mine shoulders mask the old rectangular wall silhouette.
    # Every root reaches the native Island floor even where upper terraces end.
    for side in (-1,1):
        for j,z in enumerate((1309,1330,1351,1372,1393,1414,1435)):
            height=(26,33,28,36,30,34,25)[j];x=396 if side<0 else 604
            before=len(solids)
            rock('ridges',f'quarry_ridge{side}_{j}',[x,1.8+height/2,z],[18,height,29],1+j%3,1700+j+(50 if side>0 else 0))
            # Actual face palette changes follow strata, not Blender-only shaders.
            rec=solids[before];m=next(m for m in meshes if m['id']==rec['meshId'])
            for face in range(rec['firstTriangle']-1,rec['firstTriangle']-1+rec['triangleCount']):
                m['faceColors'][face]=[1,2,3,4][((face-rec['firstTriangle'])//4+j)%4]
    source=json.loads(SOURCE.read_text());wanted=['cart__000','cart__001','silhouette_ruined_waymarker__000'];reused=[m for m in source['meshes'] if m['id'] in wanted]
    placements=[]
    for m in meshes:
        m['bounds']={key:[fn(v[k] for v in m['vertices']) for k in range(3)] for key,fn in [('min',min),('max',max)]}
        placements.append(dict(name=m['id'],meshId=m['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    meshes.extend(reused)
    for mid,x,z,scale,yaw in [('cart__000',478,1471,.9,0),('cart__001',478,1471,.9,0),('silhouette_ruined_waymarker__000',518,1480,.65,.25)]:
        c,s=math.cos(yaw),math.sin(yaw);placements.append(dict(name='Reviewed_'+mid,meshId=mid,cframe=[x,2,z,c,0,s,0,1,0,-s,0,c],scale=[scale]*3,collision=False,query=False,touch=False))
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=meshes,placements=placements,runtimeIds=None,runtimeImported=False,compositionOnly=True)
    OUT.mkdir(parents=True,exist_ok=True)
    def write(name,data):(OUT/name).write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    write('scenery.mesh.json',packet);write('solids.json',solids)
    write('metrics.json',dict(resources=len(meshes),originalResources=len(meshes)-len(reused),placements=len(placements),uniqueTriangles=sum(len(m['triangles']) for m in meshes),instancedTriangles=sum(len(next(m for m in meshes if m['id']==p['meshId'])['triangles']) for p in placements),originalSolids=len(solids)))
    sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    write('provenance.json',dict(status='FILE_GENERATED_NOT_STUDIO',originalRecipe=Path(__file__).relative_to(ROOT).as_posix(),recipeSha256=sha(Path(__file__)),reviewedSource=SOURCE.relative_to(ROOT).as_posix(),reviewedSourceSha256=sha(SOURCE),reviewedMeshIds=wanted,licenses=['assets/production/world-slice/village-LICENSE.txt','assets/production/world-slice/ruins-LICENSE.txt'],sourceSurveySha256=sha(HERE/'source-survey.json'),runtimeIds=None,notes=['All visual materials are exported vertex face colors; no external textures/fonts.','Decorative noncollision package, no navigation/gameplay activation.','Bedrock skirt does not create walkable floor.']))
    print(json.dumps(json.loads((OUT/'metrics.json').read_text()),indent=2))
if __name__=='__main__':build()
