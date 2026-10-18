# Borin source integration candidate — 2026-10-14

This task integrates contact presentation into the existing Smith Borin NPC,
without changing quest rewards, crafting, travel, profiles or NPC authority.
Source status: REVIEW CANDIDATE. The source worker did not mutate Studio.

## Implemented boundary

`FriendlyCityNpcs` keeps the existing model, root, labels, Talk prompt, NpcId,
QuestNPC tags and returned station reference. It adds an explicitly labelled
native, non-colliding workpiece/anvil, plus a twelve-second interaction timestamp
when the existing Talk callback runs. That timestamp is presentation, not quest
or conversation ownership. A later speaker refreshes the bounded timestamp.

`FriendlyNpcAnimator` remains the sole native pose owner. Borin has independent
Idle / Interact / Recover / Work state. Work fades to rest on interaction;
recovery eases into the initial windup before the work clock resumes. Visible
local Borin dialogue extends local interaction while that player is nearby.
When a replicated interactor is observed more than14 studs away the timer is
ignored locally; absent streamed character information retains only its bounded
timeout. Other clients do not receive a confirmed dialogue-close notification.

Reduced motion, escort movement, camera distance greater than100 studs, removal
from Workspace and controller destruction restore the original motor C0 values.
Streaming additions/removals are tracked; destroyed actors release listeners.
Contact flash/audio is bounded within55 studs. Audio uses the coordinator's
PlayFor / forge_strike binding and remains silent without a valid loaded asset.

`BorinWorkMotion` adapts the reviewed v2 two-second anticipation, accelerating
strike, rebound and recovery curve from `tools/blender_borin_forge.py`.
`BorinPresentation` solves the existing native right arm chain towards a fixed
workpiece using two-bone geometry, retaining the hammer weld and authoritative
root. Existing left-hand tongs stay on their original native rig; this is not
the detailed authored two-hand performance. Contact cannot mutate gameplay.

The current full-game geometry remains native Parts. No detailed mesh or
animation was imported by this worker; no runtime asset IDs were invented.
The source study remains unchanged:

- Generator SHA256: `f161e47972faaead47a3c498b95400e61bc3c75f9d6e7377a64b6a01c7cee435`
- Borin v2 manifest SHA256: `17c5fcaaf625137d8b1bdad68582439d7cd744978b692f4afff1b704b17564be`

## Coordinator's isolated detailed-art seam

Setting `DetailedBorinPreview=true` on this NPC restores/skips native pose and
native contact effects. The coordinator's separate preview adapter owns its
authored visual and effects, and removes the attribute on teardown.
Client attributes expose `BorinLocalPresentationState`, `BorinLocalWorkClock`
and `BorinLocalWorkWeight`. This seam does not certify the detailed adapter or
allow production upload. Native pose ownership resumes when the attribute clears.

## Checks performed by source worker

- Five pure Borin lifecycle/curve tests passed in `tests/borin_presentation.luau`.
  They cover repeated interaction, recovery, independent clocks, reduced motion,
  distance/escort suspension, exactly one cue per strike and stalled-frame replay.
- Existing `tests/run.luau`:714 tests passed. The runner was not edited. Its
  deterministic load fixture is local evidence, not live cross-server acceptance.
- Six scoped Luau files compiled; focused Roblox Luau-LSP analysis passed with
  the coordinator's regenerated sourcemap. No baseline check is promoted to UAT.
- Diff whitespace check passed.

`tests/studio_borin_integration.luau` is a coordinator-run disposable fixture for
actual native hammer/workpiece contact, unchanged root, idempotent station,
non-collision and restoration. It was authored and compiled but NOT executed by
the source worker. The coordinator reported actual execution in the isolated
Memory-only full preview: `PASS_NATIVE_FIXTURE_ONLY`,3 contact samples,
maximum contact error `2.6656007889869218e-7` stud, root preserved and joints
restored. `questJourneyTested=false`; this is not detailed-mesh contact proof.
The coordinator owns the raw Studio receipt and its independent review.
Full spawned dialogue/quest/craft/claim/travel journey,
streaming, multiple clients, physical device, detailed-art fitting and human
approval remain separate pending acceptance.

## Next owner

Coordinator verifies the exact isolated Studio session, runs the native probe
and actual Borin quest journey, and reviews the separate detailed-art adapter.
Independent reviewer inspects this candidate and evidence before task acceptance.

## S17 stationary daily activity integration — 2026-10-17

This extends the same animator to consume `NpcLifeSchedule` for the sixteen
existing FriendlyNpcs identities. It does not add actors, relocate roots, change
prompts/quest aliases or implement home/work walking. Earlier evidence above
belongs to its original revision; new Studio checks remain NOT_RUN by S17.

The existing world clock (`Lighting.ClockTime`, currently initialized to 10.5 by
WorldService) supplies the daily activity phase. No new day/night cycle is added.
Server-time seconds separately govern interaction deadlines and animation; these
clock domains must never be compared directly. The client uses an empty Journal
for this presentation projection; real hooks and rewards remain server-owned.

Ten Central City NPC prompts now stamp bounded `NpcInteractUntil`/`NpcInteractor`
attributes after the existing prompt's proximity validation. Borin's legacy
attributes and sole contact/pose owner remain. Six civic hosts are outside the
server-builder write scope: they use their actual local dialogue visibility and
existing `WorkMotionIdentity` gestures, not a new replicated interaction claim.
This is explicitly not sixteen server interaction hooks or multiplayer proof.

Local nearby `FriendlyDialogue_<NpcId>` visibility suspends work while the panel
and its ancestors are visible/enabled. Dialogue discovery is sampled at bounded
cadence, not recursively scanned each frame. Work fades out over .25 seconds
and returns over .6 seconds. Far/reduced-motion actors restore native joints;
restoration is skipped once already done, while streaming additions invalidate
that cache. Root motion and quest accessibility remain untouched. The one
existing RenderStepped loop still iterates the tracked actor set: this is not a
generalized population scheduler or measured support for 410 visible rigs.

### Controller-only probe

Keep the no-argument `tests/studio_borin_integration.luau` call for the existing
server native hammer/contact probe. The optional client form accepts
`{animator = require(actualClient.Controllers.FriendlyNpcAnimator)}`. It creates
an untagged disposable Nyra fixture and an injected collection provider, so the
normal animator cannot acquire a second ownership of that fixture. It checks
day work, nearby visible dialogue pause, close/recovery, night rest, reduced
motion, far restoration and unchanged root. It restores its camera/Lighting/
reduced-motion settings and destroys temporary GUI/models/connections on exit.

Run only in the Controller's verified isolated Memory candidate. The dialogue
panel is a fixture, not an earned gameplay interaction. `PASS_CLIENT_FIXTURE_ONLY`
does not pass quest acceptance, multiplayer, persistence, device or art quality.
Follow with actual Nyra/Borin dialogue and the `borin_castings` gameplay route.
S17 authored/compiled this probe but has not executed it in Studio.

Separate read-only review checked clock separation, fades, cleanup and sole pose
ownership; seven Borin lifecycle tests and eight NPC contract tests passed.
Reviewer flagged missing replicated hints for the six hosts. Controller explicitly
accepted the bounded ten-Central/six-local coverage for this write scope; shared
host interaction remains a follow-up in CivicCityWorld, not a passed feature.
Current full Roblox-aware analysis exits 0 with nine pre-existing GUI `Services`
warnings. Final full-regression receipts are delivered with the source commit.

Controller review strengthened the client probe: before each reduced-motion,
far-culling and Destroy restoration assertion it now requires Work weight > .99
and an actually non-rest C0. It returns to near work before Destroy. Both probe
entry paths reject non-Studio or nonzero PlaceId/GameId before creating fixtures.
These checks are compiled locally; actual execution remains Controller-owned.

## Six civic host shared hints — source candidate

The next scoped patch adds `NpcInteractUntil` and `NpcInteractor` inside the
existing CivicCityWorld Talk distance guard. `GreetingAt` already existed; all
three now use one server timestamp. The existing open callback, 14-stud check,
NpcId, WorkMotionIdentity and stationary root are preserved. No animator, reward,
save or quest-station binding changes. This closes the source-side six-host hint
omission; shared-client behavior is still pending actual multiplayer evidence.

`tests/studio_civic_host_interaction.luau` is an isolated server fixture returning
Prepare/Verify/Destroy. It invokes the actual CivicCityWorld builder, observes
the real prompt signal and records its actual open callback. It never invokes a
copied handler or manually sets the tested interaction attributes. Geometry is
temporarily moved 50,000 studs away; the chosen player's original pivot and root
anchoring are saved. Studio and PlaceId/GameId zero are required.

Controller procedure (actual input, not a simulated signal):

1. Load the fixture in the verified isolated candidate and call it with the test
   Player. Retain the returned handle for cleanup even if a later assertion fails.
2. Call `handle.Prepare()`, focus that player's game window, press/release E once,
   then call `handle.Verify()`. Repeat for twelve cases, six near/eight-stud and
   six far/24-stud triggers, alternating for each host.
3. The disposable prompt alone has its engine radius expanded to 40 studs so far
   input can reach the application's unchanged 14-stud guard. Verify demands one
   observed real Triggered event: absence of input cannot pass rejection. Near
   cases require the right open callback, timestamp/deadline and player; far cases
   require unchanged hints and no open callback. Root and identity are checked.
4. Call `handle.Destroy()` after success OR failure. It disconnects observers,
   destroys the disposable geometry and restores the same character's pivot and
   original anchoring. An additional Prepare reports completion/counts only.

This is not travel/progression, an actual quest journey, or two-client visual
acceptance. Observer animation, second-speaker replacement, expiry/departure and
distance recovery still require the Controller's separate multiplayer run.
Independent read-only review found no actionable issue in this bounded patch.
Scoped compilation/type analysis and seven Borin/eight NPC contract tests passed;
the new twelve-case Studio fixture was NOT_RUN by S17.
## Deepforge contact adapter — source candidate (2026-10-18)

### Durn-specific client probe follow-up

Invoke `studio_borin_integration({animator=require(actualFriendlyNpcAnimatorModule),
npcId="host_deepforge"})` from the client in the isolated candidate. This now selects
a Durn-specific fixture instead of Nyra. The actual world Durn must be streamed in,
farther than CullDistance from the current camera, with BorinLocalWorkWeight zero
before cloning; otherwise it fails before creating fixtures. This prevents taking
an animated C0 as the bind pose. Close the ordinary Durn dialogue before running.

The fixture clones that actual native model, removes all inherited tags while
unparented, disables cloned prompts and places only the disposable clone near the
stationary player. It never moves the player or original NPC, and writes no profile.
One actual animator uses isolated collection signals. A unique camera render binding
after the normal camera priority holds near/far views and is unbound on cleanup;
original camera type/CFrame, Lighting.ClockTime and reduced motion are restored.

Checks include an observed animated hammer contact within .025 studs (minimum
observed error, not a maximum-error certificate), generic deadline AND speaker
selection against conflicting legacy hints, zero work/contact while paused,
recovery, active-arm preconditions before reduced/far/removal/Destroy restoration,
duplicate discovery, and a quiet interval proving no remaining pose writer after
removal/Destroy. All cloned instances and custom signals are destroyed on success
or protected-run failure. Collection removal simulates the animator event contract;
it does not prove real network streaming. Synthetic hints do not prove ordinary
interaction or multiplayer. New client fixture remains NOT_RUN by S17; local
compile/type review only. Prior server contact evidence does not certify this probe.

Foreman Durn retains `host_deepforge`, its dialogue/prompt and civic quest binding.
`BorinWorkMotion.usesForge` selects the existing forge presentation from either
original smith identity or the explicit `WorkMotionIdentity=smith_borin` capability.
The separate `interactionAttributes` policy selects legacy Borin hints ONLY for
`smith_borin`; Durn uses `NpcInteractUntil` and `NpcInteractor`, including the
latest-speaker head-attention guard. No alias becomes an NPC identity.

CivicCityWorld attaches the existing native workstation to Durn's existing smith
kit after placement/identity assignment and before tagging it for the single
FriendlyNpcAnimator pose owner. The same arm/contact solver and lifecycle now run
for Durn. Generic work does not run a second time. The root, feet, prompt callback,
timing, culling/reduced-motion restore, economy and quests are unchanged. Workstation
and hammer attachment remain model-owned; repeated attach is idempotent, animator
cleanup restores joints/disables flash, and model destruction removes native props.

Local checks: 10 pure presentation tests (including both identity namespaces with
conflicting unused deadlines), 8 NPC-life tests, scoped compile/type analysis.
These do not establish actual native contact or ordinary interaction acceptance.

Controller Studio checklist, isolated unpublished Memory candidate:

- Run `studio_borin_integration()` for the original smith, and separately
  `studio_borin_integration({npcId="host_deepforge"})` for the same native kit with
  Durn identity/capability. Each measures three contact samples, exact root and
  identity preservation, joint restoration, one workstation/tip after reattach,
  noncolliding native props and no legacy interaction hint writes. Both remain
  NOT_RUN by S17. This fixture is not the actual civic builder.
- Run existing `studio_civic_host_interaction` against actual builder with real E
  input. It now also checks Durn has exactly one workstation on reattach, other
  hosts have none, and all civic hosts retain no legacy Borin hints. Near/far
  callback tests still check the real panel and shared stamps. Always Destroy.
- On actual Durn, observe active forge contact first, then ordinary accepted talk:
  work fades, contacts stop, head attention follows the shared stamped speaker,
  and expiration/closing dialogue recovers work. Confirm competing legacy hints
  cannot extend Durn's interaction in an isolated presentation fixture. Verify
  reduced motion, far culling, untag/stream removal and controller Destroy from
  an active pose restore joints/disable flash; reload creates only one pose owner.
- Check workstation placement/ground clearance, hammer grip and tongs visually in
  Deepforge. Original smith must retain legacy behavior. Native fit, multiplayer
  speaker/expiry behavior and human art acceptance remain separate pending gates.

# Bounded speaker attention — source candidate (2026-10-17)

Fresh inspection found work fade/recovery and bounded server hints already implemented,
but neither generic civic actors nor Borin turned their head toward the speaker.
FriendlyNpcAnimator now uses its existing single pose owner to add head-only yaw.
Only the latest server-stamped interactor with a present root within 14 studs and
an unexpired shared deadline can supply a target. Local dialogue visibility cannot
select a different speaker. Targets in the front hemisphere are limited to 55 degrees;
rear, missing, distant or expired targets ease toward neutral without an atan2 seam flip.
The exponential blend clamps elapsed time after stalls. Reduced motion, far culling,
stream removal and Destroy preserve existing bind-pose restoration. No root/leg changes,
tool-arm solve changes, new bodies, assets, identities, rewards or save writes.

Two additional pure tests cover direction, rear/seam behavior, speaker switch smoothing,
expiry/missing target decay, frame-rate equivalence and invalid/stalled time. The existing
client Studio fixture now includes a head motor and synthetic shared hints to check
attention, a stale local panel against a newer unknown speaker, expiry and active-head
Destroy restoration. This is explicitly a client hint fixture, not proof of server
acceptance or multiplayer. It remains NOT_RUN by S17; Controller owns actual runtime
verification, including visual naturalness on the real modular kit, tool/foot contact,
two-client last-speaker behavior, streaming and expiry after real accepted input.
