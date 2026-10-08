"""Reuse an original sword-swing cue and package the real rendered motion frames."""
from pathlib import Path
import wave,json,hashlib
import numpy as np
from PIL import Image
R=Path(__file__).resolve().parents[1];O=R/'assets/uat01/sword-contact-v1';source=R/'assets/uat01/audio/combat/sword_swing.wav'
with wave.open(str(source),'rb')as w:
 assert w.getnchannels()==1 and w.getsampwidth()==2;rate=w.getframerate();samples=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(np.int32)
mix=np.zeros(rate*6,dtype=np.int32)
for t in [.2,2.2,4.2]:
 start=round(t*rate);mix[start:start+len(samples)]+=samples
assert np.max(np.abs(mix))<=32767
with wave.open(str(O/'sword_contact_review.wav'),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(rate);w.writeframes(mix.astype('<i2').tobytes())
report={'status':'REUSED_ORIGINAL_CUE_TIMING_CHECKED_LISTENING_IMPORT_PENDING','source':source.relative_to(R).as_posix(),'sourceSha256':hashlib.sha256(source.read_bytes()).hexdigest(),'swingStarts':[.2,2.2,4.2],'cutSample':[.3,2.3,4.3],'sampleRate':rate,'duration':6,'peak':float(np.max(np.abs(mix))/32767),'robloxSoundId':None}
(O/'cue-sheet.json').write_text(json.dumps(report,indent=2)+'\n')
F=R/'build/sword-contact-motion';frames=[Image.open(F/f'{i:03}.png').convert('RGB')for i in range(0,60,2)];frames[0].save(O/'motion.gif',save_all=True,append_images=frames[1:],duration=[60,70,70]*10,loop=0);print('SWORD_REVIEW_MEDIA',report)
