
local Tactics=require("../../src/server/Systems/HeroTactics")
local mt={};local function V(x,y,z)return setmetatable({X=x,Y=y,Z=z},mt)end
mt.__add=function(a,b)return V(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
mt.__sub=function(a,b)return V(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
mt.__index=function(a,k)if k=="Magnitude"then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z)end end
local function suite(old)
 local service={};local phases=nil;local sharedContext={Scene={enemies={}}}
 local Target={alive=function(a)return a.health>0 end};local Config={LeaderLeash=38}
 local Expansion={};local Abilities={};local contains=function()return true end
 local observed=0;local function observe(...)observed+=1 end
 local floors={};local rays=0;local params={}
 local workspace={Raycast=function(_,origin,direction,received)
  assert(received==params);rays+=1
  local y=nil
  for _,floor in ipairs(floors)do if floor<=origin.Y and floor>=origin.Y+direction.Y and (not y or floor>y)then y=floor end end
  return if y then {Position=V(0,y,0)}else nil
 end}
	function service.PlayerAction(s: any, action: string, now: number, actorId: string?): (boolean,string)
		local leader=s.playerCombat
		if not s.active or not leader or not Target.alive(leader) or not leader.model:FindFirstChildOfClass("Humanoid") or leader.model:FindFirstChildOfClass("Humanoid").Health<=0 then return false,"NotReady" end
		if phases and (not phases.CommandReady()or not phases.Policy.key(leader))then return false,"NotReady"end
		local enemies=if phases then sharedContext.Scene.enemies else s.enemies
		local a=leader; local build=s.playerBuild
		local isOrder=Tactics.isOrder(action)
		if actorId and actorId~="player" then
			local hero=s.heroes and s.heroes[actorId]
			if not hero or hero.state~="Following" or not hero.combat or hero.combat.owner~=leader.owner or not Target.alive(hero.combat) then return false,"CompanionUnavailable" end
			a=hero.combat;build=a.build
			if not build or (not isOrder and (a.root.Position-leader.root.Position).Magnitude>Config.LeaderLeash) then return false,"CompanionUnavailable" end
		end
		if phases and not phases.Policy.key(a)then return false,"CompanionUnavailable"end
		if isOrder then
			if a==leader then return false,"Select a companion first" end
			if not a.model.Parent then return false,"CompanionUnavailable" end
			-- Orders only affect owned AI movement/selection; they never cast, heal or refill cooldowns.
			local anchor=a.root.Position
			if action=="Hold" then
				-- Match follower support: avoid overhead surfaces while retaining
				-- the original lower bound, sixteen studs below the root reference.
				local hit=workspace:Raycast(anchor+V(0,8,0),V(0,-24,0),s.params)
				if not hit then return false,"CompanionUnavailable"end
				anchor=hit.Position+V(0,3,0)
			end
			local controlled=s.heroes[actorId]
			controlled.generation+=1;controlled.path=nil
			Tactics.apply(a,action,anchor);a.focusTarget=if action=="Focus" then Target.enemy(a,enemies,nil,Config.DetectionRange,now) else nil
			a.model:SetAttribute("TacticalPreset",a.tactic or "Balanced")
			observe(leader.owner,"hero_order_accepted",{order=action})
			a.model:SetAttribute("CompanionOrder",a.order)
			return true,"OK"
		end
		-- Re-evaluate bounds at receipt time; never trust stale 5 Hz active flags.
		if not a.model.Parent or not contains(s,a) then return false,"EnterCamp" end
		if not leader.model.Parent or not contains(s,leader) then return false,"EnterCamp" end
		a.session=s;leader.session=s
		local role=Config.Classes[a.class]
		-- Resolve only from committed server progression, never a client ability ID.
		local allowed=Expansion.allowedSkills(build,role.Ability)
		a.allowedAbilities=allowed
		local slot=({Ability1=1,Ability2=2,Ability3=3})[action]
		local slots=Expansion.skillSlots(build,role.Ability)
		local skill=if slot then slots[slot] else a.ability or role.Ability
		if not skill then return false,"SkillNotLearned" end
		if action~="Basic" and action~="Ability" and not slot then return false,"InvalidRequest" end
		local def=Config.Abilities[skill]
		local target=if action~="Basic" and def.Effect=="Heal" then Target.heal(a,if phases then (if def.Group then phases.Own(a)else phases.Support())else s.allies or {},def.Range)
			else Target.enemy(a,enemies,nil,if action=="Basic" then a.stats.AttackRange else def.Range,now)
		if not target then return false,"NoTarget" end
		if action~="Basic" then return Abilities.cast(a,skill,target,enemies,now) end
		local ok=Abilities.basic(a,target,now)
		return ok,if ok then "OK" else "Cooldown"
	end

 local count=0
 local function run(mode,ys,reference)
  floors=ys;rays=0;observed=0;phases=nil
  local leader={owner=1,health=100,model={FindFirstChildOfClass=function()return {Health=100}end}}
  local a={owner=1,health=80,root={Position=V(0,reference or 5,0)},build={},model={Parent=true},cooldowns={fireball=99},stats={Attack=7}}
  function a.model:SetAttribute(k,v)self[k]=v end
  local h={state="Following",combat=a,generation=4,path={"keep"}}
  local s={active=true,playerCombat=leader,heroes={["a:Mage"]=h},params=params}
  local id="a:Mage"
  if mode=="foreign"then a.owner=2 elseif mode=="notfollowing"then h.state="Available"
  elseif mode=="deadhero"then a.health=0 elseif mode=="deadleader"then leader.health=0
  elseif mode=="inactive"then s.active=false elseif mode=="missing"then id="a:missing"
  elseif mode=="player"then id="player" elseif mode=="removed"then a.model.Parent=nil
  elseif mode=="shared"then phases={CommandReady=function()return false end,Policy={key=function()return true end}}
  elseif mode=="sharedhero"then phases={CommandReady=function()return true end,Policy={key=function(x)return x==leader end}}
  end
  local hp=a.health;local oldpath=h.path
  local ok,why=service.PlayerAction(s,"Hold",100,id)
  assert(a.health==hp and a.cooldowns.fireball==99 and a.stats.Attack==7)
  if ok then
   assert(why=="OK" and a.order=="Hold" and h.generation==5 and h.path==nil and observed==1 and rays==1)
  else assert(a.order==nil and h.generation==4 and h.path==oldpath and observed==0)end
  count+=1;return ok,why,a.holdPoint and a.holdPoint.Y,rays
 end
 local ok,_,y=run("valid",{2,12.5},5)
 assert(ok and y==(if old then 15.5 else 5),"Native lintel counterexample")
 if old then return count end
 for _,r in ipairs({5,7,9})do local yes,_,height=run("valid",{2,12.5},r);assert(yes and height==5)end
 local yes,_,height=run("valid",{52,62.5},55);assert(yes and height==55)
 for _,ys in ipairs({{}, {-15}})do local accepted,reason,_,n=run("valid",ys,5);assert(not accepted and reason=="CompanionUnavailable" and n==1)end
 local accepted,_,bottom=run("valid",{-11},5);assert(accepted and bottom==-8)
 for _,mode in ipairs({"foreign","notfollowing","deadhero","deadleader","inactive","missing","player","removed","shared","sharedhero"})do
  local accepted,_,_,n=run(mode,{2,12.5},5);assert(not accepted and n==0,mode)
 end
 return count
end
print("PASS actual PlayerAction Hold cases",suite(false))
