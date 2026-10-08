--!strict
local makeCatalog=require("../src/server/Systems/PermanentPassCatalog")
local makeEntitlements=require("../src/server/Systems/PermanentEntitlements")
local makeRestore=require("../src/server/Services/PermanentPassRestore")
return function(test:any,eq:any,harness:any,util:any,schema:any,protocol:any)
 local function fixture()
  local landCatalog=util.copy(require("../src/server/Config/GuildLand"));landCatalog.grove.productId=101
  local themeCatalog=util.copy(require("../src/shared/Config/BuildingThemes"));themeCatalog.Themes.elf.ProductId=202
  local catalog=makeCatalog(landCatalog,themeCatalog)
  local land=require("../src/shared/Data/GuildLand")(landCatalog)
  local themes=require("../src/shared/Data/BuildingThemeRights")(themeCatalog)
  local grants=makeEntitlements(catalog,land,themes,util)
  return catalog,land,themes,grants
 end
 test("permanent pass catalog excludes zero IDs and rejects cross-category collisions",function()
  local land=util.copy(require("../src/server/Config/GuildLand"));local themes=util.copy(require("../src/shared/Config/BuildingThemes"))
  eq(#makeCatalog(land,themes).Order,0)
  land.grove.productId=101;themes.Themes.elf.ProductId=101;eq(pcall(makeCatalog,land,themes),false)
  for _,id in ipairs({-1,0/0,math.huge,1.5})do land.grove.productId=id;eq(pcall(makeCatalog,land,themes),false)end
 end)
 test("verified land ownership survives locked quests without opening or spending",function()
  local _,land,_,grants=fixture();local original=schema.new(1,1000);local before=util.copy(original)
  local candidate,result,events=grants.apply(original,101)
  eq(original,before);eq(result.code,"OK");eq(#events,1)
  eq(land.describe(candidate.data.guildLand,"grove").status,"QuestLocked")
  eq(candidate.data.guildLand.plots.grove.opened,nil);eq(candidate.data.inventory,original.data.inventory)
  eq(candidate.data.quests,original.data.quests);eq(schema.validate(candidate,1),true)
  local again,duplicate,empty=grants.apply(candidate,101);eq(again,nil);eq(duplicate.code,"AlreadyCommitted");eq(#empty,0)
  eq(grants.apply(original,999),nil)
 end)
 test("permanent ownership commits exactly once and survives close/rejoin",function()
  local _,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup()
  local revision=h.service.Sessions[1].record.revision
  eq(h.service.CommitPermanentPass(1,101),"OK");eq(h.service.CommitPermanentPass(1,202),"OK")
  eq(h.service.CommitPermanentPass(1,101),"AlreadyCommitted");eq(h.service.CommitPermanentPass(1,202),"AlreadyCommitted")
  eq(h.service.Sessions[1].record.revision,revision+2)
  eq(h.data().expansion.themeRights.elf.productId,202)
  local expected=util.copy(h.data());eq(h.service.Close(1),"OK");h.service=h.make();eq(h.service.Load(1,"restored"),"OK")
  eq(h.data(),expected);eq(h.service.CommitPermanentPass(1,101),"AlreadyCommitted")
 end)
 test("ownership lost-response recovery never duplicates grant or audit",function()
  local _,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup();local revision=h.service.Sessions[1].record.revision
  h.mode="after";eq(h.service.CommitPermanentPass(1,101),"SavePending")
  eq(h.data().guildLand.plots.grove,nil);eq(h.records["p:1"].revision,revision+1)
  h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.service.CommitPermanentPass(1,101),"AlreadyCommitted")
  eq(h.service.Sessions[1].record.revision,revision+1)
  local n=0;for _,event in ipairs(h.service.Sessions[1].record.audit.outbox)do if event.name=="permanent_pass_restored"then n+=1 end end;eq(n,1)
 end)
 test("ownership write outage leaves no local entitlement and recovers pending candidate",function()
  local _,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup();h.mode="before"
  eq(h.service.CommitPermanentPass(1,202),"SavePending");eq(h.data().expansion.themeRights,nil)
  h.mode="ok";eq(h.service.Refresh(1),"OK");eq(h.data().expansion.themeRights.elf.productId,202)
 end)
 test("client cannot submit entitlement grants and unconfigured service stays disabled",function()
  local h=harness();h.setup();eq(h.service.CommitPermanentPass(1,101),"PurchasesDisabled")
  for _,action in ipairs({"PermanentPassOwnership","RecordVerifiedEntitlement","ElixirReceipt"})do eq(protocol.validate(h.command(action,{passId=101})),false)end
  local _,_,_,grants=fixture();h=harness(nil,nil,nil,grants);h.setup()
  for _,id in ipairs({0,-1,0/0,math.huge,1.1,999})do eq(h.service.CommitPermanentPass(1,id),"UnknownPass")end
 end)
 test("restore requires positive platform ownership and disabled mode makes no calls",function()
  local catalog,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup();local calls=0
  local deps:any={Enabled=false,Catalog=catalog,Data=h.service,Owns=function()calls+=1;return true end,Notify=function()end}
  local restore=makeRestore(deps);eq(restore.Restore(1),"PurchasesDisabled");eq(calls,0)
  deps.Enabled=true;deps.Owns=function()calls+=1;return false end;eq(restore.Restore(1),"OK");eq(next(h.data().guildLand.plots),nil)
  deps.Owns=function()error("platform unavailable")end;eq(restore.Restore(1),"OwnershipUnavailable")
  deps.Owns=function()return "true"end;eq(restore.Restore(1),"OwnershipUnavailable")
  eq(next(h.data().guildLand.plots),nil);eq(restore.Restore(1,999),"UnknownPass")
  deps.Owns=function()return true end;eq(restore.Restore(1),"OK");eq(h.data().guildLand.plots.grove.entitlement.productId,101)
  eq(h.data().expansion.themeRights.elf.productId,202)
 end)
 test("restore rechecks session after yielding verification and cannot grant next session",function()
  local catalog,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup();local old=h.service.Sessions[1]
  local restore=makeRestore({Enabled=true,Catalog=catalog,Data=h.service,Notify=function()end,Owns=function()
   h.service.Sessions[1]=util.copy(old);return true
  end})
  eq(restore.Restore(1,101),"SessionChanged");eq(next(h.data().guildLand.plots),nil)
  h.service.Sessions[1]=old
  restore=makeRestore({Enabled=true,Catalog=catalog,Data=h.service,Notify=function()end,Owns=function()old.closing=true;return true end})
  eq(restore.Restore(1,101),"SessionChanged");eq(next(h.data().guildLand.plots),nil)
 end)
 test("restore serializes concurrent checks and releases busy after exceptions",function()
  local catalog,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup();local restore:any
  local deps={Enabled=true,Catalog=catalog,Data=h.service,Notify=function()error("UI unavailable")end,Owns=function()
   eq(restore.Restore(1,101),"Busy");return true
  end}
  restore=makeRestore(deps);eq(restore.Restore(1,101),"OK");eq(restore.Restore(1,101),"OK")
  local original=h.service.CommitPermanentPass;h.service.CommitPermanentPass=function()error("unexpected")end
  eq(restore.Restore(1,202),"RestoreUnavailable");h.service.CommitPermanentPass=original
  eq(restore.Restore(1,202),"OK")
 end)
 test("ownership cannot commit after lease loss or while closing",function()
  local _,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup()
  h.service.Sessions[1].closing=true;eq(h.service.CommitPermanentPass(1,101),"Closing")
  h.service.Sessions[1].closing=false;h.records["p:1"].session.ownerToken="other"
  eq(h.service.CommitPermanentPass(1,101),"LeaseLost");eq(next(h.data().guildLand.plots),nil)
 end)
 local function promptFixture()
  local catalog,land,themes,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup()
  local offers=require("../src/server/Systems/PermanentPassOffers")(catalog,land,themes)
  local calls={owns=0,prompt=0};local deps:any={Enabled=true,Data=h.service,Offers=offers,Now=function()return h.now end,Clock=function()return h.now end,LeaseSafetySeconds=30,
   Spatial=function()return nil end,Owns=function()calls.owns+=1;return false end,Prompt=function()calls.prompt+=1 end}
  local prompt=require("../src/server/Services/PermanentPassPrompt")(deps)
  local function request(kind:string?,key:string?):string return prompt.Request(1,h.service.Sessions[1].record.revision,kind or "Theme",key or "elf") end
  return h,deps,calls,prompt,request,land,offers
 end
 test("quest-locked land never reaches platform prompt; explicit unlock is required",function()
  local h,_,calls,_,request,land=promptFixture()
  eq(request("Land","grove"),"QuestLocked");eq(calls.owns,0);eq(calls.prompt,0)
  h.quest("trail_watch");eq(request("Land","grove"),"QuestLocked")
  eq(h.send("UnlockGuildPlot",{plotId="grove"}),"OK");eq(request("Land","grove"),"PurchasePromptOpened")
  eq(calls.prompt,1);eq(land.describe(h.data().guildLand,"grove").status,"PurchaseRequired")
 end)
 test("prompt allows only configured server keys and never accepts client prices or IDs",function()
  local h,_,calls,_,request=promptFixture()
  for _,pair in ipairs({{"Wrong","elf"},{"Theme","human"},{"Theme","orc"},{"Theme","missing"},{"Land","quarry"}})do eq(request(pair[1],pair[2]),"PurchaseUnavailable")end
  eq(calls.owns,0);eq(calls.prompt,0)
  eq(protocol.validate(h.command("RequestPermanentPass",{kind="Theme",key="elf"})),true)
  for _,field in ipairs({"passId","price","purchased","ownerId"})do local args:any={kind="Theme",key="elf"};args[field]=1;eq(protocol.validate(h.command("RequestPermanentPass",args)),false)end
 end)
 test("disabled remote request and unsafe guild location never query platform",function()
  local _,deps,calls,_,request=promptFixture();deps.Enabled=false;eq(request(),"PurchaseUnavailable")
  deps.Enabled=true;deps.Spatial=function()return "ReturnToGuild"end;eq(request(),"ReturnToGuild");eq(calls.owns,0)
 end)
 test("prompt serializes open dialog and cancellation enables another after cooldown",function()
  local h,_,calls,prompt,request=promptFixture()
  eq(request(),"PurchasePromptOpened");eq(request(),"PurchasePromptOpen")
  prompt.Finished(1,101);eq(request(),"PurchasePromptOpen")
  prompt.Finished(1,202);eq(request(),"PurchaseCooling");h.now+=3;eq(request(),"PurchasePromptOpened");eq(calls.prompt,2)
  eq(h.data().expansion.themeRights,nil)
 end)
 test("already-owned platform pass restores durably instead of prompting",function()
  local h,deps,calls,_,request=promptFixture();deps.Owns=function()return true end
  eq(request(),"OK");eq(calls.prompt,0);eq(h.data().expansion.themeRights.elf.productId,202)
  h.now+=3;eq(request(),"AlreadyCommitted")
 end)
 test("prompt rechecks revision and guild location after ownership yields",function()
  local h,deps,calls,_,request=promptFixture()
  deps.Owns=function()eq(h.send("SetLanguage",{language="th"}),"OK");return false end
  eq(request(),"StaleRevision");eq(calls.prompt,0)
  h.now+=3;deps.Owns=function()deps.Spatial=function()return "ReturnToGuild"end;return false end
  eq(request(),"ReturnToGuild");eq(calls.prompt,0)
 end)
 test("platform errors release prompt lock and never guess ownership",function()
  local h,deps,calls,_,request=promptFixture();deps.Owns=function()error("offline")end
  eq(request(),"PurchaseUnavailable");h.now+=3;deps.Owns=function()return "yes"end;eq(request(),"OwnershipUnavailable")
  h.now+=3;deps.Owns=function()return false end;deps.Prompt=function()error("failed to open")end;eq(request(),"PurchaseUnavailable")
  h.now+=3;deps.Prompt=function()calls.prompt+=1 end;eq(request(),"PurchasePromptOpened");eq(h.data().expansion.themeRights,nil)
 end)
 test("profile busy closing and expiring lease block purchase prompt",function()
  local h,_,calls,_,request=promptFixture();local s=h.service.Sessions[1]
  s.busy=true;eq(request(),"SavePending");s.busy=false;s.closing=true;eq(request(),"Closing");s.closing=false
  h.now=s.record.session.leaseExpiresAt-30;eq(request(),"LeaseExpiring");eq(calls.owns,0)
 end)
 test("prompt discarded session cannot clear a newer session's open dialog",function()
  local h,deps,_,prompt,request=promptFixture();local old=h.service.Sessions[1];local reentered=false
  deps.Owns=function()
   if not reentered then
    reentered=true;prompt.Remove(1);h.service.Sessions[1]=util.copy(old)
    eq(request(),"PurchasePromptOpened")
   end
   return false
  end
  eq(request(),"ProfileNotReady");eq(request(),"PurchasePromptOpen")
 end)
 test("false ownership on restore never revokes saved permanent rights",function()
  local catalog,_,_,grants=fixture();local h=harness(nil,nil,nil,grants);h.setup();eq(h.service.CommitPermanentPass(1,202),"OK")
  local before=util.copy(h.data());local restore=makeRestore({Enabled=true,Catalog=catalog,Data=h.service,Owns=function()return false end,Notify=function()end})
  eq(restore.Restore(1),"OK");eq(h.data(),before)
 end)
end
