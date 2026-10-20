import urllib.request,urllib.parse,re,json,pathlib,hashlib,concurrent.futures,datetime
root=pathlib.Path('C:/Users/godsi/Downloads/Guildborne-Catalog-94/external-agent')
cat=json.loads(pathlib.Path('production/research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.json').read_text(encoding="utf-8"))['catalog']
rows=[]
def get(u): return urllib.request.urlopen(urllib.request.Request(u,headers={'User-Agent':'Guildborne-source-intake'}),timeout=55).read()
def process(n):
 c=cat[n-1]; row={'number':n,'title':c['title'],'sourceUrls':c['urls'],'licenseEvidence':c['sourceEvidence'][0]['payload'].get('rightsEvidence',c['sourceEvidence'][0]['payload'].get('license')),'files':[],'installed':False,'runtimeImported':False}; d=root/str(n);d.mkdir(exist_ok=True)
 try:
  u=c['urls'][0]; raw=get(u);(d/'source.html').write_bytes(raw);t=raw.decode();urls=[]
  if n in [87,88]:row['status']='BUILT_IN_NO_DOWNLOAD_REQUIRED'
  elif n in [82,83,89]:
   repo=u.removeprefix('https://github.com/');meta=json.loads(get('https://api.github.com/repos/'+repo+'/commits?per_page=1'));sha=meta[0]['sha'];row['revision']=sha;urls=['https://codeload.github.com/'+repo+'/zip/'+sha]
  elif n in [90,91]:urls=[re.findall(r'https://files2.makehumancommunity.org/[^"<> ]+\.zip',t)[0]]
  elif n in [84,85,86]:
   links=re.findall(r'href=["\x27]([^"\x27]+)',t)
   keys={84:['Rig_and_Attachments','Clothing_Cage','Body_Cage','Combined_Templates'],85:['RoundMale.zip','RoundFemale.zip','SquareMale.zip','SquareFemale.zip','MuzzleMale.zip','MuzzleFemale.zip','GoblinCharacter.zip'],86:['Tshirt-model.fbx','Additional-FBX-assets.zip']}[n]
   urls=list(dict.fromkeys(x for x in links if any(k in x for k in keys)))
  else:
   row['downloadRoutes']=list(dict.fromkeys(re.findall(r'https://(?:drive.google.com|quaternius.itch.io)[^\s\"\x27<>]+',t)));row['status']='ROUTE_INSPECTION_PENDING'
  for i,link in enumerate(urls):
   name=urllib.parse.urlparse(link).path.split('/')[-1];name=name if '.' in name else name+'.zip'
   data=get(link);p=d/name;p.write_bytes(data);row['files'].append({'path':str(p),'url':link,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
  if urls:row['status']='DOWNLOADED_NOT_INSTALLED_OR_IMPORTED'
 except Exception as e:row['status']='BLOCKED_HTTP';row['error']=str(e)
 return row
with concurrent.futures.ThreadPoolExecutor(max_workers=5) as ex:
 for r in ex.map(process,list(range(43,51))+list(range(82,95))):rows.append(r);print(r['number'],r['status'],len(r['files']),flush=True);(root/'manifest.json').write_text(json.dumps(rows,indent=2))

