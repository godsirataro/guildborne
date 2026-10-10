"""Prepare selected generation jobs and validate local returned files; never calls a provider."""
from __future__ import annotations
import argparse
from pathlib import Path
import struct
import sys
import zlib
from forge import ROOT, digest, inside, read_json, save_json


def prepare(root: Path, report: dict, identity: str, *, allow_rework=False):
    rows=[r for r in report['entries'] if r['id']==identity]
    if len(rows)!=1: raise ValueError('Select exactly one reconciled canonical identity')
    row=rows[0]
    if row['kind']=='screen': raise ValueError('Screens are native interactive UI, not baked full-screen image jobs')
    if (row['files'] or row.get('directories')) and not allow_rework: raise ValueError('Existing source found: review/reuse first or explicitly approve rework')
    refs=[]
    for f in row['files']:
        p=inside(root,f['path'])
        if not p.is_file() or digest(p)!=f['sha256']:raise ValueError('Source changed since reconciliation; rerun audit')
        refs.append(f['path'])
    directories=[]
    for entry in row.get('directories', []):
        path=inside(root,entry['path'])
        if not path.is_dir():raise ValueError('Source directory changed since reconciliation; rerun audit')
        directories.append(entry['path'])
    prompt=('Create an original Guildborne production candidate for '+row['designId']+'. '
        'Read production/ART_BIBLE.md and the routed specialist skill. '
        'Reuse the listed sources and preserve semantic identity. Do not bake dynamic text, prices, '
        'cooldowns, account names or localized copy into raster art. '
        'For bodies: actual R15 parts, removable clothes and preset-specific fitting; '
        'a concept sheet is not a mesh. For VFX: coherent frames and alpha, anticipation/action/impact/fade; '
        'never determine gameplay damage. No external upload or purchases. '
        'Record provider/tool, prompt revision, rights and local output paths. '
        'Report unavailable tools rather than substitute a screenshot for a rig or interaction. '
        'No new Roblox asset IDs or UAT approval may be invented.')
    return {'schemaVersion':2,'identity':identity,'workPackage':row['workPackage'],
        'state':'AWAITING_VERIFIED_PROVIDER','existingSources':refs,'existingSourceDirectories':directories,'prompt':prompt,
        'provider':None,'runtimeImported':False,'uatApproved':False,
        'reworkApproved':bool(allow_rework),'sourceRegistrySha256':report.get('registrySha256')}


def inspect_png(path: Path):
    """Decode normalized RGB/RGBA PNGs with bounded memory; not an art-quality gate."""
    if path.stat().st_size > 32 * 1024 * 1024:
        raise ValueError('PNG byte budget exceeded')
    data = path.read_bytes()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError('Not a PNG')
    offset, header, ended, idat_closed = 8, None, False, False
    compressed = []
    while offset < len(data):
        if offset + 12 > len(data):
            raise ValueError('Truncated PNG')
        n = struct.unpack('>I', data[offset:offset+4])[0]
        end = offset + n + 12
        if end > len(data):
            raise ValueError('Truncated PNG chunk')
        kind, body = data[offset+4:offset+8], data[offset+8:offset+8+n]
        if not all(65 <= c <= 90 or 97 <= c <= 122 for c in kind):
            raise ValueError('Invalid PNG chunk name')
        if struct.unpack('>I', data[offset+8+n:end])[0] != zlib.crc32(kind+body) & 0xffffffff:
            raise ValueError('PNG checksum mismatch')
        if header is None and kind != b'IHDR':
            raise ValueError('Missing first IHDR')
        if kind == b'IHDR':
            if header is not None or len(body) != 13:
                raise ValueError('Duplicate or malformed IHDR')
            width, height, depth, color, compression, filtering, interlace = struct.unpack('>IIBBBBB', body)
            if not 1 <= width <= 4096 or not 1 <= height <= 4096:
                raise ValueError('PNG dimension budget exceeded')
            if depth != 8 or color not in (2, 6) or compression or filtering or interlace:
                raise ValueError('Use normalized 8-bit noninterlaced RGB/RGBA production candidates')
            header = {'width': width, 'height': height, 'hasAlphaChannel': color == 6}
        elif kind == b'IDAT':
            if idat_closed:
                raise ValueError('Non-contiguous IDAT chunks')
            compressed.append(body)
        elif kind == b'IEND':
            if n or end != len(data) or not compressed:
                raise ValueError('Malformed PNG end or missing image data')
            ended = True
        else:
            if compressed:
                idat_closed = True
            if kind == b'PLTE':
                if compressed or not n or n > 768 or n % 3:
                    raise ValueError('Malformed or misplaced palette')
            elif not kind[0] & 32:
                raise ValueError('Unsupported critical PNG chunk')
        offset = end
    if not ended or header is None:
        raise ValueError('Missing IEND')
    channels = 4 if header['hasAlphaChannel'] else 3
    stride = header['width'] * channels
    expected = (stride + 1) * header['height']
    decoder = zlib.decompressobj()
    try:
        raw = decoder.decompress(b''.join(compressed), expected + 1)
    except zlib.error as exc:
        raise ValueError('Invalid PNG compressed pixels') from exc
    if (len(raw) != expected or not decoder.eof or decoder.unconsumed_tail or decoder.unused_data):
        raise ValueError('PNG decoded size/stream mismatch')
    previous = bytearray(stride)
    alpha_min, alpha_max, visible = 255, 0, 0
    for y in range(header['height']):
        start = y * (stride + 1)
        filter_type = raw[start]
        if filter_type > 4:
            raise ValueError('Invalid PNG scanline filter')
        row = bytearray(raw[start+1:start+1+stride])
        if filter_type:
            for x in range(stride):
                left = row[x-channels] if x >= channels else 0
                up = previous[x]
                upper_left = previous[x-channels] if x >= channels else 0
                if filter_type == 1:
                    prediction = left
                elif filter_type == 2:
                    prediction = up
                elif filter_type == 3:
                    prediction = (left + up) // 2
                else:
                    q = left + up - upper_left
                    distances = (abs(q-left), abs(q-up), abs(q-upper_left))
                    prediction = (left if distances[0] <= distances[1] and distances[0] <= distances[2]
                                  else up if distances[1] <= distances[2] else upper_left)
                row[x] = (row[x] + prediction) & 255
        if channels == 4:
            alpha = row[3::4]
            alpha_min, alpha_max = min(alpha_min, min(alpha)), max(alpha_max, max(alpha))
            visible += len(alpha) - alpha.count(0)
        else:
            alpha_max = 255
            visible += header['width']
        previous = row
    return {**header, 'alphaMin': alpha_min, 'alphaMax': alpha_max,
            'hasTransparentPixels': alpha_min < 255, 'visiblePixels': visible,
            'scope': 'BOUNDED_PIXEL_DECODE_AND_ALPHA_ONLY_VISUAL_REVIEW_PENDING'}


def inspect_candidate(root: Path, job: dict, relative: str, provenance: dict):
    if job.get('state')!='AWAITING_VERIFIED_PROVIDER':raise ValueError('Job is not awaiting a candidate')
    if any(not isinstance(provenance.get(k),str) or not provenance[k].strip() for k in ('origin','tool','rights')):
        raise ValueError('Origin, actual tool and rights declaration required')
    source=inside(root,relative)
    if source.is_symlink() or not source.is_file() or source.stat().st_size==0:raise ValueError('Missing source candidate')
    if source.suffix.lower()!='.png':raise ValueError('This inspector handles PNG only; meshes/audio need their specialist validators')
    image = inspect_png(source)
    if image['visiblePixels'] == 0:
        raise ValueError('Fully transparent candidate has no visible content')
    return {'schemaVersion':2,'identity':job['identity'],'source':relative,'sha256':digest(source),
        'image':image,'provenance':provenance,'rightsVerified':False,
        'status':'LOCAL_CANDIDATE_REQUIRES_REVIEW','robloxAssetId':None,'uatApproved':False}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--identity',required=True);p.add_argument('--allow-rework',action='store_true')
    a=p.parse_args();report=read_json(ROOT/'build/agentic/reconciliation.json')
    job=prepare(ROOT,report,a.identity,allow_rework=a.allow_rework)
    # IDs never become filenames directly.
    import hashlib
    out=ROOT/'build/agentic/asset-jobs'/hashlib.sha256(a.identity.encode()).hexdigest()
    save_json(out/'job.json',job)
    print(out/'job.json','AWAITING_VERIFIED_PROVIDER; no external provider called')


if __name__=='__main__':
    try:main()
    except (OSError,ValueError,KeyError,TypeError) as exc:
        print(f'Asset job blocked: {exc}',file=sys.stderr);sys.exit(1)
