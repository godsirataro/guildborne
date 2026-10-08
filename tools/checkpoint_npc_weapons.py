"""Record finished local batches without changing historical evidence."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
handoff=root/'docs/uat01/HANDOFF.md'
entry='''## Latest completed checkpoint — 2026-10-02 weapons, flipbook and NPC flow

User still wants continuous useful work until15% remaining. Latest quota75% used/25% remaining: CONTINUE. Studio remains correct Staging86788611613035, all changed source synced; owned Play stopped, fixtures and gallery removed, temporary player position restored.

Five original Hall3 weapon models now use WeaponVisuals through HeroRig: watchblade/oathblade/yew_longbow/tide_staff/dawn_crozier. Shared kit54parts/632triangles, editable Blender+5FBX+5GLB. All10exports round-trip PASS. Grip-based equip fixes legacy and new weapons on R6/R15;22cases/170parts PASS in studio_weapon_grip_probe. WeaponId now invalidates actor portrait snapshots. Native runtime installed; mesh imports pending. See weapon-grips.png and assets/uat01/weapon-kit/README.md.

Original native Blender shockwave4x4atlas completed at assets/uat01/vfx-native:2048RGBA,16exact512cells, all nonempty with40px transparent padding, final fade checked. Editable.blend/layout/alpha report. Cosmetic imported particle candidate only, not uploaded/wired; existing runtime impact uses native geometry.

Eight city NPC actors gain28 welded noninteractive role parts. QuestNpcState pure projection drives client-local ! / ... / ? markers, ready>available>active priority, current inventory turn-in counts, TH/EN, collection-tag stream add/remove and cleanup. Four tests bring full suite306; validation-npc.txt full PASS, including market5000order soak. studio_quest_marker_probe PASS for late tags/state/language/hide/removal/controller lifecycle. An E-key conflict was reproduced: Following heroes stole NPC interaction. Following hero InspectHero prompts now disabled (HUD remains); fresh Play verified five disabled prompts. Real E at Mira opens Journal_herbalist and auto-scrolls card to8px from viewport top. No acceptance/claim/purchase/profile migration. npc-quest-flow.png and validation-npc-runtime.json record evidence. Fixture-only type annotation corrected; final strict analyze PASS in validation-npc-final.txt, supplemental build/compile/repo PASS,108strictfiles.

'''
text=handoff.read_text(encoding='utf-8');handoff.write_text(text.split('\n',1)[0]+'\n\n'+entry+text.split('\n',1)[1].lstrip(),encoding='utf-8')
for name in ('STATUS.md','WORK_CHECKLIST.md'):
    p=root/'docs/uat01'/name;t=p.read_text(encoding='utf-8').replace('302tests','306tests').replace('302 tests','306 tests').replace('observed26%','observed25%')
    if name=='STATUS.md':t=t.replace('Current content:', 'Latest: five native weapon models plus verified Blender exports;16frame shockwave atlas; eight city NPC role appearances and per-player quest markers with direct Journal focus. See latest HANDOFF for evidence.\n\nCurrent content:',1)
    else:
        t=t.replace('completed flipbooks and multi-team readability','flipbook import and multi-team readability')
        t=t.replace('bounded local geometry','bounded local geometry')
        t=t.replace('quality settings |','quality settings; original16frame Blender shockwave atlas |')
        t=t.replace('building/character/weapon production assets','building assets and imported character/weapon review')
        t=t.replace('all new equipment route/balance/device checks','five new weapon silhouettes integrated; remaining route/balance/device checks')
        t=t.replace('HUD tracker/pin/current-inventory counts/J navigation','HUD tracker/pin/current-inventory counts/J navigation;8NPC role appearances, local markers and focused E flow')
    p.write_text(t,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';p.write_text(p.read_text(encoding='utf-8').replace('Latest check: 72% used / 28% remaining.','Latest check: 75% used / 25% remaining.'),encoding='utf-8')
p=root/'assets/uat01/GALLERY.md';p.write_text(p.read_text(encoding='utf-8')+'''\n## Original weapons and shockwave animation\n\n[Five weapon models and native runtime integration](weapon-kit/README.md), [16-frame transparent shockwave atlas](vfx-native/README.md). Exports verified locally; Roblox mesh/texture imports remain pending.\n\n![Weapon silhouettes](weapon-kit/preview.png)\n''',encoding='utf-8')
