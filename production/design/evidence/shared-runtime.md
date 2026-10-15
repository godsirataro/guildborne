# Shared encounter scheduler — injected runtime foundation

No production scene/bootstrap activation, profile writes or reward delivery. This adapter coordinates existing registered server actors; it does not replace CombatDamage or grant human Party members control over one another's heroes.

## API

`SharedEncounterRuntime({Registry, EnemyStep, OwnerStep, OnError?})` creates one encounter through the injected SharedEncounterIdentity registry and returns runtime, or nil/error if creation fails.

- `Join(ownerId, opaqueSessionTable, denseActors)` returns boolean/code. At most sixteen owners and six actors each; actor owner/kind/id and dense roster shape are checked before replacement. Exact same active token and actor order is idempotent. Same token plus changed roster rejects.
- `Leave(ownerId, exactSessionTable)` detaches only that membership. Stale removal cannot detach its replacement.
- `AddEnemy(actor)` / `RemoveEnemy(actor)` register/remove enemy objects through the same registry. At most sixty-four enemies. Removing a human leaves other owners and the shared enemies intact.
- `Tick(monotonicStamp)` runs at most once for an increasing finite nonnegative stamp. Reentrant/concurrent calls while suspended return Busy. A consumed stamp never replays after failure.
- `Policy()` supplies the existing explicit targeting policy. `EncounterToken()` returns the opaque server encounter token, nil after Close.
- `Close()` is idempotent, invalidates all membership, and prevents future steps or registrations.

Callbacks: `EnemyStep(stamp, sharedAllies, enemies)` once, followed by `OwnerStep(ownerId, session, stamp, ownActors, sharedAllies, enemies)` for each still-current owner captured at tick start. All lists are fresh frozen arrays, while actor objects remain the existing server combat entities. Owner lists contain only that owner's actors; shared support candidates are passed separately. Arrays are not public command permissions.

## Lifecycle and failure contract

Each attachment requires a fresh opaque membership token capturing the adapter's live Data session/generation, plus fresh actor wrappers. Tokens retire on Leave/replacement. Delayed Join/Leave with retired tokens cannot revive or remove a later attachment. Mentor/trial entry explicitly detaches; return creates a fresh attachment. Do not re-register pooled actor objects or pass profile tables as combat actors.

Before replacing a session, malformed/used local rosters fail without touching the current membership. If injected registry registration subsequently fails, any partial new membership is removed and the old generation remains retired: failure closes access rather than reviving stale actor objects. Other owners and enemies are retained.

The tick stamp is consumed and busy flag set before callbacks. Enemy callback failure skips owner steps; owner callback failure is contained and other current owners may continue. Partial combat effects are not rolled back or replayed. Yielded callbacks keep the tick busy; Leave/replacement/Close can still invalidate their actor references. Existing CombatDamage's effect-time registry check denies subsequent stale effects. Owners joined after tick start are not given an owner step until a later tick. Every owner callback receives a fresh current ally/enemy list after prior callbacks; stale captured arrays confer no authority.

The service does not inspect DataStore, positions or mentor state itself. The integration adapter must validate live session/progression/spatial access, call detach on death/leave/mentor transition as applicable, and retain original owned-hero command checks. Shared CombatSpace integration and enemy world movement remain separate work.

## Evidence

Pure/injected tests cover 2, 6 and 7 human owners, a 16-owner/96-allied-actor fixture, repeated local IDs, idempotent joins, stale session replacement/removal, mentor detach, once-per-step scheduling, reentry and callback faults, yielding callbacks with stale damage/heal denial, Close during suspension and malformed rosters. Counts are fixture bounds, not tested production multiplayer capacity.

Logs: build/shared-runtime-tests.log and build/shared-runtime-analysis.log. Independent source review and a Studio injected harness are next gates; neither substitutes for real 2/4/6 clients, mixed solo/Party play, cloud recovery or durable shared payouts.
