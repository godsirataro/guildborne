--!strict
-- Opt-in import contract only: no runtime consumer, uploads, hit timing or grants.
local C = {
    Enabled = false,
    Status = "UNBOUND",
    License = "CC0-1.0",
    Source = "Quaternius Ultimate Monsters",
    Assets = {
        greenwood_scout = {sourceModel = "Big/Tribal", joints = 43, clips = 14, triangles = 6620, runtimeAssetId = nil},
        forest_captain = {sourceModel = "Big/Monkroose", joints = 43, clips = 14, triangles = 5824, runtimeAssetId = nil},
    },
    -- Measured glTF accessor spans. Weapon/Punch contact frames are NOT verified.
    Clips = {
        Idle = {duration = 1, looped = true},
        Walk = {duration = 1, looped = true},
        Run = {duration = 0.5666667, looped = true},
        Weapon = {duration = 0.8666667, looped = false},
        Punch = {duration = 0.8666667, looped = false},
        HitReact = {duration = 0.6, looped = false},
        Death = {duration = 0.7666667, looped = false},
    },
}

export type Snapshot = {
    EncounterId: string,
    -- Caller supplies a fresh identity on replacement/respawn; model attrs do not
    -- currently replicate the server generation. Never reuse local death state.
    generation: string,
    present: boolean,
    CombatState: string?,
    CombatHealth: number?,
    EnemyActionAt: number?,
    RegionalTelegraphAt: number?,
    RegionalTelegraphUntil: number?,
    RegionalImpactAt: number?,
    -- CombatService publishes this only for damage; FeedbackAt also includes heals.
    DamageCueAt: number?,
    -- Local first-observed death time in server clock, scoped to generation.
    observedDeathAt: number?,
}
export type Selection = {state: string, key: string, clip: string?, offset: number, looped: boolean}

local function finite(value: number?): boolean
    return value ~= nil and value == value and math.abs(value) < math.huge
end
local function age(stamp: number?, now: number, duration: number): number?
    if not finite(stamp) or (stamp :: number) <= 0 then return nil end
    local elapsed = now - (stamp :: number)
    return if elapsed >= 0 and elapsed < duration then elapsed else nil
end

-- Pure selection, not a playback scheduler. Consumers reuse key rather than
-- restarting tracks each frame; offset seeks late observations and never rewinds.
-- A nil result means stop/remove all presentation for this actor.
function C.select(s: Snapshot, now: number): Selection?
    if not s.present or not finite(now) or not C.Assets[s.EncounterId] then return nil end
    local function result(state: string, clip: string?, offset: number, looped: boolean, stamp: number?): Selection
        return {state = state, clip = clip, offset = offset, looped = looped,
            key = s.generation .. ":" .. state .. ":" .. tostring(stamp or "state")}
    end
    if s.CombatState == "Dead" or (finite(s.CombatHealth) and (s.CombatHealth :: number) <= 0) then
        local duration = C.Clips.Death.duration
        -- Unknown/late death holds the authored final pose instead of replaying.
        local elapsed = age(s.observedDeathAt, now, duration)
        return result("Dead", "Death", elapsed or duration, false, nil)
    end
    if s.CombatState == "Windup" and finite(s.RegionalTelegraphUntil) then
        local untilTime = s.RegionalTelegraphUntil :: number
        local started = s.RegionalTelegraphAt
        if finite(started) and (started :: number) > 0 and now >= (started :: number) and now < untilTime then
            -- No guessed Weapon retiming: keep the existing authoritative warning.
            return result("Telegraph", nil, now - (started :: number), false, started)
        end
    end
    -- Cosmetic observation window, NOT clip/contact duration or attack authority.
    local impactAt = if age(s.RegionalImpactAt, now, 0.18) then s.RegionalImpactAt else nil
    if age(s.EnemyActionAt, now, 0.18) and (impactAt == nil or (s.EnemyActionAt :: number) > impactAt) then
        impactAt = s.EnemyActionAt
    end
    local impactAge = age(impactAt, now, 0.18)
    if impactAge then return result("ConfirmedImpact", nil, impactAge, false, impactAt) end
    local hitAge = age(s.DamageCueAt, now, C.Clips.HitReact.duration)
    if hitAge then return result("Hit", "HitReact", hitAge, false, s.DamageCueAt) end
    local moving = s.CombatState == "Approach" or s.CombatState == "ReturnToLeader"
    return result(if moving then "Moving" else "Idle", if moving then "Walk" else "Idle", 0, true, nil)
end

return C
