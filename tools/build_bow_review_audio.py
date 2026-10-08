"""Reuse the project's original bow-release sound at authored release markers."""
from pathlib import Path
import wave,json,hashlib
import numpy as np
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/bow-contact-v1';source=R/'assets/uat01/audio/combat/bow_release.wav'
with wave.open(str(source),'rb')as w:
 assert w.getnchannels()==1 and w.getsampwidth()==2 and w.getframerate()==48000
 cue=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(np.int32)
rate=48000;mix=np.zeros(rate*6,dtype=np.int32);starts=[round(s*rate)for s in [.24,2.24,4.24]]
for start in starts:mix[start:start+len(cue)]+=cue
assert np.max(np.abs(mix))<=32767
for start in starts:assert np.all(mix[start-480:start]==0)
with wave.open(str(O/'bow_contact_review.wav'),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(mix.astype('<i2').tobytes())
report={'sampleRate':rate,'channels':1,'bits':16,'duration':6,'releaseSeconds':[.24,2.24,4.24],'releaseSamples':starts,'peak':float(np.max(np.abs(mix))/32767),'source':source.relative_to(R).as_posix(),'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'status':'REUSED_ORIGINAL_CUE_TIMING_CHECKED_LISTENING_IMPORT_PENDING','robloxSoundId':None}
(O/'cue-sheet.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
