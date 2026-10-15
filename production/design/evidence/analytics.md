# Product analytics foundation

This change adds an optional sanitized product stream; it does not activate external telemetry, measure conversion, or replace the durable economic audit. Existing `AnalyticsAdapter.Emit` keeps its original business-event behavior.

`AnalyticsContract.sanitize` accepts only `onboarding_milestone` with `{version=1,milestone,elapsedSeconds}`. Milestones are fixed enums, elapsed seconds are integers 0–86400, and unknown fields reject the whole event. Names, user/hero/run/purchase/encounter IDs, coordinates and arbitrary text are not product payload fields. `AnalyticsAdapter.Product` delivers only validated copies and isolates provider/logging errors and provider mutation.

`OnboardingFunnel({Now,Emit})` supplies `Begin(userId)`, `Observe(userId,event,payload)`, `End(userId)`. User ID is internal routing context only, never part of the product payload. The clock is injected monotonic time. Capacity is 256 concurrent sessions; cleanup removes each departing session. Duplicate Begin does not reset progress. Rejoining starts a new observation session, not a claim that the player is new.

Independent session milestones: ready, class selected, personal Guild founded, first NPC recruited, first effective player damage/healing, first accepted hero order, first committed combat reward, first campaign chapter claim. Later milestones never imply missing earlier ones. A founding event also records the NPC recruitment it actually grants. Combat intents, zero/invalid healing, unknown orders and observations before Begin do not qualify.

## Hook ownership

Coordinator connects Begin after successful profile readiness, observes committed events from `PlayerDataService.OnCommitted`, and calls End on drain. Combat observer emits `combat_player_damage` / `combat_player_heal` with positive effective amount and `hero_order_accepted` with an allowlisted order. Bootstrap resolves the internal user ID to the live Player and forwards funnel events through `Analytics.Product`. Existing runtime provider flag remains unchanged/off. This foundation alone does not send Roblox funnel API events or enable client performance collection.

Provider delivery is best effort: crashes can lose milestones, and separate sessions can repeat them. Marking a milestone precedes provider delivery, so a failed provider does not trigger uncontrolled retries. Counts are session observations, not unique-player retention or an exactly-once ledger. Audit replay must not be used to invent historical session timing.

## Deferred delivery correction (2026-10-14)

`Product` now schedules provider/log work through an optional fourth `Defer` argument (runtime default `task.defer`). The payload and provider list are copied before scheduling. At most 32 deliveries may be pending per adapter; yielding work retains its slot, and excess events return false without retry. A scheduler error releases its slot. Each log/provider still receives an isolated payload copy and errors remain protected. The legacy `Emit` path is unchanged. This prevents a yielding product provider from suspending the authoritative gameplay caller; it does not promise delivery or provider completion.

Focused verification: `.tools/luau/luau.exe tests/run_analytics_foundation.luau` passed **7 checks**. The new coroutine-backed scheduler fixture proves immediate return before any provider/log call, a yielding provider retaining capacity, backpressure at 32, capacity recovery on completion, mutation isolation after scheduling, and scheduler failure handling. This is local Luau evidence only; integrated runtime and independent review remain coordinator-owned.

## Verification

Run `tests/run_analytics_foundation.luau` for contract rejection, bounded clocks, independent/replayed/rejoined milestones, effective combat, order enums, per-provider copies, provider/log failures, legacy Emit compatibility and session capacity/cleanup. Full integration and Studio hook verification remain separate evidence; no real traffic or retention results are asserted here.
