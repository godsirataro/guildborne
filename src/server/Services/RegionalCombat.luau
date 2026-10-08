--!strict
-- Offline vertical slice gate. Staging/live activation remains an explicit acceptance milestone.
local City=require(game.ReplicatedStorage.Shared.Config.City)
local Runtime=require(script.Parent.Parent.Config.Runtime)
local Bridge=require(script.Parent.AdventureCombatBridge)
local Evasion=require(script.Parent.RegionalEvasion)
local enabled=game:GetService("RunService"):IsStudio() and game.PlaceId==0 and game.GameId==0 and Runtime.StudioPersistence=="Memory"
return function(damage:any,rewardFactory:any):any
    local S={}
    function S.Stop(player:Player,s:any)
        s.regionalEvasion=nil
        if s.adventureRegion then
            s.adventures[s.adventureRegion].Suspend();s.adventureRegion=nil;s.adventureEnabled=false
            s.enemies=s.campEnemies
            for _,enemy in ipairs(s.enemies) do if enemy.health>0 then enemy.model.Parent=s.plot end end
            for _,hero in pairs(s.heroes or {}) do if hero.combat then hero.combat.target=nil;hero.combat.focusTarget=nil;hero.combat.previousTarget=nil;hero.combat.evasion=nil end end
        end
        player:SetAttribute("RegionalCombatEnabled",nil)
    end
    function S.Sync(player:Player,s:any)
        local region=player:GetAttribute("CurrentZone")
        local desired=if enabled and rewardFactory and type(region)=="string" and City.Regions[region] and s.active and s.characterData and s.characterData.classId and not s.towerRun then region else nil
        if desired==s.adventureRegion then return end
        S.Stop(player,s)
        if not desired then return end
        s.adventures=s.adventures or {}
        local scene=s.adventures[desired]
        if not scene then
            local geometry=workspace.GuildborneWorld:FindFirstChild(desired) :: Model?
            if not geometry then return end
            s.adventureReward=s.adventureReward or rewardFactory(player)
            local d=City.Regions[desired]
            scene=Bridge(desired,Vector3.new(d.X,0,d.Z),player.UserId,s,damage,s.adventureReward,nil,geometry)
            if not scene then return end
            local parent=scene.model.Parent;scene.model.Parent=nil
            scene.model.Name="RegionalEncounter_"..player.UserId.."_"..desired
            scene.model:SetAttribute("AdventureSceneOwner",player.UserId);scene.model:SetAttribute("PreviewOnly",false);scene.model.Parent=parent
            geometry:SetAttribute("EncountersEnabled",true);geometry:SetAttribute("EncounterMode","OfflinePersonal")
            s.adventures[desired]=scene
        else scene.Resume() end
        for _,enemy in ipairs(s.campEnemies) do enemy.model.Parent=nil end
        s.enemies=scene.actors;s.adventureRegion=desired;s.adventureEnabled=true
        s.regionalEvasion=Evasion(workspace.GuildborneWorld:FindFirstChild(desired) :: Model,desired)
        player:SetAttribute("RegionalCombatEnabled",desired)
    end
    function S.Step(s:any,allies:{any},now:number,dt:number):boolean
        if not s.adventureRegion then return false end
        local eligible={}
        for _,ally in ipairs(allies) do local p=ally.root and ally.root.Position
            if p and City.regionCombat(s.adventureRegion,p.X,p.Y,p.Z) then table.insert(eligible,ally) end
        end
        s.adventures[s.adventureRegion].Step(eligible,now,dt)
        for _,enemy in ipairs(s.enemies) do if enemy.health>0 and enemy.targetId then return true end end
        return false
    end
    function S.Dodge(s:any,actor:any,now:number):Vector3?
        if not s.regionalEvasion then actor.evasion=nil;return nil end
        return s.regionalEvasion(actor,s.enemies,now)
    end
    function S.Remove(player:Player,s:any)
        S.Stop(player,s)
        for _,scene in pairs(s.adventures or {}) do scene.Destroy() end
        s.adventures=nil;s.adventureReward=nil
    end
    return S
end
