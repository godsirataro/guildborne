"""Original native/block-mesh trial art; one shared geometry source for Roblox and Blender."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/uat01/trial-arena';OUT.mkdir(parents=True,exist_ok=True)
parts=[]
stone=[203,192,160];navy=[36,52,73];gold=[205,164,73];iron=[112,127,136];green=[78,133,105]
def box(stage,name,pos,size,color,solid=False):
 parts.append(dict(stage=stage,name=name,position=pos,size=size,color=[v/255 for v in color],solid=solid))
box('Court','ArenaFloor',[0,-.5,0],[96,1,96],stone,True)
for side in [-1,1]:
 box('Court','EdgeInlayX',[side*46,.012,0],[.25,.02,92],gold)
 box('Court','EdgeInlayZ',[0,.012,side*46],[92,.02,.25],gold)
for n in range(-36,37,12):
 box('Court','PavingJointX',[n,.012,0],[.045,.02,90],[174,164,138])
 box('Court','PavingJointZ',[0,.012,n],[90,.02,.045],[174,164,138])
for x in [-44,44]:
 for z in [-44,44]:
  for name,y,size,color in [('Base',.5,[5,1,5],stone),('Plinth',1.5,[4,1,4],iron),('Column',6,[2.8,8,2.8],stone),('Capital',10.4,[4, .8,4],gold),('Crown',11.3,[2,1,2],stone),('Finial',12.1,[.6,.6,.6],gold)]:
   box('Pillars',name,[x,y,z],size,color,True)
  box('Pillars','Banner',[x,6,z+1.45],[2.2,6,.1],navy)
  box('Pillars','BannerStem',[x,6,z+1.52],[.12,4,.05],gold)
  box('Pillars','BannerCross',[x,6.3,z+1.52],[1.4,.12,.05],gold)
for name,pos,size,color in [
 ('SentinelBase',[0,.3,0],[5,.6,4],iron),('SentinelTrim',[0,.68,0],[4,.16,3],gold),('SentinelStem',[0,1.6,0],[1.2,1.7,1.2],iron),
 ('TrialSentinel',[0,3.4,0],[3.5,2.8,2.2],iron),('ChestPlate',[0,3.6,1.18],[2.5,1.7,.22],stone),('Core',[0,3.6,1.35],[.7,.7,.2],gold),
 ('Belt',[0,2.1,0],[3.6,.35,2.4],gold),('Neck',[0,5,0],[.7,.5,.7],iron),('SentinelHead',[0,5.9,0],[1.8,1.5,1.5],gold),
 ('Visor',[0,6, .78],[1.3,.2,.12],navy),('NoseGuard',[0,5.8,.85],[.15,.85,.1],stone)]:box('Sentinel',name,pos,size,color)
for side in [-1,1]:
 for name,pos,size,color in [('Shoulder',[side*2.2,4.5,0],[.8,1,1.2],gold),('UpperArm',[side*2.8,3.8,0],[.8,1.3,1],stone),('Elbow',[side*2.8,3,0],[.7,.5,.8],gold),('Hand',[side*2.8,2.25,0],[1,1,1.1],iron)]:box('Sentinel',name,pos,size,color)
for name,pos,size,color in [('PatientBase',[0,.25,-10],[3,.5,3],iron),('PatientStem',[0,1.3,-10],[.5,1.8,.5],stone),('PracticePatient',[0,3,-10],[1.8,2,1],green),('PatientHead',[0,4.5,-10],[1.2,1.2,1.2],stone),('PatientArms',[0,3.6,-10],[4,.5,.5],stone),('HealMarkV',[0,3,-9.45],[.18,.85,.08],stone),('HealMarkH',[0,3,-9.45],[.7,.18,.08],stone)]:box('Patient',name,pos,size,color)
(OUT/'geometry.json').write_text(json.dumps(parts,indent=2)+'\n')
lines=['--!strict','-- Generated from assets/uat01/trial-arena/geometry.json by tools/generate_trial_arena.py.','return function(model:Model,origin:Vector3,classId:string)']
for p in parts:
 vec=lambda a:','.join(f'{v:.6g}' for v in a)
 lines.append('do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size=Vector3.new('+vec(p['size'])+');p.Position=origin+Vector3.new('+vec(p['position'])+');p.Color=Color3.new('+vec(p['color'])+');p.Anchored=true;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery='+str(p['solid']).lower()+';p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute("TrialArtGroup",'+json.dumps(p['stage'])+');'+('p.Transparency=if classId=="Priest"then 0 else 1;'if p['stage']=='Patient'else '')+'p.Parent=model end')
lines+=['end','']
(ROOT/'src/server/Services/NoviceTrialArt.luau').write_text('\n'.join(lines),encoding='utf-8')
print('TRIAL_ART',len(parts),'parts',len(parts)*12,'triangles')
