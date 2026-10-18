# Hand probe sampling repair — native failure retained

Parent source: `9cd036c` (controller integrated as `ddcb63b`). This correction
changes the probe and this receipt only. Production controller, pose, SkillEffects,
cursor, root/character state and lifecycle implementation remain byte-for-byte
unchanged from the parent.

## Native observations reported by Control Center

- Original exact candidate, exactly one new HUD, Studio session `a302325a`:
  hand probe FAILED twice. Second diagnostic measured **0.228706 studs** position
  error and **0.222022 radians** rotation error at action age **0.102130s**.
  Root was stationary; separate cleanup readback found zero proxies.
- Controller changed only the probe: after `PreRender:Wait()`, defer once through
  a BindableEvent barrier. Same production candidate then returned
  `PASS_LOCAL_HAND_CARRIER`, RightHand movement observed, maximum position error
  **0**, maximum rotation error **0.000690534 radians**, Basic/Physical expiry and
  cancellation passed. This is controller-reported native diagnostic evidence,
  not a test executed by this worker and not a rerun of the final revised probe.

## Cause and correction

PlayerCombatController writes body joint transforms during PreSimulation. The
hand tracker copies the resulting actual hand frame in PreRender. The old probe
waited on PreRender and immediately read the carrier, incorrectly assuming that
earlier connection registration meant the tracking callback had already executed.
The controlled diagnostic supports an observer scheduling failure rather than
a demonstrated production tracking defect.

Roblox documents `task.defer` as executing at the end of the current resumption
cycle within the frame. The revised probe uses that boundary and captures both
hand and carrier atomically in the deferred callback. Callback failures propagate
through a completion barrier into the outer cleanup path. Raw-before/deferred-after
pairs expose the observer-phase difference; multiple samples exercise moving poses.
Acceptance thresholds remain **.03 studs / .03 radians**. No smoothing, tolerance
increase or production scheduling change is used to hide the failure.

Each Basic/Physical cast requires three paired samples in the .10–.30s action
window and measurable hand motion between its deferred samples (over .001 studs
or .001 radians). Static samples return INCONCLUSIVE_NO_HAND_MOTION. A read-only
PostSimulation counter verifies that no simulation step separates each pair;
event/character/carrier identity is also checked. The counter is disconnected and
the completion barrier destroyed on exit. No undocumented frame-number API or
render-priority metadata is required.

Sources checked for scheduling semantics:
- https://create.roblox.com/docs/reference/engine/libraries/task
- https://create.roblox.com/docs/scripting/events/deferred
- https://create.roblox.com/docs/performance-optimization/microprofiler/task-scheduler

The exact committed revised probe still requires controller execution and separate
cleanup readback. Alternate rig, real death/respawn, missing-hand fallback, actual
combat/device and replication inspection remain outside the diagnostic result.

Local checks: revised probe compiles, `git diff --check` passes, and
`git diff --exit-code HEAD -- src` confirms no runtime source delta. The existing
real novice cursor suite also passed during this investigation. Independent review
caught a stationary-sample acceptance gap, corrected by the per-cast moving-sample
requirement above. No full baseline, Studio mutation, push or publication occurred.
