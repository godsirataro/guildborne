"""Original deterministic SVG/native UI symbols; not generated raster illustrations."""
from pathlib import Path
import json,html
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets/uat01/ui-symbols';OUT.mkdir(parents=True,exist_ok=True)
icons={}
def icon(id):
    a=[];icons[id]=a;return a
def line(a,*xy):
    for i in range(0,len(xy)-2,2):a.append(['line',*xy[i:i+4]])
def circle(a,x,y,r):a.append(['circle',x,y,r])
def rect(a,x,y,w,h):a.append(['rect',x,y,w,h])
def shield(a):line(a,6,5,16,2,26,5,25,19,21,25,16,30,11,25,7,19,6,5)
def sword(a):line(a,9,27,22,6,27,3,26,9,13,30);line(a,8,19,18,25)
def cross(a):line(a,16,5,16,27);line(a,5,16,27,16)
def star(a):line(a,16,3,19,12,29,16,19,20,16,29,12,20,3,16,12,12,16,3)
def house(a):line(a,4,14,16,4,28,14);line(a,7,12,7,28,25,28,25,12);line(a,13,28,13,20,19,20,19,28)
def flag(a):line(a,8,29,8,4,25,4,21,11,25,17,8,17)
def compass(a):circle(a,16,16,12);line(a,21,7,18,19,11,25,14,13,21,7)
def arrow(a,x,y,dx,dy):
    line(a,x,y,x+dx,y+dy);line(a,x+dx-dx*.3-dy*.25,y+dy-dy*.3+dx*.25,x+dx,y+dy,x+dx-dx*.3+dy*.25,y+dy-dy*.3-dx*.25)
shield(icon('ui.classes.knight'))
a=icon('ui.classes.warrior');sword(a);line(a,5,3,27,27);line(a,18,25,25,18)
a=icon('ui.classes.archer');line(a,8,4,17,8,21,16,17,24,8,28,8,4);arrow(a,3,16,26,0)
a=icon('ui.classes.mage');line(a,9,29,20,9);circle(a,22,6,4);line(a,3,6,7,6);line(a,5,4,5,8)
a=icon('ui.classes.priest');cross(a);circle(a,16,16,12)
a=icon('ui.combat.focus_target');circle(a,16,16,9);circle(a,16,16,2)
for x,y,dx,dy in [(16,2,0,7),(16,23,0,7),(2,16,7,0),(23,16,7,0)]:line(a,x,y,x+dx,y+dy)
a=icon('ui.combat.regroup');circle(a,16,16,3)
for x,y,dx,dy in [(3,3,8,8),(29,3,-8,8),(16,30,0,-9)]:arrow(a,x,y,dx,dy)
a=icon('ui.combat.retreat');line(a,6,5,6,27,16,27,16,5,6,5);arrow(a,29,16,-18,0)
sword(icon('ui.combat.physical_damage'));star(icon('ui.combat.magic_damage'));cross(icon('ui.combat.healing'))
a=icon('ui.combat.downed');circle(a,7,22,3);line(a,11,24,20,24,26,29);line(a,17,24,22,18);line(a,14,3,23,12);line(a,23,3,14,12)
a=icon('ui.combat.recovering');line(a,27,12,24,6,16,3,7,6,3,15,6,24,14,29,23,26);arrow(a,27,5,0,8);line(a,11,16,21,16);line(a,16,11,16,21)
flag(icon('ui.combat.in_expedition'))
a=icon('ui.combat.target_enemy');line(a,7,9,9,4,14,8,18,8,23,4,25,9,25,21,16,29,7,21,7,9);line(a,11,15,14,17);line(a,21,15,18,17)
a=icon('ui.combat.cooldown');circle(a,16,17,11);line(a,16,17,16,10);line(a,16,17,22,20);line(a,12,2,20,2)
a=icon('ui.combat.range');arrow(a,4,16,24,0);arrow(a,28,16,-24,0);line(a,4,5,4,9);line(a,28,5,28,9)
a=icon('ui.combat.area');circle(a,16,16,12);circle(a,16,16,5)
for x,y in [(9,9),(9,23),(23,9),(23,23)]:circle(a,x,y,1)
a=icon('ui.map.plaza')
for x,y in [(4,4),(19,4),(4,19),(19,19)]:rect(a,x,y,9,9)
house(icon('ui.map.guild_home'))
a=icon('ui.map.tavern');line(a,6,9,6,26,21,26,21,9,6,9);line(a,21,12,28,12,28,22,21,22);line(a,8,4,11,5,15,3,19,5)
a=icon('ui.map.exchange');line(a,16,4,16,28);line(a,5,10,27,10);line(a,6,10,2,20,10,20,6,10);line(a,26,10,22,20,30,20,26,10);line(a,10,28,22,28)
a=icon('ui.map.blacksmith');line(a,6,28,20,9);line(a,14,5,20,2,29,9,26,15,14,5)
a=icon('ui.map.alchemist');line(a,12,3,20,3);line(a,13,3,13,12,5,26,8,29,24,29,27,26,19,12,19,3);line(a,9,21,23,21);circle(a,16,17,1)
a=icon('ui.map.tower');line(a,7,29,7,12,4,12,4,3,10,3,10,8,14,8,14,3,18,3,18,8,22,8,22,3,28,3,28,12,25,12,25,29,7,29);line(a,13,29,13,22,19,22,19,29)
a=icon('ui.map.portal');line(a,5,29,5,13,8,6,16,2,24,6,27,13,27,29);line(a,10,29,10,14,12,10,16,8,20,10,22,14,22,29)
flag(icon('ui.map.objective'))
a=icon('ui.map.danger');line(a,16,3,30,28,2,28,16,3);line(a,16,11,16,19);circle(a,16,24,1)
a=icon('ui.map.safe_zone');shield(a);line(a,10,16,14,20,23,11)
a=icon('ui.map.player_position');line(a,16,3,27,28,16,23,5,28,16,3)
a=icon('ui.guild_emblem.shield_round');circle(a,16,16,13);line(a,16,4,16,28);line(a,4,16,28,16)
shield(icon('ui.guild_emblem.shield_kite'))
a=icon('ui.guild_emblem.shield_square');line(a,4,4,28,4,28,22,16,30,4,22,4,4)
a=icon('ui.guild_emblem.shield_crest');shield(a);line(a,10,8,13,12,16,7,19,12,22,8);line(a,12,21,20,21)
icons['ui.guild_emblem.tower']=icons['ui.map.tower'][:]
a=icon('ui.guild_emblem.oak');line(a,13,29,13,20,6,20,3,16,7,11,6,7,11,5,16,2,21,5,26,7,25,11,29,16,26,20,19,20,19,29);line(a,10,29,22,29)
a=icon('ui.guild_emblem.wing');line(a,5,28,4,12,9,3,10,15,17,4,17,17,25,7,23,22,15,28,5,28)
compass(icon('ui.guild_emblem.compass'))
a=icon('ui.guild_emblem.sun');circle(a,16,16,6)
for x,y,dx,dy in [(16,2,0,4),(16,26,0,4),(2,16,4,0),(26,16,4,0),(5,5,3,3),(24,24,3,3),(5,27,3,-3),(24,8,3,-3)]:line(a,x,y,x+dx,y+dy)
a=icon('ui.guild_emblem.moon');line(a,24,4,14,3,6,9,3,18,7,26,16,30,25,25,29,17,23,20,16,18,12,11,15,5)
a=icon('ui.guild_emblem.wolf');line(a,6,3,14,9,18,9,26,3,25,21,16,30,7,21,6,3);line(a,10,15,13,17);line(a,22,15,19,17);line(a,13,23,19,23,16,26,13,23)
a=icon('ui.guild_emblem.mountain');line(a,2,28,13,5,20,17,24,11,30,28,2,28);line(a,9,13,13,16,16,12)
a=icon('ui.empty_states.empty_inventory');line(a,7,11,25,11,28,29,4,29,7,11);line(a,11,11,11,6,14,3,18,3,21,6,21,11);line(a,12,21,20,21)
a=icon('ui.empty_states.empty_party');circle(a,16,9,5);line(a,6,28,7,21,12,18,20,18,25,21,26,28);line(a,3,8,6,8);line(a,26,8,29,8)
a=icon('ui.empty_states.no_quests');rect(a,6,4,20,25);line(a,11,3,11,8,21,8,21,3);line(a,11,15,21,15);line(a,11,21,17,21)
a=icon('ui.empty_states.no_market_orders');line(a,4,10,8,3,24,3,28,10,4,10);line(a,6,10,6,29,26,29,26,10);line(a,11,29,11,20,21,20,21,29)
a=icon('ui.empty_states.no_search_results');circle(a,13,13,9);line(a,20,20,29,29);line(a,9,13,17,13)
a=icon('ui.empty_states.guild_not_joined');shield(a);line(a,11,16,21,16);line(a,16,11,16,21)
a=icon('ui.empty_states.content_locked');rect(a,5,14,22,15);line(a,10,14,10,8,13,3,19,3,22,8,22,14);circle(a,16,21,2);line(a,16,23,16,26)
a=icon('ui.empty_states.offline_unavailable');line(a,5,22,2,18,4,13,9,12,11,5,18,3,24,8,24,13,29,15,30,19,27,23);line(a,4,4,28,28)
a=icon('ui.brand.monogram');shield(a);line(a,21,11,12,11,10,15,10,21,21,21,21,17,17,17)
a=icon('ui.brand.title_ornament');line(a,2,16,10,16,16,10,22,16,16,22,10,16);line(a,22,16,30,16);circle(a,16,16,1)
a=icon('ui.brand.loading_sigil');circle(a,16,16,10);line(a,16,2,18,6,16,10,14,6,16,2);line(a,30,16,26,18,22,16,26,14,30,16);line(a,16,30,14,26,16,22,18,26,16,30);line(a,2,16,6,14,10,16,6,18,2,16)
a=icon('ui.status.str');line(a,7,27,5,17,5,11,9,11,9,6,13,6,13,4,17,4,17,6,21,6,21,9,25,9,27,17,24,27,7,27);line(a,9,11,9,17,19,17,19,22);line(a,13,6,13,13);line(a,17,6,17,13);line(a,21,9,21,14)
a=icon('ui.status.dex');line(a,4,24,8,11,16,4,14,14,25,7,21,18,28,16,22,25,4,24);arrow(a,5,26,17,0)
a=icon('ui.status.int');line(a,16,3,27,13,16,29,5,13,16,3);line(a,5,13,27,13);line(a,16,3,12,13,16,29,20,13,16,3)
a=icon('ui.status.vit');line(a,16,28,4,16,3,10,6,5,11,4,16,9,21,4,26,5,29,10,28,16,16,28);line(a,7,16,12,16,14,12,17,21,20,16,25,16)
a=icon('ui.status.wis');line(a,3,7,10,5,16,9,22,5,29,7,29,27,22,25,16,29,10,25,3,27,3,7);line(a,16,9,16,29);line(a,7,12,12,11);line(a,7,17,12,16);line(a,20,12,25,11);line(a,20,17,25,16)
def svg(shapes):
    parts=[]
    for s in shapes:
        kind,*p=s
        if kind=='line':parts.append(f'<line x1="{p[0]}" y1="{p[1]}" x2="{p[2]}" y2="{p[3]}"/>')
        elif kind=='circle':parts.append(f'<circle cx="{p[0]}" cy="{p[1]}" r="{p[2]}"/>')
        else:parts.append(f'<rect x="{p[0]}" y="{p[1]}" width="{p[2]}" height="{p[3]}"/>')
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="64" height="64"><g fill="none" stroke="#d6b76f" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'+''.join(parts)+'</g></svg>'
for id,shapes in icons.items():(OUT/(id+'.svg')).write_text(svg(shapes),encoding='utf-8')
def lua(value):
    if isinstance(value,str):return json.dumps(value)
    if isinstance(value,(float,int)):return str(value)
    if isinstance(value,list):return '{'+','.join(lua(v) for v in value)+'}'
    return '{\n'+',\n'.join('['+lua(k)+']='+lua(v) for k,v in value.items())+'\n}'
native={key:[{'kind':shape[0],'points':shape[1:]} for shape in shapes] for key,shapes in icons.items()}
(ROOT/'src/shared/Data/UISymbols.luau').write_text('--!strict\n-- Original normalized32px geometry; no external asset IDs.\nexport type Primitive = {kind: string, points: {number}}\nlocal symbols: {[string]: {Primitive}} = '+lua(native)+'\nreturn symbols\n',encoding='utf-8')
(OUT/'symbols.json').write_text(json.dumps(icons,indent=2)+'\n',encoding='utf-8')
cards=''.join('<article>'+svg(s)+'<code>'+html.escape(i)+'</code></article>' for i,s in icons.items())
(OUT/'gallery.html').write_text('<!doctype html><html lang="en"><meta charset="utf-8"><title>Guildborne UI symbols</title><style>body{background:#101724;color:#eee5cf;font:16px system-ui;margin:32px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px}article{background:#1e293b;padding:20px;display:grid;gap:16px;place-items:center;border-radius:12px}code{font-size:12px}svg{width:64px;height:64px}</style><h1>Guildborne · '+str(len(icons))+' original UI symbols</h1><p>SVG sources and native Roblox geometry. Runtime bindings and device acceptance tracked separately.</p><main>'+cards+'</main></html>',encoding='utf-8')
assert len(icons)==58
print('UI_SYMBOLS',len(icons),'max primitives',max(map(len,icons.values())))

