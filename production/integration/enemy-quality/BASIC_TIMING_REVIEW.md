# Warrior Basic timing repair

Base: `9ae9662`, branch `codex/novice-motion-review`.

Only Warrior + Basic is routed through the new local choreography. Release uses
ActionTimeline.Release (.10), cosmetic contact uses Contact (.24). Initial .15
observations retain contact only; initial .30 observations emit neither. A queued
release delayed until contact also skips its sweep. Damage remains immediate on
the authoritative server; these are presentation markers, not hit confirmation.

The old modest 2.8-radius sweep and four-part weak impact are retained. Maximum
parts per action: 16 desktop / 12 Low or touch, subject to existing shared 48/30
detail caps. One optional trail and two attachments are cleaned with their action.
Power Strike, Fireball, Knight, other abilities and shared budgets are unchanged.
No Novice proxy hand carrier, audio or body pose changes are included.

Accepted stamp and generation guard delayed markers. ActionAt changes/clear,
CombatHealth death, Humanoid.Died and removal clear active geometry, attachments,
trail and listeners. Absolute .62 expiry also closes late/skipped actions. The
existing budget accounting conservatively retains slots until original part TTL
after cancellation; no early slot reuse or cap increase was introduced.

## Focused local checks

- `luau.exe tests/action_timeline.luau`: PASS, six printed groups, including fresh,
  .15/.30 and stalled-release Basic windows. Existing marker cancellation,
  exactly-once and server Power Strike rejection checks also pass.
- `luau-compile.exe --null` on SkillEffects, action_timeline and basic_probe: PASS.
- Rojo sourcemap + `luau-lsp analyze --platform=roblox` with Roblox definitions on
  SkillEffects: PASS, no type diagnostics. Automatic watched-file registration
  warning is tool configuration only.
- `git diff --check`: PASS.
- Initial sourcemap command failed because this new worktree had no build folder;
  the ensuing analyzer lacked DataModel mapping. Created build and reran those
  two focused checks successfully. No full baseline rerun.
- Independent source review by enemy_export_review: no concrete blocker found;
  verified branch isolation, timing, cancellation and part limits.
- Probe review caught shared-scene collection and insufficient cancellation-phase
  evidence. Corrected with empty-space isolation 10,000 studs above the camera,
  camera restoration, and explicit stage/live-object checks before cancellation.
  Updated probe compiled successfully; execution remains pending.

## Controller handoff

`basic_probe.luau` requires the actual full-game client modules in a quiet unsaved
Studio session. It invokes no remotes. Run after source sync. It covers fresh,
.15, .30, duplicates, High/Low, cancellation before release/during sweep/after
contact, replacement, nil clear, death, removal, new replacement playback,
expiry, part counts and nonphysical geometry. Missed phase windows report
INCONCLUSIVE rather than timing acceptance. Touch counts follow actual
TouchEnabled; desktop Low is not physical mobile evidence.

Probe is compiled only: Studio execution, dummy 120→110 exactly once, visible
contact/readability, physical-device performance and human acceptance remain
PENDING. The controller owns Studio and the combined baseline. No Blender,
uploads, runtime IDs, publication, push or PR were performed by this worker.
