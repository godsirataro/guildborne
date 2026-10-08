"""Original modular Chapter02 scene kit; geometry and markers, no quest grants."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/ironveil-story-kit';OUT.mkdir(parents=True,exist_ok=True)
palette={'stone':[96,108,118],'dark':[46,57,67],'wood':[122,81,50],'copper':[191,117,61],'ivory':[231,221,190],'teal':[73,184,186],'gold':[230,182,78],'red':[196,89,66],'ink':[62,91,142]}
assets=[]
def box(a,name,size,pos,color,rotation=None,solid=True):
    a['parts'].append(dict(name=name,size=size,position=pos,color=color,rotation=rotation or [0,0,0],solid=solid))
def scene(identity,w=40,d=32):
    a=dict(id=identity,kind='Chapter02Scene',parts=[],markers=[],footprint=[w,d],aisleWidth=10);assets.append(a)
    box(a,'WalkableFloor',[w,1,d],[0,-.5,0],'stone')
    for x in [-w/2+1,w/2-1]:box(a,'EdgeCurb',[1,.5,d],[x,.25,0],'dark')
    return a
def marker(a,identity,x,z):a['markers'].append(dict(id=identity,position=[x,.15,z]))
def crate(a,x,z):
    box(a,'CargoCrate',[3,3,3],[x,1.5,z],'wood')
    for dx in [-1,1]:box(a,'CrateBand',[.25,3.1,3.1],[x+dx,1.55,z],'copper',solid=False)
def support(a,x,z):
    for dx in [-4,4]:box(a,'ShoringPost',[.8,10,.8],[x+dx,5,z],'wood')
    box(a,'ShoringLintel',[9.6,1,1.2],[x,10,z],'wood')
    for dx in [-3,3]:box(a,'CopperBrace',[.35,3,.3],[x+dx,8.7,z+.65],'copper',[0,0,45 if dx<0 else -45],False)
def desk(a,x,z,w=10):
    box(a,'DeskTop',[w,.5,5],[x,3,z],'wood')
    for dx in [-w/2+.5,w/2-.5]:
        for dz in [-2,2]:box(a,'DeskLeg',[.55,3,.55],[x+dx,1.5,z+dz],'dark')
def lamp(a,x,y,z,color):
    box(a,'LampFrame',[1.3,2,1.3],[x,y,z],'copper')
    box(a,'LampGlow',[1,1.5,1.45],[x,y,z],color,solid=False)

a=scene('scale_yard',46,32)
for i,x in enumerate([-14,0,14]):
    box(a,'ScalePlinth',[10,.5,8],[x,.25,-8],'dark')
    box(a,'ScalePost',[.6,7,.6],[x,4,-8],'copper')
    box(a,'ScaleBeam',[9,.4,.4],[x,7.5,-8],'wood',[0,0,(i-1)*6])
    for side in [-1,1]:
        y=5.1+side*(i-1)*.3
        for dz in [-1,1]:box(a,'PanChain',[.12,2.2,.12],[x+side*3.6,y+1.1,-8+dz],'copper',solid=False)
        box(a,'ScalePan',[3.3,.2,3.3],[x+side*3.6,y,-8],'copper')
        for n in range(i+1 if side==1 else 1):box(a,'OreWeight',[.8,.8,.8],[x+side*3.6+(n-1)*.85,y+.5,-8],'stone',solid=False)
    marker(a,'scale_'+str(i+1),x,-1)
for x in [-18,18]:crate(a,x,9);lamp(a,x,6,12,'teal')
marker(a,'carrier',-14,8)

a=scene('signal_shaft',40,36)
box(a,'CutawayBack',[40,14,2],[0,7,-17],'dark')
for i,x in enumerate([-12,0,12]):
    support(a,x,-10);lamp(a,x,8,-9,['teal','gold','red'][i])
    box(a,'SymbolPlate',[3,3,.3],[x,5.4,-9.3],'wood')
    if i==0:
        for dx in [-.55,.55]:box(a,'TriangleSymbol',[.2,1.65,.2],[x+dx,5.4,-9],'ivory',[0,0,35 if dx<0 else -35],False)
    elif i==1:
        box(a,'DiamondSymbol',[1.2,1.2,.2],[x,5.4,-9],'ivory',[0,0,45],False)
    else:
        for angle in [-45,45]:box(a,'CrossSymbol',[.22,1.8,.2],[x,5.4,-9],'ivory',[0,0,angle],False)
    marker(a,'signal_'+str(i+1),x,-3)
box(a,'RescueBench',[6,.6,3],[-13,1.2,9],'wood')
for x in [-16,-10]:box(a,'RescueAlcovePost',[.7,8,.7],[x,4,11],'wood')
box(a,'RescueAlcoveTop',[7,.7,5],[-13,8,10],'wood')
marker(a,'trapped_miner',-13,5);marker(a,'safe_exit',0,13)

a=scene('shoring_gallery',44,34)
box(a,'CutawayRock',[44,13,2],[0,6.5,-16],'dark')
for i,x in enumerate([-14,0,14]):
    support(a,x,-9)
    for n in range(i+1):box(a,'VisibleCrack',[.18,2,.1],[x+(n-1)*.55,6.5+n*.45,-8.3],'dark',[0,0,25*(-1 if n%2 else 1)],False)
    box(a,'RepairSocket',[1.7,1.7,.3],[x,3,-8.25],'copper',[0,0,45],False)
    marker(a,'support_'+str(i+1),x,-2)
desk(a,14,8,8);box(a,'ToolHandle',[3,.25,.25],[14,3.5,8],'wood');box(a,'HammerHead',[1.2,.8,1],[15,3.7,8],'copper')
marker(a,'engineer',-12,8)

a=scene('ink_office',36,30)
box(a,'OfficeBack',[36,11,1],[0,5.5,-14],'wood')
desk(a,-10,-4,12)
for x in [-13,-9,-6]:box(a,'EvidenceSheet',[2,.1,2.5],[x,3.3,-4],'ivory',solid=False)
for i,x in enumerate([8,13]):
    box(a,'SealBoard',[4,5,.4],[x,6,-13.2],'ivory')
    box(a,'SealMark',[2,2,.2],[x,6,-12.8],['copper','ink'][i],[0,0,45],False)
    marker(a,'seal_'+str(i+1),x,-6)
desk(a,11,7,8)
for i,x in enumerate([8,11,14]):
    box(a,'ReagentBottle',[1,1.4,1],[x,3.9,7],['teal','gold','ink'][i],solid=False)
    box(a,'BottleStopper',[.5,.3,.5],[x,4.75,7],'copper',solid=False)
marker(a,'evidence_desk',-10,2);marker(a,'reagent',11,12)

a=scene('warden_mechanism',64,64)
for x in [-30,30]:box(a,'ArenaWall',[2,3,60],[x,1.5,0],'dark')
box(a,'ArenaBack',[60,3,2],[0,1.5,-30],'dark')
for x in [-20,20]:box(a,'EntryWall',[22,3,2],[x,1.5,30],'dark')
for i,x in enumerate([-20,0,20]):
    box(a,'MechanismPlinth',[5,2,5],[x,1,-20],'stone')
    box(a,'LeverBracket',[2,1.5,1.5],[x,2.75,-20],'copper')
    box(a,'LeverHandle',[.4,3,.4],[x,4.3,-20],'wood',[25,0,0],False)
    lamp(a,x,6,-24,['teal','gold','red'][i]);marker(a,'mechanism_'+str(i+1),x,-14)
for angle in range(0,360,45):
    import math
    radians=math.radians(angle);box(a,'ArenaInlay',[.2,.1,8],[math.sin(radians)*13,.06,math.cos(radians)*13],'copper',[0,angle,0],False)
box(a,'ProtectedAlcoveBack',[9,6,1],[23,3,23],'stone');box(a,'ProtectedAlcoveSide',[1,6,8],[27,3,19],'stone')
marker(a,'warden_spawn',0,0);marker(a,'protected_worker',23,19);marker(a,'arena_entry',0,25)

a=scene('training_camp',48,40)
for x in [-6,6]:
    for z in [-17,-9]:box(a,'TentPost',[.5,9,.5],[x,4.5,z],'wood')
box(a,'TentRoof',[15,.5,12],[0,9.5,-13],'ink')
box(a,'TentRear',[13,7,.3],[0,4,-18],'ink',solid=False)
for i,x in enumerate([-18,-9,0,9,18]):
    box(a,'TrainingLane',[5,.1,15],[x,.06,9],'ivory',solid=False)
    box(a,'DummyPost',[.5,5,.5],[x,2.5,4],'wood')
    box(a,'DummyArms',[3,.4,.4],[x,3.5,4],'wood')
    box(a,'ClassBadge',[1.2,1.2,.25],[x,4,4.4],['red','copper','gold','ink','teal'][i],[0,0,45],False)
    marker(a,'trial_'+str(i+1),x,14)
marker(a,'mentor',0,-5)

(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda x:'Vector3.new('+','.join(map(str,x))+')'
lines=['--!strict','-- Generated original Chapter02 scene prototypes. No quest handlers or reward authority.','return function():Folder','local f=Instance.new("Folder");f.Name="IronveilStoryKit"']
for a in assets:
    lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m:SetAttribute("StoryScene",true);m.Parent=f']
    for p in a['parts']:
        rotations=','.join('math.rad('+str(x)+')' for x in p['rotation'])
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles('+rotations+');p.Color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery='+str(p['solid']).lower()+';p.CanTouch=false;p.Parent=m end']
    for m in a['markers']:
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(m['id'])+';p.Size=Vector3.new(1,.1,1);p.Position='+v(m['position'])+';p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute("StoryMarker",'+json.dumps(m['id'])+');p.Parent=m end']
    lines+=['end']
lines+=['return f','end']
(ROOT/'src/server/Services/IronveilStoryKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('IRONVEIL_STORY_KIT',len(assets),'models',sum(len(a['parts']) for a in assets),'parts',sum(len(a['markers']) for a in assets),'markers')
