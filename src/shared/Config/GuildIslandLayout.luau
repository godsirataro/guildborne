--!strict
-- Stud coordinates relative to each owner's island origin. Balancing candidates.
type Plot={x:number,z:number,width:number,depth:number,bridgeZ:number}
local plots:{[string]:Plot}={
    grove={x=-72,z=-16,width=64,depth=48,bridgeZ=0},
    quarry={x=-72,z=32,width=64,depth=48,bridgeZ=48},
    summit={x=-72,z=80,width=64,depth=48,bridgeZ=96},
}
return {
    SlotSpacing=280,
    Bounds={minX=-104,maxX=98,minZ=-44,maxZ=118},
    Plots=plots,
}
