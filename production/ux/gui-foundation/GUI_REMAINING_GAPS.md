# Remaining GUI gaps — 2026-10-16

All items below remain pending unless a later linked receipt records the exact tested candidate. This foundation delivery does not reskin or accept 73 screens.

## Next implementation sequence

1. Complete reusable components and Title/loading candidate; obtain owner visual review before broad migration. Keep actual logo source/provenance and native fallback; no invented import ID.
2. Migrate common SliceUI presentation helpers while preserving actions/state contracts. Review main menu and player plus five-hero HUD separately.
3. Migrate status/skills and inventory/journal using real actor, stat, item and quest data; retain confirmation, pending, unavailable and recovery behavior.
4. Migrate map/travel, personal Guild/islands/building, Gold shop/crafting/market and remaining existing registry modules.
5. Reconcile the additional surfaces in GUI_SCREEN_COVERAGE.csv: human party, appearance, novice guidance, ending replay, daily rewards, dialogue and mentor training. Staged Federation/social source must not be labeled live.
6. Resolve GL2 dependencies before dedicated war/territory/treasury/research/bond/event/team-challenge actions. Canonical locations, costs, permissions, reward lifecycle, IDs and availability must come from reviewed systems.

## Asset and integration gaps

Runtime logo/image imports, approved 9-slice decoration and any new icons need actual source-to-runtime bindings and provenance. Existing uploaded IDs cannot be assumed from local PNG files. Keep dynamic labels/prices out of textures. Use native geometry fallback while asset binding is unavailable. Stylesheets are optional after capability verification; they do not justify rewriting game logic.

Studio MCP is discoverable, but the coordinator's state probe reported Place is not open. Open-place identity, Rojo sync/build, fresh boot, Output, native interaction screenshots, cleanup and test fixtures are still required. Do not attach to or overwrite another worker's interactive session without the shared ownership handoff.

## Required fresh QA

Run post-change Luau checks and builds against the actual candidate. Baseline receipt 229ed8c563764de697e5c894f55ec561 at42cb34b predates this candidate and is not GUI proof. Record commands, tree/commit, logs and expected/actual results without changing raw receipts.

Exercise Title profile loading, failure/retry, degraded/lease-lost handoff, Continue, language, settings, credits, model cleanup and respawn. For each migrated screen exercise empty/locked/pending/error/committed states, rapid repeated input, snapshot refresh, focus retention, actor switching and return navigation. Market additionally needs stale/read-only/paused/partial/recovery outcomes; no optimistic success.

Test desktop, narrow portrait and landscape layouts, Thai/English wrapping, safe areas, text scaling, virtual keyboard, mouse, keyboard and gamepad. Test disabled controls cannot activate and gameplay input is blocked when a modal owns focus. Test reduced motion/audio settings and preview lifecycle cleanup. Layout emulation is not physical touch evidence.

Actual Android/iOS input, sustained performance/memory/thermal measurements and human readability/visual approval remain external. Distinct-server market conservation, persistent recovery and multiplayer state isolation require their own scoped environments and receipts; four Studio clients are not cross-server evidence.

## Acceptance and release

Human owner review of the first screen is pending. Full visual acceptance, game UAT and all GL2 gates are pending. New tests remain NOT_RUN in the coverage CSV until actually exercised; SOURCE_AUDITED is only source/dependency classification. Independent review is required before evidence acceptance. PR creation does not authorize merge, Roblox publishing, paid uploads, commerce activation or production writes.
