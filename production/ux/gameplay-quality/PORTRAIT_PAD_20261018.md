# Portrait Map / Attack separation

Status: scoped implementation complete; integration requires controller-owned WaypointBeacon update. Not a passing full GUI acceptance packet.

Controller explicitly expanded this worker's exclusive scope to the single PlayerCombatController layout-position line. Before edits, `git diff --no-index` against `C:/Work/MySelf/Guildborne-controller/src/client/Controllers/PlayerCombatController.luau` was empty (exit 0). Raw hashes differed only because of line endings. Source also matched controller-reported integration commit 2a84b19. The primary C:/Work/MySelf/Guildborne checkout is an older branch, not the controller's source.

`CombatHudLayout.padTop` is now 116 for noncompact portrait layouts and 64 otherwise. PlayerCombatController's top-aligned buttons and the native fixture consume this field. Centered desktop placement and compact landscape/collapsed placement are unchanged. Portrait Map ends at y108; Attack starts at y116, leaving 8px. No map hiding or combat disabling. No WaypointBeacon, CityNavigation or other navigation source edited.

Checks:
- `python tests/gui/run.py --suite gameplay`: 15 focused cases passed, including portrait 390x844 / 320x760 / 360x640 / 390x570 / 499x760, compact landscape/collapsed boundaries and desktop placement. The new optional runner filter defaults to the unchanged full suite.
- Scoped luau-lsp analysis passed for PlayerCombatController and CombatHudLayout with default-project sourcemap, and for the disposable fixture with its fixture sourcemap.
- Rojo fixture build/XML safety checks passed; `git diff --check` passed.
- Independent reviewer found no additional issues and confirmed the known dependency below.
- The full GUI run FAILED at `Waypoint overlaps combat skill pad at 390x844`: updated waypoint regression now measures actual padTop, but WaypointBeacon still computes its reservation from hardcoded 64. Do not suppress or revert this assertion. Controller explicitly owns the WaypointBeacon change after this worker releases the lease. Re-run the full suite after that update; expected totals differ between this older worker branch and controller's newer waypoint suite.

Current fixture: `build/party-roster-review/GuildbornePartyRosterReview.rbxlx`.
SHA256: `36e282876d59bc18b7554565cfab29866fef1f9c1c1061dfae26a8cd4c6ebca0`.
This supersedes the fixture hash and concurrent portrait map/pad overlap described in PARTY_READABILITY_20261018.md. 15px long-name TextFits, actual control clicks and full-HUD coexistence remain Studio NOT_RUN for this revision; scaled fixture screenshots remain distinct from device proof.

Handoff order: integrate readability commit df3627c if not already integrated; integrate this pad commit; update WaypointBeacon pad reservation to use combat.padTop; run full GUI tests; perform controller-owned native Studio checks. No push, merge, publish or spending by this worker.
