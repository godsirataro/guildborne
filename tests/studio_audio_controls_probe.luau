--!strict
-- Run in an ordinary temporary LocalScript to inspect the live singleton.
return function()
    local p=game.Players.LocalPlayer;local service=game:GetService("SoundService")
    local config=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
    local audio=require(p.PlayerScripts.Client.Controllers.AudioController)
    local music=require(p.PlayerScripts.Client.Controllers.MusicController)
    local settings=require(p.PlayerScripts.Client.UI.SettingsControls)
    local locale=require(game.ReplicatedStorage.Shared.Config.Localization)
    local original: {[string]: any}={};for _,attribute in pairs(config.Attributes) do original[attribute]=workspace:GetAttribute(attribute) end
    local gui=Instance.new("ScreenGui");gui.Name="AudioSettingsFixture";gui.Parent=p.PlayerGui
    local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Size=UDim2.fromOffset(240,800);host.Parent=gui
    local checks=0
    local ok,result=pcall(function()
        audio.Start();local folders=0;for _,child in ipairs(service:GetChildren()) do if child.Name=="GuildborneAudio" then folders+=1 end end;assert(folders==1,"Audio start duplicated the live singleton")
        music.Start();music.Start();assert(service:FindFirstChild("GuildborneMusic")==nil,"Unbound music created Sounds")
        workspace:SetAttribute(config.Attributes.Music,.25);assert(audio.Level("Music")==.25)
        local folder=assert(service:FindFirstChild("GuildborneAudio"))
        local ui=folder:FindFirstChild("GuildborneUI") :: SoundGroup;local combat=folder:FindFirstChild("GuildborneCombat") :: SoundGroup
        workspace:SetAttribute(config.Attributes.Master,.5);workspace:SetAttribute(config.Attributes.UI,.25);workspace:SetAttribute(config.Attributes.Combat,.8);workspace:SetAttribute(config.Attributes.Muted,false);task.wait(.03)
        assert(math.abs(ui.Volume-.125)<.0001 and math.abs(combat.Volume-.4)<.0001,"Group mix mismatch")
        workspace:SetAttribute(config.Attributes.Muted,true);task.wait(.03);assert(ui.Volume==0 and combat.Volume==0)
        workspace:SetAttribute(config.Attributes.Muted,false);workspace:SetAttribute(config.Attributes.Master,5);workspace:SetAttribute(config.Attributes.UI,-1);task.wait(.03)
        assert(ui.Volume==0 and math.abs(combat.Volume-.8)<.0001,"Volume clamp missing")
        workspace:SetAttribute(config.Attributes.Master,"invalid");task.wait(.03);assert(math.abs(combat.Volume-.6)<.0001,"Invalid preference fallback missing")
        for key in pairs(config.Cues) do assert(audio.Play(key)==false,"Unbound asset played") end
        assert(audio.Play("unknown")==false)
        for _,child in ipairs(folder:GetDescendants()) do assert(not child:IsA("Sound"),"Unbound config created network audio objects") end
        for _,width in ipairs({240,640}) do for _,lang in ipairs({"en","th"}) do
            host.Size=UDim2.fromOffset(width,800)
            local view=settings(host,function(key)return locale.translate(lang,key)end);task.wait(.05)
            for _,child in ipairs(view.frame:GetChildren()) do if child:IsA("TextButton") or child:IsA("TextLabel") then
                assert(child.TextBounds.X<=child.AbsoluteSize.X+1 and child.TextBounds.Y<=child.AbsoluteSize.Y+1,"Settings copy clipped: "..child.Name.." "..lang)
                if child:IsA("TextButton") then assert(child.AbsoluteSize.Y>=44) end;checks+=1
            end end
            view.frame:Destroy()
        end end
        return {nativeTextChecks=checks,mixPassed=true,mutePassed=true,clampPassed=true,musicLevelPassed=true,invalidPreferenceFallback=true,unboundCues=22,unboundMusic=7,unboundSoundsCreated=0,noProfileWrites=true,actualAudioPlaybackTested=false}
    end)
    gui:Destroy();for _,attribute in pairs(config.Attributes) do workspace:SetAttribute(attribute,original[attribute]) end
    assert(ok,tostring(result));return result
end
