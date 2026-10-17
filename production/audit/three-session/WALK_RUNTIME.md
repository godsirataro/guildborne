# Corrected enemy Walk runtime — 2026-10-17

S15 source 9da9d61580ceaa1d0cba8e781881ac063bf6bddc integrated as fab41b2 after independent review. The copied Walk action changes only LowerArm.R rotations at frames 25–30. Geometry, binds, weights, translations, feet trajectories and six other clips retain their reviewed baseline. Endpoint continuity is corrected; angular velocity continuity and perceived smoothness are not fully accepted.

Disposable Studio b3360a75-c505-4b71-8a7c-5b1364c96b4d loaded build SHA256 7af909f8898130a78dc6a564538278e6bd89145b74764cebe0f2994462d1c26c. Enemy1 data SHA256 551cb55ee4f15ada14d8936483c75be5bd2a613e0336e0cb9be23c075a7be486; Enemy2 74b7d89ade3eedc6604710a4604e3178dd34098c591066587a2960064d22eac0. These were checked before Play.

A client-only fixture used the actual NativeEnemyPreview runtime with both enemy data modules, a temporary floor, and RenderStepped. It played Walk for 3.2 seconds (over three one-second cycles), then Idle, HitReact and Death, while translating and turning both preview roots. Every frame checked finite bone transforms. It does not test server combat selection, animation networking or normal enemy movement.

- First run: 331 frames, 5.5160871 seconds; Walk 192, Idle 29, HitReact 43, Death 67.
- Second run, read back after continuation: done=true, 331 frames, 5.516526199999134 seconds; Walk 192, Idle 30, HitReact 42, Death 67.
- First capture mistakenly showed the player because the game camera replaced the fixture camera. Subsequent explicit camera captures showed both enemies during early Walk from behind and final Death from the side. These are inline stills, not continuous motion recordings or proof of foot-contact quality.

Cleanup invoked both runtime handles' destroy methods, disconnected the fixture, removed its module and floor, restored 11 ScreenGui enabled states and the saved camera state (Custom). Readback confirmed floor and module absent. Earned gameplay Studio a6d25956 was untouched.

Remaining: evaluate continuous motion/foot contact visually, residual angular-speed seam, actual combat playback under ordinary input, multiplayer and device performance. No Roblox uploads, published IDs, player progression changes or human art approval are implied.

Current integrated local baseline completed exit0:897 tests,381 strict Luau files and build/compile/sourcemap checks passed. Raw output: build/controller-walk-integrated-baseline.log. Nine pre-existing Services UnknownGlobal test warnings remain. Studio role validation passed; stale generated NPC adapters caused initial verify failure after the civic plan update, then regeneration and verification passed all98 outputs. This is tooling evidence, not additional runtime acceptance.
