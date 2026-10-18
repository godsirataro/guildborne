# Greenwood authoritative combat presentation fixture

Base `96278a2`. REVIEWABLE / COMPILE-ONLY until controller executes it.
This is a **one-shot synthetic integration exercise**, not earned progression,
five-companion acceptance, reward acceptance, native input testing or art approval.
No production gameplay source is changed.

## Installation: controller-owned fresh unsaved Studio only

1. Preserve all earned sessions. Open a separate, fresh unsaved place, with
   `game.PlaceId == 0` and `game.GameId == 0`. Do not install in the existing walking,
   cosmetics or earned-gameplay session. Run one local player only.
2. Transfer the exact source tree at the reviewed harness commit using the existing
   source installation workflow. Retain the normal `default.project.json` mapping:
   `ServerScriptService.Server`, `ReplicatedStorage.Shared`, and
   `StarterPlayer.StarterPlayerScripts.Client`. This harness is outside that mapping
   and must be installed separately. It needs the complete production module tree,
   not the nine-module cosmetics bundle. Record source identity/readback evidence.
3. **Before Play or any service require**, disable both `Server.ServerBootstrap`
   and `StarterPlayerScripts.Client.ClientBootstrap`. In this disposable Studio
   copy only, set Config.Runtime.StudioPersistence to `"Memory"` and keep
   AllowedDataStoreUniverses empty. RegionalCombat captures this gate at require
   time: changing it after a service was required is too late; restart fresh Play.
   No ServerBootstrap, repository, DataStore or network persistence is constructed
   by this fixture. Do not change the repository runtime config.
4. Install `GreenwoodCombatFixture.server.luau` as an enabled Script named
   `GreenwoodCombatFixture` under ServerScriptService. Install
   `GreenwoodCombatObserver.client.luau` as an enabled LocalScript named
   `GreenwoodCombatObserver` under StarterPlayerScripts (beside Client).
5. Confirm no GuildborneWorld, GuildborneArtKit, prior fixture/report, or existing
   gameplay character/session. Start local Play once. Do not run other fixtures,
   normal bootstrap or an extra EnemyAnimator. No Studio plugins or Blender work
   are needed. A bounded timeout is a failure/inconclusive result, not permission
   to bypass guards, set actor health, stamp event attributes or stub damage.

The server constructs exactly one real WorldService, with the existing
CombatService → RegionalCombat → AdventureCombatBridge → AdventureEncounterSession
→ AdventureEnemyBrain/Patterns/Damage route. Its owner has a synthetic Knight
level-60 profile, Hall9 and an empty companion roster. The profile is initialized before Sync;
no running health/stat values are edited. See server `syntheticProfile` for exact
level. Travel uses the existing World.IntentCommitted entry point. Controlled
anchored player placement isolates geometry cases; this does not test walking,
collision response, ordinary player inputs or earned travel authorization.

The non-nil regional reward factory is a recorder returning Rejected. It is required
to activate the existing regional route, but is explicitly **not** a persistence
adapter or proof of rewards. The intended scenarios keep the captain alive and
require zero reward calls. No DataStore module or production reward adapter is
used. Player Basic attacks call real World.PlayerAction; the server still selects
the enemy, validates range/LOS/cooldown and applies actual damage.

## Paired execution and observations

The server creates Workspace.GreenwoodCombatFixture with OwnerUserId, Ready,
Phase, Captain/Victim ObjectValues, a Report StringValue and a scoped ClientStatus
RemoteEvent. The client checks its own identity and disabled bootstrap, waits for
real actor joints, starts the real default-tag EnemyAnimator once, then sends
Ready. The remote accepts owner-only readiness/finish reports; it offers no
combat commands and never authorizes hits. Do not manually send handshake events.

The client follows the real captain with front then side camera views and samples
actual Motor6D transforms, replicated health/cues and real AdventureTelegraph
outlines. Those outlines come from the existing server renderer; the harness does
not draw fake markers. Normal CombatController and skill/audio controllers are
not started. Consequently this run does not accept party VFX, HUD or audio.
Reduced motion is locally enabled for stable observations and restored on exit.

Server phases:

- **HitCleave:** enter the real 10-stud range; observe Antler Cleave's 1.1-second
  warning, then require actual victim health loss and a new DamageCueAt on release.
- **EvadeCleave:** acquire another committed warning then move to 14 studs,
  outside its locked footprint but inside detection. Require a new release stamp
  without damage. This is evasion, not cancellation.
- **CancelCleave:** leave all target detection by moving to the inspected lateral
  +55X waiting point (not +55Z near the boar). Require the warning to clear before
  due and no impact/damage cue across the former release boundary. Natural recovery
  can increase health; it is not treated as damage.
- **PhaseTwo:** real Basic commands reduce the living captain below half health;
  no raw health writes or phase forcing. Wait for the actual alternating Root Burst,
  verify its 1.5-second warning and actual victim damage on release.

Do not equate RegionalImpactAt with successful damage: the bridge also emits it
when targets evade. Server reports keep os.clock and workspace:GetServerTimeNow
separately; warning/impact attributes use the latter. Compare like clocks only.
Server ticks are .2 seconds, so release is quantized rather than exact at the
warning deadline. A stall must remain visible as an inconclusive/failing run.

## Output and cleanup

Read server `workspace.GreenwoodCombatFixture.Report.Value` and client-local
`workspace.GreenwoodCombatClientReport.Value`. The server retains the observer
payload as `UntrustedClientReport`, clearly separate from authoritative outcomes.
Retain raw JSON, console errors and exact source identity. PASS_SERVER_FIXTURE
means the server scenario assertions passed; independently inspect the client's
status and samples. A missing/failed client report does not accept presentation.
OBSERVED_NATIVE_CLIENT means observations were collected, not visual approval.
Screenshots/recordings and human grip/grounding/readability review remain external.

Finished is a bounded handshake before actor teardown. The client disconnects its
sampling, destroys its animator and restores camera/reduced-motion settings.
The server removes its owner session, destroys the hero runtime and owned world/
templates, restores lighting and the original player anchor/pivot/zone/spawn where
possible, and retains reports. Cleanup errors remain failures.

**Always Stop Play after collecting results.** WorldService has no complete
Destroy method; TravelService owns an anonymous Heartbeat without a disconnect
entry point. Collision-group registration and synthetic character equipment/
attributes also belong to this disposable session. Cleanup is therefore not a
zero-connection restoration and this harness is not reusable in the same Play.
Even a constructor failure requires Stop Play. No repair to production services
is included in this assignment.

## Review evidence

Runtime execution has **not been performed by this worker**. Both fixture scripts
compile successfully and `git diff --check` passes; production `src` has zero diff.
Independent source review found and corrected the regional scene parent lookup,
boar contamination at the original waiting point, partial-constructor cleanup, and
silently missing client joint observations. Updated review found no concrete
remaining blocker. Standalone server type analysis lacked runtime module mappings;
no full type-analysis or baseline PASS is claimed. Controller owns Studio execution.
The previous native cosmetics PASS and full baseline do not prove this new harness.
