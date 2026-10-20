import urllib.request,urllib.parse,http.cookiejar,re,json,pathlib,hashlib
root=pathlib.Path('C:/Users/godsi/Downloads/Guildborne-Catalog-94/external-agent');out=[]
for n,slug in [(92,'universal-base-characters')]:
 try:
  u='https://quaternius.itch.io/'+slug;o=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()));t=o.open(u).read().decode();token=re.search(r'name="csrf_token" value="([^"]+)',t)[1];d=json.loads(o.open(urllib.request.Request(u+'/download_url',data=urllib.parse.urlencode({'csrf_token':token}).encode(),headers={'Referer':u})).read());t=o.open(d['url']).read().decode();uploads=re.findall(r'data-upload_id="(\d+)".*?<strong title="([^"]+)"',t)
  files=[]
  for uid,name in uploads:
   if 'standard' not in name.lower():continue
   token=re.search(r'name="csrf_token" value="([^"]+)',t)[1];f=json.loads(o.open(urllib.request.Request(u+'/file/'+uid,data=urllib.parse.urlencode({'csrf_token':token}).encode(),headers={'Referer':d['url']})).read());data=o.open(f['url'],timeout=55).read();p=root/str(n)/name;p.write_bytes(data);files.append({'path':str(p),'sourceUrl':u,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'uploadId':uid})
  out.append({'number':n,'status':'DOWNLOADED_STANDARD_ONLY' if files else 'NO_STANDARD_FILE_FOUND','files':files});print(n,out[-1]['status'],flush=True)
 except Exception as e:out.append({'number':n,'status':'BLOCKED_HTTP','error':str(e)});print(n,str(e),flush=True)
 (root/'itch-base-retry.json').write_text(json.dumps(out,indent=2))


