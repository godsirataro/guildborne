# Class3 Phase B trial handoff

Base `31713a4`; task `class3-proof-trials`, shared ledger v7.
Optional producers only: no Bootstrap, Protocol, persistence, release flags or
client UI activation. Phase C must wire and verify before enabling enforcement.

## Player path

`BorrowedPathSession(expansion, util, makeTrial, pathId, mastery?, proof?, currentData?)`
preserves the old five-argument API. With proof injected, mastery selects its
receipt mode at start. Eligible Tier2 player + current story objective produces
combined proof/objective. Tier1, earned Tier3 and Tier2 without prerequisites
retain the existing story-only receipt. After mastery is already observed or the
campaign has advanced beyond chapter index24, eligible Tier2 repeat produces
actor_mastery proof only. No reward or chapter-claim call occurs here.
Legacy rulesets always retain story-only admission and completion, including
otherwise-qualified Tier2 builds. Injecting the proof dependency does not opt
legacy profiles into proof capture or new repeat qualification.

The selected path must belong to the player's class. Class3 capture binds
profile.userId, actor/path/trial and copied actor/build before combat. IDs for
proof use the domain's48-character limit. currentData is a synchronous world
callback returning current profile data or nil; proof runs check exact actor/build,
activity, Hall and selected story mode before observations and receipt creation.
The private observed-win latch prevents changing run.status alone into a receipt.
Existing Combat/NoviceTrialSession lessons still own measured skill use, two dodges
and victory. Each selected Class3 ability is installed in the copied combat config.
Proof runs additionally require an actual selected-ability damage/healing effect,
or a guarded incoming damage hit. `combatFactory(makeCombat, deps)` decorates the
existing CombatDamage/CombatAbilities callbacks per run; it does not change damage
rules or rewards. BorrowedPathFactory and proof simulation tests use this factory.
A successful Guard cast followed only by dodges and basic attacks fails proof
qualification; old story-only criteria remain unchanged.

`BorrowedPathFactory(pathId, mastery?, proof?, currentData?)` forwards these options.
Existing Class2/borrowed callers need no change.

`CrosshavenWorld(deps)` adds optional deps.Class3Proof + deps.MakeClass3Receipt
(both required together). It reuses the Sela mastery station, retains existing
story marker and offers repeat training at that station. An eligible Tier2 player
can still access the court after chapter30. Normal child is the default; explicit
existing special paths can be selected through Intent after D/C integration.

- `Intent(player, "StartClass3Trial", {actorId="player",pathId=...})` requires
  current session, live character and proximity<=9 to the authored mastery station.
- `Intent(player, "CancelClass3Trial", {})` cancels before pending delivery;
  pending delivery returns SavePending.
- `State(player)` returns actorId/pathId/status (Saving while pending), or nil.
- `Active(player)` covers a live trial or pending delivery.

Start captures exact session object/epoch/token, character and private trial token.
Character/death/activity/arena/entry checks fence callbacks. Cleanup invalidates
the token. Post-yield delivery rechecks entry, pending closure and start fence
before touching scene/state. Repeat success cleans up even without objective
change. A pending proof is not discarded merely because refresh reveals the
committed objective before its exact receipt acknowledgement.

## Hero path

`HeroMentorTrial(rules, util, class3?)` preserves start/problem for Class2 and adds:

- `class3ActivityProblem(data, actorId)` checks actual owned, healthy, undispatched
  party hero and absence of active expedition/Tower activity.
- `class3Problem(data, actorId, pathId)` adds Novice/domain Class3 eligibility.
- `startClass3(data, owner, actorId, pathId, trialId, now)` derives/validates owner
  against profile.userId and captures immutable domain proof in run.proof.

Existing matches/receipt handle run.proof. The same real hero combat simulation
must produce actual ability effect, retaliation observations and victory; its
private win latch prevents status-only proof. HeroMentorWorld accepts optional
StartClass3Trial/CancelClass3Trial via existing Intent with deps.Class3Proof and
deps.MakeClass3Receipt. Construct deps.Trial with the optional domain dependency.
It preserves existing Class2 MakeReceipt/StartHeroMentor behavior.

## Delivery adapter and controller requirements

`Class3ProofReceiptAdapter(data, userId, receipt, util, startFence, guard)` returns
`deliver(): (outcome, code)`, where outcome is Retry, Rejected or Committed.
World dependency wrapper is
`MakeClass3Receipt(userId, receipt, startFence, guard)`.
Capture `startFence={session=session,epoch=session.epoch,token=session.token}` at
trial start. guard must be non-yielding and check physical/activity/trial identity,
not actor/build/story freshness that a successful save changes. Those freshness
checks belong to domain apply after executor replay lookup.

Adapter derives authoritative command.owner and copies caller payload before any
provider call. The private Data.CommitClass3Proof must accept that owner field and
use existing exact recentResults semantics. Operation ID is epoch:requestId.
Retained command revision may reconstruct a retry, but our payload remains intact
so the executor can return RequestConflict. The adapter never decides success
from saved proof fields.

SavePending or thrown commit freezes command including revision. Retry requires
successful refresh; absent retained operation plus advanced revision refuses
terminally as ReceiptHistoryUnavailable. Same revision may retry the identical
command. Refresh failure is not evidence of retirement. Preflight Busy,
AuditBacklog, LeaseExpiring and StaleRevision can retry/rebuild only before any
uncertain commit. Lost/closing/closed/replaced sessions and failed/yielding context
guards reject; guard/fence is checked again after yielding providers. Reentrant
delivery returns Retry/Busy. Exact terminal outcomes do not invoke providers again.

Phase C still owns CommitClass3Proof, public bounded start/cancel routing, exclusion
against other trial managers, authoritative readiness injection and persistence
integration tests. Phase D owns native selection/status/error/localization. New
world admission code ReturnToCrosshaven needs TH/EN copy there. No new reward or
scene service is introduced. No arbitrary public receipt is accepted here.

## Evidence limits

`tests/run_class3_trial_receipts.luau` exercises actual pure combat simulation,
story-only compatibility, repeat mode, forged status, death/expiry/cancel/identity
changes and adversarial adapter callbacks including yielding providers. Adapter
Data responses are simulated; they do not establish real persistence or network
recovery. World adapters are source-reviewed/typechecked; no native Studio
interaction is claimed. C must verify world cleanup, real route access, session
replacement during saves, ordinary earned progression, rejoin and UI integration.
Recorded command receipts and independent review are delivered with the commit.
