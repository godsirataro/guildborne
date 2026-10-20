--!strict
-- Fixed local HUMAN_STANDARD Warrior Basic candidate; caller owns all actor gates.
-- No target tracking, limb scaling, root motion, authoritative writes or timing changes.
-- With reviewed source binds and grip fit Rx(pi+.45), the unchanged blade's y=2
-- point predicts (-13.280,3.309,78.775) inside the fixture Tunic at contact.
-- This is offline FK evidence only; native contact and human art acceptance are pending.
local Profile={}
type PoseSpec={translation: {number},angles: {number}}
local function ease(value: number): number
	value=math.clamp(value,0,1)
	return value*value*(3-2*value)
end

-- Timeline is the existing Shared.Presentation.ActionTimeline, injected by caller.
-- Numeric sampling permits deterministic checks without a Roblox CFrame runtime.
function Profile.Sample(age: number,jointName: string,timeline: any): PoseSpec?
	if jointName~="Waist" and jointName~="RightShoulder" and jointName~="RightElbow" then return nil end
	if type(age)~="number" or age~=age or math.abs(age)==math.huge or not timeline.active(age) then return nil end
	local wind=ease(age/timeline.Release)
	local release=ease((age-timeline.Release)/(timeline.Contact-timeline.Release))
	local settle=1-ease((age-timeline.Recovery)/(timeline.Duration-timeline.Recovery))
	local charge=wind*(1-release)
	local strike=release*settle
	if jointName=="Waist" then
		return {translation={0,-.23*charge,-.18*strike},angles={.12*charge-.10*strike,-.25*charge,0}}
	elseif jointName=="RightShoulder" then
		return {translation={0,0,0},angles={1.9*charge+1.15*strike,-.2*charge,.2*charge-.3*strike}}
	end
	return {translation={0,0,0},angles={-.6*charge-.3*strike,0,0}}
end

-- Preserve the already-injected production pose exactly outside these three joints.
-- The retarget caller subsequently performs its existing source-basis conjugation.
function Profile.Apply(age: number,jointName: string,fallback: CFrame?,timeline: any): CFrame?
	local sample=Profile.Sample(age,jointName,timeline)
	if not sample then return fallback end
	local p,a=sample.translation,sample.angles
	return CFrame.new(p[1],p[2],p[3])*CFrame.Angles(a[1],a[2],a[3])
end

return table.freeze(Profile)
