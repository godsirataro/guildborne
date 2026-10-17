# Fireball actual client presentation probe — 2026-10-17

S15 source 03b061005d3aad7014f7ef2364b5b1807fc34115 independently reviewed without blockers and integrated as 85da735. Worker released enemy-quality-slice before integration. Worker full baseline log records 899 tests; this is worker-source evidence, not a new combined baseline.

Controller executed the committed fireball_probe.luau against an exact source copy of SkillEffects named ControllerFireballReview in disposable running Studio 4c0f401f-f705-46a0-8baa-6d5decad4352, Client, PlaceId/GameId 0. Only the probe require target was changed. Existing whole-build gameplay module was not replaced; this is actual runtime module evidence, not whole-build or server combat acceptance. Earned chapter-7 Studio was untouched.

Tool result:
```json
{"lateObservationSkipsTravel":true,"cancellation":true,"particleEmissionCountVerified":false,"status":"PASS_LOCAL_ACTUAL_FIREBALL_PRESENTATION","serverCombatTested":false,"listenerCountVerified":false,"fiveActorPrimaryParts":8,"stages":{"Charge":9,"Travel":2,"Impact":8},"duplicate":true,"studioDevicePerformanceAccepted":false,"activeTravelImpactCancellation":true,"ttl":true,"touch":false}
```

The probe exercised real generated parts, late/expired timestamps, duplicate rejection, nil/replaced stamp, CombatHealth death, removal, active Travel/Impact cancellation, absolute expiry, aggregate five-actor compact Primary coverage, distant rejection and Low fallback. It restored camera and quality attribute and destroyed its actors/effects. Controller then removed the review ModuleScript and independently counted:
```json
{"remainingProbeActors":0,"remainingEffects":0,"moduleRemoved":true}
```

Limits: no ordinary-input combat visuals or motion-quality acceptance, no measured particle emission/listener counts, no separate Humanoid.Died fixture, no per-actor compact coverage proof, no physical touch/FPS, audio or server damage/reward evidence. Independent review approved timing/cancellation/caps within these limits. Presentation uses existing native engine texture; no asset upload or runtime ID invention.
