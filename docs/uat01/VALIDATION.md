# Executed validation

2026-10-01, Windows desktop, local repository.

- Baseline: .\tools\validate.ps1 — 271 tests passed, 5,000 synthetic orders / zero invariant violations; Rojo build, sourcemap, Roblox-aware analysis, compile, repository and diff checks passed. Existing analyzer style warnings in ExpansionView/InventoryView/SettlementView retained.
- After title/palette integration: .\tools\validate.ps1, redirected to validation-current.txt — passed with 271 tests. This synthetic load is not live cloud throughput.
- After recovery/M-key guards: Rojo build default.project.json to build/Guildborne.rbxlx and luau-lsp analyze of TitleView/SliceUI — exit 0. No transaction logic changed after full suite.
- Studio MCP: staging placeId 86788611613035 verified, mapped server/client/shared present. Three changed modules synchronized from disk. Started one actual Studio client; existing persistent profile loaded at revision 66. No fresh-profile, simulated commerce, cross-server or mobile proof.
- Client probe before mouse input: title=true, visible=true, ready=true, gui=true. Screen capture rendered saved Thai title in short desktop viewport. Capture displayed inline; no local screenshot file saved by tool.
- Real MCP mouse input clicked LocalPlayer.PlayerGui.GuildborneUI.TitleScreen.Frame.ScrollingFrame.Continue. Subsequent client probe: titleVisible=false, managementVisible=true, continueText=เข้าสู่กิลด์. This proves that input path only.
- Output: Persistent staging startup and profile_loaded; animation load/permission failures for 114302219876492. No clean-all-assets claim.
- Owned play session stopped; original Runtime DataStore configuration unchanged. No publish or account changes.

Performance numbers not measured in this UAT checkpoint. Human first-session timing, physical mobile FPS and cross-server behavior remain pending.
