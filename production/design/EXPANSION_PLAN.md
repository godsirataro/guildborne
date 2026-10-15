# Guildborne complete expansion implementation plan — 2026-10-14

Latest delivery direction (2026-10-15): [GL-2.0 full-game Go-live](integration/FULL_GAME_GOLIVE_GL2_TH.md) brings all system groups, Lv100/Class3, Federation/war/territory and player market before first Public. The Lv35-first boundary and deferred-system classifications below are historical; the existing source/evidence remains valid only within its recorded scope. P0 reconciles task/feature manifests before implementation; no runtime activation is implied.

Current execution: [GL-2.0 scope matrix](integration/GL2_SCOPE_MATRIX.json) maps all twenty themes and full-game system groups to owners, dependencies and acceptance. GL-1.0 is historical. Detailed content counts remain proposals; source/fixture evidence and existing approvals remain separate.

The attached 20-theme proposal is retained verbatim in source-proposal.txt. This reconciled plan governs implementation; proposal examples and P0/P1 labels are not evidence of shipped features. features.json tracks all twenty themes with ownership, dependencies and release classification. None is approved public marketing copy.

## Fixed Public boundary

Lv1–100; six arcs / 36 campaign steps plus Novice6; Class3 at70 and four special paths; Hall through20; four cosmetic races and thirteen presets; one human owner with up to five NPC heroes; Party6 and shared PvE; living Guild/Bond/research/events/endgame; Federation, war, territory and Gold/material market. Commerce, website, world/art, TH/EN and device/cloud qualification remain required. Lv35/two arcs is P2 internal Alpha. Party lifecycle alone does not complete shared travel, encounters or settlement. Counts proposed in GL-2.0 are not silently accepted by this classification.

## Execution sequence

1. Integrate bounded tactical commands and sanitized milestone analytics into the existing modules. Balanced preserves existing targeting; Defensive protects the leader within a bounded range; Hold captures a server position; Regroup uses safe role positions. No profile migration or external analytics activation.
2. Validate command readability and FTUE through ordinary play. Borrowed tutorial allies cannot grant permanent recruitment, class proof or Hall eligibility. The proposed 5–30 minute targets are hypotheses to measure.
3. Prototype one Knight Taunt → Mage Fireball → Archer Piercing Shot combo using existing skills and authority. Fireball currently is single-target and Piercing Shot has no weak-point mechanic. Timing/bonus remain proposed. Preserve canonical Rowan as Warrior. See TEAM_COMBO_DESIGN.md.
4. Implement shared encounter ownership, eligibility snapshots and durable conserved reward settlement, then shared travel. This mandatory Public work must not wait for Bond, Research or a website. Prove replay/crash/disconnect recovery before real two-, four- and six-client acceptance.
5. Prototype Training Ground and Strategy Table on existing Hall systems; practice gives no campaign XP, loot or proof. Expand living Guild/bond/research only after core-loop acceptance.
6. In parallel from P1, deliver the city square/tavern/forge visual benchmark and expand world/assets through P8. Complete Lv35–100/P4, living Guild/P5, Federation/war/P6 and territory/market/P7 with their authority and economy checks. Website uses reviewed real gameplay evidence.
7. P9 integrates all required streams into one full-game candidate. P10 qualifies real players/devices/cloud; P11 freezes and reviews that same build; P12 requires scoped owner release authorization. P13 covers the first72hours and first-week incidents. No missing full-game stream moves after Public merely to preserve a date.

## Implementation and evidence

The tactical/analytics integration is followed by scoped shared-PvE tasks for identity, immutable settlement, encounter scheduler, participation, durable recipient claims, optional fenced combat phases and the HeroService coordinator. There are 55 task definitions, 33 roles, 31 skills and 10 workflows; definitions are not completed tasks. Existing Forge/Studio and the one coordinator ledger remain the orchestration system. Agent workers own separate files, with an independent source reviewer. The injected shared scheduler is a private integration seam, not a second active game loop.

Current source slices are implemented; automated integration and runtime acceptance are recorded separately in integration/REPORT.md. Existing party evidence remains candidate-specific. No overall readiness percentage is inferred from source/test counts.

Latest completed full baseline:883 automated tests and repository checks passed for optional actual-profile reward wiring, terminal encounter lifecycle and Studio-only Novice identity injection (`validation-shared-travel.log`). Five synthetic physical heroes passed tactical and injected-hazard fixtures. Seven synthetic owners separately exercised shared eligibility/settlement and v2 frozen-actor durable claim replay over isolated Memory stores. Actual local Party clients reached six members; a seventh stayed solo, full-party admission was rejected, leadership authority and disconnect grace were observed, and duplicate disband returned the same result. Two clients joined through visible UI; later clients used scripted real client remotes. Profile revisions remained0 and the test session was closed. See integration/PARTY_REAL_CLIENTS.md for candidate identity and limits.

The optional combat context passed independent review and Studio fixtures with two synthetic owners, ten NPC heroes and two leader rigs. Actual effects included12 damage and34 cross-owner healing, LOS rejection and cooldown protection. Injected injury proves healing behavior, not reward participation. No profile rewards were granted in that fixture. Both negative-ID real Studio clients completed all six Novice steps, class trials, Warrior selection and free Hall founding on candidate3f7 (revision28, level10,450XP, Hall1, one earned hero each). Their shared-scout test exposed corpse-removal terminal faults. Reviewed candidate e804 matched377 sources in both local Edit and dedicated server; corrected synthetic recovery and reward fixtures pass: normal downed recovery and physical movement restored before Completed, frozen conserved payouts and replay stable. HeroService Destroy is idempotent with no recreation or later effects. Actual two-client Bootstrap payout on e804 now passes independent review: earned heroes receive1XP each, Gold splits1/2, revisions28→29; completed-scene reentry remains stable. Both owners were solo, with explicit local fixture entry. See integration/SHARED_REAL_PROFILE_PAYOUT.md. Native opt-in entry/return is source-reviewed and baseline-tested in existing TravelService under V20. Candidate2ec894 matched377 local sources; native Novice refusal passed, positive earned travel acceptance is in progress. No Party convoy claim. Shared travel, six-client companion load, cloud persistence, runtime imports, complete Lv1–35 UI journey, devices and human acceptance remain open; no default-world activation is implied.

## Design contracts

- GAME_DESIGN_PILLARS.md — identity, scope and authority
- FTUE_AND_FUN_GATES.md — onboarding and observed fun gates
- HERO_TACTICS_CONTRACT.md — bounded commands and acceptance
- TEAM_COMBO_DESIGN.md — first three-role prototype
- HERO_BOND_DESIGN.md — identity and future bond
- LIVING_GUILD_DESIGN.md — Hall prototypes
- SHARED_PVE_INTEGRATION.md — mandatory shared authority and rewards
- BALANCE_AND_ANALYTICS.md — sanitized observations and balance
- LIVEOPS_AND_RETENTION.md — daily/season and future events
- PUBLIC_WEB_CONTENT.md — truthful content and future website scope

## Agentic completion contract

User clarification on 2026-10-14: choose previously researched plugins, tools and skills autonomously where useful. Verify actual availability, provenance, license and free operation before adoption. This permits suitable tool selection without repeated preference questions; it does not remove scoped publishing, spending, live-commerce or production-data gates. Do not install every research candidate merely because it was listed.

Claim → inspect actual modules → implement within ownership → focused regression → full baseline → independent review → local Studio evidence → record limitations/lesson. Auto-learning cannot change costs, publishing permissions or server authority. Missing device/cloud access blocks that acceptance only. Tools/assets stay free by default; research candidates are reviewed individually before installation. No public publishing, production writes, paid upload or live commerce is authorized by this plan update.
