"""Independent physical Part reconstruction, exact rectangle union and seam checks."""
import hashlib,json,pathlib,subprocess
HERE=pathlib.Path(__file__).resolve().parent;ROOT=HERE.parents[3];BASE='efac81c'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def load(n):return json.loads((HERE/n).read_bytes())
def main():
    ground=load('ground.json');spec=load('runtime-descriptor.json');survey=load('source-survey.json')
    for n,h in survey['sourceHashes'].items():assert sha(ROOT/n)==h,('source drift',n)
    assert spec['id']=='ironveil_ashen_south' and spec['fromZone']=='Ironveil' and spec['toZone']=='Ashen'
    rects=[];names=set();tops=[]
    assert len(ground['parts'])==len(spec['parts'])==spec['colliderCount']==6
    for a,b in zip(ground['parts'],spec['parts']):
        assert a['name']==b['name'] and a['name'] not in names;names.add(a['name'])
        assert a['className']==b['kind']=='Part' and a['rotation']==[1,0,0,0,1,0,0,0,1]
        assert a['position']+a['rotation']==b['cframe'] and a['size']==b['size'] and a['color']==b['color']
        assert a['collision'] is b['collision'] is True and a['query'] is True and a['touch'] is False and a['anchored'] is True
        x,y,z=a['position'];sx,sy,sz=a['size'];assert min(sx,sy,sz)>0 and abs(y+sy/2-2.1)<1e-9
        rects.append((x-sx/2,x+sx/2,z-sz/2,z+sz/2));tops.append(y+sy/2)
    expected=[(596,624,1493,1519),(624,650,1493,1517),(650,750,1493,1517),(750,850,1493,1517),(850,886,1493,1517),(886,914,1493,1519)]
    assert sorted(rects)==sorted(expected)
    xs=sorted({596,914,*[v for r in rects for v in r[:2]]});zs=sorted({1493,1517,1519,*[v for r in rects for v in r[2:]]})
    cells=0
    for x0,x1 in zip(xs,xs[1:]):
        for z0,z1 in zip(zs,zs[1:]):
            x=(x0+x1)/2;z=(z0+z1)/2;required=z<=1517 or x<=624 or x>=886
            if required:assert any(a<=x<=b and c<=z<=d for a,b,c,d in rects),('uncovered_cell',x,z);cells+=1
    def supported(x,z):return any(a-1e-8<=x<=b+1e-8 and c-1e-8<=z<=d+1e-8 for a,b,c,d in rects)
    probes=[]
    for x in xs+[610,900]:
        for dx in (-.01,-.001,0,.001,.01):
            if not 596<=x+dx<=914:continue
            for z in (1493,1493.001,1505,1516.999,1517):assert supported(x+dx,z);probes.append([x+dx,z])
    assert min(r[2] for r in rects)-1490==3
    assert spec['safeRecovery']=={'Ironveil':[600,7,1500],'Ashen':[900,7,1500]}
    native={'Ironveil':(380,620,1290,1510),'Ashen':(890,1110,1290,1510)}
    for zone,(x,y,z) in spec['safeRecovery'].items():
        a,b,c,d=native[zone];assert a<x<b and c<z<d and supported(x,z) and 0<y<35
    def bbox(v):
        f=v['cframe'];sz=v['size'];assert f[3:]==[1,0,0,0,1,0,0,0,1]
        return [f[i]-sz[i]/2 for i in range(3)],[f[i]+sz[i]/2 for i in range(3)]
    for zone in ('Ironveil','Ashen'):
        lo,hi=bbox(spec['entries'][zone]);assert all(supported(x,z) for x in (lo[0],hi[0]) for z in (lo[2],hi[2]))
    old=json.loads((ROOT/'production/world/quality-slice/greenwood-ironveil/runtime-descriptor.json').read_bytes())
    a,b=bbox(old['entries']['Ironveil']);c,d=bbox(spec['entries']['Ironveil']);assert b[0]<c[0]
    # All transit volumes' entire horizontal footprints fit colliding ground.
    for v in spec['volumes']:
        lo,hi=bbox(v)
        for x in (lo[0],hi[0]):
            for z in (lo[2],hi[2]):assert supported(x,z),('volume_over_void',lo,hi)
    retained={}
    for n in subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'assets/production/world-slice'],cwd=ROOT).decode().splitlines():
        if n.endswith('.mesh.json'):
            raw=subprocess.check_output(['git','show',BASE+':'+n],cwd=ROOT);assert raw==(ROOT/n).read_bytes(),('existing_packet_changed',n);retained[n]=hashlib.sha256(raw).hexdigest()
    assert len(retained)==29
    report={'status':'PASS_OFFLINE_PHYSICAL_GEOMETRY','inputHashes':{n:sha(HERE/n) for n in ('ground.json','runtime-descriptor.json','source-survey.json')},'collidingParts':6,'exactUnionCells':cells,'seamProbeCount':len(probes),'combatBoundaryMargin':3,'oldNewIronveilEntryXGap':c[0]-b[0],'retainedOldPacketHashes':retained,'limitations':['Reconstructed source geometry only; no native rays, five companions or device/performance acceptance.','Pad collision supplies support beyond native island bounds; native streaming and scenery integration remain separate.']}
    out=HERE/'independent-ground.json';assert not out.exists();out.write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report))
if __name__=='__main__':main()
