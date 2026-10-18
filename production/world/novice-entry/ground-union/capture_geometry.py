"""Evaluate the actual factory in standalone Luau using a deliberately limited geometry adapter.

This provides source geometry evidence, never Studio/pathfinding/physics acceptance.
"""
import argparse, json, subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
TAIL = r'''
local model=factory()
print("MODEL|"..model.ModelStreamingMode)
for _,p in ipairs(model:GetChildren())do if p:IsA("BasePart")then
 local fields={p.Name,p.ClassName,p:GetAttribute("Stage") or "",tostring(p:GetAttribute("RouteDestination")==true),p.Shape,p.Material,tostring(p.Transparency),tostring(p.CanCollide),tostring(p.CanQuery),tostring(p.CanTouch),tostring(p.Anchored)}
 for _,n in ipairs({p.Position.X,p.Position.Y,p.Position.Z,p.Size.X,p.Size.Y,p.Size.Z,p.Color.R,p.Color.G,p.Color.B})do table.insert(fields,tostring(n))end
 for _,n in ipairs(p.CFrame.r)do table.insert(fields,tostring(n))end
 table.insert(fields,tostring(p.CastShadow))
 print(table.concat(fields,"|"))
end end
'''

def capture(source, output, luau):
    wrapper = output.with_suffix('.capture.luau')
    wrapper.write_bytes((HERE.joinpath('capture_prelude.luau').read_text()+'\nlocal factory=(function()\n'+source+'\nend)()\n'+TAIL).encode())
    result = subprocess.run([str(luau), str(wrapper)], capture_output=True)
    output.with_suffix('.stdout.txt').write_bytes(result.stdout)
    output.with_suffix('.stderr.txt').write_bytes(result.stderr)
    if result.returncode:
        raise RuntimeError(result.stderr.decode(errors='replace'))
    lines = result.stdout.decode().splitlines()
    assert lines[0].startswith('MODEL|'), lines[:1]
    parts=[]
    for line in lines[1:]:
        f=line.split('|'); assert len(f)==30, f
        parts.append(dict(castShadow=f[29]=='true',name=f[0],className=f[1],stage=f[2],marker=f[3]=='true',shape=f[4].split('.')[-1],material=f[5].split('.')[-1],transparency=float(f[6]),collision=f[7]=='true',query=f[8]=='true',touch=f[9]=='true',anchored=f[10]=='true',position=list(map(float,f[11:14])),size=list(map(float,f[14:17])),color=list(map(float,f[17:20])),rotation=list(map(float,f[20:29]))))
    payload=dict(evidence='OFFLINE_SOURCE_GEOMETRY_NOT_STUDIO',streaming=lines[0].split('|')[1],parts=parts)
    output.write_bytes((json.dumps(payload,indent=2)+'\n').encode())
    wrapper.unlink()
    print(output.name,len(parts),'parts',sum(p['collision'] for p in parts),'colliders')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--source',type=Path);parser.add_argument('--git-ref');parser.add_argument('--output',type=Path,required=True);parser.add_argument('--luau',type=Path,default=Path('C:/Work/MySelf/Guildborne/.tools/luau/luau.exe'));args=parser.parse_args()
    if args.git_ref:
        source=subprocess.check_output(['git','show',args.git_ref+':review/NoviceRoadKit.luau'],cwd=ROOT).decode()
    else: source=args.source.read_text(encoding='utf-8')
    capture(source,args.output,args.luau)
