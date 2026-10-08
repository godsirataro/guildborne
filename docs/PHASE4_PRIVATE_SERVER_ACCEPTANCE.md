# Private cross-server marketplace acceptance — Phase 4.5

**TRUE CROSS-SERVER LIVE ACCEPTANCE: PENDING PRIVATE PUBLISH / PLATFORM ACCEPTANCE.** This runbook does not authorize publication. PublicEnabled stays false. Studio multiplayer has one server and no qualifying live JobId evidence.

## Prerequisites and prepared artifact

Use staging place **86788611613035**, universe **10768425213**, explicit publication approval, and at least two approved real test accounts. Their numeric IDs must be supplied; the build-only 101/102 fixture is not a live account configuration. Record approved source revision, config, UTC time, target concurrency and operator. Retain backup/version information without copying old traded profiles back over current claims.

Generate a fresh local artifact (substitute real numeric IDs and a unique run ID):

```powershell
python tools/prepare_private_market_acceptance.py --run-id ACCEPTANCE_RUN --users ACCOUNT_A ACCOUNT_B
```

The command accepts integers for accounts. It builds `build/private-acceptance-<run>/PrivateAcceptance.rbxlx` only; it never uploads. Use `--drop-messages` for the explicit missed-notification run. Both player and market stores use **qa45_<run>**, never normal staging/prod roots. The default source config remains disabled. Review the generated Runtime and included QA launcher before any authorized private publication.

After separate approval, privately publish the artifact to the staging place. The non-reserved QA lobby deliberately skips all profile loading; the dedicated launcher rejects non-allowlisted accounts and teleports each approved account to a distinct reserved server. Reserved servers run normal gameplay against the isolated profile/market namespace. Join records are saved in `GB_Accept_qa45_<run>/account:<id>`, containing JobId, private server ID, namespace, place and time, bounded to twenty joins/account. Never print reserved access codes.

The supported teleport path cannot run in Studio. See [Roblox teleport documentation](https://create.roblox.com/docs/projects/teleport) and [ReserveServerAsync](https://create.roblox.com/docs/reference/engine/classes/TeleportService/ReserveServerAsync). A Studio Edit-mode JobId is not live gameplay evidence. Before claiming cross-server success, assert **A.JobId and B.JobId are nonempty and unequal**. A third account/server is optional for the split-fill case.

## Exact baseline flow

On each fresh QA profile, select Warrior, complete the three existing quests, recruit all five companions and equip the earned Iron Sword (same normal progression as the Studio helper). Verify each begins market activity with **50 Gold and 6 Iron Ore**. Stop quests/combat and avoid shops/upgrades until reconciliation. Enter the Exchange through existing travel. Record original profile/book snapshots from a trusted server operator context:

```lua
local root = game.ServerScriptService.Server
local snapshot = root.PrivateAcceptanceProbe:Invoke("Evidence")
-- Save this private fixture evidence securely; do not send full profiles to ordinary clients.
local ops = root.MarketOperations
print(ops:Invoke("MarketHealth", "iron_ore"))
print(ops:Invoke("AuditEpoch", "iron_ore"))
```

A on Server A lists SELL LIMIT 5 ore at 10. Inventory becomes 1, item escrow 5. B on Server B submits immediate BUY 2 with maximum 12: reserves 24, pays 20, gets 4 improvement refund and 2 ore. B ends 30 Gold/8 ore. A collects 19 Gold (1 fee), ends 69 Gold/1 ore with 3 still in escrow. Cancel remainder from A after reconnecting to a different JobId; collect exactly 3 ore, cancel/replay again with no extra credit. End totals: **99 wallets +1 fee =100**, **12 ore**. Audit zero residual and no pending assets.

## Required additional cases

Run with fresh explicit checkpoints; do not reuse expected totals after unrelated faucets/sinks.

| Case | Operation and required evidence |
| --- | --- |
| Full fill | A lists 5 at 10; B buys 5. Fee 3, seller 97/1 ore, buyer 0/11 ore; total 97+3=100 and 12 ore. |
| Split fill | B buys 2, C (third JobId if available) buys remainder; cumulative fee totals 3, never 1+2 rounded incorrectly through arbitrary splits. |
| Seller offline | A lists, exits, B fills, A reconnects elsewhere. Exactly one proceeds application. |
| Buyer offline | B leaves a limit bid then exits; A crosses it, B reconnects and receives items once. |
| Cross-context cancel | Owner reconnects to a different server, cancels remainder, repeats cancel. Foreign account cancellation rejects. |
| Missed/duplicate messages | Run the artifact built with --drop-messages; wait past ten-second cache TTL. Reads refresh; economic outcomes remain unchanged. Duplicate hints must only invalidate. |
| MemoryStore loss | `root.PrivateAcceptanceProbe:Invoke("DropProjection")`, then `ops:Invoke("RebuildIndex","iron_ore")`; wait >2 seconds, inspect restored bid/ask/remaining quantities. Only qa45 disposable depth is removed. |
| Server disappears after match | Record committed trade/claims, terminate that QA server, reconnect participants. No duplicate fill/fee. |
| Owner disappears before claim / both return later | Leave after durable claim creation, before credit; rejoin and collect. Use controlled QA faults/checkpoints, never guess whether a write committed. |
| Rollover | Close, observe blocked new orders and pending claims, collect, Reconcile, wait replay window, Archive, StartEpoch. Old generation replay rejects; 30D chart retains old execution. |
| Storage/circuit pressure | Bounded agreed-rate traffic, inspect live budgets/retries/backlog. Stop before profile-save starvation. No intentional flood against shared normal namespaces. |

Use [operations](MARKET_OPERATIONS_RUNBOOK.md) for server-only commands. No ordinary-client admin interface is added. Controlled hard crash timing may need a reviewed QA build and Roblox process/platform controls; mark unexecuted checkpoints pending rather than inferring them from disconnect alone.

## Reconcile, soak and close

After each checkpoint, stop cohort gameplay, collect all pending outcomes, snapshot book and all cohort profiles, and call `MarketReconciliation` with the starting totals and explicit outside faucet/sink adjustments. Repeat snapshots if revisions move during capture. A book audit alone is not a whole-wallet supply proof. Require **zero Gold/item/fee/claim residuals**, record all separate JobIds, operation/claim IDs, namespace, configs and timestamps.

For private soak, agree target concurrent accounts and duration first; minimum acceptance proposal is 30 minutes of mixed create/fill/cancel/recovery and one rollover, followed by zero-backlog reconciliation. Record p50/p95/p99 latency, request budgets, throttles, retries, bytes, oldest pending age and core profile-save latency. This proposal has NOT been executed or certified. Complete [physical device acceptance](PHASE4_5_MOBILE_DEVICE_ACCEPTANCE.md) separately.

Preserve redacted evidence; stop test servers; return to the normal staging artifact only through the approved publication workflow. Do not clear ordinary saves, delete pending claims, mint compensation, or enable public market. Mark each case PASS/FAIL/PENDING with its evidence. Publication and public release are distinct approvals; this task performs neither.
