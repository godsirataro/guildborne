"""Original deterministic synthetic review cues; platform IDs remain unassigned."""
from pathlib import Path
import json,wave
import numpy as np
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/borin-forge-v1';O.mkdir(parents=True,exist_ok=True)
rate=48000;t=np.arange(int(.65*rate))/rate;rng=np.random.default_rng(604)
hit=sum(a*np.sin(2*np.pi*f*t)*np.exp(-t/d)for f,a,d in [(640,.42,.18),(1370,.22,.13),(2190,.15,.09),(3210,.07,.065)])
hit+=rng.normal(0,1,len(t))*.13*np.exp(-t/.016)
hit*=np.minimum(t/.0007,1);hit[-240:]*=np.linspace(1,0,240)
hit*=.72/np.max(np.abs(hit));mix=np.zeros(rate*6)
for sec in [1,3,5]:mix[sec*rate:sec*rate+len(hit)]+=hit
def save(name,a):
 pcm=np.round(a*32767).astype('<i2')
 with wave.open(str(O/name),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(pcm.tobytes())
save('forge_strike.wav',hit);save('forge_contact_review.wav',mix)
assert np.max(np.abs(mix))<1
assert all(np.max(np.abs(mix[max(0,s*rate-480):s*rate]))==0 for s in [1,3,5])
report={'sampleRate':rate,'channels':1,'bits':16,'seconds':6,'contactFrames':[30,90,150],'contactSeconds':[1,3,5],'fps':30,'peak':float(np.max(np.abs(mix))),'source':'Original deterministic synthesis; no external samples','status':'TECHNICAL_SYNC_VERIFIED_LISTENING_AND_ROBLOX_IMPORT_PENDING','robloxSoundId':None}
(O/'cue-sheet.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
