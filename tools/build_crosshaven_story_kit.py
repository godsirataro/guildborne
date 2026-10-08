"""Original Chapter05 modular courts and shelters; gameplay remains unbound."""
from pathlib import Path
import json, math
root=Path(__file__).resolve().parents[1]
out=root/'assets/uat01/crosshaven-story-kit';out.mkdir(parents=True,exist_ok=True)
palette={'ivory':[224,212,181],'navy':[58,70,83],'dark':[34,44,55],'brass':[193,153,78],'wood':[130,88,61],'teal':[59,169,154],'amber':[236,168,76],'blue':[99,150,205],'cloth':[192,103,81],'violet':[145,110,194]}
assets=[]
def box(a,name,size,pos,color,rotation=None,solid=True):
    a['parts'].append(dict(name=name,size=size,position=pos,color=color,rotation=rotation or [0,0,0],solid=solid))
def scene(identity,w,d):
    a=dict(id=identity,kind='Chapter05Scene',parts=[],markers=[],footprint=[w,d],aisleWidth=10);assets.append(a)
    box(a,'WalkableFloor',[w,1,d],[0,-.5,0],'navy');return a
def marker(a,name,x,z):a['markers'].append(dict(id=name,position=[x,.15,z]))
def pillar(a,x,z,height=13,color='ivory'):
    box(a,'PillarFoot',[3,1,3],[x,.5,z],'brass');box(a,'Pillar',[2,height,2],[x,height/2+1,z],color)
    box(a,'PillarCap',[3,1,3],[x,height+1.5,z],'brass')
def arch(a,x,z,width=16,height=14):
    for dx in [-width/2,width/2]:pillar(a,x+dx,z,height)
    box(a,'OpenLintel',[width+3,2,3],[x,height+2,z],'ivory')
def desk(a,x,z,width=10):
    box(a,'TableTop',[width,.7,4],[x,3,z],'wood')
    for dx in [-width/2+1,width/2-1]:
        for dz in [-1.3,1.3]:box(a,'TableLeg',[.6,3,.6],[x+dx,1.5,z+dz],'brass')
def plaque(a,x,z,color='teal',symbol=0):
    box(a,'RecordStand',[1.2,3,1.2],[x,1.5,z],'wood');box(a,'RecordFace',[3.5,3,.4],[x,4.6,z],'ivory')
    box(a,'RecordSigil',[1,1,.2],[x,4.7,z+.35],color,[0,0,45 if symbol%2 else 0],False)
def shelter(a,x,z,color):
    for dx in [-7,7]:
        for dz in [-5,5]:box(a,'ShelterPost',[.7,9,.7],[x+dx,4.5,z+dz],'wood')
    for dx,angle in [(-4,-18),(4,18)]:box(a,'ShelterRoof',[8.5,.5,13],[x+dx,10,z],color,[0,0,angle])
    box(a,'ShelterBack',[14,7,.4],[x,3.5,z-5],color)
    for dx in [-3,3]:
        box(a,'Cot',[4,.7,6],[x+dx,1,z],'wood');box(a,'Blanket',[3.8,.4,5.8],[x+dx,1.55,z],'ivory')
def banner(a,x,z,color):
    box(a,'BannerPole',[.5,13,.5],[x,6.5,z],'brass');box(a,'BannerCloth',[3.5,6,.2],[x+1.8,9,z],color,solid=False)

a=scene('rift_refuge',72,64);arch(a,0,-18,20,18)
for x,angle in [(-7,-18),(7,18)]:box(a,'BrokenRiftLight',[1,10,.4],[x,8,-17],'violet',[0,0,angle],False)
desk(a,-24,-17);plaque(a,-24,-23,'amber');shelter(a,24,-17,'teal')
for x in [-29,29]:banner(a,x,18,'teal')
for name,x,z in [('mentor',-24,-10),('mastery_trial',0,7),('rival_start',11,-9),('rival_waypoint',16,2),('rival_refuge',24,-7),('charter',-24,1)]:marker(a,name,x,z)

a=scene('hearing_square',88,72)
for side,color in [(-1,'amber'),(1,'teal')]:
    x=side*37
    box(a,'NeighborhoodFront',[10,12,52],[x,6,-1],color)
    for z in [-19,0,19]:
        box(a,'WindowFrame',[.4,5,6],[x-side*5.3,6,z],'brass',solid=False)
        box(a,'WindowGlass',[.5,4,5],[x-side*5.5,6,z],'dark',solid=False)
        plaque(a,side*28,z,color,z);marker(a,('human_record_'if side<0 else'orc_record_')+str([-19,0,19].index(z)+1),side*23,z)
desk(a,0,-20,20)
for x in [-12,12]:box(a,'HearingBench',[5,2,9],[x,1,-16],'wood')
banner(a,-17,23,'amber');banner(a,17,23,'teal')
for name,x,z in [('speaker_human',-6,-12),('speaker_orc',6,-12),('shared_table',-10,7),('joint_work',10,7)]:marker(a,name,x,z)

a=scene('refuge_camp',88,72)
for x,color in [(-27,'cloth'),(0,'teal'),(27,'blue')]:shelter(a,x,-22,color)
for name,x in [('sleeping_space',-27),('water_space',0),('care_space',27)]:marker(a,name,x,-12)
for i,x in enumerate([-27,0,27],1):
    desk(a,x,8,9)
    for dx in [-2,0,2]:box(a,'AidBundle',[1.5,1.3,2],[x+dx,4,8],['ivory','teal','cloth'][i-1])
    marker(a,'supply_bundle_'+str(i),x,14)
    box(a,'WardInlay',[4,.1,4],[x,.08,-3],'brass',solid=False);marker(a,'ward_'+str(i),x,-3)
marker(a,'camp_steward',0,24)

a=scene('forger_passage',80,64)
box(a,'PassageScreen',[32,13,3],[0,6.5,-3],'dark')
for x in [-13,0,13]:box(a,'ScreenBrace',[1,13,3.2],[x,6.5,-3],'wood')
desk(a,0,-24,14);box(a,'PreservedCrest',[3,.3,3],[0,3.6,-24],'brass',[0,45,0],False)
for i,x in enumerate([-22,0,22],1):plaque(a,x,19,['amber','teal','violet'][i-1],i);marker(a,'passage_clue_'+str(i),x,13)
for name,x,z in [('witness',-29,13),('hidden_turn',-27,-3),('hidden_exit',-27,-20),('forger',0,-16),('testify',-12,-16),('guarded_refuge',12,-16)]:marker(a,name,x,z)

a=scene('name_registry',88,72)
for x in [-27,27]:arch(a,x,14,14,11)
box(a,'NameSorterBase',[20,2,10],[0,1,-22],'dark');box(a,'NameSorterCabinet',[18,12,8],[0,8,-22],'wood')
for x in [-6,0,6]:
    box(a,'ArchiveDrawer',[4.5,7,.8],[x,7,-17.5],'ivory');box(a,'DrawerHandle',[2,.4,.5],[x,7,-16.8],'brass')
for i,x in enumerate([-14,0,14],1):plaque(a,x,-11,['violet','amber','teal'][i-1],i);marker(a,'interlock_'+str(i),x,-5)
desk(a,31,-23,12)
for x in [28,31,34]:box(a,'BackupLedger',[2.2,.5,3],[x,3.7,-23],'ivory')
for name,x,z in [('escort_start',-27,25),('inspection_left',-27,7),('inspection_center',0,5),('inspection_right',27,7),('escort_exit',27,-4),('backup_evidence',31,-16)]:marker(a,name,x,z)

a=scene('invitation_gallery',76,64)
for i,x in enumerate([-23,0,23],1):
    for dx in [-7,7]:pillar(a,x+dx,-25,13)
    box(a,'OfferPanel',[12,10,1],[x,7,-25],'ivory');box(a,'OfferDiamond',[3,3,.2],[x,8,-24.3],['violet','amber','teal'][i-1],[0,0,45],False)
    marker(a,['offer','consequence','return_route'][i-1],x,-17)
for name,x,z in [('refuse_offer',-12,-3),('investigate_offer',12,-3)]:marker(a,name,x,z)
for i,x in enumerate([-23,0,23],1):
    desk(a,x,18,10);box(a,'PreparationKit',[5,1,3],[x,3.9,18],['cloth','teal','blue'][i-1]);marker(a,['rest_station','supply_station','route_station'][i-1],x,12)

(out/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda values:'Vector3.new('+','.join(map(str,values))+')'
lines=['--!strict','-- Generated original Crosshaven Chapter05 geometry. Gameplay unbound.','return function():Folder','local f=Instance.new("Folder");f.Name="CrosshavenStoryKit"']
for a in assets:
    lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m:SetAttribute("StoryScene",true);m.Parent=f']
    for p in a['parts']:
        rotation=','.join('math.rad('+str(n)+')'for n in p['rotation'])
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles('+rotation+');p.Color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery='+str(p['solid']).lower()+';p.CanTouch=false;p.Parent=m end']
    for m in a['markers']:
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(m['id'])+';p.Size=Vector3.new(1,.1,1);p.Position='+v(m['position'])+';p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p:SetAttribute("StoryMarker",'+json.dumps(m['id'])+');p.Parent=m end']
    lines+=['end']
lines+=['return f','end']
(root/'src/server/Services/CrosshavenStoryKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('CROSSHAVEN_STORY_KIT',len(assets),'models',sum(len(a['parts'])for a in assets),'parts',sum(len(a['markers'])for a in assets),'markers')
