from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest HUD and focus checkpoint — 2026-10-02

MenuRouter now restores a menu's selected control, skips hidden/disabled controls, recovers after rerenders/reparenting, respects pinned entry, supports Tab focus and controller B close, and leaves Roblox core menu alone. Candidate/selection listeners are disconnected on teardown;14engine selection lifecycle checks PASS. Physical keyboard/gamepad acceptance is still pending.

Combat HUD now measures the safe GUI area. Narrow/short screens show one selected actor plus Next hero; short wide screens use2or3columns; portrait skill controls avoid bottom command/health panels.110geometry cases pass from320x280 through1366x844;10native EN/TH viewport cases pass label bounds and44px targets. PlayerCombatController disconnects events/restores pose overlays on Destroy. All live actors were read-only. Pointer-tool clicks did not fire the fixture's Activated counter, so actual Next hero pointer acceptance is explicitly PENDING rather than claimed passed. Both MCP/native-script fixtures, globals and temporary GUI overrides removed; owned Play stopped.

Domain336PASS including5,000market orders/0invariant violations. Main140runtimefiles: build, strict analysis,compile,repository PASS. Latest quota83%used/17%remaining; continue to15%. Work still needs playable regional travel/rewards, v2 onboarding/progression integration, live imports, multiplayer/mobile/backend recovery and human UAT. No cloud publication, uploaded IDs or commerce enablement.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8');p.write_text(note+s if not s.startswith(note.splitlines()[0]) else s,encoding='utf-8')
for name in ['STATUS.md','WORK_CHECKLIST.md']:
 p=docs/name;s=p.read_text(encoding='utf-8').replace('335domain','336domain').replace('is335 tests','is336 tests').replace('last observed18% remaining','last observed17% remaining')
 if name=='STATUS.md':s=s.replace('Latest: journal','Latest: responsive HUD110geometry/10native cases and menu focus14lifecycle cases; journal')
 else:
  s=s.replace('Shared MenuRouter, management/map/market focus and combat blocking','Shared MenuRouter with focus restoration,14lifecycle checks; management/map/market focus and combat blocking')
  s=s.replace('native portraits, T cycle and three skill slots','native portraits, T/compact Next hero cycle and three skill slots;110HUD geometry/10native EN-TH cases')
 p.write_text(s,encoding='utf-8')
p=docs/'USAGE_STOP.md';p.write_text(p.read_text(encoding='utf-8').replace('82% used / 18% remaining','83% used / 17% remaining'),encoding='utf-8')
