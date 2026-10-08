"""Record the staged guild storage milestone without promoting cloud/multiplayer gates."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
header='> Guild store checkpoint — 2026-10-06: 605 domain tests at the store checkpoint; 56 focused guild scenarios after the pending-state projection/UI update. Founder/join/cancel/leave/kick coordinators, validated journals and injected uncached provider are staged; no cloud store opened. Native fake-provider checks and 4 SHA-256 key vectors pass. Roster/pending UI: 84 EN/TH views, 654 text bounds, 18 captured actions. 272 strict runtime sources; main/offline/four chapter builds pass. Fresh Chapter00–04 gameplay evidence remains revision 217 / Hall 11; later changes verified separately. Registry: 398 assets / 31 PNGs. RuneCaster root cause and live guild/device/persistence/import gates remain pending. Quota: 57% used / 43% remaining; continue to 25% remaining, save/stop owned jobs, then normal shutdown.\n\n'
for name in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
    p=root/'docs/uat01'/name;text=p.read_text(encoding='utf-8')
    if text.startswith('> Guild store checkpoint — 2026-10-06:'):text=header+text.split('\n\n',1)[1]
    else:text=header+text
    if name=='WORK_CHECKLIST.md':
        lines=text.splitlines()
        for i,line in enumerate(lines):
            if line.startswith('| Player Guild |'):
                lines[i]='| Player Guild | Staged founder/join/cancel/leave/kick coordinators, four roles and recipient-consent transfer, generation fences, roster privacy and validated conditional store. 56 focused scenarios, 114 write-fault combinations; native fake-provider checks and 4 key vectors. Roster/pending EN/TH: 84 views / 654 bounds / 18 captured actions | Dedicated cloud binding, authenticated session fencing, bounded fence storage/migrations, name filtering and creation policy, creation/invite/role screens, real multiplayer/reconnect and co-op quests |'
        text='\n'.join(lines)+'\n'
    p.write_text(text,encoding='utf-8')
usage=root/'docs/uat01/USAGE_STOP.md'
usage.write_text(usage.read_text(encoding='utf-8').replace('Latest observed quota: 51% used / 49% remaining.','Latest observed quota: 57% used / 43% remaining.'),encoding='utf-8')
progress=root/'docs/uat01/FRESH_OCT06_PROGRESS.md'
text=progress.read_text(encoding='utf-8').replace('Active Studio:', 'Completed Studio (Play stopped):')
text=text.replace('Latest quota observed: 56% used / 44% remaining.','Latest quota observed: 57% used / 43% remaining.')
if 'Post-run presentation' not in text:
    text+='\nPost-run presentation: owned companion sorting/names, class-art keys, advancement refund guidance and prerequisite quest navigation passed separate native UI checks. Ashen now reports missing/lost/distant companion participation after a relevant rewarded victory; six EN/TH notice views fit. This diagnostic does not establish or fix the original RuneCaster root cause. Evidence: `validation-party-polish-native.json`, `validation-victory-notice-native.json`.\n'
progress.write_text(text,encoding='utf-8')
print('Guild store checkpoint saved; no runtime/cloud activation.')
