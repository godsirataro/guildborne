"""Original Ironveil work clothes and tools on existing editable Guildborne rigs."""
from pathlib import Path
import copy,json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/ironveil-cast';OUT.mkdir(parents=True,exist_ok=True)
course=json.loads((ROOT/'assets/uat01/course-characters/kit.json').read_text(encoding='utf-8'))
orcs=json.loads((ROOT/'assets/uat01/friendly-orcs/kit.json').read_text(encoding='utf-8'))
palette=course['palette']|{'copper':[191,117,61],'coal':[46,57,67],'work_teal':[73,145,147],'chalk':[231,221,190]}
palette.update({'orc_'+k:v for k,v in orcs['palette'].items()})
assets=[]
for identity in ['miner','engineer','carrier']:
    base=next(a for a in (orcs if identity=='carrier' else course)['assets'] if a['id']==('borga' if identity=='carrier' else 'dwarf_traveler'))
    a=copy.deepcopy(base);a.update(id=identity,designId='npc.ironveil.'+identity,region='Orc' if identity=='carrier' else 'Dwarf',role='Story',friendly=True)
    removed={'Pack','Bedroll','MapRoll','Apron','Pocket','Mug','MugRim','BreadPouch'}
    a['parts']=[p for p in a['parts'] if p['name'] not in removed]
    for p in a['parts']:
        if identity=='carrier':p['color']='orc_'+p['color']
        elif p['color']=='red':p['color']='work_teal' if identity=='engineer' else 'coal'
    def box(name,size,pos,color,bone='UpperTorso',rz=0):a['parts'].append(dict(name=name,size=size,position=pos,color=color,bone=bone,rotation=[0,0,rz]))
    if identity!='carrier':
        box('SafetyHelmet',[1.85,.36,1.5],[0,3.95,0],'copper','Head')
        box('HelmetRim',[1.95,.12,1.65],[0,3.78,0],'coal','Head')
        box('LampHousing',[.48,.38,.2],[0,3.94,-.8],'coal','Head')
        box('LampLens',[.28,.25,.1],[0,3.94,-.94],'chalk','Head')
        box('WorkApron',[1.6,1.45,.15],[0,2.1,-.72],'wood')
        for x in [-.55,.55]:box('ReflectiveStrip',[.16,.85,.09],[x,2.48,-.84],'chalk')
        if identity=='engineer':
            box('Blueprint',[.95,.7,.14],[1.38,1.64,-.65],'work_teal','RightHand')
            box('BlueprintMark',[.65,.07,.05],[1.38,1.76,-.75],'chalk','RightHand')
            box('ToolBelt',[1.7,.25,1.25],[0,1.7,0],'coal','LowerTorso')
            box('WrenchHandle',[.16,.63,.15],[-1.45,1.56,-.45],'steel','LeftHand')
            for x in [-1.61,-1.29]:box('WrenchJaw',[.13,.27,.16],[x,1.99,-.45],'steel','LeftHand')
        else:
            box('RescueBand',[.48,.22,.7],[-1.38,2.19,0],'chalk','LeftLowerArm')
            box('DustPatch',[.29,.16,.07],[.51,3.25,-.7],'coal','Head')
    else:
        box('CarrierHarness',[.26,1.8,.15],[-.55,3,-.71],'copper',rz=-14)
        box('CarrierHarness',[.26,1.8,.15],[.55,3,-.71],'copper',rz=14)
        box('OrePack',[1.8,1.5,.75],[0,3,.88],'wood')
        for x in [-.55,.55]:box('PackBand',[.18,1.55,.82],[x,3,.88],'copper')
        box('ReceiptBook',[.72,.87,.13],[1.42,2,-.54],'chalk','RightHand')
        box('ReceiptSeal',[.2,.2,.05],[1.42,2,-.64],'work_teal','RightHand',45)
    assert len(a['parts'])*12<1000
    assets.append(a)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
print('IRONVEIL_CAST',len(assets),'rigs',sum(len(a['parts']) for a in assets),'parts')
