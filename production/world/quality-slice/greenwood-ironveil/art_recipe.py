"""Bounded original retaining skirt and unchanged reviewed local props. No upload."""
from pathlib import Path
import json, math, hashlib
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
OUT=ROOT/'assets/production/world-slice/greenwood-ironveil'
SOURCE=ROOT/'assets/production/world-slice/world-slice.mesh.json'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(name,value): (OUT/name).write_text(json.dumps(value,indent=2)+'\n',encoding='utf-8')
def main():
    source=json.loads(SOURCE.read_text());ground=json.loads((HERE/'ground.json').read_text())
    ids=['bush__000','silhouette_fern_rocks__000','silhouette_ruined_waymarker__000','fence__000','cart__000','cart__001']
    meshes=[m for m in source['meshes'] if m['id'] in ids];assert len(meshes)==len(ids)
    placements=[]
    # Small asymmetrical clusters. Exact full footprints tested against shoulder polygons.
    specs=[('bush__000',132,1523,0.42,.2),('silhouette_fern_rocks__000',138,1523.1,.35,.3),
      ('silhouette_ruined_waymarker__000',157,1493,.7,-.2),('bush__000',164,1493,.38,1.0),
      ('silhouette_fern_rocks__000',207,1494.5,.36,.1),('bush__000',212,1494.5,.4,.7),
      ('silhouette_fern_rocks__000',270,1525.0,.38,-.4),
      ('fence__000',246,1494.2,.85,0),('fence__000',260,1494.2,.85,0),
      ('cart__000',317,1523.2,.5,math.pi/2),('cart__001',317,1523.2,.5,math.pi/2),
      ('silhouette_fern_rocks__000',350,1489.6,.4,.1),('silhouette_ruined_waymarker__000',365,1518.2,.75,-.2)]
    for i,(mid,x,z,scale,yaw) in enumerate(specs):
        # Preserve east props relative to the surveyed final approach centerline.
        if x>300:
            z+=(ground['walkCenterline'][-1][2]-1500)*(x-300)/90
        c,s=math.cos(yaw),math.sin(yaw)
        placements.append(dict(name=f'GI_Scenery_{i:03d}',meshId=mid,cframe=[x,1.9,z,c,0,s,0,1,0,-s,0,c],scale=[scale]*3,collision=False,query=False,touch=False))
    # Solid stone retaining body, top deliberately below the native shoulders.
    sections=ground['crosssections'];rings=[]
    for x in [110,145,180,220,260,300,330,360,380]:
        for a,b in zip(sections,sections[1:]):
            if a['center'][0]<=x<=b['center'][0]:
                t=(x-a['center'][0])/(b['center'][0]-a['center'][0]);edges=[[a['shoulder'][j][k]+t*(b['shoulder'][j][k]-a['shoulder'][j][k]) for k in range(3)] for j in (0,1)]
                rings.append([[edges[0][0],1.85,edges[0][2]],[edges[1][0],1.85,edges[1][2]],[edges[1][0],.8,edges[1][2]],[edges[0][0],.8,edges[0][2]]]);break
    mesh=dict(id='gi_original_retaining_skirt',vertices=sum(rings,[]),triangles=[],colors=[[.36,.37,.31],[.43,.43,.39],[.31,.33,.29]],faceColors=[])
    def quad(q,color):
        mesh['triangles'].extend([[q[0]+1,q[1]+1,q[2]+1],[q[0]+1,q[2]+1,q[3]+1]]);mesh['faceColors'].extend([color,color])
    for i in range(len(rings)-1):
        for j in range(4):quad([4*i+j,4*(i+1)+j,4*(i+1)+(j+1)%4,4*i+(j+1)%4],1 if i<3 else 2+(j%2))
    quad([3,2,1,0],1);q=4*(len(rings)-1);quad([q,q+1,q+2,q+3],2)
    def signed_volume():
        out=0
        for tri in mesh['triangles']:
            a,b,c=[mesh['vertices'][j-1] for j in tri];out+=a[0]*(b[1]*c[2]-b[2]*c[1])+a[1]*(b[2]*c[0]-b[0]*c[2])+a[2]*(b[0]*c[1]-b[1]*c[0])
        return out/6
    if signed_volume()<0:mesh['triangles']=[list(reversed(t)) for t in mesh['triangles']]
    mesh['bounds']={key:[fn(v[k] for v in mesh['vertices']) for k in range(3)] for key,fn in [('min',min),('max',max)]}
    meshes.append(mesh);placements.append(dict(name='GI_RetainingSkirt',meshId=mesh['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    # Bounded structural visual treatment. Open arches and timber rails articulate
    # a deliberate bridge; these noncolliding parts are not engineering/footing proof.
    from structure_recipe import make_structures
    structural,solids=make_structures(ground)
    for item in structural:
        meshes.append(item);placements.append(dict(name=item['id'],meshId=item['id'],cframe=[0,0,0,1,0,0,0,1,0,0,0,1],scale=[1,1,1],collision=False,query=False,touch=False))
    packet=dict(schemaVersion=1,coordinateSystem='RobloxYUp',units='studs',meshes=meshes,placements=placements,runtimeImported=False,runtimeIds=None,compositionOnly=True)
    OUT.mkdir(parents=True,exist_ok=True);(OUT/'.gitattributes').write_text('* -text whitespace=cr-at-eol,-blank-at-eof\n')
    write('scenery.mesh.json',packet)
    write('structural-solids.json',solids)
    write('provenance.json',dict(status='FILE_GENERATED_NOT_IMPORTED',source=SOURCE.relative_to(ROOT).as_posix(),sourceSha256=digest(SOURCE),unchangedReviewedMeshes=ids,originalRecipe=Path(__file__).relative_to(ROOT).as_posix(),originalMeshes=['gi_original_retaining_skirt']+[m['id'] for m in structural],structuralRecipe='production/world/quality-slice/greenwood-ironveil/structure_recipe.py',structuralAcceptance='Decorative bridge treatment only; piers in schematic void are not terrain-footing proof',originalBounds=mesh['bounds'],retainingSkirtSignedVolume=signed_volume(),groundSha256=digest(HERE/'ground.json'),licenses=['assets/production/world-slice/village-LICENSE.txt','assets/production/world-slice/ruins-LICENSE.txt'],runtimeIds=None,studioTested=False,humanApproved=False))
    write('metrics.json',dict(resources=len(meshes),placements=len(placements),uniqueTriangles=sum(len(m['triangles']) for m in meshes),instancedTriangles=sum(len(next(m for m in meshes if m['id']==p['meshId'])['triangles']) for p in placements),originalSkirtTriangles=len(mesh['triangles']),structuralTriangles=sum(len(m['triangles']) for m in structural),structuralBounds={m['id']:m['bounds'] for m in structural},decorativeRailDisclaimer='Noncolliding rails do not prevent falls; below-deck piers do not prove terrain footings',roadParts=len(ground['parts']),roadColliders=sum(p['collision'] for p in ground['parts'])))
if __name__=='__main__':main()
