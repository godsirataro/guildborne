"""Save measured Tower acceptance without promoting fixtures to release approval."""
from pathlib import Path
import json
r=Path(__file__).resolve().parents[1]
header='> Tower actual checkpoint — 2026-10-04: 545 domain tests pass; strict analysis has no source diagnostics; 257 runtime files and all 6 builds pass. Actual Chapter00-04 run reached revision168: Mage55/3023XP, Hall8, 870Gold, 21 campaign claims plus 6 novice claims. Tower orientation, midpoint exit/reentry, Guard/Mend/Combined support lessons and archive puzzle passed through normal input; Hall9 permit earned. Memory room, doors, final guardian and Hall11 actual acceptance remain pending. No profile grants. Court navigation annex fixed during Play; final-source fresh boot still pending. Registry389assets/73screens/33workareas,28generatedPNG. Last quota49%used/51%remaining; stop at50%remaining. Memory-only test progress is lost after Stop; evidence files preserve observations, not a resumable save.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 if s.startswith('> Tower actual checkpoint'):s=s.split('\n\n',1)[1]
 s=s.replace('Runtime validation is 543 tests','Runtime validation is 545 tests')
 p.write_text(header+s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest verified usage:47%used/53%remaining','Latest verified usage:49%used/51%remaining');p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/TOWER_FOUNDATION.md';s=p.read_text(encoding='utf-8');note='## Actual journey checkpoint — 2026-10-04\n\n'+header+'The original City region boundary rejected the elevated private court. A navigation-only Ashen annex now covers x1835–2165/z1235–1565; surface combat bounds and the intervening void remain unchanged. Two domain regression cases cover court paths, original regions, void and invalid numbers. The exact saved City source was applied to the native running server configuration to continue ordinary R-entry; no profile values or avatar position were assigned by tools. Final-source fresh startup remains pending. Saved-choice copy now recognizes the actual founding motto `together`; twelve EN/TH caravan/motto combinations pass a native fixture, but that copy fix was not hot-loaded into this actual world session.\n\nEvidence: [Hall8](validation-tower-journey-hall8-live.json), [bound support lessons](validation-tower-support-story-live.json), [archive](validation-tower-archive-story-live.json), [domain suite](validation-tower-annex-domain.txt), [memory copy fixture](validation-tower-world-memories-native.json).\n\n'
if '## Actual journey checkpoint' not in s:s=s.replace('## Latest implementation checkpoint',note+'## Latest implementation checkpoint',1)
p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId'].startswith('world.tower.chapter04.') and not a['designId'].endswith('.concept'):
  a['productionBinding']='Explicit memory-only Chapter04; actual orientation/midpoint reentry/support roles/archive and reward claims pass; memory/doors/final guardian/full final-source boot pending; no human UAT approval'
 if a['designId'].startswith('vfx.tower.'):
  a['productionBinding']='Owned bounded lesson cues bootstrapped; bound Guard/Mend/Combined keyboard journey passes; device readability and human approval pending'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Measured Tower acceptance checkpoint saved')
