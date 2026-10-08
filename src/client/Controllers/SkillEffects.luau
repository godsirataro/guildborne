--!strict
-- Original geometry-based spell choreography. Cosmetic, local and bounded.
local Tween=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Input=game:GetService("UserInputService")
local Config=require(game.ReplicatedStorage.Shared.Config.VFXConfig)
local PathVFX=require(game.ReplicatedStorage.Shared.Config.PathVFX)
local V=Vector3.new
return function()
	local count=0;local primaryCount=0;local criticalCount=0;local detailedUntil=0
	local lastCast=setmetatable({} :: {[Model]: number}, {__mode="k"})
	local function low(): boolean return workspace:GetAttribute(Config.QualityAttribute)=="Low" end
	local function reduced(): boolean return Input.TouchEnabled or low() end
	local colors=Config.Palette
	local white=Config.Core
	local function make(size: Vector3,cf: CFrame,color: Color3,shape: Enum.PartType,duration: number,goal: any,alpha: number?,bucket: string?): Part?
		local cap=if Input.TouchEnabled then Config.Budget.Touch else Config.Budget.Desktop
		if bucket=="Primary" then if primaryCount>=Config.Budget.Primary then return nil end;primaryCount+=1
		elseif bucket=="Telegraph" then if criticalCount>=Config.Budget.Telegraph then return nil end;criticalCount+=1
		else if count>=cap then return nil end;count+=1 end
		local p=Instance.new("Part");p.Name="GuildborneSkillEffect";p.Size=size;p.CFrame=cf;p.Shape=shape;p.Color=color;p.Material=if color==white then Enum.Material.Neon else Enum.Material.SmoothPlastic;p.Transparency=alpha or .22
		p:SetAttribute("VFXBucket",bucket or "Detail")
		p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=workspace
		Tween:Create(p,TweenInfo.new(duration,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play();Debris:AddItem(p,duration+.05)
		task.delay(duration+.05,function() if bucket=="Primary" then primaryCount=math.max(0,primaryCount-1) elseif bucket=="Telegraph" then criticalCount=math.max(0,criticalCount-1) else count=math.max(0,count-1) end end);return p
	end
	local function line(a: Vector3,b: Vector3,width: number,color: Color3,duration: number,bucket: string?)
		local length=(b-a).Magnitude;if length<.01 then return end
		make(V(width,width,length),CFrame.lookAt((a+b)/2,b),color,Enum.PartType.Block,duration,{Size=V(.02,.02,length),Transparency=1},nil,bucket)
	end
	local function arc(cf: CFrame,radius: number,color: Color3,start: number,span: number,duration: number,bucket: string?)
		local n=if bucket=="Telegraph" then 6 elseif reduced() then 8 else 12
		for i=1,n do
			local a=start+span*(i-1)/n;local b=start+span*i/n
			line(cf:PointToWorldSpace(V(math.cos(a)*radius,0,math.sin(a)*radius)),cf:PointToWorldSpace(V(math.cos(b)*radius,0,math.sin(b)*radius)),.09+math.sin(i/n*math.pi)*.17,color,duration,bucket)
		end
	end
	local function burst(at: Vector3,color: Color3,strong: boolean)
		make(V(.6,.6,.6),CFrame.new(at),white,Enum.PartType.Ball,.18,{Size=V(2,2,2)*(if strong then .85 else .4),Transparency=1})
		if strong then
			local anchor=make(V(.05,.05,.05),CFrame.new(at),color,Enum.PartType.Ball,.6,{Transparency=1},1)
			if anchor then
				local sparks=Instance.new("ParticleEmitter");sparks.Texture=Config.SparkTexture
				sparks.Color=ColorSequence.new(white,color);sparks.LightEmission=.45;sparks.Rate=0;sparks.Lifetime=NumberRange.new(.2,.5)
				sparks.Speed=NumberRange.new(7,14);sparks.Drag=8;sparks.SpreadAngle=Vector2.new(180,180)
				sparks.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.35),NumberSequenceKeypoint.new(1,0)})
				sparks.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.1),NumberSequenceKeypoint.new(1,1)})
				sparks.Parent=anchor;sparks:Emit(if reduced() then 4 else 8)
			end
		end
		for i=1,(if strong then 6 else 3) do
			local angle=i*2.399;local direction=V(math.cos(angle),.3+(i%3)*.25,math.sin(angle))
			make(V(.12,.12,.8),CFrame.lookAt(at,at+direction),color,Enum.PartType.Block,.35,{Position=at+direction*(if strong then 5 else 2),Transparency=1})
		end
	end
	local function missile(a: Vector3,b: Vector3,color: Color3,delayTime: number)
		local delta=b-a;if delta.Magnitude<.1 then return end
		local cf=CFrame.lookAt(a,b)
		local bolt=make(V(.12,.12,2),cf,color,Enum.PartType.Block,delayTime,{Position=b,Transparency=.7})
		if bolt then
			local x=Instance.new("Attachment");x.Position=V(.08,0,0);x.Parent=bolt
			local y=Instance.new("Attachment");y.Position=V(-.08,0,0);y.Parent=bolt
			local trail=Instance.new("Trail");trail.Name="GuildborneProjectileTrail";trail.Attachment0=x;trail.Attachment1=y
			trail.Lifetime=.1;trail.FaceCamera=true;trail.Color=ColorSequence.new(color);trail.Transparency=NumberSequence.new(.35,1);trail.LightEmission=.2;trail.Parent=bolt
		end
		make(V(.35,.35,.35),cf,white,Enum.PartType.Ball,delayTime,{Position=b,Transparency=1})
	end
	-- A travelling crescent uses only original Parts and built-in particles: no paid assets.
	local function swordWave(aim: CFrame,color: Color3,wide: boolean)
		local n=if reduced() then 7 else 10
		local radius=if wide then 4.6 else 3.5
		local plane=aim*CFrame.new(0,.4,-1.4)*CFrame.Angles(0,0,-.42)
		local travel=aim.LookVector*(if wide then 5 else 4)
		for i=1,n do
			local a=-1.2+(i-1)*2.4/n;local b=-1.2+i*2.4/n
			local start=plane:PointToWorldSpace(V(math.sin(a)*radius,math.cos(a)*radius-radius*.55,0))
			local finish=plane:PointToWorldSpace(V(math.sin(b)*radius,math.cos(b)*radius-radius*.55,0))
			local length=(finish-start).Magnitude;local cf=CFrame.lookAt((start+finish)/2,finish)
			local taper=math.sin((i-.5)/n*math.pi)
			make(V(.16+.32*taper,.12,length+.08),cf,white,Enum.PartType.Block,.28,
				{CFrame=cf+travel,Size=V(.02,.02,length*.7),Transparency=1},.04)
			make(V(.4+.65*taper,.18,length+.16),cf,color,Enum.PartType.Block,.34,
				{CFrame=cf+travel*1.12,Size=V(.04,.03,length),Transparency=1},.65)
		end
	end
	local function warriorCast(model: Model,aim: CFrame,target: Vector3,color: Color3,wide: boolean)
		local hand=model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
		local charge=if hand and hand:IsA("BasePart") then hand.Position else aim.Position+aim.RightVector
		make(V(.8,.8,.8),CFrame.new(charge),color,Enum.PartType.Ball,.1,{Size=V(.12,.12,.12),Transparency=.7})
		for i=1,3 do
			local a=i*math.pi*2/3;local p=charge+V(math.cos(a)*1.5,.5,math.sin(a)*1.5)
			make(V(.12,.12,.5),CFrame.lookAt(p,charge),color,Enum.PartType.Block,.1,{Position=charge,Transparency=1})
		end
		-- Release coincides with ActionPose's .10–.24 second swing.
		task.delay(.1,function()
			if not model:IsDescendantOf(workspace) then return end
			if hand and hand:IsA("BasePart") and not hand:FindFirstChild("GuildborneCastTrail") then
				local a=Instance.new("Attachment");a.Name="GuildborneTrailRoot";a.Position=V(0,-.6,0);a.Parent=hand
				local b=Instance.new("Attachment");b.Name="GuildborneTrailTip";b.Position=V(0,-2.8,0);b.Parent=hand
				local trail=Instance.new("Trail");trail.Name="GuildborneCastTrail";trail.Attachment0=a;trail.Attachment1=b
				trail.FaceCamera=true;trail.Lifetime=.18;trail.LightEmission=.45;trail.Color=ColorSequence.new(white,color)
				trail.WidthScale=NumberSequence.new(1,0);trail.Transparency=NumberSequence.new(.08,1);trail.Parent=hand
				task.delay(.18,function() if trail.Parent then trail.Enabled=false end end)
				Debris:AddItem(trail,.5);Debris:AddItem(a,.5);Debris:AddItem(b,.5)
			end
			swordWave(aim,color,wide)
		end)
		task.delay(.24,function()
			if not model:IsDescendantOf(workspace) then return end
			burst(target,color,true)
			-- Ground-level shock crescent leaves the target silhouette readable.
			arc(CFrame.new(target-V(0,2.4,0)),if wide then 4 else 2.5,color,0,math.pi*1.8,.35)
		end)
	end
	-- Delayed phrases remain cosmetic and stop spawning when their caster disappears.
	local function later(model: Model,seconds: number,callback: () -> ())
		task.delay(seconds,function() if model:IsDescendantOf(workspace) then callback() end end)
	end
	local function pulse(at: Vector3,color: Color3)
		local n=if reduced() then 6 else 8
		for i=1,n do
			local a=(i-1)*math.pi*2/n;local b=i*math.pi*2/n
			local start=at+V(math.cos(a),0,math.sin(a));local finish=at+V(math.cos(b),0,math.sin(b))
			local cf=CFrame.lookAt((start+finish)/2,finish);local outward=cf.Position-at
			make(V(.09,.09,(finish-start).Magnitude),cf,color,Enum.PartType.Block,.38,
				{CFrame=cf+outward*3,Size=V(.03,.03,(finish-start).Magnitude*4),Transparency=1})
		end
	end
	-- Three-object fallback retains a caster/target connection when detail is saturated.
	local function compact(model: Model,class: string,effect: string,aim: CFrame,target: Vector3,color: Color3)
		local source=aim.Position+V(0,.6,0)
		local length=(target-source).Magnitude
		if effect=="Heal" then
			local a=make(V(.04,.04,.04),CFrame.new(source),color,Enum.PartType.Ball,.48,{Transparency=1},1,"Primary")
			local b=make(V(.25,.25,.25),CFrame.new(target),white,Enum.PartType.Ball,.48,{Position=target+V(0,1.5,0),Transparency=1},.3,"Primary")
			if a and b then
				local x=Instance.new("Attachment");x.Parent=a;local y=Instance.new("Attachment");y.Parent=b
				local beam=Instance.new("Beam");beam.Attachment0=x;beam.Attachment1=y;beam.Width0=.08;beam.Width1=.12;beam.Color=ColorSequence.new(color);beam.Transparency=NumberSequence.new(.5);beam.FaceCamera=true;beam.Parent=a
			end
			make(V(.12,1.2,.12),CFrame.new(target),color,Enum.PartType.Block,.48,{Position=target+V(0,1.5,0),Transparency=1},.2,"Primary")
		elseif class=="Knight" then
			local shield=aim*CFrame.new(0,0,-1.7)
			make(V(1.8,2.3,.1),shield,color,Enum.PartType.Block,.4,{Size=V(2,2.6,.05),Transparency=1},.65,"Primary")
			make(V(.1,1.4,.1),shield,white,Enum.PartType.Block,.4,{Transparency=1},.3,"Primary")
			make(V(.15,.6,.15),CFrame.new(target+V(0,2.7,0)),color,Enum.PartType.Block,.4,{Position=target+V(0,3.1,0),Transparency=1},.2,"Primary")
		elseif class=="Warrior" then
			local cf=aim*CFrame.new(0,.3,-2)*CFrame.Angles(0,0,-.6)
			make(V(3.4,.16,.25),cf,color,Enum.PartType.Block,.22,{CFrame=cf+aim.LookVector*2,Size=V(1,.04,.08),Transparency=1},.2,"Primary")
			later(model,.18,function() make(V(.15,1.3,.15),CFrame.new(target)*CFrame.Angles(0,0,.7),white,Enum.PartType.Block,.18,{Size=V(.04,2,.04),Transparency=1},.2,"Primary") end)
		else
			if length>.1 then make(if class=="Archer" then V(.12,.12,2.4) else V(.85,.85,.85),CFrame.lookAt(source,target),color,if class=="Mage" then Enum.PartType.Ball else Enum.PartType.Block,.18,{Position=target,Transparency=.35},.15,"Primary") end
			later(model,.18,function()
				make(V(.3,.3,.3),CFrame.new(target),white,Enum.PartType.Ball,.18,{Size=V(.7,.7,.7),Transparency=1},.25,"Primary")
			end)
		end
	end
	local function classCast(model: Model,class: string,effect: string,aim: CFrame,target: Vector3,color: Color3): boolean
		local origin=aim.Position;local floor=CFrame.new(target-V(0,2.4,0))
		if class=="Mage" and (effect=="Magic" or effect=="Area") then
			-- A vertical casting seal contracts into a comet before the impact crown.
			arc(aim*CFrame.new(0,.5,-1.8)*CFrame.Angles(math.pi/2,0,0),1.7,color,0,math.pi*2,.22)
			make(V(.15,.15,.15),aim*CFrame.new(0,.5,-1.8),white,Enum.PartType.Ball,.12,{Size=V(.9,.9,.9),Transparency=.3})
			later(model,.12,function()
				missile(origin+V(0,.5,0),target,color,.18)
				local orb=make(V(1.55,1.55,1.55),CFrame.new(origin+V(0,.5,0)),color,Enum.PartType.Ball,.18,{Position=target,Size=V(1.1,1.1,1.1),Transparency=.18})
				if orb and effect=="Magic" then
					local embers=Instance.new("ParticleEmitter");embers.Texture=Config.FireTexture;embers.Rate=0;embers.Color=ColorSequence.new(Config.Core,Config.Fire);embers.LightEmission=.55
					embers.Lifetime=NumberRange.new(.16,.22);embers.LockedToPart=true;embers.Speed=NumberRange.new(0,.5);embers.Size=NumberSequence.new(1.6,.4);embers.Transparency=NumberSequence.new(.3,1);embers.SpreadAngle=Vector2.new(40,40);embers.Parent=orb;embers:Emit(if reduced() then 3 else 5)
				end
				if orb then local a=Instance.new("Attachment");a.Position=V(0,.3,0);a.Parent=orb;local b=Instance.new("Attachment");b.Position=V(0,-.3,0);b.Parent=orb
					local trail=Instance.new("Trail");trail.Attachment0=a;trail.Attachment1=b;trail.Color=ColorSequence.new(white,color);trail.Transparency=NumberSequence.new(.3,1);trail.Lifetime=.12;trail.FaceCamera=true;trail.Parent=orb end
			end)
			later(model,.3,function()
				burst(target,color,true);arc(floor,if effect=="Area" then 4.8 else 2.5,color,0,math.pi*2,.48)
				if effect=="Magic" then
					local anchor=make(V(.05,.05,.05),CFrame.new(target),color,Enum.PartType.Ball,.6,{Transparency=1},1)
					if anchor then
						local fire=Instance.new("ParticleEmitter");fire.Texture=Config.FireTexture;fire.Rate=0;fire.Color=ColorSequence.new(Config.Core,Config.Fire);fire.LightEmission=.5
						fire.Lifetime=NumberRange.new(.2,.35);fire.Speed=NumberRange.new(2,5);fire.Drag=6;fire.SpreadAngle=Vector2.new(90,90);fire.Size=NumberSequence.new(1.1,0);fire.Transparency=NumberSequence.new(.2,1);fire.Parent=anchor;fire:Emit(if reduced() then 4 else 6)
						local smoke=Instance.new("ParticleEmitter");smoke.Texture=Config.SmokeTexture;smoke.Rate=0;smoke.Color=ColorSequence.new(Color3.fromRGB(100,84,72));smoke.Lifetime=NumberRange.new(.3,.5);smoke.Speed=NumberRange.new(1,2);smoke.Size=NumberSequence.new(.5,1.2);smoke.Transparency=NumberSequence.new(.7,1);smoke.Parent=anchor;smoke:Emit(2)
					end
				end
				if effect=="Magic" then for i=1,3 do local offset=V((i-2)*.5,.3,(i%2)*.5)
					make(V(.3,.3,.3),CFrame.new(target+offset),Color3.fromRGB(92,76,64),Enum.PartType.Ball,.4,{Position=target+offset+V(0,1,0),Size=V(.7,.7,.7),Transparency=1},.72) end end
				if effect=="Area" then for i=1,4 do local a=i*math.pi/2;local p=target+V(math.cos(a)*3,-2,math.sin(a)*3)
					make(V(.3,.3,.3),CFrame.new(p)*CFrame.Angles(0,a,.2),color,Enum.PartType.Block,.4,{Position=p+V(0,2,0),Size=V(.15,4,.15),Transparency=1}) end end
			end);return true
		elseif class=="Archer" and (effect=="Physical" or effect=="Area") then
			local bow=aim*CFrame.new(-.6,.5,-1.4)
			arc(bow*CFrame.Angles(math.pi/2,0,math.pi/2),1.1,color,-1.2,2.4,.2)
			line(bow:PointToWorldSpace(V(0,-1,0)),bow:PointToWorldSpace(V(0,1,0)),.06,white,.18)
			later(model,.12,function() missile(origin+V(0,.5,0),target,color,.14) end)
			later(model,.26,function()
				burst(target,color,false)
				if effect=="Area" then
					for i=1,(if reduced() then 3 else 5) do
						local a=i*2.399;local p=target+V(math.cos(a)*2.3,0,math.sin(a)*2.3)
						later(model,(i-1)*.035,function() missile(p+V(-2,8,1),p,color,.16) end)
						later(model,.16+(i-1)*.035,function() burst(p,color,false) end)
					end
				else line(target-aim.LookVector*1.5,target+aim.LookVector*2.5,.2,white,.22) end
			end);return true
		elseif class=="Knight" and (effect=="Guard" or effect=="Taunt") then
			local cf=aim*CFrame.new(0,0,-2)
			local vertices={V(-1.4,1.7,0),V(1.4,1.7,0),V(1.7,0,0),V(0,-2.2,0),V(-1.7,0,0)}
			for i,p in ipairs(vertices) do line(cf:PointToWorldSpace(p),cf:PointToWorldSpace(vertices[i%#vertices+1]),.18,color,.6) end
			later(model,.12,function()
				make(V(2.6,3.2,.12),cf,color,Enum.PartType.Block,.5,{Size=V(3,3.8,.05),Transparency=1},.66)
				line(cf:PointToWorldSpace(V(0,1.2,0)),cf:PointToWorldSpace(V(0,-1.4,0)),.18,white,.5)
				line(cf:PointToWorldSpace(V(-.8,.4,0)),cf:PointToWorldSpace(V(.8,.4,0)),.18,white,.5)
				pulse(origin-V(0,2.5,0),Config.Gold)
			end)
			if effect=="Taunt" then later(model,.24,function()
				local crown=target+V(0,2.5,0);line(crown,crown+V(0,1,0),.2,color,.5)
				make(V(.25,.25,.25),CFrame.new(crown-V(0,.4,0)),white,Enum.PartType.Ball,.5,{Transparency=1})
			end) end;return true
		elseif class=="Priest" and effect=="Heal" then
			arc(CFrame.new(origin-V(0,2.5,0)),2,color,0,math.pi*2,.2)
			later(model,.12,function()
				arc(floor,3.4,color,0,math.pi*2,.7)
				for i=1,4 do local a=i*math.pi/2;local p=target+V(math.cos(a)*2,-2,math.sin(a)*2)
					make(V(.22,.8,.22),CFrame.new(p),color,Enum.PartType.Block,.65,{Position=p+V(0,4,0),Size=V(.05,1.5,.05),Transparency=1}) end
				line(target-V(0,.9,0),target+V(0,1.2,0),.22,white,.6);line(target-V(.8,0,0),target+V(.8,0,0),.22,white,.6)
			end)
			later(model,.32,function() arc(CFrame.new(target+V(0,2.5,0)),1.2,color,0,math.pi*2,.5) end);return true
		end
		return false
	end
	local pathCast=require(script.Parent.PathSkillEffects)(line,arc,missile,burst,later,reduced)
	return function(model: Model,telegraph: boolean?,bossImpact: boolean?)
		local root=model.PrimaryPart;local camera=workspace.CurrentCamera
		if not root or not camera or not model:IsDescendantOf(workspace) then return end
		local distance=(camera.CFrame.Position-root.Position).Magnitude
		if distance>(if telegraph then Config.Distance.Telegraph else Config.Distance.Cull) then return end
		local target=model:GetAttribute("ActionTargetPosition");if typeof(target)~="Vector3" then return end
		local origin=root.Position;local class=tostring(model:GetAttribute("ClassId"));local effect=tostring(model:GetAttribute("ActionEffect") or "Basic")
		local color=if class=="Mage" and effect=="Magic" then Config.Fire else colors[class] or Color3.fromRGB(178,102,75)
		local identity=PathVFX.resolve(model:GetAttribute("ActionAbilityId"),class,effect)
		if identity then color=identity.Color end
		local effectId=if telegraph then Config.TelegraphId else Config.resolve(class,effect)
		local ground=CFrame.new(origin-V(0,2.6,0));local impact=CFrame.new(target-V(0,2.4,0))
		local aim=if (target-origin).Magnitude>.1 then CFrame.lookAt(origin,target) else root.CFrame
		local skill=effect~="Basic";local duration=if skill then .55 else .26
		if bossImpact then
			local radius=(model:GetAttribute("TelegraphRadius") :: number?) or 5
			local at=V(target.X,(model:GetAttribute("TelegraphGroundY") :: number?) or target.Y-2.4,target.Z)
			make(V(.1,radius*2,radius*2),CFrame.new(at)*CFrame.Angles(0,0,math.pi/2),Config.Gold,Enum.PartType.Cylinder,.3,{Size=V(.04,radius*2.2,radius*2.2),Transparency=1},.5,"Primary")
			burst(at+V(0,.5,0),Config.Gold,not reduced())
			return
		end
		if telegraph then
			local stamp=model:GetAttribute("TelegraphAt")
			if typeof(stamp)~="number" then return end
			local remaining=(model:GetAttribute("TelegraphDuration") or 1.2)-(workspace:GetServerTimeNow()-stamp)
			if remaining<=0 then return end
			local radius=(model:GetAttribute("TelegraphRadius") :: number?) or 5
			-- A filled circle matches the server radius, unlike an inscribed polygon.
			local footprint=CFrame.new(target.X,(model:GetAttribute("TelegraphGroundY") :: number?) or target.Y-2.4,target.Z)
			local marker=make(V(.08,radius*2,radius*2),footprint*CFrame.Angles(0,0,math.pi/2),Color3.fromRGB(255,76,50),Enum.PartType.Cylinder,remaining,{Transparency=.35},.72,"Telegraph")
			if marker then
				marker.Name="GuildborneBossTelegraph"
				task.spawn(function()
					while marker.Parent and model:IsDescendantOf(workspace) and model:GetAttribute("TelegraphAt")==stamp do task.wait(.05) end
					marker:Destroy()
				end)
			end
			return
		end
		local now=os.clock();if lastCast[model] and now-lastCast[model]<.1 then return end;lastCast[model]=now
		local cap=if Input.TouchEnabled then Config.Budget.Touch else Config.Budget.Desktop
		if skill and (low() or distance>Config.Distance.Detail or now<detailedUntil or count>cap-12) then
			compact(model,class,effect,aim,target,color);return
		end
		if skill then detailedUntil=now+.75 end
		-- Stable semantic ID is intentionally presentation-only, never sent as a combat command.
		if effectId=="Mage.Fireball" then color=Config.Fire end
		if identity then pathCast(model,identity,aim,target);return end
		if skill and classCast(model,class,effect,aim,target,color) then return end
		if class=="Warrior" and skill and (effect=="Physical" or effect=="Area") then
			warriorCast(model,aim,target,color,effect=="Area");return
		end
		if effect=="Heal" then
			arc(impact,3.4,color,0,math.pi*2,.75)
			for i=1,4 do local a=i*math.pi/2;local p=target+V(math.cos(a)*2,-2,math.sin(a)*2)
				make(V(.13,1.3,.13),CFrame.new(p),color,Enum.PartType.Block,.8,{Position=p+V(0,5,0),Transparency=1}) end
			line(target-V(0,1.1,0),target+V(0,1.1,0),.22,white,.65);line(target-V(.8,0,0),target+V(.8,0,0),.22,white,.65)
		elseif effect=="Guard" or effect=="Taunt" then
			-- Faceted shield silhouette in front of the caster, with an oath cross.
			local cf=aim*CFrame.new(0,0,-2)
			local vertices={V(-1.4,1.6,0),V(1.4,1.6,0),V(1.6,0,0),V(.8,-1.5,0),V(0,-2.1,0),V(-.8,-1.5,0),V(-1.6,0,0)}
			for i,p in ipairs(vertices) do line(cf:PointToWorldSpace(p),cf:PointToWorldSpace(vertices[i%#vertices+1]),.2,color,.65) end
			line(cf:PointToWorldSpace(V(0,1.1,0)),cf:PointToWorldSpace(V(0,-1.3,0)),.15,white,.65)
			line(cf:PointToWorldSpace(V(-.8,.3,0)),cf:PointToWorldSpace(V(.8,.3,0)),.15,white,.65)
			arc(ground,4,color,0,math.pi*2,.6)
		elseif effect=="Drain" then
			local purple=Color3.fromRGB(204,91,255)
			arc(aim*CFrame.Angles(.5,0,.7),3,purple,math.pi*.1,math.pi*1.3,.4)
			for i=1,3 do local offset=V(0,(i-2)*.5,0);missile(target+offset,origin+offset,purple,.3+i*.05) end
			burst(target,purple,true)
		elseif effect=="Slow" then
			local ice=Color3.fromRGB(124,221,255);arc(impact,3,ice,0,math.pi*2,.8)
			for i=1,5 do local a=i*math.pi*.4;local p=target+V(math.cos(a)*2,-2,math.sin(a)*2)
				make(V(.2,.2,.2),CFrame.new(p)*CFrame.Angles(.15,a,.25),ice,Enum.PartType.Block,.45,{Size=V(.3,3,.3),Position=p+V(0,1.4,0),Transparency=1}) end
		elseif class=="Warrior" or class=="Knight" then
			-- Sweeping crescent, tapered core and a separate impact burst.
			local hand=model:FindFirstChild("RightHand") or model:FindFirstChild("Right Arm")
			if hand and hand:IsA("BasePart") and not hand:FindFirstChild("GuildborneCastTrail") then
				local a=Instance.new("Attachment");a.Position=V(0,-.6,0);a.Parent=hand
				local b=Instance.new("Attachment");b.Position=V(0,-2.8,0);b.Parent=hand
				local trail=Instance.new("Trail");trail.Name="GuildborneCastTrail";trail.Attachment0=a;trail.Attachment1=b
				trail.FaceCamera=true;trail.Lifetime=.16;trail.LightEmission=.45;trail.Color=ColorSequence.new(white,color)
				trail.Transparency=NumberSequence.new(.2,1);trail.Parent=hand
				task.delay(.32,function() trail.Enabled=false end)
				Debris:AddItem(trail,.6);Debris:AddItem(a,.6);Debris:AddItem(b,.6)
			end
			arc(aim*CFrame.Angles(.2,0,-.55),if skill then 4.2 else 2.8,color,-math.pi*.85,math.pi*1.35,duration)
			if effect=="Area" then later(model,.12,function() arc(ground+V(0,1.2,0),5,color,0,math.pi*1.8,.38) end) end
			burst(target,color,skill)
		elseif class=="Archer" then
			missile(origin+V(0,.7,0),target,color,.14)
			if effect=="Area" then for i=1,4 do local p=target+V((i%2)*3-1.5,0,math.floor(i/2)*2-2);missile(p+V(-3,9,1),p,color,.24+i*.03) end end
			later(model,.14,function() burst(target,color,skill) end)
		else
			-- Arcane casting sigil, bright comet core, then impact crown.
			if skill then
				arc(ground,2.8,color,0,math.pi*2,.5)
				for i=1,3 do local a=i*math.pi*2/3;line(origin+V(math.cos(a)*2.8,-2.5,math.sin(a)*2.8),origin+V(math.cos(a+2.1)*2.8,-2.5,math.sin(a+2.1)*2.8),.1,white,.5) end
			end
			missile(origin+V(0,1,0),target,color,.18)
			later(model,.18,function()
				burst(target,color,skill)
				if effect=="Area" then arc(impact,4.5,color,0,math.pi*2,.45);make(V(.25,1,.25),CFrame.new(target),white,Enum.PartType.Block,.35,{Size=V(.1,7,.1),Transparency=1}) end
			end)
		end
	end
end
