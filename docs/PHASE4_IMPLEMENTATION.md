# Phase 4 — Global Marketplace

Implemented and Studio-verified on 2026-09-29 as a bounded five-material pilot. **Phase 4 Studio Definition of Done is met within the tested scope. True cross-server live trading is NOT YET VERIFIED. Not ready for a public economy.** No publication or Phase 5 work was performed. Public release additionally requires private-server acceptance, physical touch QA, capacity testing and a durable archive/epoch protocol.

## Architecture and ownership

`MarketRuntime` handles the separate Market remote, rate limits, safe responses and periodic recovery. `MarketService` orchestrates profile/book commits. Pure `MarketOrders`, `MarketBook`, `MarketMatching`, `MarketEscrow`, `MarketData` and `MarketProtocol` modules contain rules. `MarketCloud` supplies cloud I/O; deterministic adapters execute the same transforms in tests. Existing quests, combat, inventory, progression, travel and session persistence are reused.

Production/staging servers in the same universe and environment use `GB_Market_<environment>`, keys `b:<item>:<epoch>`. The environment matches the corresponding profile namespace; it must not vary with JobId or Studio session. One book contains both sides, escrow, operation receipts, claims, trade records, sequences and fee totals. A single DataStore UpdateAsync serializes all economic effects of a fill. Profile and book commits are separate, recoverable operations; no multi-key atomic transaction is assumed.

MemoryStore sorted maps are sharded by environment/item/side. Each disposable `depth` projection has at most 20 order rows, monotonic revision and 90-second TTL. Writes coalesce for two seconds. Currently gameplay reads use the durable adapter's ten-second local cache, not the MemoryStore projection; the latter is available for future fast lookup and was separately read/rebuilt in cloud QA. Neither cache authorizes a fill. MessagingService sends item/revision invalidation only; missed messages recover through cache expiry. There is no correctness-critical distributed lease: single-book CAS excludes overfill even with duplicate or stale workers.

## Escrow and settlement

1. Validate the server-owned profile and a disposable reservation candidate.
2. Allocate a durable CREATED admission ticket before debiting assets.
3. Commit PREPARED source transfer and subtract available Gold/items through the existing session owner.
4. Deposit once into the book: ACCEPTED creates the order and matches; ABORTED is a permanent exclusion before refund.
5. Mark the profile transfer EXPORTED or refund an ABORTED transfer atomically.
6. Match/cancel/expire creates immutable PENDING claims inside the same book update as the escrow reduction.
7. Only the recipient's active profile owner credits a claim and advances its item/epoch sequence watermark atomically, then acknowledges CLAIMED in the book.

Claim ordering stops at the first failure. Unknown outcomes retry; they never trigger speculative compensation. Credits already represented by a watermark cannot repeat. A full inventory/wallet leaves the claim pending. Foreign workers may read committed reservation provenance to recover an orphan, but never mutate another server's profile. See the [release-blocking invariants](PHASE4_MARKET_INVARIANTS.md).

Recovery scans one of the five configured books every 30 seconds (roughly 150 seconds per item), expires seven-day orders, rebuilds projections and examines two orphan tickets using a rotating cursor. Online recovery applies at most twelve claims per pass; manual collection and subsequent passes complete larger backlogs. Work resumes when a server starts; there is no background execution with zero servers.

## Matching, prices and policy

Buy/sell limits and guarded immediate orders share one matcher. Best price precedes durable acceptance sequence, and the resting maker supplies the price. Sequence means accepted book order, not client send time. Partial fills preserve `original = remaining + filled`. Immediate remainders cancel; an empty/out-of-guard book can yield zero fill with escrow returned. Buyer guard is maximum unit price × requested quantity; seller guard is minimum gross unit price, with the fee shown separately. Price improvement is refunded through a claim. Self-cross cancels the incoming remainder without a trade or fee.

`Config/Market` sets the initial fee to 500 basis points. A sell order snapshots that fee; each fill charges `ceil(cumulative gross × bps / 10000) - prior fee`. This makes splitting fills unable to alter total fees. No listing fee. The book records gross, fee, net and burned Gold. Profile market inflow/outflow are separate from ordinary Gold faucet/sink statistics.

Only stone, timber, iron_ore, iron_ingot and herb are explicitly tradable. Item definitions expose `Tradable` and `BasePrice`. Every current equipment instance is account-bound and excluded, including equipped gear; UI explains this policy. No gear is automatically unequipped. There is no material NPC market quote currently, so NPCReferencePrice is conceptually unavailable rather than invented. Design guide/BasePrice, last execution, bid, ask and calculated market reference are distinct. No real currency, Robux conversion, cash-out or external settlement was added; the future settlement adapter remains disabled.

Reference price groups recent executions by unordered participant pair and five-minute bucket, caps volume weight, requires 20 groups/10 users/5 pairs/3 buckets, filters by median absolute deviation with a 20% median band, caps aggregate pair influence at median pair weight, then takes a weighted median. Thresholds are configurable. Thin/diversity-insufficient markets show the labeled Design guide fallback. This mitigates simple manipulation, cannot defeat coordinated accounts, and never automatically punishes players. There is no additional publication smoothing; the robust window is the selected Phase 4 algorithm.

OHLCV comes from authoritative, ordered trade records: 1H/one-minute, 6H/five-minute, 1D/fifteen-minute, 7D/hourly, 30D/four-hour buckets. No synthetic candles fill gaps. Last price and 24-hour high/low/volume are independent of the reference. Native charts show wick/body price ranges; server candles retain volume and gross. Views expose 20 price levels per side and at most 60 own orders/history per item, with a bounded cross-item portfolio.

## Bounded retention and operational limits

Each item admits at most **128 lifetime tickets**, each profile retains at most **128 source transfers**, and book serialization is capped at **1 MiB**. Each player has at most five open orders. Price ≤100,000, quantity ≤1,000, order value ≤10,000,000; all must be positive finite integers. Tickets, replay receipts and raw trades do not grow without bound because new admission stops. Existing claims, cancellation and recovery continue after capacity exhaustion. These are pilot lifetime caps, not rolling windows.

This deliberate fail-closed design preserves offline replay safety. It is unsuitable for indefinite public activity until sealed epochs/archive/compaction are implemented and fault-tested. Do not clear receipts, increase epoch ad hoc, or restore old traded profiles as a repair. A hot item still serializes on one key; no high-throughput claim is made. Read/write budget checks, bounded retries with exponential backoff/jitter and local caching handle transient failures; outages return MarketUnavailable without disabling core gameplay.

## UI and security

The existing Exchange opens with its prompt (R/ButtonY avoids the nearby hero E prompt). Responsive EN/TH native UI includes browse, bilingual name/category search, material detail, Buy Now/Sell Now, advanced limit orders, quantity/price entry, estimate/guard/fee confirmation, anonymous depth, period charts, own order status/remainder/cancel, history and pending collection. Navigation stays visible above scrolling content. Server responses determine results and language.

The dedicated remote accepts exact bounded shapes and ASCII request identities; identity always comes from Player. Burst limit four and refill one per two seconds, per-player in-flight protection, ownership checks, session-lock commits, replay receipts, asset caps, item allowlist and server-only fee/result calculation protect the boundary. Client quantity/price are intentions, never authoritative execution. Profiles, session tokens, counterparties and complete books never replicate.

## Verification and remaining gates

The pre-change baseline passed **136/136**. The final suite passes **210/210**: those 136 regressions plus 74 market scenarios, with strict analysis, compile, repository checks and Rojo build. Scenarios include races, callback reruns, unknown writes, orphan recovery, claim replay, capacity, migrations, reference/aggregation and a 90-step conservation schedule. [Studio evidence](PHASE4_STUDIO_TEST.md) records real two/four-client flows, 20 heroes, combat/progression regression, actual cloud tests, screenshots and performance.

Schema v5 migrates additively to v6 with an empty market journal and accounting. Older migration chains remain supported; existing hall levels, classes/unlocks, XP, equipment and inventory are preserved. Tests execute the existing suite against schema v6, with historical fixtures explicitly retained. Existing staging profiles were not overwritten by multiplayer QA, which used temporary Memory mode. Cloud smoke used isolated names and no player-profile writes.

No known critical duplication, loss, overfill or session bypass remains in the tested scope. This is evidence, not a proof of all platform failures. Remaining gates: [independent private live servers](PHASE4_PRIVATE_SERVER_ACCEPTANCE.md), sustained cloud/hot-key load, durable retention beyond pilot caps, physical mobile touch and keyboard. Studio client input cannot certify physical touch. Production analytics export is not yet a separate market pipeline: authoritative trades/fees and adapter metrics support inspection; existing profile analytics logs market transfer events without treating them as faucets.

The game was not published. Stop at Phase 4.
