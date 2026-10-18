"""Compile offline union triangles to flat native wedges in the existing factory."""
import json,math
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
data=json.loads((HERE/'ground-union.json').read_text());v=data['verticesXZ'];rows=[]
for ids in data['triangles']:
 t=[v[i] for i in ids];j=max(range(3),key=lambda k:math.dist(t[k],t[(k+1)%3]));b,c,a=t[j],t[(j+1)%3],t[(j+2)%3]
 length=math.dist(b,c);axis=[(c[k]-b[k])/length for k in range(2)];q=sum((a[k]-b[k])*axis[k] for k in range(2));f=[b[k]+q*axis[k] for k in range(2)]
 for e in (b,c):
  L=math.dist(f,e);H=math.dist(a,f);yaw=math.atan2((f[0]-e[0])/L,(f[1]-e[1])/L);sign=1 if (a[0]-f[0])*(-math.cos(yaw))+(a[1]-f[1])*math.sin(yaw)>=0 else -1
  rows.append([(a[0]+e[0])/2,(a[1]+e[1])/2,H,L,yaw,sign])
lines=[' -- One simplified polygon, triangulated offline: no overlapping ground top faces.', ' -- Recipe and measured footprint changes: production/world/novice-entry/ground-union.', ' stage="Landscape"',' local groundWedges={']
lines += ['  {'+','.join(format(n,'.15g') for n in row)+'},' for row in rows]
lines += [' }',' for i,w in ipairs(groundWedges)do','  local p=Instance.new("WedgePart")','  p.Name="Settlement_GroundUnion_"..i','  p.Size=V(.03,w[3],w[4])','  p.CFrame=CFrame.new(w[1],.03,w[2])*CFrame.Angles(0,w[5],0)*CFrame.Angles(0,0,w[6]*math.pi/2)','  p.Color=sand;p.Material=Enum.Material.Sand','  p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false','  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth','  p:SetAttribute("Stage",stage);p.Parent=model',' end','']
p=ROOT/'review/NoviceRoadKit.luau';s=p.read_text(encoding="utf-8");start=s.index(' local groundLayer=0') if ' local groundLayer=0' in s else s.index(' -- One simplified polygon, triangulated offline:');end=s.index(' -- Overlapping outer banks',start);p.write_bytes((s[:start]+'\n'.join(lines)+s[end:]).encode());print('WEDGES',len(rows))
