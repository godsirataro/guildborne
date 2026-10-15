from pathlib import Path
import json, shutil
root=Path.cwd()
d=root/'production/design'
shutil.copyfile(Path('C:/Users/godsi/.codex/attachments/1bb9c747-bb5d-4d01-863f-87874700ede7/Pasted text.txt'),d/'source-proposal.txt')
names=['FTUE','Hero tactical AI','Team combo','Combat feel and bosses','Hero identity and bond','Living Guild','Quests','Human Party6','Shared PvE and rewards','Economy and crafting','Mobile and accessibility','Save security and performance','Analytics','Guild research','World events','Endgame','Social and cosmetics','Daily season and shop','Website and discovery','Agent pipeline']
gates=['launch-core','vertical-slice','vertical-slice','launch-core','expansion','launch-core-plus-prototype','launch-core','launch-required','launch-required','launch-core','launch-required','launch-required','foundation','post-launch','post-launch','post-launch','launch-assets-plus-expansion','launch-required','optional','production']
owners=['gameplay-designer','combat-engineer','combat-engineer','combat-engineer','narrative-designer','guild-engineer','quest-designer','guild-engineer','systems-engineer','market-engineer','ui-designer','qa-lead','growth-analyst','gameplay-designer','quest-designer','gameplay-designer','character-artist','market-engineer','release-lead','producer']
deps={3:['02'],9:['08','12'],14:['06','10'],15:['09'],16:['07','09'],19:['04','17'],18:['12']}
features=[]
for i,(name,gate,owner) in enumerate(zip(names,gates,owners),1):
 features.append(dict(id=f'{i:02}',name=name,releaseGate=gate,ownerRole=owner,dependsOn=deps.get(i,[]),status='SOURCE_IMPLEMENTED_PENDING_INTEGRATION' if i in (2,13) else 'PARTIAL_LOCAL' if i in (8,20) else 'PLANNED_OR_EXISTING_BASE_REQUIRES_ACCEPTANCE',publicCopyApproved=False))
(d/'features.json').write_text(json.dumps(dict(schemaVersion=1,date='2026-10-14',publicReady=False,source='source-proposal.txt',features=features),indent=2)+'\n',encoding='utf-8')
text='''# Guildborne complete expansion implementation plan — 2026-10-14

The attached 20-theme proposal is retained verbatim in source-proposal.txt. This reconciled plan governs implementation; proposal examples and P0/P1 labels are not evidence of shipped features. features.json tracks all twenty themes with ownership, dependencies and release classification. None is approved public marketing copy.

## Fixed Public boundary

Lv1–35; two arcs / twelve chapter steps; four cosmetic races and thirteen presets; one human owner with up to five NPC heroes; six-human Party plus Solo sharing PvE spaces and conserved EXP/loot; Hall, crafting, Premium/Battle Pass and free daily. Guild has no other human members. Federation is later human association. Party lifecycle alone does not complete shared travel, encounters or settlement.

## Execution sequence

1. Integrate bounded tactical commands and sanitized milestone analytics into the existing modules. Balanced preserves existing targeting; Defensive protects the leader within a bounded range; Hold captures a server position; Regroup uses safe role positions. No profile migration or external analytics activation.
2. Validate command readability and FTUE through ordinary play. Borrowed tutorial allies cannot grant permanent recruitment, class proof or Hall eligibility. The proposed 5–30 minute targets are hypotheses to measure.
3. Prototype one Knight Taunt → Mage Fireball → Archer Piercing Shot combo using existing skills and authority. Fireball currently is single-target and Piercing Shot has no weak-point mechanic. Timing/bonus remain proposed. Preserve canonical Rowan as Warrior. See TEAM_COMBO_DESIGN.md.
4. Implement shared encounter ownership, eligibility snapshots and durable conserved reward settlement, then shared travel. This mandatory Public work must not wait for Bond, Research or a website. Prove replay/crash/disconnect recovery before real two-, four- and six-client acceptance.
5. Prototype Training Ground and Strategy Table on existing Hall systems; practice gives no campaign XP, loot or proof. Expand living Guild/bond/research only after core-loop acceptance.
6. Close launch asset imports/fit/audio, commerce receipts, persistence/migrations, physical mobile, multiplayer, human UAT and release gates. Freeze one candidate and review its evidence before any publishing decision.
7. After launch: world events, expanded bond/research, Lv70–100 content, Federation/war and market under their separate authority and economy gates. Website and motion tools use reviewed real gameplay evidence.

## Implementation and evidence

Three scoped Forge tasks were added: hero-tactics-slice, analytics-foundation, expansion-integration. There are 45 task definitions, 33 roles, 31 skills and 10 workflows; definitions are not completed tasks. Existing Forge/Studio and the one coordinator ledger remain the orchestration system. Agent workers own separate files, with an independent source reviewer. No competing runtime services or orchestrator are introduced.

Current source slices are implemented; automated integration and runtime acceptance are recorded separately in integration/REPORT.md. Existing party evidence remains candidate-specific. No overall readiness percentage is inferred from source/test counts.

## Design contracts

- GAME_DESIGN_PILLARS.md — identity, scope and authority
- FTUE_AND_FUN_GATES.md — onboarding and observed fun gates
- HERO_TACTICS_CONTRACT.md — bounded commands and acceptance
- TEAM_COMBO_DESIGN.md — first three-role prototype
- HERO_BOND_DESIGN.md — identity and future bond
- LIVING_GUILD_DESIGN.md — Hall prototypes
- SHARED_PVE_INTEGRATION.md — mandatory shared authority and rewards
- BALANCE_AND_ANALYTICS.md — sanitized observations and balance
- LIVEOPS_AND_RETENTION.md — daily/season and future events
- PUBLIC_WEB_CONTENT.md — truthful content and future website scope

## Agentic completion contract

Claim → inspect actual modules → implement within ownership → focused regression → full baseline → independent review → local Studio evidence → record limitations/lesson. Auto-learning cannot change costs, publishing permissions or server authority. Missing device/cloud access blocks that acceptance only. Tools/assets stay free by default; research candidates are reviewed individually before installation. No public publishing, production writes, paid upload or live commerce is authorized by this plan update.
'''
(d/'EXPANSION_PLAN.md').write_text(text,encoding='utf-8')
p=root/'production/LATEST_GOALS.md'
s=p.read_text(encoding='utf-8');s='Expansion update: [20-theme implementation plan](design/EXPANSION_PLAN.md) and [feature registry](design/features.json). Tactical/analytics source slices are now being integrated; all Public gates remain required.\n\n'+s;p.write_text(s,encoding='utf-8')
p=root/'production/LAUNCH_PLAN.md'
with p.open('a',encoding='utf-8') as f:f.write('\n## Complete expansion update\n\nSee [the reconciled twenty-theme plan](design/EXPANSION_PLAN.md) and feature registry. Tactical AI and analytics are the first implementation slices; Combo, FTUE and living Guild have explicit contracts. Shared PvE/conserved settlement remains mandatory before Public. This update does not mark source changes as runtime/device acceptance.\n')
p=root/'production/launch/backlog.json';b=json.loads(p.read_text(encoding='utf-8'))
b['expansionPlan']='production/design/EXPANSION_PLAN.md'
for tid,role in [('hero-tactics-slice','combat-engineer'),('analytics-foundation','growth-analyst'),('expansion-integration','technical-director')]:
 if not any(x['id']==tid for x in b['items']):b['items'].append(dict(id=tid,phase='expansion-foundation',ownerRole=role,status='SOURCE_IMPLEMENTED_PENDING_INTEGRATION',remainingOrEvidence='production/design/integration/REPORT.md; runtime, device and human acceptance separate'))
p.write_text(json.dumps(b,indent=2)+'\n',encoding='utf-8')

