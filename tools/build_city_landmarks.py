"""Original modular city landmarks: common JSON source for Roblox and Blender."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/city-landmarks';OUT.mkdir(parents=True,exist_ok=True)
P={'ivory':[235,225,202],'stone':[155,159,155],'basalt':[65,73,81],'wood':[128,82,53],
   'redwood':[114,63,42],'burgundy':[135,53,64],'emerald':[46,119,84],'copper':[180,113,64],
   'indigo':[61,64,123],'teal':[49,130,138],'ochre':[211,156,62],'gold':[220,184,101],
   'cyan':[88,201,214],'amber':[241,147,58],'leaf':[74,140,88]}
assets=[]
def asset(id,city,name,width,depth):
 a=dict(id=id,city=city,name=name,footprint=[width,depth],parts=[],runtimeBound=False,entryRoute=dict(x=0,fromZ=depth/2+4,toZ=0,width=4,height=5,floorY=1))
 assets.append(a);return a
def part(a,n,s,p,c,rot=(0,0,0),collide=True):
 a['parts'].append(dict(name=n,size=s,position=p,color=c,rotation=list(rot),collide=collide,shape='Block'))
def base(a):
 w,d=a['footprint'];part(a,'Foundation',[w,1,d],[0,.5,0],'stone')
 for x in (-w/2+1,w/2-1):part(a,'SideBorder',[.5,.2,d-2],[x,1.1,0],'gold',collide=False)
def gable(a,w,d,y,color):
 # Two shallow pitched panels; actual rotation is shared between native/mesh exports.
 for sign in (-1,1):part(a,'RoofSlope',[w*.54,1,d],[sign*w*.24,y,0],color,(0,0,-sign*24))
def beam(a,n,p,q,width,color,collide=False):
 dx,dy,dz=[q[i]-p[i] for i in range(3)];length=math.sqrt(dx*dx+dy*dy+dz*dz)
 assert abs(dz)<1e-8
 part(a,n,[width,length,width],[(p[i]+q[i])/2 for i in range(3)],color,(0,0,-math.degrees(math.atan2(dx,dy))),collide)
def ring(a,n,r,y,z,color,segments=12,tilt=0):
 # Horizontal polygonal ring, rendered as a sequence of small straight beams.
 for i in range(segments):
  t=(i+.5)*math.tau/segments
  part(a,n,[r*2*math.sin(math.pi/segments)+.15,.55,.65],[r*math.sin(t),y+tilt*math.cos(t),z+r*math.cos(t)],color,(0,math.degrees(t),0),False)

a=asset('crownford_clock_gate','Crownford','Clock Gate',32,22);base(a)
for x in (-10,10):
 part(a,'GatePier',[7,20,8],[x,11,0],'ivory');part(a,'PierFoot',[8,1.4,9],[x,1.7,0],'stone')
 part(a,'PierCap',[8,1,9],[x,21,0],'gold')
 part(a,'Turret',[5,6,6],[x,24.5,0],'ivory');part(a,'TurretRoof',[6,2,7],[x,28.5,0],'burgundy')
 part(a,'Banner',[2.6,7,.35],[x,15,4.3],'burgundy',collide=False)
part(a,'ArchBeam',[28,5,8],[0,19,0],'ivory')
part(a,'ClockHouse',[11,11,8],[0,26.5,0],'ivory');part(a,'ClockRoof',[13,2,10],[0,33,0],'burgundy')
part(a,'ClockFace',[7,7,.35],[0,27,4.3],'gold',collide=False)
part(a,'ClockDial',[6.2,6.2,.35],[0,27,4.55],'ivory',collide=False)
for i in range(12):
 t=i*math.tau/12;part(a,'ClockTick',[.3,.7,.2],[2.5*math.sin(t),27+2.5*math.cos(t),4.8],'basalt',(0,0,-math.degrees(t)),False)
part(a,'ClockHand',[.28,2.3,.25],[0,27.9,5],'basalt',collide=False)
part(a,'ClockHand',[1.8,.28,.25],[.75,27,5.05],'basalt',collide=False)

a=asset('sylvaris_council_tree','Sylvaris','Council Tree Pavilion',38,34);base(a)
part(a,'LivingTrunk',[5,26,5],[0,14,-9],'wood')
for x in (-13,13):
 for z in (-11,11):part(a,'CarvedColumn',[1.6,16,1.6],[x,9,z],'ivory');part(a,'ColumnCapital',[3,1,3],[x,17,z],'gold')
for x in (-13,13):part(a,'SideBeam',[1.5,1.4,25],[x,17.8,0],'ivory')
part(a,'FrontBeam',[28,1.5,1.5],[0,17.8,11],'ivory');part(a,'BackBeam',[28,1.5,1.5],[0,17.8,-11],'ivory')
for sign in (-1,1):
 beam(a,'TreeBough',[0,17,-9],[sign*10,27,-9],2,'wood')
 part(a,'LeafCanopy',[17,4,15],[sign*7,29,-8],'emerald',(0,0,sign*9),False)
 part(a,'LeafCrown',[12,4,11],[sign*5,32,-8],'leaf',collide=False)
 for z in (-5,6):part(a,'CouncilBench',[3,2,8],[sign*11,2,z],'wood')
part(a,'CouncilLectern',[5,3,3],[0,2.5,-5],'ivory')
for x in (-13,13):part(a,'AmberLamp',[1.5,2,1.5],[x,14,11],'amber',collide=False)

a=asset('deepforge_grand_forge','Deepforge','Grand Forge',40,34);base(a)
for x in (-15,15):
 part(a,'ForgePier',[5,19,5],[x,10.5,10],'basalt');part(a,'CopperPierBand',[5.5,1,5.5],[x,13,10],'copper')
 part(a,'SideWall',[3,14,25],[x,8,-2],'basalt');part(a,'Chimney',[5,31,6],[x,16.5,-10],'basalt')
 part(a,'ChimneyCap',[6,1.5,7],[x,32.5,-10],'copper')
part(a,'ForgeLintel',[34,4,5],[0,22,10],'basalt')
gable(a,37,29,25,'copper')
part(a,'BackWall',[28,17,3],[0,9.5,-14],'basalt')
part(a,'HearthGlow',[10,10,.4],[0,7,-12.3],'amber',collide=False)
for x in (-7,7):part(a,'HearthJamb',[3,13,4],[x,7.5,-10.5],'stone')
part(a,'HearthLintel',[17,3,4],[0,15,-10.5],'stone')
part(a,'AnvilFoot',[7,2,5],[0,2,-6],'basalt');part(a,'AnvilBody',[5,3,3],[0,4.5,-6],'stone');part(a,'AnvilTop',[9,1,4],[0,6.5,-6],'basalt')
for x in (-10,10):part(a,'ForgeBanner',[2,7,.3],[x,17,12.7],'copper',collide=False)

a=asset('astralis_observatory','Astralis','Crystal Observatory',38,34);base(a)
for x in (-12,12):
 for z in (-11,11):
  part(a,'ObservatoryColumn',[2.5,19,2.5],[x,10.5,z],'indigo');part(a,'ColumnCapital',[4,1,4],[x,20.5,z],'gold')
for x in (-12,12):part(a,'RoofSide',[3,2,26],[x,22,0],'indigo')
for z in (-11,11):part(a,'RoofCross',[27,2,3],[0,22,z],'indigo')
part(a,'RoofDeck',[27,1,26],[0,23,0],'indigo')
part(a,'Crystal',[7,10,7],[0,31,0],'cyan',(0,0,45),False)
ring(a,'Orbit',11,30,0,'gold');ring(a,'UpperOrbit',7,37,0,'gold')
for x in (-12,12):part(a,'CyanFinial',[2,5,2],[x,25,11],'cyan',(0,0,35),False)
part(a,'ChartTable',[8,3,5],[0,2.5,-7],'indigo');part(a,'ChartInlay',[7,.15,4],[0,4.1,-7],'cyan',collide=False)

a=asset('crosshaven_charter_pavilion','Crosshaven','Charter Pavilion',38,34);base(a)
for x in (-12,12):
 for z in (-11,11):part(a,'CivicColumn',[2,15,2],[x,8.5,z],'ivory');part(a,'ColumnCapital',[3.5,1,3.5],[x,16,z],'copper')
for x in (-12,12):part(a,'SideCornice',[2,2,26],[x,17,0],'ivory')
for z in (-11,11):part(a,'FrontCornice',[27,2,2],[0,17,z],'ivory')
for width,y in ((31,19),(25,21),(19,23),(12,25),(6,27)):part(a,'TieredRoof',[width,2,width*.85],[0,y,0],'teal')
part(a,'CivicSpire',[1.2,7,1.2],[0,31.5,0],'copper')
for i,color in enumerate(('burgundy','emerald','copper','indigo','teal','ochre')):
 x=-10+i*4;part(a,'CivicBanner',[2.1,4,.2],[x,13.5,11.8],color,collide=False)
part(a,'CharterPlinth',[7,3,4],[0,2.5,-6],'ivory');part(a,'CharterBook',[5,.4,3],[0,4.2,-6],'gold',(8,0,0),False)

a=asset('ironroot_feast_hall','Ironroot','Welcome Feast Hall',42,36);base(a)
for x in (-15,15):
 for z in (-12,12):part(a,'FeastPost',[2.5,17,2.5],[x,9.5,z],'redwood');part(a,'PostBinding',[2.8,.7,2.8],[x,12,z],'gold',collide=False)
for x in (-15,15):part(a,'SideBeam',[2,2,29],[x,19,0],'redwood')
for z in (-12,12):part(a,'FeastLintel',[33,2,2],[0,19,z],'redwood')
gable(a,38,32,23,'ochre')
for sign in (-1,1):
 beam(a,'CarvedWelcome',[sign*15,20,13],[sign*10,28,13],1.2,'redwood')
 for z in (-8,1):part(a,'SideBench',[4,2,8],[sign*12,2,z],'redwood')
part(a,'FeastTable',[14,3,6],[0,2.5,-8],'redwood');part(a,'TableRunner',[3,.1,5.5],[0,4.05,-8],'emerald',collide=False)
for x in (-10,10):
 part(a,'WelcomeBanner',[3,6,.2],[x,15,13.2],'emerald',collide=False)
 part(a,'BannerDiamond',[1.2,1.2,.3],[x,15,13.4],'ochre',(0,0,45),False)

for a in assets:
 assert len(a['parts'])<100
 for p in a['parts']:
  assert all(v>0 for v in p['size']) and p['color'] in P
  assert all(math.isfinite(v) for key in ('size','position','rotation') for v in p[key])
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',palette=P,assets=assets),indent=2)+'\n',encoding='utf-8')
vec=lambda v:'Vector3.new('+','.join(str(round(n,6)) for n in v)+')'
lines=['--!strict','-- Generated by tools/build_city_landmarks.py. Review models; no gameplay or purchase hooks.','return function():Folder','local folder=Instance.new("Folder");folder.Name="CityLandmarkKit"']
for a in assets:
 lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m.Parent=folder',
         'm:SetAttribute("CityIdentity",'+json.dumps(a['city'])+');m:SetAttribute("EntryWidth",4);m:SetAttribute("FootprintDepth",'+str(a['footprint'][1])+')']
 for p in a['parts']:
  rotation=','.join('math.rad('+str(round(n,6))+')' for n in p['rotation'])
  lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+vec(p['size'])+';p.CFrame=CFrame.new('+vec(p['position'])+')*CFrame.Angles('+rotation+');p.Color=Color3.fromRGB('+','.join(map(str,P[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide='+str(p['collide']).lower()+';p.CanQuery='+str(p['collide']).lower()+';p.CanTouch=false;p.Parent=m end']
 lines+=['end']
lines+=['return folder','end']
(ROOT/'review/CityLandmarkKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('CITY_LANDMARKS',len(assets),'models',sum(len(a['parts']) for a in assets),'parts')
