"""Offline source-geometry comparison; approximate lighting, never Studio evidence."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[3]
BASE = '6c5be3b'
IDS = ('stone', 'iron_ore', 'iron_ingot', 'timber', 'herb')
OUT = ROOT / 'assets/production/ui-slice/material-portraits-v9'
BOX = np.array([[-1,-1,-1],[1,-1,-1],[1,1,-1],[-1,1,-1],[-1,-1,1],[1,-1,1],[1,1,1],[-1,1,1]], dtype=float)/2
BOX_FACES = ((0,3,2,1),(4,5,6,7),(0,1,5,4),(3,7,6,2),(0,4,7,3),(1,2,6,5))
# Roblox WedgePart rises from -Z to +Z, with full rectangular rear (+Z).
WEDGE = BOX[[0,1,4,5,6,7]]
WEDGE_FACES = ((0,1,3,2),(2,3,4,5),(0,2,5),(1,4,3),(0,5,4,1))

def git_file(path):
    return subprocess.check_output(['git','show',f'{BASE}:{path}'], cwd=ROOT)

def rotation(degrees):
    x,y,z = np.radians(degrees)
    cx,cy,cz = np.cos([x,y,z]); sx,sy,sz = np.sin([x,y,z])
    return np.array([[1,0,0],[0,cx,-sx],[0,sx,cx]]) @ np.array([[cy,0,sy],[0,1,0],[-sy,0,cy]]) @ np.array([[cz,-sz,0],[sz,cz,0],[0,0,1]])

def corners(part, actual=False):
    vertices = WEDGE if actual and part.get('shape') == 'Wedge' else BOX
    return (vertices*np.array(part['size'])) @ rotation(part['rotation']).T + part['position']

def camera(asset):
    bounds = np.concatenate([corners(p) for p in asset['parts']])
    low,high = bounds.min(axis=0),bounds.max(axis=0)
    center = (low+high)/2
    radius = np.linalg.norm(high-low)/2
    direction = np.array([1,.4,-3]); direction /= np.linalg.norm(direction)
    eye = center+direction*(radius/np.sin(np.radians(17.5))*1.12)
    forward = -direction
    right = np.cross(forward,[0,1,0]); right /= np.linalg.norm(right)
    up = np.cross(right,forward)
    basis = np.array([right,up,forward])
    points = (bounds-eye) @ basis.T
    normalized = points[:,:2]/points[:,2,None]/np.tan(np.radians(17.5))
    assert np.all(points[:,2]>0) and np.max(np.abs(normalized)) < 1, asset['id']+' frustum'
    return eye,basis,float(np.max(np.abs(normalized)))

def render(asset,palette):
    eye,basis,fit = camera(asset)
    pixels = np.full((80,80,3),[26,34,49],dtype=np.uint8)
    depth = np.full((80,80),np.inf)
    light = np.array([1,2,3],dtype=float); light /= np.linalg.norm(light)
    for part in asset['parts']:
        world = corners(part,True)
        cam = (world-eye) @ basis.T
        uv = cam[:,:2]/cam[:,2,None]/np.tan(np.radians(17.5))
        screen = np.column_stack(((uv[:,0]+1)*40,(1-uv[:,1])*40))
        faces = WEDGE_FACES if part.get('shape')=='Wedge' else BOX_FACES
        for face in faces:
            a,b,c = world[list(face[:3])]
            normal=np.cross(b-a,c-a); normal/=np.linalg.norm(normal)
            if np.dot(normal,world[list(face)].mean(axis=0)-world.mean(axis=0))<0: normal=-normal
            # Deliberately approximate SmoothPlastic shading, no texture/shadows.
            shade=.68+.32*max(0,float(normal@light))
            color=np.clip(np.array(palette[part['color']])*shade,0,255).astype(np.uint8)
            for i in range(1,len(face)-1):
                tri=[face[0],face[i],face[i+1]]; q=screen[tri]
                lo=np.maximum(np.floor(q.min(axis=0)).astype(int),0)
                hi=np.minimum(np.ceil(q.max(axis=0)).astype(int),79)
                if np.any(lo>hi): continue
                xs,ys=np.meshgrid(np.arange(lo[0],hi[0]+1)+.5,np.arange(lo[1],hi[1]+1)+.5)
                a,b,c=q; denom=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
                if abs(denom)<1e-10: continue
                w0=((b[1]-c[1])*(xs-c[0])+(c[0]-b[0])*(ys-c[1]))/denom
                w1=((c[1]-a[1])*(xs-c[0])+(a[0]-c[0])*(ys-c[1]))/denom
                w2=1-w0-w1
                reciprocal=w0/cam[tri[0],2]+w1/cam[tri[1],2]+w2/cam[tri[2],2]
                z=1/np.maximum(reciprocal,1e-20)
                area=(slice(lo[1],hi[1]+1),slice(lo[0],hi[0]+1))
                mask=(w0>=-1e-9)&(w1>=-1e-9)&(w2>=-1e-9)&(z<depth[area])
                depth[area][mask]=z[mask]; pixels[area][mask]=color
    return Image.fromarray(pixels),fit,int(np.isfinite(depth).sum())

def verify(before,after):
    old={a['id']:a for a in before['assets']}; new={a['id']:a for a in after['assets']}
    assert set(old)==set(new) and len(new)==30
    changed={key for key in old if old[key]!=new[key]}
    assert changed==set(IDS), sorted(changed)
    for key,asset in new.items():
        assert 0<len(asset['parts'])<=16
        for part in asset['parts']:
            assert part.get('shape','Part') in ('Part','Wedge')
            for field in ('size','position','rotation'):
                assert len(part[field])==3 and np.isfinite(part[field]).all()
            assert (np.array(part['size'])>0).all()
            assert part['color'] in after['palette']
        if key not in IDS:
            assert old[key]==asset
            for part in asset['parts']:
                assert before['palette'][part['color']]==after['palette'][part['color']]
        camera(asset)
    suffix='return function(id: string): Model?'
    baseline=git_file('src/shared/Data/ItemVisuals.luau').decode().replace('\r\n','\n')
    current=(ROOT/'src/shared/Data/ItemVisuals.luau').read_text()
    assert baseline.split(suffix,1)[1]==current.split(suffix,1)[1], 'constructor changed'
    return old,new

def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--check-only',action='store_true'); args=parser.parse_args()
    raw=(ROOT/'assets/uat01/item-kit/kit.json').read_bytes()
    before=json.loads(git_file('assets/uat01/item-kit/kit.json')); after=json.loads(raw)
    old,new=verify(before,after)
    report={'status':'PASS','evidence':'LOCAL APPROXIMATION NOT STUDIO','baseline':BASE,'sourceSha256':hashlib.sha256(raw).hexdigest(),'unchangedDefinitionsAndResolvedColors':25,'constructorUnchanged':True,'frustumCheckedItems':30,'camera':{'pixels':[80,80],'verticalFov':35,'direction':[1,.4,-3],'sphereFitMargin':1.12},'limitations':'CPU rasterized source geometry with approximate lighting; not Roblox rendering, device QA, asset imports or human approval.','materials':{}}
    sheet=Image.new('RGB',(950,635),(15,21,35)); draw=ImageDraw.Draw(sheet)
    draw.text((15,12),'LOCAL APPROXIMATION NOT STUDIO | native geometry / 80 x 80 camera',fill=(245,236,216))
    draw.text((15,34),'Top: baseline | Bottom: candidate | each row: 80px + nearest-neighbor 2x',fill=(220,183,107))
    for col,key in enumerate(IDS):
        x=15+col*187; draw.text((x,65),key,fill=(245,236,216))
        for row,(label,data,palette) in enumerate((('before',old,before['palette']),('after',new,after['palette']))):
            img,fit,covered=render(data[key],palette); y=95+row*270
            draw.text((x,y),label,fill=(220,183,107))
            sheet.paste(img,(x+80,y)); sheet.paste(img.resize((160,160),Image.Resampling.NEAREST),(x,y+85))
            report['materials'].setdefault(key,{})[label]={'parts':len(data[key]['parts']),'maximumFrustumFraction':fit,'coveredPixels':covered}
            if not args.check_only:
                OUT.mkdir(parents=True,exist_ok=True); img.save(OUT/f'{key}-{label}-80.png')
    if not args.check_only:
        sheet.save(OUT/'comparison.png'); (OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__=='__main__': main()
