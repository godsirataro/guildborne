from pathlib import Path
import json,subprocess
R=Path(__file__).resolve().parents[1]
project={'name':'Guildborne_CrownfordArchitectureReview','tree':{'$className':'DataModel','ReplicatedStorage':{'Shared':{'$className':'Folder','Presentation':{'$className':'Folder',**{n:{'$path':'../src/shared/Presentation/'+n+'.luau'}for n in ['CrownfordArchitecture','CivicServiceArchitecture','CivicInstitutionArchitecture']}}}},'ServerScriptService':{'Services':{'$className':'Folder',**{n:{'$path':'../src/server/Services/'+n+'.luau'}for n in ['CivicDistrictKit','CivicLandmarkKit','CivicServiceKit','CrownfordServiceKit']}},'ArchitectureBoot':{'$path':'../tools/crownford_walk_review.server.luau'}}}}
p=R/'build/crownford-walk-review.project.json';p.write_text(json.dumps(project,indent=2)+'\n');subprocess.run([str(R/'.tools/rojo/rojo.exe'),'build',str(p),'--output',str(R/'build/Guildborne_CrownfordArchitectureReview.rbxlx')],check=True)
