"""Record untouched-build gameplay evidence separately from later UI changes."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
header = (
    '> Fresh campaign checkpoint — 2026-10-06: Chapter00–04 completed with ordinary input '
    'and no source hotpatch or profile grants: revision217, Elementalist70, Hall11, '
    '3515XP, 414Gold, 6novice +24campaign claims. Memory-only desktop route; Play stopped. '
    'Later party/advancement UI polish passed4EN/TH native views with0text overflow, '
    'actual quest navigation and captured party-save input. 577 domain tests last passed '
    'before presentation polish; targeted strict and all6builds passed afterward. '
    'RuneCaster story-credit anomaly remains unresolved; diagnostic feedback added separately. '
    'Registry397assets/30generatedPNG;266runtime sources. Quota57%used/43%remaining; '
    'continue until25%remaining, save/stop owned jobs and normal shutdown. '
    'Persistence, multiplayer, devices, imports, city gameplay and human release gates remain pending.\n\n'
)
for name in ['STATUS.md', 'HANDOFF.md', 'WORK_CHECKLIST.md']:
    path = root / 'docs/uat01' / name
    text = path.read_text(encoding='utf-8')
    if not text.startswith('> Fresh campaign checkpoint — 2026-10-06:'):
        text = header + text
    if name == 'WORK_CHECKLIST.md':
        lines = text.splitlines()
        replacements = {
            'Quests / NPCs': (
                'Chapter00–04 fresh Memory-mode desktop journey complete without hotpatch/grants: revision217, Elementalist70/Hall11; 6 novice +24 campaign claims. Mine/Ashen puzzles, escorts, protection, borrowed trial, all Tower lessons and Records Guardian passed. Separate expedition chain and Elementalist promotion completed.',
                'RuneCaster story-credit anomaly unresolved; explicit companion eligibility feedback added. Six-city service/quest bindings, broader class paths, persistence, multiplayer, devices and human acceptance pending.'),
            'UI navigation': (
                'MenuRouter and focus restoration; owned named companions precede recruitment. Q/Z/X art guidance, advancement refund warning and direct prerequisite-expedition navigation. Four EN/TH native polish views have zero text overflow; actual navigation and captured party-save input passed.',
                'Full surface/state and safe-area audit; mobile/gamepad focus/input, longer translations and release acceptance.'),
            'Acceptance / release': (
                'Full untouched-source Chapter00–04 desktop Memory journey to Hall11; later presentation polish verified separately. 577 domain tests at pre-polish checkpoint; strict/build/repository checks and six build outputs verified.',
                'RuneCaster anomaly, persistent reconnect, 2/4 real clients, companion load, physical mobile FPS/memory, imported assets, human UAT and publish decision.'),
        }
        for index, line in enumerate(lines):
            for area, (done, remaining) in replacements.items():
                if line.startswith('| ' + area + ' |'):
                    lines[index] = f'| {area} | {done} | {remaining} |'
        text = '\n'.join(lines) + '\n'
    path.write_text(text, encoding='utf-8')
print('Fresh campaign checkpoint saved; release gates remain pending.')
