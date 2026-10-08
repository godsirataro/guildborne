--!strict
-- Correlates a single UI request, including a late reply after timeout.
-- A superseded reply/timer must never unlock or overwrite the current request.
export type Window = {id: string?, pending: boolean, context: string?}
local Window={}
function Window.new(): Window return {pending=false} end
function Window.begin(state: Window,id: string,context: string): boolean
    if state.pending then return false end
    state.id=id;state.context=context;state.pending=true;return true
end
function Window.timeout(state: Window,id: string): boolean
    if state.id~=id or not state.pending then return false end
    state.pending=false;return true
end
function Window.finish(state: Window,id: any): (boolean,string?)
    if type(id)~="string" or state.id~=id then return false,nil end
    local context=state.context;state.id=nil;state.context=nil;state.pending=false
    return true,context
end
return Window
