from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest companion motion checkpoint — 2026-10-02

HeroAnimator now detects anchored/CFrame follower motion from position deltas with smoothing, limits large time steps, resets stale poses past90studs or on removal, observes replacement joints and exposes teardown. Root transforms remain authoritative and untouched by animation. Server-stamped cast/downed/hit poses remain active; reduced idle motion is preserved.

Ordinary temporary client-script probe:20client-only hero clones,1,000parts,120motors passed kinematic walk, cull reset, downed, detach/reparent, late joint and root-untouched checks.90stress frames: heartbeat median16.94ms,95th18.05ms vs baseline median16.87ms in this Studio run. These are diagnostics, not mobile FPS/memory or real multiplayer certification. Reported memory delta0 does not establish zero allocation. Every clone/probe removed; local motion preference restored; owned Play stopped.

Main143runtimefiles, domain340baselinePASS. Quota83%used/17%remaining at latest check. Continue to15%. See validation-hero-lifecycle-runtime.json. All release/commerce/ordinary-save limits remain unchanged.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s if not s.startswith(note.splitlines()[0]) else s,encoding='utf-8')
p=docs/'WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('Live camp/Tower6joint animation','Anchored hero walk/cull/reparent/replacement joints with20clone diagnostic; live camp/Tower6joint animation');p.write_text(s,encoding='utf-8')
