--!strict
local Window=require("../src/shared/Data/RequestWindow")
return function(test:any,eq:any)
    test("old UI timer cannot unlock a newer pending request",function()
        local w=Window.new();eq(Window.begin(w,"a","iron:1D"),true)
        eq(Window.finish(w,"a"),true);eq(Window.begin(w,"b","wood:1D"),true)
        eq(Window.timeout(w,"a"),false);eq(w.pending,true);eq(w.id,"b")
        eq(Window.begin(w,"c","stone:1D"),false);eq(w.context,"wood:1D")
    end)
    test("late and duplicate UI responses cannot overwrite the latest selection",function()
        local w=Window.new();Window.begin(w,"a","iron:1D");eq(Window.timeout(w,"a"),true)
        Window.begin(w,"b","wood:1H");eq(Window.finish(w,"a"),false);eq(w.pending,true)
        local invalid: {any}={false,{},42,"unrelated"}
        for _,id in ipairs(invalid) do eq(Window.finish(w,id),false) end
        eq(Window.finish(w,nil),false)
        local ok,context=Window.finish(w,"b");eq(ok,true);eq(context,"wood:1H");eq(w.pending,false)
        eq(Window.finish(w,"b"),false);eq(Window.timeout(w,"b"),false)
    end)
    test("current late response recovers timeout without resubmitting a mutation",function()
        local w=Window.new();Window.begin(w,"create-1","iron:1D:Detail")
        eq(Window.timeout(w,"create-1"),true);eq(Window.timeout(w,"create-1"),false)
        local ok,context=Window.finish(w,"create-1");eq(ok,true);eq(context,"iron:1D:Detail");eq(w.id,nil)
    end)
    test("market invalid-request errors preserve only a safe correlation ID",function()
        local p=require("../src/server/Systems/MarketProtocol")({}, {})
        eq(p.errorResponse({requestId="valid-123"},"InvalidRequest"),{code="InvalidRequest",requestId="valid-123"})
        local invalid: {any}={"",string.rep("a",41),"unsafe/id",123,{}}
        for _,id in ipairs(invalid) do eq(p.errorResponse({requestId=id},"InvalidRequest").requestId,nil) end
        eq(p.busyResponse({requestId="valid-123"}).code,"MarketBusy")
    end)
end
