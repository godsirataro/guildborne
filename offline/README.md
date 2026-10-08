# Offline full-game playtest

Build from the repository root:

```powershell
.tools/rojo/rojo.exe build default.project.json --output build/Guildborne.rbxlx
python tools/build_offline_project.py
```

Open `build/Guildborne_OfflinePlaytest.rbxlx` in Roblox Studio and Play. This is the full current game with a separate memory-only Runtime configuration. Stop discards the session; another Play begins fresh. It is suitable for local onboarding practice, not persistence/reconnect acceptance.

The builder verifies that the sole source difference from the normal place is `ServerScriptService/Server/Config/Runtime`, that there is one Runtime module, and that the normal configuration file was not modified. The offline cloud-universe allowlist is empty. Do not publish this test place as the game.

No currency, inventory, levels or tutorial progress are granted by this project. Use ordinary game controls. `tests/studio_offline_journey_probe.luau` describes a public-command smoke journey, but execution through this Studio MCP session was blocked by runtime Capabilities. That automated journey has not passed; no security flags were changed. UI-driven checks are recorded separately in the UAT evidence.
