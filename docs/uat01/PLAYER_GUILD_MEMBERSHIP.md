# Player Guild membership implementation — 2026-10-06

First-release scope includes Player Guilds, separately from Personal Guild island and NPC progression. This local batch implements the membership domain and a read-only recovery planner. It does not enable multiplayer guilds in the running game.

## Implemented

- One membership reservation per user, with a monotonically increasing generation.
- Founder and invite acceptance handshake: reserve user slot, prepare canonical guild member, activate slot, then activate guild member. Only the last step grants guild capabilities.
- Targeted expiring invitations, capacity checks, invitation authority revalidation, and a bounded pending invitation list.
- Master, Officer, Commander and Member capabilities. Commanders do not inherit officer administration rights. Treasury capabilities are disabled.
- Revocation before slot release, safe removal after a newer reservation, and retained generation fences that prevent delayed join proofs from recreating removed memberships.
- Leadership transfer requires the named active recipient to accept the latest unexpired offer. Only one current master is retained.
- Recovery distinguishes failed reads from confirmed missing records. Inconsistent active records are quarantined; no missing read is treated as permission to erase or recreate membership.
- Active-member-only roster projection hides canonical operations, fences and invite lists, sorts by role and numeric user ID, and exposes a live leadership offer only to its named recipient.
- A staged EN/TH roster view includes explicit leave and leadership acceptance confirmation, busy guards and invalidation of leave confirmation when membership generation changes. It is not registered in live navigation or protocol.
- Stored-record schema validation rejects contradictory masters, capacity overflow, malformed membership generations, missing revocation receipts and invalid transfer recipients. A deterministic 240-step membership/transfer/removal sequence remains schema-valid.
- A staged invite-acceptance coordinator drives six durable writes through an injected storage contract. The operation journal pins the intended membership generation before reserving the slot. Twelve before/after-commit fault cases, post-removal replay, operation identity mismatch, expiration and two interleaved cancellation/revocation races pass against isolated in-memory records.

## Required before runtime binding

1. Persistent canonical guild keys and durable user membership slots, with conditional revisions and server session fencing. The current functions operate on trusted mutable record snapshots; they are not networking handlers.
2. Bind the staged founder, invite-acceptance, cancellation and leave/kick coordinators through the validated store and explicit provider to a dedicated real DataStore. The provider and 46-character SHA-256/base64url key adapter exist but are not opened or used by ServerBootstrap. Bind server session fencing, request budgets and authenticated identity before activation. Never use client-provided records as proof.
3. The staged store validates slot/guild/journal records and their logical identity before reads and writes. Define migrations and real storage recovery. Retain generation fences safely, with a bounded storage strategy; do not prune them merely by age and allow old operations to replay.
4. Bind actor identity to the authenticated player and validate payload sizes, action rates, expected membership generation and record revision. An old kick or promotion request must not affect a later rejoined membership.
5. Bind the implemented roster projection to an authenticated viewer and resolve/filter names. Never send full canonical records, invitation lists, operation IDs, or unrelated transfer offers to clients.
6. Bind and expand the staged roster/leave/transfer view. Creation, invitations, role changes and richer pending/recovery/error screens remain to be built.
7. Exercise fault injection at every durable write, parallel invitations and capacity races, stale sessions, actual two-client membership, reconnect persistence and device usability.

The planner intentionally returns `InvestigateMissingGuild` for an occupied slot whose guild is confirmed missing. Recovery must consult durable creation/cancellation history before releasing that slot; guessing could violate membership exclusivity.

## Evidence

`tests/run_player_guild.luau` passes 55 focused scenarios across membership transitions, recovery decisions, roster privacy, persisted schemas, coordinators and validated storage. Cancellation has 60 before/after-write fault combinations across five unfinished join stages; removal has 30 combinations across master kick, officer kick and self-leave; founding has 12 combinations. Delayed commands preserve newer memberships, and current authority is checked before revocation. Completed joins require leave; cancellation cannot undo them. Unknown or unavailable reads do not release slots. These are synthetic records and do not modify real player profiles. Latest full-suite result: 605 passing tests in `validation-guild-store-domain.txt`.

The cancellation journal enters `Cancelling` before consuming/fencing its pinned generation, revoking canonical membership, releasing only the matching slot, removing the old member and entering `Cancelled`. The join coordinator refuses cancelled journals and cannot overwrite them during finalization. An unfinished member who became master requires leadership recovery rather than forced removal. Durable operation records and generation fences must be retained; the eventual store must validate them and bound keys without losing replay protection.

Later pending-state projection adds one focused privacy test (56 focused tests total). It exposes only the authenticated owner's public phase, with no operation IDs, target identity or invitation proofs. Terminal phases are not presented as pending.

Native Studio UI fixture: 84 views across EN/TH and 240/640/704-pixel widths, 654 text bounds and 18 captured actions pass. Pending creation/join/cancellation/removal, recovery, empty membership, cancel/busy/master-leave protection and stale-generation confirmation are checked without invoking networking. Evidence: `validation-guild-pending-ui-native.json`; the earlier 48-view record remains historical. Actual player input, networking and multiplayer acceptance remain pending.

## Validated storage and native provider

`PlayerGuildStore` checks a versioned envelope with kind, full logical key, revision and domain schema. Key collisions and corrupt records fail closed; they are never treated as missing or overwritten. Each conditional retry receives a fresh isolated copy. Before/after-write exceptions remain uncertain, so coordinators retry the same journal identity. An integrated synthetic test drives founding, joining, expired-invite cancellation and leaving through this store. Counter and generation exhaustion stop before records leave the supported integer range.

`PlayerGuildStoreProvider` receives an explicit store handle and does not open one. It bypasses GetAsync cache and preserves platform metadata/user IDs in conditional updates. `PlayerGuildStoreKey` hashes kind plus logical identity into 46 ASCII characters. Native Studio testing used a fake handle only: two callback invocations, latest candidate selection, metadata preservation, cancellation without writes and four hash vectors passed. Python independently confirmed the native SHA-256/base64url vectors. Evidence: `validation-guild-provider-native.json`; audit: `tools/audit_guild_key_vectors.py`. No cloud write was performed.

Founding rolls forward with immutable creation identity; guild-key conflicts require recovery and do not overwrite an existing guild. A founder that transferred leadership and left cannot replay an unfinished creation to steal a newer membership. Name filtering, creation cost policy, DataStore activation, operational migrations and live session recovery remain pending.

Platform references checked 2026-10-06: [write uncertainty and key limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits), [uncached verification reads](https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching), [conditional updates](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore), and [EncodingService hashing](https://create.roblox.com/docs/reference/engine/classes/EncodingService).
