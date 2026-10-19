# Class3 private transaction and native routing integration

Base `ccd40f063b3111d38fde5a18ac70b732b4d102ce`, shared Forge ledger v8.
The controller's separate manifest-only fix `f792479` is applied here as dependency
`de04bf7`; it normalizes the manifest hash to canonical plan bytes without changing
the plan. It is not part of the gameplay implementation commit.

## Optional candidate and interfaces

Default Runtime and ReleaseContent are unchanged. The candidate requires explicit
`Class3ProofCandidate=true`, the existing full Crosshaven route, Studio, zero place
and universe IDs, Memory persistence, and launch preview disabled. The missing
candidate flag is false. Native activation remains controller-owned, isolated and
separate from this local source delivery.

Bootstrap supplies the same Class3Proof domain to ExpansionService argument8,
PlayerDataService.Class3Proof, ViewProjection argument12 and both world producers.
The domain delegates the existing CampaignService receipt for combined proof and
story objective. CampaignService itself needs no new code. HeroTrials can exist in
the candidate independently of the old launch-only HeroMentor policy; existing
Class2 proof enforcement, public mentor controls and projection remain launch-only.

Public Protocol accepts only `StartClass3Trial{actorId,pathId}` and
`CancelClass3Trial{}`. Network routes them to World.Class3Intent, never the profile
command dispatcher. Proof receipts, owner identity, status and arbitrary extra
keys remain forbidden on the public wire. Existing protocol ID bounds remain64;
domain/trial IDs retain their narrower private constraints.

Private `Data.CommitClass3Proof(userId,command)` validates the exact envelope,
version, owner, revision, request/trial identity and receipt shape, copies it and
uses the existing executor. Exact recentResults replay precedes domain apply.
Combined objective/proof is one candidate, revision, retained operation and audit
commit. There is no automatic chapter claim, class promotion, currency or XP grant.

## Uncertainty and session ownership

SavePending keeps the immutable pending candidate/command. Refresh completes that
same operation. Retained command conflict remains RequestConflict. If a successful
refresh finds advanced durable revision without the exact retained operation,
the Class3-only commit path adopts the authoritative record unchanged and returns
ReceiptHistoryUnavailable; it never rebases the old candidate or treats a saved
proof as acknowledgement. Refresh reports successful refresh to the adapter,
which returns that terminal refusal. Other command semantics are unchanged.

Class3 pending transactions retain a private in-memory exact session object,
epoch/token fence. It is checked inside the provider transform and after yields;
LeaseLost also refuses. A lost session before the durable write cannot apply the
candidate. A replacement or loss after an already-completed write suppresses stale
local adoption and callbacks; it cannot undo durable state. Closing intentionally
allows a valid pending save to finish, while the world adapter refuses stale
acknowledgement. Close/rejoin then reads the authoritative saved result.

## World, network and UI

HeroMentorWorld.State remains Class2-only. Both producers expose Class3State with
only actorId/pathId/status/problem; Crosshaven latches whether the actual admitted
mode can produce proof, preserving legacy and proof-ineligible story-only lessons.
Network reconstructs the bounded public class3Session after World.Update. Internal
run/snapshot/receipt/lease fields are never copied. Saved raw proof remains redacted
by Phase D; readiness is separate from live admission.

Starts recheck ownership, own actor level/path, healthy/activity conditions and the
existing physical locations. The optional AdmissionProblem callback runs for
authored mastery prompts as well as public intents. A player mastery run and a
hero run cannot overlap. Existing shared-combat/walking hooks also see active
mastery; pending shared settlement and combat prevent a new trial. No new permanent
hero Hall or rarity requirement is introduced.

During Class3 activity or pending delivery the server blocks unrelated profile,
spatial and build mutations. GetState and RetrySave remain available, and only the
matching Class3 cancellation reaches its producer. The producer refuses cancellation
during Saving even if the profile is Degraded. Social leave/decline remains on its
existing independent path. Class2 cancellation cannot cancel a Class3 run.

Both producers retain exact delivery refusal codes. Same live-session context loss
cleans up before notification; replacement sessions/characters do not receive old
callbacks. Lifecycle aliases map to Class3-specific EN/TH codes, avoiding the old
SliceController Class2 overrides. RequestConflict and receipt-history retirement
remain distinguishable. No SliceController changes are required.

## Reproducible local checks and limits

- `tools/validate.ps1`: existing full regression, Rojo build, Roblox type analysis,
  compile and repository checks; transaction tests are registered in tests/run.
- `.tools/luau/luau.exe tests/run_class3_transaction_integration.luau`: real
  PlayerDataService/domain/schema with deterministic fake providers, including
  atomicity, before/after-write uncertainty, exact replay, retirement, expiry,
  rejoin, own-hero isolation and same-session loss/closing during yielding saves.
- `python production/integration/class3-proof/network-source-tests.py --luau
  .tools/luau/luau.exe`: actual NetworkService and extracted Bootstrap gate/routing
  callbacks with real Protocol/Localization in a fake host.
- `python production/integration/class3-proof/world-check.py .tools/luau/luau.exe`:
  source-loaded world callback checks with deterministic host doubles.

Raw recorded output and independent review belong to the final committed source
identity, not this document's prose. Synthetic fixtures may construct qualified
profiles or trusted receipts to test transaction refusal; they are not earned play.
These checks do not prove Roblox scheduler/network behavior, world geometry,
physical device performance or actual DataStore recovery.

Controller still owns combined native earned acceptance: player selected art with
actual Guard hit when relevant, two dodges and victory; actual owned hero ability
effect/retaliations/victory; special paths, saved result/promotion/rejoin and recovery;
EN/TH desktop/portrait/landscape focus and interaction. No Studio, Blender, publish,
paid import, production writes, push or merge was performed for this delivery.
The full Lv100/all-city objective remains unchanged.
