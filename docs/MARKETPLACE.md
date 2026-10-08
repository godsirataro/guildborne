# Global Gold marketplace

> Phase 4.5 update (2026-09-29): Phase 4.5 implements controlled per-item generations, reconciled bounded archives, replay-safe profile compaction and private-only operations. Public market remains disabled; true cross-server and physical device gates remain pending.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): The Phase 4 bounded material-market pilot is implemented: atomic per-item durable books, profile escrow bridge, sequenced claims, maker-price matching, 5% cumulative fees, robust reference and OHLCV. MemoryStore depth is disposable; messages only invalidate. Lifetime receipt caps stop admission safely. The longer design below includes future scale work, not all shipped behavior.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


Status: Phase 0 design only. No marketplace code or remote exists. Phase 4 begins with a correctness/capacity experiment and can be stopped if its gates fail.

## Product scope

One logical market spans every server in the experience. Launch with a small allowlist of fungible material item IDs; do not fragment players into server-local markets. Unique equipment trading is deferred until its ownership/escrow model is proven. No Robux, purchased entitlements, leverage, borrowing, derivatives, short sales, cash-out, or external settlement participates.

Default UX: **Buy now**, **Sell now**, **My orders**, and **History**. Advanced controls say “Buy at my price” / “Sell at my price.” Show quantity, maximum Gold spent or minimum received, estimated fee, possible partial fill, and quote age. A quote is informational; the commit revalidates current book state. Explain a changed quote and permit reconfirmation. No client-supplied quantity or price is accepted without server bounds and balance checks.

Display Last Price, Best Bid, Best Ask, Spread, Market Reference (confidence/freshness), 24h High, Low, and Volume. Empty books show “No offers,” not zero. A spread needs both sides. Charts are secondary and collapse on small screens. Never market these as financial investments.

## Order rules

| Concept | Decision |
| --- | --- |
| Instrument | One item definition + trade-compatible variant per book |
| Unit | Integer Gold price and integer item quantity |
| Priority | Best price, then durable acceptance sequence in the book; no client timestamps |
| Execution price | Resting order's price |
| Limit buy / sell | Remain open until filled, canceled, or expired; launch max lifetime 7 days, configurable |
| Market buy | Immediate-or-cancel buy with server-approved maximum unit price and total spend ceiling |
| Market sell | Immediate-or-cancel sell with minimum acceptable price and net-proceeds disclosure |
| Partial fill | Allowed; remaining quantity and reservation remain explicit |
| Self-trade | Same user cannot match their own orders; reject the crossing incoming remainder |
| Offline orders | Persist after logout; proceeds/items remain in durable market claims until collected |
| Amend | Cancel remainder and place a new order, losing time priority |
| Slot limit | Initial proposal: 5 open orders per player across the market; enforce via profile reservations |

Suggested pilot caps: 200 open orders per item, 100 distinct funded participants per active book epoch, 20 fills per command, 1,000 units per order, and a 256 KiB serialized working-book ceiling. They are experiment limits, not capacity claims. Byte budget wins over counts. Keep reserved capacity for cancel/claim/acknowledgment and journal drainage; refuse new deposits before recovery loses headroom. Match batches yield between datastore calls, never inside the transform. If a market order hits the fill bound, cancel its remaining quantity and explain the partial execution. An accepted limit order can continue in later batches.

## Lifecycle and invariants

`PendingReservation → Reserved → Open → PartiallyFilled → Filled`

`Open / PartiallyFilled → Cancelled / Expired` applies only to remaining quantity. `PendingReservation → Rejected` is allowed before any asset debit. A reservation with an uncertain deposit outcome is `RecoveryPending`, never merely failed/refunded. Terminal orders still have independent delivery states: PendingClaims → Delivered → Archived.

Every fill satisfies:

- Buyer reserved Gold decreases by gross; seller receives gross minus fee; fee sink increases by fee.
- Seller reserved items decrease by filled quantity; buyer claim items increase by the same quantity.
- Remaining quantity never becomes negative and a fill ID commits at most once.
- Released price improvement or canceled reserve becomes a claim, not newly created Gold.
- Assets in transfer are nonspendable until the receiving record has accepted them exactly once.

The seller fee uses the cumulative ceil rule in [economy](ECONOMY.md). Store feeBps and feeVersion on the sell order, cumulative gross, and cumulative fee charged. For two fills of 1 and 19 Gold at 500 bps, fees are 1 then 0, totaling 1. The 10,000 Gold example produces a 500 Gold sink. Cancellation of the unfilled portion creates no execution fee.

## Bounded durable authority

Proposed Phase 4 design: a Standard DataStore book record per item/epoch contains active orders, funded reserves, claimable balances, transfer receipts, fill sequence, fee totals, and a bounded audit outbox. Matching changes both counterparties' **book-owned escrow** in one UpdateAsync. It never attempts to atomically save two player profiles. Shard different items, not different sides of the same book.

Concurrent server workers may propose commands, but the transform verifies current order revisions, balances, IDs, and epoch and computes fills from the current value. Only the successful durable result is authoritative. Replayed callbacks have no external side effects. A worker lease in MemoryStore can reduce redundant work but is insufficient for financial correctness. A durable epoch fences old commands after a book is sealed.

Indexes and cached snapshots are projections. MemoryStore queues can notify workers, and MessagingService can advertise a changed revision; neither acknowledges asset transfer. Poll a fixed bounded active-item registry and rebuild projections on startup. Newly accepted profile reservations also remain discoverable by deterministic player keys and budgeted ListKeys recovery scans. No reservation relies solely on a queue message that can expire.

This design intentionally chooses limited availability and scale over pretending Roblox supplies multi-key transactions. Official [single-key storage guidance](https://create.roblox.com/docs/cloud-services/data-stores/best-practices) supports grouping related updates; the escrow bridge below is Guildborne's proposed protocol, requiring implementation and fault testing before use.

## Profile ↔ book bridge

Treat each movement as a durable state machine. Clients only ask the server to initiate or query it. IDs encode a server-generated operation identity plus source/destination epoch and immutable payload identity. An existing ID with a different payload is rejected and investigated.

### Deposit and order creation

1. Validate eligibility, quantities, balance, global slot allowance, and active book epoch. In the profile's single commit, subtract available Gold/items and record a `Prepared` transfer with the exact immutable payload; reserve an order slot. It is now unavailable to other actions.
2. A server verifies that committed reservation through the profile owner or an authoritative persisted read. The reservation cannot subsequently be refunded merely because time passed. Submit its deposit to the book: in one book update, check epoch and transfer receipt, credit the reserve, create the order, and record `Accepted`. Duplicate calls return the same outcome.
3. Persist the accepted outcome in the source profile, marking the reservation `Exported`. Keep provenance and the slot allocation until terminal-order evidence is acknowledged. A crash before this acknowledgment does not repeat the debit or credit.
4. If admission is refused, commit a durable `Aborted` tombstone for the transfer in the same destination book before refunding the source profile. An `Accepted` transfer cannot become `Aborted`. A late deposit checks the tombstone and fails. If an abort cannot be recorded, leave the reservation pending; no timeout refund.

Accepted but unwanted orders use normal cancellation, returning book claims rather than undoing the original deposit. Source verification occurs outside the book transform and is safe only because a Prepared reservation remains immutable until a mutually exclusive Accepted/Aborted destination outcome exists. Do not implement a “read balance then debit later” shortcut.

### Claim delivery to the profile

1. In the book, move a claimable balance into a nonspendable `PreparedDelivery` entry addressed to one user; record claim ID, payload, epoch, and sequence. Multiple claims cannot take the same balance.
2. The profile owner verifies that durable authorization, then applies the item/Gold credit and its consumed claim receipt in one profile commit. If inventory or wallet capacity is insufficient, leave delivery pending. Do not partially credit without its own explicit child-claim protocol.
3. Acknowledge the profile receipt in the book and mark delivery `Delivered`. A retry after a crash sees the profile receipt and performs no second credit.

Delivery authorization never times out into a refund; it stays replayable to the named receiver until acknowledged. Offline users collect on next join in the first market version. Workers do not bypass an online profile lease. “Offline order support” means matching and claim accumulation, not concurrent writes into an active user's cached profile.

### Receipt retention and bounded history

Do not delete transfer tombstones or consumed claim receipts on a timer. A delayed sender could otherwise credit/refund twice. The bounded pilot retains all bridge receipts and stops admitting new work at its configured threshold. This is safe but not sufficient for indefinite commercial operation.

Before general launch, prove compaction: seal the old book epoch against new deposits/matches; cancel remaining orders into claims; complete or retain every bridge; archive immutable terminal outcomes; record a monotonic closed-epoch watermark in each affected profile before removing its old consumed receipts. Watermarks are per item book, and may advance only when that user's bridges in every covered epoch are terminal and acknowledged. Never advance past an unresolved claim. A profile must reject any command from a closed epoch forever. Retain unresolved claims and enough durable routing to serve offline users from old epochs. Archive acknowledgment must precede pruning. Never reuse an epoch or operation ID. Test partially completed compaction and stale servers at every step. Until that proof exists, reaching retention capacity pauses admission rather than deleting evidence.

## Failure and recovery table

| Failure point | Durable evidence | Safe response |
| --- | --- | --- |
| Before source debit | No reservation | Reject/retry same intent; no refund needed |
| Debit committed, response lost | Profile Prepared transfer | Reconcile; repeat same deposit ID |
| Book accepted, source acknowledgment lost | Accepted book receipt | Mark source Exported; do not refund |
| Cancel races with fill | Book revision/order remainder | Whichever commits first defines the remaining quantity; cancel only that remainder |
| Claim credit committed, ack lost | Consumed profile receipt | Retry acknowledgment; never re-credit |
| Storage timeout or throttle | Outcome may be unknown | Backoff with jitter, preserve ID, freeze affected mutation |
| MemoryStore loss / message loss | Durable book/profile journals | Rebuild and poll; stale quotes cannot authorize fills |
| Worker/server dies | Persisted pending transitions | Another live server resumes from records |
| All servers stop | Durable state only | Resume processing at next server start; no continuous-worker promise |
| Audit archive unavailable / book near cap | Unexported outbox and byte budget | Stop new economic activity before evidence is lost |

Recovery scans use continuation tokens, fixed prefixes, a request budget, and bounded batches. Prioritize unresolved asset movements over new orders. Escalate an unexplained conservation difference to a paused item book and manual reconciliation; do not mint compensation speculatively. Exact retry attempts, scan cadence, and backlogs are measured in the Phase 4 experiment.

## Price reference algorithm

Keep BasePrice, NPCReferencePrice, LastTradePrice, and MarketReferencePrice distinct. A committed fill updates LastTradePrice even when statistically unusual, with an anomaly marker if appropriate. Reference calculation is a separate deterministic projection:

1. Use a trailing 24-hour window of committed fills, bucketed by 5-minute UTC interval and unordered buyer/seller pair. Exclude self trades, administratively confirmed invalid trades, and technical corrections. Unverified suspicions are flags, not automatic punitive exclusions.
2. Within each pair/bucket, compute one volume-weighted price sample and a capped volume weight (`pairBucketVolumeCap`, tuned per item). Multiple tiny fills do not create multiple independent samples.
3. Require at least 20 pair/bucket samples, 10 distinct users, 5 distinct pairs, and at least 3 time buckets. If insufficient, report insufficient liquidity; do not allow a first trade to define the reference.
4. Compute the unweighted sample median `m` and median absolute deviation `MAD`. Keep samples within `max(3 × MAD, 0.20 × m)` of `m`. Require the same participation thresholds again after filtering.
5. Compute the weighted median of retained samples, capping each pair's total weight at the median positive pair weight in that window. This retained weighted median is the candidate MarketReferencePrice. Also expose filtered capped VWAP as a diagnostic, not the reference itself.
6. Publish at most every 5 minutes. From a previously valid reference, limit movement to ±10% per publication, configurable; record both candidate and published value for analysis. This can lag genuine shocks, so monitor it. Mark unchanged fallback stale after 1 hour without a qualifying sample set. If there has never been a valid reference, show BasePrice separately as “Design guide,” not a market value.

These defaults resist an isolated outlier and cheap trade splitting. Sybil accounts and coordinated groups can still manipulate sparse markets; diversity is not proof of independence. The reference never forces execution prices, guarantees liquidity, changes NPC rewards automatically, or triggers punishment. Revisit thresholds with real market depth and economic concentration data.

## OHLCV and history

Each committed fill records trade ID, book epoch, monotonic sequence, server execution UTC time, unit price, quantity, gross, fee, and config revision in the same durable commit. Within a book, clamp execution time to at least the previous committed time to prevent a worker clock moving candles backward; monitor clock discrepancies and fence unhealthy workers. Deduplicate projections by `(epoch, sequence)` with a contiguous processing checkpoint; retries must not add volume twice. Do not compute charts from client events or order creation.

Base candles: one minute, UTC-aligned `floor(timestamp / 60) * 60`. Open/close follow execution order `(timestamp, sequence)`; high/low are extrema; volume is units; quote volume is sum(price × quantity); VWAP is quote volume / units. Higher candles merge open of first nonempty, close of last nonempty, max high, min low, and summed volumes. Retain empty buckets as gaps/zero volume with absent OHLC; a dotted carried-close display must be labeled synthetic.

| View | Candle granularity | Proposed retention |
| --- | --- | --- |
| 1H | 1 minute | 48 hours |
| 6H | 5 minutes | 7 days |
| 1D | 15 minutes | 30 days |
| 7D | 1 hour | 90 days |
| 30D | 4 hours | 180 days |

Use separate size-bounded time-bucket keys for projections and immutable fill archive pages. Archive a page and verify its committed identity before acknowledging/removing it from the book outbox. Recompute a dirty bucket from archived fills after late delivery or a correction instead of applying an untraceable subtraction. Compute rolling 24h high/low/volume on a documented minute-aligned window; show its as-of time and bounded one-minute precision. Technical correction records link to original trades; they do not silently rewrite accounting history.

Personal transaction history shows orders, fills, fees, cancellations, claims, and their statuses; the initial UI pages recent 30-day history. Longer audit retention is an operations/privacy decision before launch and is not limited by the display period. Raw and filtered price statistics must be distinguishable.

## Phase 4 release gates

Prove conservation and idempotency under duplicate requests, concurrent cancels/fills, stale workers, unknown write outcomes, loss of all transient data, full inventory, server death at every bridge step, and archive interruption. Measure write amplification using actual serialized record sizes; a 256 KiB book repeatedly rewritten can hit per-key throughput well before universe request quotas. Publish observed orders/second, p95/p99 latency, backlog drain time, and byte growth at the target load. If the native bounded design fails, reduce scope or separately design a supported backend; do not hide the failure behind optimistic caches.
