# Guildborne full-game delivery execution — GL-2.0 / 2026-10-15

## Latest owner direction — full-game first Public, 2026-10-15

The user now requires **all systems, Lv100/Class3, Federation, war, territory and player market before first Public**. [GL-2.0 full-game phase roadmap](design/integration/FULL_GAME_GOLIVE_GL2_TH.md) is the current owner-review plan. Lv35 becomes an internal/closed milestone. The Lv35 launch boundary and post-launch classifications below are historical and superseded as delivery targets; source flags and evidence remain unchanged until reviewed implementation. Detailed GL-2.0 acceptance/counts await sign-off; publication and commerce activation remain separately scoped.

## Current execution register

[GL-2.0 scope matrix](design/integration/GL2_SCOPE_MATRIX.json), [feature registry](design/features.json) and [backlog](launch/backlog.json) use P0–P13. Every required gameplay group must pass before Public; Lv35 is internal Alpha. Current runtime selection remains the isolated Lv35 candidate until later reviewed integration. See [P0 source inventory and open decisions](design/integration/GL2_SOURCE_INVENTORY.md).

Run `python production/design/integration/validate_gl2.py` to detect scope/dependency regressions. A metadata pass does not grant gameplay or release acceptance. P0 remains open until named content, dependencies, capacity/device targets and proposed counts are resolved.

## Historical Lv35 candidate and evidence (superseded delivery scope)

Historical reference: [GL-1.0 plan](design/integration/GOLIVE_MASTER_PLAN_TH.md) described the former Lv35-first approach. GL-2.0 supersedes that delivery boundary. Neither document grants publication permission.

Status: **LOCAL CANDIDATE IN PROGRESS; NOT PUBLIC READY**. The sections below record the previous Lv35 candidate and its evidence. Their launch/post-launch labels are historical, superseded by GL-2.0; they do not define the current Public boundary. Execution details and evidence remain in `launch/` and `integration/`; no historical result is promoted to current acceptance.

## Historical candidate boundary (P2 internal Alpha)

Latest local increment: [world boundary and Lv1–35 route](launch/integration/WORLD_ROUTE_UPDATE.md). On candidate55404c19, a fresh single-client Memory run completed Novice6, Warrior/Hall founding, both main arcs through35 and Hall4 using ordinary inputs. Full launch acceptance remains pending; see the linked report for class, cloud, asset and device limits.

Continuation: [Borin and learned Berserker art](launch/integration/BORIN_SKILL_UPDATE.md) verifies normal craft-two/claim/Deepforge travel, one real player Class2 art cast, and a separate no-duplicate reward probe on the same candidate. Broader acceptance remains pending.

Historical sequence (retired): local integration → Closed Beta → Release Candidate → Public Lv1–35 → expansion. Current sequence: P0 scope → concurrent P1–P8 delivery → P9 full integration → P10 Closed Beta → P11 RC → P12 full-game Public → P13 stabilization.

The historical Lv35 candidate covered Class1 at10/Class2 at35, two main arcs, player plus five heroes, personal island/Hall/build/visits, Party6/shared PvE and reward previews. That candidate remains useful for P2 internal Alpha. First Public now additionally requires the full GL-2.0 campaign/Lv100/Class3, living Guild/endgame, Federation, war, territory and qualified player market. Personal Guild still has one human owner and NPC heroes. Paid PvE buffs cannot bypass progression or affect war; the free main route cannot require market participation. Preserve earned legacy progression.

Authoritative scope correction: [Party6 and shared PvE contract](launch/integration/PARTY6_PLAN.md). Party6 is required for first Public. [Local membership increment](launch/integration/party-integration/REPORT.md) implements lifecycle and native UI; shared encounters/travel/rewards and real multiplayer acceptance remain pending. Earlier references to basic human-member Player Guild are superseded. Six-player and mixed-population acceptance are additional gates; prior readiness estimates used the smaller scope.

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

## Former post-launch scope — now required P4/P6/P7 before Public

Complete chapters to Class3 at70 and level100 in P4. Federation and bounded war with roster locking, one-time outcomes and no paid buffs are P6. Territory and the Gold/material market are P7. Capacity is measured before promising player counts; market requires escrow/recovery/cross-server qualification. Any missing acceptance blocks full-game Public.

## Tool and asset backlog retained

Use the94-option unified free catalog and provenance registry, not blind imports. Keep Blender Python and existing Studio/Forge/skills as the primary pipeline. Trial Blender MCP, Codebase Memory, Graft and Agent Reach individually with reviewed pinned code, licenses, free backends, measured time/rework and fallback. Confirm the exact OpenDesign repository before adoption.

HyperFrames, Remotion, GSAP Skills, Animate, Claude Motion, Product Launch Motion, Claude Remotion Skill, Motion Graphics Skills and OpenMontage are video/marketing research using real game footage; they do not replace runtime rig/animation work. Agency Agents, Diagram Design, Scientific Agent Skills and grill-doc/grill-me stay selectively reviewed workflow candidates. No arbitrary skill-pack install or unreviewed network script execution. Terminal/background CLI and model routing use bounded tasks and explicit shared ownership, not unattended spending.

Auto-learn records evidence and human feedback after tasks; only held-out evaluation and an independent reviewer can promote skills. Learning cannot alter publishing/spending authority or server-owned economy.

Source reports: `launch/content.md`, `launch/rewards.md`, `launch/integration/`; earlier evidence: `integration/IMPLEMENTATION.md`, `integration/review-status.json`; research: `research/TOOLS_FREE_2026-10-14.md`, `research/GUILDBORNE_UNIFIED_FREE_CATALOG_2026-10-14.md`.

Latest hero mentor increment: [native UI and source evidence](launch/integration/HERO_MENTOR_UI_UPDATE.md), candidate82674727,752 automated tests before the separately analyzed Controller localization delta; ten synthetic native UI cases. Normal hero route and full launch gates remain pending. Earlier candidate41e341d4 world fixtures are historical evidence in HERO_MENTOR_UPDATE.md.

## Complete expansion update

See [the reconciled twenty-theme plan](design/EXPANSION_PLAN.md) and feature registry. Tactical AI and analytics are the first implementation slices; Combo, FTUE and living Guild have explicit contracts. Shared PvE/conserved settlement remains mandatory before Public. This update does not mark source changes as runtime/device acceptance.
