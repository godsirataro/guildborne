# Compact HUD clearance

Fresh worktree: `C:/Work/MySelf/Guildborne-compact-hud`, branch `codex/compact-hud-clearance`, base controller commit `4049a84`. Previous UI worktree preserved. Shared v4 ledger used. No Studio access, push, PR, merge, publishing, spending or full-baseline rerun.

## Implementation and tradeoffs

CombatHudLayout supplies shared roster, pad, map, orders and health rectangles. PlayerCombatController consumes the pad/orders/health rectangles; CityNavigation consumes only map placement and compact label visibility; WaypointBeacon reserves the same rectangles. Server commands, routes, targets, anchors, quest state and navigation input behavior are unchanged.

- 796x400: Map moves into the free center gap at x358,y64,130x44 between roster and attack pad.
- 390x449: collapsed actor and Next Hero remain at y64/112; Map moves below them to x8,y164,96x44. Orders and health retain separate bottom lanes.
- 320x240: Map stays below actor selection; orders move below the right pad to x120,y180,192x44. Six existing commands remain in the horizontal ScrollingFrame with its original 660px canvas and 106px command buttons. The 360px maximum-width constraint remains respected.
- Compact height below 360 uses explicit short mode. Wide short mode displays six actors in three columns; collapsed mode retains selected actor plus cycle access to the party. Compact skill dimensions remain unchanged.
- Only the redundant bottom health strip is hidden when short height is below 280; actor-card numeric HP and bar remain. This also folds the strip's extra class/status/XP text at these sizes.
- Floating DistrictName and WaypointDirection labels are suppressed in compact mode because their legacy coordinates cover skills/orders. Map access, selected destination state and quest-beacon routing remain intact. This removes ambient location/bearing text from the compact world view; no command is hidden. Existing noncompact label presentation is unchanged and is not accepted by this compact-only clearance check.

All new CityNavigation resize listeners use the existing connections collection and destruction cleanup. No new production input listener was introduced. Existing six-command horizontal scrolling and selection behavior is preserved, not replaced by an abbreviated command list. Touch/gamepad reachability still needs real engine verification.

## Evidence

- `python tests/gui/run.py`: 47 simulation cases passed (12 core + 16 gameplay + 13 waypoint + 4 tracker + 2 lifecycle).
- The shared-rectangle regression checks 187 width/height combinations from 320x240 through 1366x844, including compact/portrait/dense/health-visibility boundaries: bounds, pairwise separation, minimum button space, order width constraints and cycle space. This is numeric geometry evidence, not physical input or glyph-fit evidence.
- Scoped luau-lsp passed for CombatHudLayout, PlayerCombatController, CityNavigation, WaypointBeacon using default-project sourcemap; fixture scoped analysis passed using its own sourcemap.
- Independent review found floating CityNavigation labels still overlapped the new command arrangement. The compact-only presentation policy above addresses that finding. No navigation-state mutation was added.
- Rojo built the fixture; XML safety checks confirmed one LocalScript and zero server Scripts/remotes. `git diff --check` passed.

## Native fixture handoff

`build/party-roster-review/GuildbornePartyRosterReview.rbxlx`

SHA256: `23988eb2d5633b6cd79e920d896513b0db60164b88069067736068d9784afa0e`.

Use Size arrows for 796x400,390x449,320x240,600x320,390x844,1366x768. Use 1:1 / Fit and EN/Thai toggles. The logical canvas dimensions and actual display scale are explicit. Identities, HP, portraits and command outcomes are synthetic. Actor selection and Next Hero work locally; attack/skills/map and all six scrolling orders increment `FixtureActivations` attributes and print `SYNTHETIC_HUD_CLICK`. These synthetic callbacks prove only fixture input when actually tested, not server dispatch. No fixture runtime clicks or TextFits are claimed by this worker.

Controller should verify collapsed cycling reaches all six actors, scroll to and activate each of six orders (including Defensive), click map/attack/all skills, resize across thresholds, and destroy/reopen without duplicate listeners. Verify actual live HUD layering in non-quest navigation as well as tracked quests. Gamepad navigation, physical touch/performance and human readability remain NOT_RUN here. Preserve long-name truncation observations on compact cards; do not claim full name fit from bounds tests. Existing waypoint card may fold when no lane is free, while all essential controls and map remain reachable by design.
