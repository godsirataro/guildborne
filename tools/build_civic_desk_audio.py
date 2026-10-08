"""Three original profession Foley cue sketches with explicit motion timing."""
from pathlib import Path
import numpy as np,wave,json
R=Path(__file__).resolve().parents[1];rate=48000;n=rate*6;t=np.arange(n)/rate
for index,who in enumerate(['elian','nyra','sela']):
 rng=np.random.default_rng(610+index);noise=rng.normal(0,1,n);a=np.zeros(n)
 if who=='elian':
  u=t-3;mask=(u>=0)&(u<.25);a[mask]=(.15*noise[mask]*np.exp(-u[mask]*80)+.28*np.sin(2*np.pi*190*u[mask])*np.exp(-u[mask]*30));a[3*rate:3*rate+96]*=np.linspace(0,1,96);peak=.35;events=[{'time':3,'event':'stamp contact'}]
 else:
  smooth=np.convolve(noise,np.ones(3)/3,mode='same');scratch=noise-smooth
  envelope=.5+.2*np.sin(t*2*np.pi*13)+.15*np.sin(t*2*np.pi*7)
  if who=='nyra':
   a=scratch*envelope*.03;a[:480]*=np.linspace(0,1,480);a[-480:]*=np.linspace(1,0,480);events=[{'from':0,'to':6,'event':'chart tracing'}];peak=.10
  else:
   for start in [0,2,4]:
    first=start*rate;last=first+int(1.5*rate);a[first:last]=scratch[first:last]*envelope[first:last]*.03;a[first:first+480]*=np.linspace(0,1,480);a[last-480:last]*=np.linspace(1,0,480)
   events=[{'from':v,'to':v+1.5,'event':'ledger writing'}for v in [0,2,4]];peak=.12
 a*=peak/np.max(np.abs(a));assert np.max(np.abs(a))<1
 O=R/('assets/uat01/'+who+'-desk-v1')
 with wave.open(str(O/'activity_review.wav'),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(np.round(a*32767).astype('<i2').tobytes())
 report={'seconds':6,'sampleRate':rate,'channels':1,'bits':16,'peak':float(np.max(np.abs(a))),'events':events,'source':'Original deterministic synthesis','status':'TECHNICAL_TIMING_PASS_LISTENING_IMPORT_PENDING','robloxSoundId':None}
 (O/'cue-sheet.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(who,json.dumps(report))
