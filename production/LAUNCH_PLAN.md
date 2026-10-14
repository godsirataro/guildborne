# Guildborne Public launch execution — 2026-10-14

Status: **LOCAL CANDIDATE IN PROGRESS; NOT PUBLIC READY**. This is the current release scope and supersedes older all-at-once launch assumptions. Execution details and evidence remain in `launch/` and `integration/`; no historical result is promoted to current acceptance.

## Approved release boundary

Latest local increment: [world boundary and Lv1–35 route](launch/integration/WORLD_ROUTE_UPDATE.md). On candidate55404c19, a fresh single-client Memory run completed Novice6, Warrior/Hall founding, both main arcs through35 and Hall4 using ordinary inputs. Full launch acceptance remains pending; see the linked report for class, cloud, asset and device limits.

Continuation: [Borin and learned Berserker art](launch/integration/BORIN_SKILL_UPDATE.md) verifies normal craft-two/claim/Deepforge travel, one real player Class2 art cast, and a separate no-duplicate reward probe on the same candidate. Broader acceptance remains pending.

Local integration → Closed Beta → Release Candidate → Public Lv1–35 → expansion.

Public requires four cosmetic races and all 13 catalog presets; Class1 at10 and Class2 at35 with actual prerequisites; two main arcs; player plus five heroes; personal island/Hall/build/visits; six-human Party and shared Solo/Party PvE with divided encounter EXP/loot; Premium shop, Battle Pass, free daily rewards. Guild means one human owner plus NPC heroes, never a human-member organization. Human membership belongs to post-launch Federation. PvE paid buffs never bypass class/Hall/content gates and have no war effect. Player market and wars remain closed and cannot block the main route. Preserve earned legacy progression.

Authoritative scope correction: [Party6 and shared PvE contract](launch/integration/PARTY6_PLAN.md). Party6 is required for first Public; implementation is pending. Earlier references to basic human-member Player Guild are superseded. Six-player and mixed-population acceptance are additional gates; prior readiness estimates used the smaller scope.

Beta's two silhouettes per race map to existing IDs: Human STANDARD/HEAVY; Elf GRACEFUL/STURDY; Orc STANDARD/HEAVY; Dwarf COMPACT/STOUT. These are candidate mappings, not fit/import approval; never invent Elf/Dwarf STANDARD IDs. Public adds HUMAN_SLIM/ATHLETIC, ELF_RANGER, ORC_LEAN, DWARF_BROAD.

## Implemented in this source increment

- Explicit local-only release resolver requires LaunchCandidate + Studio + PlaceId0 + GameId0 + Memory. Two active arcs, Hall4, future destination/task/tower/Class3 request restrictions. Runtime production configuration is unchanged.
- Full six-arc campaign catalog validates historical saves while only the selected two arcs can advance. Completed future saves retain XP, choices and rewards; presentation recognizes active completion.
- Player Class2 requires the mentor story. Subject-owned hero Class2 proof and trial lifecycle are implemented and scoped-tested; the normal hero UI route through Lv35 remains a launch acceptance gate. See `launch/integration/HERO_MENTOR_UI_UPDATE.md` for the latest candidate and limits.
- Seven-step free UTC daily cycle; missing days retain sequence. Six story-earned season reward tiers. Claims use the existing command transaction and profile store, with bounded receipts and safe UI projection. Premium ownership and purchase activation remain disabled.
- Native Thai/English reward screen, server error explanations and a separately built Memory candidate. These are preview rewards, not a finalized priced Battle Pass.

## Ordered work and acceptance

| Gate | Owner role | Required work | Exit evidence |
|---|---|---|---|
| 0 Baseline | technical director / QA | Freeze reviewed revision, source hashes, local/staging/production identity and namespaces; check account and asset ownership | Reproducible build, passing baseline, independent review; no dirty-tree receipt presented as clean release |
| 1 Main route | gameplay / quest / UI | Fresh Novice through two arcs to35, every class and hero mentor, Borin two ingots and Deepforge, ordinary input, loading/error/save retry TH/EN | Unassisted route without grants, profile edits or skipped time; leave/rejoin; no dead end |
| 2 Presentation | art / rig / animation / audio | Beta8 then Public13 bodies, modular fit matrices, runtime imports, all weapon/class action mappings, real licensed audio, readable full-party VFX, NPC/city polish | Imported asset ownership/load proof, recordings/listening, cancellation cleanup, fit per body and outfit |
| 3 Launch systems | systems / guild / combat / market / QA | Personal Hall/build/visit permissions, human Party6, shared Solo/Party encounters and conserved reward allocation, final catalog/SKUs/durations/caps, receipt routing, verified Premium entitlement, dated season retention/migration | Party lifecycle and shared-reward fault/replay tests; 2/4/6 clients and mixed eligible outsiders; receipt delivery/rejoin; no duplicate/lost value |
| 4 Closed Beta | QA / performance / localization | Real2 then4 then6 clients, up to30 heroes for the full Party scenario plus separately bounded mixed outsiders; old/new/bad saves; distinct live JobIds; Android/iOS30min; fresh TH/EN testers | Separate Studio/cloud/device/human results; target30FPS on declared minimum hardware, bounded memory, measured total instance capacity, no critical bugs |
| 5 RC/Public | release lead / owner | Freeze same tested revision; actual footage/icon/thumbnail, maturity/eligibility, approved universe and products, rollback owner/window | Human art/UAT and scoped final release decision tied to build; validated publish permissions |
| 6 First week | release / growth | Observe join/save/delivery/tutorial/death/FPS signals,72h close coverage, daily first-week review | Actionable incident ledger and stable delivery; no paid ads by default |

No fabricated date or overall completion percentage: these gates require actual play/device/cloud evidence. Installed tooling or generated meshes do not pass them.

## Outstanding launch contracts

1. Hero-owned Class2 source implemented; normal hero UI progression and XP/material pacing through35 still require acceptance. See latest hero mentor increment.
2. Appearance runtime asset bindings for all13, clothing cages/fit, actual audio IDs and listening. Local EditableMesh previews do not satisfy published asset delivery.
3. Commerce: permanent Pass versus repeatable Developer Product versus season entitlement; one server receipt route; fulfillment survives disabled sales prompts and response loss. Final prices and IDs remain unset. Premium preview config is false.
4. Season rollover must retain old claim receipts; changing SeasonId alone is forbidden. Daily uses server day and no missed-day loss.
5. Persistent staging environment policy, account/group ownership, namespaces and migrations need actual verification; local flags cannot activate cloud.
6. World prompts, journals and class UI must communicate release restrictions, not merely rely on server rejection.

## Rollback and incident handling

Stop new offers if delivery/entitlement is incorrect, preserve unresolved receipt queues, and reconcile authoritative ledgers. Restrict affected systems for duplication/corruption; never guess compensating value or erase profiles. Rollback revision must read schemas already written. Keep market disabled until separate escrow/cross-server qualification. Record incident owner, affected build, timestamps, evidence and recovery checks.

## Post-launch scope retained

Continue chapters to Class3 at70 and level100. Guild war begins bounded with roster locking, one-time outcomes and no paid buffs. Federation supports multiple guilds plus independent participants, delegated command and withdrawal. Territory benefits have duration/caps; capacity is measured before promising player counts. Market opens separately after escrow/recovery/cross-server qualification.

## Tool and asset backlog retained

Use the94-option unified free catalog and provenance registry, not blind imports. Keep Blender Python and existing Studio/Forge/skills as the primary pipeline. Trial Blender MCP, Codebase Memory, Graft and Agent Reach individually with reviewed pinned code, licenses, free backends, measured time/rework and fallback. Confirm the exact OpenDesign repository before adoption.

HyperFrames, Remotion, GSAP Skills, Animate, Claude Motion, Product Launch Motion, Claude Remotion Skill, Motion Graphics Skills and OpenMontage are video/marketing research using real game footage; they do not replace runtime rig/animation work. Agency Agents, Diagram Design, Scientific Agent Skills and grill-doc/grill-me stay selectively reviewed workflow candidates. No arbitrary skill-pack install or unreviewed network script execution. Terminal/background CLI and model routing use bounded tasks and explicit shared ownership, not unattended spending.

Auto-learn records evidence and human feedback after tasks; only held-out evaluation and an independent reviewer can promote skills. Learning cannot alter publishing/spending authority or server-owned economy.

Source reports: `launch/content.md`, `launch/rewards.md`, `launch/integration/`; earlier evidence: `integration/IMPLEMENTATION.md`, `integration/review-status.json`; research: `research/TOOLS_FREE_2026-10-14.md`, `research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.md`.

Latest hero mentor increment: [native UI and source evidence](launch/integration/HERO_MENTOR_UI_UPDATE.md), candidate82674727,752 automated tests before the separately analyzed Controller localization delta; ten synthetic native UI cases. Normal hero route and full launch gates remain pending. Earlier candidate41e341d4 world fixtures are historical evidence in HERO_MENTOR_UPDATE.md.
