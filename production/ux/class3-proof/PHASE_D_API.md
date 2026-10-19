# Class3 native presentation handoff

Phase D, base `ebc5d2a`. Optional implementation only. Bootstrap, network routing,
transaction integration and policy activation remain Phase C. No Studio session,
runtime flags, publishing or production persistence changes occur in this phase.

## Projection

`ViewProjection` retains its eleven existing constructor arguments and appends
optional argument twelve: `{Proof=class3Domain, Trial=heroMentorTrial?,
PlayerProblem=function(data,pathId): string?}`. `Trial`, when supplied, must have
the Phase B `class3Problem` interface. The server injects these dependencies.
The existing Class3 domain is the sole saved-proof/advancement authority.

Every projection strips `build.class3Proof` and `build.mentorProof`, including
when the new policy is absent. Source data is unchanged. No owner, trial ID,
receipt, snapshot, lease or retained operation is added to the public interface.

For Novice profiles with policy present, `data.class3Proofs[actorId][pathId]`
contains only `{proven:boolean, trialProblem:string?, advanceProblem:string?}`.
Actors are actual owned instance keys or `player`. Only valid Tier2 builds and
matching Tier3 class/parent candidates are listed, including existing specials.
Legacy profiles, old earned Tier3 builds and missing policy retain old behavior.
Qualification does not guarantee world admission: proximity, current character,
session ownership, other activities and story access are checked again at start.

Trial refusal precedence: release policy, domain eligibility, optional player
route/hero activity checker. Advancement precedence: release policy, domain
advanceProblem. Activity qualification is not silently a new permanent promotion
gate. Malformed optional checker results refuse instead of projecting a table.

## Native UI contract

Existing Skills actor selection is reused. A path must be explicitly selected;
actor/class/tier/parent changes or removed candidates clear selection and pending
confirmation. `StartClass3Trial` sends only `{actorId,pathId}`. Saved proof is
separate from the existing two-click `AdvanceClass`; the UI never promotes from
a trial outcome or reconstructs proof from a campaign objective.

Phase C must publish a separate, bounded `data.class3Session` through
NetworkService: `{actorId,pathId,status,problem?}`. It must not copy the internal
run. Current Phase B HeroMentorState lacks a kind discriminator; C must distinguish
Class2 from Class3 and avoid presenting the same run as both session kinds.

| State | Presentation and available actions |
| --- | --- |
| No projection | Existing UI; no Class3 training controls |
| Candidate, no path selected | Explicit path choice; no Start action yet |
| Selected, qualification refusal | Localized reason; Start disabled |
| Selected and qualified, no saved proof | Start intent; server revalidates admission |
| Exact actor/path proof saved | Proof saved label; no duplicate training for that path; promotion remains separate and gated |
| Request pending | Existing transport busy disables controls; no optimistic proof |
| Active session | Actual run actor/path remains visible while inspecting other actors; Cancel allowed if transport idle |
| Saving session | No Cancel/Start/promotion or build mutation; pending delivery guidance; never infers new success |
| Stopped/failed/refused session | Reason shown; no success; C must clear ended session to permit fresh training |

Any Class3 session blocks mutation controls owned by ExpansionView, including
Skills, StatusPointView, Base, Furniture and crafting; it cannot block unrelated
panels. Phase C must enforce the cross-manager/server mutation exclusion. Actor
inspection stays available when transport is idle. No progress counters are
invented: current producers supply phase/identity, not live measured lesson data.

Player instructions require a real selected-art damage/heal effect, or an actual
incoming guarded hit for Guard, two dodges and victory. Hero instructions require
that owned hero's selected-art effect, three retaliations and victory. Hero
training does not display player dodge requirements. The player ClassTrialLocked
context maps to player level70/Hall11; the old Class2 message remains unchanged.

## Phase C normalization and recovery obligations

New EN/TH codes include Class3 domain failures, `ReturnToCrosshaven`,
`Class3SavePending`, `Class3ReceiptHistoryUnavailable`, `Class3ActorNotReady`,
`Class3LevelLocked`, `Class3LessonsIncomplete` and `Class3TrialUnavailable`.
The native card context maps reused ClassTrialLocked, HeroMentorUnavailable,
HeroMentorRequired, VisitStation, ActorNotReady, TrialLessonsIncomplete,
SavePending and ReceiptHistoryUnavailable to Class3 copy. This does not change
global Class2 copy or SliceController's legacy English overrides.

C must normalize asynchronous Class3 notifications to these Class3-specific
codes. It must preserve the adapter's bounded second-return refusal code:
HeroMentorWorld currently collapses Rejected to HeroChanged, so exact history
retirement cannot be rendered correctly until C reconciles that producer scope.
World integration also needs truthful committed/failed/cancelled notification
context; no UI-only code can recover a discarded server reason.

Pending world delivery already retries the retained receipt server-side. The
existing top-level Retry save / recovery control is for degraded-profile recovery;
it does not create or resubmit a new trial receipt. Terminal history retirement
must not be described as retryable or repaired by inspecting a saved proof.
No additional Retry intent or save implementation is introduced in D.

## Verification boundaries

`tests/run_class3_ui.luau` runs projection and domain tests. The bounded UI-double
runner is `python production/ux/class3-proof/run_gui_checks.py`; it reads the actual
ExpansionView, StatusPointView and SkillAvailability source. UI primitives and
unrelated decorative components are doubled; the existing test runtime is reused.
The generated ignored runner contains the exact source read during that invocation.
These checks exercise callbacks, selection, blocking and localized strings; they
do not prove native rendering, text fit, focus navigation, touch or frame rate.

Recorded full baseline/focused results and independent review accompany the
delivery commit. Native keyboard/gamepad, desktop/portrait/landscape EN/TH layout,
real earned trials, rejoin and persistence recovery remain Phase C/native gates.
Physical-device and human acceptance remain external. The full Lv100/all-city
goal remains unchanged.
