# Market archival and retention

Storage is bounded by current record shape, not an unbounded series of epoch keys. Schema-v2 books migrate in place from v1; the logical namespace is domain/environment/schema-version/item/generation while the physical root stays stable for existing escrow provenance.

| Class | Retention and pruning condition |
| --- | --- |
| HOT | At most 128 admission tickets per item generation, at most 32 live orders/admissions per item. Raw executions are bounded by those orders and `RawTradeLimit=128`; one order can consume multiple counterparties but each fill closes at least one order. |
| Protected recovery | All pending claims, accepted-source confirmations and refund evidence remain until resolved. Offline/full-capacity accounts may hold this bounded book indefinitely. Time alone never deletes ownership. |
| WARM | Detailed orders/trades remain until closure, reconciliation and the 300-second replay window complete. The one-day epoch target is not a deletion deadline for unresolved assets. |
| COLD | Five independently aggregated OHLCV series retain their required 1H/6H/1D/7D/30D windows; minute/five-minute/fifteen-minute/hour/four-hour resolutions. At most roughly 581 buckets including window-edge buckets. Last 32 epoch summaries plus cumulative fees, gross, volume and trade totals remain. |
| PRUNABLE | On successful next-generation activation, reconciled raw events and individual replay receipts are removed atomically. `archivedThrough` and cumulative claim/order/trade counters remain forever as fixed-size fields. |

An ARCHIVED book still contains its raw records until StartEpoch, so projections explicitly avoid double-counting them. New trades merge with archived candles by time bucket. Reads filter expired buckets; archive writes remove expired buckets. No empty candle is fabricated. The 24-hour summary uses fifteen-minute aggregates after rollover, so the oldest edge bucket may include less than fifteen minutes outside the exact rolling cutoff. This bounded-resolution approximation is explicit; it is not an exact raw-event replay.

A qualified robust market-reference snapshot is retained with its timestamp across rollover, labeled **Archived market reference**, and expires after the configured reference window. Without a qualified live or recent archived reference, the Design guide fallback remains explicit. Archives do not invent participant-diversity evidence from candles. Own raw order/transaction lists cover the retained current generation; indefinite personal transaction history is not promised.

Profile schema remains v6. Optional market transfer `epoch` and per-item `floors` are additive. The existing `item:1` claim watermark becomes a lifetime per-item sequence because claimSequence never resets; it must NOT be renamed to each new generation. Confirmed older transfer records are compacted only through the book's durable archived fence. A PREPARED old source resolves first: confirmed accepted sources cannot be pruned while ambiguous, and late never-accepted sources refund against the permanent closed-generation fence. Profile progress, gear, classes and currencies are otherwise unchanged.

Maximum serialized book remains 1 MiB. No epoch/raw history key proliferation occurs in the market authority. Roblox-managed historical DataStore versions and the pre-existing profile analytics archive have their own retention behavior; this change does not claim to compact the entire game's storage. All arithmetic remains bounded by existing schema numeric limits; no promise of infinite counters is made.
