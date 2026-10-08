from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest live enemy animation checkpoint — 2026-10-02

Camp goblins and three Tower silhouettes now have6cosmetic Motor6D joints, anchored authoritative root and welded noncolliding art. Native EnemyAnimator handles walk, attack, hit recoil, held boss windup and impact; reduced idle motion,90stud culling/reset, death/respawn and temporary reparent recovery. CollectionService tagging avoids a global per-frame scene scan. No imported animation ID required. Enemy_basic_attack publishes a cosmetic timestamp; server hit timing/rewards unchanged. Legacy goblin artwork faced +Z while movement faces -Z: corrected at articulation. Scaled Tower boss boot grounding corrected by scaling root ground offset.

Studio13isolated actors/78motors/275artwelds passed idempotency,1anchoredroot,forward eyes,grounded boots,no drift,respawn. Actual running client controller passed walk/attack/windup/cancel/reducedidle/reparent/deathrespawn/culling/root-untouched probe. Combat safe-boundary regression remains PASS. enemy-pose-gallery.png is a static Viewport rest/windup contact sheet; motion is verified separately in validation-enemy-animation-runtime.json. All fixture models/modules/UI removed; owned Play stopped; final grounded EnemyService synced into Edit. No profile or reward writes.

Main136strict runtimefiles. Latest domain330tests from market request fix; this animation batch uses focused Studio regressions plus build/strict/compile/repository checks. Last quota81%used/19%remaining; continue toward15%. Regional12enemy rigs are still separate preview content; this binds the existing camp/Tower models only. Release/livecommerce/human UAT gates unchanged.

'''
p=docs/'HANDOFF.md';p.write_text(note+p.read_text(encoding='utf-8'),encoding='utf-8')
p=docs/'USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('80% used / 20% remaining','81% used / 19% remaining');p.write_text(s,encoding='utf-8')
p=docs/'STATUS.md';s=p.read_text(encoding='utf-8').replace('last observed20% remaining','last observed19% remaining');s=s.replace('Latest: five city interiors','Latest: live camp/Tower native enemy animation integrated; market request races fixed;50SVG/native symbols and EN/TH empty states; five city interiors');p.write_text(s,encoding='utf-8')
