# GUI source audit â€” 2026-10-16

Status: SOURCE_AUDITED. This is a source mapping for the bounded reusable-foundation and Title review slice, not acceptance of a full GUI replacement. No new Studio/device/human GUI test is established here.

## Evidence boundary

The canonical input is `docs/uat01/intake/registry-reconciled.json`: 73 screen rows, 21 without an implementation candidate, eight historical FUTURE rows, and no `uatApproved:true`. The companion CSV preserves all 73 IDs, original scope/status/candidate fields and adds 14 separately named `extra.*` surfaces. SOURCE_AUDITED means the mapping/dependency was reviewed, not that every state or action passed. At initial audit all tests were NOT_RUN. The current CSV records partial native fixture observations for Title/loading only; see GUI_ACCEPTANCE.md.

Coordinator-reported baseline receipt `229ed8c563764de697e5c894f55ec561` passed at `42cb34b`; it is pre-change baseline evidence, not GUI acceptance. Coordinator's Studio discovery found session `1e078f2a-71bd-4c20-bc35-7a41b7bbb4d4` with null name; `get_studio_state` reported `Place is not open`. No open-place screenshot or runtime acceptance is inferred.

## Existing architecture and integration

`src/shared/Config/Art.luau` already supplies Navy #0F1523, Card #1A2231, Ivory #F5ECD8, Gold #DCB76B and Burgundy #5B2735. Reuse it as color authority.

`SliceUI.luau` creates GuildborneUI with CoreUISafeInsets and injects common card/text/button/layout helpers into the majority of view modules. This is the eventual shared-component migration seam. Preserve the context API, action callbacks and scroll retention. Title is constructed separately and is the first bounded integration target.

`TitleView.luau` returns update(view) and isOpen(). It receives enter/language callbacks and registers a pinned Title frame in MenuRouter. Continue requires an Active profile with data. ProfileReady, disabled Active/Selectable, CompanyPreview cleanup and EN/TH remain mandatory. Non-Active/non-Loading status must hand off to existing profile recovery UI. Loading has no measured percentage and must remain indeterminate.

`MenuRouter.luau` owns menu exclusivity, pinned menus, build-mode blocking, gamepad focus restoration, Tab navigation, ButtonB close and touch-control suppression. Reuse it; a second focus manager would conflict.

`SliceController.luau` owns request IDs, revision, pending operations, server response interpretation and resync. Leave it unchanged for styling. UI may send intent; only authoritative snapshots establish rewards, equipment, claims or save success.

Existing AssetImage, SymbolIcon, ActorPortrait, CompanyPreview, ItemViewport, ClassBadge, EmptyState and ScrollRetention provide image fallback, native model previews, empty states and update continuity. Do not replace a missing asset with an invented runtime ID. Dynamic text remains native and localized.

## Screen-to-source groups

| Family | Existing source |
|---|---|
| Title/loading/credits | TitleView |
| Main navigation, hero roster/detail/party, save/recovery/tutorial | SliceUI |
| Exploration/combat/boss HUD | PlayerCombatController |
| Inventory/detail/compare/Gold shop | InventoryView |
| Skills/class advancement/status | ExpansionView, SkillTreeView, StatusPointView |
| Journal/detail/tavern/recruitment/dispatch | SettlementView |
| Campaign/companion choice/Hall permit | CampaignView and CampaignViewState |
| Personal Guild/Hall | SliceUI.guild plus ExpansionView |
| Crafting/tower/layouts | ExpansionView |
| Map/travel | CityNavigation and CivicMapView |
| Market/orders/history | MarketView |
| Bestiary | BestiaryView |
| Land/islands/themes/furniture/placement | Matching dedicated UI modules |
| Accessibility/audio | SettingsControls |
| Solo class trial | NoviceTrialController |

All UI module paths are under `src/client/UI`; controllers are under `src/client/Controllers`. The CSV contains exact paths and visual-reference assignments. A mapping to mockup 01 alone means no dedicated matching supplied mockup; it is not a missing runtime image.

## Reconciliation findings

- Registry class progression still says Class2 Lv30. That remains legacy-compatible data; Novice gates are10/35/70. Do not silently migrate or relock earned classes.
- Registry shop rows have null candidates, but InventoryView already contains Gold BuyEquipment/SellEquipment with capacity/Hall checks and sale confirmation. This is not a premium storefront.
- Season row is historically FUTURE/null, while LaunchRewardsView implements a gated daily/season preview. Do not activate premium or ranked features.
- PlayerGuildRosterView explicitly says staged and not registered in live navigation/network. It is not live Federation UI.
- GL2 requires Federation, war and territory at full-game launch despite older FUTURE labels. Canonical missing decisions remain dependencies; requested GUI work does not create their economics.
- Mockup class/city/item names, six stat rows and premium balances are visual examples. Use actual IDs, STR/DEX/INT/VIT/WIS, existing catalogs and available currencies.

## State and action preservation

Every applicable surface needs loading, empty, unavailable/locked, pending, error/retry and committed success with focus/selection. Keep stale quote/read-only/paused market states, partial fills/cancel remaining and authoritative claim recovery. Keep craft station/proximity requirements, destructive confirms and disabled commerce flags.

Keep player versus owned hero context, five unique NPC companion cap, expedition assignment restrictions, Hall/class prerequisites, free respec earned-budget behavior and cosmetic/legacy ancestry separation. Human parties are separate from NPC teams and personal Guild ownership.

Keep scroll/focus on snapshots, narrow-screen skill list mode, Thai wrapping, safe areas, reduced motion and virtual-keyboard usability. The ornate references guide component borders and hierarchy; no full-screen mockup becomes an interactive GUI.
