# Class3 Phase A consumer interface

Base: `957f434`. Task: `class3-proof-domain`, shared ledger v7.
This is an optional domain implementation. No runtime flag, Bootstrap injection,
Protocol endpoint, persistence entry point or trial producer is activated here.

## Constructors and durable state

`Class3Proof(rules, util, campaign?)` returns the pure API below. `campaign` is the
existing CampaignService instance. Missing campaign refuses combined receipts.
`ExpansionService(content, util, economy, rules, landPlacement?, themes?, mentor?, class3?)`
adds argument eight; all previous callers retain their behavior. ExpansionSchema's
five-argument constructor is unchanged and always validates an optional proof,
including with runtime policy absent.

`Expansion.validClass3Proof(data, actorId, proof)` validates the exact five-field
saved shape from CLASS3_EARNED_PROOF_CONTRACT: version, actorId, pathId, trialId,
sourceKind. It never rechecks level, current tier/path, snapshots, party or active
story objectives. Earned proof must survive promotion, XP growth and later story
claims that clear the objective map. Missing proof remains legal on old builds.

## Pure API and result semantics

| Function | Result and responsibility |
|---|---|
| `problem(data, actorId, pathId)` | `string?`; actual owned actor, valid matching-class Tier2 parent, target Tier3 and unchanged existing promotion prerequisites; no proof prerequisite |
| `hasProof(data, actorId, pathId)` | Boolean; structurally valid stored proof with exact actor/path identity, independent of current eligibility |
| `advanceProblem(data, actorId, pathId)` | Qualification error first, then `Class3ProofRequired` for Novice without exact proof; legacy skips proof |
| `capture(data, actorId, pathId, trialId, sourceKind, storyObjective?)` | `(run?, error?)`; Novice only, copies actor/build, derives owner from profile.userId; status starts Active |
| `receipt(run)` | Receipt only when trusted run.status is Won; copies snapshots; no combat authenticity inferred by this pure function |
| `apply(record, command)` | `(candidate?, {code}, events)`; copies original, validates identity/current eligibility/snapshots; no candidate or events on refusal |

Capture fields are `owner`, `actorId`, `pathId`, `trialId`, `sourceKind`, optional
`storyObjective`, `expectedActor`, `expectedBuild`, `status`. Phase B may keep its
own timer/session/world wrapper. Capture does not add an `id` alias or timer.

The receipt contains top-level `owner`, `requestId="class3:"..trialId`,
`action="Class3Proof"` and the contract args. **The private transaction adapter must
preserve or derive authoritative command.owner**; adapters copying only public
version/requestId/revision/action/args would fail this domain's validation.
Never take owner or a Won status from the client.

Combined mode is player + crosshaven_mastery + exact complete_borrowed_mastery
objective. actor_mastery accepts player/hero with no objective. Phase B must choose
the permitted mode at start: player actor_mastery means repeat access after the
story lesson, not an alternate early entrance. Its activity gateway must enforce
health, jobs, party, world/anchor, active activity, story and session/character
conditions before capture and before delivery. Those are intentionally not
durable-proof or general promotion prerequisites. Preserve the existing
story-only route for Tier1, earned Tier3 and proof-ineligible Tier2 players.

Combined apply delegates CampaignService.receipt and attaches proof to that
returned candidate. It never claims the chapter or grants rewards. Objective
validation failure, including AlreadyObserved without matching retained operation
history, does not repair or infer proof. Proof-only changes only class3Proof.

The existing executor must resolve exact retained operation replay before apply.
Matching stored trial identity returns Class3AlreadyProven **without a candidate**,
not AlreadyCommitted. Conflicting stored same-trial semantics returns
RequestConflict. A different trial requires current snapshots, including the old
proof in expectedBuild. A stale earlier receipt cannot overwrite newer proof.
Only the controller transaction/adapter can handle revision/session history and
ReceiptHistoryUnavailable; this module has no store or operation-history access.

Domain-specific codes: Class3ProofRequired, Class3TrialUnavailable,
Class3ActorChanged, Class3AlreadyProven, Class3CampaignUnavailable. Other refusals
reuse InvalidReceipt, ActorNotReady, InvalidClassPath, AdvancementLocked,
QuartersRequired, SecretUndiscovered, RequestConflict and campaign validation codes.
S14 should add TH/EN presentation when its separately assigned phase begins.

## Validation and remaining work

`tests/run_class3_proof.luau` runs the new domain suite plus existing latest
progression, Class2 mentor and borrowed mastery compatibility suites. The new
suite covers fourteen paths for both actor kinds, own-level prerequisites,
same-class hero isolation, schema corruption, copying, candidate atomicity,
proof replacement, opt-in/absent policy, legacy behavior and one-time reset.
These are synthetic local checks, not earned gameplay or persistence evidence.
Full baseline and recorded command outcomes are delivered separately with the
commit. Phase B/C must test real combat admission, session loss, save uncertainty,
rejoin and replay-history retirement. Native/device/human acceptance remains pending.
