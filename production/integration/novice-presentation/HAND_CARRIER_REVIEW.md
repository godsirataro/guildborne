# Novice / Archive hand carrier

Base `39fdec4`, branch `codex/novice-hand-effects`. Source review candidate.

The actual NoviceTrialController created a proxy containing only VisualOrigin.
SkillEffects looks for RightHand or Right Arm on that same model when adding
Basic/Power Strike trails, so the proxy could never supply a hand. Existing body
pose is separately driven by PlayerCombatController; it is not replaced here.

## Change

For each accepted event on a live local character, capture that exact character.
Warrior/Knight also capture the existing R15 RightHand or R6 Right Arm if present.
Create one invisible, anchored, noncolliding/nonqueryable/non-touching RightHand
part on the local proxy, positioned before SkillEffects is invoked. One controller
PreRender connection copies only the real hand's CFrame to this carrier. Existing
SkillEffects owns trails/attachments on the carrier; nothing is parented to or
stamped on the real character. No joints, character root or server state are moved.

Missing hand on a live character uses the existing origin/target fallback. A hand
appearing later does not replay or bind the consumed action. Missing/dead bodies
consume valid timestamps but do not start presentation, preventing respawn replay.

Captured stamp, character and hand identity are checked each render. Server clear
or replacement, character replacement/death, hand replacement/removal, or arena
removal clears the proxy event and destroys the carrier. Arena replacement resets
the existing cursor. Duplicate/stale/future/nonfinite stamps still use the unchanged
cursor and ActionTimeline policy. Fresh actions can bind a new character/hand.

Carrier expiry at .62s destroys only the carrier and its children, preserving the
proxy stamp so longer spell tails are not truncated. No queued carrier timers can
erase a subsequent event. HUD destruction disconnects the render connection and
cleans the presentation. Cost: at most one tiny carrier, one render connection per
controller, and the existing bounded trail/attachment allocation.

## Checks / review

- Existing `tests/novice_action_presentation.luau` PASS: real cursor and clock,
  delayed payload, invalid/reordered/future/stale/duplicate, cancel/reset isolation.
- Changed controller compiles and passes mapped Roblox-aware luau-lsp analysis,
  no type diagnostics (tool watched-file registration warning only).
- Native hand_carrier_probe compiles; execution remains NOT_RUN here.
- `git diff --check` PASS. SkillEffects, PlayerCombatController, shared cursor,
  server/damage/reward logic and audio assets are unchanged.
- Independent enemy_export_review found no concrete blocker in controller diff;
  root reviewed the separate probe. Real trail alignment remains a Studio gate.

## Controller probe

Run `hand_carrier_probe.luau` on the local client of an unsaved isolated Studio
session after exactly one normal controller/HUD bootstrap. It refuses active
Novice/Archive arenas and existing proxies. Use an idle actual living character
within detailed camera distance. It creates only synthetic arena attributes,
never remotes, character mutations, health edits, teleports or camera changes.

Checks actual hand/carrier transforms across frames, trail attachment ownership,
physical flags, duplicate identity, cancellation/replacement/removal and Basic /
Power Strike carrier expiry. Reports whether actual hand movement was observed;
sampling a static hand is not moving-contact proof. Root movement or character
replacement during the probe is inconclusive. Missed release windows are also
inconclusive because the existing .1s event polling can observe release too late.

Actual R15/R6 visual alignment, real death/respawn, missing-hand fallback and
HUD-destroy cleanup need native acceptance. The nonmatching rig is explicitly
untested by a single-character probe. No server-side replication inspection,
ordinary combat, device, audio or human-art acceptance is claimed. Controller
owns Studio and combined checks; no Blender, push, PR, release or spending used.
