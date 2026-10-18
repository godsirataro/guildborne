# Native inventory candidate

Base96278a2, worktree Guildborne-inventory, branch codex/native-inventory.
Source phase41be870 used exclusive ux-system lease, explicitly released before
gameplay-ui-quality localized/test phase. No Studio/Blender access, push or merge.

## Visual scope and behavior

References: design/guildborne-gui-production/03_REFERENCES/
07_INVENTORY_EQUIPMENT.png (composition),01_BRAND_UI_KIT.png (native visual
language),05_CHARACTER_STATUS.png (actor/equipment placement only). Existing
navy/card/ivory/gold/burgundy palette, native borders and original item geometry;
no uploaded asset IDs, screenshot-as-UI, unsupported rarity or invented stats.

InventoryView projects existing Equipment rules into InventoryPane. Desktop has
actor/loadout, item grid and selected details; medium replaces grid with selected
details and Back; phone has Items/Loadout/Details views. Actor strip distinguishes
duplicate hero labels by canonical ID. Exactly three equipment slots and real
HP/Attack/Defense. Owned gear precedes material rows. Grid pages bound displayed
item previews to24. Full item name lives in details; grid names may truncate.
Inventory uses the existing compact management shell, avoiding repeated tutorial
copy above gear. The quest tracker still carries guidance.

Preserved: actor focus, filter/sort, compatibility, materials/counts, capacity,
Hall/gold purchase conditions, assignment/transfer/unequip payloads, unassigned
sale with two-step confirmation, busy controls and snapshot ownership. No server
logic, remotes, profile/schema or economic feature flags changed.

InventoryActorPreview uses actual LocalPlayer.Character or a roster-matched
owned hero. Missing models show a translated fallback. Non-archivable character
roots are reconstructed without changing live flags. Clones remain detached
until scripts/nonvisual classes are removed. Physics is disabled; one inert
Humanoid preserves clothing. One-second visible refresh, bounded searches and
signature comparison avoid repeated cloning of unchanged actors; destroy cancels
timer/connections. Native clothing/pivot/rendering acceptance remains pending.

## Actual local validation

- Actual InventoryView + Equipment recording-pane harness:12 PASS.
- Actual Pane/Slot/Button source simulation:5 PASS. Preview/item rendering are
  explicit stubs in this simulation; no avatar, text-shaping or engine proof.
- Existing GUI source simulation:60 PASS (12+16+14+6+2+10).
- Scoped Roblox-aware LSP:PASS for new production modules, InventoryView,
  Localization and native fixture. Eight changed Luau files compile.
- Independent inventory_review: player-root cloning and duplicate-name findings
  fixed; medium detail visibility fixed; no remaining source blockers. Fixture
  reviewer required production1000px cap/centering and4px padding; applied and
  rechecked, no remaining fixture blockers.
- Full tests/run.luau attempt was interrupted by the host/session interruption.
  Its partial build/inventory-baseline.log is NOT a completed baseline result.
- Studio/screenshots/TextFits/input/device/performance:NOT_RUN by this worker.

## Native fixture handoff

Build: `python tests/gui/build_inventory_review.py`
Place: build/inventory-review/GuildborneInventoryReview.rbxlx
SHA256:5cbed1669c28fc51d4694f944c86d7bf12278f5e03b1182808f70628198a7a86
Receipt: build/inventory-review/build_receipt.json records source hashes.
Builder asserts one LocalScript, zero server Scripts and zero remotes. Workspace
has a static SpawnLocation for the actual local avatar; it is not a game session.

Open only in a disposable Studio session and Play. Controls: Size796/Size1366/
Size320, LanguageEN/LanguageTH, FitToggle, ReportNow, ModeOwned/Busy/Empty/
Incompatible/LongCopy/Capacity/HallLocked. Controls are horizontally scrollable.
Default1:1 uses exact selected canvas dimensions; scroll the OUTER viewer to
inspect. Fit changes AbsoluteSize and breakpoints, so is not size-test evidence.
The fixture mirrors production management shell cap, centering, padding/spacing.

Synthetic fixture has owned and spare items for exercising actions; it is not
the same inventory as controller's historical earned2-item BEFORE capture.
Actor portrait uses the real local avatar. Rowan intentionally has no model,
so his missing-model fallback is testable. Real owned hero rendering belongs in
the integrated game. Actions log INVENTORY_INTENT_ONLY and a counter; they do
not mutate synthetic state or contact a server. Log names INVENTORY_TEXT and
INVENTORY_REVIEW include TextFits and clipped visibility separately, source
rectangle, language/mode and cloned-script count. No capture is fabricated.

Controller acceptance checklist:
1. Capture796,1366 and320 EN/TH1:1. At796 actor+firstgear/grid visible; selecting
   a tile opens details at top with Back. At320 full first item row fits content;
   use Loadout for actual avatar/slots. Confirm long names readable in details.
2. Select spareSword, Sell once:counter unchanged, confirmation label appears;
   confirm:one intent. Switch selection/actor before confirming:confirmation reset.
3. Busy:mutation controls inactive. Empty:truthful empty state. Incompatible:
   choose All classes to expose bow and inspect disabled equip. HallLocked:
   open Shop and inspect disabled buy. Capacity:paging reaches all items.
4. Inspect actual avatar silhouette/clothing including non-archivable root;
   output clonedScripts must remain0. Check fallback/owner isolation on hero
   selection, refresh/stream loss, close/reopen cleanup in integrated game.
5. Full-game bindings, server results, keyboard/gamepad focus, real touch,
   sustained viewport cost and human art acceptance remain separate gates.

Historical BEFORE was reported by controller from oldsource4e32013 at796x675,
earned Memory session def49833: controls filled first viewport, items below fold.
Capture exists in tool history only, not a local PNG or current session claim.
