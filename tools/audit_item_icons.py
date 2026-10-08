"""Read icon alpha/margins without modifying any rendered pixels."""
from pathlib import Path
import json,hashlib,argparse
from PIL import Image
parser=argparse.ArgumentParser();parser.add_argument('--kit',default='assets/uat01/item-kit');options=parser.parse_args()
folder=Path(__file__).resolve().parents[1]/options.kit;report=[]
for item in json.loads((folder/'export-report.json').read_text(encoding='utf-8')):
    path=folder/item['icon']
    with Image.open(path) as im:
        assert im.mode=='RGBA' and im.size==(512,512),path.name
        alpha=im.getchannel('A');bounds=alpha.getbbox();assert bounds,path.name
        margin=min(bounds[0],bounds[1],512-bounds[2],512-bounds[3]);assert margin>=24,(path.name,margin)
        report.append({'id':item['id'],'file':path.name,'size':[512,512],'transparentMarginPx':margin,'alphaRange':alpha.getextrema(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
(folder/'icon-audit.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('ITEM_ICON_PASS',len(report),'RGBA icons; minimum margin',min(r['transparentMarginPx'] for r in report))
