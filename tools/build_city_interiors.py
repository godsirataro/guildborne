"""Original room furnishings, preserving an eight-stud central entrance aisle."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/city-interior-kit';OUT.mkdir(parents=True,exist_ok=True)
palette={'wood':[107,73,49],'dark':[57,48,42],'ivory':[227,216,185],'gold':[200,160,78],'stone':[115,125,135],'navy':[61,91,128],'red':[143,68,60],'green':[77,136,110],'glass':[114,185,181],'steel':[159,174,185]}
assets=[]
def room(id,label):
    a=dict(id=id,kind='CityFurnishing',building=label,parts=[]);assets.append(a);return a
def box(a,n,s,p,c,rz=0,solid=True):a['parts'].append(dict(name=n,size=s,position=p,color=c,rotation=[0,0,rz],solid=solid))
def table(a,x,z,w=9,d=5,h=3):
    box(a,'TableTop',[w,.5,d],[x,h,z],'wood')
    for sx in (-1,1):
        for sz in (-1,1):box(a,'TableLeg',[.45,h,.45],[x+sx*(w/2-.55),h/2,z+sz*(d/2-.55)],'dark')
def stool(a,x,z):
    box(a,'Stool',[2.3,.4,2.3],[x,2.2,z],'wood')
    for dx in (-.75,.75):box(a,'StoolFoot',[.35,2,.35],[x+dx,1,z],'dark')
def shelf(a,x,z):
    for dx in (-5,5):box(a,'ShelfSide',[.5,9,2.8],[x+dx,4.5,z],'wood')
    for y in (1,4,7):box(a,'ShelfBoard',[10,.35,2.8],[x,y,z],'wood')
def books(a,x,z):
    for i in range(5):box(a,'Ledger',[.8,1.6+(i%2)*.4,1.5],[x-3+i*1.3,2+(i%2)*.2,z],['navy','red','green'][i%3])
a=room('guild_office','Guild Administration');table(a,-16,-8,13,6);stool(a,-16,-14)
for x in (-20,-16,-12):box(a,'OpenLedger',[2,.12,1.5],[x,3.32,-8],'ivory',solid=False)
shelf(a,16,-15);books(a,16,-15);table(a,16,4,10,7)
box(a,'MapParchment',[8,.1,5],[16,3.32,4],'ivory',solid=False)
for x,z in ((14,3),(18,5),(15,5)):box(a,'MapPin',[.3,.8,.3],[x,3.8,z],'gold',solid=False)
box(a,'GuildCrest',[3,3,.4],[0,9,-18],'gold',45,False)
a=room('hearth_tavern','The Hearth and Banner');table(a,-16,-5,13,5,4)
for x in (-20,-15,-10):stool(a,x,0);box(a,'Tankard',[.7,.9,.7],[x,4.7,-5],'gold',solid=False)
table(a,16,6,10,6)
for x in (12,20):stool(a,x,11)
for x in (11,21):box(a,'HearthPier',[2,7,3],[x,3.5,-15],'stone')
box(a,'HearthLintel',[12,2,3],[16,7,-15],'stone');box(a,'HearthBack',[10,6,.5],[16,3,-17],'dark')
box(a,'Coals',[7,.6,2],[16,.5,-15],'red',solid=False)
for x in (14,16,18):box(a,'FireShape',[.7,2.5,.7],[x,1.5,-15],'gold',20,False)
a=room('exchange_office','Guildborne Exchange');table(a,-16,-6,13,6,4);shelf(a,16,-15);books(a,16,-15)
box(a,'BalancePost',[.35,3,.35],[-16,5.75,-6],'gold');box(a,'BalanceBeam',[5,.25,.3],[-16,7.2,-6],'gold')
for x in (-18,-14):box(a,'ScaleChain',[.1,1.4,.1],[x,6.45,-6],'gold',solid=False);box(a,'ScalePan',[1.8,.15,1.8],[x,5.8,-6],'gold')
for x,z in ((12,5),(18,5),(18,11)):
    box(a,'CargoCrate',[4,3,4],[x,1.5,z],'wood')
    for dx in (-1.5,1.5):box(a,'CrateBand',[.3,3.1,4.1],[x+dx,1.5,z],'dark',solid=False)
a=room('forge_workshop','Blacksmith');table(a,-16,-8,12,5)
box(a,'AnvilPlinth',[4,3,4],[15,1.5,1],'wood');box(a,'AnvilWaist',[2,1.7,2],[15,3.8,1],'steel');box(a,'AnvilFace',[6,.8,3],[15,5,1],'steel')
box(a,'AnvilHorn',[2.6,.65,1.3],[18.8,4.9,1],'steel')
for x in (-20,-16,-12):box(a,'ToolHandle',[.4,3,.4],[x,4,-8],'wood',-65,False);box(a,'HammerHead',[1.5,.8,.8],[x-1.35,4.6,-8],'steel',solid=False)
for x in (10,22):box(a,'ForgeWall',[2,7,6],[x,3.5,-13],'stone')
box(a,'ForgeRoof',[14,2,6],[16,8,-13],'stone');box(a,'ForgeCoal',[10,1,5],[16,1,-13],'red');box(a,'ForgeBack',[14,6,1],[16,3,-16],'dark')
for x in (-20,-14,-8):box(a,'Ingot',[2,.6,1],[x,3.6,-8],'steel',solid=False)
a=room('alchemy_study','Alchemy Shop');table(a,-16,-3,13,6);shelf(a,16,-15)
for y in (1.8,4.8,7.8):
    for i in range(5):
        x=12+i*2;box(a,'PotionBody',[.9,1.1,.9],[x,y,-15],['green','navy','red'][i%3],solid=False)
        box(a,'PotionStopper',[.5,.25,.5],[x,y+.7,-15],'gold',solid=False)
for x in (-20,-16,-12):box(a,'Flask',[1.2,1.5,1.2],[x,4,-3],'glass',solid=False)
box(a,'CauldronBase',[6,2.5,6],[15,2,4],'dark')
for x,z in ((12,4),(18,4),(15,1),(15,7)):box(a,'CauldronRim',[.4,.6,5.7] if x!=15 else [5.7,.6,.4],[x,3.5,z],'steel')
box(a,'PotionSurface',[5.5,.15,5.5],[15,3.3,4],'green',solid=False)
(OUT/'kit.json').write_text(json.dumps(dict(schema=1,units='stud',upAxis='Y',palette=palette,assets=assets),indent=2)+'\n',encoding='utf-8')
v=lambda x:'Vector3.new('+','.join(map(str,x))+')'
lines=['--!strict','-- Generated original room decor; no service/purchase interactions.','return function(): Folder','local f=Instance.new("Folder");f.Name="CityInteriorKit"']
for a in assets:
    lines+=['do local m=Instance.new("Model");m.Name='+json.dumps(a['id'])+';m.WorldPivot=CFrame.identity;m:SetAttribute("BuildingName",'+json.dumps(a['building'])+');m.Parent=f']
    for p in a['parts']:
        lines+=['do local p=Instance.new("Part");p.Name='+json.dumps(p['name'])+';p.Size='+v(p['size'])+';p.CFrame=CFrame.new('+v(p['position'])+')*CFrame.Angles(0,0,math.rad('+str(p['rotation'][2])+'));p.Color=Color3.fromRGB('+','.join(map(str,palette[p['color']]))+');p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide='+str(p['solid']).lower()+';p.CanQuery=true;p.CanTouch=false;p.Parent=m end']
    lines+=['end']
lines+=['return f','end'];(ROOT/'src/server/Services/CityInteriorKit.luau').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('CITY_INTERIORS',len(assets),'parts',sum(len(a['parts']) for a in assets))
