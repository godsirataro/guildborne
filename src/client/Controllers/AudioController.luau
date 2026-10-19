--!strict
-- Local presentation only: no remotes, purchases or profile preference writes.
local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local GuiService=game:GetService("GuiService")
local Config=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
local budget=require(game.ReplicatedStorage.Shared.Data.AudioBudget)(Config.MaxVoices)
local A={};local started=false;local generation=0
local folder: Folder?=nil
local templates: {[string]: Sound}={};local groups: {[string]: SoundGroup}={}
local voices: {[number]: Instance}={};local connections: {RBXScriptConnection}={}
local finishes: {[number]: () -> ()}={}
local buttons: {[Instance]: {RBXScriptConnection}}={}
function A.Level(group: string): number
    local value=workspace:GetAttribute(Config.Attributes[group])
    return if type(value)=="number" and value==value then math.clamp(value,0,1) else Config.Defaults[group] or 0
end
local function mix()
    local master=if workspace:GetAttribute(Config.Attributes.Muted)==true then 0 else A.Level("Master")
    for key,group in pairs(groups) do group.Volume=master*A.Level(key) end
end
local function play(key: string,position: Vector3?,actor: Instance?): (() -> ())?
    local cue=Config.Cues[key];local template=templates[key]
    if not started or not cue or not template or not template.IsLoaded or not template.Parent then return nil end
    if workspace:GetAttribute(Config.Attributes.Muted)==true or A.Level("Master")*A.Level(cue.group)<=0 then return nil end
    if position then
        if position.X~=position.X or position.Y~=position.Y or position.Z~=position.Z or position.Magnitude==math.huge then return nil end
        local camera=workspace.CurrentCamera
        if not camera or (camera.CFrame.Position-position).Magnitude>Config.MaxDistance then return nil end
    end
    local duration=math.clamp(math.max(cue.duration,template.TimeLength)+.25,.1,10)
    local live=0;for _,container in pairs(voices) do if container.Parent then live+=1 end end
    if live>=Config.MaxVoices then return nil end -- expiry callbacks may run one frame after their deadline
    local token=budget.Reserve(key,os.clock(),duration,cue.interval);if not token then return nil end
    local sound=template:Clone();sound.Name="GuildborneCue_"..key;sound.Looped=false
    local container: Instance=sound
    if position then
        local part=Instance.new("Part");part.Name="GuildborneAudioEmitter";part.Size=Vector3.new(.1,.1,.1);part.Position=position
        part.Transparency=1;part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false
        sound.RollOffMinDistance=5;sound.RollOffMaxDistance=Config.MaxDistance;sound.RollOffMode=Enum.RollOffMode.InverseTapered
        sound.Parent=part;part.Parent=workspace;container=part
    else sound.Parent=folder end
    voices[token]=container
    local epoch=generation;local finished=false
    local ended: RBXScriptConnection?=nil
    local removed: RBXScriptConnection?=nil
    local function finish()
        if finished then return end;finished=true
        if ended then ended:Disconnect();ended=nil end
        if removed then removed:Disconnect();removed=nil end
        if generation==epoch then budget.Release(token);voices[token]=nil;finishes[token]=nil end
        container:Destroy()
    end
    finishes[token]=finish
    if actor then
        removed=actor.AncestryChanged:Connect(function() if not actor:IsDescendantOf(workspace) then finish() end end)
        if not actor:IsDescendantOf(workspace) then finish();return nil end
    end
    ended=sound.Ended:Connect(finish);sound:Play();task.delay(duration,finish)
    return finish
end
function A.Play(key: string,position: Vector3?): boolean
    return play(key,position,nil)~=nil
end
function A.PlayFor(actor: Instance,key: string,position: Vector3?): boolean
    return play(key,position,actor)~=nil
end
-- The returned idempotent disposer shares Ended, ancestry and Destroy cleanup.
function A.PlayOwned(actor: Instance,key: string,position: Vector3?): (() -> ())?
    return play(key,position,actor)
end
local function unwatch(child: Instance)
    local list=buttons[child];if list then for _,c in ipairs(list) do c:Disconnect() end;buttons[child]=nil end
end
local function watch(child: Instance)
    if not child:IsA("GuiButton") or buttons[child] then return end
    buttons[child]={child.Activated:Connect(function() if child.Active then A.Play("press") end end),child.MouseEnter:Connect(function() if child.Active then A.Play("hover") end end)}
end
function A.Start()
    if started then return end;generation+=1;started=true
    local created=Instance.new("Folder");created.Name="GuildborneAudio";created.Parent=SoundService;folder=created
    for _,key in ipairs({"UI","Combat"}) do local g=Instance.new("SoundGroup");g.Name="Guildborne"..key;g.Parent=created;groups[key]=g end
    for _,attribute in pairs(Config.Attributes) do table.insert(connections,workspace:GetAttributeChangedSignal(attribute):Connect(mix)) end
    mix()
    local load={}
    for key,cue in pairs(Config.Cues) do
        local id=Config.AssetIds[key]
        if Config.validAsset(id) then
            local sound=Instance.new("Sound");sound.Name="Template_"..key;sound.SoundId=id;sound.Volume=.65;sound.SoundGroup=groups[cue.group];sound.Parent=created
            templates[key]=sound;table.insert(load,sound)
        end
    end
    if #load>0 then task.spawn(function() pcall(function()ContentProvider:PreloadAsync(load)end) end) end
    local epoch=generation
    local gui=Players.LocalPlayer:WaitForChild("PlayerGui")
    if not started or generation~=epoch then return end
    for _,child in ipairs(gui:GetDescendants()) do watch(child) end
    table.insert(connections,gui.DescendantAdded:Connect(watch));table.insert(connections,gui.DescendantRemoving:Connect(unwatch))
    table.insert(connections,GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()local s=GuiService.SelectedObject;if s and s:IsDescendantOf(gui) and s.Active then A.Play("hover") end end))
end
function A.Destroy()
    started=false
    for _,c in ipairs(connections) do c:Disconnect() end;table.clear(connections)
    for child in pairs(buttons) do unwatch(child) end
    local pending={};for _,finish in pairs(finishes) do table.insert(pending,finish) end
    for _,finish in ipairs(pending) do finish() end
    generation+=1;table.clear(finishes);table.clear(voices);budget.Clear()
    if folder then folder:Destroy();folder=nil end;table.clear(templates);table.clear(groups)
end
return A
