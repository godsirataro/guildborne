# Inventory readability refinement

Scope: InventoryPane, opt-in GuildbornePanel presentation, and inventory component regression cases. Reference is the controller's archived native `shop-th.png` in `production/integration/quality-slice/native-forgegui-inventory-20261021/native/final/`. No Studio session or asset generation was used by this worker.

## Changes

- Inventory loadout/details panels use a single subdued brass border. Shared panel defaults, including optional slice decoration, remain unchanged for other callers.
- Inventory-local actions use the existing quiet button option, 16px text and 48px targets. Body labels and item names use 16px; item names have 48px phone / 56px desktop caption areas with wrapping and end truncation. Full selected names remain in flowing details.
- Cards are 136px on phones and 144px otherwise, retaining 80px artwork. Phone control gaps shrink so a six-actor fixture's first full item row still ends at pane-local y=380. Desktop grid height increases to 304px to fit two complete rows; pagination uses the new height.
- Loadout names, stats and hints use automatic vertical sizing in a list layout, so longer text moves subsequent equipment slots. Layout listeners are disconnected on redraw and destruction.
- Quantity badges grow within their tile for full canonical counts, including zero and the current 1,000,000 stack cap. Counts remain 16px on one line without abbreviation.

No changes to InventoryView, server actions, item geometry, ItemViewport, AssetImage, localization, equipment eligibility, currency or purchase processing.

## Verification

- `python tests/gui/run_inventory_gui.py`: 57 component simulation cases passed, including 27 existing cases. Added EN/TH width boundaries 220/280/320/599/600/744/899/900/968, default/quiet panel behavior, paging cleanup, empty/disabled states, loadout flow and zero/max stack badges.
- `python tests/gui/run.py`: 86 shared GUI simulation cases passed, including default panel and optional slice behavior.
- `python production/ux/forgegui-inventory-trial-20261020/checks/run_inspection.py`: 19 inspection cases and 7 actual ItemViewport-source cases with stub geometry passed.
- Focused Luau compilation and Roblox-aware type analysis of both changed runtime modules passed.
- Independent review identified the fixed-width quantity badge as inadequate after the font increase. The badge now expands and zero/max-count regressions cover it.

These are source-level and simulated component checks. They do not measure native font shaping, automatic layout, pixels, physical touch or device performance. The full game baseline was not rerun for this local wave.

## Controller acceptance still needed

Compare native EN/TH Shop and Inventory at 320x568 and desktop after integration. Check long names, two-line captions, 1,000,000 counts, six-actor scrolling, loadout text expansion and final-row/pager clearance. Verify actions and busy/disabled states against actual snapshots. Native Studio ownership remains with the controller.
