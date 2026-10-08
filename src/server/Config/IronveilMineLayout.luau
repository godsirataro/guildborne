--!strict
-- Private prototype interior slots above the surface map, reached through a portal.
-- X/Z remain inside Ironveil navigation bounds; slots have separate vertical floors.
return {
 MaxSlots=8,BaseX=500,BaseY=100,BaseZ=1400,SlotHeight=80,
 Width=230,Depth=230,Entry={0,3,102},Exit={0,.15,102},
 Scenes={
  {Id="scale_yard",X=-55,Z=65},
  {Id="signal_shaft",X=55,Z=65},
  {Id="shoring_gallery",X=-55,Z=0},
  {Id="ink_office",X=55,Z=0},
  {Id="warden_mechanism",X=-55,Z=-65},
  {Id="training_camp",X=55,Z=-65},
 },
}
