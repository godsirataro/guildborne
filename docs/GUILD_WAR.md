# Player Guilds, wars, and territory

Status updated 2026-10-06: the user's expanded first-release plan includes Player Guild systems. Membership transitions and a read-only recovery planner now exist locally; persistence, networking and UI are not yet bound. Historical phase references below describe implementation order, not authorization to remove features from launch scope. See [membership implementation status](uat01/PLAYER_GUILD_MEMBERSHIP.md). War and territory remain design work without runtime acceptance.

## Two different guild concepts

Personal Guild progression belongs to one profile. Player Guild membership is a separately governed organization of real users. An adventurer NPC is never a guild member or a permission-bearing player identity. Use explicit `personalGuild` and `playerGuildId` names rather than a shared ambiguous `guild` field.

| Role | Planned permissions |
| --- | --- |
| Guild Master | Transfer leadership, assign roles, set treasury budgets, disband under safe conditions |
| Officer | Invite/remove eligible members, propose research, administer approved budgets |
| Commander | Register war roster, issue tactical orders, spend allocated battle supplies |
| Member | Join activities, contribute resources, view ledger and own permissions |

Roles map to capability sets in configuration. A commander is not automatically a treasury administrator. Promotion cannot exceed the actor's authority. Leadership transfer requires the named recipient's acceptance and a recorded revision. Disband is blocked by active wars, unresolved deposits/claims, or unallocated treasury holdings; design a deterministic return policy before enabling it. Inactivity succession is deferred pending abuse review.

## Membership, treasury, and progression

One Player Guild per user initially, with a proposed 50-member cap. A membership operation reserves the player's membership slot, adds a provisional guild member with the same operation ID, and then marks both sides active through acknowledged updates. Only fully active membership can exercise permissions. Leaving/revocation first disables authority in the guild record and then clears the profile projection. Repair partial joins/leaves from persistent operation state; a cached badge never grants permission. Two concurrent guild invitations cannot bypass the profile's single membership reservation.

The guild record owns roles, research, treasury balances, and its audit outbox. Its profile membership field is a projection plus handshake state, not a competing permission authority. Guild deposits/withdrawals need the same reserve/deliver/receipt principles as the market bridge, with separate operation IDs. Do not copy a player's balance into a guild key and hope both saves succeed. Start Phase 5 with no treasury transfers; Phase 6 adds only reviewed deposit/spend paths, not arbitrary personal withdrawals.

Guild progression adds research choices, shared quests, bosses, shop unlocks, capped buffs, rankings, and later alliances. Research consumes earned resources and should specialize rather than multiply all power. Boss rewards are individually claimable using a unique encounter-participant receipt; treasury contributions are explicit. Alliances cannot silently merge membership or bypass territory/roster caps.

## Battle model and scope gates

The long-term targets are 20v20 and 30v30 real players, not NPC roster counts. Start with an 8v8 closed test to establish server simulation and mobile performance. Decide the controlled-unit model before Phase 7 implementation: recommended experiment is one active champion per real player, with roster progression contributing a capped selectable loadout. Do not spawn every adventurer for every participant by default. Expanding player count requires measured CPU, replication, latency, and device frame-time evidence.

Combat roles: tanks hold lanes; DPS pressure objectives; supports sustain pushes; siege crews threaten fortifications at a supply cost; scouts reveal limited tactical information; commanders allocate supplies and coordinate objectives. Roles must have counters and cannot be purchased as a superior power tier. Normalize/cap competitive stats, bound consumable loadouts, and disable paid advantages in war.

Possible objectives are capture points, resource points, supply points, fortresses, and castles. First war mode: two side points generate bounded score while the central fortress unlocks during announced windows. Captures require contested presence over time, validated by the server. Supply routes support siege rather than endless deathmatch rewards. Proposed match duration is 15 minutes; configurable overtime has a hard end and a deterministic tie rule. No resource rewards for farming kills of the same player.

## Match state and admission

`Scheduled → RosterLocked → Provisioning → ReadyCheck → Running → ResultPending → Finalized`

Provisioning failure becomes `Rescheduled`; failed quorum or unrecoverable simulation loss becomes `Voided`. Proposed rules: lock rosters 10 minutes before start, allow a 90-second reconnect grace, and require a minimum ready count before starting. Set regional windows and avoid mandatory middle-of-the-night defense. Forfeits need a clear ready-check policy; ordinary teleport failure must not automatically count as a loss.

A durable match record contains season, territory, guild IDs, roster snapshot, rules/config revision, authorized simulation server token and owner epoch, timestamps, score checkpoint, and result identity. Destination servers revalidate participant admission against server-side state. TeleportData carries only an opaque match reference, never an authoritative loadout, role, or balance. Reserved-server access codes remain server-private. Roblox requires published-client teleport tests; see [official teleport guide](https://create.roblox.com/docs/projects/teleport).

Only the assigned simulation authority may commit a final result, conditional on its owner epoch and expected Running/ResultPending state. Duplicates return the original result. The first version does not live-migrate battles; if the simulation is irrecoverably lost, void/reschedule rather than invent a winner. Reward claims derive only from Finalized results, with one claim per eligible participant. No defeat of another server's lease can resurrect an already final match.

## Territory ownership and economic consequences

Each territory has an independent durable record: territory ID, season ID, owner guild ID or neutral, ownership revision, effective time, source match/result ID, capped production modifiers, and upkeep state. A transfer compares the expected previous ownership revision and consumes one certified final result. Applying the same result twice cannot re-award bonuses. A result from a past season cannot seize a current-season territory.

| Territory example | Benefit concept | Anti-snowball bound |
| --- | --- | --- |
| Iron Valley | Up to +10% eligible iron gathering output | Shared per-guild daily bonus cap; baseline iron available elsewhere |
| Dragon Mountain | Limited bonus rolls on eligible dragon materials | Participation requirements and weekly cap |
| Crystal Lake | Alchemy reagent production objective | Alternate sources and diminishing additional holdings |
| Trading City | Market access convenience or capped earned service benefit | No price control; no paid fee advantage; launch benefit chosen in Phase 8 |
| Imperial Capital | Cosmetic prestige and strategic scoring | No universal production or damage multiplier |

These are design candidates, not simultaneous launch promises. Store the ownership/config revision used when a gathering job starts; later capture does not retroactively alter that job's reward. For long-lived jobs, define a boundary policy rather than stacking both owners' bonuses. Guild-wide bonus budgets and claim IDs are allocated durably; a server-local cap is insufficient.

The causal chain is war result → ownership → bounded resource modifier → legitimate production → inventory → voluntary market supply. Do not modify MarketReferencePrice or force trades. Record territory contribution separately in item faucets so concentration and shortages can be measured. If territory authority cannot be verified, suspend new territorial bonuses while leaving baseline PvE available; never guess ownership from stale UI.

Upkeep, diminishing benefit from multiple holdings, attack/defense windows, protected entry regions, and seasonal neutralization reduce entrenched monopolies. Tax systems and territorial market fees are deferred because they complicate accounting and can punish new players. Protect market escrow and Personal Guild progress from war loss.

## Events, seasons, and validation

World event definitions specify UTC start/end, region scope, objective IDs, bounded modifiers, content revision, and one-time reward eligibility. Dragon Invasion might increase reagent demand; Drought might lower herb supply with compensating alternate tasks. Events do not directly set market prices. Existing accepted orders keep their fee and price terms.

A season transition changes season-scoped rankings, territory, and objectives through idempotent transition records. Resolve or void pending wars before transferring ownership rules. Permanent Gold, items, adventurers, Personal Guild buildings, and paid entitlements remain. Old-season rewards use explicit cutoff/claim rules and cannot be redeemed into new-season rankings.

Release tests include concurrent promotion/kick, double join, treasury replay, roster changes after lock, unauthorized arrival, reconnect duplication, server death, duplicate results, ownership changes racing season rollover, and concurrent capped bonus grants. Simulate concentrated territory control and measure prices, access to basic materials, guild churn, and win rates by spend cohort. Heuristics flag collusion for human review; they do not automatically confiscate holdings or ban players.
