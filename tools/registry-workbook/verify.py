"""Read-only exported workbook audit; authoring remains in artifact-tool build.mjs."""
from pathlib import Path
from zipfile import ZipFile
import xml.etree.ElementTree as ET
import hashlib,json
root=Path(__file__).resolve().parents[2]
out=root/'outputs/01a0f39c-43bd-7a81-917f-8a8cd02c0ddf'
ns={'s':'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}
with ZipFile(out/'Guildborne_Production_Registry.xlsx') as z:
 sheets=ET.fromstring(z.read('xl/workbook.xml')).findall('s:sheets/s:sheet',ns)
 assert [s.get('name') for s in sheets]==['Summary','Worklist','Assets','Screens']
 formula_count=0
 for name in z.namelist():
  if name.startswith('xl/worksheets/sheet') and name.endswith('.xml'):
   xml=ET.fromstring(z.read(name))
   assert not [c for c in xml.findall('.//s:c',ns) if c.get('t')=='e'],f'Formula error in {name}'
   formula_count+=len(xml.findall('.//s:f',ns))
 registry=json.loads((root/'docs/uat01/intake/registry-reconciled.json').read_text(encoding='utf-8'))
 assert formula_count==len(registry['summary']['assetStatuses'])+5,formula_count
 strings=[]
 if 'xl/sharedStrings.xml' in z.namelist():
  strings=[''.join(si.itertext()) for si in ET.fromstring(z.read('xl/sharedStrings.xml'))]
 def value(c):
  v=c.find('s:v',ns)
  if c.get('t')=='s':return strings[int(v.text)]
  if c.get('t')=='inlineStr':return ''.join(c.find('s:is',ns).itertext())
  return v.text if v is not None else ''
 for index,records,key in [(3,registry['assets'],'designId'),(4,registry['screens'],'designId')]:
  xml=ET.fromstring(z.read(f'xl/worksheets/sheet{index}.xml'))
  ids=[value(c) for c in xml.findall('.//s:c',ns) if c.get('r','').startswith('A') and c.get('r','')[1:].isdigit() and int(c.get('r')[1:])>=6 and value(c)]
  assert ids==[r[key] for r in records],f'Exported row identity/order mismatch: sheet{index}'
 expected={'AssetRegistry':f"A5:H{len(registry['assets'])+5}",'ScreenRegistry':f"A5:H{len(registry['screens'])+5}",'DeliveryWorklist':'A5:D38'}
 found={}
 for name in z.namelist():
  if name.startswith('xl/tables/table') and name.endswith('.xml'):
   table=ET.fromstring(z.read(name));found[table.get('name')]=table.get('ref')
 assert found==expected,found
src=json.loads((root/'docs/uat01/intake/registry-source.json').read_text(encoding='utf-8'))
original=Path(src['source']);unchanged=hashlib.sha256(original.read_bytes()).hexdigest()==src['sha256']
assert unchanged,'Original attachment changed'
result={'sheets':4,'assetRecords':len(registry['assets']),'screenRecords':len(registry['screens']),'workAreas':33,'formulaCells':formula_count,'formulaErrors':0,'originalWorkbookUnchanged':unchanged,'authoringEngine':'@oai/artifact-tool','inputResponseVerifiedByBuilder':True}
(out/'validation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result))
