# Combat cue lifecycle review

Scope: sharedv7 `combat-cue-lifecycle`, owner `s15-cues`, base `957f434f45c2b17e5c8a334342ff45bdc5147bec`. Local source implementation only; awaiting coordinator review and native acceptance.

## Behavior

CombatCueEvents admits finite, positive, nonfuture timestamps once per model/channel. Expired observations retain their highwater; missing target metadata can become ready only within the original action timeline (.62 seconds). Explicit attribute removal consumes pending work. Weak model keys retain history across same-instance reparenting without retaining removed models indefinitely.

CombatController dispatches action presentation only after root, target, camera and action metadata are ready. Distance-culling consumes the event. This establishes admissible dispatch, not guaranteed VFX emission when the existing effect budget rejects a request. Active warnings use exact identity, interval and Windup checks and dispose on cancellation, death, ownership loss, replacement, removal, expiry or controller destruction. Known regional release events use release audio rather than claiming a confirmed hit. Damage audio additionally requires a recent observed HP decrease; pending damage survives lethal HP arriving after its timestamp.

AudioController retains boolean Play/PlayFor results and adds PlayOwned returning an idempotent disposer or nil. It shares existing Ended, ancestry, deadline and Destroy cleanup. AssetIds remain empty: no audible asset was imported, approved or claimed.

## Independent source review

Agent `enemy_export_review` independently reviewed root-authored CombatController and worker-authored AudioController. It found same-model replay, missed nil cancellation between polls and lethal replication ordering; all three were fixed and rereviewed. Final verdict: PASS, no concrete remaining source blocker. Root independently reviewed the agent-authored selector and tests: finite clocks, monotonic channel state, original TTL, explicit nil cancellation and channel/model isolation are consistent; no blocker found. Root also reviewed the worker-authored native probe including the added lifecycle and lethal-order cases.

Exact working-file SHA256 at review (raw bytes, before Git LF normalization):

| File | SHA256 |
| --- | --- |
| src/client/Controllers/CombatController.luau | 162bf26107520c392fcc5a9c9b7292b0b0523e65ade1eb3cd1cc710f4dedf4ab |
| src/client/Controllers/AudioController.luau | 51333f0929e9b61d72c051f0e6405d33861870120d566cacbffc607da1338226 |
| src/shared/Presentation/CombatCueEvents.luau | c9522d042d26da68cba664e2dbc0f619ad49ba4bbcfa4789cd25b051ee002e49 |

## Validation and handoff

Six pure selector groups passed locally. Mapped Roblox type analysis of the runtime modules and compilation of the six runtime/test/probe files passed. Immutable committed-source check receipts are composed separately under ignored build/agentic/evidence; check their actual outcomes rather than treating this report as a run receipt. The independent-review command verifies hashes of the files that received the above semantic review; the command itself is not a semantic reviewer. Overall task stays REVIEW pending a different coordinator reviewer.

`combat_cue_probe.luau` contains 17 native client cases and is compile-only until executed by the exclusive Studio owner. Follow the installation/Memory guards in its header: exact isolated client tree and Shared, disabled normal bootstraps before Play, unsaved PlaceId/GameId zero, no existing world/client singleton. Stop Play after capture to dispose module-scope MenuRouter listeners.

The probe observes actual SkillEffects instances and delegates real AudioController calls, but its warning-stop recorder is synthetic because unbound audio returns nil. It does not establish audible playback, real Sound.Ended/budget cleanup, real server damage, earned progression, five-companion load, physical-device performance or human art acceptance. Regional impact VFX, priority audio mixing, final class cue identity and imported audio remain separate follow-up work. No server authority, balance, progression, SkillEffects, EnemyAnimator or HUD layout redesign is included.

Additional baseline: tests/run.luau passed 944 tests and Rojo build passed. Full src/tests analysis exposed an invalid-input test table inference issue, fixed with an explicit {any} annotation. Existing tests/gui fragments still report UnknownGlobal (Services/UI/NoviceConfig) and ImplicitReturn diagnostics; full baseline therefore is not PASS. Those fragments are outside this seven-file task. Focused recorded analysis now includes both new test files as well as runtime modules.

Coordinator source review additionally found raw ActionAt/FeedbackAt arithmetic in the retained HUD. Both display checks now use Cue.recent, rejecting malformed, nonfinite, future and expired values without arithmetic errors. Independent agent rereview of this final controller change: PASS. This is a timestamp guard, not a layout change; valid regional warning countdown is preserved.

## Native failure 01 and probe-only follow-up

Controller reported the first actual native run failed at the compound ready-target/cue/VFX assertion (probe line 96), then stopped Play. Candidate SHA256: `a981d8d61299c91d5e249750bb4732b755a004420268437611d0eec1438bfbf8`; generated source was controller commit `93e2c922b356a7b17a9066b069d60c5c733b161b`. The controller retains the original raw output at `production/integration/quality-slice/COMBAT_CUE_NATIVE_FAILURE_01.json`; this follow-up does not modify or replace it.

Read-only diagnosis found the captured log cannot distinguish missing admission, wrong audio key, missing VFX, expired original timestamp or camera distance culling. Archer Basic creates missiles synchronously on its accepted effect call; changing animation markers is unsupported. The probe's fixed `task.wait(.14)` did not bound actual elapsed time, and its captured default camera was not protected against startup replacement/reset. These are fixture weaknesses, not a proven explanation of failure 01.

The follow-up is restricted to the probe and this report, based on worker commit `2228fe18a82a01c01afea43e4bb1b874cdb9691d`, under sharedv7 task `enemy-quality-slice`, owner `cue-probe-fixture`. Runtime controllers, selector, VFX and audio bindings remain unchanged. The probe uses an owned isolated camera, startup stabilization, measured timing and pre-cleanup diagnostics. Camera/scheduler precondition failures are inconclusive, never native PASS; there is no silent retry, action timestamp renewal or increased TTL. The native rerun remains the exclusive controller/Studio owner's responsibility. Local compilation and source review alone cannot resolve the native failure.

Failure 01 raw output SHA256: `6b7221f6eae55373eba046b46dd5e38624e12cfa1fb8e46414c5f85cefd61fc0` (read from the controller checkout; retained there). Independent source review of the worker-authored probe was performed by root: original 17 behavioral assertions remain, first target-ready assertion is split into count/key/actual-VFX checks, original timestamp is preserved, measured waits and camera interference fail closed as inconclusive, and probe-owned listeners/camera restore during cleanup. Final local compile/diff receipts accompany the handoff; no native rerun occurred in this worker.

## Camera preservation correction

Independent controller review blocked `096c63f`: assigning Workspace.CurrentCamera can destroy other Camera instances directly under Workspace, invalidating a saved reference. The bounded correction uses the allowed alternative: reuse the original camera and save/restore only CameraType, CFrame and Focus. It never assigns CurrentCamera, reparents a camera or destroys one. Identity/type/CFrame/ancestry interference monitors remain strict. Each property restoration runs under its own protected call; an external identity/ancestry change or restoration error emits a cleanup-inconclusive diagnostic and prevents PASS, without swapping references to conceal interference. This supersedes the owned-camera/reference-restoration wording above. The original 17 cases, TTL, no-retry policy and failure01 remain unchanged.

Reference: https://create.roblox.com/docs/reference/engine/classes/Camera (official Roblox documentation). Native execution remains pending.

Independent agent enemy_export_review reviewed this correction: PASS scoped static review, 17 cases and original TTL checks retained, no native execution. Reviewed raw probe SHA256: `1bf23857b833019edb910106b10653c582f35ba39b93a3cdf0bdc57629e76354`.

## Native inconclusive 02 and event-time revision

Controller native run 02 on its integrated candidate reported INCONCLUSIVE, not a 17-case PASS. Original ActionAt was `1792372234.812784`; the recorded bow_release request occurred at `1792372235.092979` (age about `.280195`, inside `.62`). The second requested `.14` wait resumed after `.854905`, so the assertion reader saw age `1.021952`. Camera identity stayed the same and Scriptable, distance was approximately `17.464`, and the camera event log was empty. Two VFX were observed, but that recorder did not retain their individual timestamps; no historical VFX timestamps are inferred here.

Controller retains raw `production/integration/quality-slice/COMBAT_CUE_NATIVE_INCONCLUSIVE_02.json`, SHA256 `29346c636108e02ce09f90774d1c7d6b1ae099751875c1ea47b3177089256854`. Failure01 and inconclusive02 remain separate immutable observations. Run02 demonstrates that assertion wake time must not substitute for recorded event time. It does not establish all 17 cases or explain failure01 conclusively.

The approved follow-up is probe-only: a manual READY/start gate, recorded event identity and timestamps, and separate result collection and negative-window coverage. No runtime timing change, source timestamp renewal, automatic start fallback or silent retry is authorized. The controller owns the next native run. Earlier compile receipts and static reviews describe earlier source revisions, not native acceptance of this revision.

### Running the revised probe

1. Install the isolated candidate using the unchanged guards, start Play, and wait for `READY_CLIENT_CUE_PROBE` / `CombatCueProbe.ProbeStatus == "READY"`.
2. After at least one second of stable frames, the Studio owner explicitly sets the **client LocalScript** `CombatCueProbe` attribute `StartRequested` to `true`. Do not preset it before READY. The probe has a single 60-second arm deadline and requires the preceding one second of Heartbeat observations with no gap above .15 seconds. Missing start or coverage is INCONCLUSIVE, with no automatic fallback or retry.
3. Capture full stdout and the compact JSON `ProbeReport` attribute plus `ProbeStatus`. The full stdout contains event records, readiness changes, waits and Heartbeat observations. Stop Play after capture even on failure.

Positive records are correlated by case, actor instance/ID, cue and original source timestamp, and checked against the unchanged original event TTL. Result collection is bounded separately (two seconds); a late assertion reader may use a timely recorded event. Missing evidence with an observation gap remains inconclusive. The first VFX case starts with no preceding casts, checks zero VFX before readiness, and requires a recorded first-cast VFX timestamp after readiness and within the original .62-second window. Later VFX records are observational and are not proof of an independently identified actor effect.

Negative observations require Heartbeat coverage across both recorded interval boundaries. Nil restoration and reparenting reserve enough original TTL for a covered live polling interval; duplicate checks use a retrospective covered interval after the recorded first request, entirely within the original TTL. A late reader does not move those intervals past expiry. All unexpected/unmatched requests fail the case, and all 17 cases must complete before PASS. Cancellation receipts retain their originating warning identity; delayed disposal with missing coverage is inconclusive.

Independent agent `enemy_export_review` rereviewed the final revision: PASS scoped static review, no remaining blocker found. Raw probe SHA256: `bb1663e679309ff65d6846f8f7ad53a344affeb6f5c0d13f7e9387aa48091d53`. Root additionally reviewed request matching, first-VFX readiness, negative live-window margins and compact terminal-report handling. Local compilation is not a Studio result; native run03 remains pending.
