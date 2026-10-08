# Guildborne — consolidated project status

> Current2026-10-03 first-playable work is tracked in [UAT01 status](uat01/STATUS.md) and [complete work checklist](uat01/WORK_CHECKLIST.md). The phase summaries below are historical. Current baseline:462domain tests,194runtime files, three offline regions/twelve enemy victories and six claimed regional contracts. Full first release, production asset import, device/multiplayer and human UAT remain incomplete.

> Phase 4.5 update (2026-09-29): Latest: Phase 4.5 hardening, native rollover and 20,000-order synthetic soak completed with zero invariant violations. True cross-server PENDING PRIVATE PUBLISH; physical device PENDING. No public release or Phase 5.
> See [implementation](PHASE4_5_IMPLEMENTATION.md), [operations](MARKET_OPERATIONS_RUNBOOK.md), and [verification](PHASE4_5_STUDIO_TEST.md). Prior phase text is historical.


> Current Phase 4 status (2026-09-29): Latest: Phase 4 Global Marketplace bounded pilot implemented and Studio-verified; 210 tests including all 136 Phase 3 regressions. Actual two/four-client trading and isolated cloud adapter smoke executed. True cross-server live trading is NOT YET VERIFIED. Not published; no Phase 5 work.
> See [implementation](PHASE4_IMPLEMENTATION.md), [Studio evidence](PHASE4_STUDIO_TEST.md), and [invariants](PHASE4_MARKET_INVARIANTS.md). Older sections below retain historical/planned scope.


> Current decision (2026-09-29): Phase 2 is closed under the user-selected implementation/polish scope. Class 2 unlocks at level 30, Class 3 at 70; no Class 4. Actor cap is 100, unlocked at Guild Hall 20 (five levels per Hall). Existing quest/tower/path prerequisites still apply. Large shared city hub is the next Phase 3 priority. See [closure](PHASE2_CLOSURE.md).


> 2026-09-29: P0 VFX director pass adds stable IDs, compact team feedback, native fire/smoke, quality budgets and desktop/mobile cleanup probes. See [VFX implementation and limitations](VFX.md). Visual polish remains in progress; not published.

> Current update — 2026-09-28: Current addition: city spawn and portals, same-server island promenade, Hall levels 1–10 with +5 actor cap per Hall level, Quarters housing capped by Hall, duplicate-class roster, ranked tavern candidates, Main/Side/NPC journal, offline dispatch and Gold Elixir are implemented. Receipt integration is disabled pending a real product ID. See [current rules](CITY_GUILD_DISPATCH.md) and [verification](PHASE3_CITY_STUDIO_TEST.md). Earlier phase descriptions below are historical.

Updated 2026-09-28. The user authorized documentation consolidation followed immediately by Phase 2.2 implementation. The subsequent continuation delivered Phase 2.3, then the user authorized completion through Phase 2.7 with animation and skill effects. Phase 3 onward remains design direction.

## Source chats

- `01-Phase 0 & 1` — codex://threads/01a0e3aa-86e1-7d82-a9fa-fbb630ab6f5b: solo Phase 1 accepted by the user, including published Player rejoin. Two-player isolation remains deferred.
- `02-Connected Roblox Studio MCP` — codex://threads/01a0e72f-e775-70c2-bbd2-9cc4d063b72b: official Studio MCP connected to Guildborne staging; read/execute/output/screenshots available.
- `03-Art Phase 1.5 & 1.6` — codex://threads/01a0e734-c114-70c3-a254-4985079e3575: Phase 1.5 closed; five visible heroes, tavern, followers and equipped visuals added in 1.6. The five companions are **in addition to the player**. Party selection is free within the current five-hero roster; duplicate-class recruits require a later roster redesign.

## Consolidated direction

The player chooses a starter class and fights alongside up to five AI companions. Class tiers 1→2→3, Epic/Legendary prestige and Secret unlock conditions are distinct concepts. Each actor eventually has its own skill build and equipment assignment, with shared account inventory. Resource gathering feeds private-base Build Mode; the first tower contains ten floors. Fantasy races are separate from class. Essential animation/VFX accompany playable systems.

See [expansion plan](EXPANSION_PLAN.md) and [delivery sequence](ROADMAP.md): 2.2 player classes → 2.3 inventory/equipment → 2.4 gathering/building → 2.5 Class 2/skill trees → 2.6 tower → 2.7 Class 3/special classes/races.

Future ideas from the art chat: customizable crest/banner/shield/shirt, expanded world, weekly tavern recruitment and F–SSS hero ranks. These remain backlog, with no random-pack sales or real-money trading implemented or authorized. The current economy uses game Gold; marketplace and monetization keep their separate future review gates.

## Current delivery boundary

Phase 2.1 is implemented and Studio-verified, not published. Phase 2.2 is implemented and Studio-verified, not published. See [implementation](PHASE2_2_IMPLEMENTATION.md) and [Studio evidence](PHASE2_2_STUDIO_TEST.md). Phase 2.3 is implemented and Studio-verified, not published: [delivery](PHASE2_3_IMPLEMENTATION.md), [Studio evidence](PHASE2_3_STUDIO_TEST.md). Phases 2.4–2.7 are implemented and Studio-verified, not published: [delivery](PHASE2_4_7_IMPLEMENTATION.md), [Studio evidence](PHASE2_4_7_STUDIO_TEST.md). The next phase is Phase 3 online activities; multiplayer validation is required before its rollout. Existing staging player data must remain untouched by QA: migration/combat tests use isolated namespaces. Published-client, physical-device and multi-player tests are not implied by Studio evidence.
