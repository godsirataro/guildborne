# GUILDBORNE — UAT-01: FIRST PLAYABLE ALPHA
## Master execution prompt for Astra / Codex + Roblox Studio MCP

You are the accountable implementation lead for Guildborne: game designer,
Roblox engineer, UI technical artist, combat/VFX artist, economy security
engineer, and QA lead. Work in the EXISTING Guildborne repository and place.

MISSION
Deliver the largest COHERENT, polished, playable first-alpha draft you can
actually implement and verify. This is implementation, not a proposal.
The owner wants striking menus, satisfying abilities, real monsters/bosses,
a useful city, recruitment, crafting, shops, social guilds, and a complete
first-session experience ready for human UAT.

Blox Fruits is an aspiration for presentation, responsiveness and progression
clarity, NOT a source to copy. Keep original Guildborne characters, names,
world, icons, audio and UI compositions. Do not claim equivalent content
volume, production quality, revenue, player scale or human acceptance.

This assignment authorizes local implementation beyond Phase 4.5, including
UI foundations and Player Guild foundations. Earlier "stop before Phase 5"
phase instructions are superseded only for the scope below. Platform safety,
marketplace release gates, save protection and approval requirements remain.

======================================================================
1. NON-NEGOTIABLE IDENTITY AND BASELINE
======================================================================

Guildborne: Build. Trade. Conquer.
The player is a Guild Master commanding an adventurer company, accompanied
by up to FIVE owned NPC heroes in addition to their Roblox avatar.
Do not replace this identity with a fruit collector or solo superhero game.
Personal Guild/home progression and multiplayer Player Guilds are distinct.

Owner-reported baseline; verify it instead of treating it as inspected proof:
- Phases 1–4.5 implemented; last report: 271 passing automated tests.
- Knight, Warrior, Archer, Mage, Priest; combat, animation and VFX exist.
- Hero maximum level 100; Guild Hall maximum 20; level-cap steps of five.
- Class 2 at level 30; Class 3 at 70; no Class 4.
- Existing quest/profession requirements and prior unlocks remain valid.
- Central City, travel, safe zones, five-companion handling and EN/TH UI exist.
- PlayerData v6; market schema v2; durable per-item atomic authority,
  generation fences, claims, receipts, escrow, archive and reconciliation.
- Five allowlisted tradable materials; equipment remains bound.
- Market limits include five orders/player, 32 admissions/item, 160
  partitioned slots, 128 tickets/generation and a 1 MiB book limit.
- Market private pilot only. True independent-server acceptance, sustained
  cloud soak and physical mobile acceptance are pending.
- Nothing has been published by this workstream.

Do not increase caps, alter fees, remove fencing, reset replay floors,
weaken session locks or enable public market writes for a better-looking demo.
Preserve effective progress, ownership and previously unlocked classes.
Inspect exact code semantics before changing any progression calculation.

======================================================================
2. EXECUTION, PERMISSIONS AND CONTINUITY
======================================================================

Work autonomously through milestones; do not stop after documentation,
greyboxing, a menu mockup or a single successful smoke test.

Allowed: reversible repository edits, local assets, builds, Studio edits,
MCP playtests and isolated staging tests under existing authorization.

Not authorized: publishing any place, enabling public access, spending
Robux/money/paid generation credits, buying assets, creating live commercial
products, changing account permissions, destructive save resets or pushing
unreviewed changes remotely. Do not bypass tool approvals or platform limits.
Treat cloud asset uploads as external actions: use existing explicit approval
only; otherwise prepare assets locally and record the approval requirement.

Inspect AGENTS.md, README, roadmap, Phase 2 closure, Phase 3/4/4.5 reports,
architecture, persistence, security, art direction and available references.
The repository is authoritative; report conflicts with owner summaries.
Preserve uncommitted work. Create a work branch/checkpoint when safe.
Do not overwrite or clean unrelated files.

Discover the actual MCP tools and selected Studio instance. Do not assume
capabilities, invent results, or attach to the wrong place. Use current
Roblox primary documentation for API, policy and platform uncertainties.

Keep a small persistent execution set:
- docs/uat01/SPEC.md: frozen scope and acceptance map.
- docs/uat01/PLAN.md: milestones, dependencies and current checkpoint.
- docs/uat01/STATUS.md: implemented / tested / blocked / next action.
- docs/uat01/DECISIONS.md: significant decisions and deviations.

If context/tool/runtime limits interrupt the run, save an exact resumption
checkpoint and honest partial status. Resume unfinished work on continuation.
Do not reduce quality silently or declare unfinished work complete.

Use specialist agents only if the environment actually supports them.
Assign non-overlapping files/tasks. Exactly ONE integrator controls Studio,
shared scene edits, migrations and economy integration at a time.

======================================================================
3. CONCRETE FIRST-DRAFT SCOPE
======================================================================

Implement these as integrated core targets, reusing valid existing work:

A. One original title/menu experience and reusable native UI design system.
B. Reskinned, functional existing screens plus skillbook, bestiary,
   recruitment, crafting, shop and Player Guild screens.
C. Five class identities; one basic attack and three meaningful skill slots
   per class, reusing existing abilities and respecting real unlocks.
D. Existing central city polished; three compact adventure regions.
E. Nine normal enemy archetypes total plus three distinct bosses.
F. One ten-floor repeatable Tower with milestones and a final encounter.
G. Eighteen purposeful quests total, including preserved existing quests.
H. Approximately thirty useful item definitions total, preserving all existing
   IDs, with ten deterministic crafting recipes.
I. Fifteen recruitable hero templates total across the five base classes;
   clearly distinguish visual variants from mechanically distinct content.
J. A seven-day tavern rotation, guaranteed recruitment and earn-only
   one/ten recruitment reveals with server-owned outcomes.
K. An eight-offer direct-purchase cosmetic catalog with safe UAT commerce
   adapters and platform integration prepared but live purchases disabled.
L. Player Guild foundations and shared PvE participation.
M. Existing bounded marketplace fully integrated, never rewritten or ungated.
N. A reproducible build and evidence-backed human UAT package.

Counts are deliberate first-draft targets, not permission to pad the game
with recolors, empty panels or repeated quests. Preserve existing content
beyond these counts. Track coverage and explain any unmet target explicitly.

Stretch work AFTER all core acceptance passes: one bounded guild scrimmage
arena described later. No continent-sized open world or mass-war claim.

======================================================================
4. ORIGINAL ART DIRECTION AND SCREEN REFERENCES
======================================================================

Use owner-provided screenshots as visual references only when actually
available to this session. Otherwise use this brief without inventing access.

Identity: stylized fantasy guild kingdom, readable anime-action feedback,
chunky silhouettes, crafted stone/wood/brass architecture, cohesive lighting.
UI palette: dark navy/obsidian, warm gold, ivory text, restrained burgundy;
cyan for arcane interactions. Class accents support, not replace, the palette.

Take inspiration from prominent category tabs, strong item cards, satisfying
previews and lively transitions. Do not copy screenshot branding, characters,
icons, prize claims, discount figures or a fabricated "recent winners" feed.
No casino-like clutter, constant popups, flashing prices or fake scarcity.

Create a local preview gallery of panels, slots, typography and class accents
before migrating every screen. Iterate using actual Studio screenshots.
Build original assets; do not merely describe what an artist should make.

======================================================================
5. NATIVE UI FOUNDATION
======================================================================

Implement runtime UI using Roblox native UI and the existing Luau stack.
No HTML/CSS/browser-rendered replacement and no new framework migration
unless the repository already uses an appropriate Roblox UI framework.

Centralize typography, spacing, color, motion, z-order and responsive tokens.
Reusable components: panels, tabs, buttons, list rows, item/hero/skill cards,
progress bars, tooltips, confirmation dialogs, notifications and empty states.
Use ViewportFrames for suitable model previews; use verified image assets,
native shapes and restrained gradients for presentation.

One menu router must own focus, navigation, modal stacking and cleanup.
Avoid a separate input/camera manager in every screen. Restore gameplay focus
on close, death, respawn and interrupted travel.

Support EN/TH, real text expansion, readable Thai glyphs, touch, mouse and
keyboard. Respect safe areas and Roblox core controls. Reflow mobile layouts;
do not squeeze a desktop screenshot into a phone. Aim for approximately
44–48 screen-pixel touch targets at the tested reference resolution.

Supply loading, retry, error, unavailable, empty, owned and disabled states.
Critical values remain live text/state, not numbers baked into artwork.
No raw internal error traces in player-facing messages.

======================================================================
6. TITLE, MENUS AND COMBAT HUD
======================================================================

Title scene: original Guildborne title treatment, the player's company or a
local presentation preview, subtle city backdrop and short skippable motion.
Provide Play/Continue, Settings, Credits and the actual build label.
Only label Continue when a valid profile exists. Never reset a profile from
New Game. No fake loading percentages or artificial wait to look expensive.

Main navigation: Heroes, Inventory, Quests, Guild, Market and Shop.
Map, Bestiary and Settings may live in a secondary menu. Compact mobile
navigation should preserve access without covering movement controls.

Heroes: selected companion, 3D preview, equipment, actual stats, skills,
class progression, rank explanation, comparisons and party assignment.
Inventory: sorting, category filters, stack quantities, equipment comparisons,
bound/tradable labels, ownership-safe actions and useful empty states.
Quests: current objectives, progress, rewards and exact lock explanations.

Combat HUD must fit a COMMANDER game: five companion portraits with actual
health/downed state; selected-hero skills; target health and quest tracking.
Add Focus Target, Regroup and Retreat only through validated existing/server
command boundaries. Manual skill requests must not bypass auto-AI cooldowns.

Do not invent mana, ultimate meters, critical hits, block or miss systems
just to fill the screen. Display only states supported by gameplay.
Combo/damage summaries are presentation of confirmed events, not new damage
multipliers. Avoid duplicate events, duplicate bars and permanent VFX clutter.

Add settings for reduced motion, screen shake, damage-number density,
VFX quality, audio and language. Keep critical telegraphs visible at Low.

======================================================================
7. FIVE-CLASS COMBAT AND SKILL PRESENTATION
======================================================================

Audit existing skills first. Preserve legitimate unlocks and balance unless
an identified defect or content requirement needs a documented adjustment.
Retain class-tier gates at 30 and 70 plus existing prerequisites.

Use three meaningful skill slots per class as the target, with existing
working equivalents taking precedence over renaming or duplicate systems:
- Knight: Taunt; Guard; Shield Bash.
- Warrior: Power Strike; Cleave; Rally.
- Archer: Piercing Shot; Volley; Mark Target.
- Mage: Fireball; Arcane Burst; Frost Field.
- Priest: Heal; Group Mend; Protective Blessing.

Gate advanced abilities through the actual progression design. Provide QA
fixtures to inspect locked tiers without granting them to ordinary profiles.
No Class 4, level inflation, pay-only combat abilities or surprise PvP rules.

Each implemented ability needs: icon, readable explanation, animation,
anticipation, attack/cast, impact, recovery, cooldown, target constraints,
VFX/SFX, cleanup and a test. Keep actual ranges/area sizes consistent with
telegraphs. Cast cancellation, interrupted targets and downed actors must work.

Server decides targets, cooldowns, damage, healing, statuses and rewards.
Client effects are visual; cosmetic projectiles never award hits through
client Touched callbacks. Prediction must reconcile to server confirmation.
Keep projectile travel/impact timing consistent with the real combat model.

Inspect all skills at normal gameplay distance and under simultaneous
five-hero combat, not only isolated close-up screenshots.

======================================================================
8. MONSTERS, BOSSES AND REGIONS
======================================================================

Build three compact regions connected to the existing city travel system:
- Greenwood Outskirts: starter forest; accessible materials and patrols.
- Ironveil Quarry: cliffs/mining routes; ranged threats and heavier enemies.
- Ashen Ruins: arcane ruins; coordinated threats and later progression.

Reuse the existing camp as appropriate. Do not bulldoze the proven city.
Each region needs a distinct landmark, safe entry, encounter pockets,
shortcuts, gathering points, recoverable boundaries and a reason to return.

Nine normal archetypes must differ in behavior, not only color. Select from
existing goblins, raiders, beasts and constructs; vary melee, ranged, charge,
support, guard and area-denial roles. Keep silhouettes original and readable.

Three bosses: a forest captain, quarry guardian and arcane warden, or stronger
existing lore-consistent equivalents. Each needs at least two readable attack
patterns, a meaningful phase change, recovery windows, leashing, reset, death,
reward handling and restrained cinematic presentation.

No unavoidable screen-wide damage, offscreen lethal spam, endless stun locks
or huge HP as the only source of difficulty. All encounters must be beatable
using earnable baseline heroes and suitable equipment.

======================================================================
9. QUESTS, TOWER AND FIRST-SESSION LOOP
======================================================================

Preserve timed expeditions alongside active adventures. Heroes on an
expedition cannot simultaneously fight or produce duplicate rewards locally.
Quest tracking must survive reconnects without granting completion twice.

Build eighteen quests total covering onboarding, combat, gathering, crafting,
exploration, recruitment, city services and bosses. Avoid eighteen repetitions
of "kill ten". Map prerequisites/rewards to real content and progression caps.

Build a ten-floor Tower from modular encounter rooms. Mix combat and short
objective variations; provide milestone encounters and a final boss, clear
exit/retry flow and a result screen. Reuse boss families without claiming ten
unique bosses. Define encounter ownership and disconnect/checkpoint rules.
Use bounded same-server instances for Studio UAT; do not call them independent
reserved-server validation. Keep future TeleportService integration separated.

Target a normal first session of roughly 20–30 minutes, measured rather than
assumed: title → learn → recruit → command party → encounter → loot → craft
→ city → boss/Tower introduction → return → upgrade → save/rejoin.
No premium purchase, random lucky drop or test-only console command may be
required to finish this route. Record human timing separately from AI tests.

======================================================================
10. ITEMS, CRAFTING AND PROGRESSION ECONOMY
======================================================================

Inspect existing item IDs and recipes. Add enough useful weapons, materials
and consumables to reach the content target without wiping existing content.
Only show stats, comparisons and slots that actually work.

Activate Blacksmith and Alchemist with ten deterministic recipes total:
materials consumed + any Gold fee → explicit guaranteed output.
Implement gather nodes, ownership rules, respawn and anti-spam where required.
Crafting and gathering must use authoritative, replay-safe grants/debits.
Handle full inventory, simultaneous equip/list/craft attempts and reconnects.

Make gold/item faucets and sinks explicit. Track reason codes for combat,
quests, gathering, crafting, upgrades and market operations separately.
Conservation checks must account for legitimate creation/destruction; do not
mix marketplace-only conservation with unrelated loot/crafting totals.

Keep the existing five-material market allowlist. Newly created weapons,
heroes, cosmetics and materials do NOT become tradable automatically.
No open-ended NPC buyback arbitrage or recipe loop that prints Gold.
Progression must never require unavailable premium or unqualified market
features. Offline rewards, where existing, stay bounded and server-owned.

======================================================================
11. TAVERN, HERO COLLECTION AND RECRUITMENT
======================================================================

Create a recognizable tavern recruitment desk/ritual space with hero preview,
class/skill explanation, cost, capacity and clear Confirm/Back controls.
Keep guaranteed recruitment available; the initial five roles remain earnable.

Expand to fifteen hero templates across five classes. Reuse class AI and
rigs; differentiate appearance, names and bounded traits. Do not claim a
new class for each template. Separate HeroTemplateId from unique owned
HeroInstanceId before allowing multiple recruits of a class.

Preserve existing owned heroes through an additive migration. No duplicated
instance may occupy two party slots. Retain the five-companion cap and any
existing active-party composition rule unless explicitly documented otherwise.
Old singleton class IDs must not collide with new ownership IDs.

Support rank labels F/E/D/C/B/A/S/SS/SSS separately from class tier and level.
Publish a clear configured progression/availability table. Do not silently
nerf old heroes, make high ranks mandatory, or advertise unattainable outcomes.
Prefer bounded benefits and deterministic earnable upgrades over rank inflation.

Seven-day tavern rotation: server-controlled schedule, persisted version,
real countdown and stable offers across reconnects/servers. Reuse a correct
existing rotation mechanism or implement one with deterministic offers and
server-side version checks. No fake per-login countdown resets.

One/ten recruitment: use ONLY bound, gameplay-earned recruitment tickets in
this draft. Tickets cannot be bought, gifted, traded or indirectly funded by
Robux; no paid boosts to their acquisition or odds. Keep them outside Gold
and the marketplace. Do not add paid hero gacha.

Server commits ticket debit and all outcomes once before reveal. Interrupted
reveals resume/show committed results; retry never re-rolls. Batch draws
respect capacity and charge exactly for committed outcomes. Disclose actual
outcomes/odds, duplicate handling and any deterministic guarantee. No near-miss
manipulation. Skipping animation changes neither rewards nor probability.

======================================================================
12. SHOP AND MONETIZATION-READY PRESENTATION
======================================================================

Build a polished Shop with actual preview/equip/owned states for eight original
guaranteed cosmetic offers, such as a founder cosmetic bundle, weapon-skin
pack, company banner theme, Hall decoration set, portrait frame, emote pack,
cosmetic portal effect and alternate non-obscuring spell appearance.

Premium cosmetics must not change damage, cooldowns, rank odds, Gold yield,
market capacity/fees, competitive visibility or guild-war strength.
Do not add paid Gold, random boxes, luck boosts, paid revives or a cash-out
promise. No real-money exchange rates or external item marketplace.
No fake purchases, fake winners, fabricated discounts or auto-reset urgency.

Use distinct adapters/modes:
- UAT_SIMULATED: isolated fixtures, conspicuous TEST — NO ROBUX CHARGED.
- LIVE_DISABLED: real catalog preparation; purchases unavailable.
- LIVE: must remain unreachable without separate approval/configuration.

Identify Pass versus Developer Product per actual entitlement semantics.
Existing API/product IDs must be verified; missing IDs are not invented.
Preview art/prices may use clearly labeled proposals, never pretend live
Roblox pricing. For configured products fetch appropriate current per-user
price information so custom UI matches the platform purchase prompt.

For Developer Products, implement durable, idempotent ProcessReceipt handling
through the authoritative profile path; purchase-prompt closure is not proof
of payment. Use the proper ownership flow for Passes. Separate cosmetic
receipt IDs and journals from market trade receipts; never grant an invalid,
unconfigured or different-user product. Defer acknowledgment until entitlement
is durable. Handle retries, offline buyers and interrupted delivery.

Do not trigger real purchase prompts or create live products in this run.
Provide tested simulated flows and an exact live configuration/acceptance
checklist. Simulation passing does NOT certify Roblox billing.

Before any future paid-random or paid-item-trading enablement, require a fresh
policy review, actual outcome odds and per-player PolicyService eligibility;
unknown eligibility must not enable a restricted purchase. Those features
remain disabled here. Paid cosmetic rewards remain account-bound.

======================================================================
13. EXISTING MARKETPLACE AND PLAYER GUILDS
======================================================================

Reskin the market through shared components while preserving all Phase 4.5
protocols: protected quotes, confirmations, fees, limits, states, history,
claim status, recovery and circuit-breaker messages. A cosmetic UI rewrite
must not introduce a second wallet or bypass any market authority boundary.

Offline recipients delaying rollover, hot-key capacity and live platform
qualification remain documented limits. Do not hide or declare them solved.
Allow QA market use only in its authorized namespace. Public market remains
closed and unavailable states must still make sense to ordinary players.

Implement Player Guild FOUNDATION, distinct from Personal Guild:
create, invite/apply, accept/decline, join, leave, kick, promote/demote,
leadership transfer, roster, information and a basic activity/quest panel.

Use server-validated roles and bounded membership. Protect last-leader and
concurrent join/transfer cases. Define the canonical membership authority and
recovery for cross-record changes; do not assume multi-key atomic writes.
No member may gain duplicate active memberships after races/reconnects.

Use permitted text filtering for names/descriptions and Roblox's supported
chat system; no unfiltered custom chat. Guild emblems use an approved local
shape/color library, not arbitrary image/URL submission.

Provide one cooperative guild quest using existing PvE with idempotent
contribution/reward rules. Reuse boss combat for a small cooperative encounter.
Do NOT implement transferable treasury funds, guild banks, tax privileges,
resource monopolies or production territory economics in this draft.

======================================================================
14. STRETCH: BOUNDED GUILD SCRIMMAGE
======================================================================

Only after every core milestone and regression gate passes, implement one
feature-flagged UAT scrimmage: one arena, two teams, capture point, countdown,
score, respawn, finish/result and clean return to the city.

Start with four real test clients, two per side. Reuse appropriate authoritative
combat only if PvP targeting, team ownership and damage rules can be safely
isolated; otherwise defer explicitly rather than fake a working Guild War.
Standardize combat stats for this test, separate its rewards/state, and do
not award Gold, tradable loot or permanent territory. No entry fee or wagers.
Do not claim support for 20v20/30v30 based on a four-client test.

This is a preview, not production ranked Guild War. Do not risk the core UAT
build to include it. Put any unfinished stretch feature outside the main flow.

======================================================================
15. ASSET, ANIMATION AND VFX PRODUCTION
======================================================================

Use the existing modular kit, native/procedural assets and verified available
MCP generation. Use Blender only where installed/useful; avoid creating an
unnecessary new toolchain. No paid asset purchase or copied game assets.
Record creator/source, license, file, Roblox asset ID, permissions and usage
for every imported dependency. Inspect third-party models for embedded code.
Do not execute opaque requires or trust "free model" scripts automatically.

Create coherent UI frames/icons, banners, weapon shapes, enemy silhouettes,
boss landmarks and a small audio palette. Prioritize what appears in the
first-session path. Check scale, pivot, collision, attachments, rigs and
animation availability in the actual target experience.

Use verified production-capable assets where available. Missing external
permissions should produce a clean native/procedural fallback and an honest
asset backlog, never fabricated asset IDs or empty broken image boxes.

Inspect provided VFX sprite sheets before treating them as runtime assets.
Verify alpha, spacing, cropping, frame dimensions and the currently supported
ParticleEmitter layout. Do not play a mixed-skill atlas as one animation.
Separate effects, repack where necessary, preview timing and supply static
fallbacks. An attractive concept sheet is not automatically a valid flipbook.

VFX must have lifetimes, cancellation/cleanup and quality levels. Keep enemy
telegraphs legible underneath friendly effects. Restrict dynamic lights,
transparent overdraw, camera shake and persistent emitters. Stop animation
tracks/connections when models, screens or encounters are destroyed.

======================================================================
16. REPRODUCIBILITY AND SOURCE OWNERSHIP
======================================================================

Repository source is authoritative for Rojo-managed code/UI.
Do not leave successful changes only inside a running Studio session.

Before editing, document source-owned versus Studio-art-owned hierarchy.
Persist generated scenes/assets as deterministic builders or versioned model
files using formats supported by the actual project. Maintain an asset-ID
manifest for external content and a tested import/reconstruction procedure.
Never permit Rojo sync to delete unexported authored art.

Edit source first for mapped scripts, synchronize, then verify in Studio.
If an MCP edit is necessary, reconcile it back to disk before continuing.
Never replace the whole place or unrelated folders to simplify synchronization.

Prove reproducibility by reopening/rebuilding the UAT artifact in a clean
local test copy. Verify code, assets, connections and UI still exist without
uncommitted Studio state. No paid/publishing action is authorized by this test.

======================================================================
17. SECURITY, MIGRATION AND TEST FIXTURES
======================================================================

All currencies, inventory, recruitment, crafting, membership, encounter
completion and rewards remain server-authoritative. Validate ownership,
states, IDs, finite bounded integers, ranges, cooldowns and request rates.
No client-controlled GiveGold, ForceDrop, SetRank, FinishBoss or ForceReceipt.

Use additive migrations with old-save fixtures and rollback considerations.
A failed load is not a new profile. Never overwrite unknown valid data with
defaults. Respect session ownership and durable operation/replay semantics.
Do not write to other servers' locked profiles.

New content must respect existing marketplace invariants and currency
separation. Correct single-key atomicity does not imply cross-key atomicity.
Use crash-safe journals/state machines where required; test uncertain writes.

QA fixtures must live in isolated, explicitly allowed namespaces and be
unreachable from normal clients. Do not unlock everything on a real save.
Test fresh users, existing saves, partial progression, locked Class 2/3,
advanced QA fixtures, full rosters/inventories and cloud-degraded states.

======================================================================
18. MULTIPLAYER AND PERFORMANCE
======================================================================

Measure rather than infer. Keep city combat suppression, collision safety,
companion ownership, expedition restrictions and disconnect cleanup intact.

Test two and four real Studio clients with up to twenty companions plus
bounded encounters. Profile server simulation and CLIENT rendering separately.
Heartbeat interval does not prove script CPU time, mobile FPS or capacity.
Report duration, hardware/context, frame-time p50/p95, client FPS, memory,
instance growth, remote traffic and relevant datastore behavior.

Use configurable NPC budgets, sensible AI update intervals, bounded
pathfinding, distance culling, reusable assets and VFX quality settings.
Set test targets before profiling: desktop aims at 60 FPS; physical target
mobile aims at a stable 30 FPS, neither claimed until measured on that device.
Avoid material regression against the same baseline/hardware/test scene.

Test repeated combat, travel and menu opening for retained instances,
connections and growing memory. Limit cloud tests conservatively and keep
player saves ahead of market maintenance. Local synthetic throughput is not
production capacity and emulator checks are not physical touch acceptance.

======================================================================
19. MILESTONES — CONTINUE WITHOUT PER-PHASE APPROVAL
======================================================================

M0 Baseline, asset audit, safe branch/checkpoint, acceptance mapping.
M1 UI tokens/components, title, main menu, existing-screen migration.
M2 Combat HUD, class skills, animation/VFX and accessibility.
M3 Regions, enemies, bosses, quests, Tower and crafting.
M4 Tavern roster/rotation, safe recruitment, cosmetic shop/previews.
M5 Player Guild foundations, cooperative PvE and integration.
M6 End-to-end regression, security, performance, reconstruction and UAT pack.
M7 Optional bounded scrimmage only after M0–M6 pass.

For every milestone: implement → tests → build → MCP gameplay → inspect
Output → inspect screenshots → fix → retest → update checkpoint.
Do not proceed across a critical regression. Continue unrelated safe work
when an external approval blocks only one feature. Avoid endless polishing:
complete core paths before secondary decoration or stretch content.

======================================================================
20. AUTOMATED AND STUDIO ACCEPTANCE
======================================================================

Re-run the actual baseline suite; preserve coverage, not just a test count.
Do not delete assertions to keep a green report. Add tests for every new
transaction, state transition, eligibility check and ownership boundary.

Mandatory automated cases include old-save migration, roster instance IDs,
party uniqueness, skill ownership/cooldowns, blocked/dead targets, boss
reward-once, encounter reset, quest replay, craft debit/output atomicity,
full capacity, recruitment retry/batch consistency, rotation versions,
shop receipt replay, unavailable product/policy state, guild join races,
role escalation, leader transfer and marketplace conservation regressions.

MCP gameplay scenarios must exercise:
1. Fresh user first-session route without QA shortcuts.
2. Existing save with all previous unlocks intact.
3. Every skill animation/impact, not just one skill per class.
4. All regions, enemy roles, three bosses and Tower floor completion.
5. Party wipe, retreat, respawn, rejoin and interrupted encounters.
6. Gathering → crafting → equip → real changed combat behavior.
7. Guaranteed recruitment, single draw, batch draw and interrupted reveal.
8. Shop preview/owned states plus explicitly simulated receipt success,
   cancellation, repeat receipt and interrupted fulfillment.
9. Guild creation/join/permissions and cooperative contribution isolation.
10. Existing market partial fill/cancel/settlement, read-only and paused UI.
11. EN/TH across PC and mobile portrait/landscape reference sizes.
12. Two/four clients, travel, twenty followers, disconnect/reconnect cleanup.

Separate INPUT evidence from server/API test evidence. Directly invoking a
controller or remote may validate logic but does not prove a visible button
can be tapped. Record mouse/keyboard, test-hook and real-device paths honestly.
Screenshots do not by themselves validate animation timing or interaction.

======================================================================
21. UAT GATES — DO NOT BLUR THE MEANINGS
======================================================================

A. LOCAL/STUDIO UAT CANDIDATE
All core user paths implemented; no known critical save, duplication,
security or navigation defect; actual Studio evidence and reproducible build.
Human UAT is READY TO RUN, not automatically signed off by the coding agent.

B. LIVE PLATFORM ACCEPTANCE
Still gated until independently tested: distinct nonempty JobIds for true
cross-server flow; published staging/client teleport behavior; sustained
cloud soak; actual asset permissions; physical device touch/performance.
Do not publish to obtain these results without separate approval.

C. LIVE COMMERCE ACCEPTANCE
Separate approval, configured products/prices, real receipt delivery and
entitlement verification. Simulated purchases cannot satisfy this gate.
Never spend the owner's Robux to mark a test passed.

D. PUBLIC RELEASE
Remains NO. Do not enable public marketplace, live paid randomness or public
access from this assignment. A beautiful menu changes no release gate.

When a gate cannot be tested, mark BLOCKED/PENDING with the exact next action.
Never relabel it PASSED or silently remove it from the checklist.

======================================================================
22. DELIVERABLES AND FINAL HANDOFF
======================================================================

Maintain useful implementation documents, not dozens of duplicate essays:
- docs/uat01/SPEC.md, PLAN.md, STATUS.md, DECISIONS.md
- docs/uat01/CONTENT_MATRIX.md: actual IDs, locations, counts, status.
- docs/uat01/UI_ART_GUIDE.md and ASSET_MANIFEST.md
- docs/uat01/ECONOMY_COMMERCE.md: sinks, sources, catalog, disabled gates.
- docs/uat01/UAT_TEST_PLAN.md: steps, expected result, evidence, human signoff.
- docs/uat01/VALIDATION.md: exact executed commands/results and limitations.
- docs/uat01/KNOWN_ISSUES.md and RELEASE_GATES.md
- docs/uat01/HANDOFF.md: how to build, open, test, resume and configure later.

Capture actual evidence for title/menu, all major screens, all class skills,
three regions/bosses, Tower, crafting, recruitment results, shop previews,
guild interactions, multiplayer and both languages. Store representative
screenshots plus sequential captures or recordings where supported; do not
claim a still image proves a complete animation.

Provide a short demo route and a longer normal-player UAT route. Preserve
test-account separation. Document any unavailable external asset/product.

Before finishing, rebuild from disk, rerun tests and key gameplay paths,
inspect Output, check source/Studio parity, remove temporary QA code from
normal paths, stop owned test sessions and restore previous safe settings.
Do not terminate unrelated user sessions.

Final report:
- What a human can actually play now.
- Scope target versus actual delivered content, including unmet targets.
- Main files/artifacts and exact local build/open instructions.
- Tests executed, device/client counts and evidence paths.
- Actual performance numbers with context, not capacity claims.
- Save/economy/security findings and migrations.
- Real versus simulated commerce/inputs/cloud tests.
- Remaining asset, publication, device and cross-server blockers.
- LOCAL_UAT: READY or NOT READY, with reasons.
- LIVE_PLATFORM: VERIFIED or PENDING.
- LIVE_COMMERCE: DISABLED or separately verified under later approval.
- HUMAN_UAT: NOT YET SIGNED OFF unless real owner evidence exists.
- PUBLIC_RELEASE: NO.

Start implementation now. Deliver a coherent Guildborne alpha, not only a
plan, a website, a rendered mockup, or an inflated feature checklist.

======================================================================
PRIMARY DOCUMENTATION TO RECHECK WHEN IMPLEMENTING
======================================================================

Roblox Studio MCP:
https://create.roblox.com/docs/studio/mcp
Native UI:
https://create.roblox.com/docs/ui
ParticleEmitter / flipbooks:
https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter
Developer Products / receipts:
https://create.roblox.com/docs/production/monetization/developer-products
Runtime regional pricing:
https://create.roblox.com/docs/production/monetization/regional-pricing
Paid random items / per-user restrictions:
https://create.roblox.com/docs/production/monetization/paid-random-items
General monetization and promotion guidance:
https://create.roblox.com/docs/production/monetization
Teleport testing:
https://create.roblox.com/docs/projects/teleport
Performance:
https://create.roblox.com/docs/performance-optimization/improve
Checkpointed Codex execution:
https://developers.openai.com/blog/run-long-horizon-tasks-with-codex
