# Hero-owned Class2 mentor — local implementation

Status: source implemented; synthetic Luau tests only. No Studio import, live hero trial, physical-device, multiplayer, or human acceptance is claimed by this worker. The earlier normal player/Borin candidate remains separate evidence. Runtime flags and published places were not changed.

## Contract and normal route

In the isolated launch candidate, open Skills, select an owned companion, and choose **Train hero** for a Class2 path. The selected hero must be Healthy, in the active party, Lv35+, with Hall4+ and claimed Quarry Patrol. No expedition, dispatch assignment or Tower may be active. The owner must be alive on their own Guild plot, outside combat.

The arena takes temporary ownership of the existing selected hero model. The normal HeroService movement/combat scheduler is suspended; other followers are frozen in place. The same CombatStats, CombatTargeting, CombatDamage and CombatAbilities modules run server-side training with copied stats, temporary health and borrowed art. The hero must demonstrate its actual art effect, survive at least three construct hits and defeat the construct within 180 seconds. Healing requires actual HP restoration; Guard requires a hit while guarded. Cast success is evaluated after the full damage/cast event batch, including a lethal first cast. Construct HP scales with attack so strong equipment does not bypass the survival lesson. The owner watches the trial and may cancel before saving begins.

Success saves proof for that specific hero and path. It does not advance the class, grant XP/currency/items, learn skills or change permanent health. Return to Skills and confirm advancement using the existing command and its existing gates. A fresh successful trial on another path replaces the unspent proof while the hero is still Class1. Old proof cannot promote another hero or another path. Historical Class2/3 heroes remain valid without proof; future Class3 advancement retains its existing rules.

## Persistence and lifecycle

Optional `expansion.actors[heroId].mentorProof` contains version, pathId and trialId. ExpansionSchema validates it regardless of launch flags. Projection removes the stored proof identifier and exposes only display readiness and gate reasons. Missing proof requires no migration.

Public Protocol accepts only StartHeroMentor and CancelHeroMentor. HeroMentorProof is private to PlayerDataService, using its existing execute/commit/replay/session-owner machinery. The receipt captures the owner session epoch/token at trial start, plus a copy of the selected hero/build. Commit rechecks current ownership, health, dispatch/expedition state, level, Hall, quarry first-clear, party and exact hero/build identity. The adapter keeps the same immutable command after an uncertain write and fences replacement sessions before delivery.

Cancellation is rejected with SavePending once receipt delivery starts. External removal still releases the arena; persistence owns any already accepted candidate. Yielding receipt callbacks recheck arena identity, session identity and character before cleanup/notification. Normal completion, cancellation, death, session loss, changed hero and disconnect restore the original model/controller. Construction errors roll back ownership. Per-member restore errors are logged; the arena is not destroyed while it still contains an unrescued selected hero.

## Automated checks

`tests/run_hero_mentor.luau` covers all ten paths, high attack, missing ownership/path/prerequisites, unhealthy/dispatched heroes, timeout/bounds, actual support effects, lethal-cast ordering, proof replacement and actor isolation, optional proof corruption, legacy earned builds, Class3 compatibility, protocol rejection and start-session fencing. `tests/run.luau` additionally exercises real PlayerDataService uncertain-before-write/after-write recovery, callback replay and rejoin using a synthetic fixture.

Logs are `build/hero-mentor-tests.log` and `build/hero-mentor-validation-final.log`. These are local automated evidence, not footage or cloud acceptance. Review the final handoff for the latest completed count; files may have been amended after an earlier log.

## Studio fixture recipe for the integration owner

1. Build a new isolated launch candidate and record its SHA; retain the old normal route as evidence for its original SHA. A fresh Memory boot must hide hero training for the Novice player and reject unavailable/foreign/low-level hero starts normally. Do not label synthetic progression as a normal route.
2. In a separate disposable fixture, create a schema-valid synthetic record with one Healthy Lv35 hero in party, Hall4 and quarry first-clear. Use the normal HeroService/WorldService model creation and BeginHeroMentor/EndHeroMentor pair. Supply HeroMentorWorld with a fixture Data session, the real HeroMentorTrial and the real receipt adapter. Never substitute a player campaign receipt or set proof directly.
3. Exercise the ten path/class combinations, observing the actual selected AdventurerId, health, art and construct result. Start/cancel a trial and compare selected model parent/pivot/attributes, unrelated follower anchors and resumed normal movement. Inject construction failure after ownership acquisition and check rollback. Cancel during a deliberately pending receipt must return SavePending. Change session token/epoch and respawn during a yielding receipt; the old callback must not touch a replacement arena or grant in a new session.
4. Treat this as synthetic world/lifecycle acceptance only. A complete normal hero recruitment→Lv35→trial→advance route, real animation/audio quality, all network and device gates remain separate work.

Known limits: the arena is a functional training presentation using a simple construct/patient. It uses deterministic training AI rather than the regional encounter scheduler. Human art review, actual companion motion/cast readability and live lifecycle verification remain pending. Hero progress is not promoted by the player's mentor story.

## Mentor UI availability increment

The server projects per-path readiness and current eligibility through `HeroMentorTrial.presentation`. Saved proof does not bypass current party, dispatch, health or expedition requirements. Legacy progression receives no new mentor UI gate. Private proof identifiers remain omitted.

`HeroMentorWorld.State` exposes only `{status, actorId, pathId}` for the current player; `Network.Send` adds this ephemeral `heroMentorSession` to a snapshot without changing profile data or revision. Active training disables new training and advancement, identifies its hero/path, and permits cancellation. Saving disables cancellation. The server still independently rejects invalid requests. Idle snapshots have no cancellation control. Start responses retain the normal `OK` message; the transition to receipt delivery sends `HeroMentorSaving`, ensuring the same-revision UI update receives a message and rerenders. Integration owner must route these known localization codes through SliceController before rendered acceptance.

Local regression checks cover saved proof plus party removal/dispatch and recovery, legacy compatibility, session projection isolation, and English/Thai gate/lifecycle messages. `build/hero-mentor-ui-validation.log` is the increment's full validation log. Rendered native UI, same-revision transitions and a normal hero journey still require separate Studio evidence on the rebuilt candidate. Suggested native fixture: show Skills for a different actor while one hero trains, verify selected training actor/path and disabled Train/Advance; send Saving at the same revision and verify Cancel is disabled; clear the session and verify no idle Cancel; remove/re-add a proven hero from party and verify Advance follows current eligibility in both languages.
