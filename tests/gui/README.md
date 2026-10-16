# Native GUI review checks

Run `python tests/gui/run.py` from the repository root. This bundles the current
Luau component and TitleView sources and executes them with the installed Luau
CLI. Nine behavior cases cover disabled/pending controls, tab selection,
logo fallback, native panels, profile readiness, repeated Continue, recovery
handoff and preview cleanup.

This is a deliberately narrow Roblox simulation. It does not model layout,
rendering, input dispatch, asset downloading, instance property validation or
engine event ordering. Title tests stub MenuRouter, CompanyPreview and
SettingsControls; they validate Title orchestration, not those dependencies.
Logo test asset 123 is an inert test input, not an approved runtime asset ID.

Run `python tools/build_gui_review.py` to generate
`build/gui-review/GuildborneGUIReview.rbxlx`. Open that place in Studio and Play
to inspect the actual native TitleView and its real dependencies. The isolated
fixture uses a clearly marked simulated Loading -> Active profile after two
seconds; Continue opens the component gallery. There are no hero models or
persisted profiles. The builder rejects server scripts/remotes and requires
exactly one LocalScript. Nothing is published or uploaded.

The generated place is BUILT_NOT_STUDIO_TESTED until a separate reviewer actually
runs it. EN/TH wrapping, phone safe areas, gamepad focus, touch targets, image
appearance, physical-device performance and full gameplay acceptance remain
separate checks. Rebuild after source changes; an older place is not current
source evidence.

W1 adds simulated Title Tab routing, loading activation guard, textbox/core-menu
pass-through, repeated refresh, hide/reopen, ScreenGui disable/enable and destroy
cleanup coverage. These mocks do not establish engine input priority or processed
input delivery. In the current native candidate, press Tab without calling
MenuRouter manually, check selection, then Return; repeat after mouse input and
with Settings open. Confirm hidden Title releases Tab back to gameplay/Core UI.
