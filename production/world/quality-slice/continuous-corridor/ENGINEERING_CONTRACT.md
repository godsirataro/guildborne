# Controller / engineering API agreement

Call the existing guarded preview initializer, then explicitly build:

```luau
local handle = require(script.Parent.WorldQualitySlice)(folder)
local route = handle.buildContinuousCorridor()
city.walkingRoutes = {route}
```

`route = {id="city_greenwood_west",fromZone="City",toZone="Greenwood",geometry=Model,volumes={OBB,...},entries={City=OBB,Greenwood=OBB},safeRecovery={City=CFrame.new(0,5,-720),Greenwood=CFrame.new(0,7,1505)},isReady=function():boolean}`.

OBB is `{cframe=CFrame,size=Vector3}`. Model is `folder.CityGreenwoodCorridor`, directly under GuildborneWorld for hero ray inclusion. Explicit method is idempotent. Destroy restores only the owned city south wall and removes geometry; no regions iteration shape changes. Existing standalone Studio/Memory guard remains. Root owns bootstrap/WorldService, permission callbacks and runtime activation. This worker supplies geometry readiness only, not gameplay eligibility.

City entry box X[-14,14],Y[-2,14],Z[-670,-630] overlaps legal City and corridor. Greenwood entry X[-14,14],Y[0,15],Z[1493,1528] overlaps legal region, existing landing and corridor endpoint. Recovery uses canonical existing destinations. Individual bounded segment boxes include four studs below and fourteen above their floor, with small endpoint overlaps; no giant world rectangle. Exact boxes generated alongside geometry.

New24-stud road starts at (0,.55,-664), remains straight through city gate Z-625 toZ-605, then western route in descriptor.json. Single south wall at(0,0,-625) is temporarily replaced with original CityArch,31-stud clear. Greenwood route ends at(0,2,1526). Existing protected return portal atZ1517 retains9-stud throat. No private island traversal; all guildbelt geometry stays west of X-104. Native five-follower pinch test remains pending.

Navigation metadata: geometry.NavigationNodes contains38 Vector3Value children named001..038; Value is exact generated floor centerline point, attribute Index is1-based. Model attributes RouteId,FromZone,ToZone,WalkWidth=24,NavigationPointKind="FloorCenter",NavigationBelowFloor=4,NavigationAboveFloor=14. No duplicate inferred curve. Greenwood entry spans35 legal source studs Z1493..1528 and final occupancy OBB extends over that existing landing/street; City entry remains40 legal source studs. Floor/scenery geometry unchanged.
