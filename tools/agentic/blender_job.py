"""Run a reviewed local Blender body audit with auto-execution disabled; no model generation."""
from __future__ import annotations
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import uuid
from forge import ROOT, digest, inside, read_json, save_json
from run_worker import run_process


def command(executable: str, source: Path, script: Path, collection: str, report: Path):
    if not collection or len(collection)>100 or '\0' in collection:raise ValueError('Explicit body collection required')
    return [executable,'--background','--disable-autoexec',str(source),'--python-exit-code','2',
        '--python',str(script),'--','--collection',collection,'--report',str(report)]


def audit(root: Path, executable: str, relative: str, expected_sha: str, collection: str, *, approved=False, invoke=run_process):
    if not approved:raise ValueError('Review .blend and script before --approve-local-blender')
    source=inside(root,relative);script=root/'tools/agentic/blender_audit.py'
    if source.suffix.lower()!='.blend' or not source.is_file() or digest(source)!=expected_sha:
        raise ValueError('Blender source/hash mismatch')
    out=root/'build/agentic/blender'/uuid.uuid4().hex;report=out/'audit.json'
    result=invoke(command(executable,source,script,collection,report),'',root,out,600,lambda:None)
    if result['exitCode']!=0 or not report.is_file():raise ValueError('Blender audit failed or emitted no report')
    result=read_json(report)
    if result.get('status')!='LOCAL_GEOMETRY_CHECKS_PASS':raise ValueError('Blender geometry report did not pass')
    result['sourceSha256']=expected_sha;result['auditScriptSha256']=digest(script)
    result['studioTested']=False;result['clothingFitAccepted']=False
    save_json(out/'result.json',result)
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',required=True);p.add_argument('--source-sha256',required=True)
    p.add_argument('--collection',required=True);p.add_argument('--blender',default='blender')
    p.add_argument('--approve-local-blender',action='store_true');a=p.parse_args()
    executable=shutil.which(a.blender)
    if not executable:raise ValueError('Blender unavailable; no geometry or Studio test performed')
    r=audit(ROOT,executable,a.source,a.source_sha256,a.collection,approved=a.approve_local_blender)
    print(r['status'],'Studio/clothing/deformation gates remain pending')


if __name__=='__main__':
    try:main()
    except (OSError,ValueError,KeyError,TypeError,subprocess.SubprocessError) as exc:
        print(f'Blender job blocked: {exc}',file=sys.stderr);sys.exit(1)
