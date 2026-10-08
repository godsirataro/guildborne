# Marketplace operations runbook

Operator API is a **server-only BindableFunction** under `ServerScriptService.Server.MarketOperations`. It exists only as a server capability; ordinary clients have no operator remote. Invocation is enabled in Studio or reserved/private staging servers. Public market is disabled by `Config/Market.PublicEnabled=false` and must remain so until live, device and soak gates pass.

Use a trusted server execution context in the reviewed staging/private build:

```lua
local ops = game.ServerScriptService.Server.MarketOperations
print(ops:Invoke("MarketHealth", "iron_ore"))
print(ops:Invoke("AuditEpoch", "iron_ore"))
```

Health includes currentEpoch, epochAge, phase, mode, activeOrders, pendingClaims, pendingRecovery, oldestPendingRecovery, archivedThrough, adapter health/metrics and circuit state. Projection age is `os.time() - adapterMetrics.projectionAt` when available; nil means unobserved, not healthy. `indexRebuildCount` counts publication attempts. Rejected admission counts include boundary and business rejections, not unique accounts. For all-item status invoke once per allowlisted material; never scan arbitrary worldwide keys.

| Action | Invocation / result |
| --- | --- |
| Read-only | `ops:Invoke("SetMode","iron_ore",{mode="READ_ONLY"})` blocks new orders, permits valid cancellation/claims |
| Pause | `ops:Invoke("SetMode","iron_ore",{mode="PAUSED"})` blocks book and profile market mutation; reads/core gameplay remain |
| Recovery status/current epoch/claim/order/archive status | `MarketHealth` fields above |
| Rebuild transient index | `ops:Invoke("RebuildIndex","iron_ore")`; publication coalesces for two seconds, then inspect cloud result |
| Safe recovery | `ops:Invoke("RecoveryAssist","iron_ore")`; does not bypass profile owners |
| Close | `ops:Invoke("CloseEpoch","iron_ore")`; ACTIVE becomes CLOSING, orders cancel into claims |
| Reconcile | `ops:Invoke("Reconcile","iron_ore")`; RecoveryPending means wait/collect, not force success |
| Archive | `ops:Invoke("Archive","iron_ore")`; requires RECONCILED and replay safety window |
| Start next | `ops:Invoke("StartEpoch","iron_ore")`; requires ARCHIVED, atomically prunes/fences old receipts |
| Resume reviewed healthy book | `ops:Invoke("SetMode","iron_ore",{mode="HEALTHY"})` after audit and incident review |

A local transport breaker becomes DEGRADED on failures and READ_ONLY after three failed attempts, with a 30-second cooldown. It permits reads and blocks market writes until a bounded retry window; a successful write restores health. A reconciliation mismatch latches PAUSED, including against late success from another in-flight operation; do not restart merely to clear it. Diagnose/fix the root cause before a reviewed server restart. Persisted item PAUSED is independent and survives restarts. Already-authorized profile settlement in flight on another server can finish before pause is observed; its acknowledgment safely waits. Pause never rewinds a committed credit. Pending claim pressure can put admission into READ_ONLY; after collection and audit, an operator may resume.

Market reads/writes reserve 20 platform requests; maintenance reserves 30. Maintenance defers before profile save/load/shutdown budgets are endangered. Distinct per-item write slots (0.5 seconds apart, at most two seconds of queued delay), bounded three-attempt exponential retries, ten-second read cache, two-second notification coalescing, fixed item rotation and bounded remote rate avoid continuous polling. These controls bound traffic per server; they do not prove unlimited global hot-item capacity. A hot item has at most 32 admissions/live orders and an independent key; global capacity is conservatively partitioned as min(per-item cap, floor(global cap/item slots)), currently 160 across five items.

Incident procedure: stop new activity, preserve namespace/config/revisions/JobIds and redacted error evidence, audit the book, reconstruct a consistent cohort checkpoint, and replay only durable authorized outcomes. Leave uncertain assets pending. Never clear receipts/watermarks, manually increase epoch, delete escrow, reset player profiles, edit order prices, mint guessed compensation, or run destructive probes against normal staging/prod keys. Do not downgrade to a v1 market writer. Changes to PublicEnabled and publishing require separate explicit approval.
