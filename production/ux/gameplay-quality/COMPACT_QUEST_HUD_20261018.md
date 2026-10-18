# Compact quest HUD — 2026-10-18

Local visual implementation on `codex/quest-hud-polish`, base `3279e6d`.
Controller owns Studio. This handoff contains source-tested presentation and a
runnable native before/after fixture, **not observed visual acceptance**.

## Design and source comparison

Reference inspected: `design/guildborne-gui-production/03_REFERENCES/01_BRAND_UI_KIT.png`.
`docs/uat01/UI_ART_GUIDE.md`, `production/ART_BIBLE.md` and the existing UI-slice
manifest govern navy/ivory/gold/burgundy colors. The selected image sources still
have no runtime IDs. This change uses original native frames/strokes and existing
Roblox fonts; it creates no image, uploads, external font or fabricated binding.

| Actual assigned source geometry | Before `3279e6d` | After |
|---|---|---|
| 796px safe width, tracker x/width | 254.72 / 306.4 | unchanged |
| Compact root y/height | 10 / 44 | 7 / 50, within existing header y6–58 |
| 796px hierarchy | objective only; seal/ribbon/heading hidden | burgundy seal clasp, gold heading/rule, 14px objective with 32px two-line box; native open chevron |
| 320px safe width, tracker x/width | 111.2 / 92.8 | unchanged |
| 320px objective width/height/font | 80.8 / 36 / 12 | 80.8 / 38 / 13 |
| Narrow phone ornament | hidden | crest interrupts top engraving; no extra text-column inset below 170px card width |
| Ready / blocked | ready glyph hidden in compact | native check for snapshot-ready; muted unavailable interaction mark/rim/copy, without inventing a reason |

The micro crest extends above the card to approximately safe-area y3.34; it stays
inside the safe canvas, but not every decorative pixel is inside the header.
Middle-width cards use a narrower seal column; desktop retains its separate
300×96 layout. Long objectives retain original live text and ellipsis. The same
button opens the original full quest details; 320px cannot show arbitrary long
Thai/English objectives in full without sacrificing the HUD controls.

No changes to SliceUI activation/J handling, snapshot projection, route resolution,
CombatHudLayout, gameplay bindings or server logic. Ready is never inferred from
a full progress bar. Disabled does not imply a particular save/error reason.
Route unavailable remains the actual separate WaypointBeacon state.

## Validation performed

- `python tests/gui/run.py`: **59 behavior cases PASS** (12 general,16 gameplay,
  13 waypoint,6 tracker,2 menu lifecycle,10 novice). Two new tracker cases cover
  minimum phone state silhouettes and reflow preserving state; existing geometry,
  focus/cleanup, finite progress and layering tests retained and updated.
- Scoped Roblox luau-lsp: current QuestTrackerView and native fixture PASS against
  default-project sourcemap. Five affected/test Luau files compile.
- Isolated Rojo build with explicit existing `--rojo`: PASS; one LocalScript,
  zero server Scripts or remotes; exact baseline bytes verified against Git.
- Forge doctor/plan-contract validate and `git diff --check`: PASS.
- Independent source review by `quest_hud_audit`: no production blocker. Its
  fixture currency-reservation correction was applied (actual x20, not x12).
- Studio render/TextFits, native clicks/J/gamepad/touch and human visual review:
  **NOT_RUN**. Local geometry checks do not certify glyph fit or visual quality.

## Before/after native fixture

```powershell
python tests/gui/build_quest_hud_review.py --rojo C:/Work/MySelf/Guildborne-controller/.tools/rojo/rojo.exe
```

Artifact: `build/quest-hud-review/GuildborneQuestHudReview.rbxlx`

SHA256: `129308bcec606a01999947e1d727473d58313d2147081cadcccccd5f5da3e3aa`

Baseline source SHA256:
`f66708c671845ecb601732011f94983900bb199e67fd6738d3e2c4bc0bb1b079`.

Open in disposable Studio and Play. Toggle Before/After, five dimensions
(796×674,320×568,320×240,390×844,1366×768), EN/TH, long copy, Progress/Ready/
Blocked/Empty, route-unavailable and focus. **1:1 is the exact preset comparison**;
scroll to inspect. Fit changes effective responsive dimensions and is labeled
accordingly. Reservation blocks are synthetic, not a full game screenshot.

Logs: `QUEST_HUD_NATIVE_OBSERVATION`, `QUEST_HUD_TEXT_NOT_FIT`,
`QUEST_HUD_ACTIVATED`; ScreenGui exposes `ActivatedCount`. Delayed text observations
use a redraw-generation guard. The fixture uses actual tracker/waypoint modules;
all state is synthetic and activation records a counter only. No screenshots or
native observations have been invented or included as evidence.

Controller next: compare exact796 and320 1:1 EN/TH captures, verify readable short
objectives and explicit long-copy truncation, ready/progress/blocked/focus states,
route-unavailable coexistence and ordinary activation in the integrated game.
Final human art and physical-device acceptance remain external. Worker stops
after this committed handoff; no next wave or plan/scope changes.
