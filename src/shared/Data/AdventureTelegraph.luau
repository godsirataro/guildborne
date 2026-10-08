--!strict
-- Bounded native outline renderer for the server-authored regional footprint schema.
-- Caller owns timing/cancellation. Polygon boundaries conservatively enclose circular damage.
local V=Vector3.new
return function(parent:Instance,p:any):Folder
    local folder=Instance.new("Folder");folder.Name="AdventureTelegraph";folder.Parent=parent
    folder:SetAttribute("PatternName",p.name);folder:SetAttribute("Shape",p.shape)
    local color=Color3.fromRGB(245,156,62);local y=p.y+.09
    local function line(x1:number,z1:number,x2:number,z2:number)
        local a,b=V(x1,y,z1),V(x2,y,z2);local length=(b-a).Magnitude;if length<.001 then return end
        local part=Instance.new("Part");part.Name="WarningEdge";part.Size=V(.24,.08,length+.12)
        part.CFrame=CFrame.lookAt(a,b)*CFrame.new(0,0,-length/2);part.Color=color;part.Material=Enum.Material.Neon
        part.Transparency=.15;part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.CastShadow=false;part.Parent=folder
    end
    local function circle(radius:number,inner:boolean?)
        local count=32;local r=radius*(if inner then math.cos(math.pi/count) else 1/math.cos(math.pi/count))
        for i=0,count-1 do
            local a,b=i*2*math.pi/count,(i+1)*2*math.pi/count
            line(p.x+math.cos(a)*r,p.z+math.sin(a)*r,p.x+math.cos(b)*r,p.z+math.sin(b)*r)
        end
    end
    local function localPoint(forward:number,side:number):(number,number)
        return p.x+p.dx*forward-p.dz*side,p.z+p.dz*forward+p.dx*side
    end
    if p.shape=="Circle" then circle(p.radius)
    elseif p.shape=="Ring" then circle(p.radius);circle(p.innerRadius,true)
    elseif p.shape=="Line" then
        local ax,az=localPoint(0,-p.width/2);local bx,bz=localPoint(p.length,-p.width/2)
        local cx,cz=localPoint(p.length,p.width/2);local dx,dz=localPoint(0,p.width/2)
        line(ax,az,bx,bz);line(bx,bz,cx,cz);line(cx,cz,dx,dz);line(dx,dz,ax,az)
    elseif p.shape=="Cone" then
        local half=math.rad(p.halfAngle);local count=24;local radius=p.radius/math.cos(half/count)
        local lastX,lastZ=localPoint(math.cos(-half)*radius,math.sin(-half)*radius)
        line(p.x,p.z,lastX,lastZ)
        for i=1,count do
            local angle=-half+2*half*i/count;local x,z=localPoint(math.cos(angle)*radius,math.sin(angle)*radius)
            line(lastX,lastZ,x,z);lastX,lastZ=x,z
        end
        line(lastX,lastZ,p.x,p.z)
    end
    return folder
end
