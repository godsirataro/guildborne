"""Original deterministic six-second cooking loop candidate."""
from pathlib import Path
import numpy as np,wave,json
O=Path(__file__).resolve().parents[1]/'assets/uat01/roka-hearth-v1';rate=48000;n=rate*6;t=np.arange(n)/rate;rng=np.random.default_rng(607)
noise=rng.normal(0,1,n);filtered=np.convolve(noise,np.ones(19)/19,mode='same');a=filtered*(.12+.05*np.cos(t*2*np.pi/3))
for start in [0.7,1.2,2.3,3.7,4.2,5.3]:
 u=t-start;mask=(u>=0)&(u<.10);a[mask]+=.015*np.sin(2*np.pi*(440*u[mask]-70*u[mask]**2))*np.exp(-u[mask]*35)
a[:960]*=np.linspace(0,1,960);a[-960:]*=np.linspace(1,0,960);a*=.25/np.max(np.abs(a))
with wave.open(str(O/'hearth_stir.wav'),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(np.round(a*32767).astype('<i2').tobytes())
assert np.max(np.abs(a))<1
report={'sampleRate':rate,'bits':16,'channels':1,'seconds':6,'peak':float(np.max(np.abs(a))),'motion':'two three-second stirring circles','source':'Original deterministic synthesis','status':'TECHNICAL_PASS_LISTENING_IMPORT_PENDING','robloxSoundId':None}
(O/'cue-sheet.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report))
