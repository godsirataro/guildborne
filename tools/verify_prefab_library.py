"""Decode every binary pack with Rojo and compare geometry to authored manifests."""
from pathlib import Path
import json,subprocess,xml.etree.ElementTree as ET,math,hashlib
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/roblox-prefabs';BUILD=ROOT/'build/prefabs';ROJO=ROOT/'.tools/rojo/rojo.exe'
report=json.loads((OUT/'pack-report.json').read_text());results=[]
def props(item):return {p.attrib['name']:p for p in item.find('Properties')}
def name(item):return props(item)['Name'].text
def named(parent):return {name(child):child for child in parent.findall('Item')}
for pack in report['packs']:
    binary=OUT/(pack['id']+'.rbxm');project=BUILD/(pack['id']+'-verify.project.json');decoded=BUILD/(pack['id']+'-decoded.rbxmx')
    project.write_text(json.dumps({'name':pack['id'],'tree':{'$path':str(binary)}}),encoding='utf-8')
    subprocess.run([str(ROJO),'build',str(project),'--output',str(decoded)],check=True,capture_output=True)
    tree=ET.parse(decoded);root=tree.getroot().find('Item');allowed={'Folder','Model','Part','WedgePart','Vector3Value'}
    for item in tree.iter('Item'):assert item.attrib['class'] in allowed,item.attrib['class']
    models=[i for i in tree.iter('Item') if i.attrib['class']=='Model'];assert len(models)==pack['models']
    for model in models:
        pivot=props(model)['WorldPivotData'].find('CFrame');assert pivot is not None
        assert [float(pivot.find(k).text) for k in ('X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22')]==[0,0,0,1,0,0,0,1,0,0,0,1]
    groups=named(root) if pack['id']=='GuildbornePrefabLibrary' else {pack['id']:root}
    checked=0
    for kit,folder in groups.items():
        source=json.loads((ROOT/'assets/uat01'/kit/'kit.json').read_text(encoding='utf-8'));modelMap=named(folder)
        assert set(modelMap)=={a['id'] for a in source['assets']}
        for asset in source['assets']:
            children=named(modelMap[asset['id']])
            if asset.get('markers'):
                markerMap=named(children['EncounterMarkers']);assert len(markerMap)==len(asset['markers'])
                for marker in asset['markers']:
                    p=props(markerMap[marker['name']]);assert p['Transparency'].text=='1'
                    assert p['CanCollide'].text=='false' and p['CanTouch'].text=='false' and p['CanQuery'].text=='false'
                    assert [float(p['CFrame'].find(k).text) for k in ('X','Y','Z')]==marker['position']
            if asset.get('routes'):
                routeMap=named(children['ReviewRoutes']);assert len(routeMap)==len(asset['routes'])
                for route in asset['routes']:
                    points=named(routeMap[route['name']]);assert len(points)==len(route['points'])
                    for i,point in enumerate(route['points']):
                        value=props(points[str(i+1)])['Value'];assert max(abs(float(value.find(k).text)-point[j]) for j,k in enumerate(('X','Y','Z')))<.0001
            for index,piece in enumerate(asset['parts']):
                item=children[f'{index+1:03d}_{piece["name"]}'];p=props(item)
                assert item.attrib['class']==('WedgePart' if piece.get('shape')=='Wedge' else 'Part')
                assert p['Anchored'].text=='true' and p['CanTouch'].text=='false'
                collide=str(piece.get('collide',piece.get('solid',False))).lower();assert p['CanCollide'].text==collide and p['CanQuery'].text==collide
                assert max(abs(float(p['size'].find(k).text)-piece['size'][i]) for i,k in enumerate(('X','Y','Z')))<.0001
                assert p['Material'].text=='272'
                if item.attrib['class']=='Part':assert int(p['shape'].text)=={'Ball':0,'Block':1,'Cylinder':2}[piece.get('shape','Block')]
                cf=p['CFrame'];assert max(abs(float(cf.find(k).text)-piece['position'][i]) for i,k in enumerate(('X','Y','Z')))<.0001
                x,y,z=map(math.radians,piece.get('rotation',[0,piece.get('yaw',0),0]))
                # Independent closed-form XYZ rotation, compared to exported float32 values.
                cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
                matrix=[cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy]
                assert max(abs(float(cf.find(f'R{i//3}{i%3}').text)-v) for i,v in enumerate(matrix))<.00001
                color=p.get('Color3uint8')
                assert color is not None
                value=int(color.text);rgb=[(value>>16)&255,(value>>8)&255,value&255]
                assert rgb==source['palette'][piece['color']],(piece['name'],rgb)
                checked+=1
    results.append({'pack':pack['id'],'models':len(models),'geometryPartsChecked':checked,'originPivotsPreserved':True,'scriptFree':True,'binarySha256':hashlib.sha256(binary.read_bytes()).hexdigest()})
(OUT/'roundtrip-report.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
print('PREFAB_BINARY_ROUNDTRIP_PASS',len(results),'packs',sum(r['geometryPartsChecked'] for r in results),'geometry comparisons')
