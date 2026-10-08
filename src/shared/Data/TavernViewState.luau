--!strict
-- Display-only readiness from the public snapshot. Server transactions revalidate.
return function(data:any,catalog:any,busy:boolean):any
 local s=data.settlement;local tavern=catalog.Tavern;local count=0;local equipment=0
 for _ in pairs(data.adventurers) do count+=1 end
 for _ in pairs(data.inventory.equipment) do equipment+=1 end
 local common=if busy then "Waiting for the current action." elseif data.quests.active or data.expansion.tower.active then "Finish your expedition first." else nil
 local full=count>=data.rosterCapacity
 local cost=if s.offer then tavern.HireCost+((table.find(tavern.Ranks,s.offer.rank) or 1)-1)*10 else 0
 local scout=common or (if full then "Your roster is full." elseif s.nextOffer>=1000000000 then "No more candidates are available." elseif data.gold<tavern.ScoutCost then "You need more Gold." else nil)
 local hire=common or (if not s.offer then "Scout a candidate first." elseif full then "Your roster is full." elseif s.nextHero>=1000000000 then "No more candidates are available." elseif data.gold<cost then "You need more Gold." elseif equipment>=catalog.EquipmentLimit then "Free one equipment slot for the starting weapon." else nil)
 local level=s.tavernLevel;local timber=data.inventory.stacks.timber or 0;local stone=data.inventory.stacks.stone or 0
 local upgrade=common or (if level>=tavern.MaxLevel then "Tavern is at maximum level." elseif data.hallLevel<=level then "Upgrade your Guild Hall first." elseif timber<5*level or stone<3*level then "Gather the required materials first." elseif data.gold<100*level then "You need more Gold." else nil)
 return {count=count,hireCost=cost,scoutCost=tavern.ScoutCost,scoutProblem=scout,hireProblem=hire,upgradeProblem=upgrade,timber=timber,stone=stone}
end
