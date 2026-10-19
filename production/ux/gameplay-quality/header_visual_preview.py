"""Execute actual header source in GUI mock and render a labelled local approximation.

Pillow/Tahoma is not Roblox text shaping, gradient composition, or native acceptance.
The JSON dump is the authoritative source-property evidence; PNGs are review aids.
"""
from pathlib import Path
import importlib.util, json, subprocess, tempfile, hashlib, math
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'assets/production/ui-slice/native-header-v10'
SPEC = importlib.util.spec_from_file_location('gui_runner', ROOT/'tests/gui/run.py')
runner = importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(runner)
CASES = [(1210, 740, 'en', 'Guild menu', '150'), (1920, 1080, 'en', 'Guild menu', '9999999999999999'),
         (390, 844, 'en', 'Guild menu', '9999999999999999'), (390, 844, 'th', 'เมนูกิลด์', '9999999999999999'),
         (320, 640, 'th', 'สำรวจ', '9999999999999999'), (844, 390, 'th', 'เมนูกิลด์', '9999999999999999')]

def capture():
    code = 'local Runtime=(function()\n'+(ROOT/'tests/gui/runtime.luau').read_text(encoding='utf-8')+'\nend)()\n'
    code += '''local env=Runtime.environment();setmetatable(env,{__index=getfenv()})
local tree,modules,cache={},{},{}
local function node(path) local c=tree for p in string.gmatch(path,"[^/]+") do if not c[p] then c[p]={Parent=c} end c=c[p] end return c end
'''
    for path in runner.MODULES:
        code += 'modules[node('+runner.quote(path.removesuffix('.luau'))+')]='+runner.quote((ROOT/path).read_text(encoding='utf-8'))+'\n'
    code += '''env.game={ReplicatedStorage={Shared=node("src/shared")}}
env.require=function(target)
 if cache[target] then return cache[target] end
 local fn=assert(loadstring(assert(modules[target])));setfenv(fn,setmetatable({script=target},{__index=env}))
 cache[target]=fn();return cache[target]
end
local function encode(v)
 if type(v)=="string" then return string.format("%q",v) end
 if type(v)=="number" or type(v)=="boolean" then return tostring(v) end
 local r={} for k,x in pairs(v) do if type(x)~="function" then table.insert(r,encode(tostring(k))..":"..encode(x)) end end
 return "{"..table.concat(r,",").."}"
end
local keys={"ClassName","Name","Size","Position","AnchorPoint","Rotation","Visible","BackgroundColor3","BackgroundTransparency","Text","TextSize","TextColor3","TextScaled","TextWrapped","TextXAlignment","Font","Color","Thickness","Transparency","MinTextSize","MaxTextSize","PaddingLeft","PaddingRight","CornerRadius"}
local function dump(n)
 local r={children={}} for _,k in ipairs(keys) do if n[k]~=nil then r[k]=n[k] end end
 for i,c in ipairs(n:GetChildren()) do r.children[tostring(i)]=dump(c) end return r
end
local Header=env.require(node("src/client/UI/Components/ResourceHeader"))
local Layout=env.require(node("src/shared/Data/CombatHudLayout"))
local Localization=env.require(node("src/shared/Config/Localization"))
'''
    # Literal strings are test-only presentation fixtures, never profile mutation.
    for i,(w,h,lang,menu,value) in enumerate(CASES):
        number = '150' if value=='150' else '9007199254740991'
        menukey='Explore' if menu=='สำรวจ' else 'Guild menu'
        code += f'do local gui=env.Instance.new("ScreenGui");gui.AbsoluteSize={{X={w},Y={h}}};local h=Header.new(gui);h.update(Localization.translate("{lang}","{{gold}}",{{gold={number}}}),Localization.translate("{lang}","Gold · Hall Lv{{level}}",{{level=20}}),"Loading");h.button.Text=Localization.translate("{lang}",{runner.quote(menukey)});print(encode({{case={i},tree=dump(gui),layout=Layout({w},{h})}}));h.destroy() end\n'
    with tempfile.TemporaryDirectory() as folder:
        entry=Path(folder)/'header.luau'; entry.write_text(code,encoding='utf-8')
        result=subprocess.run([str(ROOT/'.tools/luau/luau.exe'),str(entry)],capture_output=True,text=True,encoding='utf-8',cwd=ROOT)
        if result.returncode: raise RuntimeError(result.stdout+result.stderr)
        return [json.loads(line) for line in result.stdout.splitlines()]

def rgb(v,default=(220,183,107)):
    return tuple(round(v[k]*255) for k in ('R','G','B')) if v else default

def font(size): return ImageFont.truetype('C:/Windows/Fonts/tahoma.ttf',size)
def children(n): return list(n.get('children',{}).values())
def draw_node(im,n,parent):
    if n.get('Visible') is False: return
    if n['ClassName'] not in ('Frame','TextButton','TextLabel','ScreenGui'): return
    px,py,pw,ph=parent
    if n['ClassName']=='ScreenGui': x,y,w,h=parent
    else:
        s=n.get('Size',{});p=n.get('Position',{});a=n.get('AnchorPoint',{})
        w=s.get('1',0)*pw+s.get('2',100);h=s.get('3',0)*ph+s.get('4',100)
        x=px+p.get('1',0)*pw+p.get('2',0)-a.get('X',0)*w;y=py+p.get('3',0)*ph+p.get('4',0)-a.get('Y',0)*h
    if w<=0 or h<=0:return
    d=ImageDraw.Draw(im);box=(x,y,x+w,y+h)
    kids=children(n)
    if n.get('BackgroundTransparency',0)<1 and n['ClassName']!='ScreenGui':
        fill=rgb(n.get('BackgroundColor3'),(163,162,165))
        rounded=any(c['ClassName']=='UICorner' and c.get('CornerRadius',{}).get('Scale')==1 for c in kids)
        angle=n.get('Rotation',0)
        if angle:
            theta=math.radians(angle); cx=x+w/2;cy=y+h/2
            points=[(cx+dx*math.cos(theta)-dy*math.sin(theta),cy+dx*math.sin(theta)+dy*math.cos(theta)) for dx,dy in [(-w/2,-h/2),(w/2,-h/2),(w/2,h/2),(-w/2,h/2)]]
            d.polygon(points,fill=fill)
        elif rounded:d.ellipse(box,fill=fill)
        else:
            d.rectangle(box,fill=fill)
            gradient=next((c for c in kids if c['ClassName']=='UIGradient'),None)
            if gradient:
                end=rgb(gradient.get('Color',{}).get('2'),(255,255,255))
                for row in range(int(h)):
                    t=row/max(h-1,1);d.line((x,y+row,x+w,y+row),fill=tuple(round(v*(1-t+t*e/255)) for v,e in zip(fill,end)))
    for c in kids:
        if c['ClassName']=='UIStroke':
            stroke=d.ellipse if any(k['ClassName']=='UICorner' and k.get('CornerRadius',{}).get('Scale')==1 for k in kids) else d.rectangle
            stroke(box,outline=rgb(c.get('Color')),width=max(1,round(c.get('Thickness',1))))
    # Parent-rotated ornament children use exact local coordinates but approximate rotation.
    if n.get('Rotation',0) and n.get('BackgroundTransparency')==1 and kids:
        layer=Image.new('RGBA',im.size)
        for c in kids: draw_node(layer,c,(x,y,w,h))
        layer=layer.rotate(-n['Rotation'],center=(x+w/2,y+h/2),resample=Image.Resampling.BICUBIC)
        im.alpha_composite(layer)
    else:
        for c in kids:draw_node(im,c,(x,y,w,h))
    if n.get('Text'):
        pad=next((c for c in kids if c['ClassName']=='UIPadding'),{})
        left=pad.get('PaddingLeft',{}).get('Offset',0);right=pad.get('PaddingRight',{}).get('Offset',0)
        width=w-left-right;size=n.get('TextSize',14)
        constraint=next((c for c in kids if c['ClassName']=='UITextSizeConstraint'),{})
        if n.get('TextScaled'):
            size=constraint.get('MaxTextSize',size)
            while size>constraint.get('MinTextSize',1) and d.textlength(n['Text'],font=font(size))>width:size-=1
        lines=[n['Text']]
        if n.get('TextWrapped') and d.textlength(n['Text'],font=font(size))>width:
            lines=[];line=''
            for word in n['Text'].split(' '):
                trial=(line+' '+word).strip()
                if line and d.textlength(trial,font=font(size))>width:lines.append(line);line=word
                else:line=trial
            lines.append(line)
        for i,line in enumerate(lines):
            tx=x+left if n.get('TextXAlignment')=='TextXAlignment.Left' else x+left+(width-d.textlength(line,font=font(size)))/2
            d.text((tx,y+h/2+(i-(len(lines)-1)/2)*(size+2)),line,font=font(size),fill=rgb(n.get('TextColor3')),anchor='lm')

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    captures=capture()
    (OUT/'source-properties.json').write_text(json.dumps(captures,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    for item,(w,h,lang,menu,value) in zip(captures,CASES):
        im=Image.new('RGBA',(w,h),(35,44,50,255));d=ImageDraw.Draw(im)
        for name in ('rosterRect','mapRect','trackerRect','padRect','ordersRect'):
            r=item['layout'][name];rect=(r['x'],r['y'],r['x']+r['w'],r['y']+r['h'])
            d.rectangle(rect,outline=(111,136,149),width=1);d.text((r['x']+3,r['y']+4),name.removesuffix('Rect'),font=font(10),fill=(168,186,196))
        draw_node(im,item['tree'],(0,0,w,h))
        d=ImageDraw.Draw(im);d.text((8,h-36),'LOCAL APPROXIMATION / NOT STUDIO',font=font(11),fill=(245,236,216))
        d.text((8,h-20),'Test values; reserved HUD boxes only',font=font(10),fill=(190,197,202))
        name=f'{w}x{h}-{lang}'
        im.convert('RGB').save(OUT/f'{name}.png')
        top=im.crop((0,0,w,60));detail=Image.new('RGB',(w,90),(35,44,50));detail.paste(top,(0,26))
        ImageDraw.Draw(detail).text((8,1),'LOCAL APPROXIMATION — NOT STUDIO',font=font(10),fill=(245,236,216))
        ImageDraw.Draw(detail).text((8,13),'Tahoma replaces GothamMedium',font=font(9),fill=(190,197,202))
        detail.save(OUT/f'{name}-header.png')
    hashes={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in runner.MODULES}
    (OUT/'source-hashes.json').write_text(json.dumps(hashes,indent=2)+'\n')
    (OUT/'README.md').write_text('''# Native header v10 local visual review

These PNGs execute ResourceHeader, GuildborneButton, RegalOrnament and CombatHudLayout source through the existing Luau GUI simulation, then approximate their properties in Pillow. JSON stores captured source properties and rectangles; hashes identify inputs. No screenshot or game-world pixels are fabricated.

Tahoma substitutes GothamMedium; text fitting/wrapping, rotation, strokes, gradients and stacking are approximate. HUD reserved rectangles are labelled wireframes, not actual roster/map/tracker rendering. Six views include 1210/1920 desktop, 390/320 portrait and 844 landscape, EN/TH, Guild/Explore and unabridged 16-digit fixture values. Gold, captions and menu labels come through actual Localization.translate, with numeric 9007199254740991 and Hall20 stress fixtures. These values are presentation-only, not earned profile claims. Native text/overlap/input/device acceptance remains pending controller tests.

Before reference: `C:/Work/MySelf/Guildborne-controller/production/integration/quality-slice/native-earned-journey-20261020/earnedCampFinalCapture.png` (unchanged actual Studio screenshot). After source approximation is deliberately kept separate from that screenshot.

Reproduce: `python production/ux/gameplay-quality/header_visual_preview.py`.
''',encoding='utf-8')
    print('Captured and rendered',len(captures),'actual-source header cases; NOT Studio acceptance')

if __name__=='__main__':main()
