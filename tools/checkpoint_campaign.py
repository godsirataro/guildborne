"""Idempotent local campaign evidence checkpoint; never changes approval/cloud IDs."""
from pathlib import Path
from collections import Counter
import json

root=Path(__file__).resolve().parents[1]
p=root/'docs/uat01/intake/registry-reconciled.json'
d=json.loads(p.read_text(encoding='utf-8'))
for asset in d['assets']:
    if asset['designId'].startswith('world.crown_road.') and not asset['designId'].endswith('.concept'):
        asset['status']='NATIVE_COURSE_LOCAL_EXPORTS_IMPORT_PENDING'
        asset['productionBinding']='Optional memory-only course; three actual full Chapter00 paths, one continuing through Chapter01/Hall2; production imports and human/device acceptance pending'
new=[
    dict(designId='world.campaign.chapter01_markers',group='Campaign world',priority='P0',status='OFFLINE_JOURNEY_VERIFIED_PRESENTATION_POLISH_PENDING',source='src/server/Services/CampaignWorld.luau; docs/uat01/validation-campaign-full-journey-live.json',productionBinding='24 owner-scoped guild/city/Greenwood markers; actual six Chapter01 quests and Hall2 upgrade at revision69; no cloud release',robloxAssetId=None,uatApproved=False),
    dict(designId='world.campaign.transport_cargo',group='Campaign world',priority='P0',status='NATIVE_CARGO_FIXTURE_VERIFIED_LIVE_JOURNEY_PENDING',source='src/server/Services/CampaignWorld.luau; src/server/Services/ArtKit.luau; docs/uat01/validation-campaign-polish-native.json',productionBinding='Reuses original crate/log props; massless root-welded transport visual and cleanup verified synthetically; carry animation and actual final presentation journey pending',robloxAssetId=None,uatApproved=False),
]
new.append(dict(designId='world.guild.recognition_identity',group='Guild identity',priority='P0',status='NATIVE_IDENTITY_MATRIX_VERIFIED_REQUIRES_UAT',source='src/server/Services/GuildIdentityWorld.luau; docs/uat01/GUILD_IDENTITY.md; docs/uat01/validation-guild-identity-native.json',productionBinding='Three crests and three bilingual mottos on recognized Hall banners;216 native combinations and actual committed Compass/Together visual apply; standalone exports and final human/device acceptance pending',robloxAssetId=None,uatApproved=False))
ids={a['designId'] for a in new}
d['assets']=[a for a in d['assets'] if a['designId'] not in ids]+new
screen=dict(designId='screen.campaign.chapter01',name='Guild campaign / guaranteed companion / Hall permit',scope='UAT01',status='OFFLINE_JOURNEY_VERIFIED_POLISHED_UI_NATIVE_ONLY',implementationCandidate='src/client/UI/CampaignView.luau; src/shared/Data/CampaignViewState.luau',requiredBehavior='Ordered server objectives; two-step free companion choice; earned rewards once; Hall2 permit requires materials and Gold; tracker and bilingual guidance',requiredStates='84 EN/TH native synthetic views, 780 text bounds, 36 callbacks; actual six-quest journey before final grid/scroll/cargo polish; physical-device and human approval pending',uatApproved=False)
d['screens']=[s for s in d['screens'] if s['designId']!=screen['designId']]+[screen]
d['summary'].update(assets=len(d['assets']),screens=len(d['screens']),screenScopes=dict(Counter(s['scope'] for s in d['screens'])),assetStatuses=dict(Counter(a['status'] for a in d['assets'])))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=root/'docs/uat01/WORK_CHECKLIST.md';s=p.read_text(encoding='utf-8').replace('Runtime validation is 499 tests','Runtime validation is 510 tests').replace(';215 runtime scripts',';223 runtime scripts').replace(';222 runtime scripts',';223 runtime scripts')
lines=s.splitlines()
updates={
 'Quests / NPCs':('| Quests / NPCs | Existing31Journal+3timed quests and friendly Orc quest chains; Chapter00 fully bound offline; Chapter01 six quests now server-authoritative with ordered observations, one guaranteed Lv10 companion, two timber choices and Hall2 permit. Actual fresh Chapter00-to-Hall2 run: revision69, Mage20/Bram20/Sage16,49Gold; four course cast rigs/16clips/24exports | Chapter02 and remaining240 draft cards need concrete events/rewards; separate NPC escort, final carry/presentation journey, six-city content, balance/persistence/device/human UAT |'),
 'v2 onboarding':('| v2 onboarding | Three actual memory-only Chapter00 paths; latest continues through all six Chapter01 quests and paid-material Hall2 upgrade. Two-step free founder and companion recruitment, no duplicate starter. New grid rounding passes54Novice/84Campaign EN-TH states;12scroll retention rebuilds | Final polished full journey, alternate Chapter01 allocation and class parties, persistent reconnect, device/multiplayer/human UAT and production cutover |'),
}
for i,line in enumerate(lines):
    if line.startswith('| '):
        area=line.split('|')[1].strip()
        if area in updates:lines[i]=updates[area]
p.write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('CAMPAIGN_REGISTRY',len(d['assets']),'assets',len(d['screens']),'screens')
