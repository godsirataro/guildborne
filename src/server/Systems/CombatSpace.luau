--!strict
-- One authoritative camp boundary shared by AI damage and receipt-time commands.
-- Region combat is deliberately not enabled merely by having a map model.
return function(city:any)
    local S={}
    local function finite(n:any):boolean return type(n)=="number" and n==n and n> -math.huge and n<math.huge end
    function S.contains(session:any,position:any):boolean
        local origin=session and session.origin
        if not origin or not position or not finite(position.X) or not finite(position.Y) or not finite(position.Z) then return false end
        if session.adventureRegion then
            return session.adventureEnabled==true and city.regionCombat(session.adventureRegion,position.X,position.Y,position.Z)
        end
        return city.allowsCombat(position.X,position.Y,position.Z,origin.X,origin.Y)
    end
    function S.hostile(a:any,b:any):boolean
        if not a or not b or not a.root or not b.root then return false end
        if a.session and b.session and a.session~=b.session then return false end
        local session=a.session or b.session
        return S.contains(session,a.root.Position) and S.contains(session,b.root.Position)
    end
    return S
end
