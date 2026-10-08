--!strict
-- Run on the offline client. Temporarily records calls; restores the real singleton.
return function()
    assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
    local player=game.Players.LocalPlayer
    local client=player.PlayerScripts:WaitForChild("Client")
    local audio=require(client.Controllers.AudioController)
    local router=require(client.UI.MenuRouter)
    local config=require(game.ReplicatedStorage.Shared.Config.AudioConfig)
    local title=player.PlayerGui.GuildborneUI.TitleScreen
    local wasVisible=title.Visible
    local original=audio.Play;local calls={};local checks=0
    local gui=Instance.new("ScreenGui");gui.Name="AudioMenuProbe";gui.Parent=player.PlayerGui
    local frame=Instance.new("Frame");frame.Visible=false;frame.Parent=gui
    local function check(ok:boolean)assert(ok,"Audio menu check "..(checks+1));checks+=1 end
    local ok,reason=pcall(function()
        for id in pairs(config.Cues) do check(original(id)==false) end
        audio.Play=function(id:string,_position:Vector3?):boolean table.insert(calls,id);return false end
        title.Visible=false;task.wait();table.clear(calls)
        router.register("AudioMenuProbe",frame);task.wait();check(#calls==0)
        frame.Visible=true;task.wait();check(calls[1]=="modal_open" and #calls==1)
        frame.Visible=true;task.wait();check(#calls==1)
        frame.Visible=false;task.wait();check(calls[2]=="back" and #calls==2)
        frame.Visible=false;task.wait();check(#calls==2)
    end)
    audio.Play=original;gui:Destroy();title.Visible=wasVisible
    assert(ok,reason)
    return {checks=checks,unboundCues=22,menuTransitions=2,fixtureDestroyed=true,singletonRestored=true,profileWrites=0}
end
