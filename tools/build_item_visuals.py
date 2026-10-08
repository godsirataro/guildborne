"""Original low-poly inventory display geometry, no third-party assets."""
from pathlib import Path
import json,copy,math
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/item-kit';OUT.mkdir(parents=True,exist_ok=True)
weapons=json.loads((ROOT/'assets/uat01/weapon-kit/kit.json').read_text(encoding='utf-8'))
palette={**weapons['palette'],'stone':[119,133,143],'violet':[129,114,198],'red':[154,68,61],'green':[94,175,163],'cloth':[174,156,123],'dark':[54,67,84]}
assets=copy.deepcopy(weapons['assets'])
def asset(id):
    a={'id':id,'parts':[]};assets.append(a);return a['parts']
def box(p,name,size,pos,color,rz=0):p.append({'name':name,'size':size,'position':pos,'rotation':[0,0,rz],'color':color})
def variant(id,source,recolors):
    a=copy.deepcopy(next(a for a in assets if a['id']==source));a['id']=id
    for p in a['parts']:p['color']=recolors.get(p['color'],p['color'])
    assets.append(a);return a['parts']
variant('training_sword','watchblade',{'steel':'wood','copper':'leather'})
variant('iron_sword','watchblade',{'copper':'gold'})
p=variant('knight_sword','oathblade',{'blue':'gold'});p[:]=[x for x in p if x['name']!='BladeShoulder']
p=variant('short_bow','yew_longbow',{'gold':'leather','leaf':'wood'})
for x in p:
    x['size']=[v*.8 for v in x['size']];x['position']=[v*.8 for v in x['position']]
variant('apprentice_staff','tide_staff',{'cyan':'green','steel':'gold'})
variant('mage_staff','tide_staff',{'cyan':'violet','steel':'gold'})
for id,color,style in [('leather_vest','leather','vest'),('guardian_plate','steel','plate'),('woven_robes','violet','robe'),
    ('scout_coat','leaf','coat'),('runewoven_mantle','blue','mantle'),('harbor_mail','blue','plate'),('vanguard_harness','copper','harness'),('pilgrim_robes','cloth','robe')]:
    p=asset(id);box(p,'Body',[1.7,1.65,.55],[0,0,0],color)
    for side in (-1,1):box(p,'Shoulder',[.63,.6,.65],[side*1.04,.63,0],color,side*-12)
    box(p,'Collar',[.9,.2,.64],[0,.87,0],'ivory');box(p,'Belt',[1.8,.2,.66],[0,-.65,0],'leather')
    box(p,'Buckle',[.28,.28,.1],[0,-.65,-.4],'gold')
    if style in ('robe','coat','mantle'):
        for side in (-1,1):box(p,'Skirt',[.91,.9,.58],[side*.43,-1.05,0],color,side*7)
    if style=='plate':
        box(p,'Breastplate',[1.25,1.1,.16],[0,.1,-.37],'steel')
        box(p,'Crest',[.22,.6,.12],[0,.1,-.52],'gold')
    elif style=='harness':
        for side in (-1,1):box(p,'Strap',[.23,1.6,.1],[side*.47,.1,-.35],'leather',side*25)
    elif style in ('robe','mantle'):
        for side in (-1,1):box(p,'Stole',[.22,1.7,.12],[side*.55,-.05,-.35],'gold')
        box(p,'Brooch',[.24,.3,.12],[0,.55,-.38],'cyan',45)
    else:
        for y in (-.3,.1,.5):box(p,'Fastener',[.14,.14,.09],[.15,y,-.34],'gold')
for id,color,style in [('bronze_ring','copper','ring'),('vitality_charm','green','gem'),('sentinel_seal','blue','seal'),('hunters_token','leaf','arrow'),('focus_prism','violet','prism'),('wardstone','green','ward')]:
    p=asset(id)
    if style=='ring':
        for i in range(8):
            a=i*math.pi/4;box(p,'Band',[.49,.18,.18],[.6*math.sin(a),.6*math.cos(a),0],color,-i*45)
        box(p,'Signet',[.36,.25,.28],[0,.7,0],'gold')
    else:
        box(p,'Bail',[.22,.33,.18],[0,.88,0],'gold')
        box(p,'Mount',[.95,1.05,.22],[0,.15,0],'gold',45 if style in ('prism','gem') else 0)
        box(p,'Stone',[.69,.8,.3],[0,.15,-.2],color,45 if style in ('prism','gem') else 0)
        if style=='arrow':
            box(p,'ArrowShaft',[.08,.75,.07],[0,.12,-.4],'ivory');box(p,'ArrowHead',[.3,.3,.07],[0,.46,-.4],'ivory',45)
        elif style=='seal':
            box(p,'Cross',[.5,.1,.08],[0,.2,-.4],'ivory');box(p,'CrossUpright',[.1,.7,.08],[0,.2,-.4],'ivory')
        elif style=='ward':
            for side in (-1,1):box(p,'WardRune',[.11,.6,.08],[side*.15,.15,-.4],'ivory',side*20)
        else:box(p,'Highlight',[.13,.4,.05],[-.12,.25,-.43],'ivory',20)
p=asset('stone')
for size,pos,rot in [([1.3,1,.95],[0,0,0],15),([.8,.7,.8],[.65,-.2,.1],-12),([.7,.65,.65],[-.7,-.3,.2],30)]:box(p,'Rock',size,pos,'stone',rot)
p=asset('iron_ore');box(p,'Rock',[1.5,1.1,1.05],[0,0,0],'dark',14)
for x,y in [(-.5,.2),(0,.48),(.48,-.1)]:box(p,'OreSeam',[.35,.58,.4],[x,y,-.4],'copper',x*40)
p=asset('iron_ingot');box(p,'Ingot',[1.8,.55,.8],[0,0,0],'steel');box(p,'TopBevel',[1.55,.15,.65],[0,.35,0],'steel')
p=asset('timber')
for x,y in [(-.35,-.2),(.35,-.2),(0,.4)]:
    box(p,'Log',[.63,.63,1.7],[x,y,0],'wood',10);box(p,'CutEnd',[.48,.48,.03],[x,y,-.87],'ivory',10)
box(p,'Binding',[1.35,.13,1.85],[0,0,0],'leather')
p=asset('herb');box(p,'Stem',[.12,1.65,.12],[0,0,0],'leaf',-10)
for i in range(5):
    side=1 if i%2 else -1;box(p,'Leaf',[.65,.27,.2],[side*.28,-.4+i*.29,-.05],'leaf',side*35)
box(p,'Flower',[.35,.35,.27],[.13,.88,0],'ivory',45)
assert len(assets)==30 and len({a['id'] for a in assets})==30
assert all(0<len(a['parts'])<=16 for a in assets)
(OUT/'kit.json').write_text(json.dumps({'schema':1,'units':'stud','palette':palette,'assets':assets},indent=2)+'\n',encoding='utf-8')
lines=['--!strict','-- Generated original display geometry; no gameplay statistics or asset IDs.','local V=Vector3.new','type Piece={name:string,size:Vector3,position:Vector3,rotation:Vector3,color:Color3,kind:string}','local definitions: {[string]: {Piece}}={']
vec=lambda x:'V('+','.join(str(round(v,5)) for v in x)+')'
for a in assets:
    lines.append('\t["'+a['id']+'"]={')
    for p in a['parts']:
        lines.append('\t\t{name='+json.dumps(p['name'])+',size='+vec(p['size'])+',position='+vec(p['position'])+',rotation='+vec(p['rotation'])+',color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+'),kind='+json.dumps('WedgePart' if p.get('shape')=='Wedge' else 'Part')+'},')
    lines.append('\t},')
lines+=['}','return function(id: string): Model?','\tlocal data=definitions[id];if not data then return nil end','\tlocal m=Instance.new("Model");m.Name=id;m.WorldPivot=CFrame.identity',
'\tfor _,v in ipairs(data) do local p=Instance.new(v.kind) :: BasePart;p.Name=v.name;p.Size=v.size;p.CFrame=CFrame.new(v.position)*CFrame.Angles(math.rad(v.rotation.X),math.rad(v.rotation.Y),math.rad(v.rotation.Z));p.Color=v.color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=m end',
'\treturn m','end','']
(ROOT/'src/shared/Data/ItemVisuals.luau').write_text('\n'.join(lines),encoding='utf-8')
print('ITEM_VISUALS',len(assets),sum(len(a['parts']) for a in assets),'parts')
