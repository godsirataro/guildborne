# Greenwood scout / captain presentation

Base: `9c34435`; branch: `codex/greenwood-enemy-art`.
Controller approved a bounded original native art and motion wave. This is source
implementation plus local checks, **not Studio, device or human art acceptance**.

## Problem and resulting behavior

The existing regional bridge publishes EnemyActionAt after Basic/Impact. Greenwood
previously used generic ActionPose, which starts another windup before its .24-second
contact marker. The captain's real RegionalTelegraphAt/Until warning was also not
read by that generic branch. Existing correct ground footprints remain intact.

Only `greenwood_scout` and `forest_captain` with `GreenwoodForgedV1` use the new
presentation. Confirmed strikes immediately enter a .48-second follow-through,
decaying to the ready stance. Captain anticipation requires Windup, a known
Antler Cleave or Root Burst name, a positive finite elapsed start and a finite,
unexpired end later than start. Cleave raises and twists the sword side; Root Burst
braces behind the shield and lowers the torso. Warning cancellation or expiry
removes anticipation on the next simulation update. Both impacts share a recovery
pose after the bridge clears TelegraphName; no stale pattern cache is retained.

Future event clocks are filtered independently so they cannot mask a valid hit.
Old absolute event times cannot restart motion. DamageCueAt alone drives the brief
recoil; healing FeedbackAt does not. Idle breathing is disabled by reduced motion.
Locomotion blends into rest; only the six existing Motor6D transforms move, with
the existing distance cull and death/removal/tag removal/Destroy reset behavior.

## Preserved contracts and source decision

No changes to IDs, authority, root, scale, hitboxes, profiles, timing, rewards,
ActionPose, SkillEffects, projectile plumbing, or runtime asset IDs. The regional
root remains one stud cubed at authored pivot +Y3 with PivotOffset -Y3. Original
Head and four upper-limb socket records stay first and unchanged. Other ten
templates, including the prior Ironveil pair, retain their existing art routes.

Actual server patterns remain Antler Cleave (cone radius10, half-angle55,
1.1-second warning/1.5 recovery) and Root Burst (circle radius8, 1.5 warning/2
recovery). Scout tuning remains 135 health, 12 power/speed, range5, interval1.6;
captain remains 650 health, 24 power, speed10, range10, interval2.

Reviewed local source assets remain available in `assets/production/enemy-slice`:
Tribal and Monkroose glTFs, atlas, license, intake and review records. Existing
CC0 intake identifies archive SHA256
`61d7144dd8dfa05433e43c48cf3c68edd0a92be218fd29623114056654a79181`.
This wave did not download, import or revalidate that archive. EnemyVisualAssets
still says UNBOUND/disabled with nil runtime IDs; its 43-joint clips and contact
frames are not a playable replacement. This wave uses original native geometry
without a Blender dependency. No new effects, lights or per-frame instances.

Scout uses 58 art parts (65 BaseParts with six carriers and one existing root);
captain uses 70 (77 total). Each has six existing motors and one weld per art part.
Both stay under the 90-art-part cap. Scout has a layered hood, leather equipment,
wrapped sword and asymmetric bracer/pouch. Captain has branching wooden antlers,
leaf mantle, sword and layered bark shield with an original tree crest. The
existing .82/1.45 authoring dimensions remain baked into geometry; Model scale
is unchanged. Wedge/block parts use wood, fabric, leather and metal materials.
These counts are not physical-device performance measurements.

## Local evidence and remaining acceptance

- Actual AdventurePatterns, AdventureBrain and AdventureLifecycle suites plus
  Ironveil and Greenwood identity/tuning checks: **18 PASS cases**.
- Existing enemy_quality: **two PASS groups**, including Tower compatibility.
- Both changed runtime modules pass mapped Roblox luau-lsp analysis (only the
  tool's disabled watched-file registration warning). Both runtime modules plus
  the domain harness and native probe compile. `git diff --check` passes.
- Bridge, articulation, profiles, patterns, ActionPose and SkillEffects have zero
  diff. Original definition block and prior Ironveil helper remain unchanged.
- Independent reviewers found no concrete blocker in the art or animator; root
  separately reviewed the native probe. Forge doctor, plan and contract validation
  ran; validation passed for 70 tasks/31 skills, not game acceptance.

`greenwood_probe.luau` is for a controller-owned, unsaved Studio CLIENT. Its header
lists exact source copies, including BaselineAdventureEnemyKit from `9c34435`.
It uses a private tag, checks original sockets and unaffected template signatures,
root invariance, part/weld/motor budgets, real profile/pattern contracts, immediate
follow-through, actual-duration warnings, cancellation, stale/future clocks,
damage versus healing, reduced motion and cleanup. Optional bounded front/side
gallery shows actual source dimensions. This worker does not execute Studio.

Controller acceptance must inspect grips, shield/sword clearance, antlers,
ground contact and silhouette, then actual continuous Greenwood combat with the
player plus five heroes and both captain phases. Warning readability amid party
effects, device performance and human art approval remain separate. Controller
owns the combined baseline; this worker does not duplicate it. No publication,
push, PR, upload, spending or production-data changes.
