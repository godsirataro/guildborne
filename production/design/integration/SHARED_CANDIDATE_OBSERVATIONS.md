# Shared candidate observations — 2026-10-15 Bangkok

## Latest candidate 3f7 — actual earned two-client route

Candidate `3f7f4cf06ff4757bd9b38717797e9a39482af4032c5aadbbca52a4f0281bae9c` compared all377 sources in LocalPreview and dedicated Studio server. Full baseline869 tests and automated checks passed. Negative Studio IDs are now admitted only under exact injected Studio/Place0/Game0/Memory and current original-Player identity; defaults remain unchanged.

Actual Player1/-1 and Player2/-2 completed all six Novice chapters with ordinary native prompts/UI claims, Humanoid walking/dodging, and a bounded normal TrialInput driver for Keeper/class/Hall battles. No profile, objective, HP, cooldown or time mutations were used. Both reached revision28, Warrior Lv10/450XP, Hall1, claimed6 and one free Lv10 founder hero (P1 Priest, P2 Warrior). The 700HP class sentinels and 360HP Hall sentinels were defeated at full57 playerHP. One P2 Knight lesson failed TrialLeftArena; retry passed without source/gameplay changes. Client/server position lag and tool click offsets required re-observation; this is not physical mobile or latency acceptance. P2 founding required native scroll because the small viewport clipped its button.

Evidence: `novice-negative-identity-live.json`, `novice-first-class-player1.json`, `novice-first-class-player2.json`, `novice-two-client-founded.json`. Earlier failed gate observations remain below as history. Screenshots were returned in conversation; no saved video is claimed.

After earned founding, an explicit server fixture pivot moved both actual players into the opt-in shared lab (not a public travel path). Their naturally following Priest/Warrior companions damaged the same ordinary135HP scout: final counters36+99 damage; Priest lifetime HealingDone61.4 includes earlier recovery, so it is not a fresh shared-heal total. Both profiles stayed revision28,450XP and0Gold as reward binding was disabled. After corpse cleanup the scene incorrectly became Faulted/EnemyStep; `shared-earned-two-client.json` preserves this failure. Original player pivots were restored. A terminal lifecycle correction is in progress; this observation is not accepted shared-combat completion.

Separately, the actual CombatService-to-isolated-Memory-PDS fixture passed conserved fixed test rewards and replay after two retained failed attempts. See `shared-rewards-flow.md`; this is not delivery to the preceding real clients. Subsequent source changes add an opt-in actual-profile reward binding and HeroService.Destroy; those are not part of candidate3f7 and require a new candidate/test.

## Stage B synthetic physical integration

Candidate fd07d5754ab833e6bdc268a6a665b18077fb767582a4c2c483d13abd16cf57a1 matched375 local sources. Full baseline856 tests and all automated checks passed before later Bootstrap lab changes. Independent source review covered Coordinator, HeroService, World and tests. shared-hero-service-fixture.luau used actual HeroService scheduling, two synthetic Player objects and ten physical companion rigs. Synthetic schema records never entered PlayerDataService.

Raw attempt1 passed both owners prepared, owned commands, Saving/Degraded continuity (measured Knight movement0.0001051426 studs), session replacement, removal preserving the other owner/scout, geometry exit and model cleanup.21 damage/heal observations,0 legacy reward callbacks. A long-lived10000HP fixture scout was explicitly used; this is not balance or ordinary quest proof. Stop Play was then executed and returned Game Stopped, disconnecting the fixture's empty Heartbeat before the next Play.

## Opt-in lab and actual clients

The subsequent builder option --launch --shared-combat produces explicit local-only opt-in. Bootstrap requires launch, opt-in, Studio, Place/Game0 and Memory, and supplies a trusted exact-current-Player session provider. The lab has one ordinary scout, no respawn, public travel or reward binding. Independent source review and scoped LSP/compile passed. Runtime gate inspection is separate from the preceding856 baseline.

Candidate43b00810a08bb6fd3ff4232d45911dc79e236e29d5075a341622e6d455f507f3 was synced375 sources, then a native Server and Clients session was started. Dedicated server49ed688c-031a-405e-a8c8-3fd255315f05 compared all375 sources exactly against the generated payload; Place/Game0, empty JobId, Memory. Actual clients Player1/-1 and Player2/-2 joined.

Explicit fixture movement placed both new Novice players in the lab. Both personal plots reported NotReady. One actual client's Basic intent received no response, consistent with the existing Novice gate; scout HP stayed135. Original character pivots were restored. This proves no early combat bypass, not successful shared combat.

Both clients then walked the first Novice chapter using Humanoid.MoveTo and native E, physically dodged the practice warning, and clicked Claim100XP in visible UI. Their profiles reached revision5, Lv3. An initial movement observer incorrectly used PracticeWarning existence (the part exists while hidden); it was corrected to active transparency after inspecting source/state. No objective, health, timing or save fields were edited.

## Discovered multiplayer test blocker

Both reached TrainingYard and its enabled prompt. Server-side read-only signal observation confirmed Player1's genuine Triggered event. No arena was created. Actual projection showed Active profile, claimed1, Lv3 and no class. NoviceLessonSession.start rejects negative user IDs; the genuine class trial has the same positive-only check. Studio multiplayer generates negative Player IDs, so this blocks local multiplayer validation while the earlier positive-ID single-client path can work.

The failed observation is retained in novice-negative-studio-block.json. A narrowly scoped local Studio/zero-ID/Memory identity compatibility fix is in progress under V19 novice-studio-identity; no progression bypass is planned. Native End Session closed both owned clients/server; MCP inventory returned only LocalPreview and unchanged Staging. Re-test requires a fresh session and earned progression again.
