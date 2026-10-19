--!strict
-- Pure proposal projection. Consumers retain existing prompt, pose and reward owners.
-- A phase never moves/despawns a named actor; all anchors remain available for quests.
local function finite(n:any):boolean return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function dense(value:any,count:number):boolean
    if type(value)~="table" then return false end
    local found=0
    for key in pairs(value) do
        if type(key)~="number" or not finite(key) or key%1~=0 or key<1 or key>count then return false end
        found+=1
    end
    if found~=count then return false end
    for index=1,count do if rawget(value,index)==nil then return false end end
    return true
end
return function(config:any,entries:any,catalog:any):(any?,string?)
    if type(config)~="table" or type(entries)~="table" or type(catalog)~="table" or type(catalog.Journal)~="table"
        or config.Version~=1 or not dense(config.Ids,16) or not dense(config.Phases,4) then return nil,"InvalidDefinitions" end
    for _,key in ipairs({"DaySeconds","RecoverySeconds","NearEnter","NearExit","FarEnter","FarExit"}) do
        if not finite(config[key]) or config[key]<=0 then return nil,"InvalidDefinitions" end
    end
    if config.DaySeconds~=86400 or config.RecoverySeconds>5 or not (config.NearEnter<config.NearExit and config.NearExit<config.FarExit and config.FarExit<config.FarEnter) then return nil,"InvalidDefinitions" end
    local phases={}
    local last=-1
    for i,raw in ipairs(config.Phases) do
        if type(raw)~="table" then return nil,"InvalidDefinitions" end
        local p:any=raw
        if not finite(p.start) or p.start<=last or p.start>=config.DaySeconds or (i==1 and p.start~=0)
            or not ({Work=true,Rest=true,Social=true})[p.activity] then return nil,"InvalidDefinitions" end
        phases[i]={start=p.start,activity=p.activity};last=p.start
    end
    local records:any={};local aliases:any={};local routines:any={}
    for _,id in ipairs(config.Ids) do
        local e=entries[id]
        if type(id)~="string" or records[id] or type(e)~="table" or type(e.name)~="string" or e.name=="" or not finite(e.x) or not finite(e.z) then return nil,"InvalidIdentityOrAnchor" end
        records[id]={id=id,name=e.name,x=e.x,z=e.z,hooks={}}
    end
    if config.Routines~=nil then
        if type(config.Routines)~="table" then return nil,"InvalidRoutines" end
        local count=0
        for id,r in pairs(config.Routines) do
            if not records[id] or type(r)~="table" or not finite(r.work) or not finite(r.pause) or not finite(r.offset)
                or r.work<8 or r.work>120 or r.pause<2 or r.pause>30 or r.offset<0 or r.offset>=r.work+r.pause then
                return nil,"InvalidRoutines"
            end
            for key in pairs(r) do if key~="work" and key~="pause" and key~="offset" then return nil,"InvalidRoutines" end end
            routines[id]={work=r.work,pause=r.pause,offset=r.offset};count+=1
        end
        if count~=#config.Ids then return nil,"InvalidRoutines" end
    end
    for id,r in pairs(records) do
        if aliases[r.name] or (records[r.name] and r.name~=id) then return nil,"DuplicateAlias" end
        aliases[r.name]=id
    end
    for questId,quest in pairs(catalog.Journal) do
        if type(questId)~="string" or type(quest)~="table" then return nil,"InvalidJournal" end
        local definition:any=quest
        local id=aliases[definition.NPC]
        if id then table.insert(records[id].hooks,questId) end
    end
    for _,r in pairs(records) do table.sort(r.hooks);table.freeze(r.hooks);table.freeze(r) end
    -- Copy configuration so a caller cannot change this projection after validation.
    local day,recovery=config.DaySeconds,config.RecoverySeconds
    local nearEnter,nearExit,farEnter,farExit=config.NearEnter,config.NearExit,config.FarEnter,config.FarExit
    local S={}
    function S.resolve(identity:any):string?
        if type(identity)~="string" then return nil end
        return if records[identity] then identity else aliases[identity]
    end
    function S.sample(identity:any,now:any,distance:any,previousTier:any?,interactUntil:any?,routineClock:any?):(any?,string?)
        local id=S.resolve(identity)
        if not id then return nil,"UnknownNpc" end
        if not finite(now) or now<0 or not finite(distance) or distance<0
            or (interactUntil~=nil and (not finite(interactUntil) or interactUntil<0))
            or (routineClock~=nil and (not finite(routineClock) or routineClock<0))
            or (previousTier~=nil and previousTier~="Near" and previousTier~="Mid" and previousTier~="Far") then return nil,"InvalidSample" end
        local r=records[id];local timeOfDay=now%day;local activity=phases[1].activity
        for _,p in ipairs(phases) do if timeOfDay>=p.start then activity=p.activity end end
        local scheduled=activity
        local routine=routines[id]
        -- Day/night and short work bouts use separate clocks. A fixed Lighting
        -- clock must not freeze the work/pause cycle. No local timers or RNG.
        if activity=="Work" and routineClock~=nil and routine then
            local period=routine.work+routine.pause
            if (routineClock%period+routine.offset)%period>=routine.work then activity="Social" end
        end
        if interactUntil~=nil then
            if now<interactUntil then activity="Interact"
            elseif now-interactUntil<recovery then activity="Recover" end
        end
        local tier="Mid"
        if distance<=nearEnter or (previousTier=="Near" and distance<nearExit) then tier="Near"
        elseif distance>=farEnter or (previousTier=="Far" and distance>farExit) then tier="Far" end
        return {id=id,legacyName=r.name,anchor={x=r.x,z=r.z},activity=activity,scheduledActivity=scheduled,
            tier=tier,updateSeconds=if tier=="Near" then .1 elseif tier=="Mid" then .5 else 5,
            backgroundEnabled=tier~="Far",accessible=true,questCritical=#r.hooks>0,questIds=r.hooks,
            poseOwner=if id=="smith_borin" then "Borin" else "FriendlyNpcAnimator",routeEnabled=false},nil
    end
    return table.freeze(S),nil
end
