import pathlib,zipfile,hashlib,json,shutil,collections
root=pathlib.Path(r'C:/Users/godsi/Downloads/Guildborne-Catalog-94')
dl=root.parent
packs={43:'Medieval Village Pack - Dec 2020-20261015T181905Z-1-001.zip',44:'Ultimate Modular Ruins Pack - Aug 2021-20261015T191438Z-1-001.zip',45:'Medieval Weapons Pack by @Quaternius-20261015T191442Z-1-001.zip',46:'Ultimate RPG Items Pack - Aug 2019-20261015T191443Z-1-001.zip',47:'Ultimate Monsters-20261015T191447Z-1-001.zip',48:'Ultimate Animated Animals - July 2021-20261015T191450Z-1-001.zip',49:'Ultimate Food Pack - Oct 2019-20261015T191453Z-1-001.zip',50:'Nature Crops Pack - Jan 2020-20261015T191457Z-1-001.zip'}
duplicate='Nature Crops Pack - Jan 2020-20261015T191312Z-1-001.zip'
results=[]
for num,name in [*packs.items(),(50,duplicate)]:
 p=dl/name
 r={'number':num,'sourcePath':str(p),'name':name,'exists':p.is_file()}
 if p.is_file():
  r['bytes']=p.stat().st_size;r['sha256']=hashlib.file_digest(p.open('rb'),'sha256').hexdigest()
  with zipfile.ZipFile(p) as z:
   r['corruptEntry']=z.testzip(); members=[x for x in z.infolist() if not x.is_dir()]
   r['fileCount']=len(members);r['extensions']=dict(collections.Counter(pathlib.PurePosixPath(x.filename).suffix.lower() for x in members));r['licenseFiles']=[x.filename for x in members if 'license' in x.filename.lower()]
   r['contentIndex']=[{'name':x.filename,'bytes':x.file_size,'crc':x.CRC} for x in members]
   r['assetCount']=sum(pathlib.PurePosixPath(x.filename).suffix.lower() in ['.fbx','.obj','.blend','.gltf','.glb'] for x in members)
  assert r['corruptEntry'] is None and r['assetCount']>0,(name,r)
 results.append(r)
 print(num,name,r.get('fileCount'),r.get('assetCount'),'OK' if r.get('exists') and r.get('corruptEntry') is None else 'FAILED',flush=True)
assert all(x['exists'] for x in results)
a,b=[x for x in results if x['number']==50]
same_content=sorted(a['contentIndex'],key=lambda x:x['name'])==sorted(b['contentIndex'],key=lambda x:x['name'])
report={'date':'2026-10-16','archives':results,'cropsDuplicate':{'sameArchiveSHA256':a['sha256']==b['sha256'],'sameEntryNamesSizesCRC':same_content}}
(root/'quaternius-archive-validation.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
manifest=json.loads((root/'ACQUISITION_MANIFEST.json').read_text(encoding='utf-8'))
for r in results[:8]:
 src=pathlib.Path(r['sourcePath']);dest=root/src.name
 if not dest.exists():shutil.copy2(src,dest)
 assert hashlib.file_digest(dest.open('rb'),'sha256').hexdigest()==r['sha256']
 row=next(x for x in manifest['catalog'] if x['number']==r['number'])
 row.update(status='DOWNLOADED',files=[{'path':str(dest),'bytes':r['bytes'],'sha256':r['sha256'],'archiveEntries':r['fileCount'],'assetCount':r['assetCount']}],validationFile='quaternius-archive-validation.json')
 row.pop('reason',None)
manifest['counts']=dict(collections.Counter(x['status'] for x in manifest['catalog']))
(root/'ACQUISITION_MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
lines=['# Guildborne — ผลการรับคลัง Research 94 ตัวเลือก','','วันที่ 16 ตุลาคม 2026 (Asia/Bangkok)','','**ครบ 94/94 รายการในขั้นรับของ/ดาวน์โหลด**','','- Creator Store: อยู่ใน Inventory ครบ 53 รายการ','- แพ็ก/ซอร์ส/ไฟล์อ้างอิงภายนอก: ดาวน์โหลดแล้ว 39 รายการ','- เครื่องมือใน Studio: 2 รายการ ไม่ต้องรับเพิ่ม','- Quaternius จาก Drive: ตรวจ ZIP ครบ 8 แพ็ก มีไฟล์โมเดลจริง และตรวจ CRC ไม่พบไฟล์เสีย','- Nature Crops มี ZIP 2 ไฟล์; รายการภายใน ชื่อ ขนาด และ CRC ตรงกัน จึงนับเป็น 1 แพ็ก เก็บต้นฉบับทั้งคู่ไว้','','สถานะนี้ยืนยันการรับ/ดาวน์โหลด ยังไม่ได้ยืนยันติดตั้ง นำเข้าเกม หรือทดสอบใน Studio','','## รายการครบ 94','','| # | รายการ | ผล |','|---|---|---|']
labels={'IN_ROBLOX_INVENTORY':'อยู่ใน Roblox Inventory','DOWNLOADED':'ดาวน์โหลดแล้ว','BUILT_IN_NO_ACQUISITION_REQUIRED':'เครื่องมือใน Studio ไม่ต้องรับเพิ่ม'}
for r in manifest['catalog']:
 title=r['title'].replace('|','/').replace('[','').replace(']','');lines.append(f"| {r['number']} | [{title}]({r['sourceUrls'][0]}) | {labels[r['status']]} |")
lines+=['','## หลักฐาน','','- `ACQUISITION_MANIFEST.json`: ผลครบ 94 รายการ พร้อมพาธและ SHA256','- `quaternius-archive-validation.json`: ผลตรวจ ZIP 9 ไฟล์ที่ผู้ใช้ส่งมา (8 แพ็ก) และรายละเอียดรายการภายใน','- `receipts.json`: หลักฐานข้อความยืนยัน Roblox Inventory','- `archive-validation.json`: ผลตรวจ ZIP Kenney 16 ไฟล์','- `kenney-manifest.json`, `cinderlore-manifest.json`, `external-agent/manifest.json`: ที่มาและข้อมูล license; manifest ของงานย่อยเก็บสถานะเดิมในเวลานั้น ให้ใช้ ACQUISITION_MANIFEST.json เป็นยอดปัจจุบัน','','Cinderlore ใช้ในโปรเจกต์ Roblox ตาม license ที่เก็บไว้ ห้ามแจกไฟล์แอนิเมชันแยกหรือใส่ public asset repository','','ไฟล์อยู่ในโฟลเดอร์นี้และ external-agent ไม่มีการเพิ่ม third-party assets ลง Git หรือเผยแพร่เกม']
(root/'ACQUISITION_REPORT_TH.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('DUPLICATE',report['cropsDuplicate']);print('COUNTS',manifest['counts'])
