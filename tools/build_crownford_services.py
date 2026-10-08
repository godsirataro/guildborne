"""Author shared Blender/Roblox architectural geometry in Roblox stud coordinates."""
from pathlib import Path
import json,math
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/crownford-services-v1';O.mkdir(parents=True,exist_ok=True)
colors={'stone':[228,213,179],'trim':[183,159,114],'wood':[89,58,45],'plank':[133,91,62],'roof':[129,46,57],'roofLight':[153,57,68],'brass':[193,148,68],'glass':[96,154,165],'cream':[243,229,194],'leaf':[68,113,71],'apple':[173,69,54],'grain':[210,177,104],'iron':[52,60,65],'warm':[255,187,91],'ember':[220,96,42]}
buildings={}
for kind in ['Market','Tavern']:
 parts=[]
 def add(name,p,s,material,collision=False,rotation=(0,0,0),shape='Block'):
  parts.append(dict(name=name,position=p,size=s,color=colors[material],collision=collision,rotation=rotation,shape=shape))
 def beam(name,a,b,width,mat='wood'):
  # All braces are in XY (front) or YZ planes; Roblox XYZ Euler angles.
  a=list(a);b=list(b);dx,dy,dz=[b[i]-a[i]for i in range(3)];length=math.sqrt(dx*dx+dy*dy+dz*dz)
  assert abs(dx)<1e-9 or abs(dz)<1e-9
  rotation=(math.degrees(math.atan2(dz,dy)),0,0) if abs(dx)<1e-9 else (0,0,-math.degrees(math.atan2(dx,dy)))
  add(name,[(a[i]+b[i])/2 for i in range(3)],[width,length,width],mat,False,rotation)
 add('Floor',(0,.15,0),(30,.3,24),'stone',True)
 add('Rear',(0,6,-11.5),(30,12,1),'stone',True)
 for side in [-1,1]:
  add('Side',(side*14.5,6,0),(1,12,24),'stone',True)
  add('FrontWing',(side*9.5,6,11.5),(11,12,1),'stone',True)
  add('DoorJamb',(side*4.4,5.2,12.15),(.8,10.4,1.3),'trim',True)
  for z in [-11.7,11.7]:
   add('CornerPier',(side*14.65,6,z),(1.1,12,1.1),'trim')
   for y in [1,3.4,5.8,8.2,10.6]:add('Quoin',(side*14.75,y,z),(1.45,.65,1.45),'stone')
  for z in [-6,4]:
   add('SideWindow',(side*15.03,6.8,z),(.08,3.6,3.2),'glass')
   for dz in [-1.8,0,1.8]:add('WindowMullion',(side*15.12,6.8,z+dz),(.18,4,.16),'wood')
   for y in [4.8,8.8]:add('WindowRail',(side*15.12,y,z),(.18,.2,3.8),'wood')
  add('FrontWindow',(side*9.5,6.7,12.03),(3.6,3.4,.08),'glass')
  for dx in [-1.95,0,1.95]:add('FrontMullion',(side*9.5+dx,6.7,12.12),(.18,3.8,.18),'wood')
  for y in [4.8,8.6]:add('FrontWindowRail',(side*9.5,y,12.12),(4.1,.2,.18),'wood')
  add('Planter',(side*9.5,4.4,12.65),(4.3,.6,1.3),'plank')
  for x in [-1.4,0,1.4]:add('PlanterLeaf',(side*9.5+x,4.9,12.6),(.95,.75,.8),'leaf',shape='Ball')
 add('DoorLintel',(0,11.2,11.5),(8,1.6,1),'stone',True)
 add('DoorHeader',(0,10.65,12.2),(9.7,.7,1.3),'trim')
 # Eight stud door, ten stud clearance, no door collision or step above .3 studs.
 for y in [.65,10.7,12.1]:
  add('FrontCourse',(0,y,12.3),(30.8,.3,.45),'trim') if y>10 else None
  add('RearCourse',(0,y,-12.2),(30.8,.3,.4),'trim')
  for side in [-1,1]:add('SideCourse',(side*15.2,y,0),(.4,.3,24.8),'trim')
 for x in [-13,-6,6,13]:
  add('GablePost',(x,13.1,12.05),(.35,2,.35),'wood')
 # Roof slab split across ridge; roof tile bands create readable silhouette.
 rise=6;half=16.3;angle=math.degrees(math.atan2(rise,half));length=math.hypot(rise,half)
 for side in [-1,1]:
  for row in range(7):
   u=(row+.5)/7;x=side*half*u;y=18-rise*u
   add('RoofTileBand',(x,y,0),(length/7+.16,.36,26.6),'roof'if row%2 else'roofLight',False,(0,0,-side*angle))
  beam('FrontGableRafter',(0,18.2,13.35),(side*16.4,12.1,13.35),.48)
  beam('RearGableRafter',(0,18.2,-13.35),(side*16.4,12.1,-13.35),.48)
  # Broad raised eaves and ornamental support braces.
  add('Eave',(side*16.4,12.05,0),(.48,.65,27.2),'wood')
  for z in [-10,0,10]:beam('EaveBracket',(side*14.9,10.5,z),(side*16.3,12.2,z),.3)
 add('Ridge',(0,18.22,0),(.6,.45,27.2),'brass')
 add('FrontTie',(0,12.55,12.25),(30,.4,.45),'wood')
 beam('GableKing',(0,12.5,12.25),(0,17.7,12.25),.45)
 for side in [-1,1]:beam('GableBrace',(side*10,12.5,12.25),(0,17.7,12.25),.4)
 # Open roof gable is intentionally timber lattice; ceiling hides attic from inside.
 add('Ceiling',(0,12.15,0),(28,.25,22),'plank')
 for x in range(-13,14,2):add('FloorBoard',(x,.32,0),(1.94,.04,22.5),'plank'if x%4==1 else'wood')
 for z in [-8,0,8]:add('CeilingBeam',(0,11.65,z),(28,.65,.7),'wood')
 for side in [-1,1]:
  add('InteriorWainscot',(side*13.94,1.65,0),(.12,2.7,21.9),'plank')
  add('InteriorChairRail',(side*13.8,3.05,0),(.4,.2,22),'wood')
  for z in range(-10,11,2):add('WainscotStile',(side*13.8,1.65,z),(.22,2.7,.16),'wood')
 for z in [-3,7]:
  add('LanternChain',(0,10.2,z),(.12,2.3,.12),'iron')
  add('LanternGlass',(0,8.65,z),(.85,1.2,.85),'warm')
  for y in [7.95,9.35]:add('LanternCap',(0,y,z),(1.1,.2,1.1),'iron')
  for x in [-.5,.5]:
   for dz in [-.5,.5]:add('LanternBar',(x,8.65,z+dz),(.1,1.4,.1),'iron')
 add('Counter',(0,1.75,-7),(16,3.5,3),'plank',True)
 add('Countertop',(0,3.65,-7),(16.8,.3,3.6),'wood',True)
 for x in [-7,-3.5,0,3.5,7]:add('CounterStile',(x,1.8,-5.45),(.25,3.4,.18),'wood')
 # Continuous central aisle +/-4 studs; furniture stays outside it.
 for side in [-1,1]:
  if kind=='Tavern'and side==1:continue
  for dx in [-3,3]:add('ShelfPost',(side*10+dx,4,-9),(.4,7.4,.4),'wood')
  for y in [2,4.5,7]:
   add('Shelf',(side*10,y,-9),(7,.25,2.2),'plank')
   for dx in [-2.1,0,2.1]:
    add('StockJar',(side*10+dx,y+.8,-9),(1.15,1.4,1.05),'glass'if dx==0 else'grain',shape='Ball')
    add('JarLid',(side*10+dx,y+1.52,-9),(.55,.2,.55),'wood')
    add('JarLabel',(side*10+dx,y+.85,-8.48),(.48,.4,.08),'cream')
 if kind=='Market':
  # Crimson and cream canopy; not over the door opening.
  for side in [-1,1]:
   for stripe in range(5):
    add('AwningStripe',(side*9.7+(stripe-2)*1.6,9.6,14.0),(1.6,.16,4),'roof'if stripe%2==0 else'cream',False,(14,0,0))
   for x in [side*6.1,side*13.3]:add('AwningPost',(x,4.8,15.5),(.25,9.6,.25),'wood',True)
   for z in [-2,3]:
    add('ProduceBin',(side*10,1.55,z),(5,3.1,3.4),'plank',True)
    for dx in [-1.5,0,1.5]:
     for dz in [-.8,.8]:add('Produce',(side*10+dx,3.25,z+dz),(1.1,.8,1),'apple'if z<0 else'grain',shape='Ball')
  add('Signboard',(0,14.8,12.65),(5.8,2.4,.3),'roof')
  for x in [-1,1]:add('ExchangeCoin',(x,14.8,12.9),(1.25,1.25,.14),'brass',shape='Ball')
 else:
  add('HearthBack',(10,3.15,-10.85),(5,5.7,.25),'iron')
  for x in [6.9,13.1]:add('HearthPillar',(x,3,-10.25),(1.1,5.4,2.5),'trim',True)
  add('HearthLintel',(10,5.9,-10.25),(7.3,.65,2.5),'trim',True)
  add('HearthMantel',(10,6.4,-10.25),(8,.35,2.9),'wood')
  add('HearthHood',(10,8.6,-10.7),(5.5,4.1,1.3),'stone')
  for x in [8.7,10,11.3]:
   add('HearthLog',(x,1.5,-9.9),(.75,.7,1.5),'wood')
   add('HearthEmber',(x,1.85,-9.7),(.7,.45,.65),'ember',shape='Ball')
  for side in [-1,1]:
   for z in [-1,5]:
    add('DiningTable',(side*9.5,2.65,z),(5,.4,3.2),'plank',True)
    for dx in [-1.8,1.8]:add('TableLeg',(side*9.5+dx,1.35,z),(.45,2.7,2.4),'wood',True)
    for dz in [-2,2]:
     add('Bench',(side*9.5,1.25,z+dz),(5,.5,1.0),'wood',True)
     for dx in [-1.8,1.8]:add('BenchSupport',(side*9.5+dx,.6,z+dz),(.4,1.2,.8),'wood',True)
    add('BreadPlate',(side*9.5,2.95,z),(1.2,.15,.9),'cream',shape='Ball')
    add('Bread',(side*9.5,3.15,z),(.95,.35,.6),'grain',shape='Ball')
  add('Chimney',(10,17,-7),(3,10,3),'stone')
  add('ChimneyCap',(10,22.1,-7),(3.8,.55,3.8),'trim')
  add('SignBracket',(-5.3,11.1,14.3),(.3,.3,4),'iron')
  add('TavernSign',(-5.3,9.3,15.6),(3.6,2.8,.45),'roof')
  add('MugSymbol',(-5.3,9.3,15.9),(1.25,1.5,.15),'cream')
  add('MugHandle',(-4.45,9.3,15.9),(.45,.8,.14),'brass')
 buildings[kind]=dict(parts=parts,doorWidth=8,doorClearance=10,floorStep=.3,mainAisleWidth=8,footprint=[30,24],visualOnlyRoof=True)
d=dict(version=1,city='Crownford',reference='assets/uat01/generated/guildborne-city-identities-v1.png',coordinates='Roblox studs X right Y up Z front',buildings=buildings,platformAssetIds=[],approval='Local architectural study; final likeness and in-game acceptance pending')
(O/'kit.json').write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8')
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(tuple,list)):return '{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,bool):return 'true'if v else'false'
 return json.dumps(v)
(R/'src/shared/Presentation/CrownfordArchitecture.luau').write_text('--!strict\n-- Generated by tools/build_crownford_services.py; local architecture, not gameplay authority.\nreturn '+lua(buildings)+'\n',encoding='utf-8')
print('CROWNFORD_ARCHITECTURE', {k:len(v['parts'])for k,v in buildings.items()})
