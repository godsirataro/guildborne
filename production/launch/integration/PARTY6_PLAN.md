# Six-player Party and shared PvE — launch contract, 2026-10-14

Status: APPROVED REQUIREMENT / DESIGN PROPOSAL / NOT IMPLEMENTED. Required for first Public. User clarification supersedes earlier references to a human-member Player Guild.

## Identity and scope

- Personal Guild: one human owner, their NPC heroes, Hall/island and earned progression. No other human members.
- Human Party: temporary cooperative group of 1–6 human players including its leader. Independent of each member's personal Guild.
- Federation (สมาพันธ์): persistent association across human players/personal Guilds; remains post-launch. Do not expose existing PlayerGuild membership as a launch Guild feature.
- Solo means no human Party is required. A solo human may bring their own heroes. Do not remove the existing allowance of up to five heroes per owner merely to fit the Party feature.
- Solo humans, human Parties and owners bringing NPC teams must be able to share the same supported map/zone/dungeon encounter population. Party membership is not a requirement to enter ordinary launch content or earn legitimate participation rewards. Never promise all players worldwide occupy one server; shard/instance capacity is bounded and measured.

## Proposed encounter and reward rules

The following are implementation design defaults, subject to balance playtests; the approved intent is that more eligible participants divide EXP and loot.

1. One authoritative encounter ID, shared enemy HP/threat/outcome and fixed reward budget per encounter. Joining/leaving a Party cannot reset enemies or create another reward budget. Difficulty and reward tier are fixed when the encounter starts; late arrivals cannot multiply that budget. Required solo content must remain winnable by one appropriately progressed owner/team.
2. Count eligible human owners, not NPC count, for the cross-player split. NPC participation credits its owner; existing player-versus-hero XP allocation occurs inside that owner's share and must be reconciled before implementation. Bringing heroes does not mint extra reward shares.
3. Eligibility uses server-observed participation in that encounter: meaningful damage, effective healing/protection or tanking, eligible area and active involvement. Do not require a last hit, count overhealing as useful contribution, or let mere proximity/Party membership dilute others' rewards. Define and test exact thresholds/windows before coding payouts. A dead or briefly disconnected legitimate contributor must not automatically lose earned eligibility; define a bounded recovery policy.
4. Example only: a fixed 600 EXP owner pool yields 600 to one eligible owner, 300 each to two, or 100 each to six. If an eligible solo owner fights beside a Party, include that owner in the same denominator; six is the Party cap, not necessarily the encounter population cap. Integer rounding must preserve the exact total with a deterministic, non-exploitable remainder policy.
5. Currency and stackable materials share the fixed budget. Indivisible equipment cannot be copied or cut into fractions: allocate each original unit once among eligible owners using a server-side fair draw/rotation with visible rules. Exact policy and small-pool rounding fairness need balance approval. No automatic loot trading or Party-leader loot ownership is implied.
6. Personal story/class first-clear and guaranteed quest items remain per-owner prerequisite rewards. Do not divide away a required quest item or let Party membership bypass a mentor/Hall/class gate. Keep this separate from repeatable shared enemy/dungeon loot.
7. Snapshot eligible owner IDs, reward budget and allocations at settlement. Persist settlement before per-profile grants, with encounter/recipient claim identity, schema version and payload hash; preserve session fencing and acknowledge only committed delivery. Never claim separate profile writes are atomic: successful recipients retain receipts, failed deliveries stay pending and recover without reroll or recomputing the split. Inventory-full delivery must reserve the assigned item rather than duplicate, discard or reassign it prematurely. Existing AdventureLifecycle/AdventureRewardAdapter in-memory state is insufficient for durable multi-owner recovery; introduce a reviewed persistence contract through existing storage boundaries. Define cap overflow policy explicitly rather than awarding excess XP or silently reallocating another owner's reserved share.
8. No launch shared EXP multiplier by headcount. Personal PvE boosts, if later approved, apply only to their owner's assigned share under the existing cap contract; they cannot shrink another player's share. Confirm this interaction before commerce activation.

## Party lifecycle and native UI

Invite/accept/decline/expire; one Party per human; 6 includes leader; server validates membership and concurrent accepts. Leave/kick/disband, deterministic leader transfer, disconnect/rejoin grace, ready check and explicit travel acceptance. Membership changes after settlement cannot alter claims. Kick-before-kill must not erase earned participation; anti-leech rules cannot grant an inactive new member a share simply because of an invite.

Native EN/TH UI shows Party roster, each owner's hero count, leader, invite availability, ready/travel state and current reward-sharing explanation. Show waiting/full/unavailable/left-instance/recovery states. Party controls give no authority to edit another owner's heroes, inventory, personal Hall or build permissions. Cross-guild friendship is allowed because each Guild has only its own owner.

Routing groups consenting members into a compatible shared instance while keeping personal level/quest access gates. Define slot reservation, partial-arrival recovery and return route; do not strand failed travelers or silently admit locked members. Solo entry remains available. Class/mentor trials remain individual assessments unless explicitly redesigned, even when world/dungeon PvE is shared.

## Current source gap and work sequence

Observed source: `RegionalCombat.luau` builds `RegionalEncounter_<UserId>_<zone>`, caches encounters per owner and marks `OfflinePersonal`; `PlayerParticipation.luau` requires matching ownership. Existing `data.party`/hero scheduler represent NPC companions. These are not already six-human co-op.

Cross-owner actor keys must include ownerUserId plus local actorId: current `player` and hero IDs are not globally unique. Define PvE allegiance/healing/targeting explicitly instead of removing owner checks wholesale. Current CombatRewards grants configured XP to each member entry; reconcile this with the proposed owner budget before implementation. The 600 EXP example is a new design illustration, not a claim about today's reward code or permission to silently nerf legacy earned progression.

1. Reconcile identity/UI terminology, inventory existing PlayerGuild* modules and persisted namespaces; map only reviewed reusable primitives into future Federation. Preserve historical data and canonical IDs. Do not rename/delete persisted records or activate legacy membership to satisfy this plan.
2. Finalize eligibility, reward budgets, loot allocation and solo pacing contracts with concrete scenarios. Assign actual module write scopes before workers implement; no duplicate economy or party service by assumption.
3. Add authoritative human Party lifecycle and minimal client projection separately from NPC party selection. Native invitation/roster/ready UI and shared travel integration.
4. Replace owner-isolated encounters on selected launch destinations with shared encounter authority, multi-owner targeting/support and participant accounting. Retain individual mentor/quest gates and owner-only hero commands.
5. Integrate conserved reward settlement with bounded durable pending claims/replay recovery. Test fault injection across recipient saves and instance shutdown; player-market escrow is not activated.
6. Integrate EN/TH UI; play normal Solo, Party and mixed-population routes, then verify 2, 4 and 6 real clients. Only then accept the feature for Public.

## Release gates and scope impact

- Six humans with five heroes each is 36 allied actors before enemies or outside players. This is a required stress scenario, not measured supported server capacity. Additional solo/Party visitors require a separately measured total instance cap. Keep the original two/four-client checks and add six-client and mixed-population checks.
- No control of another owner's hero/profile/Hall; all authoritative targeting and friendly support respect encounter rules. No duplication through join/leave, last-hit, Party split/merge, disconnect, retry or server restart.
- Test healer/tank, dead contributor, late join, AFK, high/low level, full inventory, same owner repeated requests, six plus eligible outside solo, and tiny loot pools. Total distributed value equals the approved encounter budget, excluding separately documented personal quest awards and approved personal modifiers.
- Test actual devices, frame time/memory/thermal behavior and readable telegraphs with the supported population. A six-client single-server test is not cross-server evidence.
- Persistent staging, cloud instance transfer where used, and human UAT remain external gates. No publication, paid assets or live-commerce activation is authorized by this design.
- Public readiness must be recalculated after this scope addition. Previous approximate 40% used the older scope and is not a current measured percentage. Planning adds requirements, not implementation credit.
