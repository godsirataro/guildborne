## Latest delivery direction — 2026-10-15

First Public must be the **full game including Lv100/Class3, Federation, war, territory and player market**, per the user's latest instruction. Review [GL-2.0](design/integration/FULL_GAME_GOLIVE_GL2_TH.md) for phases P0–P13 and all twenty system groups. Lv35 is now an internal milestone. Older first-Public/post-launch classifications below and in existing manifests must be reconciled in P0; they do not override this direction. Runtime flags and historical evidence are unchanged. Detailed plan sign-off and actual release approval remain pending.

Expansion update: [20-theme implementation plan](design/EXPANSION_PLAN.md) and [feature registry](design/features.json). Tactical/analytics source slices are now being integrated; all Public gates remain required.

# Full-game delivery scope — 2026-10-15

The first Public requires Lv1–100, Class3, the full campaign, Federation, war, territory and the Gold/material player market, together with every required group in [GL-2.0](design/integration/FULL_GAME_GOLIVE_GL2_TH.md). Lv1–35/two arcs is P2 internal Alpha only. Guild has one human owner and NPC heroes; human membership belongs to Federation. See [Party6 contract](launch/integration/PARTY6_PLAN.md). City/model work begins at P1 alongside systems; P8 closes that work. Content minimums remain proposals pending named-inventory decisions. Implementation, cloud/device/human acceptance and scoped release authorization remain separate gates. Preserve legacy saves and identity namespaces.

# Guildborne latest-goal implementation contract — 2026-10-09

This continuation stays in PR #1. It is not approval to merge, publish, purchase,
upload paid assets, activate commerce, or change production DataStores.

## Approved destination

Original fantasy party RPG: the player fights and leads up to five heroes. Build
an enjoyable complete player route, not a list of empty menus. Native responsive
Roblox UI in EN/TH; original identity, clear inputs, natural motion/contact,
readable VFX, modular equipment, interesting NPCs, quests, bosses and guild spaces.
No promises of popularity or revenue.

Player begins Novice Lv1, chooses Class1 at10 through a quest. Class2 at35 and
Class3 at70 require their actual prerequisites; no Class4 and no level beyond100.
New heroes begin at10. Recruitment follows Class1 plus the Hall story. Personal
Hall1 cap20, +5 per Hall, reaching100 at17;18–20 retain non-level benefits.
Respec returns earned SP/AP, never adds another budget. One SP and three AP per
level after1 are the current design, with existing status math reused. Preserve
legacy earned levels, paths, receipts, inventory, active jobs and ownership.

Human, Elf, Orc and Dwarf visual bodies are modular; Wizard is Human appearance.
Fifteen core R15 parts; clothing, hair, ears, tusks and equipment stay removable.
Thirteen body presets and20 palettes are planned definitions, not created meshes.
Cosmetic stature cannot silently change combat proxies or loot/skill entitlement.

Cover title/HUD/panels, all reconciled screens, skill trees/status, inventory and
crafting, monsters/bosses, class/main/side/secret/world/hero quests, NPC activity,
cities/travel, personal guild building/visits/themes, player guilds, wars/territory,
market presentation/integrity, audio, accessibility, performance and UAT.
Production order is not permission to discard any latest requested goal.

## Current-source facts versus adoption work

The full source audit found TWO supported progression modes. Do not replace the
working Novice implementation with a second system:

| Current source | Observed behavior | Action in this continuation |
| --- | --- | --- |
| `src/server/Config/Content.luau` | Novice Hall0=10, Hall1=20, Hall17=100; new Novice heroes get450XP/Lv10 | Reuse and regression-test; no new Hall formula |
| `src/shared/Data/StatusPoints.luau` | Three AP/level after1; existing soft caps and allocation checks | Reuse, not duplicate |
| `src/shared/Data/Expansion.luau` | Legacy Class2 paths carry Level30 | New ruleset-aware readiness enforces35 for Novice; legacy remains compatible |
| `src/server/Systems/ExpansionSchema.luau` | Validation deliberately retains previously earned early promotions | Preserve validator; do not re-lock old classes |
| `src/server/Config/Runtime.luau` | New campaign modes opt in through separate preview; default flags are off | Do not silently activate a new schema against staging saves |
| `src/shared/Data/Expansion.luau` | Legacy ancestry has Human/Elf/Dwarf stats; no Orc entry | Keep legacy balance unchanged; cosmetic IDs require a separate appearance adapter |

A recorded offline journey or generated file is not a live cutover. Default
runtime flags, market ledger and persistent schema remain unchanged here.
Do not report global10/35/70 rollout or completed Orc integration from these fixes.

## Authoritative intake

Read `docs/uat01/WORK_CHECKLIST.md`, `docs/uat01/intake/registry-reconciled.json`,
and `docs/LAUNCH_GUILD_ISLANDS.md` in addition to README. At the audited base the
registry contains502 assets and73 screens, including8 future screens. Count at
runtime rather than hard-coding502 as a permanent truth. Never reset status fields.
The earlier239-row design inventory and271-test phase summary are historical.

Launch island scope includes quest-gated permanent plots/themes, materials,
free starting island, permissions and visits. Existing purchase bindings remain
disabled. Prior blocked commerce-writing capability stays explicitly deferred;
this continuation does not bypass that block or enable sales. Track the gap.

## Priority

Reconcile -> trustworthy evidence -> verified tool handoff -> Human Standard/Heavy
and removable outfit -> native HUD + one complete skill -> expand verified
content. UI/gameplay/art work may proceed while cross-server/hardware gates wait,
but those gates cannot be marked passed or removed.
