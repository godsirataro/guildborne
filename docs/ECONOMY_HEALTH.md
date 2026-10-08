# Economy health and analytics

> Phase 4.5 update (2026-09-29): Current operator diagnostics expose generation, phase/mode, active orders, pending claims/source recovery and oldest age, adapter metrics and breaker state. MarketReconciliation audits consistent closed-cohort snapshots; live global supply is not falsely presented as atomic.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): Phase 4 durable trades record gross, fee, net, parties and time; public views remove identities. Book fee totals, profile market transfer counters and adapter read/write/failure metrics support reconciliation. A dedicated production analytics export/alert pipeline remains future operational work. Reference diversity/outlier filters do not automatically punish accounts.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


Status: Phase 0 measurement design retained. Phase 1 implements committed event outboxes, immutable per-player archive pages and an injected analytics adapter with Studio logging. See [implementation](PHASE1_IMPLEMENTATION.md). Dashboards/cohort reporting below remain future work; Phase 10 expands the foundation.

## Sources of truth

Use committed economic audit records for conservation and trade history. Use product analytics for behavior/funnels and operational logs for failures/latency. An analytics chart is not the asset ledger. Telemetry delivery can be missing or duplicated; surface coverage, lag, and reconciliation status alongside every economic conclusion.

Proposed pipeline: domain commit + bounded audit outbox → idempotent archive consumer → bounded daily/item/cohort summaries → dashboards/investigation. In Phase 1, a small durable per-player audit archive and local debug adapter are sufficient; no external warehouse is required. Sampling is allowed for presentation/performance events, never for money/item conservation. Do not write one global statistics key on every mutation.

## Metric definitions

| Metric | Definition and important caveat | Cadence |
| --- | --- | --- |
| Gold created | Sum positive authorized faucet deltas by reason and config revision | Hour/day |
| Gold destroyed | Sum explicit sink deltas, including execution fees | Hour/day |
| Total Gold supply | All wallets + guild treasury + market escrow/claims + in-flight value counted once | Daily reconciled estimate/checkpoint |
| Conservation residual | Ending supply − starting supply − created + destroyed − authorized correction delta | Every reconciliation batch; target exactly zero |
| Item supply | Counts by definition, binding, upgrade tier; include escrow/pending once | Day |
| Item creation/destruction | Separate acquisition from new creation; crafting transforms inputs to outputs | Hour/day |
| Market volume | Executed units and gross Gold; exclude canceled orders, show suspect fraction separately | Minute/hour/day |
| Active traders | Distinct users with at least one committed fill in the window; each user counted once | Day/week |
| Median price | Unweighted median executed unit price; publish raw and robust reference separately | Hour/day |
| VWAP | Sum(price × quantity) / sum(quantity), absent when volume is zero | Hour/day |
| Spread/depth | Best ask − best bid; quantities near current reference; absent sides remain absent | Snapshot |
| Inflation/deflation | Change in fixed-basket price index using qualifying item references | Day/week |
| Currency velocity | Eligible market gross Gold over period / average circulating Gold during same period | Day/week |
| Wealth distribution | P10/P50/P90/P99 wallet+escrow Gold, top 1% share, and Gini; separate dormant/active cohorts | Week |
| Shortage | Low stock/depth, increasing fill time and price, rising failed demand | Hour/day |
| Oversupply | High days-of-supply, slow sell-through, declining robust price | Day/week |
| Economic accessibility | Median and P75 minutes to afford a standard useful upgrade from legitimate play | Week/cohort |

Circulating Gold excludes burned value; report player-accessible balances and locked escrow separately. For velocity use an average of daily reconciled snapshots, not just today's rich online players. Define dormant as no session in the past 30 days for the first analysis, and show whole-population versus 30-day-active estimates. Inventory wealth valuation is a separate approximate report, never mixed into actual Gold supply without labeling it.

Transfers appear in two records but are one logical asset movement. Resolve the source/destination ownership state using the transfer receipt rules in [data model](DATA_MODEL.md). If a live global snapshot cannot be aligned, publish an estimate with cutoff, coverage, unresolved amount, and reconciliation lag. Do not advertise a strongly consistent live global supply total.

## Price index and diagnosis

Choose a fixed starter-material/consumable basket at market launch, with documented baseline quantities `q_i` and baseline qualifying prices `p_i0`. Index at time t = `100 × sum(q_i × p_it) / sum(q_i × p_i0)`. Rebalance the basket only on an announced version change; compare overlapping series. Show coverage and mark stale references; suppress the headline if less than 80% of baseline basket value has qualifying current data. Sparse/no-market Phase 1 has no inflation metric yet.

Separate an economy-wide price trend from a single recipe change or war-driven ore shortage. Compare Gold per active minute, net issuance, material outputs, destruction, active population, regional events, and content revisions. Deflation can indicate excessive sinks, lower activity, oversupply, or improved production; it does not automatically require a Gold faucet.

## Event contract and catalog

Internal events have eventId, schemaVersion, occurredAt, sessionId where relevant, userId where relevant, operationId for committed changes, domain revision, content/config version, eventName, and a small validated payload. Internal IDs are for audit/deduplication, not unbounded analytics custom-field dimensions. Security rejection events are rate-limited and never include raw hostile payloads.

| Event | Trigger / minimum domain payload | Phase |
| --- | --- | --- |
| `session_started` | Profile becomes active; platform, cohort, load duration | 1 |
| `session_ended` | Best-effort session close; duration, close reason; missing close is expected on crash | 1 |
| `tutorial_started` | First persisted tutorial start | 1 |
| `tutorial_completed` | Hall milestone flow finished, once per tutorial version | 1 |
| `adventurer_recruited` | Committed recruit; classId, cost reason | 1 |
| `party_created` | First valid NPC party; roster size | 1 |
| `quest_started` | Durable run start; questId, runId, duration | 1 |
| `quest_completed` | Durable reward claim; runId, first/repeat, Gold/XP summary | 1 |
| `item_acquired` | Credited item; definitionId, quantity, source, created-versus-transferred | 1 |
| `item_destroyed` | Consumed item; definitionId, quantity, sink reason | 1 |
| `craft_completed` | Committed recipe; recipeId, revision, quantities and fee | 2 |
| `guild_upgraded` | Personal Guild building commit; buildingId, from/to level, cost | 1 |
| `market_opened` | Debounced interaction, validated server observation; not an economic fact | 4 |
| `market_order_created` | Funded accepted order; side/kind/item/quantity | 4 |
| `market_order_filled` | One committed fill ID; two counterparties, gross/fee/quantity | 4 |
| `market_order_cancelled` | Durable cancel of remaining quantity; expired uses a distinct reason | 4 |
| `player_guild_joined` | Membership handshake active on both sides | 5 |
| `guild_war_joined` | Validated admitted participant; matchId/role | 7 |
| `guild_war_completed` | Final result participation; resultId, outcome; dedupe per participant | 7 |
| `purchase_attempted` | Server-approved prompt intent; product/benefit category | 9 |
| `purchase_completed` | Verified durable entitlement grant; receipt correlation in private audit only | 9 |

Add internal `gold_created`, `gold_destroyed`, `transfer_prepared`, `transfer_committed`, `recovery_pending`, `persistence_failed`, and `audit_backlog` where needed. Do not log gross buyer debits as destruction and seller proceeds as creation in the global supply model. If an analytics API models wallet movements as source/sink, label transfers distinctly and exclude them from global issuance queries.

Roblox's custom events are server-side and require a published experience; Studio uses a local debug sink. Keep the stable event-name vocabulary bounded. Use a tutorial funnel for progression steps and economy/custom adapters for other events. [Custom events](https://create.roblox.com/docs/production/analytics/custom-events)

The Roblox projection chooses at most three low-cardinality fields per event (for example feature, progression band, config cohort). Full operation/trade/user identifiers remain in private audit records. Respect the current global event budget and group low-priority repetitive telemetry; never let analytics failure turn a committed reward into a failed response. [Event limits](https://create.roblox.com/docs/production/analytics/event-types), [Custom fields](https://create.roblox.com/docs/production/analytics/custom-fields)

## Manipulation investigation hooks

| Signal | Initial heuristic for evaluation, not proof | False-positive examples |
| --- | --- | --- |
| Wash trading | Large repeated A↔B volume with little net inventory change | Friends exchanging crafting inputs |
| Extreme price deviation | Fill far outside robust median/MAD band and unusually large notional | Scarce new item, genuine supply shock |
| Abnormal volume | Item/user volume several times its trailing baseline | Event demand, returning high-volume crafter |
| Rapid flipping | Repeated short holding periods combined with counterparty concentration | Legitimate market makers |
| Coordinated activity | Overlapping trade cycles, time clustering, resource flow concentration | Organized guild production |

Store rule version, evidence IDs, time window, baseline coverage, and confidence. Suppress unreliable rules during cold start or missing data. Only human review can turn a heuristic into enforcement; the reference algorithm's statistical outlier treatment is not punishment.

## Alerts and actions

Initial operational targets: any confirmed conservation residual triggers investigation; unresolved transfers older than 5 minutes alert operators; archive lag over 15 minutes warns; 70% of an application byte/queue cap warns and admission closes before exhausting recovery headroom. These are project thresholds requiring tuning, not Roblox limits.

Initial economic review triggers: basket movement above 15% week over week, a material's days-of-supply below one day or above two weeks, top 1% wealth share moving sharply, or new-player upgrade time doubling. Require sufficient sample coverage and compare to known content/events before acting. Keep changes human-reviewed; no automatic punishment or automatic global price controls.

Weekly review: verify telemetry health → reconcile assets → segment new/returning and paying/nonpaying players → inspect faucets/sinks → inspect shortages/concentration → choose one experiment → record expected outcome and rollback. Include safety and accessibility metrics alongside revenue. Before public beta, set retention/deletion periods and export access controls, then test deletion across all user-linked data.
