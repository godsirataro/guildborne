"""Original water-pour synthesis aligned to the gardener's local motion."""
from pathlib import Path
import json,wave
import numpy as np
O=Path(__file__).resolve().parents[1]/'assets/uat01/vaela-garden-v1';rate=48000;length=97600;rng=np.random.default_rng(606)
noise=rng.normal(0,1,length);smooth=np.convolve(noise,np.ones(7)/7,mode='same');t=np.arange(length)/rate
sound=smooth*(.45+.15*np.sin(t*2*np.pi*9))
for at in [.08,.26,.43,.71,.96,1.2,1.45,1.73,1.94]:
 u=t-at;mask=(u>=0)&(u<.08);sound[mask]+=.06*np.sin(2*np.pi*(1700*u[mask]-500*u[mask]**2))*np.exp(-u[mask]*55)
sound[:960]*=np.linspace(0,1,960);sound[-960:]*=np.linspace(1,0,960);sound*=.4/np.max(np.abs(sound));mix=np.zeros(rate*6);mix[rate*2:rate*2+length]=sound
for name,a in [('water_pour.wav',sound),('watering_review.wav',mix)]:
 with wave.open(str(O/name),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(np.round(a*32767).astype('<i2').tobytes())
assert not np.any(mix[:rate*2]);assert not np.any(mix[rate*2+length:]);assert np.max(np.abs(mix))<1
report={'sampleRate':rate,'channels':1,'bits':16,'startSeconds':2,'endSeconds':2+length/rate,'visualFrames':[60,120],'durationSeconds':6,'peak':float(np.max(np.abs(mix))),'source':'Original deterministic synthesis','status':'TECHNICAL_TIMING_PASS_LISTENING_IMPORT_PENDING','robloxSoundId':None}
(O/'cue-sheet.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
