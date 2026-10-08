from pathlib import Path
from collections import Counter
import json
r=Path('.')
p=r/'docs/uat01/CITY_GUILD_PORTALS.md';p.write_text('''# District guild portals — 2026-10-06

Central City now has guild-island access in the Guild, Market and Tower districts, in addition to the arrival gate. These are districts of the existing city, not six finished launch cities. Each portal also opens the existing island directory with its usual ownership/access checks.

The server remembers the last city guild portal used during this session. Returning from the guild lands beside that fixed stop. Clients cannot submit a stop or coordinates. Each landing is checked for ground and body clearance; obstructed district candidates fall back to normal City spawn candidates. If every candidate is blocked, travel is rejected without moving the character. Removing the player clears the remembered stop; reconnect defaults to the original City arrival. Combat/downed/tower restrictions and the two-second cooldown remain enforced. Earned Hall-upgrade guidance now points to the nearest city guild portal.

Native final-geometry evidence: four stops/eight landings/eight no-jump gate paths; twelve road corridors sampled at837points with no blockage. The first layout placed Guild/Market pillars at a junction; both gates were moved20studs into their district lanes before final verification.

Actual ordinary-input offline Memory round trips passed for Market(300,-1068), Guild(-300,-1068) and Tower(0,-1502), using normal-speed navigation and E prompts. No profile grants. An attempted obstruction-input test started before travel cooldown elapsed and is excluded. A separate native dummy-character fixture verifies all-landings-blocked rejection, default fallback, replacement of remembered stops and removal cleanup; this is not multiplayer or actual-player safety acceptance.

[Native evidence](validation-district-portals-native.json). Full633-domain regression and strict checks passed after later narrative presentation work. Real visitors/multiplayer, reconnect and physical devices remain release gates.
''',encoding='utf-8')
p=r/'docs/uat01/ARCHIVE_ENDINGS.md';s=p.read_text(encoding='utf-8');s+='\n## Saved-choice recollections\n\nRead-only caravan, timber allocation, Human/Orc reconciliation and voluntary warden-oath recollections now appear at relevant Chapter06 stations and in the completed Guild view. Sixteen combined histories retain distinct bilingual text; missing/unknown records use neutral copy. These lines grant no rewards or route shortcuts. Native checks:96billboard bounds,144completion views/996text bounds and5world history binding checks. See validation-archive-memory-native.json. Full fresh gameplay predates these additions.\n';p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/intake/registry-reconciled.json';d=json.loads(p.read_text(encoding='utf-8'));rows=[]
for kind in ['caravan','timber','reconciliation','warden']:
 rows.append(dict(designId='dialogue.archiveheart.memory.'+kind,group='ArchiveHeart',priority='P0',status='SAVED_CHOICE_DIALOGUE_NATIVE_VERIFIED_UAT_PENDING',source='src/shared/Data/ArchiveStoryMemory.luau; docs/uat01/validation-archive-memory-native.json',productionBinding='Bilingual saved-choice station and completion recollection; neutral fallback; no rewards/gates modified',robloxAssetId=None,uatApproved=False))
for kind in ['GuildDistrict','MarketDistrict','TowerDistrict']:
 rows.append(dict(designId='world.city.guild_portal.'+kind,group='City',priority='P0',status='CITY_PORTAL_ACTUAL_INPUT_VERIFIED_UAT_PENDING',source='src/server/Services/CityWorld.luau; docs/uat01/validation-district-portals-native.json',productionBinding='Reuses native gate art; normal-input roundtrip and fixed landing verification; multiplayer/devices pending',robloxAssetId=None,uatApproved=False))
ids={a['designId']for a in rows};d['assets']=[a for a in d['assets']if a['designId']not in ids]+rows;d['summary'].update(assets=len(d['assets']),assetStatuses=dict(Counter(a['status']for a in d['assets'])));p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
header='> Portal and narrative checkpoint — 2026-10-06: three district guild portals now support actual-input round trips and remembered safe city returns;837road samples/8landing paths clear, blocked-landings checked separately with a dummy. Four saved-choice recollections support16histories,96billboard bounds and144completion views/996text bounds.633domain tests;294strict runtime sources;eight builds. Registry428assets/34generatedPNG. Full fresh Chapter00–06 remains revision266/Mage100/Hall17; subsequent presentation/travel tested separately. Quota66%used/34%remaining; continue to25%remaining, save/stop owned work and normal shutdown.'
for n in ['STATUS.md','HANDOFF.md','WORK_CHECKLIST.md']:
 p=r/'docs/uat01'/n;s=p.read_text(encoding='utf-8');p.write_text(header+'\n\n'+s,encoding='utf-8')
p=r/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('33 original generated PNGs with manifests/prompts; 417 registry assets','34 original generated PNGs with manifests/prompts; 428 registry assets').replace('628 domain tests; 290 runtime sources','633 domain tests; 294 runtime sources').replace('144 completion UI views/882 bounds','144 completion UI views/996 bounds');p.write_text(s,encoding='utf-8')
p=r/'docs/uat01/USAGE_STOP.md';s=p.read_text(encoding='utf-8').replace('Latest observed quota: 65% used / 35% remaining.','Latest observed quota: 66% used / 34% remaining.');p.write_text(s,encoding='utf-8')
print('CHECKPOINT',len(d['assets']))
