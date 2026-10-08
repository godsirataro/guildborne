"""Five city-specific modular roof/facade studies over the verified service footprint."""
from pathlib import Path
import copy,json,math
R=Path(__file__).resolve().parents[1];base=json.loads((R/'assets/uat01/crownford-services-v1/kit.json').read_text())
profiles={
 'Sylvaris':{'stone':[227,230,191],'trim':[172,157,89],'wood':[98,96,58],'plank':[144,129,84],'roof':[45,115,79],'roofLight':[67,137,90],'brass':[205,183,96],'glass':[134,186,152]},
 'Deepforge':{'stone':[83,89,96],'trim':[121,128,132],'wood':[57,56,55],'plank':[98,75,55],'roof':[149,87,46],'roofLight':[176,106,54],'brass':[205,135,72],'glass':[235,155,78]},
 'Astralis':{'stone':[116,123,157],'trim':[184,192,209],'wood':[60,61,103],'plank':[98,94,128],'roof':[59,71,145],'roofLight':[78,89,174],'brass':[181,158,86],'glass':[104,208,223]},
 'Crosshaven':{'stone':[229,218,184],'trim':[186,165,115],'wood':[90,74,61],'plank':[142,108,73],'roof':[36,116,123],'roofLight':[57,142,145],'brass':[200,158,75],'glass':[124,184,192]},
 'Ironroot':{'stone':[130,98,68],'trim':[190,142,73],'wood':[86,53,37],'plank':[139,91,51],'roof':[190,130,60],'roofLight':[215,155,75],'brass':[220,180,102],'glass':[150,180,116]},
}
old={'stone':[228,213,179],'trim':[183,159,114],'wood':[89,58,45],'plank':[133,91,62],'roof':[129,46,57],'roofLight':[153,57,68],'brass':[193,148,68],'glass':[96,154,165]}
remove={'RoofTileBand','Eave','Ridge','FrontGableRafter','RearGableRafter','GablePost','GableKing','GableBrace','FrontTie','Chimney','ChimneyCap','ExchangeCoin'}
result={}
for city,palette in profiles.items():
 buildings=copy.deepcopy(base['buildings']);mapping={tuple(old[k]):v for k,v in palette.items()}
 for kind,b in buildings.items():
  parts=b['parts']=[p for p in b['parts']if p['name']not in remove]
  for p in parts:p['color']=mapping.get(tuple(p['color']),p['color'])
  def add(name,pos,size,mat='trim',rotation=(0,0,0),shape='Block'):
   parts.append(dict(name=name,position=list(pos),size=list(size),color=palette.get(mat,mat if isinstance(mat,list)else[228,218,182]),collision=False,rotation=list(rotation),shape=shape))
  def beam(name,a,z,width=.4,mat='trim',shape='Block'):
   dx,dy,dz=[z[i]-a[i]for i in range(3)];assert abs(dx)<1e-9 or abs(dz)<1e-9
   rot=(math.degrees(math.atan2(dz,dy)),0,0) if abs(dx)<1e-9 else(0,0,-math.degrees(math.atan2(dx,dy)))
   length=math.sqrt(dx*dx+dy*dy+dz*dz)+(width if shape=='Ball'else 0)
   add(name,[(a[i]+z[i])/2 for i in range(3)],[width,length,width],mat,rot,shape)
  def roof(points):
   for side in [-1,1]:
    for i,(a,z)in enumerate(zip(points,points[1:])):
     dx=z[0]-a[0];dy=z[1]-a[1];length=math.hypot(dx,dy);angle=math.degrees(math.atan2(side*dy,dx))
     add('ProfileRoof', (side*(a[0]+z[0])/2,(a[1]+z[1])/2,0),(length+.1,.4,26.5),'roofLight'if i%2 else'roof',(0,0,angle))
     for depth in [-13.4,13.4]:beam('RoofRib',(side*a[0],a[1]+.25,depth),(side*z[0],z[1]+.25,depth),.4,'trim')
   add('Ridge',(0,points[0][1]+.25,0),(.6,.45,27),'brass')
  if city=='Sylvaris':
   roof([(0,20),(4,18.7),(8,17),(12,16),(15,16.2),(18,17.8)])
   for side in [-1,1]:
    beam('LivingColumn',(side*14,0,12.4),(side*14,12.8,12.4),.65,'stone',shape='Ball')
    for tip in [(side*18,17.8,12.4),(side*8,17,12.4),(0,20,12.4)]:beam('BranchArc',(side*14,10.5,12.4),tip,.4,'trim',shape='Ball')
    for depth in [-9,9]:
     add('RoofLeaf',(side*15.7,17.2,depth),(2.5,1.1,6.8),'roofLight',(0,side*18,side*15),'Ball')
    for x in [side*9.5]:
     beam('LancetLeft',(x-1.9,8.6,12.25),(x,11.3,12.25),.18,'brass')
     beam('LancetRight',(x+1.9,8.6,12.25),(x,11.3,12.25),.18,'brass')
   add('LeafCrest',(0,22.1,12.5),(1.8,5.2,.55),'brass',(0,0,16),'Ball')
   add('LeafVein',(0,22.1,12.83),(.13,4.9,.13),'stone',(0,0,16))
  elif city=='Deepforge':
   roof([(0,18.5),(4,17.1),(8,15.7),(12,14.3),(16,12.9)])
   for side in [-1,1]:
    add('FoundryButtress',(side*15.6,5.5,9),(2.2,11,3),'stone')
    add('FoundryCap',(side*15.6,11.3,9),(2.8,.7,3.6),'trim')
    for y in [2,5,8]:add('IronBand',(side*15.6,y,9),(2.3,.45,3.1),'wood')
    add('ExhaustStack',(side*10,19,-7),(3,13,3),'stone')
    for y in [17,21,25]:add('StackCollar',(side*10,y,-7),(3.6,.6,3.6),'roofLight')
    for y in [2,4,6,8]:add('DoorRivet',(side*4.45,y,12.9),(.22,.22,.15),'brass',shape='Ball')
   for y in range(13,18):add('StoneGable',(0,y,12.0),(max(2,30-(y-12)*5),1,.4),'stone')
   beam('CrossedTool',(-1.3,14.5,12.95),(1.3,16.7,12.95),.25,'brass')
   beam('CrossedTool',(1.3,14.5,12.95),(-1.3,16.7,12.95),.25,'brass')
  elif city=='Astralis':
   roof([(0,23),(4,20.3),(8,17.5),(12,14.5),(16,12.8)])
   for side in [-1,1]:
    add('ObservatoryTurret',(side*14,15,10),(7,2.6,2.6),'stone',(0,0,90),'Cylinder')
    for layer in range(8):
     diameter=3.8*(1-layer/8)
     add('TurretSpire',(side*14,19+layer*.65,10),(.7,diameter,diameter),'roofLight',(0,0,90),'Cylinder')
    add('SpireStar',(side*14,24.4,10),(.8,.8,.8),'glass',(0,0,45))
    beam('AstralButtress',(side*15.2,1,11),(side*17,10,11),.65,'trim')
   for angle in [0,45,90,135]:add('CompassStar',(0,16.1,12.85),(.22,3.2,.2),'brass',(0,0,angle))
   add('StarCore',(0,16.1,13),(1.0,1.0,.3),'glass',(0,0,45))
  elif city=='Crosshaven':
   for layer in range(12):
    u=(layer+.5)/12;r=math.sqrt(1-u*u)
    add('HarborDome',(0,12.4+u*6,0),(.57,32*r,26.5*r),'roofLight'if layer%3==0 else'roof',(0,0,90),'Cylinder')
   add('DomeFinial',(0,19.5,0),(.65,2.2,.65),'brass',shape='Ball')
   for side in [-1,1]:
    add('ArcadeColumn',(side*4.55,5.4,12.7),(10.2,.8,.8),'stone',(0,0,90),'Cylinder')
    for y in [.6,10.7]:add('ColumnCapital',(side*4.55,y,12.7),(1.5,.5,1.5),'trim')
    add('HarborBanner',(side*13.5,7.2,12.8),(1.7,4,.16),'roof')
    for y in [6.2,7.2,8.2]:add('BannerWave',(side*13.5,y,12.91),(1.3,.13,.12),'brass',(0,0,side*12))
   for angle in range(0,180,30):add('ShipWheel',(0,14.8,13),(.14,2.3,.14),'brass',(0,0,angle))
  else:
   roof([(0,19.5),(4,17),(8,14.9),(12,14.6),(17,16)])
   for side in [-1,1]:
    add('HearthTimber',(side*14.7,6.5,11.5),(1.2,13,1.2),'wood')
    for y in [3,8,12]:add('TimberBinding',(side*14.7,y,11.5),(1.35,.4,1.35),'brass')
    points=[(side*16,16,13.3),(side*18.2,17.2,13.3),(side*19.3,19.3,13.3),(side*18.8,21.5,13.3)]
    for i,(a,z)in enumerate(zip(points,points[1:])):beam('WelcomeHorn',a,z,1.1-i*.30,'brass',shape='Ball')
   for angle in [-35,35]:add('HearthEmblem',(0,15.3,12.95),(.55,2.7,.3),'brass',(0,0,angle))
  if kind=='Tavern'and city not in ['Deepforge','Crosshaven','Astralis']:
   add('KitchenFlue',(10,18,-7),(2.3,9,2.3),'stone');add('KitchenFlueCap',(10,22.7,-7),(3,.4,3),'trim')
  b['identity']=city+' '+kind+' architectural study';b['sharedFootprint']=True
 result[city]=buildings
 out=R/'assets/uat01'/f'{city.lower()}-services-v1';out.mkdir(parents=True,exist_ok=True)
 (out/'kit.json').write_text(json.dumps({**base,'city':city,'buildings':buildings},indent=2)+'\n')
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x)for k,x in v.items())+'}'
 if isinstance(v,(tuple,list)):return '{'+','.join(lua(x)for x in v)+'}'
 if isinstance(v,bool):return 'true'if v else'false'
 return json.dumps(v)
(R/'src/shared/Presentation/CivicServiceArchitecture.luau').write_text('--!strict\n-- Generated by tools/build_civic_service_variants.py.\nreturn '+lua(result)+'\n')
print('CIVIC_VARIANTS', {city:{kind:len(b['parts'])for kind,b in buildings.items()}for city,buildings in result.items()})
