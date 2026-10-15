# Guildborne AI development tool adoption — 2026-10-16

**Purpose:** Adapt useful facts from the NEONSHIFT Roblox AI research to **Guildborne**, the existing original fantasy guild-management RPG. **Not** a new project template or a claim that a live game/Studio session was tested.

**Repository inspected:** main at 4cc9a8232e0fd9ae7bf517983c274e800e8ad4a4, including AGENTS.md, README.md, production/STUDIO_V3.md, LATEST_GOALS.md, research/SOURCES.md, mcp_probe.py, Rojo setup and GitHub CI. The merged Studio v3 already provides **33 agent roles, 30 project skills, 10 workflows**, cooperative Forge handoffs, offline tests and reviewed MCP discovery. Reuse those: adding every community skill, framework or agent again would be counterproductive.

## Adoption decisions

| Priority | Verified upstream reference | Real Guildborne baseline | Action and limit |
| --- | --- | --- | --- |
| P0 | [Roblox official Studio agent plugin](https://github.com/Roblox/roblox-studio-agent-plugin) (MIT, version 0.2.1 in plugin.json when checked) and [MCP docs](https://create.roblox.com/docs/studio/mcp) | Current read-only mcp_probe.py; prior Studio inventory was empty | Add **static-only** studio_mcp_preflight.py; use official Quick Connect in real Windows Studio; inspect current tools and staging place, never claim connected from TOML alone |
| P0 | [StudioTestService API](https://create.roblox.com/docs/reference/engine/classes/StudioTestService) and [testing modes](https://create.roblox.com/docs/studio/testing-modes) | Guildborne QA has partial earlier local multiplayer evidence and remaining live gaps | Apply [Studio MCP QA runbook](../STUDIO_MCP_QA_RUNBOOK.md) to the existing hero/guild economy: start 2/4-client cases; plugin-security scripted mode supports up to 8 simulated clients on **one** server |
| P0 | [Roblox physical-device testing](https://create.roblox.com/docs/performance-optimization/test-on-hardware) | Existing QUALITY_GATES and device acceptance distinguish emulation | Never promote Studio/network-simulated results into Android/iOS thermal/input/memory or distinct live JobId acceptance |
| P1 | [Rojo 7.7.1 changelog](https://github.com/rojo-rbx/rojo/blob/master/CHANGELOG.md) (2026-10-01) | Both rokit.toml and checksum-pinned tools/setup_tools.ps1 use **7.7.0** | Follow-up upgrade only after real Windows serve/build/sourcemap + updated verified download checksum and CI. **No unsafe pin-only upgrade now** |
| P1 | [roblox-brain NPC AI guidance](https://github.com/TabooHarmony/roblox-brain/blob/main/skills/gameplay/roblox-npc-ai/SKILL.md) and [official server authority](https://create.roblox.com/docs/projects/server-authority) | Guildborne's existing guildborne-npc-life, combat/quests, native hero systems | Use targeted pathfinding, ownership, state-machine guidance; leave combat/loot server-authoritative, avoid a duplicate framework or copying the 29 generic community skills |
| P1 | [Official Roblox Blender workflow](https://create.roblox.com/docs/art/blender) | Existing Python/Blender generators, rigging kit, asset provenance and fit matrix | Prioritize Human Standard/Heavy + removable clothing/gear: inspected source → export → real Studio import → animation fit → physical-device look → human signoff. Never invent imported IDs |
| Optional P2 | [Community MCP for Blender](https://github.com/ahujasid/mcp-for-blender), [package metadata](https://github.com/ahujasid/mcp-for-blender/blob/main/pyproject.toml), [privacy terms](https://github.com/ahujasid/mcp-for-blender/blob/main/TERMS_AND_CONDITIONS.md) | Blender Python currently reproducible; old research mentioned an unavailable alternative URL | Correct current repository address to **ahujasid/mcp-for-blender**. Plugin can run Blender Python and optional asset services. Review exact version, privacy/telemetry, origin/license, network & paid-service exposure and owner approval **before** installation |
| Concepts only | [Donchitos Claude Code Game Studios](https://github.com/Donchitos/Claude-Code-Game-Studios) (MIT) | Studio v3 already adopted the role/workflow approach | Preserve current roles and canonical Forge ledgers; do not import another Claude-native orchestra into Codex |

## Avoid importing the wrong game's features

NEONSHIFT-specific vehicle physics, drifting, garages, tuning, races and car market **do not map** onto Guildborne's original fantasy gameplay. Guildborne needs meaningful first-session quest/combat, player plus up to five hero companions, NPC life, modular body/equipment, islands, class/skill progression, inventory/Gold ownership, safe player guilds, territory and eventual market testing. Introducing ProfileStore, Fusion, Matter ECS, Wally or similar packages without examining existing runtime and save migrations would increase risk; **no runtime dependency is added** by this PR.

## Safe incremental execution

1. **This PR:** add static Codex/Studio registration preflight with fixture-only Python tests; a Studio MCP + multiplayer QA playbook; and current sources/upgrade decisions. No default game flags, imported assets, persistent schemas, market ledgers, Roblox publication, third-party install or CI credential changes.
2. **Workstation work (not completed):** verify the local Codex and Studio bridge; confirm exact staging place/permissions and actual discovered MCP tool names. Execute solo Guildborne progression then 2/4-player Studio tests. Record real Output and server snapshots, not just screen images.
3. **Further separate approval:** physical devices and *different live JobIds* on approved isolated private staging experiences. Never equate Studio clients with true cross-server behavior.
4. **Then implement playable improvements:** Human Standard/Heavy mesh/clothing fit; responsive original HUD; a complete ability VFX/animation; NPC activity; natural combat and actual quest flow. Require independent QA/human art approval.

**This research does not verify installations or games.** Local preflight unit tests exercise temporary TOML files and launcher fixtures only. Preserve production/MERGE_READINESS.md and QUALITY_GATES.md; never let a green CI badge self-approve playable completeness or publication.

Sources retrieved or checked **2026-10-16**. Verify upstream versions, source hashes, terms and published docs again before a future install, upgrade or release.
