"""Eight original cosmetic art prototypes; no ownership or gameplay bonuses."""
from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/cosmetic-kit';OUT.mkdir(parents=True,exist_ok=True)
P={'burgundy':[129,55,71],'gold':[214,169,75],'ivory':[229,218,191],'navy':[43,57,82],'cyan':[89,207,219],'blue':[155,202,241],'wood':[113,79,53],'stone':[117,132,151],'gray':[143,148,157]};assets=[]
def model(id,kind):
    a=dict(id=id,kind=kind,parts=[],entitlementBound=False);assets.append(a);return a
def box(a,n,s,p,c,rz=0,ry=0):a['parts'].append(dict(name=n,size=s,position=p,color=c,rotation=[0,ry,rz]))
def ring(a,n,center,radius,segments,color,width=.18):
    x,y,z=center
    for i in range(segments):
        t=i*math.tau/segments;box(a,n,[math.tau*radius/segments*1.07,width,width],[x+math.sin(t)*radius,y+math.cos(t)*radius,z],color,-math.degrees(t))
a=model('founder_cloak','Back')
box(a,'Cape',[2.2,2.8,.18],[0,1.8,.45],'burgundy')
for x in (-1.03,1.03):box(a,'Trim',[.14,2.8,.23],[x,1.8,.44],'gold')
box(a,'Hem',[2.2,.14,.23],[0,.4,.44],'gold');box(a,'Collar',[2.45,.3,.5],[0,3.25,.4],'ivory');box(a,'Brooch',[.48,.48,.15],[.65,3.16,.06],'gold',45)
a=model('compass_blade','WeaponSkin')
box(a,'Grip',[.2,1,.22],[0,.5,0],'navy');box(a,'Guard',[1.25,.18,.35],[0,1.08,0],'gold');box(a,'Blade',[.42,2.5,.17],[0,2.35,0],'gold')
box(a,'Inlay',[.13,2.25,.05],[0,2.35,-.12],'cyan');box(a,'Pommel',[.4,.4,.3],[0,-.12,0],'gold',45)
a=model('company_banner','GuildDecoration')
box(a,'Pole',[.17,6,.17],[0,3,0],'wood');box(a,'Crossbar',[3.3,.17,.17],[0,5.9,0],'gold');box(a,'Banner',[2.9,3.8,.14],[0,3.88,-.05],'navy')
box(a,'BannerHem',[2.9,.16,.18],[0,2,-.05],'gold');ring(a,'Compass',[0,4.1,-.18],.68,8,'gold',.12)
box(a,'CompassNeedle',[.12,1.7,.1],[0,4.1,-.22],'ivory',25)
a=model('hearth_decor','GuildDecoration')
box(a,'Rug',[5,.1,4],[0,.05,0],'burgundy')
for x in (-2.35,2.35):box(a,'RugTrim',[.12,.12,4],[x,.1,0],'gold')
box(a,'Seat',[1.8,.3,1.6],[-.8,1.1,0],'wood');box(a,'Back',[1.8,1.7,.22],[-.8,1.9,.72],'wood')
for x in (-1.5,-.1):
    for z in (-.55,.55):box(a,'ChairLeg',[.22,1,.22],[x,.55,z],'wood')
box(a,'LanternBase',[.85,.15,.85],[1.35,.25,0],'gold');box(a,'LanternGlow',[.55,.75,.55],[1.35,.68,0],'ivory');box(a,'LanternTop',[.85,.18,.85],[1.35,1.12,0],'gold')
a=model('ivory_portrait_frame','PortraitFrame')
for x in (-1.6,1.6):box(a,'Side',[.28,3.7,.3],[x,2,0],'ivory')
for y in (.15,3.85):box(a,'Rail',[3.5,.28,.3],[0,y,0],'ivory')
for x in (-1.6,1.6):
    for y in (.15,3.85):box(a,'Corner',[.48,.48,.34],[x,y,-.02],'gold',45)
box(a,'Crest',[.55,.55,.24],[0,4.2,0],'gold',45)
a=model('friendly_greeting','EmotePreview')
for n,s,p,c,rz in [('Body',[1.6,1.8,.9],[0,2.5,0],'gray',0),('Head',[1.1,1.1,1.1],[0,4,0],'gray',0),('LeftArm',[.55,1.8,.6],[-1.1,2.5,0],'gray',0),('RaisedArm',[.55,1.8,.6],[1.15,3.7,0],'gray',-30),('Hand',[.6,.6,.6],[1.7,4.65,0],'ivory',-30),('LeftLeg',[.65,1.6,.7],[-.43,.8,0],'gray',0),('RightLeg',[.65,1.6,.7],[.43,.8,0],'gray',0)]:box(a,n,s,p,c,rz)
for x in (-.24,.24):box(a,'Eye',[.12,.12,.05],[x,4.05,-.575],'navy')
for y in (4.5,5):box(a,'MotionEcho',[.7,.09,.1],[2.5,y,0],'cyan',20)
a=model('rune_portal','PortalAppearance')
ring(a,'BrassRing',[0,3,0],2.5,16,'gold',.35);ring(a,'InnerLight',[0,3,-.12],2.17,16,'cyan',.13)
for x in (-2.7,2.7):box(a,'RuneStone',[.75,1.6,.85],[x,.8,0],'stone');box(a,'Rune',[.15,.8,.08],[x,.85,-.47],'cyan')
a=model('pale_spell_trail','SpellAppearancePreview')
box(a,'Wand',[.16,2,.16],[0,1.1,0],'wood',-25);box(a,'WandTip',[.35,.35,.35],[.46,2.1,0],'ivory',45)
for i in range(12):
    t=i/11*math.tau;size=.12+.14*i/11
    box(a,'Spark',[size,size,size],[math.cos(t)*(.7+i*.04),1.2+i*.2,math.sin(t)*.4],'blue',45,45)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=P,assets=assets),indent=2)+'\n',encoding='utf-8')
print('COSMETIC_ART',len(assets),'parts',sum(len(a['parts']) for a in assets))
