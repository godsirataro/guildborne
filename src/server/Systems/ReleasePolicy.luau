--!strict
-- Pure server command policy. Existing services remain responsible for all other checks.
return function(config:any)
 local Policy={}
 function Policy.resolve(runtime:any,context:any):any
  local enabled=runtime.LaunchCandidate==true and runtime.StudioPersistence=="Memory"
   and context.isStudio==true and context.placeId==0 and context.gameId==0
  local profile:any={Enabled=enabled,Id=config.Id,MaxLevel=config.MaxLevel,MaxHall=config.MaxHall,CampaignChapters=config.CampaignChapters}
  function profile.problem(data:any,action:string,args:any):string?
   if not enabled then return nil end
   if type(args)~="table"then return "InvalidRequest"end
   if action=="TravelZone" and not config.Zones[args.zone]then return "ReleaseContentUnavailable"end
   if action=="StartTower"or action=="EnterTowerFloor"then return "ReleaseContentUnavailable"end
   if action=="AcceptTask"and config.BlockedTasks[args.questId]then return "ReleaseContentUnavailable"end
   if action=="GatherResource"and config.BlockedNodes[args.nodeId]then return "ReleaseContentUnavailable"end
   if action=="UpgradeGuildHall"and data.personalGuild.buildings.guildHall>=config.MaxHall then return "ReleaseHallCap"end
   if action=="AdvanceClass"then
    if not config.Class2Paths[args.pathId]then return "ReleaseContentUnavailable"end
    if data.progression.ruleset=="guildborne.progression.2"then
     -- The current story trial is player-owned. Never treat it as a hero's proof.
     if args.actorId~="player"then
      local build=data.expansion and data.expansion.actors[args.actorId];local proof=build and build.mentorProof
      return if proof and proof.version==1 and proof.pathId==args.pathId then nil else "HeroMentorRequired"
     end
     local campaign=data.progression.campaign
     if not campaign or campaign.claimed<config.CampaignChapters then return "ClassMentorRequired"end
    end
   end
   return nil
  end
  return profile
 end
 return Policy
end
