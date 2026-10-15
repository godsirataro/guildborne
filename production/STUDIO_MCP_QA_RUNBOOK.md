# Guildborne — official Studio MCP and multiplayer QA runbook

**Status: PROCEDURE ONLY.** This change has not connected to Roblox Studio, run a live game, imported any asset, published a place, or written DataStores. Follow the existing safety and approval boundaries in [AGENTS.md](../AGENTS.md), [QUALITY_GATES.md](QUALITY_GATES.md), [EXECUTION_V2.md](EXECUTION_V2.md) and [MERGE_READINESS.md](MERGE_READINESS.md).

## 1. Prepare the real workstation

This is for the developer's Windows machine with an approved **Guildborne - Staging** place open. It cannot be accomplished through a GitHub connector or a web-only ChatGPT chat.

1. Run the static-only preflight from repo root: **python tools/agentic/studio_mcp_preflight.py --strict**
2. Inspect actual host setup: **codex mcp list**. The canonical server is **Roblox_Studio**; review unexpected or duplicate registrations rather than adding another.
3. In Roblox Studio: open the **approved staging place** → Assistant → … → Settings → MCP Servers → Enable Studio as MCP server → Quick Connect **ChatGPT (codex)**. If tools are absent, open a new Codex thread.
4. Use the [official Roblox Studio agent plugin](https://github.com/Roblox/roblox-studio-agent-plugin) and its [host registration instructions](https://github.com/Roblox/roblox-studio-agent-plugin/blob/main/skills/roblox-get-started/references/connect.md); do not install community bridges blindly.
5. Use existing read-only [mcp_probe.py](../tools/agentic/mcp_probe.py) only after reviewing its local command JSON and SHA-256, as documented in EXECUTION_V2.md. Its output is **MCP_CONNECTED_NOT_STUDIO_ACCEPTED**, not a passed playtest.

**Preflight meanings:** CONFIGURED_NOT_CONNECTED verifies only a reviewed launcher-shaped TOML entry and presence of the local launcher file. REVIEW_DUPLICATE_STUDIO and REVIEW_UNKNOWN_COMMAND require human review. There is no credential, command or environment-value echo and no executable launch. Verify actual connected Studio ID, place identity, tool inventory and input schemas before any mutating tool call. Claim the appropriate exclusive Forge/Studio owner lease and retain existing source control.

## 2. Test the existing Guildborne game, not a generic template

For a single player, use actually advertised [Studio MCP tools](https://create.roblox.com/docs/studio/mcp) or Studio controls to play the original route:

1. New Novice save → tutorial and Guild Hall → Class1 quest at Lv10 → recruit heroes and form up to a five-hero party.
2. Quest claim, authoritative Gold/XP receipt, weapon equip, battle and loot, crafting, city, island and TH/EN mobile HUD.
3. Leave/rejoin, duplicate claim, malformed client intent and refused/inactive marketplace states; all authoritative economy results must be verified on server.
4. Record logs/screenshots, actual build commit/tree, environment, observed expected vs actual, reviewer and the uncompleted gates. Merely opening a UI or taking a screenshot is not server-state evidence.

Consult docs/uat01/WORK_CHECKLIST.md and the respective implementation records for current canonical IDs, rules and existing evidence.

## 3. Multiplayer test matrix

[StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService) supports up to **8 simulated clients on one Studio server**. Its ExecuteMultiplayerTestAsync method **requires plugin security and a plugin script**; it is not callable from arbitrary server code or assumed available via execute_luau. Programmatic tests need a reviewed plugin-side launcher and a running test-server script to call EndTest. Start with manual Studio multi-client testing if no such harness is yet available. Do not claim these scenarios have run.

| Scenario | What must be observed | Evidence layer |
| --- | --- | --- |
| Two clients: identity | A and B retain independent Gold, character level, hero roster, equipped items, allocated status and saved Hall state; B cannot spend A's materials | Studio single-server |
| Two clients: quests/combat | Damage and loot are server-owned; duplicate RemoteEvents cannot claim Gold, XP or items twice; no combat from cosmetic animation/VFX markers | Studio single-server |
| Two clients: guild plots | Server enforces owner/guest build and visitor permission, unlock ownership and returns assets correctly after cancellation | Studio single-server |
| Four clients: companions | Up to five companions each (up to 20) navigate, follow, fight and clean up correctly; ownership does not jump between users | Studio single-server |
| Four clients: disconnects | Join late, leave/rejoin during quest/guild/market UI, retry pending claims without duplicate rewards or leaked locks | Studio single-server |
| Four clients: marketplace boundaries | Public market and paid purchase switches remain disabled; any isolated internal market QA retains fencing, ledger/escrow and Gold/item conservation | Studio single-server |
| Optional eight clients | Collect actual CPU/frame, network and NPC/companion observations over bounded time; do not imply production capacity | Studio experiment |

**Outside this gate:** independent privately published live servers with *distinct nonempty JobIds* ([private cross-server acceptance](../docs/PHASE4_PRIVATE_SERVER_ACCEPTANCE.md)), real Android/iOS touch/FPS/thermal/memory ([device acceptance](../docs/PHASE4_5_MOBILE_DEVICE_ACCEPTANCE.md)), distinct human art/feel/UAT and explicit release owner signoff. Roblox [hardware guidance](https://create.roblox.com/docs/performance-optimization/test-on-hardware) explains why emulation cannot approve a real device. Studio MCP single-player start_stop_play is also not proof of StudioTestService multiplayer.

## 4. Per-scenario evidence contract

Start every case at **PENDING**. Record: scenario ID, source commit/tree, test timestamp UTC, operator, verified staging place, local single-server vs live server designation, number of real/simulated users, expected outcome, **observed actual** values, server-authoritative snapshots, console output and capture artifact hash. Mark FAIL/BLOCKED honestly and leave human approval outside agent automation. Keep private account data and tokens out of PRs. Use ignored build/agentic output or another authorized private evidence location.

An existing record_check.py/compose_evidence.py receipt proves a **local command was invoked** on a clean committed source; it cannot itself certify user actions in Studio or independent cloud server events. No source-code change, migration, publishing, paid upload or production DataStore mutation is authorized by this runbook.

Sources checked **2026-10-16**: [official Studio MCP](https://create.roblox.com/docs/studio/mcp), [official plugin](https://github.com/Roblox/roblox-studio-agent-plugin), [StudioTestService](https://create.roblox.com/docs/reference/engine/classes/StudioTestService), [testing modes](https://create.roblox.com/docs/studio/testing-modes), [test on hardware](https://create.roblox.com/docs/performance-optimization/test-on-hardware).
