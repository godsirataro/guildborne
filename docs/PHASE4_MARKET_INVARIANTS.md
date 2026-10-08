# Phase 4 release-blocking market invariants

These rules apply to the bounded material-market pilot. Tests in [market.luau](../tests/market.luau) execute the real pure transforms and PlayerDataService, including uncertain saves and adversarial scheduling.

## Gold conservation

For a closed set of participants, initial wallet Gold equals current wallets + book Gold escrow + unapplied Gold claims + source reservations not yet accepted + burned fees. Resolve bridge ownership by immutable operation identity: a PREPARED profile receipt is provenance only after the book ACCEPTED it. Resolve claims against the recipient's committed watermark, not merely the book's potentially delayed acknowledgment. Never count either bridge twice.

`goldCreated - goldDestroyed + market.goldIn - market.goldOut = wallet Gold` is enforced by schema v6. Market transfers never increment faucet/sink statistics. `sum(fill.fee) = book.burnedFees`; `gross = price × quantity = net + fee`.

## Item conservation and escrow ownership

Owned material + accepted book escrow + unapplied item claims + not-yet-accepted source reservations stays constant across trading. Reservations subtract the source's available balance and journal the exact payload in the same session-owned commit. The destination requires a preallocated durable ticket. An ABORTED destination cannot later accept that reservation. No refund follows a timeout alone.

Only stone, timber, iron_ore, iron_ingot and herb are eligible. Existing equipment remains account-bound, including equipped items. Class kits, progression, quests and revival entitlements cannot enter escrow.

## Order quantities and fees

`original = remaining + filled`, always. Terminal cancellation retains remaining as historical unfilled quantity but sets spendable escrow to zero and creates one refund claim. Active buy escrow equals remaining × limit price; active sell escrow equals remaining units. Filling both orders, creating their claims, recording the trade and burning its fee is one item-book UpdateAsync.

The sell order snapshots configured fee basis points (default 500). Each fill charges `ceil(cumulative gross × bps / 10000) - previous cumulative fee`. Cancellation has no execution fee; there is no listing fee. Buyer price improvement becomes a refund claim.

## Settlement and cancellation idempotency

Claims have immutable identity, sequence, recipient, source transaction, asset, amount, creation time and PENDING/CLAIMED state with acknowledgment time. The recipient owner processes its claims in strictly increasing book sequence. Applying credit and advancing that item's epoch watermark is one profile commit. Retrying a sequence at or below that watermark cannot credit again. Processing stops on the first capacity/save failure; it must never skip an unapplied claim to advance the watermark. The book retains every claim, so a later snapshot always contains the earlier prefix. A worker may acknowledge only after the profile committed; unknown acknowledgments safely retry.

Cancellation checks owner and current durable remainder in the book transform. Repeating cancellation on a terminal order is a no-op. A fill/cancel race is decided by the successful UpdateAsync order, not cached data.

## Matching exclusivity

There is no correctness-critical MemoryStore lease. Roblox single-key compare/update serializes changes to the entire item book, including both sides' escrow. Callback retries recompute from the latest value without external side effects. Concurrent workers, missing leases and duplicate notifications cannot authorize overfill. Best price precedes durable acceptance sequence; the resting order sets the execution price. A self-cross cancels the incoming remainder without price/volume/fee creation.

## Recovery guarantees and capacity

Prepared reservations retry after uncertain writes/rejoin. A foreign worker may read the immutable committed profile reservation through its ticket and deposit it, but never writes that profile. Terminal order slots close on owner recovery. Claims persist offline, after expiry and after every transient cache/message is lost. Core gameplay has its own persistence path and remains available if market I/O fails.

Recovery visits one allowlisted item every 30 seconds; each item is revisited within roughly 150 seconds. It expires orders, republishes depth and checks up to two orphan admission tickets with a rotating cursor. Online claim batches apply at most 12 claims. Manual collection is also available. No active server means no background execution; work resumes on startup. Inventory/wallet capacity intentionally leaves claims pending.

This pilot retains at most 128 lifetime admission receipts/orders per item and 128 source transfers per profile. It never deletes replay evidence on a timer. Ticket allocation precedes asset debit, so reaching the cap rejects admission without stranding new assets. Existing cancellation/claim/recovery remains available. Before indefinite/public operation, implement and independently fault-test sealed epochs and archive/compaction, including offline users and stale processes. Raising or clearing these caps/receipts manually is not a supported recovery procedure.

Any observed duplication, overfill, missing escrow, session-lock bypass or skipped claim sequence blocks release. Do not repair by minting speculative compensation.
