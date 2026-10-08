# Phase 1 implementation

Updated 2026-09-28. Code scope: Phase 1 only. **Accepted for the agreed solo-play handoff.** Agent verification covers implementation, 37 automated tests, Studio gameplay/rejections and actual DataStore Stop/Play rejoin. The user subsequently confirmed published Player rejoin and all remaining checks as passed; these are user-reported results. Two-player data/plot isolation is deferred, not passed. See the [acceptance record](PHASE1_STUDIO_TEST.md).

## Implemented systems and files

| Boundary | Important files | Actual behavior |
| --- | --- | --- |
| Bootstrap | `src/server/ServerBootstrap.server.luau`, `src/client/ClientBootstrap.client.luau` | Explicit dependencies, validated/frozen content, lifecycle, heartbeat, shutdown |
| Content | `src/server/Config/Content.luau` | Exactly 8 items, 3 adventurers, 3 quests, 1 enemy, reward/cost/progression parameters |
| Runtime policy | `src/server/Config/Runtime.luau` | Studio mode, universe allowlist, retries, leases, logging and analytics |
| Protocol | `src/shared/Network/Protocol.luau` | Exact intent schemas, bounded identifiers/arrays, finite revisions, extra-field rejection |
| Types/utilities | `src/shared/Types/Domain.luau`, `src/shared/Util/TableUtil.luau` | Domain aliases, deep copy/equality, numeric checks, freeze |
| Economy | `src/server/Services/EconomyService.luau` | Gold boundary; item grant/consumption with reason events and capacity checks |
| Adventurers / party | `AdventurerService.luau`, `PartyService.luau` in server Services | Deterministic recruitment, compatible owned equipment, unique owned party members |
| Quests / Hall | `QuestService.luau`, `PersonalGuildService.luau` in server Services | One persisted timed run; atomic claims; one Hall upgrade with costs/prerequisites |
| Pure rules | `src/server/Systems/Commands.luau`, `Progression.luau`, `ContentValidator.luau` | Copy-based transactions, XP/stats, resumable tutorial, catalog checks |
| Profile schema | `src/server/Systems/ProfileSchema.luau` | Versioned defaults, validation, sequential migration mechanism |
| Persistence | `src/server/Services/PlayerDataService.luau`, `src/server/Persistence/RobloxStore.luau`, `MemoryStore.luau` | Leased commits, uncertain-write recovery, audit export, isolated Studio memory |
| Networking/view | `src/server/Services/NetworkService.luau`, `src/server/Systems/ViewProjection.luau` | Two RemoteEvents, rate-limited commands, owner-only public snapshots |
| World | `src/server/Services/WorldService.luau` | Simple plot/spawn per player, Hall and four interaction markers |
| Client | `src/client/Controllers/SliceController.luau`, `src/client/UI/SliceUI.luau` | HUD, tutorial, four tabs, rewards, inventory/equipment, notifications, responsive scrolling |
| Localization | `src/shared/Config/Localization.luau` | Thai/English UI, content descriptions, tutorial and errors; validated profile language preference |
| Analytics | `src/server/Services/AnalyticsAdapter.luau` | Injected providers, independent durable audit, optional Roblox custom-event provider |
| Validation | `tests/run.luau`, `tools/validate_repository.py`, `tools/validate.ps1` | Domain/failure scenarios, native analysis/build, documentation checks |

Players choose a party and quest, wait for the server deadline, then claim configured results. Goblin Scouts are the sole encounter archetype. There is no combat simulation, enemy navigation or damage remote. XP raises level every 50 accumulated XP, capped at level 10. Weapon attack modestly shortens a new quest's timer, with a 10-second minimum.

## Minimal corrections to Phase 0

1. **Eight useful items.** Phase 0 reserved Herb, Iron Ingot and Iron Sword without gameplay use. The Phase 1 request requires useful items. Trail Watch first-clear additionally grants 2 Herbs; Timber Escort grants 1 Iron Ingot; Quarry Patrol grants an Iron Sword. Hall level 2 consumes Herbs/Ingots alongside the original 80 Gold + 6 Timber + 6 Ore. All eight items are obtainable/useful without crafting, vendors or additional definitions. Gold remains 130 earned − 40 recruitment − 80 Hall = 10.
2. **Pure injected modules.** Small feature services are factories with explicit dependencies, tested through standalone Luau instead of a framework/test place. A new server-only Persistence directory holds adapters. No runtime dependency framework was added.
3. **Schema detail.** `recruitedClasses` is a string-keyed boolean map instead of the illustrative empty array. Persist `welcomeSeen`, `everEquipped`, `tutorialCompleted` and `quests.lastResult` for guidance/result recovery. Adventurer names/base stats are stored with class identity. Schema is v1 because Phase 0 had no live records.
4. **Equipment utility.** Weapon bonuses shorten future expeditions using configured attack-per-second savings. Active party/reward/deadline snapshots remain unchanged. This gives weapons purpose without Phase 2 combat.
5. **Audit export.** Per-player pages of 32 immutable events persist before profile-outbox acknowledgment so the bounded buffer can drain during repeated play.

All long-term systems remain design-only.

## Security

RemoteEvent `GuildborneRemotes.Command` accepts `{version, requestId, action, revision, args}`. `GuildborneRemotes.State` is server-to-client snapshots/results only. Identity comes from OnServerEvent's Player argument. The client cannot choose an account, grant values, timestamp, completion flag, item ownership, guild level, or arbitrary callback.

Actions: GetState, RetryLoad, RetrySave, BeginTutorial, SetLanguage (only `en` or `th`), Recruit, UpdateParty, StartQuest, CompleteQuest (runId), EquipItem (instanceId + adventurerId), UpgradeGuildHall. Read/recovery actions cannot choose economic values. Runtime validation complements Luau types and rejects extra fields.

Per-player admission is 6 burst / 2 replenished tokens per second. One profile write is in flight at a time; other mutations receive Busy. The native adapter checks DataStore budget. Identifiers are at most 64 allowed ASCII characters, parties at most three entries, revisions finite nonnegative integers. Capacity errors discard the whole candidate; partial Gold/XP grants never survive an item-grant rejection.

Quest start snapshots server reward, content revision, party stats and deadline. Completion checks exact active run and server time. Reward, first-clear fact, XP, inventory, Gold, audit and claimed-through sequence commit together. Duplicate successful command IDs return the saved result without mutation. Same ID/different payload is rejected; stale revisions cannot spend twice. Semantic run/recruit/Hall state remains protected after the 32-entry response cache rotates.

Equip checks ownership, class compatibility and unique assignment. Repeated equip does not duplicate items. Hall level 2 cannot upgrade again. World prompts only open a screen after player/distance checks; they award nothing. Catalog display data is public, but client copies cannot change server authority.

## Persistence and recovery

`GB_Player_<environment>` stores `p:<userId>` envelopes with schema, semantic revision, session owner/epoch/expiry, data, recent outcomes and audit outbox. Every economic command checkpoints through UpdateAsync before UI success. `GB_PlayerAudit_<environment>` stores `p:<userId>:<page>` audit pages. Profiles/pages have a 128 KiB application ceiling.

Defaults are created only in a successful absent-key acquisition. Unknown schemas/malformed data are preserved without overwrite. Migrations are explicit pure version-to-version functions; v1 has no legacy population. Changes to stored base stats/XP definitions may need migration too.

Ownership uses a random session token, monotonic epoch and 180-second lease. Heartbeats run about 50 seconds apart. New economic commands stop 30 seconds before expiry unless refreshed. Writes verify stored owner/epoch; normal mutation/recovery cannot extend an expired lease. A stale server stays fenced after a newer owner releases the key.

Transient calls retry up to three times with exponential delay/jitter. UpdateAsync transforms can rerun without analytics/random reward side effects. An uncertain write retains the immutable pending command and previous confirmed UI state. Retry save/heartbeat repeats the same operation ID: persisted receipt wins if it committed; otherwise it may commit once. Other progression remains blocked. After a crash, the next acquired profile loads whichever revision actually committed.

Audits export by immutable sequence/page; confirmed archive writes precede profile acknowledgment/pruning. Export failure retains evidence; 128 pending events stops new event-producing mutations until drainage. An uncertain archive acknowledgment can replay export, not economic effects. No global counter is written per action.

PlayerRemoving/BindToClose stop admission, try pending recovery and release ownership. Drain time is bounded. Hard crashes rely on economic checkpoints and lease expiry, not guaranteed shutdown saves. A crashed session may delay login up to lease expiry. No force-unlock/reset remote exists.

## Studio and published modes

Current StudioPersistence is `DataStore`, restricted to verified staging universe `10768425213` (place `86788611613035`). For an isolated offline preview, a temporary `Memory` setting needs no publishing/API access and is labeled **not saved after Stop**. It retains data only while that server process lives. It is not persistent storage. Restore DataStore before staging sync/publish.

For real save/load, publish a separate test experience, allowlist its universe ID as `dev` or `staging`, choose StudioPersistence `DataStore`, and enable Studio API access on that test experience. Published servers always need an allowlist entry and never fall back to memory. Studio refuses `prod` entries even with API access enabled. Failed DataStore loads never become default/memory saves. [Exact setup](PHASE1_STUDIO_TEST.md)

## Tutorial, UI and world

Tutorial guidance derives from persisted accomplishments. Begin tutorial is idempotent; Continue guidance reopens the relevant tab. Missed UI dialogs do not permanently trap the user. Ordinary screens remain usable independently of tutorial order.

Guild, Party, Quests and Inventory tabs cover the required loop. HUD shows Gold/Hall; quest screens show requirements, rewards, countdown and saved result. UI uses 48–52 px buttons, wrapped text, safe-area insets, scrolling and a compact landscape layout. Explore / M reveals the plot. Server completion checks remain authoritative if the display timer drifts.

Guild provides a TH/EN switch. `settings.language` is an optional backward-compatible v1 profile field; existing records without it use English. A server-validated SetLanguage command checkpoints the choice. Thai covers gameplay UI, content names/descriptions, guidance and known errors; world signs/prompts show both languages. Localization placeholders and all catalog entries are tested. Preference recovery passes injected-store tests and actual DataStore Stop/Play rejoin in Studio for both Thai and English.

Studio testing exposed the default player list covering Explore and polling replacing controls during interaction. The client now hides that list, keeps controls stable for unchanged snapshots, resets scrolling on tab changes, and only clears a pending action when one actually exists.

Device Emulator testing additionally exposed orientation and touch-overlay issues. The Rojo project explicitly sets StarterGui.ScreenOrientation to Sensor. Management hides Roblox touch movement controls and restores them on Explore; the ScrollingFrame explicitly receives input. Compact landscape moves guidance into the scroll area to leave more room for actions. The 360×800/800×360 emulator route exercised Thai recruitment, party, rotating an active countdown, claiming and equipping. Exact target dimensions and physical touch remain separate checks.

Anchored primitive plots have private spawn assignments, a Hall, and labeled Quest Board, Hall, Party and Inventory markers. The Hall roof changes on upgrade. Other plots can be visible, but cannot grant access to their owners' progression.

## Analytics and debugging

Foundation events: session_started/ended, tutorial_started/completed, adventurer_recruited, party_created/updated, quest_started/completed, item_acquired/destroyed, guild_upgraded, weapon_equipped, gold_created/destroyed. Economic events also commit to the audit outbox. Session events are best-effort; a crash may omit session_ended.

Studio debug logging is the default provider. Optional Roblox custom events are disabled until configured and send only from published servers. Provider/logging failures do not fail a committed action. Telemetry is best-effort, not an exactly-once/replayed analytics pipeline; the archive is accounting evidence. Studio logs omit account IDs, lease tokens and raw payloads. Production verbosity is off.

## Executed validation

- 37 Luau tests passed, including full onboarding, bilingual placeholders/catalog coverage, language validation/rejoin/legacy records, and a 400-step deterministic adversarial command sequence.
- Catalog counts/IDs/references, invalid quests, early/duplicate claims, forged fields, unowned/incompatible weapons, Hall replay, nonnegative Gold and full-inventory rollback pass.
- Failed/unknown loads/saves, callback replay, crash/rejoin, ownership takeover, pending shutdown, audit failure/capacity, migrations and post-cache-eviction replay tests pass.
- Rojo 7.7.0 build/source map, Luau 0.740 compilation and Luau LSP 1.70.0 Roblox-aware strict analysis pass. The CLI's sourcemap-watcher warning is informational, not a source diagnostic.
- The final verification command is `tools/validate.ps1`, including documentation/configuration, built-place and whitespace checks.

Full run on 2026-09-28: all 37 scenarios passed; required documents, local links, JSON/TOML and the JSON example validated; all 26 strict runtime sources compiled and passed Roblox-aware analysis. The generated place contains two executable bootstraps and 24 ModuleScripts, matching the source map exactly. `tools/setup_tools.ps1` also completed checksum verification/extraction successfully. Outputs are `build/Guildborne.rbxlx` and `build/sourcemap.json` (ignored generated files).

The injected store simulates failures; it does not certify Roblox infrastructure. Mocked tests are not Studio Play tests.

## Studio evidence and remaining acceptance

The earlier blank startup shell was resolved in a later session. Computer Use opened the generated place and ran local Play. The UI route completed recruitment, party, all three quests, rewards, Training Sword equip and Hall 2. A separate native client probe exercised actual RemoteEvents with real quest deadlines, early/duplicate claims, replay/conflicting IDs, forged reward fields, invalid party/equipment and repeated Hall upgrades. It ended with 10 Gold, Warrior XP 90/level 2, all three recruits/first clears, Hall 2, tutorial complete and Thai selected. See [captured native Output](evidence/studio-native-2026-09-28.txt) and the executable procedure in `tests/studio_client_probe.luau`.

These runs used Studio Memory. They establish local client/server gameplay and rejection behavior, not DataStore durability. [Studio procedures](PHASE1_STUDIO_TEST.md) record remaining subcases. Guildborne - Staging was subsequently created, its real IDs read in Studio, and the DataStore configuration published as version 4 at 15:08:00 Bangkok on 2026-09-28. Roblox's universe endpoint confirms Private audience. After the user enabled API access, three Studio Play sessions verified exact restored states at revisions 7 (Thai active quest) and 17 (English completed Hall), then saved Thai at revision 18. Published-client rejoin and remaining live failure checks were subsequently accepted based on user confirmation, without additional agent-observed evidence. See the checklist for the evidence distinction.

## Known limitations, risks and deferred work

- No known duplication path remains in tested domain scenarios; live two-server and backend behavior still require verification.
- Desktop rendering, spawn, TH/EN switching and the local loop were observed. Remaining target-device and multiplayer checks are recorded individually; responsive code is not visual certification.
- Staging must measure request latency/budgets, key sizes and archive growth. Audit retention/deletion tools and broad operational dashboards are deferred until before public launch.
- Lease expiry can cause a temporary rejoin wait. There is no unsafe force takeover.
- Full inventory/wallet/XP caps pause claims without loss. No salvage/expansion/account-repair UI exists; ordinary slice play stays far below caps.
- Stored stat/content changes need compatible migrations; live configuration hot reload is absent.
- Optional Roblox analytics is off; session telemetry can be lost on crashes.
- Combat/crafting, marketplace/trading, Player Guilds, war, territory, PvP, bosses, monetization and settlement remain absent.

**Definition of Done:** met for the agreed solo Phase 1 handoff, combining agent-verified evidence and explicit user acceptance of remaining checks. Two-player isolation remains deferred. This does not certify multiplayer/public release. Phase 2 is not started and requires explicit approval.
