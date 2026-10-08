"""Original deterministic synthesis, no sampled or downloaded audio.
48 kHz mono 16-bit PCM masters with short fades and a conservative peak.
"""
from pathlib import Path
import hashlib
import json
import math
import struct
import wave

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/audio'
RATE=48000
# (start seconds, frequency Hz, note duration, relative amplitude)
SCORES={
 'hover':[(0,740,.065,.35)],
 'press':[(0,440,.11,.55),(0,880,.07,.12)],
 'back':[(0,554,.12,.45),(.06,370,.15,.35)],
 'modal_open':[(0,440,.18,.4),(.045,660,.19,.3)],
 'confirm':[(0,523.25,.22,.5),(.09,783.99,.24,.45)],
 'error':[(0,277.18,.15,.4),(.1,220,.18,.35)],
 'reward':[(0,659.25,.24,.4),(.09,783.99,.28,.4),(.18,1046.5,.38,.45)],
 'level_up':[(0,392,.24,.35),(.1,523.25,.27,.4),(.2,659.25,.3,.42),(.31,783.99,.42,.46)],
 'recruit_reveal':[(0,261.63,.28,.25),(.11,392,.3,.3),(.23,523.25,.35,.35),(.35,659.25,.43,.4),(.35,783.99,.43,.2)],
 'notification':[(0,659.25,.17,.3),(.12,523.25,.21,.28)],
}
OUT.mkdir(parents=True,exist_ok=True)
records=[]
for name,notes in SCORES.items():
    duration=max(start+length for start,_,length,_ in notes)+.035
    values=[0.0]*math.ceil(duration*RATE)
    for start,frequency,length,amplitude in notes:
        offset=round(start*RATE)
        for i in range(round(length*RATE)):
            t=i/RATE
            attack=min(1,t/.006)
            release=min(1,(length-t)/.022)
            envelope=attack*attack*(3-2*attack)*release*math.exp(-5*t/length)
            fundamental=2*math.pi*frequency*t
            tone=math.sin(fundamental)+.18*math.sin(fundamental*2)+.065*math.sin(fundamental*3)
            values[offset+i]+=amplitude*envelope*tone
    # Remove small numerical DC and fade again at file edges.
    weights=[min(1,i/(RATE*.005),(len(values)-1-i)/(RATE*.005)) for i in range(len(values))]
    dc=sum(v*w for v,w in zip(values,weights))/sum(weights)
    values=[(v-dc)*w for v,w in zip(values,weights)]
    peak=max(abs(v) for v in values)
    gain=min(1,.45/peak)
    pcm=[round(v*gain*32767) for v in values]
    path=OUT/(name+'.wav')
    with wave.open(str(path),'wb') as stream:
        stream.setnchannels(1);stream.setsampwidth(2);stream.setframerate(RATE)
        stream.writeframes(struct.pack('<'+'h'*len(pcm),*pcm))
    with wave.open(str(path),'rb') as stream:
        assert stream.getnchannels()==1 and stream.getsampwidth()==2 and stream.getframerate()==RATE
        decoded=struct.unpack('<'+'h'*stream.getnframes(),stream.readframes(stream.getnframes()))
    assert max(abs(v) for v in decoded)<32767 and decoded[0]==0 and decoded[-1]==0
    assert abs(sum(decoded)/len(decoded))<3
    rms=math.sqrt(sum((v/32767)**2 for v in decoded)/len(decoded))
    records.append({'id':'ui.audio.'+name,'file':str(path.relative_to(ROOT)).replace('\\','/'),
        'durationSeconds':round(len(pcm)/RATE,4),'sampleRate':RATE,'channels':1,'bitDepth':16,
        'peakDbFS':round(20*math.log10(max(abs(v) for v in pcm)/32767),2),
        'rmsDbFS':round(20*math.log10(rms),2),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'source':'original procedural synthesis','status':'CREATED_LISTENING_REVIEW_PENDING','robloxAssetId':None})
(OUT/'manifest.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'files':len(records),'totalSeconds':round(sum(r['durationSeconds'] for r in records),2),'clipping':False,'robloxUpload':False}))
