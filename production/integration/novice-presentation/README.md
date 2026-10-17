# Novice / Archive accepted-action presentation repair

The server writes `ActionAt` after successful actions in NoviceTrialArena and
ArchiveHeartArena. The client proxy previously omitted this attribute, so
SkillEffects rejected accepted actions for lacking a valid server timestamp.

NoviceTrialController now forwards the original timestamp before invoking VFX and
audio. Its small presentation cursor uses the existing ActionTimeline.accept:
finite, live, strictly newer observations only, with the shared 0.62-second window.
Missing origin/target positions do not consume the timestamp. A nil ActionAt clears
the proxy timestamp to cancel delayed effects but does not erase the consumed
cursor. Removing or replacing the arena destroys its proxy and resets the cursor.
Server combat, inputs, cooldowns, rewards and audio asset bindings are unchanged.

## Local checks

Run the added stateful test explicitly (it is not registered in tests/run.luau):

```
.tools/luau/luau.exe tests/novice_action_presentation.luau
.tools/luau/luau.exe tests/action_timeline.luau
```

The first executes the production cursor with the real shared clock predicate:
delayed/incomplete payload, duplicates, reordering, invalid/future/expired stamps,
cancel/re-observation, reset and independent cursor isolation. The existing
action-timeline test also exercises actual server CombatAbilities with spies for
accepted and rejected actions; it does not simulate arena remotes.

`baseline.log` retains the initial tools/validate.ps1 run: 894 existing tests and
Rojo build/sourcemap passed, then analysis rejected an unannotated mixed-type test
fixture. The fixture now explicitly uses `{any}`. `validation-continuation.log`
records the corrected cursor test plus the remaining full-source analysis,
compilation, repository and diff checks; the long unchanged regression suite was
not repeated for this test annotation. These checks do not constitute Studio or
physical-device acceptance. Independent source review found no blocking
production-code issue; a separate reviewer ran the cursor test successfully.

## Controller-run Studio probe — NOT_RUN by S15

Use a fresh isolated, unsaved local full-game play session with exactly one
bootstrapped NoviceTrialHUD and no active Novice/Archive encounter. Run
`tests/studio_novice_presentation.luau` on the CLIENT using the existing trusted
controller Studio workflow. Do not instantiate another controller. The probe
refuses pre-existing arenas and creates only its own synthetic local fixtures.

It drives the actual controller in both arena modes, observes its real proxy and
nearby Mage VFX, and checks accepted forwarding, invalid/repeated observations,
late position arrival, cancellation and removal. Camera/quality are restored and
fixtures cleaned even on failure. No remotes are fired. Audio remains unbound, so
this is not listening acceptance. Save actual returned results and errors without
promoting a synthetic fixture to server combat/reward evidence.

Cancellation scenarios require detailed Mage cues and observation before 0.25s,
ahead of its delayed 0.3s stage. A stalled run reports INCONCLUSIVE_STUDIO_STALL
instead of counting already-completed effects as successful cancellation.

After the fixture passes, separately perform accepted Basic/Ability and rejected
cooldown/invalid-target/downed actions through actual server-owned arenas, then
verify no timestamp/presentation is created by rejection. Existing unit tests are
not substitutes for this end-to-end check. S15 has no Studio access for this task.
