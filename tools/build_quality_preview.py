"""Build reviewed art beside current game in an isolated Memory Studio place."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import build_integration_preview
import import_quality_meshes

ROOT=Path(__file__).resolve().parents[1]

def world_contract(sources):
    manifest=json.loads((ROOT/'assets/production/world-slice/collision.json').read_text())
    module=(ROOT/'src/server/Services/WorldQualityAssets.luau').read_text()
    match=re.search(r'\["sourceMeshSha256"\]="([0-9a-f]{64})"',module)
    if not match or match.group(1)!=manifest['sourceMeshSha256']:
        raise ValueError('World collision source and manifest disagree')
    matches=[i for i,p in enumerate(sources,1) if hashlib.sha256(p.read_bytes()).hexdigest()==match.group(1)]
    if len(matches)!=1:
        raise ValueError('World preview requires exactly one matching reviewed mesh dataset')
    return f'Dataset{matches[0]}',manifest

def build(sources, launch=False, shared_combat=False, world=False, images=None, enemies=None, bind_enemies=False, continuous_world=False):
    if bind_enemies and not enemies:
        raise ValueError('Enemy binding requires reviewed enemy datasets')
    world_data=world_contract(sources) if world else None
    build_integration_preview.build(launch, shared_combat, continuous_world)
    variant='launch' if launch else 'integration'
    out=ROOT/'build'
    project=json.loads((out/f'{variant}-preview.project.json').read_text())
    base=json.loads((out/f'{variant}-sync/sources.json').read_text())
    project['name']='Guildborne_QualityPreview'
    folder={'$className':'Folder','$attributes':{'IsolatedMemory':True,'EnableWorldSlice':world,'BindEnemies':bind_enemies}}
    source_root=ROOT/'production/integration/quality-slice'
    entries=base['entries']
    if world_data:
        dataset,manifest=world_data
        folder['$attributes'].update(WorldDataset=dataset,WorldSourceSha256=manifest['sourceMeshSha256'])
        contract_path=out/'quality-world-contract.luau'
        contract_json=json.dumps({'expectedArt':manifest['expectedArt'],'sourceMeshSha256':manifest['sourceMeshSha256']})
        contract_path.write_text('return game:GetService("HttpService"):JSONDecode('+json.dumps(contract_json)+')\n',encoding='utf-8')
        folder['WorldArtContract']={'$path':str(contract_path)}
        entries.append(dict(path=['ReplicatedStorage','QualityPreviewAssets','WorldArtContract'],className='ModuleScript',source=contract_path.read_text()))
    for name in ['NativeAssetPreview','NativeImagePreview']+(['NativeEnemyPreview','EnemyBindingPreview'] if enemies else []):
        native=source_root/(name+'.luau')
        folder[name]={'$path':str(native)}
        entries.append(dict(path=['ReplicatedStorage','QualityPreviewAssets',name],className='ModuleScript',source=native.read_text(encoding='utf-8-sig')))
    reports=[]
    for i,source in enumerate(sources,1):
        name=f'Dataset{i}'
        target=out/'quality-art'/name
        report=import_quality_meshes.package(source,target)
        node={'$className':'Folder','$attributes':{'SourceSha256':report['sourceSha256']}}
        for filename in ['Data.luau']+[f'Chunk{n}.luau' for n in range(1,report['chunks']+1)]:
            path=target/filename
            node[path.stem]={'$path':str(path)}
            entries.append(dict(path=['ReplicatedStorage','QualityPreviewAssets',name,path.stem],className='ModuleScript',source=path.read_text(encoding='utf-8-sig')))
        folder[name]=node
        reports.append({'dataset':name,**report})
    enemy_reports=[]
    for i,source in enumerate(enemies or [],1):
        name=f'Enemy{i}'
        target=out/'quality-art'/name
        report=import_quality_meshes.package_enemy(source,target)
        node={'$className':'Folder','$attributes':{'SourceSha256':report['sourceSha256'],'SkeletalReview':True}}
        for filename in ['Data.luau']+[f'Chunk{n}.luau' for n in range(1,report['chunks']+1)]:
            path=target/filename
            node[path.stem]={'$path':str(path)}
            entries.append(dict(path=['ReplicatedStorage','QualityPreviewAssets',name,path.stem],className='ModuleScript',source=path.read_text(encoding='utf-8-sig')))
        folder[name]=node
        enemy_reports.append({'dataset':name,**report})
    image_report=None
    if images:
        target=out/'quality-art/Images'
        image_report=import_quality_meshes.package_images(images,ROOT,target)
        node={'$className':'Folder'}
        for filename in ['Data.luau']+[f'Chunk{n}.luau' for n in range(1,image_report['chunks']+1)]:
            path=target/filename
            node[path.stem]={'$path':str(path)}
            entries.append(dict(path=['ReplicatedStorage','QualityPreviewAssets','Images',path.stem],className='ModuleScript',source=path.read_text(encoding='utf-8-sig')))
        folder['Images']=node
    project['tree']['ReplicatedStorage']['QualityPreviewAssets']=folder
    for filename,container,name in [
        ('QualityPreview.client.luau',project['tree']['StarterPlayer']['StarterPlayerScripts'],'QualityPreview'),
        ('QualityPreview.server.luau',project['tree']['ServerScriptService'],'QualityPreview')]:
        path=source_root/filename; container[name]={'$path':str(path)}
        prefix=['StarterPlayer','StarterPlayerScripts'] if '.client.' in filename else ['ServerScriptService']
        entries.append(dict(path=prefix+[name],className='LocalScript' if '.client.' in filename else 'Script',source=path.read_text(encoding='utf-8-sig')))
    project_path=out/'quality-preview.project.json'
    project_path.write_text(json.dumps(project,indent=2)+'\n',encoding='utf-8')
    candidate=out/'Guildborne_QualityPreview.rbxlx'
    subprocess.run([str(ROOT/'.tools/rojo/rojo.exe'),'build',str(project_path),'--output',str(candidate)],cwd=ROOT,check=True)
    digest=hashlib.sha256(candidate.read_bytes()).hexdigest()
    sync=out/'quality-sync';sync.mkdir(exist_ok=True)
    attributes=[{'path':['ReplicatedStorage','QualityPreviewAssets'],'values':folder['$attributes']}]
    for name,node in folder.items():
        if isinstance(node,dict) and '$attributes' in node:
            attributes.append({'path':['ReplicatedStorage','QualityPreviewAssets',name],'values':node['$attributes']})
    (sync/'sources.json').write_text(json.dumps({'mode':'VERIFY_BUILT_PLACE_ONLY_NOT_SOURCE_SYNC','candidateSha256':digest,'attributes':attributes,'entries':entries}),encoding='utf-8')
    receipt={'status':'BUILT_NOT_STUDIO_TESTED','persistence':'Memory','candidate':str(candidate),'sha256':digest,'launch':launch,'sharedCombat':shared_combat,'continuousWorld':continuous_world,'worldSlice':world,'bindEnemies':bind_enemies,'art':reports,'enemies':enemy_reports,'images':image_report,'runtimeAssetsUploaded':False}
    (out/'quality-preview-build.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(receipt,indent=2))
    return receipt

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mesh',type=Path,action='append',default=[])
    parser.add_argument('--launch',action='store_true')
    parser.add_argument('--shared-combat',action='store_true')
    parser.add_argument('--continuous-world',action='store_true',help='Opt-in local Memory City-Greenwood walking; requires --launch')
    parser.add_argument('--world',action='store_true')
    parser.add_argument('--images',type=Path)
    parser.add_argument('--enemy',type=Path,action='append',default=[])
    parser.add_argument('--bind-enemies',action='store_true')
    args=parser.parse_args()
    build(args.mesh,args.launch,args.shared_combat,args.world,args.images,args.enemy,args.bind_enemies,args.continuous_world)
