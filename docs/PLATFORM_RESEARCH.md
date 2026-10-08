# Platform research and external assumptions

Reviewed 2026-09-27 using official Roblox Creator Hub and Rojo documentation. These are research snapshots, not permanent quotas or guarantees. Recheck before implementing a dependent feature and before each scale/monetization release. Some engine reference pages exposed less explanatory text on direct retrieval than in their indexed documentation; limits below were cross-checked against the cited official source results. No community tutorial is used as authority.

## Persistence

DataStoreService is experience-wide durable storage. Studio API access can touch the same data as live servers; use separate development/staging experiences. Cached reads can be stale. UpdateAsync is appropriate for conditional changes to a key; its callback cannot yield. [Data stores](https://create.roblox.com/docs/cloud-services/data-stores)

An UpdateAsync callback may be called again after a conflicting update; returning nil cancels the write. Treat external side effects inside it as unsafe. No reviewed API provides an atomic transaction across arbitrary player keys. Guildborne's cross-record recovery is application design, not a platform transaction guarantee. [GlobalDataStore](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore#UpdateAsync)

Current standard-store limits (`U` = experience concurrent users; `P` = players in one server):

| Scope | Read/min | Write/min | List/min | Remove/min |
| --- | --- | --- | --- | --- |
| Experience | 300 + 40U | 300 + 20U | 300 + 2U | 300 + 40U |
| Server defaults | 60 + 40P | 60 + 40P | 5 + 2P | 60 + 40P |

UpdateAsync consumes both read/write budgets; Open Cloud shares experience budgets. Current per-key throughput: 25 MB/min reads, 4 MB/min writes. Names/keys/scopes: 50 characters; serialized value: 4,194,304 maximum. Throttle queues hold 30 requests. Failed writes can have unknown outcomes. Query runtime budgets; Studio Run has distinct limits. [DataStore limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)

Project implication: keep bounded profiles/books with serialization headroom, budget all retries/scans/archives, and reconcile uncertain commits. At 256 KiB per book write, the documented 4 MB/min envelope is roughly 16 full writes/min before any other traffic or overhead, illustrating why a large book is a pilot constraint rather than a scale solution. Actual units, overhead, and throttling must be measured in staging. Increasing server request settings does not remove per-key throughput or experience limits.

The official player-data sample discusses session ownership, ordered retries, and atomic purchase recording, and cautions against using it untested. We use it as design evidence, not an installed production dependency. [Player data and purchasing](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing)

Shutdown callbacks have a 30-second window; a process crash does not promise successful final persistence. [BindToClose](https://create.roblox.com/docs/reference/engine/classes/DataModel#BindToClose)

## Temporary shared state

Current MemoryStore baseline: `64 KB + 1.2 KB × users` memory, and `1000 + 120 × CCU` request units/minute across the experience. Item values: 32 KB; expiration up to 3,888,000 seconds (45 days). Sorted maps/queues: 1,000,000 items or 100 MB each, still subject to the smaller experience quota. Range/queue reads consume units based on returned items; hash-map UpdateAsync costs at least two units. Partition throttling may start around 30,000 units/min; this is an estimate, not a promised capacity. Studio MemoryStore is isolated from production. [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores)

Project implication: ephemeral leases, presence, and small indexes only. Expiry, memory pressure, or service failure must never erase offline ownership. Use short TTLs, cleanup, backoff, bounded scans, and rebuildable caches. Do not plan around purchasing extra quota; any Extended Services decision needs measured demand and an explicit operating budget.

## Cross-server messaging

MessagingService delivery is best effort. Current documented limits:

| Limit | Value |
| --- | --- |
| Message size | 1 kB |
| Topic length | 1–80 characters |
| Sends/server/min | 600 + 240 × server players |
| Receives/topic/min | 40 + 80 × server count |
| Receives/experience/min | 400 + 200 × server count |
| Subscriptions/server | 20 + 8 × server players |
| Subscribe requests/server/min | 240 |

Use notifications as hints and resynchronize by entity revision. No assumed durable queue, ordering, or exactly-once delivery. [MessagingService](https://create.roblox.com/docs/reference/engine/classes/MessagingService)

Project implication: coalesce updates and use a bounded topic scheme; do not publish every fill or create unbounded per-order subscriptions. Missed messages recover by polling authoritative state. When no game server runs, this design has no persistent worker process.

## Networking, travel, and user text

Roblox advises validation of all client-triggered actions, including permissions, payload shape, values, and request rates. Client-owned physics and interaction events are not sufficient proof of eligibility. [Security guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary)

TeleportService needs published-client tests. Use server TeleportAsync and handle both thrown failures and TeleportInitFailed. TeleportData is client-visible and unsuitable for secure balances. [Teleport guide](https://create.roblox.com/docs/projects/teleport)

Use supported TextChatService workflows and recheck communication eligibility/filtering rules at Phase 3; do not invent custom unfiltered guild chat. Guild names/descriptions also need supported text filtering before public display. [Text chat overview](https://create.roblox.com/docs/chat/in-experience-text-chat)

## Analytics and monetization

AnalyticsService's documented global request budget is `120 + 20 × CCU` per minute. Current custom-event names: 100; economy resource types: 10; event custom fields: 3. [Event types and limits](https://create.roblox.com/docs/production/analytics/event-types)

Custom events need a published server and may take up to 24 hours to appear in charts. Use a local debug adapter in Studio and keep accounting in durable game records. [Custom events](https://create.roblox.com/docs/production/analytics/custom-events)

Developer-product grants require server receipt processing; a purchase-finished prompt event is not a grant authorization. Current references include ProcessReceipt and BindReceiptHandler; ProcessReceipt has no timer-based retry guarantee. Reverify routing/receipt behavior before Phase 9. [Developer products](https://create.roblox.com/docs/production/monetization/developer-products), [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService)

No paid feature is implemented or approved by this research. Product selection, regional policy restrictions, ownership checks, and refund behavior require a fresh official review in Phase 9. Nothing here authorizes a future player settlement service or establishes an exchange rate. [Monetization overview](https://create.roblox.com/docs/production/monetization)

## Tools and assumptions register

Rojo 7.7.0 was the current release returned by the official GitHub API during inspection and is pinned in `rokit.toml`. Luau 0.740 tools were fetched locally for compilation/type checking; Roblox Studio may use a different engine-integrated Luau version. Rojo has separate CLI and Studio plugin installation steps. [Rojo installation](https://rojo.space/docs/v7/getting-started/installation/), [Rojo 7.7.0 release](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.0), [Luau 0.740 release](https://github.com/luau-lang/luau/releases/tag/0.740)

| Assumption or open question | Current decision | Revisit |
| --- | --- | --- |
| Small team and no operating backend | Native services; explicit modules; no framework | Before market scale expansion |
| Low-frequency management slice | Durable economic checkpoint per action | Phase 1 budget/load test |
| Client/UI and durable world state can lag | Show revisions and pending states; never spend from cache | Every feature adding shared assets |
| DataStore/MemoryStore/Messaging quotas change | Snapshot above plus runtime observation | Before dependent implementation/release |
| Global market hot items exceed single-key capacity eventually | Bounded closed pilot; stop at cap | Phase 4, before public trading |
| 20v20/30v30 feasible on chosen devices | Unproven target, not accepted requirement for first battle | Phase 7 performance experiment |
| No published test universe configured here | Record IDs/access later, never invent them | Before Phase 1 live persistence checks |
| Audit and receipt retention can fit indefinitely | Not assumed; measured archives and safe compaction required | Before market/monetization launch |

See [validation evidence](VALIDATION.md) for what was actually executed locally. Research is not a substitute for published-server tests.

## Phase 1 verification supplement — 2026-09-28

The implemented ScreenGui uses `CoreUISafeInsets` and explicit scrolling/compact layout. Safe areas still need device testing; the API setting alone cannot prove usable rendering. [Official ScreenGui reference](https://create.roblox.com/docs/reference/engine/classes/ScreenGui)

Roblox-aware strict analysis uses Luau LSP 1.70.0 with its pinned `globalTypes.d.luau` and Rojo source map. `tools/setup_tools.ps1` verifies SHA-256 checksums of downloaded development tools; these tools do not ship in the game. [Official Luau LSP repository](https://github.com/JohnnyMorganz/luau-lsp), [1.70.0 release](https://github.com/JohnnyMorganz/luau-lsp/releases/tag/1.70.0)

Rechecked native DataStore UpdateAsync behavior and budgeting against the official documentation while implementing the persistence adapter. Domain tests inject callback replay, unavailable calls and committed writes with lost responses. Actual backend quota/rejoin behavior remains a staging gate. [Data stores](https://create.roblox.com/docs/cloud-services/data-stores), [Errors and limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits)

Current executed results are in [Phase 1 implementation](PHASE1_IMPLEMENTATION.md); interactive tests are in the [Studio checklist](PHASE1_STUDIO_TEST.md).
