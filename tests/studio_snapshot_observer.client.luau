--!strict
-- Optional Studio acceptance observer. Reads published client snapshots only.
-- Never sends requests, mutates gameplay data, or grants a profile checkpoint.
assert(game:GetService("RunService"):IsStudio()and game.PlaceId==0 and game.GameId==0)
local player=game.Players.LocalPlayer
local latest:any=nil
local copy=require(game.ReplicatedStorage:WaitForChild("Shared").Util.TableUtil).copy
local event=game.ReplicatedStorage:WaitForChild("GuildborneRemotes"):WaitForChild("State") :: RemoteEvent
event.OnClientEvent:Connect(function(value)if value.data then latest=copy(value)end end)
local snapshot=Instance.new("BindableFunction");snapshot.Name="AcceptanceSnapshot";snapshot.OnInvoke=function()return copy(latest)end;snapshot.Parent=player:WaitForChild("PlayerGui")
