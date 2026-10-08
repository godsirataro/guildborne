#!/usr/bin/env python3
"""Checksum-verified safe intake of the user-supplied Modular Character Kit v1."""
from __future__ import annotations
import argparse
import hashlib
from pathlib import Path, PurePosixPath
import shutil
import stat
import tempfile
import zipfile
from forge import ROOT, inside, read_json, save_json

# Filled from the supplied archive, not from an untrusted download endpoint.
EXPECTED_SHA256 = '476e5a53755bac952e0adfa9ecee038c013e911852ee9bcefc95f2822320cb23'
PREFIX = 'Guildborne_Character_Pipeline_v1'


def import_kit(archive: Path, root: Path):
    if archive.stat().st_size > 4*1024*1024:
        raise ValueError('Archive exceeds intake limit')
    if hashlib.sha256(archive.read_bytes()).hexdigest() != EXPECTED_SHA256:
        raise ValueError('Not the reviewed Character Kit v1 archive; inspect changes before updating checksum')
    destination=inside(root,'production/character-kit-v1/original')
    if destination.exists():
        raise ValueError('Intake already exists; never reset production status by overwriting it')
    destination.parent.mkdir(parents=True,exist_ok=True)
    staging=Path(tempfile.mkdtemp(prefix='.kit-intake-',dir=destination.parent))
    try:
        with zipfile.ZipFile(archive) as bundle:
            files=bundle.infolist()
            if len(files)>64 or sum(f.file_size for f in files)>2*1024*1024:
                raise ValueError('Expanded archive exceeds intake limit')
            seen=set()
            for entry in files:
                p=PurePosixPath(entry.filename)
                if '\\' in entry.filename or ':' in entry.filename or p.is_absolute() or '..' in p.parts or not p.parts or p.parts[0]!=PREFIX:
                    raise ValueError('Unsafe or unexpected archive member')
                key=p.as_posix().casefold()
                if key in seen or stat.S_ISLNK(entry.external_attr >> 16):
                    raise ValueError('Duplicate or symlink archive member')
                seen.add(key)
                target=staging/p
                if entry.is_dir(): target.mkdir(parents=True,exist_ok=True);continue
                target.parent.mkdir(parents=True,exist_ok=True)
                target.write_bytes(bundle.read(entry))
        manifest=read_json(staging/PREFIX/'manifest/asset_registry.json')
        presets=read_json(staging/PREFIX/'manifest/body_presets.json')
        palettes=read_json(staging/PREFIX/'manifest/skin_palettes.json')
        if len(manifest['assets'])!=89 or len(presets['presets'])!=13 or len(palettes['palettes'])!=20:
            raise ValueError('Unexpected original catalog counts')
        if any(a['status']!='PLANNED' or a['roblox_asset_id'] is not None for a in manifest['assets']):
            raise ValueError('Original source must not assert generated/imported assets')
        staging.rename(destination)
        save_json(destination.parent/'intake-receipt.json',{'archiveSha256':EXPECTED_SHA256,'assets':89,'bodyPresets':13,'skinPalettes':20,'executedBundledScripts':False,'runtimeImported':False})
    finally:
        if staging.exists(): shutil.rmtree(staging)
    return destination


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('archive',type=Path)
    p.add_argument('--root',type=Path,default=ROOT)
    a=p.parse_args()
    try: print(import_kit(a.archive,a.root.resolve()))
    except (ValueError,OSError,zipfile.BadZipFile,KeyError) as e: p.exit(2,f'INTAKE_ERROR: {e}\n')
