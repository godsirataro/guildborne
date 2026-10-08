"""Original regional geometry; runtime traversal binding lives in RegionalWorld."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/region-kit';OUT.mkdir(parents=True,exist_ok=True)
P={'grass':[74,117,72],'earth':[100,78,56],'path':[180,153,108],'rock':[96,105,119],'dark':[52,61,79],'sand':[177,143,88],'rune':[80,202,216],'purple':[112,86,155],'wood':[116,79,50],'leaf':[55,96,63],'gold':[216,174,76]}
assets=[]
def region(id,title):
    a={'id':id,'title':title,'parts':[],'routes':[],'markers':[]};assets.append(a);return a
def part(a,name,size,pos,color,collide=True,shape='Block',yaw=0):
    a['parts'].append(dict(name=name,size=size,position=pos,color=color,collide=collide,shape=shape,yaw=yaw))
def floor(a,n,x,z,w,d,top,color):part(a,n,[w,4,d],[x,top-2,z],color)
def route(a,n,points):a['routes'].append(dict(name=n,points=points))
def ramp(a,n,zlow,zhigh,low,high):
    assert zlow>zhigh and high>low
    part(a,n,[20,high-low,zlow-zhigh],[0,(high+low)/2,(zhigh+zlow)/2],'path',True,'Wedge',180)
def marker(a,n,pos,role):a['markers'].append(dict(name=n,position=pos,role=role))
def tree(a,x,z,y):
    part(a,'Trunk',[3,12,3],[x,y+6,z],'wood')
    for dy,s in [(11,13),(16,10),(20,6)]:part(a,'Canopy',[s,6,s],[x,y+dy,z],'leaf',False)
def crystal(a,x,z,y,color='rune'):
    part(a,'CrystalBase',[7,3,7],[x,y+1.5,z],'rock')
    for dx,h in [(-2,5),(0,10),(2,7)]:part(a,'Crystal',[2,h,2],[x+dx,y+3+h/2,z],color,False,yaw=45)

a=region('Greenwood','Greenwood Reach')
floor(a,'Island',0,0,220,200,2,'grass');floor(a,'Landing',0,113,28,26,2,'wood')
floor(a,'BossRise',0,-70,96,50,6,'earth');ramp(a,'RootAscent',-20,-45,2,6)
for x in (-60,60):
    floor(a,'Trail',x,10,18,90,2.05,'path')
for z in (50,-25):floor(a,'CrossTrail',0,z,138,18,2.06,'path')
floor(a,'ArrivalTrail',0,78,18,46,2.05,'path')
for x,z in [(-90,75),(85,72),(-89,18),(90,5),(-85,-50),(87,-60),(-45,8),(42,12),(-95,-83),(95,-87)]:tree(a,x,z,2)
for x in (-37,37):tree(a,x,-77,6)
route(a,'Main',[ [0,2.05,112],[0,2.05,50],[0,2.06,-20],[0,6,-45],[0,6,-70]])
route(a,'WestLoop',[[0,2.06,50],[-60,2.06,50],[-60,2.06,-18],[0,2.06,-18]])
route(a,'EastLoop',[[0,2.06,50],[60,2.06,50],[60,2.06,-18],[0,2.06,-18]])
for n,p,r in [('Arrival',[0,2,105],'Arrival'),('ScoutCamp',[-60,2,10],'Melee'),('ArcherCamp',[60,2,10],'Ranged'),('BoarTrail',[0,2,10],'Charge'),('ForestCaptain',[0,6,-70],'Boss')]:marker(a,n,p,r)

a=region('Ironveil','Ironveil Quarry')
floor(a,'Island',0,0,240,220,2,'rock');floor(a,'Landing',0,122,28,24,2,'wood')
floor(a,'MidTerrace',0,-30,220,160,6,'sand');floor(a,'UpperTerrace',0,-57.5,190,105,10,'rock')
ramp(a,'QuarryAscent',75,50,2,6);ramp(a,'SummitAscent',20,-5,6,10)
for x,z,y in [(-82,80,2),(82,80,2),(-85,22,6),(85,22,6),(-72,-48,10),(72,-48,10),(-60,-90,10),(60,-90,10)]:crystal(a,x,z,y,'gold')
for x in (-106,106):part(a,'QuarryWall',[7,15,145],[x,13,-26],'dark')
for x in (-44,44):
    part(a,'GantryPost',[4,18,4],[x,19,-80],'wood');part(a,'GantryBrace',[4,3,20],[x,27,-73],'wood',False)
part(a,'GantryCrossbeam',[92,4,4],[0,29,-80],'wood',False)
route(a,'Main',[[0,2,120],[0,2,75],[0,6,50],[0,6,20],[0,10,-5],[0,10,-70]])
route(a,'MidLoop',[[0,6,40],[-52,6,40],[-52,6,5],[0,6,30]])
route(a,'UpperLoop',[[0,10,-20],[45,10,-20],[45,10,-68],[0,10,-68]])
for n,p,r in [('Arrival',[0,2,115],'Arrival'),('RaiderCamp',[-52,6,25],'Melee'),('StoneGuard',[45,10,-25],'Guard'),('ShamanCamp',[-45,10,-50],'Support'),('QuarryGuardian',[0,10,-70],'Boss')]:marker(a,n,p,r)

a=region('Ashen','Ashen Sanctum')
floor(a,'Island',0,0,220,220,2,'dark');floor(a,'Landing',0,123,28,26,2,'rock')
floor(a,'CentralSanctum',0,0,90,50,5,'purple');ramp(a,'SanctumAscent',45,25,2,5)
floor(a,'BossSanctum',0,-72.5,90,55,8,'rock');ramp(a,'WardenAscent',-25,-45,5,8)
# Fill the low void beneath the elevated wedge so navigation does not split the ramp.
part(a,'WardenRampFoundation',[20,3,20],[0,3.5,-35],'rock')
for x in (-72,72):
    floor(a,'SideCourt',x,0,45,70,5,'rock');floor(a,'Bridge',math.copysign(47.25,x),0,4.5,16,5,'path')
    for z in (-24,24):crystal(a,x,z,5)
for x in (-38,38):
    for z in (-52,-90):
        part(a,'SanctumColumn',[5,19,5],[x,17.5,z],'rock');part(a,'ColumnCrown',[8,2,8],[x,28,z],'gold',False)
for x in (-91,91):
    for z in (-80,75):part(a,'BrokenSpire',[8,24,8],[x,14,z],'purple')
part(a,'WardenArch',[82,5,6],[0,29,-90],'rock',False)
route(a,'Main',[[0,2,120],[0,2,45],[0,5,25],[0,5,-25],[0,8,-45],[0,8,-70]])
route(a,'WestCourt',[[0,5,0],[-72,5,0],[-72,5,10]])
route(a,'EastCourt',[[0,5,0],[72,5,0],[72,5,10]])
for n,p,r in [('Arrival',[0,2,115],'Arrival'),('SentinelCourt',[-72,5,0],'Melee'),('CasterCourt',[72,5,0],'Spell'),('HoundApproach',[0,2,65],'Charge'),('ArcaneWarden',[0,8,-70],'Boss')]:marker(a,n,p,r)

for a in assets:
    assert all(all(v>0 for v in p['size']) for p in a['parts'])
    a['partCount']=len(a['parts']);a['encountersEnabled']=False
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=P,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda xyz:'V('+','.join(str(x) for x in xyz)+')'
lines=['--!strict','-- Generated regional geometry. RegionalWorld binds travel; encounter authority is separate.','local V=Vector3.new',
'type Piece={name:string,size:Vector3,pos:Vector3,color:Color3,collide:boolean,wedge:boolean,yaw:number}',
'type Marker={name:string,pos:Vector3,role:string}',
'type Route={name:string,points:{Vector3}}',
'type Region={id:string,parts:{Piece},markers:{Marker},routes:{Route}}','local regions:{Region}={']
for a in assets:
    lines.append('{id="'+a['id']+'",parts={')
    for p in a['parts']:lines.append('{name="%s",size=%s,pos=%s,color=Color3.fromRGB(%s),collide=%s,wedge=%s,yaw=%s},'%(p['name'],v(p['size']),v(p['position']),','.join(map(str,P[p['color']])),str(p['collide']).lower(),str(p['shape']=='Wedge').lower(),p['yaw']))
    lines.append('},markers={')
    for m in a['markers']:lines.append('{name="%s",pos=%s,role="%s"},'%(m['name'],v(m['position']),m['role']))
    lines.append('},routes={')
    for r in a['routes']:lines.append('{name="%s",points={%s}},'%(r['name'],','.join(v(p) for p in r['points'])))
    lines.append('}},')
lines.extend(['}', '''return function(): Folder
    local folder=Instance.new("Folder");folder.Name="AdventureMapKit"
    for _,def in ipairs(regions) do
        local model=Instance.new("Model");model.Name=def.id;model.WorldPivot=CFrame.identity
        model:SetAttribute("Region",def.id);model:SetAttribute("EncountersEnabled",false);model:SetAttribute("ArtVersion",1)
        for _,piece in ipairs(def.parts) do
            local p:BasePart=if piece.wedge then Instance.new("WedgePart") else Instance.new("Part")
            p.Name=piece.name;p.Size=piece.size;p.CFrame=CFrame.new(piece.pos)*CFrame.Angles(0,math.rad(piece.yaw),0)
            p.Color=piece.color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true
            p.CanCollide=piece.collide;p.CanQuery=piece.collide;p.CanTouch=false;p.Parent=model
        end
        local markers=Instance.new("Folder");markers.Name="EncounterMarkers";markers.Parent=model
        for _,entry in ipairs(def.markers) do
            local p=Instance.new("Part");p.Name=entry.name;p.Size=V(1,1,1);p.CFrame=CFrame.new(entry.pos)
            p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false
            p:SetAttribute("Role",entry.role);p.Parent=markers
        end
        local routes=Instance.new("Folder");routes.Name="ReviewRoutes";routes.Parent=model
        for _,entry in ipairs(def.routes) do
            local path=Instance.new("Folder");path.Name=entry.name;path.Parent=routes
            for index,pos in ipairs(entry.points) do
                local point=Instance.new("Vector3Value");point.Name=tostring(index);point.Value=pos;point.Parent=path
            end
        end
        model.Parent=folder
    end
    return folder
end'''])
(ROOT/'src/server/Services/AdventureMapKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('REGION_SHELLS',len(assets),'parts',sum(a['partCount'] for a in assets),'routes',sum(len(a['routes']) for a in assets))
