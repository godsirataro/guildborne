# Native inventory inspection refinement — 2026-10-20

Source-only candidate from `b36e055`, branch `codex/forgegui-inventory-trial`.
Worktree: `C:/Work/MySelf/Guildborne-forgegui-inventory`.

## Visible change

Selected items now have a navy inspection bay with restrained brass corners and
a teal inner line. Its original model portrait grows responsively from the old
80px to as much as 256px, bounded by the detail pane's available width. The
selected inventory tile uses the existing focus color to connect selection with
inspection. Item name, model, available actions and metadata form one vertical
sequence. Metadata retains automatic height but starts at 24/40px instead of
64/84px, avoiding large blank rows for short descriptions and quantity text.

All labels and values still come from the existing view model, including zero
quantities. No slots, statistics, currencies, categories, callbacks or server
rules were added. Empty, busy and unavailable states retain existing behavior.
The inspector remains passive; equip/unequip and other intents use existing buttons.

`AssetImage.item(parent, id, {size = pixels, modelOnly = true})` is optional.
Omitting options preserves 80px source artwork and the existing .6 equipment
scale (48px). `ItemViewport(parent, id, edge)` also defaults to 80px. Sizes are
finite and bounded to 16–512px. Inspection requests current original model
geometry instead of allowing an older atlas to hide it; atlas behavior remains
unchanged for existing callers. Camera direction, field of view and distance
formula are unchanged. No new models, raster assets or Roblox asset IDs.

## Concept provenance, separate from implementation

Controller-generated ForgeGUI concept job:
`b3689284-a531-4000-ab08-1da00180e1eb`.
Artifact: `mcp-artifact:b3689284-a531-4000-ab08-1da00180e1eb:0`.
Original provider receipt is preserved at controller commit `03ddacf` under
`production/integration/quality-slice/forgegui-inventory-trial-20261020`.

The controller supplied its visual interpretation: navy/brass/teal, large item
inspection and restrained selection. This worker inspected the prior native
`build/native-post-20261020/inventory-en-after.png` in the controller checkout.
That image showed a tiny Herb portrait and large blank metadata rows; it is a
before image, not evidence of this candidate's rendering.

The generated concept is guidance only. Fictional ring/necklace slots were not
copied. No concept image was imported or uploaded, no additional provider call
was made, and no new license/import approval is asserted.

## Verification actually run

- Existing inventory pane simulation: **27 passed**, unchanged test suite.
- New focused checks: **19 passed**, including 12 width/language combinations,
  size/default/atlas behavior, five metadata fields, busy/stale callbacks,
  actual quantity zero, equipment scale and no extra slots.
- Actual ItemViewport source: **7 cases passed** with stub model bounds and
  camera arithmetic. This does not test all 30 original geometry definitions.
- Full `tools/validate.ps1`: **973 domain tests passed**, Rojo build/sourcemap,
  Luau analysis/compilation, repository coverage and diff whitespace passed.
- Independent reviewer `material_review_v9` reran 27 + 19 + 7 checks and found
  no actionable source issue.
- Forge validate/doctor/plan, reconciliation and character-contract checks ran.

Reproduce focused checks:

```powershell
python tests/gui/run_inventory_gui.py
python production/ux/forgegui-inventory-trial-20261020/checks/run_inspection.py
python tests/gui/build_inventory_review.py
```

Local raw baseline log: `build/inventory-baseline.log`.
Compatibility log: `build/inventory-compatibility.log`.
The isolated candidate is `build/inventory-review/GuildborneInventoryReview.rbxlx`;
its builder records exact source hashes and asserts one LocalScript, no server
scripts and no remotes. A build is not a Studio test.

## Native acceptance owned by controller

Use a fresh full Memory candidate for integrated Inventory acceptance; the
party lab lacks SliceUI and cannot prove this screen. The isolated inventory
review is available for bounded component inspection. Check EN/TH at 320/390,
medium and desktop widths; small and tall items; selected tile focus; zero and
unowned states; native automatic text growth; scroll-to-action visibility;
busy and back/paging callbacks; resize and teardown. Camera math checks do not
prove rendered pixels. Native Studio/device/human approval remains pending.

Only the three authorized UI modules and this new report/check folder changed.
No combat/HUD/world/server edits, Studio/Blender ownership, paid calls, push, PR
or publication occurred.

## Shop Hall-label follow-up

Controller integrated the inspection change as `395d0a4` and reported matching
447 script identities in the full Memory candidate, a 249px inspector, unchanged
80px grid art and correct zero quantities. Its EN desktop shop screenshot exposed
`Requires Hall Lv{level}` for Apprentice Staff at Hall0.

The actual catalog omits HallLevel for that item. The existing UI availability
gate and server buy rule already default it to 1; InventoryView's translation
parameter now uses the same `def.HallLevel or 1`. This is a one-line display fix,
not a catalog or purchase-rule change.

Run `python production/ux/forgegui-inventory-trial-20261020/checks/run_hall_label.py`.
The regression executes actual InventoryView, Equipment, Content and Localization
with a captured pane model. Before the fix: 10 passed, 2 failed (missing default,
EN and TH). After: 12 passed, 0 failed. Explicit Hall2/3, threshold, price,
capacity, busy state, nonmutating selection and intentional canonical purchase
dispatch are covered. Disabled model flags are checked; this is not an engine
click test. Raw logs remain `build/hall-label-before.log` and
`build/hall-label-after.log`.

Follow-up source scope is InventoryView only plus this report and its two new
check files. Controller owns the final native reread and immutable full baseline;
the worker did not rerun the full baseline for this display fix.
