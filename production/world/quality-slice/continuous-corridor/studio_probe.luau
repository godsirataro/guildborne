--!strict
-- Controller-only opt-in probe. No movement, progression, profiles or publishing.
return function(world: Instance): any
 local model=world:FindFirstChild("CityGreenwoodCorridor")
 assert(model and model:IsA("Model"),"Missing explicitly activated corridor")
 local floors=0
 for _,part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") and string.sub(part.Name,1,5)=="Road_" then
   assert(part.CanCollide and part.CanQuery and part.Anchored,"Broken floor flags");floors+=1
  end
 end
 assert(floors==148,"Unexpected static floor count")
 local coordinates={
 {0,0.55,-664},
 {0,0.55,-625},
 {0,0.55,-605},
 {-60,1.03333333333,-563.333333333},
 {-120,1.51666666667,-521.666666667},
 {-180,2,-480},
 {-215,2.75,-422.5},
 {-250,3.5,-365},
 {-285,4.25,-307.5},
 {-320,5,-250},
 {-323.333333333,5.16666666667,-178.333333333},
 {-326.666666667,5.33333333333,-106.666666667},
 {-330,5.5,-35},
 {-333.333333333,5.66666666667,36.6666666667},
 {-336.666666667,5.83333333333,108.333333333},
 {-340,6,180},
 {-324,5.6,254},
 {-308,5.2,328},
 {-292,4.8,402},
 {-276,4.4,476},
 {-260,4,550},
 {-260,4.14285714286,628.571428571},
 {-260,4.28571428571,707.142857143},
 {-260,4.42857142857,785.714285714},
 {-260,4.57142857143,864.285714286},
 {-260,4.71428571429,942.857142857},
 {-260,4.85714285714,1021.42857143},
 {-260,5,1100},
 {-246.666666667,4.5,1175},
 {-233.333333333,4,1250},
 {-220,3.5,1325},
 {-206.666666667,3,1400},
 {-193.333333333,2.5,1475},
 {-180,2,1550},
 {-120,2,1550},
 {-60,2,1550},
 {0,2,1550},
 {0,2,1526}
 }
 local points={};for _,v in ipairs(coordinates)do table.insert(points,Vector3.new(v[1],v[2]+3,v[3]))end
 table.insert(points,1,Vector3.new(0,5,-720));table.insert(points,Vector3.new(0,7,1505))
 local reports={}
 for i=1,#points-1 do
  local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false,WaypointSpacing=8})
  local ok,err=pcall(function()path:ComputeAsync(points[i],points[i+1])end)
  table.insert(reports,{index=i,ok=ok and path.Status==Enum.PathStatus.Success,error=if ok then tostring(path.Status) else tostring(err),waypoints=if ok then #path:GetWaypoints() else 0})
  path:Destroy()
 end
 local passed=0;for _,r in ipairs(reports)do if r.ok then passed+=1 end end
 return {scope="ENGINE_PATHS_ONLY_NOT_PLAYER_OR_FIVE_HERO_ACCEPTANCE",colliders=floors,passed=passed,total=#reports,routes=reports}
end
