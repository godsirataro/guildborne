--!strict
-- Bilingual billboard text layout only; no profile or world progression.
return function():any
 local memory=require(game.ReplicatedStorage.Shared.Data.ArchiveStoryMemory)
 local gui=Instance.new("ScreenGui");gui.Name="ArchiveMemoryLayoutFixture";gui.Parent=game.Players.LocalPlayer.PlayerGui
 local label=Instance.new("TextLabel");label.Size=UDim2.fromOffset(320,120);label.TextWrapped=true;label.Font=Enum.Font.GothamMedium;label.TextSize=16;label.Parent=gui
 local checks=0
 local ok,result=pcall(function():any
  for _,branch in ipairs({"rescue","supplies"})do for _,timber in ipairs({"workers","town"})do for _,reconciliation in ipairs({"shared_table","joint_work"})do for _,warden in ipairs({"release","renew"})do
   local data={progression={novice={branch=branch},campaign={choices={allocate_timber=timber,choose_reconciliation=reconciliation,choose_warden_release=warden}}}}
   for index=1,2 do for _,kind in ipairs({"caravan","reconciliation","warden"})do
    local line=assert(memory(data,kind))[index]
    if kind=="caravan"then line..="\n"..assert(memory(data,"timber"))[index]end
    label.Text=line;task.wait(.04)
    assert(label.TextBounds.X<=320 and label.TextBounds.Y<=120,"Billboard clipped: "..line);checks+=1
   end end
  end end end end
  return {histories=16,languages=2,billboardBounds=checks,profileWrites=0}
 end)
 gui:Destroy();if not ok then error(result)end;return result
end
