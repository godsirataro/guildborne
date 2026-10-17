# Native Mage Fireball presentation — 2026-10-17

Source candidate; Studio motion, audible playback and device performance acceptance
remain pending. Existing `SkillEffects` remains the sole effect owner. This change
uses original native geometry choreography and existing engine fire texture;
no assets, sounds, external generators or paid providers were added.

## Behavior

Only detailed base Mage/Magic changes. The accepted server `ActionAt` observation
still gates entry. At anticipation, six/eight small orange motes converge on a
small core1.4 studs ahead of the caster. The projectile starts at that same point,
travels linearly with a short trail, and resolves into a brief core plus outward
embers. There is no opaque blast disk, smoke cloud or new light. Existing Area,
class-path, compact/Low and boss telegraph behavior remain in their owners.

Release/impact presentation markers stay at0.12/0.30 seconds. An observation
after release skips travel and retains only a still-future impact. If an already
scheduled release callback runs late, travel lasts only until the original impact
deadline; at/after that deadline no projectile is created. These markers do not
change when the server applies damage or grants anything.

| Allocation upper bound per detailed cast | Desktop | Touch |
|---|---:|---:|
| Charge Parts | 9 | 7 |
| Travel Parts | 2 | 2 |
| Impact Parts | 8 | 6 |
| Total Parts allocated across all stages | 19 | 15 |
| Emitted particles across both emitters | 11 | 7 |

These are source maxima, not measured device peaks or FPS. Shared48/30 detail,
16 primary and16 telegraph caps still admit each Part. Global0.75s detailed-cast
spacing and55/100stud detail/cull distances remain unchanged. Low uses existing
compact geometry with no new detailed particles. Particle rates are zero and
lifetimes at most0.28s; the two emitters and one trail are children of bounded Parts.

Action replacement, nil action, health death, Humanoid death and workspace removal
destroy this cast's active Parts and disconnect its listeners. An absolute0.85s
expiry also cleans up casts whose future markers are skipped. Distance is checked
at admission and new-stage creation, not continuously after impact. Existing
counter release deadlines remain conservative after early destruction, so capacity
cannot be oversubscribed by cancelling repeatedly.

## Validation and limits

`tests/action_timeline.luau` executes the actual injectable presentation scheduler,
including delayed release at0.20, rejection at0.30/0.31, and late initial observation.
Its existing rejection, duplicate, cancellation, expiry and five-actor timing cases
also passed. Source compiled locally. Independent review found no correctness
blocker and prompted the shared charge/travel origin fix.

`fireball_probe.luau` is a controller-run local CLIENT probe against actual
SkillEffects, not a mock runtime. It is **NOT_RUN** here. It creates only disposable
presentation models and no remotes. It checks stages, budgets, stale/duplicate
events, cancellation/death/removal, TTL, distance and Low fallback. It does not
claim observable emitter emission counts, listener counts or physical-device FPS.

The full baseline in `fireball-baseline.log` exited0:899 tests, Rojo build,
analysis, compilation and repository/built-place checks passed. Existing warnings
for globals in unchanged `tests/gui/behavior.luau` remain in the raw log; this is
not a zero-warning claim. The5000-order synthetic market load reported zero
invariant violations, not live cross-server acceptance. Forge validation and
Studio router validate/verify passed (68 tasks/33 roles/98 generated adapters).
Visual inspection must use normal player input as a separate test:
ensure the hot core and trail remain visible in world lighting, the target silhouette
and boss warning stay readable, and near/far/five-companion scenes remain clear.
The existing original shockwave atlas in `assets/uat01/vfx-native` remains unbound;
this change does not pretend that a local texture file is a Roblox runtime ID.
