# W2 visual candidate — reference comparison

Human direction: make the GUI beautiful and close to the supplied references.
Used guildborne-ui-art and guildborne-ux-native. Visually inspected the official
logo, all ten supplied reference PNGs and the actual W0 English Title screenshot.
This changes working native Luau presentation, not a flat mockup overlay.

## Before and after artifacts

Before: evidence/title-desktop-en.jpg (actual historical Studio fixture).
After candidate: build/gui-review/GuildborneGUIReview.rbxlx, built from the current
source with tools/build_gui_review.py. This is an executable native review place;
an after screenshot must be captured in Studio by the current session owner.
No browser rendering or concept illustration is presented as a runtime screenshot.

Candidate SHA256: `a74e5cb21b1704217f4233fa058fd7d2c737f9a02d1c036efd53009714072f4f`.
BUILT_NOT_STUDIO_TESTED. Before screenshot remains unchanged; an after screenshot
is not yet available while the controller owns Studio.

Local checks: tools/validate.ps1 passed 890 regressions, Rojo build/sourcemap,
strict analysis, compilation and repository boundaries. After the final smooth
surface decoration adjustment, targeted strict analysis/compilation and all 11
GUI simulations passed again. Raw output lives in evidence/w2. These are local
checks, not visual/device acceptance. Independent read-only review found no
blocking source issue; foreground foundation cropping is a native review point.

## Visible implementation changes

| Reference cue | Native implementation | Remaining gap |
| --- | --- | --- |
| Large illustrated crest and serif wordmark | Original burgundy mantle/shield/compass geometry, ivory-to-gold Garamond wordmark, gold divider and gem | Exact supplied painted logo needs genuine approved runtime binding; current Logo is empty |
| Cinematic city and hero focal point | Original static 51-part citadel diorama in a ViewportFrame, warm windows, spires, burgundy banners; existing actual owned CompanyPreview sits in foreground | Painted city landscape and final hero art are not reproduced; no invented heroes |
| Strong asymmetric menu | Desktop 62% scenic/story region, 35% action rail; one prominent 72px burgundy Continue action | Only real existing Title actions are included, no fake campaign/news/currency |
| Antique metal frames | Shadow rim, bright bevel, gold inset, etched edge and engraved corner flourishes | Procedural geometry is less intricate than imported 9-slice metal artwork |
| Clear heading hierarchy | Built-in Garamond for Latin branding/headings; existing Gotham body and explicit Thai heading fallback | Thai and English wrapping need native screenshots |
| Responsive design | Below 680px content width, full-width action rail first, then 240px scene/story; vertical scrolling | Physical device input/performance remains external |

The diorama is decorative artwork, not a world map, unlocked location or a new
game system. It has no scripts, asset IDs, render loop, physics participation,
remotes or data writes. No animated loading percentage or claimed progress is
invented. Existing profile readiness, language, recovery, Settings and Credits
callbacks remain intact. MenuRouter still owns keyboard focus.

## Native review handoff requested

Studio remains reserved for the controller. After the owned integrated run ends,
review this isolated candidate or integrate these presentation modules into the
same approved Memory candidate. Capture desktop EN/TH and 360px portrait; check
crest/wordmark, full spire framing, hero foreground, frame corners, text wrapping,
settings expansion, Tab/Return, mouse and hide/destroy cleanup. Include an empty
roster and actual replicated owned heroes separately. Do not seed fictional earned
heroes or claim fixture data as gameplay progress.

Compare the after screenshot directly with both the historical screenshot and
03_MAIN_MENU/01_BRAND_UI_KIT. Current source is a substantial composition change;
final visual similarity and human approval are pending actual native review.

## Next visual scopes (proposal only)

- HUD: src/client/Controllers/PlayerCombatController.luau; inspect
  src/shared/Data/CombatHudLayout.luau before requesting any shared-layout write.
  Six distinct actor cards, actual HP/condition, selected-actor tray and real
  cooldown masks. Preserve compact/collapsed layouts and CombatBindings hints.
- Status: src/client/UI/StatusPointView.luau and actor selector in ExpansionView.
  Actual actor preview and five STR/DEX/INT/VIT/WIS rows; preserve Points budget,
  AllocateStatus and reset confirmation. A mockup Apply button is not a new draft
  allocation contract.
- Inventory: src/client/UI/InventoryView.luau; actual Equipment(catalog) and owned
  instance IDs, weapon/armor/accessory slots, filters, capacity and sale confirm.
  Use existing ItemViewport/ActorPortrait instead of painted fictional ownership.
- Journal: Journal branch in src/client/UI/SettlementView.luau, actual
  JournalViewState.describe/matches; category/list/parchment details, existing
  Track_/Accept_/Claim_ callbacks and NPC explanations. No invented codex counts.
- Shared visual helpers: src/client/UI/SliceUI.luau plus components/design system,
  tests/gui and production/ux/gui-runtime require the controller's next scope.

No HUD, shared runtime, plan or Studio specification writes in W2. No upload,
publish, payment or live commerce activation. Existing PR only.
