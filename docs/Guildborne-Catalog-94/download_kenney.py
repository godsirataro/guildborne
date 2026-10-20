import json,urllib.request,re,pathlib,hashlib
out=pathlib.Path(r'C:/Users/godsi/Downloads/Guildborne-Catalog-94')
cat=json.loads(pathlib.Path('production/research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.json').read_text(encoding='utf-8'))['catalog']
results=[]
for x in cat:
 u=next((u for u in x['urls'] if 'kenney.nl/assets/' in u),None)
 if not u: continue
 r={'title':x['title'],'source':u}
 try:
  html=urllib.request.urlopen(u,timeout=20).read().decode()
  urls=re.findall(r'https://kenney\.nl/[^\s\"\'<>]+\.zip',html)
  if not urls: raise ValueError('No public archive link in official page')
  url=urls[0]; dest=out/url.rsplit('/',1)[-1]
  if not dest.exists():
   with urllib.request.urlopen(url,timeout=30) as response: dest.write_bytes(response.read())
  r.update(status='downloaded',downloadUrl=url,path=str(dest),bytes=dest.stat().st_size,sha256=hashlib.sha256(dest.read_bytes()).hexdigest(),license='CC0' if 'CC0' in html else 'review-required')
 except Exception as e:r.update(status='blocked',reason=str(e))
 results.append(r)
 (out/'kenney-manifest.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
 print(r['title'],r['status'],flush=True)
