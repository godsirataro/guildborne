from pathlib import Path
root=Path(__file__).resolve().parents[1]
note='''## Latest live-hero and review-place checkpoint — 2026-10-02

320tests/full validation PASS in validation-hero-appearance-full.txt. New HeroTemplateChoice picks a stable class_01..03 appearance from companion ID, independent of rank/spending. HeroAppearance maps authored geometry onto existing R6 limbs, preserves all6locomotion motors, strips baked weapons, leaves actual equipped items authoritative.15variants passed native fit/weld/bounds/reuse/invalid-ID checks. Five existing Following companions now use warrior_02/archer_03/priest_02/knight_02/mage_02 and moved9.9–14.1studs during safe-guild follow check. Player position restored; no profile mutations. HeroVisualKit supports optional onlyId to avoid instantiating all15per actor.

ActorPortrait cap64 and VisualTemplateId invalidation; head/hat bounding corners now determine camera fit. Six real replicated portraits passed sanitization/reuse/nil cleanup and all280head-gear corner checks; validation-portrait-framing.json. Screenshot hero-variants-hud.png. Final portrait-only refinement passed strict analyze (validation-hero-portrait-final.txt), compile/build/repo125strictfiles. Runtime source synced, owned Play stopped.

Standalone review artifact build/Guildborne_ArtReview.rbxlx (~250KB), art-review.project.json and review/README.md. Explicit12dependency-module allowlist plus ReviewWorld/Bootstrap; no main-game bootstrap, persistence/commerce APIs or remotes. Contains15heroes/30items/8cosmetics and3region travel+18scombat demos. Isolated Studio construction1345parts/9prompts,94synthetic damage events; automatic demo cleanup/restart/repeatedDestroy passed. Full fresh-file join/travel acceptance still pending. Default main build excludes review directory. Screenshot art-review-gallery.png; review source strict checked separately with review-sourcemap.json. Build boundary evidence validation-review-build.json and runtime validation-review-world.json.

Registry/ledger updated to distinguish current companion appearance integration from unfinished new recruitment catalog/ownership/rotation.15custom16bone Blender rigs remain separate from the active R6visual adapter. Quota last78% used/22% remaining: continue toward15%. Studio Edit, all fixtures and camera overrides cleared. Existing persistent template libraries remain intentionally installed.

'''
p=root/'docs/uat01/HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s if note not in s else s,encoding='utf-8')
for name in ['STATUS.md','WORK_CHECKLIST.md']:
    p=root/'docs/uat01'/name;s=p.read_text(encoding='utf-8').replace('319tests','320tests').replace('319 tests','320 tests');p.write_text(s,encoding='utf-8')
p=root/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest check: 75% used / 25% remaining.','Latest check: 78% used / 22% remaining.');p.write_text(s,encoding='utf-8')
p=root/'assets/uat01/GALLERY.md';s=p.read_text(encoding='utf-8');line='\nStandalone local Studio review: [instructions](../../review/README.md). Includes all native display libraries, region routes and synthetic boss demos.\n';p.write_text(s+line if line not in s else s,encoding='utf-8')
