import pathlib,json,hashlib,zipfile,shutil,collections,datetime
root=pathlib.Path(r'C:/Users/godsi/Downloads/Guildborne-Catalog-94')
cat=json.loads(pathlib.Path('production/research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.json').read_text(encoding='utf-8'))['catalog']
store={r['id']:r for r in json.loads((root/'receipts.json').read_text(encoding='utf-8'))}
external={r['title']:r for name in ['kenney-manifest.json','cinderlore-manifest.json'] for r in json.loads((root/name).read_text(encoding='utf-8'))}
agent={r['number']:r for r in json.loads((root/'external-agent/manifest.json').read_text(encoding='utf-8'))}
source=pathlib.Path(r'C:/Users/godsi/Downloads/Medieval Village Pack - Dec 2020-20261015T181905Z-1-001.zip');dest=root/source.name
if not dest.exists():shutil.copy2(source,dest)
with zipfile.ZipFile(dest) as z:
 assert z.testzip() is None
 village={'status':'DOWNLOADED','files':[{'path':str(dest),'bytes':dest.stat().st_size,'sha256':hashlib.sha256(dest.read_bytes()).hexdigest(),'archiveEntries':len(z.namelist())}]}
rows=[]
for n,c in enumerate(cat,1):
 row={'number':n,'title':c['title'],'sourceUrls':c['urls'],'runtimeImported':False,'studioTested':False}
 if c.get('candidateStoreAssetId'):
  r=store[str(c['candidateStoreAssetId'])];assert r['status'] in ['acquired','owned','already-owned'];row.update(status='IN_ROBLOX_INVENTORY',storeAssetId=c['candidateStoreAssetId'],account='iswhlaedev',receiptFile='receipts.json')
 elif c['title'] in external:
  r=external[c['title']];row.update(status='DOWNLOADED',files=[{'path':r['path'],'sha256':r['sha256'],'bytes':r['bytes']}],license=r.get('license',r.get('redistribution','See source manifest')))
 elif n==43:row.update(village)
 elif n in [87,88]:row.update(status='BUILT_IN_NO_ACQUISITION_REQUIRED',evidence=agent[n])
 elif n in range(44,51):row.update(status='DOWNLOAD_NOT_VERIFIED',downloadRoutes=agent[n]['downloadRoutes'],reason='Folder download attempted in Chrome; local completed archive not observed. RPG showed Chrome blocked frame; ruins temporary download remained incomplete.')
 else:
  r=agent[n];row.update(status='DOWNLOADED' if r.get('files') else r['status'],files=r.get('files',[]),evidence=r)
 rows.append(row)
counts=collections.Counter(r['status'] for r in rows)
(root/'ACQUISITION_MANIFEST.json').write_text(json.dumps({'date':'2026-10-16','timezone':'Asia/Bangkok','scope':'Acquire catalog options only; no software installation, runtime import, publication or paid purchases','counts':counts,'catalog':rows},ensure_ascii=False,indent=2),encoding='utf-8')
lines=['# Guildborne — ผลการรับคลัง Research 94 ตัวเลือก','', 'วันที่ 16 ตุลาคม 2026 (Asia/Bangkok)','', '**ยืนยันสำเร็จ 87/94 รายการ — อีก 7 รายการยังดาวน์โหลดไม่สำเร็จ**','', '- Creator Store: ยืนยันว่าอยู่ใน Inventory บัญชี iswhlaedev ครบ 53 รายการ','- ดาวน์โหลดแพ็ก/ซอร์ส/ไฟล์อ้างอิงภายนอกแล้ว 32 รายการ','- เครื่องมือที่มีใน Studio อยู่แล้ว 2 รายการ ไม่ต้องกดรับ','- Quaternius ผ่าน Google Drive อีก 7 รายการ: กดดาวน์โหลดแล้ว แต่ยังไม่มีไฟล์สมบูรณ์ให้ตรวจรับ','', 'การรับเข้า Inventory/ดาวน์โหลด ไม่ใช่การติดตั้ง นำเข้าเกม หรือผ่าน Studio UAT และไม่มีการซื้อ/บริจาค/เผยแพร่เกม','', 'Cinderlore: ใช้ภายในโปรเจกต์ Roblox ได้ตาม license ที่บันทึกไว้ ห้ามแจกไฟล์แอนิเมชันแยกหรือใส่ public asset repository','', '## รายการครบ 94','', '| # | รายการ | ผล |','|---|---|---|']
labels={'IN_ROBLOX_INVENTORY':'อยู่ใน Roblox Inventory','DOWNLOADED':'ดาวน์โหลดแล้ว','BUILT_IN_NO_ACQUISITION_REQUIRED':'เครื่องมือใน Studio ไม่ต้องรับเพิ่ม','DOWNLOAD_NOT_VERIFIED':'ค้าง — ยังไม่มีไฟล์ดาวน์โหลดสมบูรณ์'}
for r in rows:lines.append(f"| {r['number']} | [{r['title'].replace('|','/').replace('[','').replace(']','')}]({r['sourceUrls'][0]}) | {labels.get(r['status'],r['status'])} |")
lines+=['','## หลักฐานและไฟล์','', '- `ACQUISITION_MANIFEST.json`: ผลครบ 94 รายการ พร้อมที่มาและตำแหน่งไฟล์','- `receipts.json`: ผลข้อความยืนยัน Inventory จากหน้า Creator Store','- `kenney-manifest.json`, `cinderlore-manifest.json`, `external-agent/manifest.json`: ที่มา license และ SHA256 ของไฟล์','- `archive-validation.json`: ตรวจ ZIP Kenney 16 ไฟล์ ไม่พบไฟล์เสีย','- `store-proof.png`: ภาพตัวอย่างยืนยัน Inventory','- `drive-rpg-download-blocker.png`: ภาพหน้าดาวน์โหลดที่ค้าง','', 'ไฟล์ดาวน์โหลดทั้งหมดเก็บในโฟลเดอร์นี้และ `external-agent` ไม่ได้เพิ่มแพ็กบุคคลที่สามลง Git repository','', '## รายการค้าง','']
for r in rows:
 if r['status']=='DOWNLOAD_NOT_VERIFIED':lines.append(f"- {r['number']}. [{r['title']}]({r['downloadRoutes'][0]})")
(root/'ACQUISITION_REPORT_TH.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print(dict(counts))
