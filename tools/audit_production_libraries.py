"""Evidence ledger: portable art files, native sources and explicitly unfinished bindings."""
from pathlib import Path
import json,hashlib
ROOT=Path(__file__).resolve().parents[1];BASE=ROOT/'assets/uat01'
specs=[
 ('city-interior-kit','City room furnishings','src/server/Services/CityInteriorKit.luau','Native five-building integration complete; mesh imports, physical traversal and device acceptance pending'),
 ('adventure-kit','Environment props','src/server/Services/AdventurePropKit.luau','Roblox mesh import; dressing and environment acceptance'),
 ('weapon-kit','Equipment weapons','src/server/Services/WeaponVisuals.luau','Roblox mesh import; device readability'),
 ('item-kit','Inventory display models','src/shared/Data/ItemVisuals.luau','Roblox image/mesh import; arbitrary avatar fitting'),
 ('character-kit','Sentinel custom rig',None,'Roblox rig import and retargeting'),
 ('enemy-kit','Regional enemy rigs','src/server/Services/AdventureEnemyKit.luau','Live regional AI, attacks, damage, quest events and rewards'),
 ('region-kit','Traversable regional blockouts','src/server/Services/AdventureMapKit.luau','Final dressing/boundaries, travel/checkpoints, encounters and rewards'),
 ('hero-kit','Companion visual templates','src/server/Services/HeroVisualKit.luau','Current companion appearances integrated; new recruitment catalog/ownership/rotation and custom-rig imports remain'),
 ('cosmetic-kit','Cosmetic art prototypes','src/server/Services/CosmeticVisualKit.luau','Entitlements/equip, shop delivery, cloak skinning and dynamic VFX'),
]
libraries=[]
for directory,label,native,pending in specs:
    folder=BASE/directory;assert folder.is_dir()
    files=[]
    for p in sorted(folder.iterdir()):
        if p.suffix.lower() not in ('.fbx','.glb','.blend','.png','.gif','.json'):continue
        files.append(dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    if native:assert (ROOT/native).is_file()
    libraries.append(dict(id=directory,title=label,files=files,counts={ext:sum(Path(f['path']).suffix==ext for f in files) for ext in ('.blend','.fbx','.glb','.png','.gif')},nativeSource=native,pending=pending,uatApproved=False,cloudImported=False))
registry=json.loads((ROOT/'docs/uat01/intake/registry-reconciled.json').read_text(encoding='utf-8'))
assert all(a['uatApproved'] is False and a['robloxAssetId'] is None for a in registry['assets'])
for entry in registry['assets']:
    source=entry.get('source')
    if isinstance(source,dict):
        for key in ('icon','blend','native'):
            if key in source:assert (ROOT/source[key]).is_file(),(entry['designId'],key)
output=dict(schema=1,libraries=libraries,registrySummary=registry['summary'],notes=[
 'Library entries overlap: weapon models also appear in the item kit; counts are not unique game assets.',
 'Portable exports are local artifacts, not uploaded Roblox IDs or human UAT acceptance.',
 'Static portal/trail previews are not implemented dynamic VFX; templates are not recruitment entitlements.',
 'Runtime full domain suite323; subsequent art-only changes have separate build/type/compile/native evidence.'
])
(ROOT/'docs/uat01/intake/production-libraries.json').write_text(json.dumps(output,indent=2)+'\n',encoding='utf-8')
lines=['# Production asset evidence ledger','', 'Local original art libraries. Counts include alternate formats and reused geometry; do not interpret their sum as unique production-ready game assets. No cloud imports or human UAT approvals are claimed.','', '| Library | Blender | FBX | GLB | PNG | Native source | Remaining |','| --- | ---: | ---: | ---: | ---: | --- | --- |']
for a in libraries:
    c=a['counts'];native='[source](../../'+a['nativeSource']+')' if a['nativeSource'] else 'None'
    lines.append('| ['+a['title']+'](../../assets/uat01/'+a['id']+'/README.md) | '+str(c['.blend'])+' | '+str(c['.fbx'])+' | '+str(c['.glb'])+' | '+str(c['.png'])+' | '+native+' | '+a['pending']+' |')
lines+=['','Hash and size of each artifact: [production-libraries.json](intake/production-libraries.json). Registry now distinguishes30native inventory previews,15visual hero templates and8cosmetic art slots from their unfinished import/gameplay/ownership bindings. All239asset rows and65screen rows preserve `uatApproved=false`.','']
(ROOT/'docs/uat01/PRODUCTION_LIBRARIES.md').write_text('\n'.join(lines),encoding='utf-8')
print('PRODUCTION_LEDGER_PASS',len(libraries),'libraries',sum(len(a['files']) for a in libraries),'files; no UAT approvals')
