# Guildborne

**Build. Trade. Conquer.** A planned Roblox guild-management RPG with persistent personal progression and, in later phases, a global Gold economy and territorial guild conflict.

## Current state

**Phase 4.5 hardening:** controlled epochs, bounded archives, replay-safe compaction, circuit breakers and server-only operations. 271 tests pass; the 20,000-order synthetic soak had zero invariant violations. Further private testing is supported. **Public market disabled; true cross-server and physical device acceptance pending.** Nothing published; Phase 5 not started. [Implementation](docs/PHASE4_5_IMPLEMENTATION.md) · [Studio evidence](docs/PHASE4_5_STUDIO_TEST.md) · [Operations](docs/MARKET_OPERATIONS_RUNBOOK.md).

**Previous Phase 4 Global Marketplace bounded pilot implemented and Studio-verified.** 210 automated tests pass, including all 136 Phase 3 regressions. Actual two/four-client trades and isolated cloud adapter tests passed. **True cross-server live trading NOT YET VERIFIED; not publicly ready.** No publication or Phase 5. See [implementation](docs/PHASE4_IMPLEMENTATION.md), [Studio evidence](docs/PHASE4_STUDIO_TEST.md), [invariants](docs/PHASE4_MARKET_INVARIANTS.md) and [private-server gates](docs/PHASE4_PRIVATE_SERVER_ACCEPTANCE.md).

**Earlier city and settlement slice:** City → Guild Zone, server-local island walkways, Hall +5 level cap per upgrade, housing capacity, duplicate ranked heroes, journal, offline teams and Gold Elixir. See [current rules](docs/CITY_GUILD_DISPATCH.md) and [native verification](docs/PHASE3_CITY_STUDIO_TEST.md). Robux integration is prepared but disabled pending a real Product ID. Older phase summaries below retain their historical limits.

The slice includes Personal Guild Hall levels 1–2, three timed quests, Gold/XP, weapons, tutorial, TH/EN management UI and persistence/recovery. Art Phase 1.5 is closed by user approval. Phase 1.6 expands the roster and party to five: Warrior, Archer, Priest, Knight and Mage, with ten item definitions at that phase. Visible heroes wait at an open-front tavern, selected members follow the player in the hub, and actual equipped weapons appear on their models. Expedition members return after the saved claim. See [Phase 1.6 and its validation](docs/PHASE1_6_IMPLEMENTATION.md), [the art implementation](docs/PHASE1_5_IMPLEMENTATION.md), [art direction](docs/ART_DIRECTION.md) and [Blender backlog](docs/BLENDER_ASSET_BACKLOG.md).

**Phase 1 accepted for the agreed solo-play handoff on 2026-09-28.** The user confirmed published Roblox Player rejoin, then confirmed all remaining acceptance checks passed. Two-player data/plot isolation remains **DEFERRED, not passed**, as agreed. **Phase 2.1 Combat Foundation is implemented and Studio-verified, not published**: five companion roles, starter abilities, Goblin Camp and secure Gold/XP rewards. See [implementation](docs/PHASE2_1_IMPLEMENTATION.md), [Studio/mobile evidence](docs/PHASE2_1_STUDIO_TEST.md) and [combat rules](docs/COMBAT.md). Phase 2.2 is implemented and Studio-verified, not published; see [the report](docs/PHASE2_2_IMPLEMENTATION.md).

The current automated suite has 271 tests plus strict Roblox-aware analysis and Rojo build. Original Phase 1 evidence includes Studio gameplay/native rejection tests and actual staging DataStore Stop/Play. Published Player/device/live-failure acceptance of Phase 1 is user-reported. Phase 1.6 evidence is tracked separately in its report; the new art and heroes have not been published. See the [original acceptance record](docs/PHASE1_STUDIO_TEST.md).

## Read the design

**Expansion direction:** player-controlled classes, Class 1→2→3 and special-class skill trees, shared inventory with separate player/team equipment, gathering and Build Mode, a ten-floor tower, and fantasy races. [Read the consolidated expansion plan and delivery sequence](docs/EXPANSION_PLAN.md). Phase 2.2 now implements the player starter classes; Phase 2.3 now adds inventory/equipment; the first expansion slice is now delivered through Phase 2.7. Essential animations and effects ship with each playable feature. **Phase 2.3 is implemented and Studio-verified, not published:** three equipment slots per actor, atomic transfers, a Gold shop, confirmed sale, filters and comparison. See [delivery](docs/PHASE2_3_IMPLEMENTATION.md) and [rules](docs/INVENTORY.md). **Phases 2.4–2.7 are implemented and Studio-verified, not published:** gathering, private-base Build Mode, Class 2/3 and skill builds, ten-floor tower, four special paths, three ancestries, crafting, procedural animation and skill effects. See [delivery](docs/PHASE2_4_7_IMPLEMENTATION.md) and [native evidence](docs/PHASE2_4_7_STUDIO_TEST.md). **Next: two-client island QA and published staging acceptance, followed by Elixir product setup.**

| Document | Purpose |
| --- | --- |
| [Phase 1 implementation](docs/PHASE1_IMPLEMENTATION.md) | Actual modules, corrections, security, persistence, tests and limitations |
| [Studio acceptance tests](docs/PHASE1_STUDIO_TEST.md) | Exact setup, full gameplay loop and 14 manual tests |
| [Game design](docs/GAME_DESIGN.md) | Vision, loops, mobile UX, exact slice |
| [Architecture](docs/ARCHITECTURE.md) | Boundaries, persistence, consistency, operations |
| [Economy](docs/ECONOMY.md) | Faucets, sinks, item utility, balance |
| [Marketplace](docs/MARKETPLACE.md) | Orders, escrow, recovery, reference prices, charts |
| [Guild war](docs/GUILD_WAR.md) | Organizations, war, territories, seasons |
| [Security](docs/SECURITY.md) | Threats, invariants, failure tests, incident response |
| [Economy health](docs/ECONOMY_HEALTH.md) | Metrics, event contracts, investigation |
| [Data model](docs/DATA_MODEL.md) | Versioned records, ownership, migrations |
| [Roadmap](docs/ROADMAP.md) | Small increments and release gates |
| [Platform research](docs/PLATFORM_RESEARCH.md) | Dated official sources, quotas, assumptions |
| [Validation](docs/VALIDATION.md) | Verification evidence and remaining Studio checks |

## Local workflow

Requires Roblox Studio, Git, and Rojo 7.7.0. Python 3.11+ is optional for the repository validation script. There are no runtime third-party dependencies.

From PowerShell in `C:\Work\MySelf\Guildborne`:

```powershell
.\tools\setup_tools.ps1
.\.tools\rojo\rojo.exe plugin install
.\.tools\rojo\rojo.exe serve default.project.json
```

In Roblox Studio, open **Guildborne - Staging** (place `86788611613035`), open the Rojo plugin, connect to `localhost:34872`, inspect the sync tree, and accept. The project restricts live sync to that place. Press **Play / F5**, not Run. The world and UI are created at runtime. Edit synced scripts in this repository, not Studio.

Alternatively, build with `.\.tools\rojo\rojo.exe build default.project.json --output build/Guildborne.rbxlx`, then use Studio's Open from File on the generated place. The build includes all modules and needs no live Rojo connection.

The current configuration uses **DataStore staging** for verified universe `10768425213`. The staged code was published on 2026-09-28; API access works and actual backend rejoin passed across three Studio Play sessions. A standalone local snapshot has no universe ID and will refuse persistence. For an isolated offline preview, temporarily use `StudioPersistence = "Memory"` in [Runtime configuration](src/server/Config/Runtime.luau) and rebuild; restore DataStore before staging sync/publish. Memory resets after Stop. Published servers never fall back to memory. Follow [the exact setup and tests](docs/PHASE1_STUDIO_TEST.md).

Run `.\tools\validate.ps1` for Luau tests, compilation, Roblox-aware analysis, Rojo build/source map, document/configuration checks, built-place boundary checks, and whitespace validation.

The setup script downloads checksum-pinned development tools to ignored `.tools/`; it does not change PATH or install the Studio plugin. Generated `build/` output is also ignored. There are no third-party runtime dependencies.

The universe and place IDs were read directly from the created staging place in Studio. `servePlaceIds` allows only that staging place. Keep development, staging, and production in separate Roblox experiences. Never enable Studio DataStore access against production; see [research](docs/PLATFORM_RESEARCH.md).

## Repository boundaries

`src/client` maps to `StarterPlayerScripts/Client`, `src/server` to `ServerScriptService/Server`, and `src/shared` to `ReplicatedStorage/Shared`. `src/server/Config` holds authoritative definitions and policy; `src/server/Persistence` holds platform adapters. Shared modules and public snapshots are safe for clients to inspect. Session tokens, audit records and operation receipts never replicate. Documentation, tools, and tests are outside the runtime tree.

Git is initialized on `main`; no remote, commit or CI publishing workflow was created. Staging was published manually through Studio. Phase 4 material-market trading is implemented. Player Guilds, war, territory, PvP and external settlement remain outside this phase. Phase 2.2 implementation was explicitly authorized on 2026-09-28.

## First-session loop

1. Guild → Begin tutorial.
2. Party → recruit Warrior free → select Warrior → Save selected party.
3. Quests → Trail Watch → wait → Claim: 30 Gold, 20 XP, Training Sword and 2 Herbs.
4. Inventory → equip Training Sword; Party → recruit Archer for 20 Gold.
5. Quests → Timber Escort → claim: 40 Gold, 30 XP, 6 Timber and 1 Iron Ingot.
6. Party → recruit Priest for 20 Gold → optionally select all three and save.
7. Quests → Quarry Patrol → claim: 60 Gold, 40 XP, 6 Iron Ore and Iron Sword.
8. Guild → upgrade Hall for 80 Gold plus the listed materials. Remaining Gold: 10. Tutorial completes; the Hall gains a wider facade, stone reinforcement, porch, banners and gold ridge.
9. In configured DataStore mode, leave/rejoin and verify Gold, roster, party, weapons, XP, first clears, tutorial and Hall.

Use Explore (or **M** on PC) to close/open management and walk to the four interaction points or a visible tavern hero. Repeat quests provide recovery supplies and Gold for optional Knight/Mage recruits (20 each). Select any one to five owned heroes; the five role labels do not force a composition. Equipping a weapon shortens future quest durations; an active quest's snapshot stays unchanged. Phase 2.1 adds class-specific companion combat in the Goblin Camp beyond the south exit. A larger class catalog remains future work.

Existing v1 saves and old active snapshots remain readable by Phase 1.6. After a profile recruits a new class, an older three-class server cannot read it; publish the expanded reader consistently and retain it in any rollback. Native five-class persistence QA uses a separate Studio-only DataStore namespace, preserving the existing staging profile.
