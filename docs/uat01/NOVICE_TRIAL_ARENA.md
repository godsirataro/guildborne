# Playable isolated novice trials — 2026-10-04

The five root-class trials now use the game's shared damage, targeting, ability and cooldown rules. The server samples actual avatar position, checks isolation and life, commits orange warning positions for 1.2 seconds, and measures successful dodges. Trial health and borrowed level-10 stats are temporary; the adapter never changes saved XP, class, equipment or rewards. The clock starts on the first input so preparation does not consume health.

## Actual native input evidence

| Class | Result | Final trial HP | Required lessons | Accepted result deliveries |
| --- | --- | --- | --- | --- |
| Warrior | Won | 57/57 | 3 basic hits, dodge, victory | 1 |
| Knight | Won | 67/67 | 2 taunts, 2 basic hits, victory | 1 after 2 attempts |
| Archer | Won | 49/49 | 3 ranged hits, dodge, victory | 1 |
| Mage | Won | 47/47 | 3 skill hits, dodge, victory | 1 |
| Priest | Won | 41/51 | Restore 40 actual HP, dodge, victory | 1 |

These used actual F/Q keys and physical avatar movement in the owned memory-only Studio place. Eligibility was a temporary level-10/classless fixture. No tool injected hits, damage, health, XP or victory. This is not a saved-profile Chapter 00 completion or human UAT. Mage's earlier reactive attempts failed during tool latency and pauses; the successful run used continuous W/D/S/A movement. Archer also required earlier input/camera preparation fixes. The retained failure records must not be counted as wins.

The Knight completion callback deliberately rejected its first delivery. The arena retained the stable receipt and retried, producing one accepted result. Persisted transaction acceptance is covered separately by domain tests, not by this callback fixture.

Evidence: `validation-novice-archer-arena-live.json`, `validation-novice-arena-four-classes-live.json`, `validation-novice-mage-arena-live.json`. The middle file includes the failed Mage run; the last file is its successful rerun.

## Presentation and source assets

`NoviceTrialController` shows owner-only health, localized lessons, ready/failure/victory, cooldowns and clickable F/Q controls. Native prompts failed when the sentinel left the camera view, so controls now use a scoped Basic/Ability/Return RemoteEvent with owner/type/rate validation and server-sampled range/cooldowns. Clients cannot submit damage, XP, progress or results. Actual clicks cast all five skills. The Thai Mage skill/leave flow restores the original position and removes the arena, proxy and HUD. The regular HUD hides during trials. Thai Priest text fits 180/220/250-pixel panel fixtures; real devices remain open.

Shared class VFX and R6/R15 poses follow successful server action stamps. Five native casts produced noncollidable effects; cleanup left zero effects/proxies. AnimationConstraint motion was observed during all five casts, including normal locomotion; this does not establish artistic pose quality. Audio hooks await Sound IDs. References: [Roblox remote events](https://create.roblox.com/docs/scripting/events/remote), [server boundary validation](https://create.roblox.com/docs/scripting/security/client-server-boundary).

Original Five Disciplines concept is saved with its exact built-in prompt. The 96×96-stud native/Blender kit has 81 parts / 972 triangles, four editable groups and ten round-trip-verified exports. The dynamic orange warning is additional geometry. Floor and pillars collide; decorative joints, sentinel and patient do not. Mage won again with final art, camera-independent input and VFX/pose bindings at 47/47 HP and one accepted result: `validation-novice-final-art-combat-live.json`.

## Validation and remaining work

498 domain tests passed, including combat, receipt recovery, manager lifecycle, input owner/rate validation and 5,000 market orders with zero invariant violations. Strict/compile and main/offline builds pass at 214 runtime scripts. Default runtime still starts legacy profiles. The separate memory-only Novice project now binds the full course; one actual six-chapter Mage/Knight rescue journey passed at revision28. See NOVICE_COURSE.md.

`NoviceReceiptAdapter` freezes one observation, pins its profile session and never rebases an uncertain write. A real PlayerDataService harness recovers a lost acknowledgment once without granting XP/Gold. `NoviceTrialManager` bounds arena slots, retains pending victory delivery, rejects mismatched results, frees slots on cancellation/session loss and notifies once. Manager lifecycle tests are synthetic; actual course registration and Mage receipt delivery also passed in the full journey.

Remaining: broader class/branch/founder native journeys, retry entry/range feedback, borrowed weapon appearance, motion/audio polish, real devices/multiplayer isolation, persistent reconnect, cloud import and human UAT. No final balance, production readiness or popularity claim is made.
