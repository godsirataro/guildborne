--!strict
-- Native contact substitute on the existing CityCharacterKit. No mesh/animation IDs.
local M={}
local V=Vector3.new
local STRIKE_HAND=V(1.05,2.04,-.28)
local function part(parent:Instance,name:string,size:Vector3,cf:CFrame,color:Color3,root:BasePart):Part
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Material=Enum.Material.SmoothPlastic;p.Anchored=false;p.Massless=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 p:SetAttribute("AssetStatus","NATIVE_CONTACT_SUBSTITUTE_NOT_IMPORTED_ART");p.Parent=parent
 local w=Instance.new("WeldConstraint");w.Part0=root;w.Part1=p;w.Parent=p;return p
end
function M.attach(model:Model):boolean
 if model:GetAttribute("NpcId")~="smith_borin" or not model.PrimaryPart then return false end
 if model:FindFirstChild("BorinWorkstation") then return true end
 local head=model:FindFirstChild("HammerHead")
 local hand=model:FindFirstChild("RightHand",true)
 local skeleton=model:FindFirstChild("Skeleton")
 local bone=skeleton and skeleton:FindFirstChild("RightHand")
 if not head or not head:IsA("BasePart") or not hand or not bone or not bone:IsA("BasePart") then return false end
 local root=model.PrimaryPart
 local point=bone.CFrame:PointToObjectSpace(head.CFrame:PointToWorldSpace(V(0,-head.Size.Y/2,0)))
 local station=Instance.new("Model");station.Name="BorinWorkstation";station:SetAttribute("ReviewStatus","PROCEDURAL_CONTACT_ADAPTER_FIT_PENDING");station.Parent=model
 local contact=root.CFrame*(CFrame.new(STRIKE_HAND+point))
 local block=part(station,"Workpiece",V(.85,.16,.62),contact*CFrame.new(0,-.08,0),Color3.fromRGB(190,92,49),root)
 part(station,"AnvilFace",V(1.2,.18,.9),contact*CFrame.new(0,-.25,0),Color3.fromRGB(89,99,110),root)
 part(station,"AnvilStand",V(.75,1.2,.65),contact*CFrame.new(0,-.94,0),Color3.fromRGB(105,67,44),root)
 local target=Instance.new("Attachment");target.Name="BorinContactTarget";target.Position=V(0,.08,0);target.Parent=block
 local tip=Instance.new("Attachment");tip.Name="BorinHammerContact";tip.Position=V(0,-head.Size.Y/2,0);tip.Parent=head
 local flash=Instance.new("PointLight");flash.Name="BorinContactFlash";flash.Enabled=false;flash.Brightness=1.5;flash.Range=4;flash.Color=Color3.fromRGB(255,185,98);flash.Parent=block
 model:SetAttribute("BorinPresentation","NATIVE_CONTACT_SUBSTITUTE_NOT_IMPORTED_ART")
 return true
end
local function rotation(from:Vector3,to:Vector3):CFrame
 local a,b=from.Unit,to.Unit;local axis=a:Cross(b);local cosine=math.clamp(a:Dot(b),-1,1)
 if axis.Magnitude<1e-6 then return CFrame.identity end
 return CFrame.fromAxisAngle(axis.Unit,math.acos(cosine))
end
function M.apply(model:Model,motors:{[Motor6D]:CFrame},sample:any):boolean
 local byName:{[string]:Motor6D}={}
 for motor,base in pairs(motors) do if motor.Parent then motor.C0=base;byName[motor.Name]=motor end end
 local station=model:FindFirstChild("BorinWorkstation")
 local flash=station and station:FindFirstChild("BorinContactFlash",true)
 if flash and flash:IsA("PointLight") then flash.Enabled=false end
 if sample.weight<=0 then return false end
 local torso,upper,lower,hand=byName.UpperTorso,byName.RightUpperArm,byName.RightLowerArm,byName.RightHand
 local pelvis=byName.LowerTorso
 if not torso or not upper or not lower or not hand or not pelvis then return false end
 local torsoBind=motors[pelvis]*pelvis.C1:Inverse()*motors[torso]*torso.C1:Inverse()
 local upperBind=torsoBind*motors[upper]*upper.C1:Inverse()
 local lowerBind=upperBind*motors[lower]*lower.C1:Inverse()
 local handBind=lowerBind*motors[hand]*hand.C1:Inverse()
 local target=handBind.Position:Lerp(STRIKE_HAND+V(.035*sample.lift,.38*sample.lift,0),sample.weight)
 local shoulder=upperBind.Position;local delta=target-shoulder
 local l1=(lowerBind.Position-shoulder).Magnitude;local l2=(handBind.Position-lowerBind.Position).Magnitude
 local distance=delta.Magnitude
 if distance<1e-5 or distance>=l1+l2 or distance<=math.abs(l1-l2) then return false end
 local direction=delta.Unit;local side=V(1,0,0)-direction*direction.X
 if side.Magnitude<1e-5 then return false end
 local along=(l1*l1-l2*l2+distance*distance)/(2*distance)
 local elbow=shoulder+direction*along+side.Unit*math.sqrt(math.max(0,l1*l1-along*along))
 local desiredUpper=CFrame.new(shoulder)*rotation(lowerBind.Position-shoulder,elbow-shoulder)
 local desiredLower=CFrame.new(elbow)*rotation(handBind.Position-lowerBind.Position,target-elbow)
 local desiredHand=CFrame.new(target)*CFrame.Angles(-.35*sample.lift*sample.weight,0,0)
 upper.C0=torsoBind:ToObjectSpace(desiredUpper)*upper.C1
 lower.C0=desiredUpper:ToObjectSpace(desiredLower)*lower.C1
 hand.C0=desiredLower:ToObjectSpace(desiredHand)*hand.C1
 -- This certifies only adapter math; actual spawned contact is a separate Studio probe.
 if sample.contact and flash and flash:IsA("PointLight") then flash.Enabled=true end
 return sample.contact==true
end
return M
