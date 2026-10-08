--!strict
-- Pure temporary records, actual Roblox JSON round-trips; no player profile access.
return function():any
 local shared=game.ReplicatedStorage.Shared;local server=game.ServerScriptService.Server
 local content=require(server.Config.Content);local util=require(shared.Util.TableUtil);local rules=require(shared.Data.Expansion)
 local placement=require(shared.Data.LandBuildingPlacement)(rules,require(shared.Data.IslandPlacement),require(shared.Config.GuildIslandLayout))
 local themes=require(shared.Data.BuildingThemeRights)(require(shared.Config.BuildingThemes))
 local expansion=require(server.Systems.ExpansionSchema)(content,util,rules,placement,themes)
 local gear=require(shared.Data.Equipment)(content,rules,require(shared.Data.StatusPoints))
 local marketConfig=require(server.Config.Market);local orders=require(server.Systems.MarketOrders)(marketConfig,util)
 local market=require(server.Systems.MarketEscrow)(marketConfig,util,content,orders)
 local land=require(shared.Data.GuildLand)(require(server.Config.GuildLand));local factory=require(server.Systems.ProfileSchema)
 local legacy=factory(content,util,gear,rules,expansion,market,land)
 local schema=factory(content,util,gear,rules,expansion,market,land,true)
 local http=game:GetService("HttpService");local cases=0
 local function roundtrip(record:any,validator:any)
  local decoded=http:JSONDecode(http:JSONEncode(record));assert(validator.validate(decoded,987654));assert(util.equal(decoded,record));cases+=1
 end
 local function selected(record:any)
  local c=record.data.character;local def=content.Character.Classes.Warrior
  c.classId="Warrior";c.classPathId=def.PathId;c.skillId=def.SkillId;c.xp=9999;c.level=content:LevelFromXP(c.xp,content.ProfileLevelCap(record.data))
 end
 for hall=0,20 do
  local r=schema.new(987654,1000);r.data.personalGuild.buildings.guildHall=hall
  if hall==0 then r.data.character.xp=450;r.data.character.level=10 else selected(r)end
  roundtrip(r,schema)
 end
 for hall=1,20 do
  local r=legacy.new(987654,1000);r.data.personalGuild.buildings.guildHall=hall;selected(r);roundtrip(r,legacy)
  local before=util.copy(r);local migrated,code=schema.migrate(r);assert(code=="OK" and util.equal(r,before));roundtrip(migrated,schema)
  assert(migrated.data.character.level==r.data.character.level and migrated.data.character.xp==r.data.character.xp)
  assert(content.ProfileLevelCap(migrated.data)==hall*5)
 end
 assert(legacy.Version==7 and schema.Version==8)
 return {jsonRoundTrips=cases,noviceHallCases=21,legacyHallCases=20,migrationCases=20,ordinarySchema=legacy.Version,optInSchema=schema.Version,profileWrites=0,runtimeNoviceEnabled=false}
end
