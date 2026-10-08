--!strict
-- Client-only presentation fixture: fake historical data, no gameplay remote calls.
-- Stop Play after use to release input listeners from the normal UI constructor.
return function(data:any,catalog:any):any
 assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
 local player=game.Players.LocalPlayer
 local pg=player.PlayerGui
 for _,gui in pg:GetChildren()do if gui:IsA("ScreenGui")and gui.Name:match("^Guildborne")then gui.Enabled=false end end
 local calls={}
 local ui=require(player.PlayerScripts.Client.UI.SliceUI)(function(action,payload)
  table.insert(calls,{action=action,payload=payload})
 end)
 local gui=pg:FindFirstChild("GuildborneUI")
 for _,child in pg:GetChildren()do if child:IsA("ScreenGui")and child.Name=="GuildborneUI"and child.Enabled then gui=child end end
 assert(gui,"Fixture GUI missing");gui.Name="HallTrackerFixture"
 local view={revision=1,status="Active",mode="SYNTHETIC UI ONLY · no save or network",data=data,catalog=catalog}
 ui.Update(view)
 local api={}
 function api.Inspect():any
  local target=gui:FindFirstChild("UpgradeGuildHall",true)
  local tracker=gui:FindFirstChild("QuestTracker",true)
  local result:any={calls=#calls,tracker=if tracker and tracker:IsA("TextButton")then tracker.Text else nil}
  if target and target:IsA("TextButton")then
   local scroll=target:FindFirstAncestorWhichIsA("ScrollingFrame")
   assert(scroll)
   result.button=target.Text;result.top=target.AbsolutePosition.Y;result.bottom=target.AbsolutePosition.Y+target.AbsoluteSize.Y
   result.viewportTop=scroll.AbsolutePosition.Y;result.viewportBottom=scroll.AbsolutePosition.Y+scroll.AbsoluteSize.Y
   result.fullyVisible=result.top>=result.viewportTop and result.bottom<=result.viewportBottom
   result.x=target.AbsolutePosition.X+target.AbsoluteSize.X/2+62;result.y=target.AbsolutePosition.Y+target.AbsoluteSize.Y/2+20
  end
  return result
 end
 function api.Language(language:string)
  data.language=language;view.revision+=1;ui.Update(view)
 end
 return api
end
