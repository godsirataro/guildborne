# Inventory native art candidate v8 — 2026-10-19

Base 3b62d2f. Admin-only dependency f792479 (local cherry-pick 7ffffa7)
corrects the generated manifest's canonical plan hash; controller already owns
that change. Deliverable touches three Inventory components, focused GUI tests,
and this report/builder only. No Localization, HUD, Title or server changes.

## Reference interpretation and implementation

References: design/guildborne-gui-production/03_REFERENCES/01_BRAND_UI_KIT.png
and 07_INVENTORY_EQUIPMENT.png. Original native geometry interprets the compass,
grounded character display and quiet storage borders; it does not reproduce the
concept's six stats, premium currency, extra equipment slots or item rarity.

- InventoryActorPreview: a faint compass with four axes/cardinal marks and a low
  navy/brass podium behind the full-size transparent ViewportFrame. Existing
  camera fit, cloned real avatar, ownership, sanitization and update loop remain.
  Stage hides on missing/invalid preview. No added events, animation, image IDs
  or fonts. Medium stage remains233x180 in the existing fixture's measured case;
  this wave has not remeasured it in Studio.
- EquipmentSlot: recessed48px icon mounts; empty weapon/armor/accessory have
  native semantic outlines. An outline is slot identity, not owned equipment.
  Actual equipment imagery and all unequip affordances are preserved.
- InventoryPane: storage cells replace command-button bevel/burgundy treatment
  with a fine border, navy surface, caption shelf and selected-only corner marks.
  Quantities use a dark plate over the artwork. Hover/press only change surface;
  keyboard focus has its own cyan rim and never changes selected item. Busy
  cells cannot dispatch. Item selection still invokes the supplied callback;
  Equip/Sell and two-step sale stay in the unchanged InventoryView.

Native geometry authored directly in Luau; no imported/generated raster assets,
external services or new asset IDs. Existing palette and font tokens reused.
This is a source-reviewed art candidate, not final/human-approved art.

## Local evidence

- InventoryPane26 simulations PASS, including new focus/press/no-selection,
  busy/destruction and paging stale-callback cases.
- Existing yielded redraw/destruction2 PASS; actual InventoryView mocked
  bindings12 PASS, including sale confirmation, equip/unequip and refusal gates.
- Shared GUI60 simulations PASS. Scoped Roblox LSP and Luau compilation of the
  three production components PASS. Diff whitespace check PASS.
- Independent read-only reviewer reran Inventory26 and sharedGUI60, inspected
  source lifecycle and viewed both reference images: no code blockers.
- Forge plan/skill contract PASS; reconciliation502 assets/73screens, no missing
  references; character contract PASS; studio adapter verification98 PASS.
- Inventory harness replaces the actor preview: its PASS does not test avatar
  rendering, camera composition, podium foot alignment or actual native input.

Full baseline tools/validate.ps1 PASS:953 tests, Rojo build, full Roblox LSP,
compile and repository/built-place checks. Raw log:build/inventory-art-v8/baseline.log
SHA256:13e4689be8a7ba00967ef2c3857884b74a88fce454c4e4d784163b299d9c800b. This precommit run used the final runtime source;
only documentation/commit metadata changed afterward. Immutable focused-check
receipts accompany the handoff.
No Studio/Blender/publish/push/PR/spend in this worker wave. No native capture,
TextFits, physical device, performance or human visual approval claimed.

## Exact comparable candidates

Run `python production/ux/gui-foundation/inventory-art-v8/build_comparables.py`.
Outputs under build/inventory-art-v8:

- GuildborneInventoryArtBefore.rbxlx: three component sources from base3b62d2f.
- GuildborneInventoryArtAfter.rbxlx: current component sources.
- comparison_receipt.json: SHA256 and source hashes for both, with build commit.

All other dependencies and the synthetic fixture are identical. Both places
contain one LocalScript, zero server Scripts and zero remotes (XML asserted).
This is an isolated UI fixture; callbacks log intent and do not transact.

## Root-owned Studio capture protocol (NOT_RUN)

Use the same Studio viewport, local avatar, language/mode/size, 1:1 scaling and
scroll positions for before and after. Fit mode changes breakpoints, so cannot
stand in for 1:1 evidence. Capture the whole first viewport plus a stage close-up.

| Scenario | Visual comparison and interaction |
| --- | --- |
| Size796, TH, Actors1, Items | ActorStage/Viewport remains233x180; no avatar/clothing crop. Compass is behind silhouette, feet plausibly meet podium. First item row and existing labels retain position. |
| Size796, EN, Owned | Select spare sword: only selected corners change, no burgundy tile. Item art stays visible; Equip/Sell remain distinct. First sale click0 intents, confirmation exactly1. |
| Size320, TH, Actors1 | Items shows two-column cells with readable labels/counts. Loadout shows160px actor stage and empty slot marks; tab/picker dimensions unchanged. |
| Size1366, EN/TH, Owned | Inspect the actual entire logical canvas by outer scrolling at1:1;200px stage, three panes. Do not label an796px visible crop full1366px evidence. |
| Material filter + Busy | Quantity plate/corners do not cover identity; selection works normally, busy tiles inactive. Test keyboard/gamepad focus independently from selection. |
| Actors6, select missing-model hero | Fallback text remains explicit and unobstructed; decorative stage hidden. No fabricated hero appearance. |
| Capacity, paging, resize, close/reopen | Selected item/details stay canonical; old paged-out tiles and destroyed UI inert; no duplicate callbacks or cloned scripts. |

Native risks to resolve: fixed podium scenery may appear separated from feet for
wide accessories/nonstandard proportions; compass contrast may be too subtle;
count plate and selected corners need real artwork/layering review. Adjust only
from fresh native captures. Local geometry and no-TextFits failures are not
visual acceptance. Normal fresh-game Inventory must also be checked after
integration; fixture success does not prove server results or economy receipts.
