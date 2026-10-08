"""Read-only per-tile alpha inspection; never changes the rendered atlas pixels."""
from pathlib import Path
from PIL import Image
import json,hashlib
folder=Path(__file__).resolve().parents[1]/'assets/uat01/vfx-native'
path=folder/'guildborne-shockwave-4x4-v1.png';layout=json.loads((folder/'layout.json').read_text(encoding='utf-8'))
with Image.open(path) as im:
    assert im.size==(2048,2048) and im.mode=='RGBA'
    alpha=im.getchannel('A');report=[]
    for frame in layout['frames']:
        a=alpha.crop(frame['rectXYXY']);bounds=a.getbbox();assert bounds,frame['frame']
        margin=min(bounds[0],bounds[1],512-bounds[2],512-bounds[3]);assert margin>=40,(frame['frame'],margin)
        report.append({'frame':frame['frame'],'alphaBounds':bounds,'transparentMarginPx':margin,'alphaRange':a.getextrema()})
    assert report[-1]['alphaRange'][1]<report[0]['alphaRange'][1]
(folder/'alpha-report.json').write_text(json.dumps({'file':path.name,'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'frames':report,'pixelDataModified':False,'robloxCompressionVerified':False},indent=2)+'\n',encoding='utf-8')
print('FLIPBOOK_ALPHA_PASS 16 nonempty tiles,>=40px clear margin,transparent RGBA,final opacity reduced')
