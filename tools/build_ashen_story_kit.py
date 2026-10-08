"""Original Ashen Chapter03 prototypes; no campaign activation or imported IDs."""
from pathlib import Path
import json, math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/ashen-story-kit';OUT.mkdir(parents=True,exist_ok=True)
palette={'ivory':[210,203,186],'ash':[82,77,94],'dark':[44,42,58],'wood':[114,79,65],'copper':[185,121,73],'teal':[73,192,183],'violet':[157,124,201],'amber':[239,181,84]}
assets=[]
def box(a,name,size,pos,color,rotation=None,solid=True):
 a['parts'].append(dict(name=name,size=size,position=pos,color=color,rotation=rotation or [0,0,0],solid=solid))
def scene(identity,w,d):
 a=dict(id=identity,kind='Chapter03Scene',parts=[],markers=[],footprint=[w,d],aisleWidth=10);assets.append(a)
 box(a,'WalkableFloor',[w,1,d],[0,-.5,0],'ash');return a
def marker(a,name,x,z):a['markers'].append(dict(id=name,position=[x,.15,z]))
def pillar(a,x,z,h=12):
 box(a,'PillarFoot',[3,1,3],[x,.5,z],'ivory');box(a,'RuinedPillar',[2,h,2],[x,1+h/2,z],'ivory');box(a,'CopperBand',[2.2,.3,2.2],[x,h*.7,z],'copper',solid=False)
def lamp(a,x,z):
 box(a,'LanternPost',[.4,6,.4],[x,3,z],'copper');box(a,'LanternFrame',[1.4,2,1.4],[x,6.5,z],'dark');box(a,'LanternGlow',[1.5,1.3,1.5],[x,6.5,z],'amber',solid=False)
def desk(a,x,z):
 box(a,'EvidenceDesk',[8,.5,4],[x,3,z],'wood')
 for dx in [-3,3]:
  for dz in [-1.5,1.5]:box(a,'DeskLeg',[.5,3,.5],[x+dx,1.5,z+dz],'copper')
def plaque(a,x,z,color):
 box(a,'MemoryFrame',[4,4,.5],[x,5,z],'copper');box(a,'MemoryPlate',[3.5,3.5,.6],[x,5,z],color)
def symbol(a,x,y,z,kind,color='ivory'):
 if kind=='triangle':
  for dx in [-.55,.55]:box(a,'TriangleSide',[.2,1.8,.18],[x+dx,y,z],color,[0,0,35 if dx<0 else -35],False)
  box(a,'TriangleBase',[1.9,.2,.18],[x,y-.72,z],color,solid=False)
 elif kind=='diamond':box(a,'Diamond',[1.25,1.25,.2],[x,y,z],color,[0,0,45],False)
 else:
  for angle in [-45,45]:box(a,'Cross',[.2,1.9,.18],[x,y,z],color,[0,0,angle],False)

a=scene('caravan_checkpoint',48,36)
for x in [-7,7]:pillar(a,x,-11,16)
box(a,'GatewayLintel',[18,2,3],[0,18,-11],'ivory');box(a,'WeatheredBanner',[4,8,.2],[0,12,-12.7],'violet',solid=False)
for x in [-18,18]:
 lamp(a,x,10);box(a,'CargoChest',[5,3,4],[x,1.5,-4],'wood')
 for dx in [-1.5,1.5]:box(a,'ChestBand',[.25,3.1,4.1],[x+dx,1.55,-4],'copper',solid=False)
for i,x in enumerate([-12,0,12]):
 box(a,'SupplyTrace',[1.5,.08,2],[x,.04,3],'copper',solid=False);marker(a,'supply_trace_'+str(i+1),x,5)
marker(a,'gatekeeper',-12,-8);marker(a,'permit_ledger',12,-8)

a=scene('memory_hearth',44,36)
box(a,'HouseRear',[44,8,1],[0,4,-17],'ivory')
for x,h in [(-21,7),(21,5)]:box(a,'BrokenSide',[1,h,21],[x,h/2,-6],'ivory')
for x in [-5,5]:box(a,'HearthColumn',[2,10,3],[x,5,-12],'ivory')
box(a,'HearthMantel',[14,1.2,4],[0,10.5,-12],'ivory');box(a,'CharcoalHearth',[7,.4,4],[0,.2,-12],'dark')
for i,x in enumerate([-14,0,14]):
 plaque(a,x,-16,['teal','violet','amber'][i]);symbol(a,x,5,-15.6,['triangle','diamond','cross'][i]);marker(a,'memory_'+str(i+1),x,-5)
for i,x in enumerate([-2,0,2]):box(a,'MemoryEmber',[.5,1+i*.3,.5],[x,2+i*.5,-12],'teal',[0,0,20],False)
desk(a,-13,6);marker(a,'memory_order',-13,11);marker(a,'survivor',13,8)

a=scene('ash_bridge',60,44)
box(a,'AshChannel',[20,.1,42],[0,.06,0],'dark',solid=False)
box(a,'BridgeDeck',[56,.12,12],[0,.14,0],'ivory',solid=False)
for x in [-25,-15,-5,5,15,25]:
 for z in [-6.5,6.5]:box(a,'BridgeRailPost',[.6,3,.6],[x,1.5,z],'copper')
for z in [-6.5,6.5]:
 for x in [-17,17]:box(a,'BridgeRail',[22,.35,.35],[x,2.7,z],'wood')
for i,x in enumerate([-18,0,18]):
 box(a,'RepairBrace',[4,.2,3],[x,.22,0],'wood',solid=False);marker(a,'support_'+str(i+1),x,0)
for x in [-23,23]:lamp(a,x,13)
marker(a,'sheltered_route',-20,13);marker(a,'direct_route',20,13);marker(a,'bridgewright',0,14)

a=scene('witness_court',44,38)
for x,z,h in [(-18,-14,13),(18,-14,10),(-18,13,6),(18,13,8)]:pillar(a,x,z,h)
desk(a,0,-10)
for x in [-13,13]:
 box(a,'StoneBench',[5,1,3],[x,1.5,1],'ivory')
 for dx in [-1.5,1.5]:box(a,'BenchFoot',[.8,1,.8],[x+dx,.5,1],'dark')
for i,x in enumerate([-12,0,12]):
 box(a,'EvidenceStand',[2,3,2],[x,1.5,-15],'copper');symbol(a,x,3,-13.9,['triangle','diamond','cross'][i]);marker(a,'testimony_'+str(i+1),x,-5)
marker(a,'witness',0,4);marker(a,'trust_route',-7,12);marker(a,'guard_route',7,12)

a=scene('bell_tower',48,44)
for x in [-17,17]:
 for z in [-15,5]:pillar(a,x,z,24)
box(a,'BellCrossbeam',[38,2,3],[0,25,-9],'wood')
box(a,'BellSuspension',[.4,4,.4],[0,22,-9],'copper');box(a,'BellCrown',[5,3,5],[0,18.5,-9],'copper');box(a,'BellBody',[7,5,7],[0,14.5,-9],'copper');box(a,'BellLip',[9,.8,9],[0,11.6,-9],'amber');box(a,'BellClapper',[1,4,1],[0,10,-9],'dark')
for i,x in enumerate([-12,0,12]):
 plaque(a,x,-18,'dark');symbol(a,x,5,-17.6,['triangle','diamond','cross'][i],'amber');marker(a,'tuning_'+str(i+1),x,-2)
for angle in range(0,360,45):
 r=math.radians(angle);box(a,'WaveInlay',[.18,.1,3],[math.sin(r)*8,.07,9+math.cos(r)*8],'teal',[0,angle,0],False)
marker(a,'wave_trial',0,10);marker(a,'courier',16,14)

a=scene('warden_seals',64,64)
for x in [-30,30]:box(a,'CourtWall',[2,4,60],[x,2,0],'ivory')
box(a,'CourtRear',[60,4,2],[0,2,-30],'ivory')
for i,x in enumerate([-20,0,20]):
 box(a,'BindingPillar',[3,8,3],[x,4,-20],'dark');symbol(a,x,5,-18.35,['triangle','diamond','cross'][i],'violet')
 box(a,'BrokenCrown',[3,2,3],[x+.5,8.5,-20],'ivory',[0,0,12],False);marker(a,'binding_'+str(i+1),x,-13)
for angle in range(0,360,45):
 r=math.radians(angle);box(a,'WardCircle',[.2,.1,8],[math.sin(r)*14,.06,math.cos(r)*14],'violet',[0,angle,0],False)
box(a,'ShelterRear',[10,5,1],[22,2.5,23],'ivory');box(a,'ShelterSide',[1,5,8],[27,2.5,19],'ivory')
marker(a,'civilian',22,18);marker(a,'warden',0,0);marker(a,'evidence_return',0,25)

(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda x:'Vector3.new('+','.join(map(str,x))+')'
lines=['--!strict','-- Generated original Ashen scene prototypes. Gameplay unbound.','return function():Folder','local f=Instance.new("Folder");f.Name="AshenStoryKit"']
for a in assets:
 lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m:SetAttribute("StoryScene",true);m.Parent=f']
 for p in a['parts']:
  rotations=','.join('math.rad('+str(x)+')'for x in p['rotation'])
  lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles('+rotations+');p.Color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery='+str(p['solid']).lower()+';p.CanTouch=false;p.Parent=m end']
 for m in a['markers']:
  lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(m['id'])+';p.Size=Vector3.new(1,.1,1);p.Position='+v(m['position'])+';p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute("StoryMarker",'+json.dumps(m['id'])+');p.Parent=m end']
 lines+=['end']
lines+=['return f','end'];(ROOT/'src/server/Services/AshenStoryKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('ASHEN_STORY_KIT',len(assets),'models',sum(len(a['parts'])for a in assets),'parts',sum(len(a['markers'])for a in assets),'markers')
