
local Rules=require("../../../../src/server/Systems/TravelRules")({})
 local function routeReady(route:any):boolean
  if type(route)~="table" or Rules.walkingContext(route.id,route.fromZone,route.toZone)==nil
   or not route.geometry or not route.geometry.Parent or type(route.volumes)~="table"
   or #route.volumes==0 or #route.volumes>128 or type(route.entries)~="table" or type(route.safeRecovery)~="table" then return false end
  local ok,ready=Rules.walkingCall(route.isReady)
  return ok and ready==true
 end

local checks=0
local function check(value,message)assert(value,message);checks+=1 end
local function scenario(mode,full,disabled)
 local folder={};local calls={};local created={};local destroyed=false;local cleanups=0
 local quality={};local junction=nil;local wallDetached=false
 local states={}
 local walkingPolicy=if disabled then nil else {FullConnectedWorld=full,Session={},Gate={},Notify={}}
 local script={Parent={WorldQualitySlice={}}}
 local function require(module)
  assert(module==script.Parent.WorldQualitySlice)
  calls[#calls+1]="quality"
  return function(parent)assert(parent==folder);return quality end
 end
 local function handle(id,from,to)
  local state={ready=true,parent=true};states[id]=state
  local geometry={Parent=folder,IsDescendantOf=function(_,parent)return state.parent and not destroyed and parent==folder end}
  local h={id=id,fromZone=from,toZone=to,geometry=geometry,ownedModel=geometry,
   volumes={{}},entries={},safeRecovery={}}
  h.isReady=function()
   if destroyed then return false end
   if state.throw then error("readiness exception")end
   return if destroyed then false else state.ready
  end
  h.destroy=function()state.ready=false;state.parent=false;geometry.Parent=nil end
  created[id]=h;return h
 end
 quality.buildContinuousCorridor=function()
  calls[#calls+1]="first";wallDetached=true
  if mode=="first-error"then error(mode)end
  return handle("city_greenwood_west","City","Greenwood")
 end
 quality.buildGreenwoodIronveilCorridor=function()
  calls[#calls+1]="second"
  if mode=="second-error"then error(mode)end
  local h=handle("greenwood_ironveil_south","Greenwood","Ironveil")
  if mode=="route-not-ready"then states[h.id].ready=false end
  if mode=="route-wrong-parent"then states[h.id].parent=false end
  return h
 end
 quality.buildGreenwoodEastJunction=function()
  calls[#calls+1]="junction";assert(full==true)
  if mode=="junction-error"then error(mode)end
  junction=handle("greenwood_east_junction")
  if mode=="junction-not-ready"then states[junction.id].ready=false end
  if mode=="junction-truthy"then states[junction.id].ready="true" end
  if mode=="junction-wrong-parent"then states[junction.id].parent=false end
  if mode=="junction-read-error"then states[junction.id].throw=true end
  return junction
 end
 quality.buildIronveilAshenCorridor=function()
  calls[#calls+1]="third";assert(full==true)
  if mode=="third-error"then error(mode)end
  local h=handle("ironveil_ashen_south","Ironveil","Ashen")
  if mode=="third-not-ready"then states[h.id].ready=false end
  return h
 end
 quality.destroy=function()
  destroyed=true;cleanups+=1;wallDetached=false
  for _,h in pairs(created)do h.destroy()end
 end
 local function initialize()
	local walking:any=nil
	if walkingPolicy then
		-- The quality initializer independently enforces unsaved Studio/Memory.
		local quality=require(script.Parent.WorldQualitySlice)(folder)
		-- BEGIN REVIEWED WALKING INITIALIZER
		local ready,routes=pcall(function()
			local descriptors={quality.buildContinuousCorridor(),quality.buildGreenwoodIronveilCorridor()}
			if walkingPolicy.FullConnectedWorld==true then
				local junction=quality.buildGreenwoodEastJunction()
				local east=descriptors[2]
				local corridorReady=east.isReady
				-- Keep the reviewed route identity/bounds; its direct approach must
				-- remain ready at registration and every later travel admission.
				local connected=table.clone(east)
				connected.isReady=function(): boolean
					return corridorReady()==true and junction.geometry:IsDescendantOf(folder) and junction.isReady()==true
				end
				descriptors[2]=connected
				table.insert(descriptors,quality.buildIronveilAshenCorridor())
			end
			for _,route in ipairs(descriptors) do
				assert(route.geometry:IsDescendantOf(folder) and route.isReady(),"Walking corridor is not ready: "..route.id)
			end
			return descriptors
		end)
		if not ready then quality.destroy();error(tostring(routes)) end
		walking={Routes=routes,Session=walkingPolicy.Session,Gate=walkingPolicy.Gate,Notify=walkingPolicy.Notify}
		-- END REVIEWED WALKING INITIALIZER
	end

  return walking
 end
 local ok,walking=pcall(initialize)
 if disabled then
  check(ok and walking==nil and #calls==0,"Default without walking constructed geometry")
  return
 end
 if mode~="success"then
  check(not ok and cleanups==1 and destroyed and not wallDetached,"Startup failure did not clean up: "..mode)
  for _,h in pairs(created)do check(not h.isReady() and h.geometry.Parent==nil,"Partial model retained")end
  return
 end
 local fullMode=full==true
 check(ok and not destroyed and wallDetached,"Initialization failed")
 check(#walking.Routes==(if fullMode then 3 else 2),"Route count changed")
 check(table.concat(calls,",")==(if fullMode then "quality,first,second,junction,third" else "quality,first,second"),"Wrong builder dispatch")
 check(walking.Session==walkingPolicy.Session and walking.Gate==walkingPolicy.Gate and walking.Notify==walkingPolicy.Notify,"Policy callbacks changed")
 local original=created.greenwood_ironveil_south;local connected=walking.Routes[2]
 check(walking.Routes[1]==created.city_greenwood_west,"First route replaced")
 if not fullMode then
  check(connected==original and junction==nil,"Two-route mode changed")
 else
  check(connected~=original and connected.isReady~=original.isReady,"Original route mutated or predicate not wrapped")
  for k,v in pairs(original)do if k~="isReady"then check(connected[k]==v,"Route field changed: "..k)end end
  check(walking.Routes[3]==created.ironveil_ashen_south,"Third route replaced")
  check(routeReady(connected),"Complete route not ready")
  states[junction.id].ready=false
  check(not routeReady(connected) and routeReady(original),"Late junction failure did not close admission independently")
  check(routeReady(walking.Routes[1]) and routeReady(walking.Routes[3]),"Unrelated route changed")
  states[junction.id].ready=true;states[junction.id].parent=false
  check(not routeReady(connected),"Detached junction accepted")
  states[junction.id].parent=true;states[junction.id].throw=true
  check(not routeReady(connected),"Runtime readiness exception accepted")
  states[junction.id].throw=false;states[junction.id].ready=1
  check(not routeReady(connected),"Truthy junction readiness accepted")
  states[junction.id].ready=true;states[original.id].ready=false
  check(not routeReady(connected),"Late corridor failure accepted")
  states[original.id].ready=true
  check(routeReady(connected),"Restored genuine readiness rejected")
  junction.destroy()
  check(not routeReady(connected),"Destroyed junction accepted")
 end
 quality.destroy()
 for _,r in ipairs(walking.Routes)do check(not routeReady(r),"Destroyed quality route accepted")end
 check(cleanups==1 and not wallDetached,"Destroy did not restore boundary")
end
scenario("success",nil,true)
scenario("success",nil,false)
for _,flag in ipairs({false,"true",1,true})do scenario("success",flag,false)end
for _,mode in ipairs({"first-error","second-error","route-not-ready","route-wrong-parent"})do
 scenario(mode,nil,false);scenario(mode,true,false)
end
for _,mode in ipairs({"junction-error","junction-not-ready","junction-truthy","junction-wrong-parent","junction-read-error","third-error","third-not-ready"})do scenario(mode,true,false)end
print("PASS actual initializer/readiness: "..checks.." assertions; 21 scenarios; native physics NOT_RUN")
