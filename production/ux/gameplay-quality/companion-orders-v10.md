# Companion command dock — 2026-10-20

Source candidate based on `bbf8bf7`, branch `codex/companion-orders-v10`.
Worktree: `C:/Work/MySelf/Guildborne-companion-orders-v10`.
Studio is controller-owned. This worker did not call Studio, Blender or a paid
provider, push, publish, create a PR, or change server/gameplay rules.

## Problem and implementation

The old CompanionOrders ScrollingFrame had a 360px maximum viewport and a 660px
canvas. Hold occupied x330–436; its center was outside the visible viewport at
the initial scroll position. A coordinate click there was a world click, not a
correct activation of Hold. Existing `Activated -> send("Hold")` was correct;
the earlier synthetic party report already recorded accepted Hold commands.

The new reusable native CompanionOrders component shows all six existing actions
without scrolling. Focus, Regroup, Retreat and Hold have primary gold borders;
Balanced and Defensive remain immediately accessible with quieter borders.
Selected command/preset styling comes only from replicated actor attributes.
Name and keyboard/gamepad hint occupy separate text lanes. Inner grid navigation
is explicit; nil outer neighbours leave navigation to the surrounding native HUD.

Phones below 500px wide and at least 380px high use three columns and two 48px
rows. Other layouts use six columns of at least 44px targets. The shared
CombatHudLayout supplies the whole dock rectangle, including waypoint avoidance.
Phones at least 500px high retain 112px below the health strip for native touch
controls. To fit the larger dock, expanded phone roster starts at height 622;
tall cards start at 784. Very short layouts use a narrower map lane; its actual
text readability is a native acceptance item.

CombatPointerGate checks active objects returned by native PlayerGui hit testing
before the global MouseButton1-to-Basic binding. It does not classify invisible
logical bounds as UI, and does not alter keyboard/gamepad mappings. Disabled
order buttons sit within an active dock so clicking the dock is not an attack.
Existing send() guards still resolve actor, class, life state, menu and trial.
See [Roblox BasePlayerGui reference](https://create.roblox.com/docs/reference/engine/classes/BasePlayerGui).

## Local verification

- `python tests/gui/run.py`: 86 cases pass, including 17 new component/input
  cases. Shared-layout matrix: 16 widths × 25 heights = 400 combinations, with
  six-cell containment, minimum targets and pairwise HUD separation.
- `powershell -NoProfile -File tools/validate.ps1`: 973 domain cases pass;
  Rojo build/sourcemap, Luau analysis/compilation, repository validation and diff
  whitespace checks pass. Exact runtime sourcemap coverage: 395 strict files.
- Independent read-only reviewer `material_review_v9` reran 86 GUI cases and
  found no actionable source issue after the final touch-reserve adjustment.
- Forge doctor/validate/plan, reconciliation and character-contract checks ran;
  missing external tool capability is not promoted to acceptance.

Raw local logs retained in this worktree:
`build/companion-orders-gui-final.log`,
`build/companion-orders-baseline-final.log`, and
`build/companion-orders-baseline-first.log`.
The first baseline passed domain tests but failed nullable navigation-reference
types. Four narrow RHS casts address the checked-in non-null API definitions;
the final full baseline passed. The failed log is retained unchanged.

The historical domain layout test reconstructs older rectangles; the actual
new shared rectangles and all six targets are covered by the expanded GUI test.
No test claims native glyph measurement or OS pointer delivery.

## Controller acceptance still required

Build a fresh preview from the integrated source; the earlier party-r3 preview
does not contain this change or the latest three-road integration. Test 320/390
phone widths, short landscape and desktop in EN/TH with player + five companions:
all six buttons visible, correct selected actor/action, no extra Basic on a
correct UI click, world clicks still Basic, keyboard K and gamepad controls,
focus movement/resizing, disabled/downed/menu states, TextBounds and native
TouchGui clearance. Use native hit testing/visible coordinates for automation.
Synthetic party acceptance remains distinct from earned progression and devices.

Overlapping world labels remain a separate problem in CombatController's
CombatHealthBar policy, outside this wave's scope. No billboard or world-sign
source was edited. Native Studio, physical device and human approval remain pending.
