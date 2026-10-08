--!strict
-- Owner-online visits in this server. No cross-server discovery or shared building.
local Players=game:GetService("Players")
local Layout=require(game.ReplicatedStorage.Shared.Config.GuildIslandLayout)
local makeAccess=require(game.ReplicatedStorage.Shared.Data.IslandAccess)
local identitySummary=require(game.ReplicatedStorage.Shared.Data.GuildIdentitySummary)
local V=Vector3.new
return function(plots:any,travel:any,friendLookup:((Player,Player)->boolean)?,portals:{BasePart}?)
    local access=makeAccess({maxVisitors=8,ticketSeconds=5})
    local entries:{[Player]:BasePart}={};local visiting:{[Player]:Player}={}
    local identities:{[Player]:any}={}
    local pending:{[Player]:boolean}={};local cooldown:{[Player]:number}={};local activeLookups=0
    local S={}
    local function problem(player:Player,code:string)
        player:SetAttribute("IslandVisitProblem",code);player:SetAttribute("IslandVisitNoticeAt",workspace:GetServerTimeNow())
    end
    local function home(player:Player,reason:string)
        access.leave(player.UserId);visiting[player]=nil;player:SetAttribute("VisitingIslandOwner",nil)
        travel.Travel(player,"Guild");problem(player,reason)
    end
    local function eject(ids:{number},reason:string)
        for _,id in ipairs(ids) do local player=Players:GetPlayerByUserId(id);if player then home(player,reason) end end
    end
    local function context(visitor:Player,owner:Player,friend:boolean):any
        local character=visitor.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
        local humanoid=character and character:FindFirstChildOfClass("Humanoid");local plot=plots[visitor]
        local entry:BasePart?=entries[owner]
        local near=root~=nil and root:IsA("BasePart") and entry~=nil and (root.Position-entry.Position).Magnitude<=14
        if root and root:IsA("BasePart") then for _,portal in ipairs(portals or {}) do if portal.Parent and (root.Position-portal.Position).Magnitude<=14 then near=true;break end end end
        return {alive=humanoid~=nil and humanoid.Health>0 and character~=nil and (character:GetAttribute("CombatHealth") or 1)>0,
            inCombat=plot~=nil and plot.model:GetAttribute("InCombat")==true,inTower=plot~=nil and plot.model:GetAttribute("TowerState")~=nil,
            nearPortal=near,friend=friend}
    end
    local function landing(owner:Player):Vector3?
        local plot=plots[owner];if not plot then return nil end
        local target=plot.origin+V(64,5,4)
        local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={plot.model};ray.RespectCanCollide=true
        local hit=workspace:Raycast(target+V(0,8,0),V(0,-20,0),ray)
        if not hit or math.abs(hit.Position.Y-plot.origin.Y)>1 then return nil end
        local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={plot.model};overlap.RespectCanCollide=true
        if #workspace:GetPartBoundsInBox(CFrame.new(target),V(4,5,4),overlap)>0 then return nil end
        return target
    end
    function S.enter(visitor:Player,owner:Player):string
        if pending[visitor] or (cooldown[visitor] or 0)>os.clock() then return "VisitBusy" end
        cooldown[visitor]=os.clock()+2
        local ownState=access.describe(visitor.UserId)
        if not ownState or not ownState.ready then problem(visitor,"IslandUnavailable");return "IslandUnavailable" end
        local initial=context(visitor,owner,false)
        if not initial.nearPortal then problem(visitor,"VisitStation");return "VisitStation" end
        local info=access.describe(owner.UserId);if not info or not info.ready then problem(visitor,"IslandUnavailable");return "IslandUnavailable" end
        local friend=false
        if visitor~=owner and info.mode=="Friends" then
            if activeLookups>=4 then problem(visitor,"VisitBusy");return "VisitBusy" end
            pending[visitor]=true;activeLookups+=1
            local ok,result=pcall(function()return if friendLookup then friendLookup(visitor,owner) else visitor:IsFriendsWithAsync(owner.UserId)end)
            activeLookups-=1;pending[visitor]=nil;friend=ok and result==true
            if not ok then problem(visitor,"FriendshipUnavailable");return "FriendshipUnavailable" end
        end
        if visitor.Parent~=Players or owner.Parent~=Players then return "IslandUnavailable" end
        local current=access.describe(visitor.UserId)
        if not current or not current.ready then problem(visitor,"IslandUnavailable");return "IslandUnavailable" end
        local state=context(visitor,owner,friend)
        local ticket,reason=access.request(visitor.UserId,owner.UserId,state,os.clock())
        if not ticket then problem(visitor,reason);return reason end
        local target=landing(owner);state.destinationClear=target~=nil
        local ok,code=access.commit(ticket,state,os.clock());if not ok or not target then problem(visitor,code);return code end
        local character=visitor.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
        if not character or not root or not root:IsA("BasePart") then access.leave(visitor.UserId);return "ActorNotReady" end
        if not travel.Visit(visitor,target) then access.leave(visitor.UserId);problem(visitor,"TravelUnavailable");return "TravelUnavailable" end
        if visitor~=owner then visiting[visitor]=owner;visitor:SetAttribute("VisitingIslandOwner",owner.UserId)
        else visiting[visitor]=nil;visitor:SetAttribute("VisitingIslandOwner",nil) end
        problem(visitor,"VisitStarted")
        return "OK"
    end
    function S.add(owner:Player,entry:BasePart)
        entries[owner]=entry;access.register(owner.UserId);access.ready(owner.UserId,false)
        local prompt=Instance.new("ProximityPrompt");prompt.Name="VisitIsland";prompt.ActionText="Visit island / เยี่ยมเกาะ"
        prompt.ObjectText=owner.DisplayName;prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt.Parent=entry
        prompt.Triggered:Connect(function(visitor)S.enter(visitor,owner)end)
    end
    function S.update(owner:Player,data:any,active:boolean)
        identities[owner]=if active then identitySummary.project(data)else nil
        local mode=data.guildLand and data.guildLand.accessMode or "Private"
        local _,_,removed=access.policy(owner.UserId,mode);eject(removed,"IslandChanged")
        eject(access.ready(owner.UserId,active),"IslandUnavailable")
        local plot=plots[owner];if plot then plot.model:SetAttribute("IslandAccess",mode) end
    end
    function S.remove(owner:Player)
        identities[owner]=nil
        eject(access.remove(owner.UserId),"OwnerLeft");entries[owner]=nil;visiting[owner]=nil;pending[owner]=nil;cooldown[owner]=nil
    end
    function S.kick(owner:Player,visitor:Player):(boolean,string)
        local ok,reason=access.kick(owner.UserId,visitor.UserId);if ok then home(visitor,"VisitBlocked") end;return ok,reason
    end
    function S.roster(owner:Player):{any}
        local result={}
        for visitor,target in pairs(visiting) do
            if target==owner and visitor.Parent==Players and access.contains(visitor.UserId,owner.UserId) then
                table.insert(result,{visitorId=tostring(visitor.UserId),name=visitor.Name,displayName=visitor.DisplayName})
            end
        end
        table.sort(result,function(a,b)return a.visitorId<b.visitorId end)
        return result
    end
    function S.directory(viewer:Player):{any}
        local result={}
        for owner in pairs(entries) do
            local info=access.describe(owner.UserId)
            if info and info.ready and (owner==viewer or info.mode~="Private") then
                local identity=identities[owner]or {}
                table.insert(result,{ownerId=tostring(owner.UserId),name=owner.Name,displayName=owner.DisplayName,mode=info.mode,visitors=info.visitors,capacity=info.capacity,hallLevel=identity.hallLevel,crestId=identity.crestId,mottoId=identity.mottoId})
            end
        end
        table.sort(result,function(a,b)return a.ownerId<b.ownerId end)
        return result
    end
    local elapsed=0
    local heartbeat=game:GetService("RunService").Heartbeat:Connect(function(dt)
        elapsed+=dt;if elapsed<.5 then return end;elapsed=0
        for visitor in pairs(plots) do
            local character=visitor.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
            if not root or not root:IsA("BasePart") then continue end
            local present:Player?=nil
            for owner,plot in pairs(plots) do
                if visitor==owner then continue end
                local point=root.Position-plot.origin;local b=Layout.Bounds
                if point.X>=b.minX and point.X<=b.maxX and point.Z>=b.minZ and point.Z<=b.maxZ and point.Y>=-12 and point.Y<=40 then
                    present=owner
                    if not access.contains(visitor.UserId,owner.UserId) then home(visitor,"IslandAccessDenied") end
                    break
                end
            end
            if not present and visiting[visitor] then access.leave(visitor.UserId);visiting[visitor]=nil;visitor:SetAttribute("VisitingIslandOwner",nil) end
        end
    end)
    function S.destroy()
        heartbeat:Disconnect()
        for owner in pairs(entries) do S.remove(owner) end
    end
    return S
end
