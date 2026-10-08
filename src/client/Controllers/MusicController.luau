--!strict
-- Local two-voice ambience; zero bindings mean zero Sounds or asset requests.
local Players=game:GetService("Players")
local SoundService=game:GetService("SoundService")
local Run=game:GetService("RunService")
local Config=require(game.ReplicatedStorage.Shared.Config.MusicConfig)
local AudioConfig=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
local Audio=require(script.Parent.AudioController)
local makeTransition=require(game.ReplicatedStorage.Shared.Data.MusicTransition)
local S={};local started=false;local folder:Folder?=nil;local tick:RBXScriptConnection?=nil
local sounds:{[string]:Sound}={};local transition=makeTransition(Config.FadeSeconds)
local function clearSounds()
 for key,sound in pairs(sounds)do sound:Destroy();sounds[key]=nil end
end
function S.Start()
 if started then return end;started=true
 local any=false;for key,id in pairs(Config.AssetIds)do if Config.Tracks[key]and AudioConfig.validAsset(id)then any=true;break end end
 if not any then return end
 local f=Instance.new("Folder");f.Name="GuildborneMusic";f.Parent=SoundService;folder=f
 local elapsed=0
 tick=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.05 then return end;elapsed=0
  local zone=Players.LocalPlayer:GetAttribute("CurrentZone")
  local key=if type(zone)=="string"then Config.ZoneTracks[zone]else nil
  if key and not AudioConfig.validAsset(Config.AssetIds[key])then key=nil end
  local now=os.clock();transition.Set(key,now);local mix=transition.Step(now)
  if not mix then return end
  for id,sound in pairs(sounds)do if mix[id]==nil then sound:Destroy();sounds[id]=nil end end
  local volume=if workspace:GetAttribute(AudioConfig.Attributes.Muted)==true then 0 else Audio.Level("Master")*Audio.Level("Music")*Config.Volume
  for id,gain in pairs(mix)do
   local sound:Sound?=sounds[id]
   if not sound then
    local created=Instance.new("Sound");created.Name="Music_"..id;created.SoundId=Config.AssetIds[id];created.Looped=true;created.Volume=0;created.Parent=f;sounds[id]=created;created:Play();sound=created
   end
   assert(sound).Volume=gain*volume
  end
 end)
end
function S.Destroy()
 started=false;if tick then tick:Disconnect();tick=nil end
 clearSounds();transition.Clear();if folder then folder:Destroy();folder=nil end
end
return S
