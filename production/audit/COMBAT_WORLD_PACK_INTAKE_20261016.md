# Combat and world pack reconciliation — 2026-10-16

Status: W0 audit checkpoint; W1 and full-game acceptance are not complete.
Inspected source: `49c5162a35c0afc2026e806569e198aa50c1dddd`, branch
`codex/gui-regal-foundation`. Initial working tree was clean.

## Request and supplied material

The pasted request describes a full Combat/Skill Tree production program. The
supplied ZIP instead contains seven World Builder files; it does not contain the
named Combat master prompt, 937-case matrix or ten GUI references. The user then
asked us to evaluate as appropriate. Documents are reference material, not an
independent authorization to change priorities, publish or enable commerce.
The archive was inventoried without executing its contents or extracting over
existing work. Existing world work is already tracked in `world-builder/` beside
this report; preserve its bounded Central City evidence and unfinished rounds.

## Canonical class proposal

Retain the current 29 runtime IDs and save compatibility as the implementation
baseline. Keep the 35-class/105-active draft in a separate design namespace until
each production binding and branching decision is reviewed.

| Root | Class2 → ordinary Class3 |
|---|---|
| Warrior | berserker → warlord; duelist → sword_saint |
| Knight | guardian → fortress; paladin → holy_sentinel |
| Archer | ranger → beastwarden; sniper → deadeye |
| Mage | elementalist → archmage; spellblade → arcane_knight |
| Priest | cleric → high_priest; oracle → prophet |

Special Class3 IDs: commander, rune_knight, bard, shadow_dancer. Definitions live
in `src/server/Config/Content.luau`, `src/server/Config/Combat.luau` and
`src/shared/Data/Expansion.luau`. There are 29 active runtime ability IDs.
This is catalog coverage, not 29 completed class-specific skill trees.

The draft Oracle is Tier3 under cleric with a null production binding; runtime
oracle is Tier2 under Priest. Matching names is not a migration. Do not rename
saved paths or silently replace 10 ordinary Class3 branches with 20 draft branches.

New-journey progression already uses 10/35/70; legacy Class2 at30 remains supported.
Hall caps are 20 at Hall1, 35 at Hall4, 70 at Hall11 and100 at Hall17. Earned
classes, actor-specific levels and promotion refunds must remain intact.

## Actual skill-tree and presentation gaps

- `Expansion.Skills` has five boolean nodes: vitality, focus, ward, path_art,
  master_art. Focus/ward are mutually exclusive. `SkillTreeView.luau` positions
  those five nodes explicitly. Ranked actives, rune selections and class-specific
  capstones are not implemented by this tree.
- The draft costs39 SP per fully filled tier and117 across three tiers against99
  SP at100. This permits specialization, not buying everything. Required unlock
  routes must be checked individually; do not increase budgets merely to fill
  the entire tree. Structural draft validation does not prove playable gates.
- Status-point code exists (`StatusPoints.luau`, `StatusPointService.luau`), but
  `Content.StatusAllocationAvailable` is false. Older prose saying AP code is
  absent is stale; existence and player availability are separate.
- Companion AI currently chooses one equipped ability. A complete ability
  priority editor and multi-ability decision system remain separate work.
- Current cast applies authoritative damage synchronously, then emits the
  presentation event. Both per-skill and shared cooldown receive the full skill
  cooldown. Contact timing and hotbar cooldown policy need intentional design.

## Golden skill candidate and next implementation boundary

Use existing Warrior `power_strike`: native input in PlayerCombatController →
CombatService validation → CombatAbilities/CombatDamage → replicated action →
CombatController/SkillEffects. Extend this route instead of creating another
combat service. A future scoped implementation should define authoritative
windup/contact/recovery, interruption and duplicate-event behavior, with cosmetic
markers unable to grant damage. Verify ordinary player input, five companions,
target loss, downed actors, cooldowns, late presentation and cleanup in an isolated
Memory candidate before expanding content. No new Golden Skill is claimed here.

The existing Forge combat/progression tasks are not READY until dependencies are
accepted. Audit work uses the existing matching shared
`build/agentic/gui-v27-ledger.sqlite3`, task audit, owner combat-pack-intake.
The default ledger rejected the plan fingerprint; it was not reset. Runtime
implementation requires reconciled scopes and independent audit acceptance.

## Fresh observations

- Forge doctor/validate/plan ran:61 tasks,31 skills; metadata validation PASS.
- Studio routing validate/verify PASS:33 roles,10 workflows,98 generated files.
- Reconciliation:502 assets,73 screens,89 kit assets,402 hashes,0 missing references.
- Character contract PASS:89 planned assets,15 body parts; no fit/import claim.
- Read-only draft audit via imported audit/load functions:35 classes,240 quests,
  105 active concepts,0 structural errors; warning that prose gates are not
  executable; runtimeReady=false. The tracked draft report was not overwritten.
- `tests/run_latest_progression.luau`:12 checks passed on this source.
- Reviewed pinned setup script and full `tools/validate.ps1` completed successfully:
  890 tests, strict analysis, compilation, Rojo build and repository/built-place
  boundary checks PASS; 366 strict runtime Luau files. Synthetic 5,000-order load
  recorded zero invariant violations; this is not live cross-server evidence.
  Raw output: `build/combat-intake-baseline-20261016.log`, SHA256
  `37A0C6CFB5511AE182245058ED741796633F7AC1C1DA779A8FBC14BF5CD99365`.
  This local log is not a composed/accepted Forge evidence packet.
- Studio MCP discovery returned two instances, one named GuildborneGUIReview.rbxlx
  and one unnamed. Discovery is not place identity, source parity or gameplay QA.
- Forge doctor did not find Blender on PATH; earlier world evidence records an
  installed binary. This run did not establish Blender availability or absence.

No runtime source, schema, flags, saved data, asset IDs or Studio scenes were
changed. No new Studio/device/multiplayer acceptance, upload, publish or PR is
claimed. Full combat specifications remain missing from the supplied attachments;
the existing draft supports reconciliation but does not reconstruct that pack.
