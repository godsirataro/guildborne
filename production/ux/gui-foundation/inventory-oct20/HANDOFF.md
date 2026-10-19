# Inventory native route and ordering repair — 2026-10-20

Base7f392a5, existing worktree Guildborne-inventory-art-v8 on new branch
codex/inventory-native-route-oct20. Previous aac6267 branch retained. Shared v8
lease gui-foundation, owner s14-inventory-oct20. No interactive Studio/Blender use.

## Source finding and narrow repair

InventoryPane's final depth-only layer(root,20) overwrote component ZIndex hints.
Nested compass/podium shapes ended above the actor viewport under Global order;
item artwork descendants ended above count plates, and could cover corner marks.
Post-pass now flattens the complete stage below the viewport and puts complete
corner/count subtrees above the highest artwork layer. No geometry, labels,
data, selection, callbacks, camera or allocation/equipment logic changes.

New painter-order regression fails against baseline7f392a5 with
`decoration paints over avatar`; unchanged raw streams retained in
build/inventory-oct20/before-regression.stdout.txt and .stderr.txt. Current source
passes27 pane simulations,2 yielded redraw/destruction cases and12 actual-view
binding simulations. Scoped Roblox LSP and compile PASS. Independent read-only
reviewer reran27 and cleared the change. Mocks verify ordering, not rendered pixels.

Reviewed actual controller capture:
C:/Work/MySelf/Guildborne-controller/production/integration/quality-slice/native-20261020/inventory-novice-th.png
It shows real player portrait, five zero-count materials, Herb detail and no
equipment in fresh Novice state. This is pre-repair controller evidence, not
our native test. Controller reported one pane/no duplicated sections and no
visible TextFits failures. Do not reintroduce the historical portrait/duplicate
blocker as current. The native frame already conveys navy/brass/ivory identity;
further restyling should follow actual art review rather than a broad rewrite.

Forge trial concept: TOOLCHAIN_20261020 says website generation is excluded from
MCP job history. No matching local file or open Forge tab was found in this
worker session. That image was not directly reviewed; no paid call, generation
or invented concept interpretation. Original user references01/07 remain available.

Language observation: read-only audit found Continue only exits Title. SetLanguage
is a separate callback and both views consume projected language. Controller
later confirmed a SetLanguage action in console; no speculative fix made.
Asset203785492: no literal reference found anywhere under src. Historical console
reports contain it, but no scoped UI dependency was identified to remove; no
replacement asset ID invented. Runtime/Studio origin remains unresolved.

## Controller native route and exact state setup

1. Normal Memory preview FIRST: preserve current fresh profile. From title use
   visible coordinate-confirmed Continue, open management and Inventory. Capture
   language before/after. Do not seed class, gear, heroes, currency or saved data.
   Expected fresh Novice: no class selector row, real player portrait; catalog
   materials may display0, equipment0/50, no equip/sale action for a material.
2. Owner runs native_readback.luau in CLIENT context after opening. Save raw result
   and screenshot. Verify exactly one pane, each named direct section once,
   stageBelow=true and all present quantityAbove/cornersAbove=true. Pixel review
   still required even if all numeric relations pass. Explicit coordinate input
   must use a fresh screenshot; previous MCP target paths had inset mismatch.
3. Separate disposable fixture: build with tests/gui/build_inventory_review.py.
   Candidate is build/inventory-review/GuildborneInventoryReview.rbxlx; receipt
   build_receipt.json contains exact current source hashes. One LocalScript,
   zero server Scripts/remotes. Do not install synthetic data in normal preview.
4. Size796 + LanguageTH + ModeActors1,1:1: capture first viewport and portrait;
   expected medium stage233x180. Verify compass/podium behind actual avatar,
   count plates/corners above artwork, no cropped labels. Repeat EN. Compare
   actor height/position with the prior candidate, not a different avatar.
5. Size320 + TH + Actors1: Items then Loadout then Details. CategoryPicker expanded
   full-word choices; select Material, observe collapse. Native chevron should
   remain visible. Loadout stage160px; desktop Size1366 stage200px. Use outer
   scroll at1:1 to inspect full1366 canvas; Fit is not breakpoint/device evidence.
6. ModeOwned: select spareSword; first Sell shows confirmation and0 intents,
   second exactly1 SellEquipment. Switch item/actor before confirmation to cancel.
   ModeBusy prevents action/picker dispatch; ModeIncompatible + All classes shows
   disabled equipment action. ModeHallLocked + Shop keeps buy disabled.
7. ModeActors6: scroll to final hero, confirm identity/stats and unavailable-model
   fallback with stage hidden. ModeCapacity: next page, select an item, resize,
   close/reopen; no duplicated sections/callbacks. LongCopy: full text reachable.
   Test keyboard/gamepad focus separately from selection; touch/device still pending.

To compare Global ordering, controller may use a separate fixture copy with only
the fixture ScreenGui.ZIndexBehavior changed, recording that mutation explicitly.
Normal game remains unchanged. Screenshot and console evidence belong to owner;
no new native PASS, economy receipt, device or human artwork approval is claimed.
