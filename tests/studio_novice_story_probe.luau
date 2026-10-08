--!strict
-- Synthetic records only. This is persistence-format acceptance, not played quests.
return function():any
 local shared=game.ReplicatedStorage.Shared;local server=game.ServerScriptService.Server
 local content=require(server.Config.Content);local util=require(shared.Util.TableUtil);local rules=require(shared.Data.Expansion)
 local placement=require(shared.Data.LandBuildingPlacement)(rules,require(shared.Data.IslandPlacement),require(shared.Config.GuildIslandLayout))
 local themes=require(shared.Data.BuildingThemeRights)(require(shared.Config.BuildingThemes))
 local expansion=require(server.Systems.ExpansionSchema)(content,util,rules,placement,themes)
 local gear=require(shared.Data.Equipment)(content,rules,require(shared.Data.StatusPoints))
 local marketConfig=require(server.Config.Market);local orders=require(server.Systems.MarketOrders)(marketConfig,util)
 local market=require(server.Systems.MarketEscrow)(marketConfig,util,content,orders)
 local land=require(shared.Data.GuildLand)(require(server.Config.GuildLand))
 local config=require(server.Config.NoviceChapter)
 local story=require(server.Services.NoviceStoryService)(content,util,require(server.Services.EconomyService)(content,util),config)
 local schema=require(server.Systems.ProfileSchema)(content,util,gear,rules,expansion,market,land,true,story)
 local http=game:GetService("HttpService");local checks=0;local paths=0
 local function roundtrip(record:any):any
  assert(schema.validate(record,987654));local decoded=http:JSONDecode(http:JSONEncode(record))
  assert(schema.validate(decoded,987654));assert(util.equal(decoded,record));checks+=1;return decoded
 end
 for _,branch in ipairs({"rescue","supplies"}) do
  for _,classId in ipairs(content.AdventurerOrder) do for _,heroClass in ipairs(content.AdventurerOrder) do
   local r=roundtrip(schema.new(987654,1000));local events={}
   local function emit(name:string,payload:any)table.insert(events,{name=name,payload=payload})end
   for index,chapter in ipairs(config.Chapters) do
    if index==6 then
     assert(story.trialWon(r.data,classId)==nil);r=roundtrip(r)
     assert(story.selectClass(r.data,classId,emit)==nil);r=roundtrip(r)
    end
    for _,objective in ipairs(chapter.Objectives) do
     assert(story.observe(r.data,objective,if objective=="caravan_choice" then branch else nil)==nil);r=roundtrip(r)
    end
    assert(story.claim(r.data,chapter.Id,if index==6 then heroClass else nil,emit)==nil);r=roundtrip(r)
   end
   assert(r.data.character.xp==450 and r.data.character.level==10 and r.data.currencies.gold==0)
   assert(r.data.personalGuild.buildings.guildHall==1 and content.ProfileLevelCap(r.data)==20)
   assert(util.count(r.data.adventurers)==1 and util.count(r.data.inventory.equipment)==2)
   assert(#events==10);paths+=1
  end end
 end
 return {classHeroBranchPaths=paths,jsonRoundTrips=checks,profileWrites=0,actualGameplay=false,runtimeNoviceEnabled=false}
end
