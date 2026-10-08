"""Preserve the user-requested quota stop and measured acceptance."""
from pathlib import Path
import json
r=Path(__file__).resolve().parents[1]
header='> STOPPED at user quota boundary — 2026-10-04: Codex weekly50%used/50%remaining. Owned Studio Play stopped; resume only manually. Actual fresh Chapter00-04 journey completed atrevision195: Mage70/3523XP,Hall11,230Gold,Bram70/Sage67;24campaign+6novice claims. Orientation midpoint exit/reentry, all3support lessons, archive, physical echo, compassion oath, moon bypass, records guardian, ledger/seals, court cleanup and surface return passed with normal input and no profile grants. City navigation annex required a source hot reload during that run; final-source fresh boot only reachedrevision0, so a full unmodified final-build journey remains pending. Latest earned-Hall tracker/J-button auto-scroll fix is source-validated but native UI acceptance pending.546domain tests pass;257runtime files; strict/compile pass. Registry389assets/73screens/33workareas,28generatedPNG. Memory-only observed progress is not a resumable save. See TOWER_ACCEPTANCE.md.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/name;s=p.read_text(encoding='utf-8')
 s=s.replace('Runtime validation is 545 tests','Runtime validation is 546 tests')
 p.write_text(header+s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest verified usage:49%used/51%remaining','Latest verified usage:50%used/50%remaining');p.write_text(header+s,encoding='utf-8')
p=r/'docs/uat01/TOWER_FOUNDATION.md';p.write_text(header+p.read_text(encoding='utf-8'),encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'))
for a in d['assets']:
 if a['designId'].startswith('world.tower.chapter04.') and not a['designId'].endswith('.concept'):
  a['productionBinding']='Actual Chapter00-04 journey completed through Hall11/Lv70; revision195; navigation config hot reload required. Final-build full rerun, import, multiplayer/device and human UAT pending.'
 if a['designId'].startswith('npc.tower.'):
  a['productionBinding']='4friendly cast roles bound; actual22stud memory echo escort and story receipts pass; import/device/human approval pending'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('STOP checkpoint saved; no automatic resumption')
