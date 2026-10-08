"""Fifteen original companion visual templates matching all registry hero slot IDs."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/hero-kit';OUT.mkdir(parents=True,exist_ok=True)
P={'skin_light':[219,177,139],'skin_mid':[175,122,87],'skin_dark':[109,73,59],'steel':[161,178,191],'iron':[83,103,130],'gold':[209,169,79],'red':[152,67,65],'green':[66,113,80],'blue':[65,104,148],'purple':[112,82,150],'ivory':[223,215,188],'wood':[104,72,48],'dark':[39,44,57],'cyan':[90,203,218],'hair':[71,50,43]}
def skeleton():
    b=[]
    def add(n,h,t,parent=None):b.append(dict(name=n,head=h,tail=t,parent=parent))
    add('Root',[0,0,0],[0,.5,0]);add('LowerTorso',[0,2.15,0],[0,2.8,0],'Root');add('UpperTorso',[0,2.8,0],[0,3.75,0],'LowerTorso');add('Head',[0,3.75,0],[0,4.85,0],'UpperTorso')
    for side,x in [('Left',-1),('Right',1)]:
        add(side+'UpperArm',[x*1.05,3.65,0],[x*1.15,2.85,0],'UpperTorso');add(side+'LowerArm',[x*1.15,2.85,0],[x*1.18,2.2,0],side+'UpperArm');add(side+'Hand',[x*1.18,2.2,0],[x*1.18,1.9,0],side+'LowerArm')
        add(side+'UpperLeg',[x*.48,2.15,0],[x*.48,1.15,0],'LowerTorso');add(side+'LowerLeg',[x*.48,1.15,0],[x*.48,.35,0],side+'UpperLeg');add(side+'Foot',[x*.48,.35,0],[x*.48,.2,-.6],side+'LowerLeg')
    return b
assets=[]
for cls,main in [('Knight','blue'),('Warrior','red'),('Archer','green'),('Mage','purple'),('Priest','ivory')]:
    for variant in range(1,4):
        id=f'{cls.lower()}_{variant:02}';p=[];skin=['skin_light','skin_mid','skin_dark'][variant-1]
        def box(n,s,pos,c,bone='UpperTorso',rz=0,ry=0):p.append(dict(name=n,size=s,position=pos,color=c,bone=bone,rotation=[0,ry,rz]))
        armor='steel' if cls=='Knight' else main
        for n,s,pos,c,b in [('Waist',[1.45,.6,.78],[0,2.45,0],main,'LowerTorso'),('Chest',[1.7,.85,.95],[0,3.22,0],armor,'UpperTorso'),('Belt',[1.58,.2,.86],[0,2.35,0],'wood','LowerTorso'),('Head',[1.32,1.1,1.12],[0,4.35,0],skin,'Head')]:box(n,s,pos,c,b)
        for side,x in [('Left',-1),('Right',1)]:
            box(side+'Eye',[.13,.14,.05],[x*.3,4.42,-.576],'dark','Head')
            for n,s,y,c,b in [('UpperArm',[.56,.72,.64],3.25,main,'UpperArm'),('Shoulder',[.85,.35,.9],3.57,armor,'UpperArm'),('LowerArm',[.51,.56,.59],2.54,skin,'LowerArm'),('Hand',[.49,.35,.56],2.02,skin,'Hand')]:box(side+n,s,[x*1.16,y,0],c,side+b)
            for n,s,y,z,c,b in [('UpperLeg',[.61,.86,.68],1.68,0,'dark','UpperLeg'),('LowerLeg',[.59,.7,.66],.75,0,main,'LowerLeg'),('Boot',[.72,.42,1],.23,-.18,'wood','Foot')]:box(side+n,s,[x*.48,y,z],c,side+b)
        box('GuildClasp',[.3,.4,.13],[0,3.5,-.56],'gold')
        box('Hair',[1.39,.29,1.18],[0,4.99,.02],'hair','Head')
        if cls=='Knight':
            box('Breastplate',[1.45,.7,.18],[0,3.15,-.58],'iron');box('Shield',[1.45,1.85,.3],[-1.4,2.25,-.5],main,'LeftHand');box('ShieldMark',[.3,1.2,.1],[-1.4,2.3,-.71],'gold','LeftHand')
            if variant==1:box('OpenHelm',[1.5,.3,1.3],[0,5.12,0],'steel','Head')
            elif variant==2:
                box('GreatHelm',[1.5,.8,1.28],[0,4.72,0],'iron','Head');box('Visor',[1.25,.13,.1],[0,4.55,-.69],'dark','Head')
            else:
                box('Crest',[.28,.9,1.45],[0,5.32,.05],'blue','Head');box('Cape',[1.85,2.3,.22],[0,2.8,.68],main)
        elif cls=='Warrior':
            box('ChestStrap',[.26,1.2,.18],[0,3.22,-.55],'wood',rz=-35)
            if variant==1:box('Headband',[1.39,.22,1.24],[0,4.84,0],main,'Head')
            elif variant==2:
                box('FurMantle',[2.4,.38,1.4],[0,3.85,.1],'ivory');box('Beard',[.9,.6,.2],[0,3.99,-.62],'hair','Head')
            else:
                box('BattleHelm',[1.5,.45,1.3],[0,5.08,0],'iron','Head')
                for side in (-1,1):box('HelmWing',[.35,.8,.5],[side*.78,5.4,.1],'gold','Head',side*25)
        elif cls=='Archer':
            box('Quiver',[.65,1.4,.55],[.65,3.2,.8],'wood')
            for x in (.43,.65,.86):box('Arrow',[.05,.8,.05],[x,4.1,.8],'ivory')
            box('Hood',[1.48,.4,1.3],[0,5.1,0],main,'Head')
            if variant>=2:box('CowlBack',[1.48,1.1,.25],[0,4.6,.65],main,'Head');box('Cloak',[1.8,2.3,.2],[0,2.8,.72],main)
            if variant==3:
                box('FaceWrap',[1.15,.37,.15],[0,4.03,-.62],'ivory','Head');box('Feather',[.13,.85,.25],[.68,5.62,.12],'gold','Head',-20)
        elif cls=='Mage':
            box('Robe',[1.6,1.3,1.05],[0,1.6,.1],main,'LowerTorso')
            if variant==1:
                box('HatBrim',[2,.15,1.6],[0,5.2,0],main,'Head');box('HatCrown',[.85,.8,.85],[0,5.67,0],main,'Head');box('HatTip',[.4,.55,.4],[.15,6.25,0],main,'Head')
            elif variant==2:
                box('ScholarHood',[1.5,.5,1.3],[0,5.15,.1],'blue','Head');box('Book',[.8,1,.25],[-1.3,2.1,-.5],'gold','LeftHand')
            else:
                for side in (-1,1):box('CrystalCrown',[.24,.8,.28],[side*.47,5.42,0],'cyan','Head',side*15)
                box('Mantle',[2.5,.3,1.3],[0,3.8,.1],'blue')
        else:
            box('Robe',[1.65,1.3,1.05],[0,1.6,.1],main,'LowerTorso')
            for x in (-.55,.55):box('Stole',[.28,1.8,.14],[x,2.9,-.59],'red' if variant==1 else 'gold')
            box('Circlet',[1.42,.16,1.25],[0,5.08,0],'gold','Head')
            if variant==2:box('Mitre',[.9,.85,.65],[0,5.52,0],'ivory','Head')
            if variant==3:
                box('Mantle',[2.45,.4,1.35],[0,3.8,.15],'gold');box('SunCrest',[.5,.5,.12],[0,5.5,-.5],'gold','Head',45)
        if cls in ('Knight','Warrior'):
            box('Grip',[.15,.55,.15],[1.35,2,-.35],'wood','RightHand');box('Guard',[.8,.15,.22],[1.35,2.3,-.35],'gold','RightHand');box('Blade',[.3,1.7,.15],[1.35,3.2,-.35],'steel','RightHand')
        elif cls=='Archer':
            for side in (-1,1):box('BowLimb',[.15,1.15,.2],[-1.48,2.1+side*.5,-.4],'wood','LeftHand',side*-25)
            box('Bowstring',[.03,1.95,.03],[-1.76,2.1,-.4],'ivory','LeftHand')
        else:
            box('Staff',[.15,3.6,.15],[1.35,2,-.3],'wood','RightHand');box('Focus',[.5,.6,.5],[1.35,4,-.3],'cyan' if cls=='Mage' else 'gold','RightHand',45)
        assets.append(dict(id=id,region=cls,role='Support' if cls=='Priest' else 'Spell' if cls=='Mage' else 'Ranged' if cls=='Archer' else 'Melee',rigType='Humanoid',parts=p,bones=skeleton(),designId='ui.heroes.'+id,recruitmentBound=False))
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=P,assets=assets),indent=2)+'\n',encoding='utf-8')
source=json.loads((ROOT/'docs/uat01/intake/registry-reconciled.json').read_text(encoding='utf-8'))
expected={x['designId'] for x in source['assets'] if x['group']=='heroes'}
assert expected=={a['designId'] for a in assets}
print('HERO_TEMPLATES',len(assets),'parts',sum(len(a['parts']) for a in assets),'registryCoverage',len(expected))
