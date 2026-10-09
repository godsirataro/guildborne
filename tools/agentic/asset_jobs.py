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
    if row['files'] and not allow_rework: raise ValueError('Existing source found: review/reuse first or explicitly approve rework')
    refs=[]
    for f in row['files']:
        p=inside(root,f['path'])
        if not p.is_file() or digest(p)!=f['sha256']:raise ValueError('Source changed since reconciliation; rerun audit')
        refs.append(f['path'])
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
        'state':'AWAITING_VERIFIED_PROVIDER','existingSources':refs,'prompt':prompt,
        'provider':None,'runtimeImported':False,'uatApproved':False,
        'reworkApproved':bool(allow_rework),'sourceRegistrySha256':report.get('registrySha256')}


def inspect_png(path: Path):
    if path.stat().st_size>32*1024*1024:raise ValueError('PNG byte budget exceeded')
    data=path.read_bytes()
    if data[:8]!=b'\x89PNG\r\n\x1a\n':raise ValueError('Not a PNG')
    offset=8;header=None;ended=False
    while offset<len(data):
        if offset+12>len(data):raise ValueError('Truncated PNG')
        n=struct.unpack('>I',data[offset:offset+4])[0];end=offset+n+12
        if end>len(data):raise ValueError('Truncated PNG chunk')
        kind=data[offset+4:offset+8];body=data[offset+8:offset+8+n]
        if struct.unpack('>I',data[offset+8+n:end])[0] != zlib.crc32(kind+body)&0xffffffff:
            raise ValueError('PNG checksum mismatch')
        if header is None:
            if kind!=b'IHDR' or len(body)!=13:raise ValueError('Missing first IHDR')
            width,height,depth,color,compression,filtering,interlace=struct.unpack('>IIBBBBB',body)
            if not 1<=width<=4096 or not 1<=height<=4096:raise ValueError('PNG dimension budget exceeded')
            if depth!=8 or color not in (2,6) or compression!=0 or filtering!=0 or interlace!=0:
                raise ValueError('Use normalized 8-bit noninterlaced RGB/RGBA production candidates')
            header={'width':width,'height':height,'hasAlphaChannel':color==6}
        if kind==b'IEND':
            if n or end!=len(data):raise ValueError('Malformed PNG end')
            ended=True
        offset=end
    if not ended:raise ValueError('Missing IEND')
    return {**header,'scope':'CONTAINER_AND_CRC_ONLY_PIXEL_DECODE_AND_VISUAL_REVIEW_PENDING'}


def inspect_candidate(root: Path, job: dict, relative: str, provenance: dict):
    if job.get('state')!='AWAITING_VERIFIED_PROVIDER':raise ValueError('Job is not awaiting a candidate')
    if any(not isinstance(provenance.get(k),str) or not provenance[k].strip() for k in ('origin','tool','rights')):
        raise ValueError('Origin, actual tool and rights declaration required')
    source=inside(root,relative)
    if source.is_symlink() or not source.is_file() or source.stat().st_size==0:raise ValueError('Missing source candidate')
    if source.suffix.lower()!='.png':raise ValueError('This inspector handles PNG only; meshes/audio need their specialist validators')
    return {'schemaVersion':2,'identity':job['identity'],'source':relative,'sha256':digest(source),
        'image':inspect_png(source),'provenance':provenance,'rightsVerified':False,
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
