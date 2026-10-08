from pathlib import Path
root=Path(__file__).resolve().parents[1];docs=root/'docs/uat01'
note='''## Latest city interiors and boss timing checkpoint — 2026-10-02

Tower BossPatterns now drops impacts more than0.5s late or from dead actors and preserves recovery; CombatService clears expired warning attributes. Three regression cases plus existing suite passed323tests including5000market orders. Sources synced. Client effect cleanup evidence is immediately below.

Five original city interior layouts: guild/tavern/exchange/forge/alchemy,169parts2028triangles,5FBX5GLB6PNGand editable Blender. Ten exports round-trip verified. CentralCityWorld decorates all five actual buildings;155entrance-corridor samples (8studwide/5high) passed, all furnishings bounded/anchored. Larger furniture collides; small props don't. No new service/purchase interactions. Image city-interior-cutaway.png is an isolated roof/front-removed review model, not a changed live shell. Gallery and camera restored. Individual/gallery Blender cameras corrected for room scale and imported quaternion transforms. Full build/strict/compile/repo PASS127runtimefiles. Native runtime probe validation-city-interiors-runtime.json; physical-walk result recorded separately when completed.

Production ledger now9libraries449files (alternate formats/overlap, not unique asset count). No cloud imports/publication/human UAT. Main build includes new interiors; standalone ArtReview build does not yet include them. Last quota78used/22remaining; continue toward15%. Check Studio mode before resuming because isolated physical walker may still be running at this checkpoint.

'''
p=docs/'HANDOFF.md';old=p.read_text(encoding='utf-8')
if not old.startswith(note):p.write_text(note+old,encoding='utf-8')
p=docs/'STATUS.md';s=p.read_text(encoding='utf-8').replace('Validation:320tests and full checks passed.','Validation:323domain tests passed, followed by build/strict/compile/repository checks.')
s=s.replace('Latest:30item visual models,8wearable armors/6accessories,12regional enemy rigs/48clips and3walkable map blockouts. Native inventory/wardrobe/NPC/navigation/recovery UI integrated; regional AI/travel not integrated. See latest HANDOFF for evidence.','Latest: five city interiors169parts integrated;15hero appearances/fitted portraits/camera occlusion integrated;30item models,8armors/6accessories,12regional enemy rigs,3walkable map blockouts,8cosmetic prototypes. Regional encounter AI/patterns run in isolated preview; player travel/combat/rewards remain unbound. Standalone art-review place is built. See latest HANDOFF for evidence.')
p.write_text(s,encoding='utf-8')
p=docs/'WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('Runtime validation is320 tests','Runtime validation is323 tests')
s=s.replace('12regional art rigs are created;9adventure AI archetypes and3bosses with2patterns/phases each remain','12regional art actors/AI prototypes and3two-pattern bosses verified in isolated scenes; player authority/travel/rewards/quest integration remains')
s=s.replace('15visual templates/rigs created; actual recruitment bindings','15visual templates/rigs created and stable appearances applied to current companions; new catalog recruitment bindings')
s=s.replace('| Blender environment |10 original props;','| Blender environment |5city interiors169parts integrated;10 original props;')
p.write_text(s,encoding='utf-8')
