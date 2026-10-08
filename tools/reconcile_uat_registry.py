"""Reconcile attachment planning rows with local evidence, without marking UAT passed."""
from pathlib import Path
import json
from collections import Counter

root=Path(__file__).resolve().parents[1]
intake=root/'docs/uat01/intake'
source=json.loads((intake/'registry-source.json').read_text(encoding='utf-8'))
manifest=json.loads((root/'assets/uat01/manifest.json').read_text(encoding='utf-8'))
tables={s['name']:[dict(zip(s['rows'][0],row)) for row in s['rows'][1:]] for s in source['sheets'] if s['name']!='Overview'}
cells={}
for image in manifest['images']:
    for cell in image.get('cells',[]): cells[cell['id']]={'file':image['file'],'rectXYXY':cell['rectXYXY']}
items=[]
for image in manifest['images']:
    if 'item-icons' in image['file'] or 'equipment-icons' in image['file']:
        items.extend(c['id'] for c in image.get('cells',[]))
assert len(items)==30 and len(set(items))==30
skills={'knight_taunt':'taunt','warrior_power_strike':'power_strike','warrior_cleave':'cleave',
        'archer_piercing_shot':'piercing_shot','archer_volley':'volley','mage_fireball':'fireball','priest_heal':'heal'}
for cls in ['Knight','Warrior','Archer','Mage','Priest']: skills[cls.lower()+'_basic']=cls+'.basic'
assets=[]
enemyData=json.loads((root/'assets/uat01/enemy-kit/kit.json').read_text(encoding='utf-8'))['assets']
enemyPortraits={False:[a['id'] for a in enemyData if not a.get('boss')],True:[a['id'] for a in enemyData if a.get('boss')]}
cosmetics={'founder_bundle':'founder_cloak','weapon_skins':'compass_blade','banner_theme':'company_banner','hall_decor':'hearth_decor',
           'portrait_frame':'ivory_portrait_frame','emotes':'friendly_greeting','portal_effect':'rune_portal','spell_appearance':'pale_spell_trail'}
for row in tables['Assets']:
    entry={'designId':row['Asset ID'],'group':row['Group'],'priority':row['Priority'],
           'status':'PLANNED','productionBinding':None,'source':None,'robloxAssetId':None,'uatApproved':False}
    if row['Group']=='items':
        binding=items[int(row['Asset ID'].split('_')[-1])-1]
        entry.update(productionBinding=binding,source=cells[binding],status='SOURCED_CROP_REVIEW')
        path=f'assets/uat01/item-kit/{binding}.png'
        if (root/path).is_file():entry.update(status='NATIVE_PREVIEW_AND_LOCAL_ICON_READY_IMPORT_PENDING',source={'icon':path,'native':'src/shared/Data/ItemVisuals.luau','atlasCandidate':cells[binding]})
    elif row['Group']=='skills':
        binding=skills.get(row['Asset ID'].split('.')[-1])
        if binding: entry.update(productionBinding=binding,source=cells.get(binding),status='SOURCED_CROP_REVIEW')
        else: entry['status']='UNBOUND_GAMEPLAY_DESIGN'
    elif row['Group'] in ['frames','actions','navigation','rank','class_tier','currency','system','quest_type']:
        entry.update(status='REUSE_NATIVE_COMPONENTS_PENDING_AUDIT',source='src/client/UI/SliceUI.luau')
    elif row['Group']=='heroes':
        entry['status']='TEMPLATE_BINDING_REQUIRED'
        binding=row['Asset ID'].split('.')[-1];path=f'assets/uat01/hero-kit/{binding}.blend'
        if (root/path).is_file():entry.update(status='NAMED_RECRUITMENT_OFFLINE_BOUND_IMPORT_PENDING',source={'blend':path,'icon':f'assets/uat01/hero-kit/{binding}.png','native':'src/server/Services/HeroVisualKit.luau','runtimeAppearance':'src/server/Services/HeroAppearance.luau','recruitment':'src/server/Config/Content.luau'},visualTemplateId=binding)
    elif row['Group']=='shop':
        binding=cosmetics.get(row['Asset ID'].split('.')[-1]);path=f'assets/uat01/cosmetic-kit/{binding}.png'
        if binding and (root/path).is_file():entry.update(status='COSMETIC_PREVIEW_INTEGRATED_ENTITLEMENT_UNBOUND',source={'icon':path,'native':'src/shared/Data/CosmeticVisuals.luau','runtimePreview':'src/client/UI/CosmeticPreview.luau'},visualTemplateId=binding)
    elif row['Group']=='audio':
        name=row['Asset ID'].split('.')[-1]
        path=f'assets/uat01/audio/{name}.wav'
        if (root/path).is_file(): entry.update(status='CREATED_LISTENING_REVIEW_PENDING',source=path)
        if (root/path).is_file():
            entry.update(status='AUDIO_HOOK_READY_IMPORT_LISTENING_PENDING',source={'wav':path,'config':'src/shared/Config/AudioConfig.luau','controller':'src/client/Controllers/AudioController.luau','notes':'assets/uat01/audio/RUNTIME_BINDINGS.md'})
    elif row['Group']=='brand':
        name=row['Asset ID'].split('.')[-1]
        files={'wordmark':'guildborne-logo-v1.png','crest':'guildborne-crest-v2.png','obsidian_texture':'guildborne-obsidian-texture-v1.png','parchment_texture':'guildborne-parchment-texture-v1.png'}
        if name in files:
            path='assets/uat01/generated/'+files[name];assert (root/path).is_file()
            entry.update(status='BRAND_SOURCE_READY_IMPORT_REVIEW_PENDING',source={'image':path,'prompt':'assets/uat01/CREST_PROMPTS.md' if name=='crest' else 'assets/uat01/PROMPTS.md'})
            if name.endswith('_texture'):entry.update(status='UI_TEXTURE_TILING_IMPORT_REVIEW_PENDING',source={'image':path,'prompt':'assets/uat01/UI_TEXTURE_PROMPTS.md'})
        elif name=='title_fallback':entry.update(status='NATIVE_FALLBACK_IMPLEMENTED_REQUIRES_UAT',source='src/client/UI/TitleView.luau')
    elif row['Group']=='enemies':
        name=row['Asset ID'].split('.')[-1];boss=name.startswith('boss_');index=int(name.split('_')[-1])-1
        binding=enemyPortraits[boss][index];path=f'assets/uat01/enemy-kit/{binding}.png';assert (root/path).is_file()
        entry.update(status='ENEMY_OFFLINE_COMBAT_VERIFIED_IMPORT_PENDING',productionBinding=binding,visualTemplateId=binding,source={'icon':path,'native':'src/server/Services/AdventureEnemyKit.luau','runtime':'src/server/Services/AdventureCombatBridge.luau','evidence':'docs/uat01/REGIONAL_COMBAT_OFFLINE.md','blend':f'assets/uat01/enemy-kit/{binding}.blend'})
    elif row['Group']=='classes':
        name=row['Asset ID'].split('.')[-1];binding=name+'_01';path=f'assets/uat01/hero-kit/{binding}.png';assert (root/path).is_file()
        entry.update(status='CLASS_PORTRAIT_CANDIDATE_REVIEW_PENDING',productionBinding=name.title(),source={'icon':path,'runtimeDisplay':'src/client/UI/ActorPortrait.luau'},visualTemplateId=binding)
    elif row['Group']=='regions':
        name=row['Asset ID'].split('.')[-1]
        if name in ('city','guild_home'):
            path='assets/uat01/world-captures/'+('central-city.png' if name=='city' else 'personal-guild.png');assert (root/path).is_file()
            entry.update(status='LIVE_WORLD_CAPTURE_READY_IMPORT_PENDING',source={'image':path,'native':'src/server/Services/CentralCityWorld.luau' if name=='city' else 'src/server/Services/WorldService.luau','notes':'Actual staging runtime overview, no profile changes; not a thumbnail upload or UAT certificate.'})
        if name in ('greenwood','ironveil','ashen'):
            binding=name.title();path=f'assets/uat01/region-kit/{binding}.png';assert (root/path).is_file()
            entry.update(status='REGION_TRAVERSAL_GATHERING_OFFLINE_COMBAT_BOUND',visualTemplateId=binding,source={'icon':path,'native':'src/server/Services/AdventureMapKit.luau','runtime':'src/server/Services/RegionalWorld.luau','evidence':'docs/uat01/REGIONAL_TRAVERSAL.md','combat':'docs/uat01/REGIONAL_COMBAT_OFFLINE.md','blend':f'assets/uat01/region-kit/{binding}.blend'})
    symbol=f"assets/uat01/ui-symbols/{row['Asset ID']}.svg"
    if (root/symbol).is_file():
        previous=entry['source'];bound=row['Asset ID'] in ('ui.combat.focus_target','ui.combat.regroup','ui.combat.retreat','ui.empty_states.empty_inventory','ui.empty_states.empty_party','ui.empty_states.no_market_orders','ui.empty_states.no_search_results','ui.empty_states.offline_unavailable','ui.empty_states.no_quests','ui.brand.monogram','ui.brand.title_ornament','ui.brand.loading_sigil','ui.map.plaza','ui.map.guild_home','ui.map.exchange','ui.map.tavern','ui.map.tower','ui.map.portal','ui.classes.knight','ui.classes.warrior','ui.classes.archer','ui.classes.mage','ui.classes.priest')
        entry.update(status='NATIVE_SYMBOL_INTEGRATED_REQUIRES_UAT' if bound else 'SVG_NATIVE_SYMBOL_READY_BINDING_PENDING',source={'svg':symbol,'native':'src/shared/Data/UISymbols.luau','renderer':'src/client/UI/SymbolIcon.luau','runtimeDisplay':'src/client/Controllers/PlayerCombatController.luau' if bound else None,'priorCandidate':previous})
        if row['Group']=='empty_states':entry['source']['runtimeDisplay']='src/client/UI/EmptyState.luau' if bound else None
        if row['Group']=='brand':entry['source']['runtimeDisplay']='src/client/UI/TitleView.luau' if bound else None
        if row['Group']=='map':entry['source']['runtimeDisplay']='src/client/Controllers/CityNavigation.luau' if bound else None
        if row['Group']=='classes':entry['source']['runtimeDisplay']='src/client/UI/ClassBadge.luau' if bound else None
    assets.append(entry)

for stat in ('str','dex','int','vit','wis'):
    assets.append({'designId':f'ui.status.{stat}','group':'status','priority':'P0',
        'status':'NATIVE_SYMBOL_INTEGRATED_REQUIRES_UAT','productionBinding':stat.upper(),
        'source':{'svg':f'assets/uat01/ui-symbols/ui.status.{stat}.svg','native':'src/shared/Data/UISymbols.luau','runtimeDisplay':'src/client/UI/StatusPointView.luau'},
        'robloxAssetId':None,'uatApproved':False})

groups={'entry':'TitleView','inventory':'InventoryView','heroes':'SkillTreeView','quests':'SettlementView',
        'guild_home':'ExpansionView','craft':'ExpansionView','bestiary':'BestiaryView','tower':'ExpansionView',
        'market':'MarketView','recruitment':'SettlementView','system':'SettingsControls','onboarding':'SliceUI'}
overrides={'screen.main_menu':'SliceUI','screen.heroes_roster':'SliceUI','screen.hero_detail':'SliceUI',
           'screen.party_editor':'SliceUI','screen.credits':'TitleView','screen.connection_status':'SliceUI',
           'screen.system_dialog':'SliceUI'}
screens=[]
for row in tables['Screens']:
    target=overrides.get(row['Screen ID'],groups.get(row['Group']))
    file=f'src/client/UI/{target}.luau' if target else None
    if row['Group']=='hud': file='src/client/Controllers/PlayerCombatController.luau'
    if row['Group']=='world': file='src/client/Controllers/CityNavigation.luau'
    assert not file or (root/file).is_file()
    screens.append({'designId':row['Screen ID'],'name':row['Surface'],'scope':row['Scope'],
        'implementationCandidate':file,'status':'DEFERRED' if row['Scope']=='FUTURE' else 'PARTIAL_REQUIRES_STATE_AUDIT' if file else 'PLANNED',
        'requiredBehavior':row['Required behavior'],'requiredStates':row['States'],'uatApproved':False})

# Add first-release evidence without replacing or renumbering attachment design rows.
for kit,group,native in [
    ('friendly-orcs','friendly_npcs','docs/uat01/WORK_CHECKLIST.md'),
    ('building-themes','utility_themes','docs/uat01/BUILDING_THEMES_IMPLEMENTATION.md'),
    ('hall-themes','hall_themes','src/shared/Presentation/HallAppearance.luau'),
    ('furniture-kit','furniture','src/server/Services/FurnitureWorld.luau')]:
    for asset in json.loads((root/f'assets/uat01/{kit}/kit.json').read_text(encoding='utf-8'))['assets']:
        binding=asset['id']
        if group=='utility_themes':binding=binding.removeprefix('theme_')
        if group=='hall_themes':binding=binding.removeprefix('hall_').split('_lv')[0]
        assets.append({'designId':f"launch.{group}.{asset['id']}",'group':group,'priority':'P0',
            'status':'NATIVE_RUNTIME_LOCAL_EXPORTS_REQUIRES_UAT','productionBinding':binding,
            'source':{'kit':f'assets/uat01/{kit}/kit.json','implementation':native,
                      'acceptance':'Local native fixtures and mesh round-trip verified; import/device/human review pending.'},
            'robloxAssetId':None,'uatApproved':False})
for art in json.loads((root/'assets/uat01/path-vfx/manifest.json').read_text(encoding='utf-8'))['assets']:
    assets.append({'designId':f"launch.path_vfx.{art['id']}",'group':'path_vfx','priority':'P0',
        'status':'NATIVE_VFX_FIXTURE_VERIFIED_ART_REVIEW_PENDING','productionBinding':art['id'],
        'source':{'implementation':art['source'],'catalog':art['catalog'],'evidence':'docs/uat01/PATH_VFX.md'},
        'robloxAssetId':None,'uatApproved':False})
existing_audio={a['designId'].split('.')[-1] for a in assets if a['group']=='audio'}
for landmark in json.loads((root/'assets/uat01/city-landmarks/kit.json').read_text(encoding='utf-8'))['assets']:
    assets.append({'designId':f"launch.city_landmark.{landmark['id']}",'group':'city_landmarks','priority':'P0',
        'status':'LOCAL_MODEL_ACCESS_PATH_VERIFIED_IMPORT_PENDING','productionBinding':None,
        'source':{'kit':'assets/uat01/city-landmarks/kit.json','native':'review/CityLandmarkKit.luau','evidence':'assets/uat01/city-landmarks/README.md'},
        'robloxAssetId':None,'uatApproved':False})
assets.append({'designId':'launch.world.city_identity_board','group':'world_concepts','priority':'P0',
    'status':'SIX_CITY_CONCEPT_REFERENCE_NOT_PLAYABLE','productionBinding':None,
    'source':{'image':'assets/uat01/generated/guildborne-city-identities-v1.png','prompt':'assets/uat01/CITY_IDENTITY_PROMPTS.md'},
    'robloxAssetId':None,'uatApproved':False})
for wav in sorted((root/'assets/uat01/audio').rglob('*.wav')):
    if wav.stem not in existing_audio:
        assets.append({'designId':f'launch.audio.{wav.stem}','group':'audio','priority':'P0',
            'status':'AUDIO_HOOK_READY_IMPORT_LISTENING_PENDING','productionBinding':wav.stem,
            'source':{'wav':wav.relative_to(root).as_posix(),'notes':'assets/uat01/audio/RUNTIME_BINDINGS.md'},
            'robloxAssetId':None,'uatApproved':False})
for ident,name,file,behavior in [
    ('status_points','Status allocation and respec','StatusPointView','Per-actor level-derived AP, effective-stat previews, safe Hall allocation and free SP/AP reset; offline only, EN/TH live flow verified.'),
    ('land','Guild land','GuildLandView','Quest eligibility, material contributions and gated purchase; real product IDs remain disabled.'),
    ('island_directory','Island directory','IslandDirectoryView','Current-server discovery, private/friends/public permission and safe return; cross-server pending.'),
    ('building_themes','Building themes','BuildingThemesView','Owned utility/Hall themes, quest-earned Orc and preview; paid themes unavailable until configured.'),
    ('furniture','Furniture workshop','FurnitureView','Craft, place, store, recycle with confirmation; preserve owned identity and materials.'),
    ('build_placement','Building placement','BuildView','Hall/utility/furniture 2-stud placement and rotation; bounds, collision and route rejection.')]:
    candidate=f'src/client/UI/{file}.luau';assert (root/candidate).is_file()
    screens.append({'designId':f'screen.launch.{ident}','name':name,'scope':'UAT01',
        'implementationCandidate':candidate,'status':'PARTIAL_REQUIRES_STATE_AUDIT','requiredBehavior':behavior,
        'requiredStates':'EN/TH, empty/owned/locked, pending/failure/recovery, mouse/touch/controller, multiplayer where applicable',
        'uatApproved':False})
assert len({a['designId'] for a in assets})==len(assets)
assert len({s['designId'] for s in screens})==len(screens)
out={'version':3,'sourceWorkbookSha256':source['sha256'],'assets':assets,'screens':screens,
     'summary':{'assets':len(assets),'screens':len(screens),'screenScopes':dict(Counter(s['scope'] for s in screens)),
                'assetStatuses':dict(Counter(a['status'] for a in assets))},
     'notes':['Candidate file mapping is not evidence that every screen behavior exists.',
              'Basic attack icons are presentation bindings, not new skill IDs.',
              'Fifteen named templates bind offline Tavern offers, hired actors and native appearances; tickets, rotation, v2 gates and production imports remain pending.',
              'Original class symbols now have SVG/native sources; representative hero portraits remain secondary candidates.',
              'Existing class IDs, quest receipts and save schemas remain unchanged.']}
(intake/'registry-reconciled.json').write_text(json.dumps(out,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(out['summary']))
