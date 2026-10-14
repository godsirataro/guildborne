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
