"""Hash-check and extract only reviewed world source assets; never execute archive content."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/production/world-slice'
CATALOG=Path('C:/Work/MySelf/Guildborne/docs/Guildborne-Catalog-94')
PACKS=[('village','Medieval Village*.zip','ba03a970b2d23cb9d7b85da36e65f1861812b15868e418f8c116c1c199e53221'),('ruins','Ultimate Modular Ruins*.zip','7e352d461b3730a85fd43076042cb130f0e72b922ae59d7d9feaf95345008347')]
ASSETS=[('stable','village','Buildings/FBX/Stable.fbx',30),('house','village','Buildings/FBX/House_2.fbx',32),('sawmill','village','Buildings/FBX/Sawmill.fbx',28),('cart','village','Props/FBX/Cart.fbx',7),('fence','village','Props/FBX/Fence.fbx',5),('barrel','village','Props/FBX/Barrel.fbx',3),('path','village','Props/FBX/Path_Straight.fbx',None),('arch','ruins','FBX/Arch_Round.fbx',25),('ruin_wall','ruins','FBX/Wall_ArchRound_Overgrown_Broken.fbx',16),('bridge','ruins','FBX/BridgeSection.fbx',None),('bridge_support','ruins','FBX/Column_BridgeSupport.fbx',12),('tree_a','ruins','FBX/Tree_1.fbx',30),('tree_b','ruins','FBX/Tree_3.fbx',38),('bush','ruins','FBX/Bush_Large.fbx',4),('stag','ruins','FBX/Statue_Stag.fbx',13)]
def main():
 OUT.mkdir(parents=True,exist_ok=True);records=[]
 for pack,pattern,expected in PACKS:
  paths=list(CATALOG.glob(pattern));assert len(paths)==1
  path=paths[0];assert hashlib.sha256(path.read_bytes()).hexdigest()==expected
  with zipfile.ZipFile(path) as z:
   license_name=next(n for n in z.namelist() if n.endswith('/License.txt'))
   license_bytes=z.read(license_name);assert b'CC0 1.0' in license_bytes
   (OUT/f'{pack}-LICENSE.txt').write_bytes(license_bytes)
   for asset_id,p,suffix,height in ASSETS:
    if p!=pack:continue
    members=[n for n in z.namelist() if n.endswith('/'+suffix)];assert len(members)==1
    member=members[0];raw=z.read(member)
    dest=OUT/'source'/f'{asset_id}.fbx';dest.parent.mkdir(exist_ok=True);dest.write_bytes(raw)
    records.append(dict(id=asset_id,pack=pack,member=member,archive=path.name,archiveSha256=expected,sourceSha256=hashlib.sha256(raw).hexdigest(),source=str(dest.relative_to(ROOT)).replace('\\','/'),height=height,license='CC0-1.0',runtimeId=None))
 (OUT/'intake.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
 print('Verified and extracted',len(records),'real FBX assets')
if __name__=='__main__':main()
