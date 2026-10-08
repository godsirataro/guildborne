# Phase 4.5 load and chaos evidence

Deterministic tests use the actual market/profile transforms and PlayerDataService with shared storage and separate service owners. They are CPU/adversarial scheduling tests, not native independent Roblox servers or a cloud capacity benchmark.

The regular suite executes 5,000 accepted orders (2,500 alternating seller/buyer cycles), claim settlement, 63 complete epoch transitions, profile compaction and invariant/cohort reconciliation after each cycle. A separate sustained run executed four fresh cohorts: **20,000 orders, 10,000 cycles, 252 rollovers, 228.374 seconds, zero invariant violations**. Per-run throughput was 86.71, 88.08, 87.98 and 87.74 orders/sec; pair-operation p95 was 38.14–39.39 ms. See [raw soak log](evidence/phase45-soak.txt). These timings include local profile validation/copying/audit export and are not expected cloud throughput. No 24-hour soak is claimed.

All runs keep one fixed authority key for the tested item, prune old receipts safely, retain at most 32 epoch summaries and leave no retained terminal profile transfer records after compaction. The regular final suite also invokes the explicit `MarketReconciliation` module with closed-cohort starting balances after every cycle. Any residual fails the test; failures are not averaged away.

## Fault coverage

| Checkpoint / scenario | Executed path |
| --- | --- |
| Item/Gold reserve committed, response lost | Profile adapter fails after commit; Refresh resolves owner journal, recovery completes once |
| Before/after durable ticket/order/match writes | Injected adapter failures and original Phase 4 uncertain-outcome tests; immutable replay preserves balances |
| Claim credit before ack / repeated claim / duplicate refund | Unknown profile write, refresh, repeated recovery; watermark and source state prevent duplicates |
| Cancel versus fill / competing fill / retried callback | Shared deterministic adapter interleaves independent services; priority/quantity/conservation asserted |
| Cache/index fails after durable commit | Changed callback throws; source commits persist and rebuild reads authority |
| Durable write fails while stale cache exists | Matching never trusts projection; no new economic effect from the cache |
| Total MemoryStore loss / duplicate or absent messaging | Projections discarded, repeated rebuild; actual cloud remove/TTL and unsubscribed-reader path additionally executed |
| Recovery crash/restart / repeated recovery | Adapter after-write exception followed by retries; exact-once net results |
| Owner leaves/returns during settlement | Closing session rejects credit; active owner refresh/recovery resumes; original session-lock suite retained |
| Epoch closes with open order or pending claim | All remainder becomes claims; Reconcile returns RecoveryPending until delivery; stale generations fenced |
| Lease expires | Matching has no transient lease; duplicate/stale workers serialize on single-key CAS. Existing profile lease tests remain mandatory. |
| Corrupt Gold/item/claim state | Read-only audit fails, no repair mint; invariant circuit latches PAUSED |
| Throttling/budget exhaustion | Pure breaker/budget tests check reserved profile headroom, threshold/cooldown; real platform throttling was not deliberately induced |

Fault hooks live in test adapters, not production remotes. Simulated timing/interleaving does not replace kill/reconnect tests on independent live JobIds.

## Cloud and native measurements

The [final paced-adapter retest](evidence/phase45-final-cloud.json), isolated namespace qa45_1790659451, passed in 21.41 seconds: 14 durable writes, two reads, four projection writes, two rebuilds, two notifications and zero failures. Write p50 was 516.23 ms and p95 1,416.79 ms; the final book was 927 bytes with epoch 2, one archived fee and two chart units. Profile writes remained zero. This is a smoke test, not a cloud soak.

[Actual cloud test](evidence/phase45-cloud.json): isolated qa45_1790658517, 14 DataStore writes, two reads through another adapter, four MemoryStore projection writes, two observed notifications, zero adapter failures. Completed in 24.68 seconds; write-operation p50 981.76 ms, p95 1,318.01 ms. Archive/restart reduced this synthetic ledger to 927 JSON bytes, retained two traded units in the chart and one burned fee. It tested removal, rebuild and two-second expiry. The independent reader intentionally did not subscribe and refreshed correctly after its one-second test cache TTL. No player profiles were written. This is a smoke test, not sustained cloud load.

Four actual Studio clients with twenty followers: 180 Heartbeat samples, mean 16.66 ms, p95 18.10 ms, max 20.10 ms. Core gameplay continued during market pause. Cloud write pacing is 0.5 seconds per item/server, admission 32/item and 160 partitioned global slots; recovery skips low-budget periods. Multiple servers still share a hot authority key. Private soak must measure concurrent throttling, backlog, p50/p95/p99, serialized size and save latency before scaling. A low-end phone was not measured.

Re-run:

```powershell
.\tools\validate.ps1
.\.tools\luau\luau.exe tests/market_soak.luau
```

The native cloud probe is [studio_market_cloud_hardening_probe.luau](../tests/studio_market_cloud_hardening_probe.luau); execute only in a Studio server against its generated isolated namespace. Its synthetic source confirmations/claim acknowledgments are fixture transitions, not evidence of live player-profile delivery.
