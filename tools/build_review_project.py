"""Produce a review-only Rojo project from an explicit dependency allowlist."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
services=['AdventureMapKit','AdventureEnemyKit','AdventureScene','AdventureEncounterPreview','AdventureNavigation','AdventureLocomotion','HeroVisualKit','CosmeticVisualKit','CityInteriorKit','CityCharacterKit']
systems=['AdventurePatterns','AdventureEnemyBrain'];config=['AdventureEncounters','AdventureEnemyProfiles']
def modules(category,names):return {'$className':'Folder',**{name:{'$path':f'src/server/{category}/{name}.luau'} for name in names}}
project={'name':'Guildborne_ArtReview','serveAddress':'127.0.0.1','tree':{'$className':'DataModel',
'ReplicatedStorage':{'$className':'ReplicatedStorage','Shared':{'$className':'Folder','Data':{'$className':'Folder',**{name:{'$path':f'src/shared/Data/{name}.luau'} for name in ['AdventureTelegraph','ItemVisuals','CosmeticVisuals']}}}},
'ServerScriptService':{'$className':'ServerScriptService','Server':{'$className':'Folder','Services':modules('Services',services),'Systems':modules('Systems',systems),'Config':modules('Config',config)},'Review':{'$className':'Folder','Bootstrap':{'$path':'review/Bootstrap.server.luau'},'ReviewWorld':{'$path':'review/ReviewWorld.luau'},'CityLandmarkKit':{'$path':'review/CityLandmarkKit.luau'},'CityDistrictKit':{'$path':'review/CityDistrictKit.luau'},'NoviceRoadKit':{'$path':'review/NoviceRoadKit.luau'}}},
'Workspace':{'$className':'Workspace','$properties':{'Gravity':196.2}},
'Lighting':{'$className':'Lighting','$properties':{'ClockTime':14,'Brightness':2}},
}}
(ROOT/'art-review.project.json').write_text(json.dumps(project,indent=2)+'\n',encoding='utf-8');print('REVIEW_PROJECT',len(services)+len(systems)+len(config)+4,'allowed dependency modules')
