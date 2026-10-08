"""Validate copied design graphs without modifying sources or enabling runtime rules."""
from pathlib import Path
from collections import Counter
import json,hashlib,sys

ROOT=Path(__file__).resolve().parents[1]
FOLDER=ROOT/'docs/uat01/intake'
def audit(rules,classes,quests):
    errors=[];warnings=[]
    def issue(code,id,detail):errors.append({'code':code,'id':id,'detail':detail})
    def index(rows,kind):
        out={}
        for row in rows:
            key=row.get('id')
            if not isinstance(key,str) or not key:issue('invalid_id',kind,str(key));continue
            if key in out:issue('duplicate_id',key,kind)
            out[key]=row
        return out
    cq=index(classes,'class');qq=index(quests,'quest')
    for key,q in qq.items():
        for parent in q.get('prerequisite_design_ids',[]):
            if parent not in qq:issue('missing_prerequisite',key,parent)
        level=q.get('recommended_level')
        if type(level)!=int or not 1<=level<=100:issue('invalid_quest_level',key,str(level))
        if not q.get('objectives_th'):issue('missing_objectives',key,'No objectives')
    colors={};order=[]
    def visit(key,stack):
        if colors.get(key)==1:issue('quest_cycle',key,' -> '.join(stack+[key]));return
        if colors.get(key)==2:return
        colors[key]=1
        for parent in qq[key].get('prerequisite_design_ids',[]):
            if parent in qq:visit(parent,stack+[key])
        colors[key]=2;order.append(key)
    for key in qq:visit(key,[])
    abilities=set()
    for key,c in cq.items():
        tier=c.get('tier');parent=c.get('parent_id')
        if tier not in (1,2,3):issue('invalid_class_tier',key,str(tier));continue
        if c.get('unlock_level')!={1:10,2:35,3:70}[tier]:issue('class_level_mismatch',key,str(c.get('unlock_level')))
        if tier==1:
            if parent is not None or c.get('base_class_id')!=key:issue('invalid_class_root',key,str(parent))
        elif parent not in cq:issue('missing_class_parent',key,str(parent))
        elif cq[parent]['tier']!=tier-1 or cq[parent]['base_class_id']!=c['base_class_id']:issue('class_parent_mismatch',key,parent)
        children=c.get('next_choices',[])
        expected=sorted(k for k,v in cq.items() if v.get('parent_id')==key)
        if sorted(children)!=expected:issue('class_children_mismatch',key,str(children))
        active=c.get('active_ability_concepts',[])
        if len(active)!=3:issue('active_skill_count',key,str(len(active)))
        for a in active:
            aid=a.get('id')
            if not aid or aid in abilities:issue('duplicate_ability',key,str(aid))
            abilities.add(aid)
        trial=qq.get('CLASS_'+key.upper())
        if not trial:issue('missing_class_trial',key,'Missing class quest')
        elif trial.get('class_id')!=key or trial.get('required_entity_level')!=c['unlock_level'] or trial.get('required_previous_class_id')!=parent:
            issue('trial_gate_mismatch',key,trial['id'])
    schedule=rules.get('hall_schedule',[])
    if [h.get('hall_level') for h in schedule]!=list(range(1,21)):issue('hall_schedule_incomplete','Hall','Expected ordered levels 1–20')
    previous=10
    for h in schedule:
        level=h['hall_level'];expected=min(100,20+5*(level-1))
        if h['level_cap']!=expected:issue('hall_cap_mismatch',str(level),str(h['level_cap']))
        if h['minimum_player_level']>previous:issue('hall_level_deadlock',str(level),f"Requires {h['minimum_player_level']} but previous cap {previous}")
        permit=h.get('permit_quest_design_id')
        if permit not in qq:issue('missing_hall_permit',str(level),str(permit))
        elif qq[permit]['recommended_level']>previous:
            warnings.append({'code':'permit_recommended_above_previous_cap','id':permit,'detail':f"Recommended {qq[permit]['recommended_level']}; previous cap {previous}. Recommendation is not assumed to be a hard gate."})
        previous=expected
    if not schedule or schedule[0].get('cost')!='FREE_STORY_GRANT':issue('first_hall_not_free','Hall1','First Hall must be story-granted')
    for level in (10,35,70,100):
        if rules.get('skill_points',{}).get('level'+str(level))!=level-1:issue('sp_budget_mismatch',str(level),'Expected level minus one')
        if rules.get('status_points',{}).get('level'+str(level))!=3*(level-1):issue('ap_budget_mismatch',str(level),'Expected three per level after one')
    tree=rules.get('skill_tree',{});tier=tree.get('per_tier',{})
    calculated=tier.get('active_skills',0)*tier.get('active_max_rank',0)+tier.get('passives',0)*tier.get('passive_max_rank',0)+tier.get('rune_groups',0)*tier.get('max_choices_per_group',0)*tier.get('rune_cost_per_choice',0)+tier.get('capstone_count',0)*tier.get('capstone_cost',0)
    if calculated!=39 or tier.get('total_full_tier_cost')!=calculated:issue('tree_cost_mismatch','SkillTree',str(calculated))
    if tree.get('selected_path_max_cost')!=3*calculated or tree.get('level100_budget')!=99:issue('path_budget_mismatch','SkillTree','Expected 117 cost / 99 budget')
    warnings.append({'code':'prose_gates_not_executable','id':'All content','detail':'Prerequisite arrays do not encode every story, Hall, class, entity, checkpoint or reward rule. Acyclic design does not prove playable progression.'})
    return {'errors':errors,'warnings':warnings,'topologicalQuestOrder':order,
        'counts':{'classes':len(classes),'quests':len(quests),'abilityConcepts':len(abilities),'questCategories':dict(Counter(q['category'] for q in quests))},
        'unboundClasses':[c['id'] for c in classes if c.get('production_class_id') is None],
        'unboundQuests':[q['id'] for q in quests if q.get('production_quest_id') is None],
        'runtimeReady':False,'sourceModified':False}

def load():
    files=['PROGRESSION_RULES_DRAFT.json','CLASS_PATHS_DRAFT.json','QUEST_CATALOG_DRAFT.json']
    docs=[json.loads((FOLDER/f).read_text(encoding='utf-8')) for f in files]
    return docs[0],docs[1]['classes'],docs[2]['quests']

if __name__=='__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    report=audit(*load())
    report['sources']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in FOLDER.glob('*_DRAFT.json')}
    (FOLDER/'progression-audit.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:report[k] for k in ['counts','errors','warnings','runtimeReady']},ensure_ascii=False,indent=2))
    raise SystemExit(1 if report['errors'] else 0)
