# Novice local Studio identity compatibility

Actual two-client Studio observation: both negative-ID Players completed chapter one through normal objectives/claim (revision5, Lv3). Practice prompt triggered but the lesson did not open. Source identified positive-only owner validation in both lesson and first-class trial constructors. This is a compatibility failure, not evidence of a successful chapter-two trial.

## Change

Pure `StudioTrialIdentity(context, ownerId, isCurrentOriginalPlayer)` produces an exact-owner predicate. Negative finite nonzero integer IDs require every explicit fence: `IsStudio==true`, `PlaceId==0`, `GameId==0`, `PersistenceMode=="Memory"`. The current-original-Player callback must return true without errors or yielding. Zero, fractional, nonfinite, malformed and different-owner IDs fail. Positive defaults in Trial/Lesson constructors remain unchanged when no policy is injected.

Root Bootstrap supplies `TrialIdentityContext` to Course from actual trusted server environment. Course binds each predicate to the actual Player object using Players:GetPlayerByUserId and Parent identity. No client flag or public action changes. Borrowed LessonFactory receives the predicate; manager obtains per-player TrialsFor, and the arena receives the predicate as optional ninth argument for its default first-class simulator. Existing option-based later-game arenas retain their own factories.

Audit: TrialInput already validates exact sender, bounded action shape and rate, without positive-only ID validation. NoviceReceiptAdapter and PDS.CommitNovice use the exact owner/session key and immutable receipt transaction; no additional positive-ID restriction found. Their code is unchanged. Solo distance, server-observed movement, cooldowns, eligibility, objective order and receipt gates remain active. No profile, XP, HP, timer or proof was edited to advance the route.

## Evidence and pending acceptance

Four focused pure tests cover default compatibility, every environment fence/current-object callback failure, real negative-ID practice combat and exact receipt owner, plus first-class trial evidence/solo gates. Logs: `build/novice-identity-tests.log`, `build/novice-identity-analysis.log`, `build/novice-identity-compile.log`.

Actual restarted two-client earned journey is pending root Studio validation; source tests do not establish that acceptance. No publishing, cloud writes or runtime flag mutation in this scoped task.

Independent policy review reran all four focused tests and found no source blocker. Scoped Luau LSP and compile passed; actual Studio journey remains pending.

## Courier presentation wiring — 2026-10-18 source candidate

The existing courier now selects `WorkMotionIdentity=marshal_elian` for the existing
letter gesture. Its Name, DesignId, OwnerUserId, unset NpcId, native kit, root and
invisible interaction proxy are unchanged. No helper, environment or UI edits.
The courier callback retains exact owner, live character, 12-stud proxy distance
and current courier-objective checks, and now also rejects non-Active/pending
sessions before any presentation hint. After the unchanged observe function queues
a receipt callback, one server timestamp supplies GreetingAt and NpcInteractUntil
(plus existing InteractSeconds), with NpcInteractor set to the owner. This signals
a queued observation, not committed progress or granted rewards. Existing animator
owns idle/work, wave, bounded head attention, fade/recover and cleanup.

The existing four pure identity tests exercise identity/trial compatibility, **not**
this Roblox prompt callback. No copied guard test or unowned probe was added.
Focused compile/type checks and independent source review cover the patch locally;
actual callback and visual acceptance remain NOT_RUN by this worker. No full baseline
run, Studio/Blender action, push, publication or asset import in this slice.

Controller-run isolated probe instructions (Memory, unpublished PlaceId/GameId 0):

1. Build the actual NoviceCourseWorld with controlled in-memory sessions and a
   MakeReceipt spy that returns a pending callback without committing progress.
   Use its real CourierInteraction prompt and actual input; do not copy its handler.
   Record actor Name/DesignId/OwnerUserId/NpcId, root and feet transforms, proxy
   size/CFrame and envelope attachment before testing. Confirm the motion alias.
2. At each valid objective meet_courier and help_courier, with Active/no pending,
   owner/live root inside 12 studs, trigger E once. Require one queued NoviceObjective
   receipt with unchanged owner/action/args; GreetingAt must be a new server time,
   NpcInteractUntil-GreetingAt exactly InteractSeconds, NpcInteractor exact owner.
3. Repeat while pending: no new receipt or timestamp. In fresh controlled fixtures,
   separately test non-Active, another player, missing/dead character, wrong next
   objective and owner beyond 12 studs. Each must leave all three hints and receipt
   count unchanged. For the distance case, widen only the disposable prompt reach
   and verify an actual Triggered event reached the real callback; absent input is
   not a passing rejection. Do not mutate an earned profile to create these cases.
4. Observe the actual client: letter motion before input, work fade/head attention
   after accepted input, expiry and recovery after 12 seconds, reduced-motion and
   destroy cleanup. Preserve root/feet/proxy/identity. Confirm envelope grip and
   readability visually; reusing a pose does not establish fit. Actor-distance gaze
   remains <=14 and front-hemisphere limited, independent of proxy acceptance.
5. Disconnect observers, remove all test courses and restore test player/camera
   state on both success and assertion failure. Record actual results separately
   from this source proposal; no quest completion or multiplayer claim by inference.
