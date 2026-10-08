--!strict
-- Presentation only: copied view data, captured callbacks, no gameplay remotes.
return function(view:any):any
 assert(game.PlaceId==0 and game.GameId==0,"Offline fixture only")
 local player=game.Players.LocalPlayer
 for _,g in player.PlayerGui:GetChildren()do if g:IsA("ScreenGui")then g.Enabled=false end end
 view.mode="SYNTHETIC UI ONLY - no network";view.navigate="Party"
 view.data.quests.firstClears.quarry_patrol=nil
 view.data.character.tier=1;view.data.character.classPathId="mage:1"
 view.data.expansion.actors.player={tier=1,skills={}}
 local calls={}
 local ui=require(player.PlayerScripts.Client.UI.SliceUI)(function(action,payload)table.insert(calls,{action=action,payload=payload})end)
 ui.Update(view)
 local gui:any=nil
 for _,g in player.PlayerGui:GetChildren()do if g:IsA("ScreenGui")and g.Name=="GuildborneUI"and g.Enabled then gui=g end end
 assert(gui,"Fixture GUI missing");gui.Name="PartyPolishFixture"
 local api={}
 function api.Inspect(tab:string?,language:string?):any
  if tab then view.navigate=tab;view.data.language=language or "en";view.revision+=1;ui.Update(view)end
  local cards={};local buttons={};local overflow={}
  for _,g in gui:GetDescendants()do
   if g:IsA("Frame")and g.Name:match("^PartyMember_")then
    local labels={};for _,v in g:GetChildren()do if v:IsA("TextLabel")then table.insert(labels,v.Text)end end
    table.insert(cards,{name=g.Name,y=g.AbsolutePosition.Y,labels=labels})
   elseif g:IsA("TextButton")then
    table.insert(buttons,{name=g.Name,text=g.Text,x=g.AbsolutePosition.X+g.AbsoluteSize.X/2+62,y=g.AbsolutePosition.Y+g.AbsoluteSize.Y/2+20})
   end
   if (g:IsA("TextLabel")or g:IsA("TextButton"))and g.Visible and g.Text~=""and g.AbsoluteSize.X>0 then
    if g.TextBounds.Y>g.AbsoluteSize.Y+2 or g.TextBounds.X>g.AbsoluteSize.X+2 then table.insert(overflow,{name=g.Name,text=g.Text})end
   end
  end
  table.sort(cards,function(a,b)return a.y<b.y end)
  return {cards=cards,buttons=buttons,overflow=overflow,calls=calls}
 end
 return api
end
