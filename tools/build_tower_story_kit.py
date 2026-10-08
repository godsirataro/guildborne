"""Original Chapter04 tower scene prototypes; no gameplay or imported IDs."""
from pathlib import Path
import json, math
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/tower-story-kit';OUT.mkdir(parents=True,exist_ok=True)
palette={'ivory':[216,207,185],'navy':[42,57,76],'dark':[29,37,50],'brass':[188,149,75],'wood':[110,76,57],'teal':[64,195,185],'amber':[243,181,76],'blue':[99,157,220]}
assets=[]
def box(a,name,size,pos,color,rotation=None,solid=True):
 a['parts'].append(dict(name=name,size=size,position=pos,color=color,rotation=rotation or [0,0,0],solid=solid))
def scene(identity,w,d):
 a=dict(id=identity,kind='Chapter04Scene',parts=[],markers=[],footprint=[w,d],aisleWidth=10);assets.append(a)
 box(a,'WalkableFloor',[w,1,d],[0,-.5,0],'navy');return a
def marker(a,name,x,z):a['markers'].append(dict(id=name,position=[x,.15,z]))
def column(a,x,z,h=16):
 box(a,'ColumnFoot',[3,1,3],[x,.5,z],'ivory');box(a,'ColumnShaft',[2,h,2],[x,1+h/2,z],'navy')
 for y in [2,h-1]:box(a,'ColumnBand',[2.4,.5,2.4],[x,y,z],'brass',solid=False)
 box(a,'ColumnCrown',[3,1,3],[x,h+1.5,z],'ivory')
def arch(a,x,z,w=12,h=18):
 for dx in [-w/2,w/2]:column(a,x+dx,z,h)
 box(a,'ArchLintel',[w+3,2,3],[x,h+2,z],'ivory');box(a,'CrestInlay',[2,2,.2],[x,h+2,z+1.6],'teal',[0,0,45],False)
def desk(a,x,z,w=10):
 box(a,'DeskTop',[w,.6,4],[x,3,z],'wood')
 for dx in [-w/2+1,w/2-1]:
  for dz in [-1.4,1.4]:box(a,'DeskLeg',[.6,3,.6],[x+dx,1.5,z+dz],'brass')
def symbol(a,x,y,z,kind,color='teal'):
 if kind=='triangle':
  for dx in [-.6,.6]:box(a,'TriangleSide',[.22,2,.2],[x+dx,y,z],color,[0,0,35 if dx<0 else -35],False)
  box(a,'TriangleBase',[2.1,.22,.2],[x,y-.8,z],color,solid=False)
 elif kind=='diamond':box(a,'Diamond',[1.5,1.5,.2],[x,y,z],color,[0,0,45],False)
 else:
  for angle in [-45,45]:box(a,'Cross',[.22,2.1,.2],[x,y,z],color,[0,0,angle],False)
def plaque(a,x,z,kind):
 box(a,'PlaqueStand',[1.2,3,1.2],[x,1.5,z],'brass');box(a,'PlaqueFace',[4,4,.5],[x,5,z],'dark');symbol(a,x,5,z+.4,kind)
def beacon(a,x,z,color='teal'):
 box(a,'BeaconBase',[2,1,2],[x,.5,z],'ivory');box(a,'BeaconStem',[.6,5,.6],[x,3.5,z],'brass');box(a,'BeaconLight',[1.5,2,1.5],[x,6.5,z],color,solid=False)

a=scene('charter_gate',64,72);arch(a,0,-25,18,26)
for x in [-27,27]:column(a,x,-28,20)
desk(a,24,-23);marker(a,'council',24,-17);marker(a,'charter',0,-20)
for i in range(10):
 x=-12 if i%2==0 else 12;z=24-(i//2)*9
 box(a,'CheckpointPlinth',[3,3,3],[x,1.5,z],'ivory');box(a,'CheckpointGlyph',[1,.1,1],[x,3.1,z],'teal',solid=False)
 marker(a,'checkpoint_'+str(i+1),x+(-4 if x<0 else 4),z)
marker(a,'route_chart',0,29)
for z in [-8,4,16,28]:box(a,'AisleInlay',[.3,.08,7],[0,.05,z],'brass',solid=False)

a=scene('guardian_school',64,48)
for x in [-28,28]:column(a,x,-19,18)
arch(a,0,-18,16,16)
for x,c in [(-17,'amber'),(17,'teal')]:
 box(a,'TrainingPlatform',[12,.15,12],[x,.08,0],'ivory',solid=False)
 for z in [-5,5]:box(a,'TrainingBoundary',[10,.12,.2],[x,.16,z],c,solid=False)
 beacon(a,x,-10,c)
box(a,'ShieldStand',[.8,5,.8],[-17,2.5,-5],'wood');box(a,'TrainingShield',[4,5,1],[-17,4,-5],'brass');box(a,'ShieldStripe',[.4,4,1.1],[-17,4,-5],'ivory',solid=False)
box(a,'HealingBasin',[5,1,4],[17,2.5,-5],'ivory');box(a,'HealingWater',[4,.1,3],[17,3.1,-5],'teal',solid=False)
for i,x in enumerate([-17,0,17]):plaque(a,x,-18,['triangle','diamond','cross'][i]);marker(a,'rule_'+str(i+1),x,-14)
for name,x,z in [('guard_trial',-17,3),('mend_trial',17,3),('refuge',0,9),('defense_trial',0,-4)]:marker(a,name,x,z)

a=scene('hidden_archive',64,56)
box(a,'ArchiveWall',[30,18,3],[0,9,0],'dark')
for y in [2,7,12,17]:box(a,'ArchiveShelf',[31,.5,4],[0,y,0],'wood')
for x in [-14,-7,0,7,14]:box(a,'ShelfUpright',[.5,17,4],[x,9,0],'brass')
for row,y in enumerate([4,9,14]):
 for i,x in enumerate(range(-12,13,3)):box(a,'ArchiveVolume',[1.8,3,2.2],[x,y,.8],['teal','ivory','navy','brass'][(i+row)%4])
desk(a,0,-19);box(a,'RecoveredPlan',[6,.15,3],[0,3.5,-19],'ivory',solid=False)
for i,x in enumerate([-12,0,12]):plaque(a,x,16,['triangle','diamond','cross'][i]);marker(a,'sequence_'+str(i+1),x,10)
for name,x,z in [('hidden_turn',-24,0),('hidden_exit',-24,-16),('archive_record',0,-12),('return_chart',24,12)]:marker(a,name,x,z)
for x in [-27,27]:beacon(a,x,-21)

a=scene('memory_chamber',64,52)
for i,x in enumerate([-20,0,20]):
 for dx in [-7,7]:column(a,x+dx,-21,14)
 box(a,'MemoryFrame',[13,14,1],[x,9,-21],'brass');box(a,'MemoryGlass',[11,12,1.1],[x,9,-21],'dark')
 symbol(a,x,10,-20.3,['triangle','diamond','cross'][i],'amber');marker(a,['caravan_memory','timber_memory','guild_memory'][i],x,-12)
for angle in range(0,360,45):
 r=math.radians(angle);box(a,'OathCircle',[.2,.1,5],[math.sin(r)*8,.08,6+math.cos(r)*8],'teal',[0,angle,0],False)
box(a,'MemorySpiritBase',[3,.4,3],[16,.2,7],'ivory');box(a,'MemorySpirit',[1.6,3,1.6],[16,3,7],'teal',[0,0,12],False)
marker(a,'help_memory',16,12);marker(a,'oath_courage',-6,6);marker(a,'oath_compassion',6,6)

a=scene('twin_doors',76,58)
for x in [-16,16]:arch(a,x,-9,12,20)
box(a,'DoorDivider',[4,12,4],[0,6,-9],'navy')
for x,c in [(-16,'amber'),(16,'blue')]:box(a,'DoorSigil',[2.5,2.5,.3],[x,18,-7.3],c,[0,0,45],False)
for x in [-33,33]:beacon(a,x,-18)
for i,x in enumerate([-21,0,21]):plaque(a,x,15,['triangle','diamond','cross'][i]);marker(a,'door_clue_'+str(i+1),x,9)
for name,x,z in [('sun_door',-16,-3),('moon_door',16,-3),('bypass_left',-29,-18),('bypass_right',29,-18),('bypass_record',0,-22)]:marker(a,name,x,z)
for x in [-24,-12,0,12,24]:box(a,'BypassInlay',[7,.1,.25],[x,.08,-22],'teal',solid=False)

a=scene('first_ledger',76,72)
for x in [-31,31]:
 for z in [-28,24]:column(a,x,z,22)
arch(a,0,-28,20,26);desk(a,0,-13,16)
for x,angle in [(-3,-10),(3,10)]:
 box(a,'LedgerCover',[6,.5,7],[x,3.8,-13],'brass',[0,0,angle]);box(a,'LedgerPages',[5.7,.7,6.7],[x,4.3,-13],'ivory',[0,0,angle])
for i,x in enumerate([-20,0,20]):plaque(a,x,25,['triangle','diamond','cross'][i]);marker(a,'city_seal_'+str(i+1),x,18)
for angle in range(0,360,45):
 r=math.radians(angle);box(a,'GuardianCircle',[.2,.1,7],[math.sin(r)*11,.08,3+math.cos(r)*11],'brass',[0,angle,0],False)
marker(a,'records_guardian',0,3);marker(a,'copy_ledger',0,-7);marker(a,'certify_ledger',26,18)

(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda x:'Vector3.new('+','.join(map(str,x))+')'
lines=['--!strict','-- Generated original Tower Chapter04 geometry; gameplay unbound.','return function():Folder','local f=Instance.new("Folder");f.Name="TowerStoryKit"']
for a in assets:
 lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m:SetAttribute("StoryScene",true);m.Parent=f']
 for p in a['parts']:
  rotation=','.join('math.rad('+str(x)+')'for x in p['rotation'])
  lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles('+rotation+');p.Color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery='+str(p['solid']).lower()+';p.CanTouch=false;p.Parent=m end']
 for m in a['markers']:
  lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(m['id'])+';p.Size=Vector3.new(1,.1,1);p.Position='+v(m['position'])+';p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute("StoryMarker",'+json.dumps(m['id'])+');p.Parent=m end']
 lines+=['end']
lines+=['return f','end'];(ROOT/'src/server/Services/TowerStoryKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('TOWER_STORY_KIT',len(assets),'models',sum(len(a['parts'])for a in assets),'parts',sum(len(a['markers'])for a in assets),'markers')
