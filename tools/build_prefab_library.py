"""Build script-free local Roblox model packs from the authored geometry manifests.

Format references: https://rojo.space/docs/v7/properties/ and
https://dom.rojo.space/xml.html (WorldPivotData optional coordinate frame).
"""
from pathlib import Path
import json,math,subprocess,xml.etree.ElementTree as ET,hashlib
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/roblox-prefabs';OUT.mkdir(parents=True,exist_ok=True)
BUILD=ROOT/'build/prefabs';BUILD.mkdir(parents=True,exist_ok=True);ROJO=ROOT/'.tools/rojo/rojo.exe'
KITS=['adventure-kit','weapon-kit','item-kit','hero-kit','enemy-kit','region-kit','cosmetic-kit','city-interior-kit']
def multiply(a,b):return [[sum(a[i][k]*b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
def cframe(position,rotation):
    x,y,z=map(math.radians,rotation);cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
    matrix=multiply(multiply([[1,0,0],[0,cx,-sx],[0,sx,cx]],[[cy,0,sy],[0,1,0],[-sy,0,cy]]),[[cz,-sz,0],[sz,cz,0],[0,0,1]])
    return position+[v for row in matrix for v in row]
def attr(value):return {'Bool' if isinstance(value,bool) else 'String':value}
def geometry(p,palette):
    shape=p.get('shape','Block');assert shape in ('Block','Wedge','Ball','Cylinder'),shape
    rotation=p.get('rotation',[0,p.get('yaw',0),0]);rgb=palette[p['color']]
    props=dict(Size=p['size'],CFrame=cframe(p['position'],rotation),Color=[v/255 for v in rgb],Material='SmoothPlastic',Anchored=True,CanCollide=p.get('collide',p.get('solid',False)),CanTouch=False,CanQuery=p.get('collide',p.get('solid',False)),TopSurface='Smooth',BottomSurface='Smooth')
    if shape!='Wedge':props['Shape']=shape
    props['Attributes']={'SourcePartName':attr(p['name'])}
    return {'$className':'WedgePart' if shape=='Wedge' else 'Part','$properties':props}
categories={};models=parts=markers=routes=0
for kit in KITS:
    source=ROOT/'assets/uat01'/kit/'kit.json';data=json.loads(source.read_text(encoding='utf-8'))
    category={'$className':'Folder'}
    for a in data['assets']:
        m={'$className':'Model','$properties':{'Attributes':{'AssetId':attr(a['id']),'SourceKit':attr(kit),'StaticArtOnly':attr(True),'GameplayBound':attr(False)}}}
        for i,p in enumerate(a['parts']):m[f'{i+1:03d}_{p["name"]}']=geometry(p,data['palette']);parts+=1
        if a.get('markers'):
            f={'$className':'Folder'}
            for marker in a['markers']:
                f[marker['name']]={'$className':'Part','$properties':{'Size':[1,1,1],'CFrame':cframe(marker['position'],[0,0,0]),'Transparency':1,'Anchored':True,'CanCollide':False,'CanQuery':False,'CanTouch':False,'Attributes':{'VisualRole':attr(marker['role'])}}};markers+=1
            m['EncounterMarkers']=f
        if a.get('routes'):
            f={'$className':'Folder'}
            for route in a['routes']:
                f[route['name']]={'$className':'Folder',**{str(i+1):{'$className':'Vector3Value','$properties':{'Value':point}} for i,point in enumerate(route['points'])}};routes+=1
            m['ReviewRoutes']=f
        category[a['id']]=m;models+=1
    categories[kit]=category
reports=[]
for name,tree in [('GuildbornePrefabLibrary',{'$className':'Folder',**categories})]+[(kit,tree) for kit,tree in categories.items()]:
    project=BUILD/(name+'.project.json');raw=BUILD/(name+'-raw.rbxmx')
    project.write_text(json.dumps({'name':name,'tree':tree}),encoding='utf-8')
    subprocess.run([str(ROJO),'build',str(project),'--output',str(raw)],check=True,capture_output=True)
    xml=ET.parse(raw)
    for item in xml.iter('Item'):
        if item.attrib['class']=='Model':
            props=item.find('Properties')
            for old in list(props):
                if old.attrib.get('name')=='WorldPivotData':props.remove(old)
            pivot=ET.SubElement(props,'OptionalCoordinateFrame',name='WorldPivotData');cf=ET.SubElement(pivot,'CFrame')
            for key,value in zip(['X','Y','Z','R00','R01','R02','R10','R11','R12','R20','R21','R22'],[0,0,0,1,0,0,0,1,0,0,0,1]):ET.SubElement(cf,key).text=str(value)
    path=OUT/(name+'.rbxmx');xml.write(path,encoding='utf-8',xml_declaration=True)
    wrapper=BUILD/(name+'-binary.project.json');wrapper.write_text(json.dumps({'name':name,'tree':{'$path':str(path)}}),encoding='utf-8')
    binary=OUT/(name+'.rbxm');subprocess.run([str(ROJO),'build',str(wrapper),'--output',str(binary)],check=True,capture_output=True)
    reports.append({'id':name,'models':sum(x.attrib['class']=='Model' for x in xml.iter('Item')),'parts':sum(x.attrib['class'] in ('Part','WedgePart') for x in xml.iter('Item')),'rbxmBytes':binary.stat().st_size,'sha256':hashlib.sha256(binary.read_bytes()).hexdigest()})
result=dict(schema=1,kits=len(KITS),models=models,visibleParts=parts,invisibleMarkers=markers,reviewRoutes=routes,packs=reports,scriptFree=True,cloudImported=False,staticArtOnly=True)
(OUT/'pack-report.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print('PREFAB_PACKS_BUILT',len(reports),'packs',models,'models',parts,'visible parts')
