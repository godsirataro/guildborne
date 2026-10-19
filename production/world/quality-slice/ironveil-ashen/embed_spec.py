"""Embed only the new third route; preserve prior generated blocks byte-for-byte."""
from pathlib import Path
import json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def lua(v):
    if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x) for k,x in v.items())+'}'
    if isinstance(v,list):return '{'+','.join(lua(x) for x in v)+'}'
    if isinstance(v,str):return json.dumps(v)
    if isinstance(v,bool):return 'true' if v else 'false'
    return format(v,'.15g')
p=ROOT/'src/shared/Config/WorldQuality.luau';s=p.read_bytes()
a=b'-- BEGIN GENERATED IRONVEIL ASHEN CORRIDOR';b=b'-- END GENERATED IRONVEIL ASHEN CORRIDOR'
if a in s:s=s[:s.index(a)]+s[s.index(b)+len(b):].lstrip(b'\r\n')
spec=json.loads((HERE/'runtime-descriptor.json').read_bytes());assert spec['id']=='ironveil_ashen_south'
block=a+b'\nQuality.IronveilAshenCorridor='+lua(spec).encode()+b'\n'+b+b'\n'
s=s.replace(b'return table.freeze(Quality)',block+b'return table.freeze(Quality)');p.write_bytes(s)
print('EMBEDDED_NOT_ACTIVATED')
