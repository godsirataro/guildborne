"""Embed the second route without activating it or changing the west block."""
from pathlib import Path
import json
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
def lua(v):
 if isinstance(v,dict):return '{'+','.join('['+json.dumps(k)+']='+lua(x) for k,x in v.items())+'}'
 if isinstance(v,list):return '{'+','.join(lua(x) for x in v)+'}'
 if isinstance(v,str):return json.dumps(v)
 if isinstance(v,bool):return 'true' if v else 'false'
 return format(v,'.15g')
p=ROOT/'src/shared/Config/WorldQuality.luau';s=p.read_text(encoding='utf-8')
a='-- BEGIN GENERATED GREENWOOD IRONVEIL CORRIDOR';b='-- END GENERATED GREENWOOD IRONVEIL CORRIDOR'
if a in s:s=s[:s.index(a)]+s[s.index(b)+len(b)+1:]
spec=json.loads((HERE/'runtime-descriptor.json').read_bytes())
assert spec['id']=='greenwood_ironveil_south'
s=s.replace('return table.freeze(Quality)',a+'\nQuality.GreenwoodIronveilCorridor='+lua(spec)+'\n'+b+'\nreturn table.freeze(Quality)')
p.write_bytes(s.encode())
print('EMBEDDED_NOT_ACTIVATED',len(spec['parts']),len(spec['centerline']))
