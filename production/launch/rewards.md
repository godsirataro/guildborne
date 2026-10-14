# Launch rewards preview

The preview adds seven rotating daily material rewards and six story-earned free/Premium tiers. It does not create a dated season, sell products, grant Premium ownership, or enable commerce. Premium claims are disabled in the default config; product and pass IDs remain zero.

Daily claims use the server UTC day. Missing days retain the next reward; clocks moving backwards cannot reopen an already claimed day. Rewards and claim markers must commit together through Commands and PlayerDataService. Inventory-full failures retain eligibility.

Story tiers correspond to campaign claimed indices 6–11: MAIN_01_06 then MAIN_02_01 through MAIN_02_05. The server derives availability from stored campaign progress. No client progress or time fields are accepted. Claim keys are bounded string keys 1–6, and free/Premium tracks are independent. Verified ownership integration remains future work; no public ownership setter exists.

## Integration contract

Factory `LaunchRewards(Content, Util, Economy, Config)` exposes `new()`, `validate(extension?)`, `migrate(data)`, `apply(data, action, args, now, emit)` and `view(data, now)`. Nil extensions validate for old profiles; migration only adds defaults after validating existing data. Invalid existing extensions must reject profile load. Existing schema versions, progression and purchase receipts remain unchanged.

`apply` returns `problem, reward`. It requires a disposable transaction copy, as do existing economy modules. Commands must discard on problem and return `result.reward` on success. Project only `view` under `view.data.launchRewards`, not the raw extension. UI factory takes `{scroll,T,card,text,button,act}` and returns `(snapshot,busy)`.

The stored extension is v1, with daily counter/day and one explicitly named preview season. Unknown seasons reject rather than overwrite receipts. A future season rollover requires a migration/retention design; changing SeasonId is not a safe reset mechanism.

Standalone domain checks: `tests/run_launch_rewards.luau`. Persistent uncertain writes, session fencing, full-game UI and Studio acceptance must be tested by integration; domain tests alone do not establish those facts.
