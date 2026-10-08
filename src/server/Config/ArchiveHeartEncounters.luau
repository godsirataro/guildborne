--!strict
-- Staged private encounter rules. Native combat/world binding remains pending.
return {
 Duration=240,Radius=45,Warning=2.5,Window=12,RetryDelay=1,MaxMistakes=3,
 InteractionRange=7,StrikeRange=24,StrikeInterval=.5,CoreHealth=180,MaxHitEvents=128,
 Modes={
  warden={Claimed=32,Level=90,Hall=15,Prerequisite="read_last_warden_patterns",Objective="break_warden_seals",Rescue=false,Attack=false},
  keeper={Claimed=35,Level=100,Hall=17,Objective="complete_keeper_of_names",Rescue=true,Attack=true},
 },
 Patterns={
  {name="Oath Line",shape="Line",length=30,width=6},
  {name="Hollow Oath",shape="Ring",radius=18,innerRadius=5},
  {name="Marked Name",shape="Circle",radius=6,targeted=true},
 } :: {any},
 RescuePoints={{x=-12,y=0,z=10},{x=12,y=0,z=10},{x=0,y=0,z=-12}},
 SealPoints={{x=12,y=0,z=-8},{x=-12,y=0,z=-8},{x=0,y=0,z=12}},
}
