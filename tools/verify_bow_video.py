"""Read MP4 container tracks and sample counts without installing extra software."""
from pathlib import Path
import struct,json,sys
study='sword'if '--sword'in sys.argv else'bow'
O=Path(__file__).resolve().parents[1]/f'assets/uat01/{study}-contact-v1';data=(O/'motion-with-sound.mp4').read_bytes()
def atoms(buf):
 pos=0
 while pos+8<=len(buf):
  size,kind=struct.unpack_from('>I4s',buf,pos);header=8
  if size==1:size=struct.unpack_from('>Q',buf,pos+8)[0];header=16
  if size==0:size=len(buf)-pos
  assert size>=header and pos+size<=len(buf)
  yield kind.decode('ascii'),buf[pos+header:pos+size];pos+=size
def get(buf,name):return next(v for k,v in atoms(buf)if k==name)
moov=get(data,'moov');tracks=[]
for kind,trak in atoms(moov):
 if kind!='trak':continue
 mdia=get(trak,'mdia');handler=get(mdia,'hdlr')[8:12].decode('ascii');mdhd=get(mdia,'mdhd');version=mdhd[0]
 if version==0:scale,duration=struct.unpack_from('>II',mdhd,12)
 else:scale=struct.unpack_from('>I',mdhd,20)[0];duration=struct.unpack_from('>Q',mdhd,24)[0]
 table=get(get(mdia,'minf'),'stbl');samples=struct.unpack_from('>I',get(table,'stsz'),8)[0];description=get(table,'stsd');codec=description[12:16].decode('ascii')
 record={'type':handler,'codec':codec,'samples':samples,'mediaSeconds':duration/scale}
 if handler=='vide':record['width'],record['height']=struct.unpack_from('>HH',description,40)
 if handler=='soun':record['channels']=struct.unpack_from('>H',description,32)[0];record['sampleRate']=struct.unpack_from('>I',description,40)[0]>>16
 tracks.append(record)
video=next(x for x in tracks if x['type']=='vide');audio=next(x for x in tracks if x['type']=='soun')
assert video['codec']=='avc1'and video['samples']==60 and video['width']==480 and video['height']==480 and abs(video['mediaSeconds']-2)<.001
assert audio['codec']=='mp4a'and audio['sampleRate']==48000 and 1.99<audio['mediaSeconds']<2.05
report={'status':'PASS','bytes':len(data),'tracks':tracks,'cueStartsInVideo':[.2 if study=='sword'else .24],'decodedFrame':f'build/{study}-video-decoded.png','listeningApproved':False}
(O/'video-report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
