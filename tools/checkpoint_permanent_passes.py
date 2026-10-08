"""Idempotent 2026-10-06 evidence checkpoint; never edits imported source workbook."""
from pathlib import Path
import json,re
r=Path(__file__).resolve().parents[1]
header='> Permanent ownership checkpoint — 2026-10-06: five root classes passed the isolated Keeper arena using normal input, each3rescues/3seals/6basic hits/0mistakes; this is not five full campaigns. Disabled permanent Game Pass offers/restore now cover land and themes, quest/material gates, durable recovery and session checks;20new scenarios,653domain tests.48native UIviews/750bounds/12captured callbacks; no actual purchases.300strict runtime sources/eight builds. Registry428assets/34generatedPNG. Quota67%used/33%remaining; continue to25%remaining, checkpoint/stop owned work, then normal shutdown.'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 s=re.sub(r'^> Permanent ownership checkpoint[^\n]*\n\n','',s)
 p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8')
s=s.replace('633 domain tests; 294 runtime sources','653 domain tests; 300 runtime sources')
rows={
'Guild land':'| Guild land | Three quest-gated plots, material accounting/native terrain; disabled Game Pass offers and durable restore; 20 ownership/prompt scenarios, 48 EN/TH native views/750 bounds across land/themes | Real pass IDs, actual Roblox purchase/rejoin/outage, persistent migration and human/device acceptance |',
'Building themes':'| Building themes | Six utility/Hall themes, free Human and quest Orc; disabled paid theme offers/restore, per-building selection; 5287 Hall checks/48 door routes | Real platform purchase/rejoin, imported art, furniture geometry polish and multiplayer/device acceptance |',
}
for area,row in rows.items():s=re.sub(r'^\| '+re.escape(area)+r' \|[^\n]*$',row,s,flags=re.M)
p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8');s=re.sub(r'Latest observed quota: \d+% used / \d+% remaining\.', 'Latest observed quota: 67% used / 33% remaining.',s,count=1);p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId']=='world.archiveheart.boss.keeper_of_names':
  a['source']='assets/uat01/archive-heart-bosses/keeper_of_names.blend; src/server/Services/ArchiveHeartBossKit.luau; docs/uat01/validation-archive-five-roots-native.json'
  a['productionBinding']='Fresh full Mage campaign complete; five roots separately passed isolated Keeper normal-input basic route (3rescues/3seals/6hits/0mistakes each). Final art, imports, multiplayer/devices/human UAT pending.'
for s in d['screens']:
 if s['designId'] in ['screen.launch.land','screen.launch.building_themes']:
  s['status']='PAID_OFFERS_DISABLED_NATIVE_UI_VERIFIED_UAT_PENDING'
  s['requiredBehavior']='Quest-gated land or permanent cosmetic theme; server key/ownership checks and durable restore; IDs zero/feature disabled.48native UIcases/750bounds/12captured callbacks. Actual platform purchase acceptance pending.'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('CHECKPOINT: 428 assets, 73 screens; no source workbook changes')
