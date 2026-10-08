--!strict
-- Native art matrix. Never grants recognition or changes profile data.
return function(sync:any):any
 local templates=game.ServerStorage.GuildborneArtKit
 local appearance=require(game.ReplicatedStorage.Shared.Presentation.HallAppearance)
 local themes=require(game.ReplicatedStorage.Shared.Config.BuildingThemes)
 local folder=Instance.new("Folder");folder.Name="GuildIdentityFixture";folder.Parent=workspace
 local cases=0;local parts=0
 local ok,result=pcall(function():any
  for _,theme in ipairs(themes.Order)do for level=1,2 do for _,crest in ipairs({"sun","oak","compass"})do for _,motto in ipairs({"together","courage","discovery"})do for _,language in ipairs({"en","th"})do
   local hall=(templates:FindFirstChild("GuildHallLv"..level) :: Model):Clone();appearance.apply(hall,theme);hall:PivotTo(CFrame.new(8000,0,0));hall.Parent=folder
   local data={language=language,progression={campaign={claimed=6,choices={choose_crest=crest,choose_motto=motto}}}}
   local colliders=0;for _,p in ipairs(hall:GetDescendants())do if p:IsA("BasePart")and p.CanCollide then colliders+=1 end end
   sync(hall,data);local count=0;local banners=0;local labels=0
   for _,v in ipairs(hall:GetDescendants())do
    if v:IsA("Model")and v.Name=="RecognizedCrest"then banners+=1;assert(v:GetAttribute("CrestId")==crest)
     for _,p in ipairs(v:GetDescendants())do if p:IsA("BasePart")then assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch);count+=1 end end
    elseif v:IsA("TextLabel")and v.Name=="Motto"then assert(#v.Text>0);labels+=1 end
   end
   assert(banners==(if level==1 then 1 else 3)and labels==banners)
   local before=#hall:GetDescendants();sync(hall,data);assert(#hall:GetDescendants()==before,"Duplicate identity art")
   data.progression.campaign.claimed=12;sync(hall,data);assert(#hall:GetDescendants()==before and hall:FindFirstChild("RecognizedCrest",true),"Continuation lost recognition")
   local oldPivot=hall:GetPivot();hall:PivotTo(oldPivot*CFrame.new(24,0,16)*CFrame.Angles(0,math.pi/2,0));sync(hall,data)
   local after=0;for _,p in ipairs(hall:GetDescendants())do if p:IsA("BasePart")and p.CanCollide then after+=1 end end;assert(after==colliders)
   sync(hall,{progression={}});assert(not hall:FindFirstChild("RecognizedCrest",true)and not hall:FindFirstChild("GuildMotto",true))
   for _,p in ipairs(hall:GetDescendants())do if p:IsA("BasePart")and(p.Name=="GuildDiamond"or p.Name=="CrestBlade")then assert(p.Transparency==0)end end
   parts+=count;cases+=1;hall:Destroy()
  end end end end end
  return {cases=cases,crestPartChecks=parts,themes=6,crests=3,mottos=3,languages=2,hallLevels=2,profileWrites=0}
 end)
 folder:Destroy();assert(ok,tostring(result));return result
end
