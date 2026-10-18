# Class3 earned-proof implementation contract

Date: 2026-10-19. Source baseline: `a763e92590a09ee9e47b47135d147b85156380c9`.
Status: controller-accepted implementation direction; documentation only.
Runtime implementation, local regression, native earned play and human acceptance
are separate, pending facts. No new route, release flag or production save change.

## Authority and bounded decision

[PROGRESSION_CONTRACT](../PROGRESSION_CONTRACT.md) requires Class3 at the subject
actor's level70 plus an appropriate class quest, and preservation of earned
classes, saves and refunds. It does not require fourteen new named quests.

The controller accepted these defaults: reuse Sela/Crosshaven mastery for the
player and existing Guild HeroMentor activity for an owned hero; add separate
optional Class3 proof; preserve legacy and campaign compatibility; grant no
additional rewards; commit any story objective and proof atomically; use private
receipts with actor/path identity and replay/session fencing. These are now the
implementation direction, not unresolved broad narrative questions. Bespoke
stories, new mentors, new rarity restrictions and extra quest quantities are
outside this increment.

Current assignment uses task `progression` in the shared
`build/agentic/four-session-v6.sqlite3` ledger, restricted to documentation under
`production/progression`. Its broader existing runtime scope is not used here.
Implementation owners below require controller registry reconciliation first.

## Canonical path and prerequisite matrix

Definitions and readiness live in
[Expansion](../../src/shared/Data/Expansion.luau), not this document. Preserve IDs.

| Base class | Required normal Class2 parent | Class3 ID | Tower highest |
|---|---|---|---|
| Warrior | berserker | warlord | 5 |
| Warrior | duelist | sword_saint | 5 |
| Knight | guardian | fortress | 5 |
| Knight | paladin | holy_sentinel | 5 |
| Archer | ranger | beastwarden | 5 |
| Archer | sniper | deadeye | 5 |
| Mage | elementalist | archmage | 5 |
| Mage | spellblade | arcane_knight | 5 |
| Priest | cleric | high_priest | 5 |
| Priest | oracle | prophet | 5 |
| Warrior | any existing matching-class Tier2 | commander | 5 |
| Knight | any existing matching-class Tier2 | rune_knight | 5 |
| Priest | any existing matching-class Tier2 | bard | 5 |
| Archer | any existing matching-class Tier2 | shadow_dancer | 10 |

Every new promotion retains matching base class, Tier2 to Tier3, the actor's own
level70 and profile `quarry_patrol` first-clear. Normal paths retain exact Parent.
All four specials additionally require a placed `quarters` building;
`shadow_dancer` retains gathered `wood`, `stone`, `ore`, `herbs`. Current
`path.Prestige` checks quarters, not actor rarity: do not invent Epic/Legendary
hero ownership gates. Tower and gathering remain existing profile prerequisites;
the new trial proves the subject actor rather than rewriting those systems.

Hall11 supports the normal level70 cap and is already required by player mastery.
Keep that story gate and existing hero/world access/health/party/activity checks.
Do not use the player's level or player story receipt as the hero's own proof.
Do not create a new direct Hall gate in shared advancement without a reason from
the existing route; earned legacy levels remain valid.

## Current producer and consumer boundaries

| Boundary | Current source and behavior | Required additive change |
|---|---|---|
| Advancement | `src/shared/Data/Expansion.luau:advanceProblem`; `src/server/Services/ExpansionService.luau:AdvanceClass` | Require exact proof for new Novice Class3 only when the new policy is explicitly injected |
| Player lesson | `src/server/Config/ChapterFive.luau:MAIN_05_01`; `src/server/Services/CrosshavenWorld.luau`; `BorrowedPathFactory.luau` | Reuse Sela / `rift_refuge` / `mastery_trial`; select a legitimate existing path before combat |
| Player receipt | `src/server/Systems/BorrowedPathSession.luau` emits only `CampaignObjective{objective="complete_borrowed_mastery"}` | New proof receipt must retain actor/path/trial identity; old receipt is not path evidence |
| Story save | `src/server/Services/NoviceReceiptAdapter.luau` strictly allows objective/choice; `PlayerDataService.CommitCampaign` delegates `CampaignService.receipt` | Preserve this old interface; add a distinct private transaction for combined objective/proof |
| Hero lesson | `src/server/Systems/HeroMentorTrial.luau`; `src/server/Services/HeroMentorWorld.luau` | Reuse actual hero combat/selected ability for Class3, preserving existing Class2 API |
| Hero receipt | `HeroMentorReceiptAdapter.luau` captures start epoch/token and freezes uncertain commands; `PlayerDataService.CommitHeroMentor` | Retain these semantics for the new private receipt, including fresh eligibility and exact snapshots |
| Saved schema | `src/server/Systems/ExpansionSchema.luau` permits `mentorProof` v1 only on heroes with Tier2 path IDs | Separate optional Class3 field; leave old proof shape and old earned-build validation intact |

The story trial currently requires player70/Hall11, campaign claimed24,
`meet_crosshaven_mentor`, incomplete mastery, and no active quest/Tower. Its path
selection is the current normal child, current Tier3, or base-class default.
It does not currently offer pre-promotion special-path selection. Historical
objective completion records neither selected path nor owned hero identity.

## Phase A: additive schema and pure domain interface

Proposed exact optional field, nested under the existing owned build:

```luau
data.expansion.actors[actorId].class3Proof = {
    version = 1,
    actorId = actorId, -- "player" or an actual owned hero instance key
    pathId = pathId,   -- one of the existing Tier3 IDs above
    trialId = trialId,
    sourceKind = "crosshaven_mastery", -- or "actor_mastery"
}
```

Reject unknown keys/versions, wrong containing actor key, unknown/non-Tier3 path,
wrong base class, invalid trial ID or source kind. Use existing bounded ID
validation: trial ID 1..48 characters matching `^[%w_:%-]+$`; generated private
request IDs remain within the existing 64-character limit. Owner identity is the
authoritative profile userId. Never use hero template IDs. Do not persist session
tokens in proof: proof must survive a legitimate rejoin.

`crosshaven_mastery` is player-only and accompanies the first story objective;
`actor_mastery` is player repeat or hero qualification and carries no story
objective. Reject actor/source/objective combinations outside those modes.

Keep one proof per actor, not an unbounded receipt log. An eligible fresh trial
can replace a different-path proof; stale replay must never replace newer proof.
Preserve `mentorProof` v1 without converting it. Missing Class3 proof is valid in
the schema, including already-earned Novice or legacy Tier3. Never backfill an
exact path from generic campaign completion. No saved class/level is removed.

Proposed `src/server/Systems/Class3Proof.luau` is a pure module using existing
Expansion/Util and campaign-domain dependencies, not a persistence service:

| Interface | Contract |
|---|---|
| `problem(data, actorId, pathId)` | Read-only qualification eligibility: actual owned actor and existing path/level/special rules; do not require proof to start earning proof |
| `hasProof(data, actorId, pathId)` | Exact stored version/actor/path match; current promotion rules remain independently necessary |
| `capture(data, actorId, pathId, trialId, sourceKind, storyObjective?)` | Copy actor/build and immutable intended identity before server combat; capture no client success claims |
| `receipt(wonRun)` | Only a trusted won trial produces the private receipt below |
| `apply(record, command)` | Return candidate/result/events through existing transaction conventions; verify identity/snapshots and optionally delegate existing campaign objective validation atomically |

Keep `Expansion.advanceProblem`'s existing prerequisites unchanged. The optional
server proof policy augments the mutation consumer and read-only readiness view.
Without policy injection, current compatibility behavior remains. With it, NEW
Novice Class3 promotion needs `hasProof`; legacy ruleset and existing Tier3 builds
remain usable. Never activate enforcement before producers, retry access and UI
are integrated. Promotion remains explicit `AdvanceClass`, not a trial reward.

## Phase B: trial identity, anchors and repeatability

Use Sela's existing Crosshaven station for player qualification. Default to the
eligible normal child of the current path; offer eligible existing special paths
explicitly. Use the existing Guild hero training activity for owned heroes.
Reuse real ability, damage, target, movement and lifecycle rules; cosmetic events
cannot win a trial. No new combat/reward service or scene ownership convention.

At start, capture userId, exact Data session object/epoch/token, character identity,
actorId, intended pathId, unique trialId, sourceKind, copied actor/build and the
server-selected optional story objective. Actor/build comparison is a delivery
freshness check. Ordinary XP growth after proof was saved does not erase proof.
Recheck existing level/class/tier/parent/special conditions at start, proof delivery
and promotion; owner level cannot substitute for hero level.

Private receipt/command proposal:

```luau
{
    owner = userId,
    requestId = "class3:" .. trialId,
    action = "Class3Proof",
    args = {
        actorId = actorId, pathId = pathId, trialId = trialId,
        sourceKind = sourceKind,
        expectedActor = actorSnapshot, expectedBuild = buildSnapshot,
        storyObjective = "complete_borrowed_mastery", -- absent on repeat/hero
    },
}
```

The world/adapter retains start-session fencing outside the durable proof. Public
Protocol must reject `Class3Proof`. Proposed bounded public intents are
`StartClass3Trial{actorId,pathId}` and `CancelClass3Trial{}`; Controller routes them
to the existing player/hero activity. Keep `StartHeroMentor` Class2 behavior.
Server derives owner, sourceKind, result and objective; clients cannot send them.

First eligible player story win commits proof and objective in one candidate/
transaction by delegating existing campaign validation. If either validation or
save fails, neither is partially applied. Do not widen old NoviceReceiptAdapter
argument acceptance or split this into two saves.

Campaign compatibility is essential: every actor eligible under the existing
story trial rules must still be able to complete that objective. This includes
Tier1 players, already-Tier3 players and Tier2 players lacking promotion
prerequisites (for example Tower highest below5). These cases use the existing
story-only receipt; do not impose proof eligibility on the story objective.
Only an eligible Tier2 actor/path uses the combined proof transaction. Choose
this receipt mode at trial start, not after a stale save result or client response.

Repeat qualification after story completion emits proof only, without reopening
MAIN_05_01 or granting XP, Gold, Hall permits or points. A returning Tier2 player
with historical generic mastery can repeat qualification at the same station.
An earned Tier3 player needs no retroactive proof. Hero qualification never
consumes or advances the player's Crosshaven objective. Preserve existing access
checks, but make repeat access independent of the active objective marker.

## Phase C: controller transaction, readiness and integration

Add a private `PlayerDataService.CommitClass3Proof` entry point that validates the
new command then uses existing `execute`/save/audit machinery and the pure domain
application. No public receipt endpoint, second store, production cutover or
release-cap changes. Full-campaign preview integration and native testing remain
Controller-owned.

Exact replay identity is owner + captured session epoch + requestId plus immutable
command payload, including actor/path/trial/source and snapshots. Follow existing
recent-result `AlreadyCommitted` / `RequestConflict` semantics. The adapter must
freeze command/revision once a result is uncertain; retry/refresh that operation,
never rebase it into a second write. Fence changed session/character before new
delivery. Do not replay an old session's pending win into a replacement session.

If a saved matching proof is found after refresh/rejoin, it remains valid for
advancement. Exact receipt acknowledgement and payload conflict checking are
available only while the matching current-epoch operation remains in
`recentResults`; use that result before reevaluating fresh objective/snapshot
eligibility. The small saved proof does not preserve the full command, snapshots,
revision or epoch and cannot establish exact receipt equivalence.

For an adapter that already attempted an uncertain operation, retirement of its
operation record is a terminal `ReceiptHistoryUnavailable` refusal, not permission
to rebase, reapply or manufacture an exact acknowledgement from proof fields.
Old-session delivery is likewise rejected. A stored proof can independently make
the advancement UI ready; that is not proof of a particular receipt response.
Operationally, after a successful refresh in the same session: if an uncertain
fixed command has no retained result and its revision is no longer current, refuse
without guessing whether it committed or another command advanced the revision.
If its revision is still current, retrying that same immutable command remains
allowed through the existing transaction machinery. Missing history alone is
not evidence of either success or failure.
Reject a fresh receipt reusing the saved trialId without a retained exact result
without writing (mismatched semantic fields conflict; matching fields are already
proven, not a new completion). A genuinely new trialId may replace a different
proof only with its captured current actor/build and current eligibility intact.
An older receipt must never overwrite newer evidence. Never infer missing proof
from an objective alone. A combined receipt with inconsistent objective/proof
state is an integrity failure, not permission to guess or repair missing state.

No proof operation changes levels, currency, inventory, allocations or class.
Existing campaign claim owns its normal rewards; existing AdvanceClass owns the
one-time allocation reset. Repeated claims/promotions retain existing protections.
ViewProjection and native UI must show the same opted-in readiness, selected path,
trial state, saving/retry/refusal and TH/EN copy as authoritative checks.

## Proposed reconciled ownership and dependency order

These are proposed implementation scopes, not claims made by this document.
Controller must reconcile overlap with `progression`, `launch-content`,
`story-quests`, integration and active GUI tasks before assignment.

| Phase / exclusive owner | Proposed files | Dependency / boundary |
|---|---|---|
| A: progression/domain worker | `src/shared/Data/Expansion.luau`; `src/server/Services/ExpansionService.luau`; `src/server/Systems/ExpansionSchema.luau`; proposed `src/server/Systems/Class3Proof.luau`; `tests/expansion.luau`; `tests/latest_progression_gates.luau`; proposed `tests/class3_proof.luau`; `production/progression` | Optional schema, pure candidate semantics and readiness contract first; no runtime activation |
| B: trial worker | `src/server/Systems/BorrowedPathSession.luau`; `HeroMentorTrial.luau`; `src/server/Services/BorrowedPathFactory.luau`; `CrosshavenWorld.luau`; `HeroMentorWorld.luau`; `HeroMentorReceiptAdapter.luau`; `tests/borrowed_mastery.luau`; `tests/hero_mentor.luau`; proposed `tests/class3_trial_receipts.luau` | After A interfaces settle; preserve old APIs and existing trial ownership; do not edit A tests/files |
| C: controller integration | `src/server/Services/PlayerDataService.luau`; `CampaignService.luau`; `src/server/ServerBootstrap.server.luau`; `src/shared/Network/Protocol.luau`; `tests/run.luau`; focused transaction integration tests | Private commit, atomic campaign delegate and optional policy injection after A/B; no default Runtime or ReleaseContent changes |
| D: separately assigned S14 presentation | `src/server/Systems/ViewProjection.luau`; `src/client/UI/ExpansionView.luau`; relevant existing path selector; `src/shared/Config/Localization.luau`; focused UI tests | Contract first; serialize with current GUI/Localization work; no authority from UI |
| Verification: controller / independent reviewer | Existing isolated full-campaign candidate and evidence tools | Review source, local tests, then real earned routes; Studio ownership remains exclusive |

File shorthand within a row retains the immediately preceding directory. If a
new adapter/test file is necessary, Controller must explicitly add its exact path
to the registry; this document does not authorize unlisted writes. B can expose
the new adapter behavior through its owned existing factory while keeping the
old signature compatible; it must not mutate old receipt acceptance accidentally.

## Required test matrix

All rows below are **NOT_RUN for the new contract**, not counts of passing tests.
Existing suites are reuse targets, not acceptance of unimplemented proof.

| ID | Scenario / required invariant | Existing suite / proposed owner |
|---|---|---|
| C3-01 | Enumerate all fourteen canonical paths for player and owned hero; own69 rejected,70 eligible when existing prerequisites hold | `tests/expansion.luau`, `latest_progression_gates.luau`; A |
| C3-02 | Wrong class, tier, normal parent, quarry clear or Tower highest rejected; specials retain quarters and shadow gathering; no invented rarity gate | `expansion.luau`, `class3_proof.luau`; A |
| C3-03 | Player70 cannot qualify hero69; two owned heroes sharing a template cannot share proof; foreign/removed actor rejected | `class3_proof.luau`; A |
| C3-04 | Missing/wrong actor/path/version proof, Tier2 mentor proof and generic campaign completion cannot authorize new opted-in promotion | `class3_proof.luau`; A |
| C3-05 | Actual selected ability and server win required for all supported paths; no proof from client payload, animation or a mere successful call | `borrowed_mastery.luau`, `hero_mentor.luau`, trial tests; B |
| C3-06 | Cancel, death, timeout, character/session replacement and changed actor/build cannot deliver fresh proof; cleanup/return remains safe | trial/adapter tests; B |
| C3-07 | Combined first story win writes objective+eligible proof atomically; failure on either domain validation/save leaves no half-state | transaction tests; C |
| C3-08 | All existing story-eligible actors retain objective-only completion when proof-ineligible: Tier1, earned Tier3 and Tier2 missing Tower5; no new promotion/story gate or retroactive proof | `borrowed_mastery.luau`, transaction tests; B/C |
| C3-09 | Closed-story repeat and hero qualification yield proof only; no repeated XP/Gold/items/Hall permits or story replay | trial/transaction tests; B/C |
| C3-10 | Exact retry/conflict while operation retained; SavePending, stale revision, degraded refresh and unknown result freeze identity; retired uncertain operation refuses without reapply or guessed acknowledgement | adapter/transaction tests; B/C |
| C3-11 | Rejoin loads durable proof; stale old-session delivery rejected; newer different proof cannot be overwritten by old replay | schema/adapter/transaction tests; A/B/C |
| C3-12 | Legacy and Novice earned Tier3 load and remain usable without proof; legacy Class2@30 and mentorProof v1 unchanged; no inferred backfill | `hero_mentor.luau`, `latest_progression_gates.luau`, schema fixtures; A/B |
| C3-13 | Policy absent preserves existing proof-free compatibility; opted-in new Novice promotion requires proof; Class2 behavior unchanged | `hero_mentor.luau`, `class3_proof.luau`; A/B |
| C3-14 | Advancement happens only on explicit successful command; reset/refund once, no duplicated SP/AP, currency or class change on receipt replay | `latest_progression_gates.luau`, `status_points.luau`; A/C |
| C3-15 | Public proof action rejected; start/cancel payloads bounded; launch candidate still rejects Class3; no release widening | `hero_mentor.luau`, `launch_content.luau`, protocol tests; C |
| C3-16 | Native TH/EN readiness/path selection/saving/error/retry matches authority, with distinct player and owned hero names | S14 focused UI tests then controller native route |
| C3-17 | Ordinary earned full-campaign player/hero qualification, advancement, repeat access and rejoin verified on identified candidate | Controller; synthetic fixtures do not satisfy this row |

Existing `tests/hero_mentor.luau` explicitly expects hero Class3 promotion without
new proof when the old optional integration is used. Retain that compatibility
test and add policy-enabled cases. `tests/borrowed_mastery.luau` covers fourteen
temporary abilities and objective-only receipts; it is not already a proof test.
Schema compatibility must be tested with feature policy absent as well as present.

## Delivery and remaining acceptance

This contract changes documentation only. Required next steps: reconcile exact
worker scopes, implement A/B/C/D in dependency order, independent source review,
focused behavior/replay/schema tests, baseline integration checks and identified
native earned-route verification. No implementation or test success is asserted
by writing this file. All existing raw failure/pass evidence remains unchanged.
