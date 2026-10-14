--!strict
local Renderer=require(game.ReplicatedStorage.Shared.Presentation.ModularAppearance.Renderer)
local Service={}
Service.Build=Renderer.Build
Service.Apply=Renderer.apply
Service.apply=Renderer.apply
Service.Clear=Renderer.clear
Service.Validate=Renderer.Validate
return Service
