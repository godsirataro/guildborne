#!/usr/bin/env python3
"""Generate original procedural UI/VFX previews offline; not final illustrated art."""
from __future__ import annotations
import argparse
import hashlib
import json
import math
from pathlib import Path
import struct
import zlib
from forge import ROOT, inside, save_json


def chunk(kind: bytes, payload: bytes) -> bytes:
    return struct.pack('>I', len(payload)) + kind + payload + struct.pack('>I', zlib.crc32(kind + payload) & 0xffffffff)


def png(width: int, height: int, pixels: bytes) -> bytes:
    if not 1 <= width <= 4096 or not 1 <= height <= 4096 or len(pixels) != width * height * 4:
        raise ValueError('Invalid RGBA dimensions or pixel length')
    raw = b''.join(b'\x00' + pixels[y*width*4:(y+1)*width*4] for y in range(height))
    return b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b'')


def effect_sheet(name: str, size=128):
    if name not in ('taunt', 'slash', 'shot', 'fire', 'heal') or not 16 <= size <= 256:
        raise ValueError('Unknown effect or invalid cell size')
    colors = {'taunt':(143,201,238),'slash':(255,144,70),'shot':(159,220,112),'fire':(255,170,52),'heal':(255,231,172)}
    width = height = size * 4
    pixels = bytearray(width*height*4)
    for frame in range(16):
        t = frame / 15
        # Start/end fully transparent. Keep a margin to avoid neighboring-cell bleed.
        fade = math.sin(math.pi*t)**0.75
        for y in range(size):
            for x in range(size):
                xx, yy = (x+.5-size/2)/(size/2), (y+.5-size/2)/(size/2)
                r, angle = math.hypot(xx, yy), math.atan2(yy, xx)
                if r >= .87 or frame in (0,15):
                    continue
                radius = .12 + .64*t
                ring = math.exp(-((r-radius)/.045)**2)
                if name == 'taunt': a = ring
                elif name == 'slash': a = ring * max(0, math.cos(angle-5*t))**2
                elif name == 'shot': a = math.exp(-(yy/.09)**2) * max(0, 1-abs(xx-(t-.5))/.7)
                elif name == 'fire': a = math.exp(-(r/(.16+.36*t))**2) * (.75+.25*math.cos(angle*7+r*22-t*14))
                else: a = .65*ring + .35*math.exp(-(r/.22)**2)
                alpha = round(255 * min(1, max(0, a*fade)))
                dx, dy = (frame % 4)*size+x, (frame // 4)*size+y
                offset = (dy*width+dx)*4
                pixels[offset:offset+4] = bytes((*colors[name], alpha))
    return png(width, height, bytes(pixels))


def panel(size=256):
    pixels=bytearray(size*size*4)
    for y in range(size):
        for x in range(size):
            edge=min(x,y,size-1-x,size-1-y)
            cut = min(x+y, x+(size-1-y), (size-1-x)+y, (size-1-x)+(size-1-y))
            if cut < 14: continue
            if 5 <= edge <= 7: rgba=(210,172,96,255)
            elif edge < 5: rgba=(15,21,32,210)
            else: rgba=(23,31,46,240)
            i=(y*size+x)*4;pixels[i:i+4]=bytes(rgba)
    return png(size,size,bytes(pixels))


def generate(root: Path, size=128):
    root = root.resolve()
    out=inside(root,'build/agentic/generated/primitives')
    out.mkdir(parents=True,exist_ok=True)
    records=[]
    def emit(name,data,metadata):
        path=out/name
        if path.is_symlink(): raise ValueError('Refuse symlink output')
        path.write_bytes(data)
        records.append(dict(id='gb-preview-'+Path(name).stem,source=path.relative_to(root).as_posix(),sha256=hashlib.sha256(data).hexdigest(),status='PROCEDURAL_PREVIEW',robloxAssetId=None,**metadata))
    emit('panel.png',panel(),{'kind':'nine_slice','size':[256,256],'sliceCenter':[20,20,236,236],'containsText':False})
    for name in ('taunt','slash','shot','fire','heal'):
        emit(name+'.png',effect_sheet(name,size),{'kind':'flipbook','size':[size*4,size*4],'grid':[4,4],'frameCount':16,'sequence':'row-major','cellSize':[size,size],'loop':False,'containsText':False})
    save_json(out/'manifest.json',{'schemaVersion':1,'origin':'original-procedural-code','note':'A repeatable fallback/test texture pack, not hand-directed final art or Studio acceptance.','assets':records})
    return records


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--cell-size',type=int,default=128)
    args=parser.parse_args()
    result=generate(args.root.resolve(),args.cell_size)
    print(json.dumps({'files':len(result),'status':'PROCEDURAL_PREVIEW','studioTested':False}))
