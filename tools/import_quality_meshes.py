"""Validate and package local reviewed mesh data; never uploads or calls Studio."""
from __future__ import annotations
import argparse
import hashlib
import json
import math
import re
from pathlib import Path

ID = re.compile(r"^[A-Za-z0-9_-]{1,100}$")

def reject_constant(value):
    raise ValueError(f"Non-finite JSON: {value}")

def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"Duplicate JSON field: {key}")
        result[key] = value
    return result

def numbers(value, count, bound):
    if (not isinstance(value, list) or len(value) != count or
        any(type(x) not in (int, float) or not math.isfinite(x) or abs(x) > bound for x in value)):
        raise ValueError("Invalid finite numeric vector")

def validate(data):
    if not isinstance(data, dict) or data.get("schemaVersion") != 1:
        raise ValueError("Expected quality mesh schemaVersion 1")
    meshes, placements = data.get("meshes"), data.get("placements")
    if not isinstance(meshes, list) or not 1 <= len(meshes) <= 128:
        raise ValueError("Mesh count outside local preview budget")
    if not isinstance(placements, list) or not 1 <= len(placements) <= 1000:
        raise ValueError("Placement count outside local preview budget")
    ids, total_faces, total_vertices = set(), 0, 0
    for mesh in meshes:
        key = mesh.get("id")
        if not isinstance(key, str) or not ID.fullmatch(key) or key in ids:
            raise ValueError("Invalid or duplicate mesh identity")
        ids.add(key)
        vertices, faces, colors, face_colors = (mesh.get(k) for k in ("vertices", "triangles", "colors", "faceColors"))
        if not isinstance(vertices, list) or not 3 <= len(vertices) <= 20000:
            raise ValueError("Vertex budget exceeded")
        if not isinstance(faces, list) or not 1 <= len(faces) <= 20000:
            raise ValueError("Face budget exceeded")
        if not isinstance(colors, list) or not 1 <= len(colors) <= 4096:
            raise ValueError("Color budget exceeded")
        if not isinstance(face_colors, list) or len(face_colors) != len(faces):
            raise ValueError("Every face requires a color")
        for vertex in vertices:
            numbers(vertex, 3, 10000)
        for color in colors:
            numbers(color, 3, 1)
            if min(color) < 0:
                raise ValueError("Negative color")
        for face, color in zip(faces, face_colors):
            if (not isinstance(face, list) or len(face) != 3 or
                any(type(i) is not int or not 1 <= i <= len(vertices) for i in face) or len(set(face)) != 3):
                raise ValueError("Invalid triangle indices")
            if type(color) is not int or not 1 <= color <= len(colors):
                raise ValueError("Invalid face color")
        total_vertices += len(vertices)
        total_faces += len(faces)
    if total_vertices > 250000 or total_faces > 250000:
        raise ValueError("Total geometry exceeds bounded local preview budget")
    names = set()
    for placement in placements:
        if placement.get("meshId") not in ids:
            raise ValueError("Placement references missing mesh")
        name = placement.get("name")
        if not isinstance(name, str) or not ID.fullmatch(name) or name in names:
            raise ValueError("Invalid or duplicate placement name")
        names.add(name)
        matrix = placement.get("cframe")
        numbers(matrix, 12, 50000)
        rotation = [matrix[3:6], matrix[6:9], matrix[9:12]]
        for i, row in enumerate(rotation):
            if abs(sum(x*x for x in row)-1) > 0.001:
                raise ValueError("Non-unit rotation basis")
            for other in rotation[i+1:]:
                if abs(sum(a*b for a,b in zip(row,other))) > 0.001:
                    raise ValueError("Non-orthogonal rotation")
        a,b,c = rotation
        det = a[0]*(b[1]*c[2]-b[2]*c[1])-a[1]*(b[0]*c[2]-b[2]*c[0])+a[2]*(b[0]*c[1]-b[1]*c[0])
        if abs(det-1) > 0.001:
            raise ValueError("Mirrored rotation must be baked into geometry")
        scale = placement.get("scale", [1,1,1])
        numbers(scale, 3, 100)
        if min(scale) < 0.01:
            raise ValueError("Scale must be positive and bounded")
    return dict(meshes=len(meshes), vertices=total_vertices, triangles=total_faces, placements=len(placements))

def load(path):
    path = Path(path)
    if path.stat().st_size > 64 * 1024 * 1024:
        raise ValueError("Mesh data larger than 64 MiB")
    raw = path.read_bytes()
    data = json.loads(raw.decode('utf-8-sig'), parse_constant=reject_constant, object_pairs_hook=unique_pairs)
    return data, {**validate(data), "sourceSha256": hashlib.sha256(raw).hexdigest()}

def package(path, output):
    data, report = load(path)
    report.update(package_data(data,output))
    report['status']='PACKAGED_LOCAL_PREVIEW_NOT_IMPORTED'
    (Path(output)/'receipt.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report

def package_data(data, output):
    output = Path(output); output.mkdir(parents=True, exist_ok=True)
    # Encode into bounded, data-only ModuleScripts; malicious delimiters cannot
    # escape the Lua long string. Never evaluate input as Lua or Python.
    source = json.dumps(data, separators=(',', ':'), ensure_ascii=True, allow_nan=False)
    chunks = [source[i:i+120000] for i in range(0,len(source),120000)]
    for i, chunk in enumerate(chunks, 1):
        delimiter = '=='
        while ']' + delimiter + ']' in chunk:
            delimiter += '='
        (output / f'Chunk{i}.luau').write_text('return ['+delimiter+'['+chunk+']'+delimiter+']\n', encoding='utf-8')
    (output/'Data.luau').write_text('local pieces={}\nfor i=1,'+str(len(chunks))+' do pieces[i]=require(script.Parent["Chunk"..i]) end\nreturn game:GetService("HttpService"):JSONDecode(table.concat(pieces))\n',encoding='utf-8')
    return {'chunks':len(chunks)}

def package_images(manifest, root, output):
    from PIL import Image
    root=Path(root).resolve()
    data=json.loads(Path(manifest).read_text(encoding='utf-8-sig'),object_pairs_hook=unique_pairs,parse_constant=reject_constant)
    rows=data.get('images')
    if not isinstance(rows,list) or not 1<=len(rows)<=16:
        raise ValueError('Expected one to sixteen reviewed images')
    keys=set(); images=[]; total_pixels=0; sources=[]
    for row in rows:
        key=row.get('key')
        if not isinstance(key,str) or not ID.fullmatch(key) or key in keys:
            raise ValueError('Invalid or duplicate image key')
        keys.add(key)
        relative=Path(row['path'])
        path=(root/relative).resolve()
        if relative.is_absolute() or not path.is_relative_to(root/'assets/production/ui-slice') or path.suffix.lower()!='.png':
            raise ValueError('UI image must be a selected PNG in assets/production/ui-slice')
        with Image.open(path) as source:
            w,h=source.size
            total_pixels+=w*h
            if not 1<=w<=1024 or not 1<=h<=1024 or total_pixels>1048576:
                raise ValueError('Image memory budget exceeded')
            # Exact format conversion only: no crop, resize, retouch or generated art.
            raw=source.convert('RGBA').tobytes()
        runs=[]
        for offset in range(0,len(raw),4):
            rgba=int.from_bytes(raw[offset:offset+4],'little')
            if runs and runs[-1][1]==rgba:
                runs[-1][0]+=1
            else:
                runs.append([1,rgba])
        image={'key':key,'width':w,'height':h,'runs':runs}
        if row.get('sliceCenter') is not None:
            center=row['sliceCenter']; numbers(center,4,1024)
            if any(type(x) is not int for x in center) or not (0<=center[0]<center[2]<=w and 0<=center[1]<center[3]<=h):
                raise ValueError('Invalid image slice center')
            image['sliceCenter']=center
        images.append(image)
        sources.append({'key':key,'path':relative.as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'width':w,'height':h})
    report={**package_data({'schemaVersion':1,'images':images},output),'images':sources,'pixels':total_pixels,'status':'PACKAGED_EXACT_LOCAL_IMAGE_PREVIEW_NOT_UPLOADED'}
    (Path(output)/'receipt.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    return report

if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source',type=Path)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    print(json.dumps(package(args.source,args.output) if args.output else load(args.source)[1],indent=2))
