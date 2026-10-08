"""Twelve original modelable regional enemies from the Guildborne concept roster."""
from pathlib import Path
import json,math,copy
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/enemy-kit';OUT.mkdir(parents=True,exist_ok=True)
P={'leaf':[88,131,73],'skin':[134,152,84],'bark':[111,76,50],'cloth':[67,70,64],'stone':[114,116,123],
   'slate':[66,75,94],'steel':[163,179,185],'gold':[192,149,69],'amber':[249,164,65],'ivory':[225,211,170],
   'violet':[112,87,159],'cyan':[90,206,218],'eye':[246,213,113],'dark':[34,44,55]}
def skeleton(quad=False):
    result=[]
    def bone(n,h,t,p=None):result.append({'name':n,'head':h,'tail':t,'parent':p})
    bone('Root',[0,0,0],[0,.5,0])
    if quad:
        bone('Body',[0,1.4,.6],[0,1.9,-.5],'Root');bone('Head',[0,2,-1.25],[0,2.2,-2],'Body')
        bone('Tail',[0,1.8,1.3],[0,1.8,2.2],'Body')
        for end,z in [('Front',-1),('Rear',1)]:
            for side,x in [('Left',-.8),('Right',.8)]:
                n=end+side;bone(n+'UpperLeg',[x,1.6,z],[x,.9,z],'Body');bone(n+'LowerLeg',[x,.9,z],[x,.3,z],n+'UpperLeg');bone(n+'Foot',[x,.3,z],[x,.2,z-.35],n+'LowerLeg')
    else:
        bone('LowerTorso',[0,2.15,0],[0,2.8,0],'Root');bone('UpperTorso',[0,2.8,0],[0,3.75,0],'LowerTorso');bone('Head',[0,3.75,0],[0,4.85,0],'UpperTorso')
        for side,x in [('Left',-1),('Right',1)]:
            bone(side+'UpperArm',[x*1.05,3.65,0],[x*1.15,2.85,0],'UpperTorso');bone(side+'LowerArm',[x*1.15,2.85,0],[x*1.18,2.2,0],side+'UpperArm');bone(side+'Hand',[x*1.18,2.2,0],[x*1.18,1.9,0],side+'LowerArm')
            bone(side+'UpperLeg',[x*.48,2.15,0],[x*.48,1.15,0],'LowerTorso');bone(side+'LowerLeg',[x*.48,1.15,0],[x*.48,.35,0],side+'UpperLeg');bone(side+'Foot',[x*.48,.35,0],[x*.48,.2,-.6],side+'LowerLeg')
    return result
assets=[]
def box(p,n,s,v,c,b,rz=0,ry=0):p.append({'name':n,'size':s,'position':v,'color':c,'bone':b,'rotation':[0,ry,rz]})
def humanoid(p,skin,armor,cloth):
    for n,s,v,c,b in [('Waist',[1.45,.6,.78],[0,2.45,0],cloth,'LowerTorso'),('Chest',[1.7,.85,.95],[0,3.22,0],armor,'UpperTorso'),('Belt',[1.58,.2,.86],[0,2.35,0],'gold','LowerTorso'),('Head',[1.32,1.1,1.12],[0,4.35,0],skin,'Head')]:box(p,n,s,v,c,b)
    for side,x in [('Left',-1),('Right',1)]:
        box(p,side+'Eye',[.2,.14,.05],[x*.3,4.42,-.576],'eye','Head')
        for n,s,y,c,b in [('UpperArm',[.56,.72,.64],3.25,armor,'UpperArm'),('Shoulder',[.85,.35,.9],3.57,armor,'UpperArm'),('LowerArm',[.51,.56,.59],2.54,skin,'LowerArm'),('Hand',[.49,.35,.56],2.02,skin,'Hand')]:box(p,side+n,s,[x*1.16,y,0],c,side+b)
        for n,s,y,z,c,b in [('UpperLeg',[.61,.86,.68],1.68,0,cloth,'UpperLeg'),('LowerLeg',[.59,.7,.66],.75,0,armor,'LowerLeg'),('Boot',[.72,.42,1],.23,-.18,armor,'Foot')]:box(p,side+n,s,[x*.48,y,z],c,side+b)
def ears(p):
    for side in (-1,1):box(p,'PointedEar',[.72,.27,.38],[side*.9,4.5,0],'skin','Head',side*22)
    box(p,'Nose',[.33,.25,.33],[0,4.25,-.65],'skin','Head')
def sword(p):
    box(p,'SwordGrip',[.15,.6,.15],[1.35,2,-.35],'bark','RightHand');box(p,'SwordGuard',[.8,.16,.25],[1.35,2.33,-.35],'gold','RightHand');box(p,'SwordBlade',[.28,1.5,.12],[1.35,3.15,-.35],'steel','RightHand',-9)
def staff(p,c):
    box(p,'Staff',[.16,3.8,.16],[1.4,2,-.25],'bark','RightHand');box(p,'StaffGem',[.55,.65,.55],[1.4,4.05,-.25],c,'RightHand',45)
def shield(p,c):
    box(p,'Shield',[1.4,1.8,.3],[-1.42,2.25,-.5],c,'LeftHand');box(p,'ShieldCrest',[.55,.55,.12],[-1.42,2.4,-.72],'gold','LeftHand',45)
def crystal(p,n,v,c,b,s=.45):box(p,n,[s,s*1.5,s],v,c,b,45,45)
def add(id,region,role,scale=1,quad=False):
    a={'id':id,'region':region,'role':role,'boss':role=='Boss','rigType':'Quadruped' if quad else 'Humanoid','scale':scale,'parts':[],'bones':skeleton(quad)};assets.append(a);return a['parts']
p=add('greenwood_scout','Greenwood','Melee',.82);humanoid(p,'skin','bark','cloth');ears(p);sword(p)
box(p,'Hood',[1.48,.3,1.25],[0,4.95,.1],'leaf','Head')
p=add('greenwood_archer','Greenwood','Ranged',.8);humanoid(p,'skin','leaf','cloth');ears(p)
box(p,'Mask',[1.1,.32,.16],[0,4.15,-.62],'cloth','Head');box(p,'Quiver',[.65,1.5,.5],[.6,3,.85],'bark','UpperTorso')
for side in (-1,1):box(p,'BowLimb',[.18,1.15,.2],[-1.48,2.1+side*.5,-.4],'bark','LeftHand',side*-25)
box(p,'BowString',[.04,1.95,.04],[-1.76,2.1,-.4],'ivory','LeftHand')
for x in (.4,.6,.8):box(p,'Arrow',[.05,.8,.05],[x,3.9,.85],'ivory','UpperTorso')
def quadruped(p,body,trim,hound=False):
    box(p,'Body',[1.8,1.2,2.9],[0,1.85,0],body,'Body');box(p,'Head',[1.25,.95,1.3],[0,2,-1.7],body,'Head');box(p,'Snout',[.9,.58,.6],[0,1.75,-2.48],trim,'Head')
    for x in (-.42,.42):box(p,'Eye',[.15,.15,.08],[x,2.2,-2.39],'cyan' if hound else 'eye','Head')
    for end,z in [('Front',-1),('Rear',1)]:
        for side,x in [('Left',-.8),('Right',.8)]:
            n=end+side;box(p,n+'Thigh',[.58,.8,.65],[x,1.2,z],body,n+'UpperLeg');box(p,n+'Shin',[.42,.6,.5],[x,.55,z],trim,n+'LowerLeg');box(p,n+'Paw',[.65,.25,.85],[x,.17,z-.16],trim,n+'Foot')
    box(p,'Tail',[.25,.25,1.2],[0,1.85,1.95],trim,'Tail',0,12)
    for side in (-1,1):box(p,'Ear',[.33,.6,.4],[side*.48,2.65,-1.65],trim,'Head',side*20)
p=add('greenwood_boar','Greenwood','Charge',1,True);quadruped(p,'bark','leaf')
for side in (-1,1):box(p,'Tusk',[.18,.9,.2],[side*.59,1.9,-2.48],'ivory','Head',-side*25)
for z in (-.8,0,.8):box(p,'LeafArmor',[1.95,.2,.85],[0,2.55,z],'leaf','Body',0,15)
p=add('forest_captain','Greenwood','Boss',1.45);humanoid(p,'skin','bark','leaf');ears(p);shield(p,'bark');sword(p)
for side in (-1,1):
    box(p,'Antler',[.18,1.5,.25],[side*.73,5.45,0],'ivory','Head',-side*25)
    box(p,'AntlerBranch',[.6,.15,.2],[side*1.02,5.8,0],'ivory','Head',side*25)
    box(p,'LeafMantle',[1.3,.28,1.1],[side*1.1,3.85,0],'leaf',('Left' if side<0 else 'Right')+'UpperArm',side*15)
crystal(p,'CaptainCrest',[0,3.2,-.58],'cyan','UpperTorso',.3)
p=add('quarry_raider','Ironveil','Melee',.95);humanoid(p,'skin','slate','bark');ears(p)
box(p,'MiningHelm',[1.5,.35,1.3],[0,4.95,0],'stone','Head');crystal(p,'Headlamp',[0,5.25,-.4],'amber','Head',.27)
box(p,'PickHandle',[.15,2.3,.15],[1.35,2.4,-.3],'bark','RightHand',-15);box(p,'PickHead',[1.1,.18,.2],[1.6,3.43,-.3],'steel','RightHand',12)
p=add('stone_guard','Ironveil','Guard',1.15);humanoid(p,'stone','stone','slate');shield(p,'stone')
box(p,'StoneBrow',[1.45,.23,.3],[0,4.65,-.58],'slate','Head');crystal(p,'GuardCore',[0,3.2,-.6],'amber','UpperTorso',.32)
p=add('crystal_shaman','Ironveil','Support',.8);humanoid(p,'skin','gold','bark');ears(p);staff(p,'amber')
for x,y in [(-.43,5.02),(0,5.2),(.43,5.02)]:crystal(p,'CrownCrystal',[x,y,0],'amber','Head',.35)
p=add('quarry_guardian','Ironveil','Boss',1.6);humanoid(p,'stone','stone','slate')
for part in p:
    if any(n in part['name'] for n in ('Arm','Shoulder','Hand')):part['size']=[v*1.5 for v in part['size']]
box(p,'CoreFrame',[1.05,1.05,.2],[0,3.15,-.55],'gold','UpperTorso',45);crystal(p,'Core',[0,3.15,-.72],'amber','UpperTorso',.58)
for side in (-1,1):crystal(p,'ShoulderCrystal',[side*1.3,4,0],'amber',('Left' if side<0 else 'Right')+'UpperArm',.47)
crystal(p,'Crown',[0,5.2,0],'amber','Head',.44)
p=add('arcane_sentinel','Ashen','Melee',1.05);humanoid(p,'slate','steel','violet');staff(p,'cyan')
box(p,'Tabard',[1.2,1.5,.16],[0,1.9,-.49],'violet','LowerTorso');box(p,'Visor',[.18,.6,.12],[0,4.45,-.64],'cyan','Head')
p=add('rune_caster','Ashen','Spell',1.05);humanoid(p,'slate','violet','violet');staff(p,'violet')
for side in (-1,1):
    box(p,'FloatingMantle',[.4,2.2,.18],[side*.95,2.5,.65],'violet','UpperTorso',side*15)
    crystal(p,'OrbitShard',[side*1.95,3.1,-.2],'violet','UpperTorso',.4)
box(p,'Halo',[1.7,.12,.35],[0,5.1,0],'gold','Head');crystal(p,'Crown',[0,5.15,0],'cyan','Head',.28)
p=add('rune_hound','Ashen','Charge',1,True);quadruped(p,'slate','steel',True)
for z in (-.7,.1,.9):crystal(p,'DorsalRune',[0,2.6,z],'cyan','Body',.32)
for side in (-1,1):box(p,'FlankRune',[.1,.55,.75],[side*.94,2,0],'cyan','Body',20)
p=add('arcane_warden','Ashen','Boss',1.5);humanoid(p,'slate','steel','violet')
for i in range(8):
    a=i*math.pi/4;box(p,'CoreRing',[.48,.12,.12],[math.sin(a)*.6,3.17+math.cos(a)*.6,-.64],'gold','UpperTorso',-i*45)
crystal(p,'HollowCore',[0,3.17,-.69],'cyan','UpperTorso',.35)
for side in (-1,1):
    box(p,'CrownHorn',[.2,1.25,.3],[side*.6,5.25,0],'steel','Head',-side*20)
    crystal(p,'OrbitRune',[side*1.8,3.8,.15],'cyan','UpperTorso',.5)
    box(p,'SplitTabard',[.6,1.6,.2],[side*.35,1.55,-.5],'violet','LowerTorso',side*10)
for a in assets:
    s=a['scale']
    for part in a['parts']:part['position']=[v*s for v in part['position']];part['size']=[v*s for v in part['size']]
    for bone in a['bones']:bone['head']=[v*s for v in bone['head']];bone['tail']=[v*s for v in bone['tail']]
    assert len(a['parts'])<60 and all(p['bone'] in {b['name'] for b in a['bones']} for p in a['parts'])
(OUT/'kit.json').write_text(json.dumps({'schema':1,'units':'stud','upAxis':'Y','palette':P,'assets':assets},indent=2)+'\n',encoding='utf-8')
lines=['--!strict','-- Generated original static art templates; no live AI, rewards or encounter bindings.','local V=Vector3.new',
       'type Piece={name:string,size:Vector3,position:Vector3,rotation:Vector3,color:Color3,bone:string}',
       'type Asset={id:string,region:string,role:string,rig:string,parts:{Piece}}','local definitions: {Asset}={']
vec=lambda v:'V('+','.join(str(round(x,5)) for x in v)+')'
for a in assets:
    lines+=[f'\t{{id="{a["id"]}",region="{a["region"]}",role="{a["role"]}",rig="{a["rigType"]}",parts={{']
    for p in a['parts']:
        lines+=[f'\t\t{{name="{p["name"]}",size={vec(p["size"])},position={vec(p["position"])},rotation={vec(p["rotation"])},color=Color3.fromRGB({",".join(map(str,P[p["color"]]))}),bone="{p["bone"]}"}},']
    lines+=['\t}},']
lines+=['}','return function(): Folder','\tlocal folder=Instance.new("Folder");folder.Name="AdventureEnemyKit"',
'\tfor _,a in ipairs(definitions) do local m=Instance.new("Model");m.Name=a.id;m.WorldPivot=CFrame.identity;m.Parent=folder;m:SetAttribute("TemplateOnly",true);m:SetAttribute("Region",a.region);m:SetAttribute("VisualRole",a.role);m:SetAttribute("RigType",a.rig)',
'\t\tfor _,v in ipairs(a.parts) do local p=Instance.new("Part");p.Name=v.name;p.Size=v.size;p.CFrame=CFrame.new(v.position)*CFrame.Angles(math.rad(v.rotation.X),math.rad(v.rotation.Y),math.rad(v.rotation.Z));p.Color=v.color;p.Material=Enum.Material.SmoothPlastic;p:SetAttribute("BindBone",v.bone);p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=m end',
'\tend','\treturn folder','end','']
(ROOT/'src/server/Services/AdventureEnemyKit.luau').write_text('\n'.join(lines),encoding='utf-8')
print('ENEMY_KIT',len(assets),'models',sum(len(a['parts']) for a in assets),'parts')
