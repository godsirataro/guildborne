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
