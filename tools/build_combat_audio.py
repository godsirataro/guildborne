"""Original deterministic combat SFX synthesis; no recordings or third-party samples."""
from pathlib import Path
import math,random,struct,wave,json,hashlib
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/audio/combat';OUT.mkdir(parents=True,exist_ok=True)
RATE=48000
SOUNDS={'sword_swing':.28,'melee_hit':.22,'shield_block':.48,'bow_release':.3,'arrow_hit':.22,
        'fire_cast':.85,'frost_cast':.75,'heal_cast':1.1,'enemy_warning':.9,'boss_slam':1.2,'enemy_defeat':.65,'grass_step':.16}
def tone(t,f):return math.sin(2*math.pi*f*t)
records=[]
for index,(name,duration) in enumerate(SOUNDS.items()):
    rng=random.Random(4100+index);values=[];low=0;slow=0
    for i in range(round(duration*RATE)):
        t=i/RATE;u=t/duration;noise=rng.uniform(-1,1);low+=.13*(noise-low);slow+=.012*(noise-slow)
        sweep=math.sin(2*math.pi*(1500*t-2000*t*t))
        if name=='sword_swing':v=(noise-low)*math.sin(math.pi*u)**1.4*.45+sweep*.08*math.sin(math.pi*u)
        elif name=='melee_hit':v=(tone(t,90)*.55+slow*.7+noise*.18)*math.exp(-10*u)
        elif name=='shield_block':v=sum(tone(t,f)*a for f,a in [(610,.3),(887,.21),(1345,.16),(2100,.08)])*math.exp(-6*u)+noise*.15*math.exp(-25*u)
        elif name=='bow_release':v=(tone(t,390)+.35*tone(t,780)+.16*tone(t,1170))*.32*math.exp(-9*u)+noise*.13*math.exp(-22*u)
        elif name=='arrow_hit':v=(noise*.35+tone(t,220)*.3)*math.exp(-13*u)
        elif name=='fire_cast':v=(low*.7+slow*1.5+tone(t,65+30*u)*.1)*math.sin(math.pi*u)**.8
        elif name=='frost_cast':v=sum(tone(t,f)*math.exp(-4*u)*a for f,a in [(980,.2),(1433,.17),(2017,.12)])+(noise-low)*.06*math.sin(math.pi*u)
        elif name=='heal_cast':v=sum(tone(t,f)*a for f,a in [(523.25,.2),(659.25,.16),(783.99,.14),(1046.5,.07)])*math.sin(math.pi*u)**1.2
        elif name=='enemy_warning':
            pulse=(math.sin(2*math.pi*3*t)*.5+.5)**2
            v=(tone(t,330)+.25*tone(t,660))*.3*pulse*math.sin(math.pi*u)**.5
        elif name=='boss_slam':v=(tone(t,48)*.45+tone(t,73)*.2+slow*1.8)*math.exp(-5*u)+noise*.22*math.exp(-30*u)
        elif name=='enemy_defeat':v=math.sin(2*math.pi*(330*t-120*t*t))*.3*math.exp(-5*u)+tone(t,165)*.12*math.exp(-5*u)
        else:v=(low*.6+(noise-low)*.12)*math.sin(math.pi*u)*math.exp(-4*u)
        values.append(v)
    weights=[max(0,min(1,i/(RATE*.004),(len(values)-1-i)/(RATE*.02))) for i in range(len(values))]
    dc=sum(v*w for v,w in zip(values,weights))/sum(weights)
    values=[(v-dc)*w for v,w in zip(values,weights)];peak=max(map(abs,values));gain=min(2,.55/peak)
    pcm=[round(v*gain*32767) for v in values];path=OUT/(name+'.wav')
    with wave.open(str(path),'wb') as out:
        out.setnchannels(1);out.setsampwidth(2);out.setframerate(RATE);out.writeframes(struct.pack('<'+'h'*len(pcm),*pcm))
    with wave.open(str(path),'rb') as stream:
        assert stream.getnchannels()==1 and stream.getsampwidth()==2 and stream.getframerate()==RATE
        decoded=struct.unpack('<'+'h'*stream.getnframes(),stream.readframes(stream.getnframes()))
    assert decoded[0]==0 and decoded[-1]==0 and max(map(abs,decoded))<32767
    assert abs(sum(decoded)/len(decoded))<3
    rms=math.sqrt(sum((v/32767)**2 for v in decoded)/len(decoded));assert rms>0
    records.append({'id':'combat.audio.'+name,'file':str(path.relative_to(ROOT)).replace('\\','/'),'durationSeconds':duration,
        'sampleRate':RATE,'channels':1,'bitDepth':16,'peakDbFS':round(20*math.log10(max(map(abs,decoded))/32767),2),
        'rmsDbFS':round(20*math.log10(rms),2),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'source':'original procedural synthesis','status':'CREATED_LISTENING_REVIEW_PENDING','robloxAssetId':None})
(OUT/'manifest.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8')
print('COMBAT_AUDIO_PASS',len(records),'files',round(sum(SOUNDS.values()),2),'seconds; no clipping; listening/import pending')
