--!strict
-- Local eight-second work gestures; angles in radians, no root motion or rewards.
local M={Duration=8}
type Angles={number}
local poses:{[string]:{[string]:Angles}}={
 -- Existing FriendlyNpcKit props follow their bind bones. These are stationary
 -- occupation gestures, not contact solves, forge strikes or new service actions.
 borga={Head={-.06,.14,0},UpperTorso={0,.04,0},RightUpperArm={-.32,0,-.10},RightLowerArm={-.45,0,0},RightHand={0,.10,.08}},
 mogra={Head={.28,-.20,0},UpperTorso={.025,-.04,0},LeftUpperArm={-.12,0,.08},LeftLowerArm={-.18,0,0},RightUpperArm={-.18,0,0}},
 rukk={Head={.14,.18,0},RightUpperArm={-.38,0,-.08},RightLowerArm={-.25,0,0},RightHand={.06,0,0}},
 ghar={Head={-.04,-.26,0},UpperTorso={0,-.04,0},LeftUpperArm={-.32,0,.08},LeftLowerArm={-.24,0,0},RightUpperArm={-.08,0,0}},
 marshal_elian={Head={.16,-.12,0},LeftUpperArm={-.48,0,-.10},LeftLowerArm={-.35,0,0},RightUpperArm={-.30,0,-.16},RightLowerArm={-.42,0,0}},
 arborist_vaela={Head={.20,-.16,0},UpperTorso={.06,0,0},LeftUpperArm={-.35,0,-.08},LeftLowerArm={-.25,0,0},RightUpperArm={-.42,-.22,.08},RightLowerArm={-.48,0,0}},
 smith_borin={Head={.12,.10,0},UpperTorso={.04,-.08,0},RightUpperArm={-.62,0,-.12},RightLowerArm={-.44,0,0},LeftUpperArm={-.22,0,.08}},
 cartographer_nyra={Head={.18,-.16,0},LeftUpperArm={-.42,0,-.08},LeftLowerArm={-.30,0,0},RightUpperArm={-.35,-.16,0},RightLowerArm={-.32,0,0}},
 harbormaster_sela={Head={-.08,.28,0},UpperTorso={0,.08,0},LeftUpperArm={-.20,0,-.08},RightUpperArm={-.48,0,-.35},RightLowerArm={-.25,0,0}},
 steward_roka={Head={.10,-.12,0},UpperTorso={.04,0,0},LeftUpperArm={-.32,0,-.10},LeftLowerArm={-.20,0,0},RightUpperArm={-.40,-.16,.05},RightLowerArm={-.36,0,0}},
}
function M.sample(id:string,time:number,reduced:boolean?):{[string]:Angles}
 local pose=poses[id];if not pose or reduced or time~=time or math.abs(time)==math.huge or time<0 then return {} end
 local phase=(time%M.Duration)/M.Duration
 local envelope=math.sin(math.pi*phase)^2
 local detail=math.sin(phase*math.pi*4)*envelope
 local result:{[string]:Angles}={}
 for bone,a in pairs(pose)do
  local x=a[1]*envelope;local y=a[2]*envelope;local z=a[3]*envelope
  if bone=="RightLowerArm" then x+=.045*detail end
  if bone=="Head" then y+=.025*detail end
  result[bone]={x,y,z}
 end
 return result
end
return M
