# Bounded party readability wave

Status: implemented locally, independently reviewed, fixture BUILT_NOT_STUDIO_TESTED.

Production delta: tall cards retain their 68px height, 48px portrait and 12px HP; names increase from 13px to 15px with a 36px two-line lane. Name bounds end at y40; HP starts at y42 and ends at y58, above the y60 health bar. Compact/short typography and all CombatHudLayout geometry are unchanged. No controller/navigation/server/profile/asset-ID changes.

Native fixture now has selectable logical safe-area presets 390x844, 320x760 and 1366x768. Its toolbar is outside the simulated game canvas. The canvas uses an explicit UIScale to fit the actual window, capped at 100%; the displayed percentage means a scaled screenshot is not a physical-size readability or device test. Native dummy portraits, six identities and HP are simulated. Selecting a card updates its ornaments, burgundy background and synthetic selected-health region.

Surrounding synthetic reservations expose the controller geometry: top HUD strip, right attack/skill pad using actual CombatChrome, orders strip, selected-health strip and map button rectangle. They do not implement the real controllers or full HUD interactions. All regions are displayed concurrently as a conservative layout review. Existing map/skill coordinates overlap in both portrait presets; the fixture labels this explicitly. Actual concurrent visibility requires controller-owned Studio verification. No navigation fix is included in this scope. Roster remains separate from these regions. The map reservation is a translucent label, not an interactive blocker.

Validation actually run in this worktree (base b9d0029):
- `python tests/gui/run.py`: 44 local cases passed: 12 core + 14 gameplay + 12 waypoint + 4 tracker + 2 lifecycle. Controller reports its newer integrated runner has 45 (13 waypoint); these are different branch suites, not conflicting counts. Do not report this local run as the controller's 45-case run.
- Rojo fixture build passed; builder XML checks confirm one LocalScript, zero server Scripts/remotes.
- Scoped luau-lsp analysis passed for CombatChrome, CombatHudLayout and fixture; fixture analysis repeated after the review correction.
- `git diff --check` passed.
- Independent reviewer found no blocking issue; its stale synthetic selected-HP finding was fixed.
- No full baseline rerun, Studio call, screenshot, publish, push, merge or spending.

Artifact: `build/party-roster-review/GuildbornePartyRosterReview.rbxlx`.
SHA256: `0ac0894fa0bc83915bbaecbe10e2290f65f176ec1fd747942454aca718f9e387`.
Rebuild: `python tests/gui/build_party_roster_review.py`.

Controller handoff: open fixture and Play; use the three preset buttons and EN/Thai toggle. Output logs TextFits after preset/language switches with logical canvas dimensions and render scale. Check all six names, HP/bar separation, selection and surrounding reservations; record truncation rather than assuming all names fit. At 320x760 the name lane remains 108px wide; 15px glyph fit is unproven. Check actual full HUD state separately for map/skill overlap. Prior controller-reported 60 TextFits observations and six successful clicks belong to the previous 13px fixture; they do not accept this revision. Physical-device and human readability approval remain external.
