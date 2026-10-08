# Security and recovery

> Phase 4.5 update (2026-09-29): Durable generation fences survive receipt pruning, source confirmations gate archival, and item claim sequences never reset. Operator API is server-only, public market disabled, acceptance artifacts isolate both profiles/books. Equipment weld changes now reassert existing server physics ownership.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): Phase 4 uses strict remote shapes/rate limits, server-owned identity, session-safe profile commits, immutable admission/escrow receipts, sequenced idempotent claims and atomic book matching/cancellation. Never discard receipts or restore a traded profile without reconciliation. Public launch remains gated on independent server failure testing and durable archive/compaction.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


> Current update — 2026-09-28: City addition: server-checked portal/NPC proximity and own-plot construction; away-hero assignment/equipment locks; hidden dispatch outcomes committed at launch and omitted from projection; atomic one-time job/journal rewards. Elixir receipt grant and durable PurchaseId are committed together before acknowledgment; ID 0 disables purchase integration. See [city contract](CITY_GUILD_DISPATCH.md).

Phase 2.1 has no client combat authority or new combat remote. Server-private entities validate ownership, life state, distance, stats and cooldowns. Death is latched before yielding; reward commits retain immutable IDs/revisions through uncertain storage results. SetHealth, DealDamage, Heal, SetStats and CombatReward are rejected by the public protocol. See [combat protections](COMBAT.md).

Status: Phase 0 threat model retained. Phase 1 authority, validation, ownership fencing and replay controls are implemented and exercised by domain/failure tests; see [evidence and remaining native checks](PHASE1_IMPLEMENTATION.md). Later systems below remain a design/test contract.

## Trust and assets

Protect Gold, XP, item ownership, quest completion, guild authority, territory state, verified purchase benefits, player privacy, and service availability. Assume a hostile client can read all replicated code/data, invoke exposed remotes with arbitrary payloads, replay old requests, manipulate timing, and disconnect at any step. Server scripts are trusted application code but may crash, retry, race, deploy with bugs, or be operated with excessive permissions.

Client input is intent, never evidence that an action occurred. Validate context/ownership as well as types, numeric ranges, payload size, and request rate. Reject nonfinite numbers and malformed strings before storage or arithmetic. Roblox recommends server validation at every client-triggered boundary, including interactive instances. [Client-server security](https://create.roblox.com/docs/scripting/security/client-server-boundary)

Keep private modules in ServerScriptService/ServerStorage and public projections only in replicated containers. Obscure remote names do not provide security. Phase 1 exposes an intent-only Command RemoteEvent and an owner-only State RemoteEvent; server content, leases and accounting remain private. Separate staging experiences also keep unreleased assets out of production replication. [Access control](https://create.roblox.com/docs/scripting/security/access-control)

## Threat/control matrix

| Threat | Control and recovery | Required test |
| --- | --- | --- |
| Fake grant/completion request | Narrow command allowlist; server-owned rewards, deadlines and run IDs | Send fabricated Gold/XP/reward fields, foreign run ID, early completion |
| Arbitrary prices/quantity | Finite integer/range/product checks, authoritative balances and item eligibility | NaN, infinity, negatives, fractions, oversized arrays and overflow |
| Replay or double click | Durable semantic operation identity and outcome, not just a request nonce cache | Same payload twice, different payload with same ID, replay after rejoin |
| Double spending | Serialized profile mutations; reservation and debit in one record | Equip/craft/trade same instance concurrently |
| Stale server overwrite | Session token + monotonic epoch verified on every commit | Old server resumes after takeover and subsequent release |
| Interrupted transfer | Immutable reservation, destination outcome, durable receipt, no timeout refund | Crash/timeout at every bridge step |
| Market cancel/fill race | Current book order revision and atomic remainder transition | Match and cancel in two workers |
| Client damage forgery | Server simulation, target/range/cooldown checks where combat is introduced | Impossible hit rate, target, position, cooldown |
| Guild privilege escalation | Authoritative capabilities/revision; fully active membership only | Removed officer uses stale UI; concurrent leadership transfer |
| Territory/war forgery | Assigned match owner epoch, final-result identity, ownership CAS | Fake winner, duplicate result, old-season result |
| Fake purchase confirmation | Server receipt verification, allowlisted products, atomic benefit + receipt | Client finished signal, replayed PurchaseId, unknown product |
| Remote spam / storage exhaustion | Per-player per-action token buckets, bounded queues, server-wide budgets | Burst and sustained spam cannot create unbounded work |
| Bad config/migration | Schema validation, stable IDs, migration fixtures, staged rollout | Dangling item ID, negative reward, future schema, corrupt record |
| Operator or dependency compromise | Least privilege, no committed secrets, pinned tools, reviewed changes | Restore drill and audit of privileged mutation path |

Implemented Phase 1 boundary caps: 64-character ASCII IDs, three NPC party entries, one active economic command per player, exact shallow argument keys/types, and no arbitrary nested payloads. A token bucket admits six requests in a burst and replenishes two per second before schema traversal. Tune it against actual mobile retries. Per-session limiter state is discarded on leave; durable replay controls remain. Future market composite IDs retain their narrower separate contract.

## Transaction semantics

For a single-profile operation, construct the intended `Validate → Reserve → Execute → Transfer → Apply fee → Commit → Audit` effects as one candidate mutation; unused stages are no-ops. Commit state and minimal audit evidence together, then export logs. Do not split a quest reward into separate Gold, XP, item, and completion saves. Record server timestamps and content revision with the operation.

For cross-record transactions, this logical sequence becomes a recoverable saga with nonspendable reservations between commits. There is no general SQL-style rollback. Apply compensation only when a durable mutually exclusive abort proves a transfer did not become spendable at its destination. Unknown results remain pending. The [market protocol](MARKETPLACE.md) specifies deposit, cancel, claim, acknowledgment, retention, and epoch closure.

An idempotency key is not permission. The server binds it to actor, command type, immutable payload, and operation generation. Reusing a key with a changed payload is a conflict. Late valid requests whose receipts were compacted must still fail via semantic progress markers or a closed-generation watermark. A bounded recent-response cache alone is insufficient.

For Phase 1, use monotonic quest run numbers, claimed-through markers, a once-only recruit set, hall level/revision, and one serialized mutation sequence. Require the expected profile revision for spending operations and deduplicate while an outcome is unresolved. Completed quest reward state must remain provable after a user has performed thousands of later actions. No general persistent unbounded nonce list is needed for the slice.

## Persistence failure policy

- Failed initial load: show retry/unavailable; do not initialize/save defaults.
- Lease conflict: bounded wait and a readable “profile already active” state; no forced takeover before policy permits it.
- Lease lost: stop economic commands immediately; stale local state never writes again.
- Write failure: distinguish validation rejection from uncertain transport failure. Reconcile by operation ID before choosing retry or rejection.
- Shutdown/crash: persisted economic checkpoints survive; unsaved cosmetic settings may be lost. Do not claim final-save callbacks always run.
- Corruption/unknown schema: preserve original data, block mutation, record a redacted incident, and use a reviewed recovery tool later.
- Telemetry failure: gameplay may continue if only noncritical analytics is affected; bounded durable accounting outbox exhaustion pauses new economic commits.

Backoff with jitter and a retry ceiling prevents a service outage from becoming a retry storm. Queue limits and global admission budgets protect storage; no infinite retry loop in a remote handler. Do not rely on a cached read to prove an uncertain write was absent.

## Purchase and policy boundary, Phase 9 only

Gold trading is distinct from Roblox MarketplaceService. A future developer-product handler must validate user/product/receipt identity, commit entitlement and consumed PurchaseId together, and acknowledge only a durable grant. Never grant from client purchase-finished signals. Current documentation describes ProcessReceipt and an alternative BindReceiptHandler; choose one deliberate routing strategy after re-verifying APIs at Phase 9. Receipt redelivery must be harmless, including concurrent server delivery. [Developer products](https://create.roblox.com/docs/production/monetization/developer-products), [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)

Passes use official ownership checks, not the developer-product receipt path. No purchase products, IDs, prompts, or handlers are installed now. Paid randomness, tradable purchased rewards, regional entitlements, and policy-dependent convenience require fresh official review if proposed. User restrictions are not proof that a future settlement service is permitted; it remains disabled and unimplemented.

## Detection is not punishment

Flag wash-trade patterns, volume bursts, extreme price deviations, circular asset paths, and rapid repeated counterparty trading. Record confidence, evidence window, thresholds, and data quality. Alternate accounts or legitimate friends can resemble manipulation. Statistical suspicion never automatically bans, confiscates, cancels unrelated orders, or changes ownership. Deterministically invalid inputs can be rejected immediately; operator-reviewed enforcement is separate.

## Auditing, access, and incident response

Audit minimal before/after deltas and committed IDs, not entire profiles or chat text. Keep UserId access controlled; use non-identifying aggregates for dashboards. Never record tokens, reserved-server codes, raw client payloads, or personal contact data. Establish retention and deletion rules before public data collection, including transaction archives and third-party exports. Re-verify Roblox privacy obligations and supported deletion workflows before launch.

On suspected duplication: pause the affected economic feature, preserve durable records/version identifiers, identify first inconsistent sequence, trace counterparties, reconcile conservation, and rehearse a forward repair in staging. A profile rollback after player trading can duplicate assets elsewhere; do not restore one side blindly. Prefer reviewed corrective entries tied to original operations. Validate invariants, then reopen gradually. A reviewed repair should carry actor, reason, scope, timestamp, and resulting revisions.

## Adversarial acceptance gates

Phase 1: corrupted/default/future-version saves; duplicate joins; two servers contending for a profile; session expiry; disconnect before/after each checkpoint; save succeeds but acknowledgment is lost; full inventory; concurrent claims; forged early quest completion; replay after receipt-cache eviction; migrations repeated; no critical errors in Studio.

Phase 4: fuzz integer boundaries and callbacks rerunning; deliver commands duplicated/reordered; wipe transient services; kill workers after each persistent transition; cancel during partial fill; retry abandoned deposit after abort; deliver an old claim after epoch compaction; exhaust audit capacity; preserve offline orders when no servers run. Reconcile every run's starting + created − destroyed = ending assets, counting escrow once.

Phases 5–9: concurrent guild membership changes, treasury delivery replay, match owner replacement, season rollover races, forged teleports, receipt replay/uncertainty, and irreversible schema changes under rollback. Review the native storage protocol independently before enabling transfer of player-owned assets at commercial scale.


## Phase 2.2 player intents

SelectPlayerClass is an exact-shape, revision/receipt-backed command; repeat choice cannot change class or grant rewards. CombatIntent permits only Basic/Ability, with four burst tokens refilling at four/second before payload handling. The server requires an Active profile, live private actor, current own-camp bounds, valid target/range, class ability and server cooldown. Targets, positions, damage, clocks and rewards cannot be supplied by the client. Player participation comes from successful domain effects, not client claims; expired taunts grant no new credit. No per-attack persistence writes are made.

Schema v1→v2 validates legacy data before adding the character. Corrupt/future data fails closed, and uncertain class/reward commits use the existing reconciliation path. Avatar respawn does not reset session HP/cooldowns. This does not add comprehensive avatar movement anti-cheat; mobile/desktop solo Studio evidence does not replace multiplayer/published-client checks.

## Phase 2.3 equipment intents

AssignEquipment, UnequipEquipment, BuyEquipment and SellEquipment validate exact payload shape and authoritative owned actor/item, class, slot, price, capacity and equipped-sale restrictions. Atomic saved candidates conserve both sides of a transfer; schema validation rejects duplicate assignments independently. Fault tests cover failed and uncertain transfer/buy/sell saves. Legacy v2 migration rejects unexpected destination fields; rollback requires schema-v3 support. [Equipment rules](INVENTORY.md).

## Phase 2.4–2.7 authority

New intents carry IDs and bounded grid coordinates, never costs, reward amounts or victory flags. Server checks ownership, resource distance/cooldown, grid footprint/overlap/access lane, progression gates, points and prerequisites. Combat loadout changes are rejected while a tower floor is Fighting. Tower completion is a private server operation with save reconciliation and receipt deduplication. Support effects exclude foreign, downed and out-of-range actors. VFX parts are client cosmetic, non-colliding/non-queryable, short-lived and capped at 48 on desktop / 30 on touch.
