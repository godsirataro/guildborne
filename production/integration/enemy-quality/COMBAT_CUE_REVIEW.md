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

## V8 recorder endpoint publication correction

Worktree base: `f387f052d2d6c4fa1db4b12204e14b06d3fddf8f`; branch `codex/combat-cue-boundary-v8`; shared ledger `four-session-v8.sqlite3`; task `combat-cue-lifecycle`; owner `s15-probe-boundary`. This correction changes only this report and `combat_cue_probe.luau`. Runtime controllers, class/skill data, cue TTLs, camera ownership guards and all 17 native cases remain unchanged.

Subsequent controller runs supersede the earlier pending-run notes: native03 and native04 were inconclusive before cases started. Native04 console identifies Studio Assistant ExecuteLuauActions restoring CameraType after the enabling tool call. The controller therefore owns native UI enable/start outside that tool boundary. Native05 avoided camera interference but remained INCONCLUSIVE on the first missing-target observation: 1,377 recorded Heartbeats, maximum recorded adjacent gap `.0977890491`, zero requests/VFX/cases. Its console tool output was truncated; the compact terminal report was retained by the controller under `build/agentic/native05`. This change does not relabel any of those runs.

The old coverage predicate could fail because no recorder sample yet reached the fixed endpoint b, even when every adjacent recorded gap was below .15. A waking coroutine's clock reaching b is not itself a Heartbeat observation. Native05's summary supports this explanation but lacks its original a/b/last-sample values, so callback ordering for that historical run remains unproven.

After the clock reaches the original b, observe now waits for recorder publication only while the reason is `end_sample_pending`. The requested wait budget is two seconds; a host stall may delay resumption, and already completed recorded coverage is evaluated without moving the window. No timestamp is inserted by the waiter. A real gap above .15, absent starting sample, clock regression, or endpoint still missing at the deadline remains INCONCLUSIVE. The compact ProbeReport includes a/b, predecessor/successor when present, lastRecorded, sampleCount, maxWindowGap, explicit reason, gap endpoints when relevant, and publication wait duration. Full stdout is retained as before.

Observation still returns the original `[a,b]`. `noNew` still checks that endpoint against the original action deadline and rejects unexpected requests, including ones observed during publication waiting. The next target/HP/reparent stimulus still must satisfy `readyForMutation` using current time and the original source deadline. Waiting for evidence cannot renew a cast or make a late missing-target stimulus valid. The controller must still observe `CLIENT_CUE_PROBE_TERMINAL` before post-cleanup tool reads.

Independent agent enemy_export_review reviewed the scoped source change before commit: PASS, no blocker found. Reviewed raw probe SHA256: `66788caef644b9c43e897705e6f48c6a5136403f1b1b3d5f7fa700a96d1d6ea1`. Deterministic focused checks use the actual extracted helper source under ignored `build/cue-boundary-tests`; their committed-source receipts accompany handoff. Local compilation/static review/helper checks do not establish native or audible acceptance. The next Studio run remains controller-exclusive.

Focused deterministic result: **17 local harness cases PASS** (12 helper cases and 5 extracted control-flow cases). This count is separate from the **17 native cases, still pending**. The harness reproduces the old baseline missing-tail rejection, verifies publication/no fabricated samples, exact .15 threshold and two-second deadline behavior, and checks actual observe/noNew/readyForMutation for fixed endpoints, late unexpected cues and rejected late follow-up stimuli. Extracted helper SHA256 `19ac1286de4cf2239b94578b4d82857cf85d318d4182d982a9c79777c52c8e1b`; extracted control-flow SHA256 `03a3fd1727f99b9c1dc3178a715695f07470e3dfd81a23e096ebf16f6946c59c`. Receipt stdout retains the harness inputs as well as their hashes/results for review.

## Native06 manual-arm endpoint follow-up

Controller reported native06 on exact `fefe3d8` was inconclusive at manual arm with zero cases, requests and VFX, and clean teardown. Its coverage diagnostic was `end_sample_pending`: a `1792380236.978566`, b `1792380237.978566`, lastRecorded `1792380237.971273`, predecessor `1792380236.970796`, maxWindowGap `.0180940628`. The controller reported 1,267 samples and global maximum gap `.0186948776`. These are controller observations; this worker did not run Studio or modify its raw receipts.

The manual-arm call still used synchronous covered despite observe having the publication barrier. The one-line fix routes it through `observe(1,"Manual arm preceding 1s Heartbeats",armedAt-1)`. The single captured armedAt, original preceding one-second interval, .15 gap limit, existing two-second publication budget, following camera-interference guard and all action TTLs remain unchanged. Action timestamps are created only after this gate. This does not restart READY, invent Heartbeats or retry the arm edge.

`combat_cue_arm_regression.py` extracts actual helper, observe and manual-arm source and runs four local cases: delayed endpoint publication succeeds on the original interval; a real gap fails immediately; missing predecessor fails immediately; camera interference during publication still fails. All four passed, and the prior 17 local boundary/control tests passed again. These local counts do not establish native case acceptance. Run the new regression with `python production/integration/enemy-quality/combat_cue_arm_regression.py --luau <absolute-luau-executable>`.

Independent agent enemy_export_review reviewed the actual probe change and regression: PASS, no blocker; reviewer did not rerun tests or execute Studio. Reviewed raw probe SHA256 `bb7a7538aca1c5a77f05d14ae438337c11795055cb6a0bd71a5f4d1ce74d12b1`. Extracted arm-source SHA256 `300713a563cc86c8b673a399c0708f9378c48c69d645aa291c0703c9e5e958fb`. This bounded follow-up uses shared v8 task enemy-quality-slice, owner s15-arm-boundary; earlier accepted combat-cue-lifecycle evidence stays intact. Controller owns integration and the next native run; native acceptance remains pending.


## V10 party overhead readability candidate — 2026-10-20

Base `f4a3c97`, branch `codex/party-labels-v10`, shared v10 ledger, task `combat-cue-lifecycle`, owner `s15-party-labels`. Authorized scope is CombatController, this review, and focused tests in the existing combat_cue_events test file. No Studio, provider, push, publishing or gameplay changes are part of this worker delivery.

The archived R3 image `production/integration/quality-slice/native-party-r2-r3-20261020/r3/manual-cast.png` shows overlapping companion overhead name/HP/action panels despite the dedicated six-card HUD. This is evidence of the earlier layout, not native acceptance of this candidate. The bright purple object remains unidentified by this worker; neither this change nor the evidence attributes it to Fireball.

CombatController now inspects the existing direct `GuildbornePlayerCombatUI.CompanionSelection.Actor1`–`Actor6` cards once per existing 0.1-second HUD tick. It maps exact ActorId (`player` only for the current Character, otherwise the owned following hero's AdventurerId), never a cached PartySlot. Coverage requires ScreenGui.Enabled, visible positive-size GuiObject ancestors, an attached visible HealthTrack, and the complete track rectangle within the current viewport. A hidden/collapsed/reused/missing/offscreen card does not suppress that actor's overhead. The walk is bounded to six cards and eight ancestors; no workspace scan or new event connection is added. Arbitrary overlapping GUI occlusion is not measurable by this predicate and remains a native visual review limitation.

Covered friendly actors omit redundant name/HP panels. A recent action or feedback retains a 132x34 transient two-line label, with end truncation and no duplicate HP fill. It uses the existing 0.8-second display freshness guards, not the combat admission TTL. Uncovered own player/following companions use the existing 156x50 full label; this also supplies the previously absent own-player fallback. Foreign actors and nonfollowing heroes stay hidden. Enemy/boss labels retain full HP, phase, action, warning countdown and feedback. Cue admission, sound dispatch, damage and SkillEffects are unchanged. No new localization keys are added; existing translated action text and feedback bindings remain.

Focused behavioral tests exercise the actual extracted controller helpers, not a rewritten policy: six added groups cover visible-card suppression and transient feedback; disabled/hidden hierarchy fallback; exact identity, reused slots and collapsed cards; viewport/zero-size rejection; detached/missing HUD and malformed identity; ownership, nonfollowing membership, invalid HP and enemy fallback. The original six cue selector groups run in the same invocation. The standard standalone cue runner continues to run its original groups; the optional presentation cases require the extraction below. This local fixture models UI hierarchy/properties, not Roblox rendering or physical-device acceptance.

Reproduce from the repository root (Python, then existing pinned Luau):

```python
from pathlib import Path
out = Path("build/party-label-tests")
out.mkdir(parents=True, exist_ok=True)
source = Path("src/client/Controllers/CombatController.luau").read_text()
policy = source.split("-- BEGIN PARTY_LABEL_POLICY\n", 1)[1].split("-- END PARTY_LABEL_POLICY", 1)[0]
(out / "policy.luau").write_text(policy + "\nreturn {visibleHealthCards=visibleHealthCards,overheadMode=overheadMode}\n")
(out / "run.luau").write_text('require("../../tests/combat_cue_events")(require("./policy"))\n')
```

Run `.tools/luau/luau.exe build/party-label-tests/run.luau`, then `powershell -NoProfile -File tools/validate.ps1`. Local results and independent review are recorded below when complete. Controller native acceptance must inspect desktop and collapsed layouts, HUD enabled/hidden/missing, party reorder/replacement, own-player fallback, enemy windup and long Thai/English feedback; transient text truncation is intentional but still needs visual review. No mobile FPS or all-party layout acceptance is claimed.

Local result: all 12 focused groups PASS (six existing cue groups plus six added presentation groups); compilation PASS; full tools/validate.ps1 exited 0 with 973 tests, build, Roblox-aware analysis, compilation and repository checks PASS. Baseline raw log: `build/party-label-baseline.txt`, SHA256 `6339ddbe72f620b9b1965997ce493f63a60500f300866a04cce5e4aeb8db44ca`. This baseline ran on the final runtime/test source before this documentation/result commit. Independent agent enemy_export_review reviewed runtime, test extraction and the V10 documentation: PASS, no blocker; reran all 12 focused groups. Reviewed raw CombatController SHA256 `ee00b655a1c7c8faefec2c1ddae588bfabe439f6a4b97dbb54db2a60ff83b183`. No Studio execution or visual/device acceptance occurred in this worker.
