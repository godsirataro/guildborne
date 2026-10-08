--!strict
-- Full profile-service composition for synthetic Novice/campaign validation.
return function(campaignConfig:any?):any
 local util=require("../src/shared/Util/TableUtil");local content=require("../src/server/Config/Content")
 local expansion=require("../src/shared/Data/Expansion")
 local placement=require("../src/shared/Data/LandBuildingPlacement")(expansion,require("../src/shared/Data/IslandPlacement"),require("../src/shared/Config/GuildIslandLayout"))
 local themes=require("../src/shared/Data/BuildingThemeRights")(require("../src/shared/Config/BuildingThemes"))
 local validator=require("../src/server/Systems/ExpansionSchema")(content,util,expansion,placement,themes)
 local gear=require("../src/shared/Data/Equipment")(content,expansion,require("../src/shared/Data/StatusPoints"))
 local mc=require("../src/server/Config/Market");local market=require("../src/server/Systems/MarketEscrow")(mc,util,content,require("../src/server/Systems/MarketOrders")(mc,util))
 local land=require("../src/shared/Data/GuildLand")(require("../src/server/Config/GuildLand"))
 local economy=require("../src/server/Services/EconomyService")(content,util)
 local config=require("../src/server/Config/NoviceChapter");local story=require("../src/server/Services/NoviceStoryService")(content,util,economy,config)
 local campaign=require("../src/server/Services/CampaignService")(content,util,economy,campaignConfig or require("../src/server/Config/ChapterOne"))
 local schema=require("../src/server/Systems/ProfileSchema")(content,util,gear,expansion,validator,market,land,true,story,campaign)
 return {Schema=schema,Story=story,Campaign=campaign,Content=content,Config=config}
end
