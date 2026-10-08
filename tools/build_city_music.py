"""Original deterministic musical sketches, no recordings/downloaded melodies.
Seven 24-second stereo loops share an authored Guildborne motif.
"""
from pathlib import Path
import numpy as np
import json,wave,hashlib,math
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/city-music';OUT.mkdir(parents=True,exist_ok=True)
RATE=48000;BPM=80;BEAT=60/BPM;BEATS=32;N=round(BEATS*BEAT*RATE)
SPECS=[
 ('crownford','Crownford • Civic Dawn',50,[0,2,4,7,9],[(0,4,7),(5,9,12),(7,11,14),(0,4,7)],'pluck',.18),
 ('sylvaris','Sylvaris • Canopy Paths',55,[0,2,4,7,9],[(0,4,7),(2,5,9),(5,9,12),(0,4,7)],'flute',.04),
 ('deepforge','Deepforge • Gentle Embers',50,[0,3,5,7,10],[(0,3,7),(5,8,12),(7,10,14),(0,3,7)],'bell',.2),
 ('astralis','Astralis • Starlit Charts',57,[0,2,4,6,9],[(0,4,7),(2,6,9),(4,7,11),(0,4,7)],'bell',.03),
 ('crosshaven','Crosshaven • Meeting Tides',53,[0,2,4,7,9],[(0,4,7),(5,9,12),(2,5,9),(7,11,14)],'pluck',.12),
 ('ironroot','Ironroot • A Shared Hearth',50,[0,2,3,7,9],[(0,3,7),(5,9,12),(3,7,10),(0,3,7)],'flute',.16),
 ('guild_haven','Guild Island • Homeward',50,[0,2,4,7,9],[(0,4,7),(5,9,12),(2,5,9),(0,4,7)],'pluck',.02),
]
# Authored four-bar question and answer, repeated with a softer upper response.
MOTIF=[(0,0,1.5),(2,2,.75),(3,1,.75),(4,3,1.5),(6,2,1),(8,1,1.5),(10,4,.75),(11,3,.75),(12,2,1),(14,0,1.75)]
records=[];scores={}
for seed,(identity,title,root,scale,chords,timbre,percussion) in enumerate(SPECS):
 rng=np.random.default_rng(98231+seed);buffer=np.zeros((N,2),np.float64);events=[]
 def mix(values,start,pan):
  idx=(np.arange(len(values),dtype=np.int64)+round(start*RATE))%N
  gains=np.array([math.cos((pan+1)*math.pi/4),math.sin((pan+1)*math.pi/4)])
  np.add.at(buffer,idx,values[:,None]*gains)
 def note(beat,midi,duration,level,voice,pan=0):
  seconds=duration*BEAT;t=np.arange(round((seconds+.4)*RATE))/RATE;frequency=440*2**((midi-69)/12)
  attack=np.clip(t/(.09 if voice=='pad' else .012),0,1);release=np.clip((seconds+.4-t)/.4,0,1)
  if voice=='pad':tone=np.sin(2*np.pi*frequency*t)+.12*np.sin(2*np.pi*frequency*2*t);env=attack*release*.8
  elif voice=='flute':tone=np.sin(2*np.pi*frequency*t+.008*np.sin(2*np.pi*4.1*t))+.08*np.sin(2*np.pi*frequency*2*t);env=attack*release*np.exp(-1.2*t/max(seconds,.1))
  elif voice=='bell':tone=np.sin(2*np.pi*frequency*t)+.24*np.sin(2*np.pi*frequency*2*t)*np.exp(-3*t)+.05*np.sin(2*np.pi*frequency*3*t);env=attack*release*np.exp(-3*t/max(seconds,.1))
  else:tone=np.sin(2*np.pi*frequency*t)+.2*np.sin(2*np.pi*frequency*2*t)+.09*np.sin(2*np.pi*frequency*3*t);env=attack*release*np.exp(-4*t/max(seconds,.1))
  signal=level*tone*env;mix(signal,beat*BEAT,pan)
  # Quiet deterministic circular echoes preserve the wraparound tail.
  mix(signal*.12,beat*BEAT+.21,-pan);mix(signal*.05,beat*BEAT+.43,pan*.5)
  events.append(dict(beat=beat,midi=midi,durationBeats=duration,level=level,voice=voice,pan=pan))
 for bar in range(8):
  chord=chords[(bar//2)%len(chords)]
  for i,pitch in enumerate(chord):note(bar*4,root+pitch,3.7,.037,'pad',(i-1)*.35)
  note(bar*4,root-12+chord[0],2.8,.068,'pluck',0)
  if bar%2:note(bar*4+2,root-12+chord[2],1.65,.035,'pluck',0)
 for repeat in range(2):
  for beat,degree,duration in MOTIF:
   note(beat+16*repeat,root+12+scale[degree],duration,.13 if repeat==0 else .1,timbre,-.15 if repeat==0 else .15)
 if percussion:
  for beat in range(0,32,2):
   t=np.arange(round(.18*RATE))/RATE;noise=rng.normal(0,1,len(t));noise=np.convolve(noise,np.ones(9)/9,mode='same')
   env=np.minimum(1,t/.004)*np.exp(-35*t)*np.minimum(1,(.18-t)/.025)
   mix(percussion*.12*noise*env,beat*BEAT,.2 if beat%4 else -.2)
 buffer-=buffer.mean(axis=0);peak=np.max(np.abs(buffer));rms=np.sqrt(np.mean(buffer**2));buffer*=min(.45/peak,.075/rms)
 pcm=np.rint(buffer*32767).astype('<i2');path=OUT/(identity+'.wav')
 with wave.open(str(path),'wb')as stream:stream.setnchannels(2);stream.setsampwidth(2);stream.setframerate(RATE);stream.writeframes(pcm.tobytes())
 decoded=pcm.astype(np.float64)/32767;peak=np.max(np.abs(decoded));rms=np.sqrt(np.mean(decoded**2));seam=np.max(np.abs(decoded[0]-decoded[-1]));dc=np.max(np.abs(decoded.mean(axis=0)))
 assert peak<.451 and dc<1e-5 and seam<.015 and np.isfinite(decoded).all(),(identity,peak,dc,seam)
 records.append(dict(id='music.city.'+identity,title=title,file=path.relative_to(ROOT).as_posix(),seconds=N/RATE,bpm=BPM,bars=8,channels=2,sampleRate=RATE,bitDepth=16,peakDbFS=round(20*math.log10(peak),2),rmsDbFS=round(20*math.log10(rms),2),seamDifference=round(float(seam),7),dc=round(float(dc),9),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),source='original score and procedural synthesis',status='MUSICAL_SKETCH_LISTENING_IMPORT_PENDING',robloxAssetId=None))
 scores[identity]=dict(title=title,rootMidi=root,scale=scale,chords=chords,events=events)
 print(identity,records[-1]['peakDbFS'],records[-1]['rmsDbFS'],seam)
(OUT/'manifest.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'scores.json').write_text(json.dumps(dict(bpm=BPM,beats=BEATS,motif=MOTIF,scores=scores),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('CITY_MUSIC_PASS',len(records),'original24secondloops',sum(p.stat().st_size for p in OUT.glob('*.wav')),'bytes')
