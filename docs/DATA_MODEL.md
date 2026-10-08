# Versioned domain data

> Phase 4.5 update (2026-09-29): Phase 4.5 market book schema v2 migrates in place at fixed b:<item>:1 keys. Generation lives inside the record. Profile schema stays v6 with optional transfer epoch and per-item floors; item:1 claim watermarks remain lifetime cumulative sequences. No progression rewrite.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): Current schema is v6: additive market={transfers,claims,goldIn,goldOut}. Claims stores per-item/epoch applied sequence watermarks, not a growing claim-ID set. v5 migration preserves progression/assets and adds empty market state. GB_Market_<environment> stores schema-v1 books at b:<item>:<epoch>; profiles and books have independent commits bridged by durable operations.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


> Current update — 2026-09-28: Current executable schema is **v5**, content slice-3.0-city. Settlement contains tavern level, candidate and sequences, journal, timestamped jobs with server-private outcomes, Elixir count and durable purchase receipts. Hero IDs include h:N and duplicate classes; rank/condition/injuredUntil persist. Quarters levels and Hall levels 1–10 bound capacity/actor level. v4→v5 migration preserves existing actors and raises the Hall floor only as needed; see [current contract](CITY_GUILD_DISPATCH.md). Earlier schema notes below document historical transitions.

Historical Phase 2.2 introduced schema **v2**, content `slice-2.2`, and `data.character`: `definitionVersion=1`, `raceId=Human`, `tier=1`, `level=1`, `xp=0`, with `classId`, `classPathId` and `skillId` absent until selection. The five class definitions map paths/skills/training weapons in server Content; Human is the only playable race. The class kit is not an inventory instance. Phase 2.3 now adds equipment assignments; Phase 2.5 now supplies bounded skill builds for each actor.

The explicit v1→v2 migration validates the legacy envelope, rejects unexpected pre-existing character data, copies the profile, and adds only the character record. It runs within the existing lease-acquisition UpdateAsync. Hero IDs, gear, XP, active quest snapshots, receipts and audit remain intact. Future versions and corrupt input fail closed without defaults overwriting them. A migrated profile cannot be opened by the old v1-only server: rollback must retain the v2 reader or use a separately reviewed data restoration, never downgrade/reset the record.

Character class selection is a persisted, revision-checked, idempotent command. This phase permits one starter choice; respec is deferred. Player XP uses the existing cap/level formula (50 XP per level, max level 10), separate from companion XP. Targets, health, cooldowns and animation instances remain transient. Avatar replacement within a session preserves domain HP/downed timer/cooldowns; an actual fresh session starts healthy. See [expansion scope](EXPANSION_PLAN.md).

Phase 2.1 keeps schema v1 unchanged. Combat HP, targets, threat, cooldowns, movement and enemy generations are transient. Combat rewards checkpoint existing Gold/XP fields and operation/audit records. No save migration or reset is required. See [combat](COMBAT.md).

Status: Phase 0 design contracts retained for later systems. The executable Phase 1 schema is [ProfileSchema.luau](../src/server/Systems/ProfileSchema.luau); [implementation notes](PHASE1_IMPLEMENTATION.md) describe the small changes from the illustrative v1 example below. Future fields still require explicit migrations.

## Conventions and ownership

Phase 1.6 keeps schema v1 and expands content to five classes, roster slots and party members. Existing three-class records and old active quest snapshots validate unchanged. Knight/Mage records require the expanded reader, including after rollback. World hero models, trails, labels and animation state are derived at runtime and never saved. See [compatibility details](PHASE1_6_IMPLEMENTATION.md).

All persisted records are serializable finite numbers, booleans, valid UTF-8 strings, arrays, and string-keyed dictionaries. No Instances, functions, cyclic tables, NaN/infinity, or reliance on sparse-array serialization. Optional values are absent, not sentinel prices of zero. Use numeric Roblox UserId for identity; key encoding is its decimal string. IDs never use display names. Timestamps use server UTC Unix seconds; revisions and sequences are nonnegative integers.

Schema version describes storage shape; content version describes gameplay definitions; revision describes a particular record update. They are not interchangeable. Store names identify domain/environment, not every schema revision. Use a small fixed set of stores and stable prefixes; keep fields that require atomic changes in the same key. [Official organization guidance](https://create.roblox.com/docs/cloud-services/data-stores/best-practices)

| Record | Proposed key | Owner / introduced |
| --- | --- | --- |
| Player envelope | `GB_Player_dev`, `p:<userId>` | PlayerDataService, Phase 1 |
| Player audit page | `GB_PlayerAudit_dev`, `p:<userId>:<page>` | Bounded immutable audit export, Phase 1 |
| Market book | `GB_Market_dev`, `b:<itemId>:<epoch>` | Market repository, Phase 4 |
| Market book routing | `GB_Market_dev`, `route:<itemId>` | Market epoch lifecycle, Phase 4 |
| Fill archive page | `GB_MarketAudit_dev`, `f:<itemId>:<epoch>:<page>` | Immutable archive writer, Phase 4 |
| Price candle page | `GB_MarketStats_dev`, `c:<itemId>:<period>:<bucket>` | Rebuildable projection, Phase 4 |
| Player Guild | `GB_Guild_dev`, `g:<guildId>` | PlayerGuildService, Phase 5 |
| War match | `GB_War_dev`, `w:<matchId>` | WarService, Phase 7 |
| Territory | `GB_World_dev`, `t:<territoryId>` | TerritoryService, Phase 8 |
| World event schedule | `GB_World_dev`, `events:<revision>` | Reviewed content deployment, Phase 8 |

`_dev` is illustrative; select environment from a server-side universe allowlist, not client input. Enforce composed key length before writes; item IDs used in composite market keys have a narrower maximum (16 ASCII characters) so epoch/bucket suffixes fit within the platform limit. Compact server-generated guild/match IDs must also fit. No future stores are created in Phase 0.

## Phase 1 player schema v1

Proposed envelope example for a newly initialized player, before recruitment:

```json
{
  "schemaVersion": 1,
  "revision": 1,
  "contentVersion": "slice-1",
  "createdAt": 1790467200,
  "updatedAt": 1790467200,
  "session": {
    "ownerToken": "server-generated-session-token",
    "epoch": 1,
    "leaseExpiresAt": 1790467380
  },
  "data": {
    "profile": { "userId": 12345 },
    "currencies": { "gold": 0 },
    "adventurers": {},
    "inventory": { "stacks": {}, "equipment": {} },
    "personalGuild": { "buildings": { "guildHall": 1 } },
    "party": { "adventurerIds": [] },
    "progression": { "tutorialStep": "recruit", "recruitedClasses": [] },
    "quests": {
      "nextRunSequence": 1,
      "claimedThrough": 0,
      "firstClears": {}
    },
    "statistics": { "questsCompleted": 0, "goldCreated": 0, "goldDestroyed": 0 },
    "settings": { "musicEnabled": true, "reducedMotion": false }
  },
  "operations": { "lastCommittedSequence": 0, "recentResults": [] },
  "audit": { "nextSequence": 1, "exportedThrough": 0, "outbox": [] }
}
```

Example identity/timestamps are fixtures, not live account or environment settings. `session.ownerToken` may be absent when released; preserve the increasing epoch. Example initial Gold is zero because the first recruit is free. The content version is a proposed future identifier, not an existing configuration module.

| Field | Meaning and invariant |
| --- | --- |
| `adventurers[id]` | `{classId, level, xp, equipmentSlots}`; owner is the profile, ID is server-created |
| `inventory.stacks[itemId]` | Positive integer; omit zero entries; total counts checked |
| `inventory.equipment[id]` | `{definitionId, upgradeLevel, binding}`; unique instance ID, no copied ownership |
| `adventurer.equipmentSlots.weapon` | Optional equipment instance ID; same profile, compatible class, not equipped elsewhere |
| `party.adventurerIds` | Up to three unique owned IDs; no clients may reference other players' rosters |
| `quests.active` | Optional `{runId, sequence, questId, contentVersion, partySnapshot, startAt, completeAt, rewardSnapshot, state}` |
| `rewardSnapshot` | Validated exact Gold/XP/item reward, stable over restart; Phase 1 rewards are deterministic |
| `claimedThrough` | Monotonic terminal run sequence; one active run allows compact replay protection |
| `firstClears[questId]` | Durable claim fact committed with first-clear reward; repeated runs use repeat table |
| `recentResults` | Bounded response cache, not sole replay defense; one unresolved command is retained separately |
| `audit.outbox` | Bounded committed events waiting for durable export; never silently discarded |

An equipped item remains in inventory and its equipment slot is a reference, not a second asset. Derived stats combine catalog base stats, level curve, and validated equipment; do not persist both derived and canonical values as competing sources. Party snapshots preserve participants and relevant combat values at quest start, so later equip changes cannot rewrite an active encounter.

Proposed Phase 1 limits: 3 adventurers, 1 party, 1 active quest, 8 stack definitions, 50 equipment instances, 32 recent command results, and 128 pending audit records. Stop an operation before exceeding a cap. A completed quest whose item cannot fit stays claimable; no reward is lost or partially credited. The slice's first-clear equipment grant is once-only, so repeated starter farming does not fill equipment slots. The profile soft size ceiling is 128 KiB; measure serialized bytes, not only entry count.

## Important domain types

These Luau-style declarations are documentation, not runtime code:

```luau
type OperationStatus = "Pending" | "Committed" | "Rejected" | "RecoveryPending"
type AssetDelta = { gold: number, items: { [string]: number } }
type AuditEvent = {
    eventId: string, operationId: string, sequence: number,
    actorUserId: number?, occurredAt: number, kind: string,
    reason: string, delta: AssetDelta, configVersion: string,
}
type QuestState = "Running" | "ReadyToClaim" | "Claimed"
type Binding = "Account" | "Tradable"
```

Runtime validators must enforce integer/range/domain constraints that `number` and `string` types cannot express. Negative deltas are permitted only in validated changes, never in holdings. Use explicit debit/credit reason codes and counterpart operation IDs for transfers.

## Future player evolution

Add skills, traits, jobs/professions, elements, research, region unlocks, and class specialization as fields on canonical adventurers/progression when their systems ship. Add facility levels under `personalGuild.buildings`, crafting jobs under `crafting`, real-player membership under `playerGuildMembership`, and market bridge state under `marketTransfers`. No copied guild treasury or territory authority goes in the player profile.

Separate account-bound entitlements from game items. A future `monetization` section records verified benefit ownership and durable purchase receipt identifiers. Receipt capacity/archival must be designed before purchases ship; never discard old PurchaseIds just because a session cache is full. No monetary exchange value or payout address is part of the domain schema.

## Future market records

| Type | Required fields |
| --- | --- |
| Order | orderId, ownerUserId, itemId, side, kind, limitPrice, initialQuantity, remainingQuantity, acceptedSequence, expiresAt, state, revision, reservedAssets, feeBps/feeVersion, cumulativeGross/fee |
| Deposit | transferId, sourceUserId, sourceSessionEpoch, bookEpoch, immutablePayload, payloadIdentity, Prepared/Accepted/Aborted outcome, acknowledgments |
| Delivery | claimId, destinationUserId, bookEpoch, sequence, immutablePayload, PreparedDelivery/Delivered state |
| Fill | tradeId, bookEpoch, sequence, buyOrderId, sellOrderId, buyer/seller IDs, price, quantity, gross, fee, executedAt, configVersion |
| Book envelope | schemaVersion, revision, itemId, epoch, accepting/sealed state, nextSequence, orders, escrow, claimable, deliveries, bridgeReceipts, feeSinkTotal, auditOutbox |
| Book routing | itemId, activeEpoch, revision, sealedEpoch references; switching requires durable sealing before routing update |
| Reference snapshot | itemId, asOf, candidate, published, sampleCount, participantCount, confidence/freshness, algorithmVersion |
| Candle | itemId, intervalSeconds, bucketStart, open/high/low/close?, units, quoteVolume, tradeCount, sourceCheckpoint, revision |

The source reservation and destination receipt can temporarily both mention an asset. For supply accounting they represent **one** logical transfer, identified by transferId: before Accepted, count the source reserved amount; after Accepted, count the destination holdings and treat source reservation as provenance only. For outbound claims, count PreparedDelivery until the profile credit commits, then count profile holdings. Reconciliation resolves uncertain cases from durable receipts and reports unknowns, never double-counts them as inflation.

History archives use bounded pages and explicit export checkpoints. Player audit pages similarly use deterministic user/page keys and event sequence IDs: persist the page, verify its identity, then advance the profile export checkpoint before pruning its outbox. Retrying an export writes the same events, not duplicates. Projection retries deduplicate by contiguous book sequence, never by a timestamp window alone. A route change cannot let a delayed writer reopen a sealed epoch. Receipts persist until the safe closed-epoch protocol in [marketplace](MARKETPLACE.md) completes.

## Future guild/world records

PlayerGuild: schema/revision, guildId, filtered display-name source/version, masterUserId, members with membership operation IDs and role capabilities, pending membership operations, treasury, research, activity progression, season ranking reference, and audit outbox. PlayerGuildId is not a Personal Guild ID or a Roblox group ID.

WarMatch: matchId, seasonId, territoryId, guild IDs, locked roster, rules revision, owner token/epoch, scheduled/start/end times, state, score checkpoint, final result ID, and participant claim ledger. Territory: ownerGuildId, seasonId, ownershipRevision, sourceResultId, modifier revision, effectiveAt, upkeep, and capped bonus allocation state.

WorldEvent: eventId, revision, UTC start/end, region allowlist, objective IDs, modifier caps, reward eligibility policy. Season: seasonId, state, transition operation ID, ranking snapshot reference, and territorial reset policy. No reset instruction implicitly wipes player profiles.

## Migration and recovery rules

1. Acquire ownership and validate envelope/version. Absence and load failure are different.
2. New profiles use a fresh deep-copied v1 default; never share mutable default tables between users.
3. Apply pure sequential `vN → vN+1` functions to a copy. Each migration preserves unknown retained data unless an explicit removal is approved, and records provenance.
4. Validate balances, unique IDs, equipment references, bounds, content availability, and serialized size.
5. Commit new shape and schemaVersion together. Report active only after durable success; retry cannot apply the migration twice.
6. Reject newer unsupported versions without writing. Do not silently downgrade or reset corrupted data.

There is no preexisting v0 player population. Phase 1 tests should include a clearly synthetic v1→v2 additive migration fixture, repeated application, interrupted writes, missing/invalid fields, and forward-version refusal. Deleted content IDs require a mapping or preserved legacy definition; never silently turn an unknown item into Gold.

Before production migrations, exercise backup/restore on staging, measure record growth, define minimum reader version, and rehearse partial rollout. DataStore versions are recovery aids, not a transaction ledger. Restoring traded profiles requires reconciliation of external effects. Associate records with users where supported and inventory every player-linked archive for deletion workflows; finalize retention and privacy policy before public release.

## Historical schema v3 — Phase 2.3

Content is `slice-2.3`. `character.equipmentSlots` maps weapon/armor/accessory to owned instance IDs; heroes use the same three slots. `inventory.nextEquipmentSequence` starts at 1 and allocates shop instance IDs. The validated v2→v3 migration adds only these two fields; v1 first migrates to v2. No legacy gear is replaced or duplicated. Schema validation enforces global instance exclusivity and class/slot compatibility. Rollback must preserve a v3-capable reader. See [inventory contract](INVENTORY.md).

## Current schema v4 — Phases 2.4–2.7

Content is `slice-2.7`. The v3→v4 migration adds only `data.expansion`: buildings and next ID, persisted gather cooldowns and discovery flags, actor tier/path/skills/equipped art, a one-time ancestry flag, and tower highest/checkpoint/active run/next sequence. Existing inventory, roster, character XP, quests and currency remain exact. An active Fighting floor is reconstructed on join; rewards are committed only by the private server victory path. Readers must remain v4-capable on rollback. See [class rules](CLASS_SKILLS.md), [base rules](BASE_BUILDING.md), and [tower rules](TOWER.md).
