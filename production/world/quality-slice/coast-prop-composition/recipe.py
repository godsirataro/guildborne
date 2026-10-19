"""Six translations only; footprint-wide terrain extrema determine buried bases."""
from pathlib import Path
import json,hashlib,copy
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/coast-prop-composition'
SOURCE=ROOT/'assets/production/world-slice/bespoke-spire/scenery.mesh.json'
EXPECTED='148ba821817101a0372d851f557d4c7593a594295814f0e20da194924adfb3ae'
MOVES={'CorridorScenery_010':[-289,-168],'CorridorScenery_009':[-302,-184],'CorridorScenery_007':[-294,-178],'CorridorScenery_044':[-360,155],'CorridorScenery_015':[-370,169],'CorridorScenery_013':[-357,179]}
def world(v,p):
 f=p['cframe'];s=p['scale'];return [f[i]+sum(f[3+3*i+j]*v[j]*s[j] for j in range(3)) for i in range(3)]
def clip(poly,axis,edge,sign):
 result=[]
 for p,q in zip(poly,poly[1:]+poly[:1]):
  dp,dq=sign*(p[axis]-edge),sign*(q[axis]-edge)
  if dp>=0:result.append(p)
  if (dp>=0)!=(dq>=0):
   t=dp/(dp-dq);result.append([p[i]+t*(q[i]-p[i]) for i in range(3)])
 return result
def main():
 assert hashlib.sha256(SOURCE.read_bytes()).hexdigest()==EXPECTED
 packet=json.loads(SOURCE.read_bytes());before=copy.deepcopy(packet);meshes={m['id']:m for m in packet['meshes']}
 terrain=[]
 for p in packet['placements']:
  if p['meshId'].startswith(('landforms_west','landforms_east','coast_headland')):
   m=meshes[p['meshId']];vv=[world(v,p) for v in m['vertices']]
   terrain.extend([[vv[i-1] for i in t] for t in m['triangles']])
 ground=json.loads((ROOT/'production/world/quality-slice/continuous-corridor/ground.json').read_bytes())
 terrain.extend(t['vertices'] for t in ground['topTriangles'])
 evidence=[]
 for p in packet['placements']:
  if p['name'] not in MOVES:continue
  previous=copy.deepcopy(p);p['cframe'][0],p['cframe'][2]=MOVES[p['name']];p['cframe'][1]=0
  vv=[world(v,p) for v in meshes[p['meshId']]['vertices']]
  support=[world(v,p) for v in meshes[p['meshId']]['vertices'] if v[1]<1e-7] if p['meshId']=='tree_a__000' else vv
  bounds=[min(v[0] for v in support),max(v[0] for v in support),min(v[2] for v in support),max(v[2] for v in support)]
  clips=[]
  for t in terrain:
   poly=t
   for axis,edge,sign in [(0,bounds[0],1),(0,bounds[1],-1),(2,bounds[2],1),(2,bounds[3],-1)]:
    if poly:poly=clip(poly,axis,edge,sign)
   if len(poly)>=3:clips.append(poly)
  assert clips,p['name']
  low=min(v[1] for poly in clips for v in poly);high=max(v[1] for poly in clips for v in poly)
  # Tree uses structural trunk bottom vertices; other resources use full bounds. Basal
  # plane sits 0.12 below lowest supporting triangle across that footprint.
  p['cframe'][1]=low-min(v[1] for v in vv)-.12
  evidence.append(dict(name=p['name'],before=previous['cframe'][:3],after=p['cframe'][:3],footprintXZ=bounds,footprintMethod='basal trunk rectangle' if p['meshId']=='tree_a__000' else 'conservative full geometry rectangle',terrainMin=low,terrainMax=high,clippedTerrainPolygons=len(clips),basalPlane=low-.12,burialRange=[.12,high-low+.12]))
 assert packet['meshes']==before['meshes']
 for p,q in zip(packet['placements'],before['placements']):
  if p['name'] not in MOVES:assert p==q
  else:
   cp=copy.deepcopy(p);cp['cframe'][:3]=q['cframe'][:3];assert cp==q
 OUT.mkdir(parents=True,exist_ok=True)
 (OUT/'scenery.mesh.json').write_text(json.dumps(packet,separators=(',',':'))+'\n',encoding='utf-8')
 report=dict(status='GENERATED_NOT_STUDIO',sourceSha256=EXPECTED,translations=evidence,unchangedPlacements=66,original57Exact=51,meshesUnchanged=True,uniqueTriangles=sum(len(m['triangles']) for m in packet['meshes']),instanceTriangles=sum(len(meshes[p['meshId']]['triangles']) for p in packet['placements']),groundParts=len(ground['parts']),limitations='Footprint-wide basal-plane embedding; independent component support, clearance and sightline review required. Not native acceptance.')
 (OUT/'placement-recipe-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
 (OUT/'provenance.json').write_text(json.dumps(dict(origin='Existing reviewed Guildborne bespoke-spire packet, six translations only',license='Retains existing original Guildborne geometry and reviewed Quaternius CC0 vegetation',sourceProvenance='assets/production/world-slice/bespoke-spire/provenance.json',licenseFiles=['assets/production/world-slice/village-LICENSE.txt','assets/production/world-slice/ruins-LICENSE.txt'],source=SOURCE.relative_to(ROOT).as_posix(),sourceSha256=EXPECTED,recipe=Path(__file__).relative_to(ROOT).as_posix(),packetSha256=hashlib.sha256((OUT/'scenery.mesh.json').read_bytes()).hexdigest(),runtimeAssetIds=None,downloads=False,newMeshes=False),indent=2)+'\n')
 print(json.dumps(report,indent=2))
if __name__=='__main__':main()
