"""Original Chapter06 modular archive scenes; native world binding remains pending."""
from pathlib import Path
import json, math
root=Path(__file__).resolve().parents[1]
out=root/'assets/uat01/archive-heart-story-kit';out.mkdir(parents=True,exist_ok=True)
palette={'ivory':[224,212,181],'navy':[58,70,83],'dark':[34,44,55],'brass':[193,153,78],'wood':[130,88,61],'teal':[59,169,154],'amber':[236,168,76],'blue':[99,150,205],'cloth':[192,103,81],'violet':[145,110,194]}
assets=[]
def box(a,name,size,pos,color,rotation=None,solid=True):a['parts'].append(dict(name=name,size=size,position=pos,color=color,rotation=rotation or [0,0,0],solid=solid))
def scene(identity,w=96,d=84):
    a=dict(id=identity,kind='Chapter06Scene',parts=[],markers=[],footprint=[w,d],aisleWidth=10);assets.append(a)
    box(a,'WalkableFloor',[w,1,d],[0,-.5,0],'navy');return a
def marker(a,name,x,z):a['markers'].append(dict(id=name,position=[x,.15,z]))
def pillar(a,x,z,h=16):
    box(a,'ColumnFoot',[3,1,3],[x,.5,z],'brass');box(a,'Column',[2,h,2],[x,h/2+1,z],'ivory');box(a,'Capital',[4,1,4],[x,h+1.5,z],'brass')
def arch(a,x,z,w=18):
    for dx in [-w/2,w/2]:pillar(a,x+dx,z)
    box(a,'OpenLintel',[w+4,2,3],[x,19,z],'ivory')
def desk(a,x,z,w=12):
    box(a,'Desk',[w,.8,4],[x,3,z],'wood')
    for dx in [-w/2+1,w/2-1]:
        for dz in [-1.4,1.4]:box(a,'DeskLeg',[.7,3,.7],[x+dx,1.5,z+dz],'brass')
def sigil(a,x,z,color,number):
    box(a,'RecordPlinth',[4,2,3],[x,1,z],'dark');box(a,'SymbolPanel',[4,4,.5],[x,4,z],'ivory')
    for i in range(number):box(a,'CountMark',[.4,1.6,.15],[x+(i-(number-1)/2)*.8,4,z+.35],color,solid=False)
def banner(a,x,z,color):
    box(a,'BannerPole',[.6,14,.6],[x,7,z],'brass');box(a,'Banner',[4,7,.3],[x+2.2,10,z],color,solid=False)

a=scene('three_gates',112,88)
for i,(x,route,color) in enumerate([(-35,'guard','amber'),(0,'stealth','teal'),(35,'puzzle','violet')],1):
    arch(a,x,-25);sigil(a,x,-32,color,i);marker(a,'choose_'+route,x,-13)
    for j,z in enumerate([5,16,27],1):
        box(a,'RouteInlay',[4,.08,4],[x,.05,z],color,solid=False);marker(a,route+'_step_'+str(j),x,z)
desk(a,0,35,18);marker(a,'command_post',0,29)

a=scene('supply_court',112,88)
for x in [-40,40]:
    for z in [-26,0,26]:
        box(a,'SupplyCrate',[7,5,7],[x,2.5,z],'wood');box(a,'CrateBrace',[7.2,.6,7.2],[x,2.5,z],'brass')
for x in [-24,24]:banner(a,x,-30,'teal')
for name,x,z in [('caravan_greeting',-20,27),('escort_start',-20,17),('escort_turn',-20,-8),('escort_exit',20,-8),('supply_anchor',20,10),('ward_1',-12,0),('ward_2',0,0),('ward_3',12,0)]:marker(a,name,x,z)

a=scene('warden_approach',112,96)
arch(a,0,-34,32)
for i,(x,color) in enumerate([(-30,'amber'),(0,'violet'),(30,'teal')],1):sigil(a,x,30,color,i);marker(a,'warning_'+str(i),x,23)
for name,x,z in [('warden_trial',0,8),('release_oath',-16,-20),('renew_oath',16,-20)]:marker(a,name,x,z)
for x in [-46,46]:
    for z in [-30,0,30]:pillar(a,x,z,20)

a=scene('living_ledger',112,96)
for x in [-44,44]:
    for z in [-29,0,29]:
        box(a,'LedgerShelf',[8,10,14],[x,5,z],'dark')
        for row in [2,5,8]:box(a,'NamedVolumes',[6,1.8,12],[x,row,z],'ivory')
for i,x in enumerate([-28,0,28],1):
    desk(a,x,-29);marker(a,'recover_'+str(i),x,-21)
    desk(a,x,28);marker(a,'backup_'+str(i),x,21)
    sigil(a,x,0,'violet',i);marker(a,'interlock_'+str(i),x,7)
marker(a,'recovery_start',0,37)

a=scene('alliance_gate',112,96)
for i,(x,color) in enumerate([(-40,'amber'),(-20,'teal'),(0,'brass'),(20,'violet'),(40,'cloth')],1):
    banner(a,x,-32,color);marker(a,'pledge_'+str(i),x,-22)
arch(a,0,28,28)
for i,x in enumerate([-12,0,12],1):marker(a,'ward_'+str(i),x,0)
marker(a,'evacuation_station',0,12);marker(a,'heart_gate',0,21)

a=scene('heart_chamber',112,112)
for x in [-46,46]:
    for z in [-42,0,42]:pillar(a,x,z,23)
# Continuous floor: the concept's stepping platforms are decoration, never traversal gaps.
for i in range(12):
    angle=i*math.pi/6;x=math.sin(angle)*35;z=math.cos(angle)*35
    box(a,'HeartCircuit',[3,.08,8],[x,.06,z],'teal',[0,i*30,0],False)
for i,x in enumerate([-30,0,30],1):
    sigil(a,x,-40,['amber','teal','violet'][i-1],i)
    marker(a,['ending_preserve','ending_transform','ending_dismantle'][i-1],x,-32)
marker(a,'keeper_trial',0,19);desk(a,0,44,18);marker(a,'epilogue_record',0,36)

(out/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda values:'Vector3.new('+','.join(map(str,values))+')'
lines=['--!strict','-- Generated original Archive Heart Chapter06 geometry. Gameplay unbound.','return function():Folder','local f=Instance.new("Folder");f.Name="ArchiveHeartStoryKit"']
for a in assets:
    lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m:SetAttribute("StoryScene",true);m.Parent=f']
    for p in a['parts']:
        rotation=','.join('math.rad('+str(n)+')'for n in p['rotation'])
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles('+rotation+');p.Color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery='+str(p['solid']).lower()+';p.CanTouch=false;p.Parent=m end']
    for m in a['markers']:
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(m['id'])+';p.Size=Vector3.new(1,.1,1);p.Position='+v(m['position'])+';p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute("StoryMarker",'+json.dumps(m['id'])+');p.Parent=m end']
    lines+=['end']
lines+=['return f','end']
(root/'src/server/Services/ArchiveHeartStoryKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('ARCHIVE_HEART_STORY_KIT',len(assets),'models',sum(len(a['parts'])for a in assets),'parts',sum(len(a['markers'])for a in assets),'markers')
