# W1 Title keyboard entry

Acknowledged controller contract revision 1, commit a483a7c, SHA256
`a9d5d586b4ae235f7436c862f491bf979fe9a8ea4eba63137a3f6aa629566fb9`.
No boundary/schema changes proposed. Controller contract remains canonical.

TitleKeyboardFocus binds Tab at ContextActionPriority.High only while Title is
visible and its ScreenGui enabled/attached. It delegates to MenuRouter.focusCurrent;
MenuRouter remains the sole focus owner. Textbox and core-menu input passes through.
Hide, disable, detach and destroy release the binding. Existing readiness guards
still block Continue during loading. This addresses the observed Tab entry gap;
the precise engine/Core UI conflict remains an inference until native retest.

Local GUI simulation: 10 cases passed, including new keyboard lifecycle coverage
and a Title loading-path routing assertion. These do not simulate Roblox input
priority arbitration or prove actual processed Tab delivery. Independent read-only
agent review found no actionable P1/P2 findings. No Studio calls made in W1;
controller retains interactive ownership.

Fresh tools/validate.ps1 passed: game regression suite, Rojo build/sourcemap,
strict Luau analysis, compilation, repository boundaries and git diff checks.
Raw local outputs are in evidence/w1; they are local subprocess evidence only.

Preview: build/gui-review/GuildborneGUIReview.rbxlx, SHA256
`a47f1ce4f23723d7c5102b12011eb1e5d5590fbde2b8092f0ce1b6a3cd3e36a5`.
BUILT_NOT_STUDIO_TESTED for this revision. User agrees to open when ready;
coordinate with controller before starting Play. Historical native screenshots
and receipts describe their original candidate only.

Metadata repair: controller cherry-pick 84fe8cb became d4c660f; GitHub run
38864305260 passed. Do not include ongoing controller metadata edits in GUI commit.

## Next exact scopes for controller registration

Proposed gui-runtime-slice: src/client/UI/SliceUI.luau,
src/client/UI/StatusPointView.luau, src/client/UI/InventoryView.luau,
src/client/UI/SettlementView.luau, src/client/UI/Components,
src/client/UI/DesignSystem, tests/gui, production/ux/gui-runtime.
Not claimed or changed by this W1 patch.

StatusPointView consumes actor/statusAllocations, Points.Order, budget/validate,
catalog.StatusAllocationAvailable and busy/expedition/job restrictions. Preserve
AllocateStatus and ResetBuildPoints actor IDs and authoritative responses.
InventoryView consumes data/catalog/busy through existing ui callbacks, selected
actor and actual Equipment catalog. Preserve equip/sale confirmations and filters.
SettlementView Journal consumes JournalViewState and catalog.Journal; pinning uses
ui.trackQuest, mutations retain AcceptTask/ClaimTask. Do not replace quest routes.
Shared SliceUI helpers require regression coverage across all consuming screens.

HUD in src/client/Controllers/PlayerCombatController.luau needs a separate scope;
src/client/UI/CivicMapView.luau and src/client/Controllers/CityNavigation.luau
must coordinate with S13. No MenuRouter, server or shared data writes requested.
