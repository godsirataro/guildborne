# Guildborne production playbook v2

These are acceptance-oriented workflows for the existing specialist skills, not
claims of finished content. Read LATEST_GOALS.md first. All task owners use the
same ledger and immutable source/evidence procedure. Read actual code and registry
sources, not just old phase reports. Do not overwrite unowned files or promote
historic fixtures to new acceptance.

## Director / tooling / research

Inspect branch, dirty files, runtime entrypoints, latest UAT work checklist,
registry and tool availability. Record conflicts before edits. Reconcile 502/73
or actual current counts with the character kit, retaining separate design and
runtime IDs. Pick one complete player route and dependency-ready packages. Use
run_worker only for local-code work with explicit quota approval. Interactive
Studio/Blender requires verified session plus exclusive ownership. Never use
model exit0 as acceptance. Investigate failed tests, retry within bounded time,
and preserve logs/checkpoints; human taste and publishing remain outside automation.
Research only actual unknown technical decisions using current primary sources;
record date, source, version and tested/unverified adoption separately. Do not
install unrelated marketplace skills or credentials based on a web page.

## Native UX/UI and UI art

Audit actual components and all reconciled screen states before producing art.
Use native ScreenGui/Frame/TextLabel/ImageLabel and existing Luau state binding,
not web pages or baked screenshots. Keep shared spacing, typography, focus,
selection, error and action tokens. Large ornate frames use appropriate slices;
labels, prices, cooldowns, names and translations remain runtime text. Portraits
and product previews should depict actual models; a missing asset gets a clear
fallback rather than a fabricated rbxassetid.

For every screen specify enter/back/confirm/cancel, loading, empty, unavailable,
failed/retry, submitted/pending and success. Preserve scroll/focus on updates.
Test keyboard/gamepad navigation, phone safe areas, virtual keyboard and TH line
wrapping. Validate selected hero versus player context; do not display18 active
skill buttons simultaneously. Skill-tree mobile list mode remains usable without
pinch zoom. Snapshot stale/expired quotes and disabled buttons must be truthful.
Use asset_jobs to request a specific missing/rework-approved item, then actual
image-generation tools, alpha inspection, in-game scale review and provenance.

## Characters / rigging / appearance

Generate the self-contained character contract, resolve head-ID aliases, and
inspect existing body/hero libraries. Human Standard and Heavy form the first
fit matrix. Build exactly15 selectable core body meshes, caps/UVs/rig and
independent hair/ears/tusks/clothes; do not substitute drawn separation lines.
Skin tints must remain consistent at neck/hand seams under different lighting.
Keep fixed non-exposing safety coverage when garments are removed.

Match the actual skeleton reference. Check units, axes, transforms, influences,
shoulders/elbows/wrists/hips/knees/ankles. Layered clothing requires compatible
cages and ordering; rigid armor requires tested attachments/offsets. A fit family
is an eligibility hint, never automatic approval. Dwarfs are authored short-limb
proportions, not squashed humans. Orcs remain friendly/playable as well as NPCs.
Appearance race IDs do not replace legacy combat ancestry fields or stat bonuses.
Use blender_job plus deformation/Studio tests; deliver source/export/manifest and
standard movement/equipment evidence before multiplying presets.

## Animation / VFX / audio

Create anticipation, action, impact and recovery aligned to shared semantic
markers. Local animation feedback may start promptly but server validation owns
hits, cooldowns, healing, status, deaths and rewards. Handle rejected casts,
streamed-out targets, interrupted actions and replayed effects. Do not use a
particle collision or a client animation marker to mint damage/rewards.

Motion: verify foot contact, grip, recoil, root drift, retargeted body proportions,
loop seams, idle transitions, ragdoll/downed/recovery and partial-body blending.
Existing bow/sword/civic contact studies are reusable source, not already bound
clips. Show movement at real gameplay distance and speed, not only turntables.

VFX: compose bounded burst/trail/beam/telegraph layers with explicit lifetimes,
pooled frequent objects where measured useful, distance/quality reductions and
cleanup on cancel/respawn. Preserve enemy warning shapes on low quality. Check
simultaneous5-hero casts and4 players/20 followers without wall-like transparency.
Flipbook CRC checks prove file integrity only; inspect alpha, frame progression,
clipping and actual emitter behavior. Never advertise procedural placeholder
textures as final art. Support reduced screen motion/flashes and class readability.

Audio: source-owned/licensed masters, cue IDs, spatial versus UI channels,
concurrency limits and listener review. Align impacts to markers, avoid clipped
or over-loud mixes, and fade/stop loops on zone/actor removal. File count is not a
unique sound count when mixes reuse samples. No fabricated voice consent or
copyright clearance; imports and physical listening remain separate gates.

## Combat / monsters / bosses / NPC life

Read CombatAbilities, CombatDamage and CombatTargeting before changes. Keep
bounded decisions, server authority, ownership, aggro/leash and safe-zone rules.
Client intent is validated for type/range/finite values/cooldown/state/target.
Separate normal enemies by decisions (charger/ranged/support/guard/flanker), not
only model color or health totals. Boss phases need readable telegraphs, valid
support-role solutions and one durable reward path. Never require maximum DPS
for a Priest class exam. Test despawn, fleeing, return, disconnection, duplicate
kill signals and isolation between parties.

NPC life uses shared schedule data and lightweight idle/work/travel/talk states.
Route recomputation is bounded; distance/streaming suspend costly detail. Work
animations must physically meet tools. Talking can interrupt and resume safely;
quest hooks request authoritative actions, not direct reward grants. World roles
are not determined by skin tone/body shape. Bind current civic studies gradually.

## Progression / skills / status / quests / hero stories

Reuse Content.ProgressionRulesets, HallLevelCap, RecruitmentStartingXP,
StatusPoints and existing journal/campaign services. New Novice readiness uses
10/35/70; preserved legacy mode and earned unlocks remain valid until reviewed
cutover. Do not enable default preview flags just to make a test pass. Respec
returns spent budget, never creates a second set. Each hero owns its own level,
build and cooldown. Skin/gear preview must not alter those values.

Normalize proposed quest/skill DAGs and validate missing references, cycles,
mutually exclusive prerequisites, duplicate reward keys and Hall permits. A Hall4
permit must be possible at Hall3/Lv30; Class1 and Hall1 cannot require a hero that
is only recruited afterward. Verify transitive main-story dependencies do not
require paid content, online markets, player guild membership or random heroes.
The normalized graph checker is not a Luau parser; trace real IDs back to source.

Vary objectives through escort, investigation, protection, traversal, conversation,
role mastery and controlled combat. Hidden quests need discoverable clues and no
irrecoverable paid-character loss. Hero stories should preserve identity, bond,
chapter and duplicate-instance ownership; first-time narrative rewards cannot be
farmed by repeatedly recruiting/releasing the same template. Old quest receipts,
active expedition snapshots and saved choices survive migrations and reconnects.

## Items / inventory / crafting / market

Resolve actual item IDs and allowlists; do not generate content for fictional IDs
that look plausible. Separate stack/instance/bound/equipped/escrow ownership and
preview/equipped/owned states. Apply craft/equip transfers once through existing
transactions. Test wrong owner, insufficient materials, active expedition,
cancellation, unknown writes and replay before drawing success UI.

Market changes preserve per-item atomic authority, generation fencing, replay
floors, claim sequence, profile-owned settlement and conservation. MemoryStore
is disposable projection, MessagingService notification only. UI must distinguish
no liquidity from a fabricated price; partial fills/cancel remaining/recovery are
not terminal success until authoritative state confirms. A paused market must
not block combat, quests, profile saves or the free core progression route.

## World / cities / guild islands / social / wars

Start with scale, silhouettes, safe routes and landmarks; then detail. Reuse the
existing six city institutions and verify ordinary entry plus actual service
interactions. Player plus5 followers must traverse stairs, doors, warps and
recovery points. Streaming and collision changes need measured tests, not blind
activation. Include platform fallback when a location is unavailable.

Follow LAUNCH_GUILD_ISLANDS: one personal island accessible from launch cities,
free starting Hall, building placement/move/store/restore, themes and visits.
Quest rights, purchase rights, material delivery and buildable state are distinct.
Moving or changing theme never resets paid ownership/building progress. Visitors
have no build/withdraw rights by default; owner leave/privacy change safely ends
visits. Text names/descriptions require platform filtering before public use.
New commerce processing remains explicitly deferred; existing sales stay disabled.

Player Guild is distinct from Personal Guild. Role transfer, invites, applications,
leave/disband and permissions require retries and concurrency checks. Wars and
territory have a separate work package and bounded state machine; do not enable
PvP inside the safe city or grant territory income from visual-only results.
Test roster locking, win/lose/cancel, disconnect resolution and reward-once.
Do not force market prices as a side effect of a battle.

## QA / performance / asset provenance / growth

Test the full new-player journey and returning saves; isolated demos remain
labeled isolated. Capture build/commit/tree, invocation, input method, scenario,
expected/actual values, Output and screenshots. Record_check helps bind command
results; Forge rejects fake/stale commits, but reviewers still inspect the truth.
Run existing Luau/build checks unchanged plus the targeted latest-ruleset suite.

Measure client frame work separately from server heartbeat, with duration/sample
counts; add per-quality effect density, UI updates, pathing and memory trend.
Synthetic throughput is not production capacity. Real phones and distinct live
JobIds remain separate acceptance, never inferred from emulation or4 local clients.

Provenance records original sources, output hashes, revisions, generation tool and
rights declaration; declared rights are not verified rights. Keep nullable IDs,
explicit fit compatibility and source/export/import/Studio/human states. Catalog
counts are work inventory, not uniquely playable assets. Prevent stale sources,
accidental duplicates and irreversible replacements without review.

Growth work measures first-session friction, clarity, fun, replay intent and
opt-in retention against real tester feedback. Do not fabricate players/revenue,
promise popularity, copy a competitor's identity or use coercive timers. No
public release or monetization activation without a separate owner decision.
