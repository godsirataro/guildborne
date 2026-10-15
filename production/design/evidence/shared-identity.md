# Shared encounter identity — pure foundation

Implemented explicit server-owned membership, with no runtime activation, profile writes, reward changes or CombatSpace permission changes.

## API

`SharedEncounterIdentity()` creates an isolated registry. `create()` returns an opaque frozen encounter token, or nil/error at capacity. `addOwner(encounter, numericUserId)` returns an opaque owner registration token. `addActor(encounter, ownerToken, actor)` registers a Hero with matching owner; `addEnemy(encounter, actor)` registers an Enemy. Registration returns the composite key or nil plus an error. `removeActor(actor)`, `removeOwner(ownerToken)` and `close(encounter)` revoke membership. `policy()` returns immutable `valid(a,b,ally)` and `key(actor)` functions for CombatTargeting's optional fourth argument.

Registry limits are eight active encounters, sixteen human owners per encounter, six allied actors per owner (player plus five heroes), and sixty-four enemies per encounter. Capacity is reclaimed on explicit cleanup. These are defensive bounds, not measured multiplayer capacity.

User IDs are nonzero finite safe integers, including negative Studio IDs. Enemy owner may be zero; local actor IDs are bounded ASCII identifier strings. Existing actor.id stays unchanged. Keys encode encounter generation, human owner identity/incarnation, local actor ID and registration generation. Different owners may each register player and h:1 without threat collisions. Enemy keys use a separate namespace.

Authority resides in private object registrations and registry-minted tokens, not copied fields, region strings or user-provided token contents. Cross-encounter pairs fail. Explicit allies are registered Hero→Hero only; hostility is Hero↔Enemy only. Enemy healing and friendly damage fail closed. Original range, sight and hostile-space callbacks remain required.

Captured id/owner/kind mutations invalidate a registration. Removing an owner revokes all its actors. Rejoining requires a new owner token and fresh actor objects; a previously registered actor object is never reactivated. This prevents a stale selected object from gaining authority again under a new registration. Runtime integration must close encounters/remove owners and replace reused pooled actor objects at generation boundaries.

CombatTargeting without a policy retains legacy owner/kind behavior and local threat keys. With a policy, enemy threat reads and CombatDamage threat writes both use the registered composite key. CombatDamage rechecks membership through targeting.effectValid immediately before health mutation, after spatial callbacks and damage calculation. This is a pure no-yield identity check; it does not relax effect range/cooldown checks. Missing policy leaves legacy behavior intact.

## Evidence and remaining work

`tests/run_shared_encounter_identity.luau` covers two owners with repeated player/hero IDs, unique threat accounting, real effective heal/zero overheal, no friendly damage/enemy heal, stale selections, detach/rejoin, forged tokens, changed encounter generations, malformed IDs, preserved spatial restrictions, revocation during spatial checks, and legacy owner/local-key behavior. These are pure local tests.

Runtime adapters, shared encounter lifecycle, original CombatSpace reconciliation, owned command authority, participation thresholds, durable settlement and actual multiplayer remain separate work. No region string or Party membership alone confers support/hostility permission. No rewards are created by this registry.

## Legacy damage compatibility correction

Full baseline exposed an ID-less legacy enemy fixture in the Wisdom/guard test: the first implementation incorrectly required a threat key for all damage. A key is now required only when damaging an Enemy and writing its threat table; legacy damage to a Hero does not need a local actor ID. Explicit identity mode still rejects unregistered actors through effectValid. A focused regression reproduces this case. The original failed full-validation log remains unchanged as diagnostic evidence.

Private server consumers may use policy.encounter(actor) and policy.ownerToken(actor) instead of parsing composite keys. Both resolve current registration; stale actors return nil, and enemies have no owner token. These opaque capabilities must not be projected to clients. They identify membership generations, not personal reward entitlement.
