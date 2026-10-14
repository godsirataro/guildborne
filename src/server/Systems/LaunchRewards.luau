--!strict
-- Caller supplies a disposable transaction copy. Never grants outside profile commit.
return function(content:any,util:any,economy:any,config:any)
 local S={}
 local function keys(value:any,allowed:any):boolean
  if type(value)~="table" or getmetatable(value)~=nil then return false end
  for k in pairs(value)do if not allowed[k]then return false end end
  return true
 end
 local function material(r:any)
  assert(content.Items[r.Id] and content.Items[r.Id].Kind=="Material" and util.integer(r.Quantity,1,10),"Invalid launch reward")
 end
 assert(config.Version==1 and #config.Daily==7 and #config.Tiers==6)
 for _,r in ipairs(config.Daily)do material(r)end
 for _,entry in ipairs(config.Tiers)do local t:any=entry;material(t.Free);material(t.Premium)end
 function S.new():any return {version=1,daily={lastClaimDay=-1,claims=0},season={id=config.SeasonId,free={},premium={},premiumOwned=false}}end
 function S.validate(s:any):boolean
  if s==nil then return true end
  if not keys(s,{version=true,daily=true,season=true}) or s.version~=1 then return false end
  local d,z=s.daily,s.season
  if not keys(d,{lastClaimDay=true,claims=true}) or not util.integer(d.lastClaimDay,-1,1157407) or not util.integer(d.claims,0,1000000) then return false end
  if (d.claims==0)~=(d.lastClaimDay==-1) or d.claims>d.lastClaimDay+1 then return false end
  if not keys(z,{id=true,free=true,premium=true,premiumOwned=true}) or z.id~=config.SeasonId or type(z.premiumOwned)~="boolean" then return false end
  for _,track in ipairs({"free","premium"})do
   if type(z[track])~="table" or getmetatable(z[track])~=nil then return false end
   for tier,v in pairs(z[track])do
    if type(tier)~="string" or not tier:match("^[1-6]$") or v~=true or (track=="premium" and not z.premiumOwned) then return false end
   end
  end
  return true
 end
 function S.migrate(data:any):boolean
  if not S.validate(data.launchRewards)then return false end
  if data.launchRewards==nil then data.launchRewards=S.new()end
  return true
 end
 local function earned(data:any,tier:number):boolean
  local p=data.progression;local c=p and p.campaign
  return type(c)=="table" and util.integer(c.claimed,0,1000) and c.claimed>=config.Tiers[tier].Claimed
 end
 function S.apply(data:any,action:string,args:any,now:number,emit:any):(string?,any?)
  if not config.Enabled then return "LaunchRewardsUnavailable",nil end
  if not util.integer(now,0,100000000000)then return "InvalidRewardTime",nil end
  if not S.validate(data.launchRewards)then return "CorruptLaunchRewards",nil end
  local state=util.copy(data.launchRewards or S.new());local reward:any;local prefix:string
  if action=="ClaimDailyReward" then
   if not keys(args,{})then return "InvalidRequest",nil end
   local day=math.floor(now/86400)
   if day<=state.daily.lastClaimDay then return "DailyAlreadyClaimed",nil end
   if state.daily.claims>=1000000 then return "RewardCapacity",nil end
   reward=config.Daily[state.daily.claims%#config.Daily+1];prefix="daily:"..tostring(day)
   state.daily.lastClaimDay=day;state.daily.claims+=1
  elseif action=="ClaimSeasonReward" then
   if not keys(args,{seasonId=true,tier=true,track=true}) or args.seasonId~=config.SeasonId or not util.integer(args.tier,1,#config.Tiers) or (args.track~="free" and args.track~="premium")then return "InvalidSeasonReward",nil end
   if args.track=="premium" and (not config.PremiumEnabled or not state.season.premiumOwned)then return "PremiumRequired",nil end
   if not earned(data,args.tier)then return "SeasonTierLocked",nil end
   local key=tostring(args.tier)
   if state.season[args.track][key]then return "SeasonAlreadyClaimed",nil end
   reward=config.Tiers[args.tier][if args.track=="free" then "Free" else "Premium"]
   prefix="season:"..config.SeasonId..":"..args.track..":"..key;state.season[args.track][key]=true
  else return "InvalidAction",nil end
  local problem=economy.items(data,{reward},prefix,emit)
  if problem then return problem,nil end
  data.launchRewards=state
  emit("launch_reward_claimed",{source=prefix,itemId=reward.Id,quantity=reward.Quantity})
  return nil,{Gold=0,XP=0,Items={util.copy(reward)}}
 end
 function S.view(data:any,now:number):any
  if not config.Enabled or not util.integer(now,0,100000000000) or not S.validate(data.launchRewards)then return {available=false}end
  local s=data.launchRewards or S.new();local day=math.floor(now/86400)
  local tiers={}
  for i,entry in ipairs(config.Tiers)do local t:any=entry;table.insert(tiers,{tier=i,milestone=t.Milestone,earned=earned(data,i),free=util.copy(t.Free),premium=util.copy(t.Premium),freeClaimed=s.season.free[tostring(i)]==true,premiumClaimed=s.season.premium[tostring(i)]==true})end
  return {available=true,preview=true,seasonId=config.SeasonId,premiumAvailable=config.PremiumEnabled and s.season.premiumOwned,
   daily={claimable=day>s.daily.lastClaimDay and s.daily.claims<1000000,claims=s.daily.claims,reward=util.copy(config.Daily[s.daily.claims%#config.Daily+1]),nextAt=(math.max(day,s.daily.lastClaimDay)+1)*86400},tiers=tiers}
 end
 return S
end
