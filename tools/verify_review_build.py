"""Check the standalone review artifact cannot accidentally include main-game persistence."""
from pathlib import Path
import xml.etree.ElementTree as ET,json,hashlib
ROOT=Path(__file__).resolve().parents[1];p=ROOT/'build/Guildborne_ArtReview.rbxlx';tree=ET.parse(p)
scripts=[];sources=[]
for item in tree.iter('Item'):
    if item.attrib.get('class') in ('Script','LocalScript','ModuleScript'):
        props=item.find('Properties');name=next((x.text for x in props if x.attrib.get('name')=='Name'),'')
        source=next((x.text or '' for x in props if x.attrib.get('name')=='Source'),'');sources.append(source)
        scripts.append(dict(name=name,kind=item.attrib['class']))
assert sum(s['kind']=='Script' for s in scripts)==1
assert sum(s['kind']=='ModuleScript' for s in scripts)==21
assert {'AdventureNavigation','AdventureLocomotion','CityLandmarkKit','CityDistrictKit','NoviceRoadKit','CityCharacterKit'} <= {s['name'] for s in scripts}
assert not any(s['name'] in ['ServerBootstrap','ClientBootstrap','PlayerDataService','RobloxStore','MarketService'] for s in scripts)
for source in sources:
    for forbidden in ['DataStoreService','MarketplaceService','ProcessReceipt','GetDataStore','LoadProfile']:
        assert forbidden not in source,forbidden
assert not any(x.attrib.get('class') in ('RemoteEvent','RemoteFunction') for x in tree.iter('Item'))
report=dict(file=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),scripts=scripts,persistenceApis=False,commerceApis=False,remoteEndpoints=False,fullStandalonePlayAcceptance=False)
(ROOT/'docs/uat01/validation-review-build.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print('REVIEW_BUILD_BOUNDARIES_PASS',len(scripts),'scripts/modules',p.stat().st_size,'bytes')
