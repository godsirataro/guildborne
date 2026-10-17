# Six-actor roster review

Status: local implementation and disposable fixture built; Studio and device acceptance NOT_RUN.

Tall portrait safe areas (width <500, height >=760) and desktop safe areas (width >=900, height >=640) now use 68px cards with 74px stride. Desktop width is 224px; portrait width is capped at 232px and reserves the skill column. Names have a 34px two-line lane, HP a separate 16px lane with 12px text. Short layouts remain unchanged. No controller, navigation, server, asset-ID or commerce changes.

Validation performed:
- `python tests/gui/run.py`: 44 simulated GUI behavior cases passed, including six-card geometry at 390x844, 360x800, 320x760, 900x640 and 1366x768. These assert rectangles/state, not rendered glyph fit.
- Native fixture built through Rojo; XML inspection asserts one LocalScript, zero server Scripts/remotes.
- Luau compilation passed. Scoped luau-lsp analysis passed for CombatChrome, CombatHudLayout and the fixture, running from build/party-roster-review with its relative sourcemap. Initial root-relative and Windows extended absolute source maps failed path resolution; correcting the analysis working directory resolved this.
- Independent read-only agent review found no blocking production issue. Its fixture background-selection correction was applied to match PlayerCombatController.

Build: `python tests/gui/build_party_roster_review.py`.
Output: `build/party-roster-review/GuildbornePartyRosterReview.rbxlx`.
SHA256: `86d79948823c8d18da36de4fd4225b94210098712a4caa131e58e8502114a9a2`.

Open the file locally in Studio and Play. Review desktop and 390x844 emulator settings, recording the actual safe-area dimensions printed at the top (viewport dimensions may differ). Click each of six actors to verify selection rail/gem/burgundy background. Toggle EN/TH at the bottom; Output records actual TextFits per actor after each language change. Check name wrapping/truncation, separate HP, low/zero health, and native dummy portrait bounds. Very long names may still truncate. Dummy identities/health/portraits are explicitly simulated; this fixture does not establish live five-hero integration or physical-device performance. It targets tall layouts, not compact/collapsed layouts. No screenshots or Studio results are claimed. Controller owns Studio follow-up.

No full baseline rerun, push, PR, merge, publish or spending in this bounded wave.
