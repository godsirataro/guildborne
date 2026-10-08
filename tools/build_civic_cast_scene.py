"""Package authored NPC activity rigs beside the six walkable city services."""
from pathlib import Path
import json,subprocess
R=Path(__file__).resolve().parents[1]
for script in ['build_civic_contact_preview.py','build_civic_architecture_review.py']:
 subprocess.run(['python',str(R/'tools'/script)],check=True,cwd=R)
p=R/'build/civic-architecture-review.project.json';project=json.loads(p.read_text());project['name']='Guildborne_CivicCastSceneReview'
project['tree']['ReplicatedStorage']['CivicReview']={'$className':'Folder','NativeReview':{'$path':'civic-contact-preview-source/NativeReview.luau'},'Effects':{'$path':'civic-contact-preview-source/Effects.luau'},'Data':{'$path':'civic-contact-preview-source/Data'}}
project['tree']['StarterPlayer']['StarterPlayerScripts']['CivicCastScene']={'$path':'../tools/civic_cast_scene.client.luau'}
p=R/'build/civic-cast-scene.project.json';p.write_text(json.dumps(project,indent=2)+'\n')
subprocess.run([str(R/'.tools/rojo/rojo.exe'),'build',str(p),'--output',str(R/'build/Guildborne_CivicCastSceneReview.rbxlx')],check=True,cwd=R)
