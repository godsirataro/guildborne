-- Pure import/presentation contract, not Studio animation or combat acceptance.
local C = require("../src/shared/Config/EnemyVisualAssets")
assert(C.Enabled == false and C.Status == "UNBOUND")
assert(C.Assets.greenwood_scout.sourceModel == "Big/Tribal")
assert(C.Assets.forest_captain.sourceModel == "Big/Monkroose")
for _, asset in pairs(C.Assets) do assert(asset.runtimeAssetId == nil and asset.joints == 43 and asset.clips == 14) end
assert(not C.Clips.Weapon.looped and not C.Clips.Punch.looped and not C.Clips.Death.looped)
local s = {EncounterId = "greenwood_scout", generation = "model1:spawn1", present = true, CombatState = "Idle", CombatHealth = 100}
local function select(patch, now)
    local snapshot = table.clone(s)
    for key, value in pairs(patch) do snapshot[key] = value end
    return C.select(snapshot, now or 10)
end
assert(select({}).state == "Idle")
assert(select({CombatState = "Approach"}).clip == "Walk")
assert(select({CombatState = "ReturnToLeader"}).looped)
assert(select({present = false}) == nil and select({EncounterId = "unknown"}) == nil)
assert(select({}, math.huge) == nil and select({}, 0/0) == nil)
for _, stamp in ipairs({0, -1, 11, 0/0, math.huge, -math.huge, 9}) do
    assert(select({EnemyActionAt = stamp, RegionalImpactAt = stamp, DamageCueAt = stamp}).state == "Idle")
end
local accepted = select({EnemyActionAt = 10}, 10)
local duplicate = select({EnemyActionAt = 10}, 10.1)
assert(accepted.state == "ConfirmedImpact" and accepted.clip == nil)
assert(accepted.key == duplicate.key and duplicate.offset > accepted.offset)
assert(select({EnemyActionAt = 10}, 10.2).state == "Idle", "Expired impact replayed")
assert(select({EnemyActionAt = 10.1}, 10.1).key ~= accepted.key, "Replacement must change playback identity")
assert(select({EnemyActionAt = 10, generation = "model2:spawn1"}).key ~= accepted.key)
assert(select({EnemyActionAt = 10, generation = "model1:spawn2"}).key ~= accepted.key)
local warning = {CombatState = "Windup", RegionalTelegraphAt = 9, RegionalTelegraphUntil = 11, EnemyActionAt = 10}
assert(select(warning).state == "Telegraph" and select(warning).clip == nil)
assert(select(warning, 11).state == "Idle", "Telegraph did not expire")
warning.CombatState = "Idle"
assert(select(warning, 10.5).state == "Idle", "Cancelled windup retained warning")
assert(select({RegionalImpactAt = 10, DamageCueAt = 10}).state == "ConfirmedImpact")
assert(select({RegionalImpactAt = 10, EnemyActionAt = 11}).state == "ConfirmedImpact", "Future action masked valid impact")
assert(select({RegionalImpactAt = math.huge, EnemyActionAt = 10}).state == "ConfirmedImpact")
assert(select({DamageCueAt = 9.8}).clip == "HitReact")
assert(select({DamageCueAt = 9.8}, 10.5).state == "Idle")
-- Healing publishes Feedback/FeedbackAt, but never a new DamageCueAt.
assert(select({FeedbackAt = 10, Feedback = "+20"}).state == "Idle", "Heal triggered hit reaction")
assert(select({FeedbackAt = 10, Feedback = "+20", DamageCueAt = 9}).state == "Idle", "Heal refreshed stale damage")
local priorHit = select({DamageCueAt = 9.8}, 9.9)
local healed = select({DamageCueAt = 9.8, FeedbackAt = 10, Feedback = "+20"})
assert(priorHit.key == healed.key and healed.offset > priorHit.offset, "Heal restarted prior hit")
local dead = select({CombatHealth = 0, EnemyActionAt = 10, DamageCueAt = 10, observedDeathAt = 9.8})
assert(dead.state == "Dead" and dead.clip == "Death" and not dead.looped)
assert(math.abs(dead.offset - 0.2) < 0.00001)
assert(select({CombatState = "Dead"}).offset == C.Clips.Death.duration)
assert(select({CombatHealth = 0, observedDeathAt = 9}, 11).offset == C.Clips.Death.duration)
assert(select({present = false, CombatHealth = 0}) == nil, "Removal must stop even death playback")
assert(select({generation = "model1:spawn2"}).state == "Idle", "Fresh generation inherited death")
print("PASS enemy quality: unbound assets, finite clocks, duplicate/replacement identity, warning cancellation, death/removal and respawn selection")
