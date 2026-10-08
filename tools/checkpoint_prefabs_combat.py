from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest prefab and combat boundary checkpoint — 2026-10-02

CombatSpace now supplies the same authoritative camp geometry to AI target selection, hostile damage, boss impacts and receipt-time player/companion commands. It blocks damage in either direction across safe boundaries and rejects mismatched/missing sessions/nonfinite positions; friendly recovery remains available. Found old AI path only checked distance while commands checked bounds. New domain regressions plus existing suite326PASS incl5000orders. Studio synthetic AI fixture passed: companion outside protected, inside both sides damage, retreat stops damage, enemy outside rejected, commands cannot hit safe targets. Existing movement orders still pass.

Advanced companion command regression must run in a temporary ordinary server Script: MCP execute_luau has a separate module require cache with5base abilities/unfrozen config, while actual server VM has29merged abilities/frozen config. Initial direct-MCP probe failed on missing advanced ability definition; actual server Script rerun passed all8command checks. Test header updated. This was a probe-context issue, not evidence that advanced skills fail in the real game. All runners/fixtures removed; owned Play stopped, Studio Edit. Build/strict/compile/repo130runtimefilesPASS. All runtime sources synced. No profile/reward writes in fixtures.

assets/uat01/roblox-prefabs now provides aggregate +8category model packs, each.rbxm and.rbxmx.88static entries (five weapons overlap item kit),1576visibleparts,15markers9routes. Binary roundtrip across9packs passed3152geometry comparisons, class allowlist, origin pivots, map data, material/color/collision. No scripts/Humanoids/ownership behaviors. Import library into ServerStorage because models share authored origin. Direct Studio LoadLocalAsset blocked by missing RobloxScript capability; manual native file-insertion acceptance pending, no permission bypass. README links format sources and exact limitations. Main native factory templates already tested separately.

Latest quota79% used/21% remaining; continue toward15%. Last cosmetic stable-card-name refinement was subsequently rebuilt/strict/repository checked. ArtReview remains separate16scripts/modules~306KB. No publish/upload/livecommerce/humanUAT.

'''
p=docs/'HANDOFF.md';s=p.read_text(encoding='utf-8')
if not s.startswith(note):p.write_text(note+s,encoding='utf-8')
for name in ('STATUS.md','WORK_CHECKLIST.md'):
    p=docs/name;s=p.read_text(encoding='utf-8').replace('323domain tests','326domain tests').replace('validation is323 tests','validation is326 tests');p.write_text(s,encoding='utf-8')
