# Personality, Bond and Secret Path — adapted controller handoff

2026-10-20. Status: SOURCE-RECONCILED PROPOSAL, NOT IMPLEMENTED OR ACCEPTED.
Source audit: controller d5e9379; independent read-only reviewer r6_preflight.
The human's pasted design, relayed by the recovery chat, is design input, not
runtime evidence or an asset license. This is the canonical handoff for this
proposal; production/plan.json remains the unchanged ownership authority.

## Latest operating instruction

Stop starting work at or below **30% weekly Codex quota remaining**, replacing
50% and the older 5% boundary. Check supported account usage between bounded
waves and before costly dispatch; if unavailable, stop new costly dispatch.
Latest supported read: 22% used / 78% remaining. Preserve active work and report;
no shutdown is authorized. Do not redeem resets, purchase credits, publish,
enable commerce, delete worktrees or touch production DataStores.

S16 remains the sole Controller. Reuse existing S13/S14/S15/S17 chats and
suitable checkouts. No new specialist chat is needed for this proposal: S17
already owns narrative/quest/character work. A missing runtime ownership scope
must be repaired in the existing plan, not hidden by creating another writer.

## Verified source, bounded claims

- `src/server/Config/Content.luau` defines 15 HeroTemplates with Id, Name, Class
  and VisualId. Personality, preferences and Bond fields are not defined there.
- `src/server/Systems/ProfileSchema.luau` validates owned-instance template,
  class and name consistency. Owned IDs such as `a:<Class>` and `h:<sequence>`
  are distinct from names and template IDs. Rowan remains Warrior; hero Elian
  and Marshal Elian are separate identities.
- No named Bond/HeroEcho runtime, field, receipt path or test was identified in
  this branch's schema, recruitment, projection and expansion code. Migration
  copies raw records and is not a globally closed schema: preserve unknown
  saved extensions; this audit does not prove every historical save lacks them.
  Existing mentorProof, class3Proof and quest receipts are not Bond evidence.
- `src/shared/Data/Expansion.luau` has these Prestige paths:

| Canonical ID | Base class | Label | Required tower highest | Explicit Secret |
| --- | --- | --- | --- | --- |
| commander | Warrior | Epic | 5 | No |
| rune_knight | Knight | Epic | 5 | No |
| bard | Priest | Epic | 5 | No |
| shadow_dancer | Archer | Legendary | 10 | Yes |

All four require the actor's level 70, matching class, Tier2 to Tier3,
`quarry_patrol` first-clear and placed Hero Quarters. Shadow Dancer additionally
requires recorded wood, stone, ore and herbs gathering. Preserve the integrated
actor/path-specific Class3 proof policy, existing earned paths and legacy
Class2 level30 versus Novice level35. Prestige labels are not Rank gates.
See `production/progression/CLASS3_EARNED_PROOF_CONTRACT.md`.

Mage has ordinary elementalist/archmage and spellblade/arcane_knight paths.
No Mage Prestige row exists. **Rift Weaver is proposed and has no runtime ID**;
do not rename or repurpose arcane_knight.

`src/server/Systems/HeroTactics.luau` supports Focus, Regroup, Retreat, Hold,
Balanced and Defensive. Manual orders, ownership, leash/safety, downed-state
handling, hazard evasion, mentor control, cooldowns and healing eligibility
remain authoritative. Personality cannot override them or authorize damage.

## Proposed content — keep separate from saved implementation

Separate identity, stable personality, balanced personal traits, earned
relationships/memories, Class/Secret Path, Rank/Echo and owned appearance.
Do not introduce stacked random rolls or paid progression.

| Existing template group | Proposed stable personalities |
| --- | --- |
| warrior_01/02/03 | Rowan Loyal; Kira Reckless; Toren Stoic |
| knight_01/02/03 | Bram Protective; Elian Disciplined; Vera Brave |
| archer_01/02/03 | Ash Curious; Neris Mysterious; Fenn Playful |
| mage_01/02/03 | Lyra Calculating; Orin Ambitious; Selene Mysterious |
| priest_01/02/03 | Sage Compassionate; Iona Loyal; Corin Stoic |

These cover the proposed 12 archetypes. Five proposed Bond stages are
Acquaintance, Trust, Companion, Oathbound and Legacy. Thresholds and IDs are
unapproved design choices. Team Combos need a separate balance/server contract.
Echo/duplicate rank progression must never erase personality, Bond or chosen
path; no new rank economy or migration is authorized by this document.

Secret Hero identity/acquisition and Secret Class unlocks remain different
systems. Existing owned heroes should use supported class selection, not require
a random duplicate carrying the desired class. Future paid-random policy and
commerce are outside this wave. The illustrative Story.com image has no adopted
provenance and is not approved game art.

## Existing-session allocation and current dispatch

| Owner | Bounded current work | Later implementation boundary |
| --- | --- | --- |
| S13 Map | Read-only audit of existing Shadow Dancer/story anchors and reachable approaches | Location/landmark/trainer placement after contract; no unlock authority |
| S14 GUI | AlreadyEquipped source repair integrated as c2b385a; native Inventory retest owned by Controller | Hero profile, personality, committed Bond/memories and discovery feedback after data contract; no invented progress |
| S15 Animation/VFX | Read-only rig/attachment/manual-order compatibility and reusable presentation audit | Gestures/audio/effects from approved state; no authoritative hits or forced AI actions |
| S17 NPC/Item/Quest/Character | Read-only one-story reuse and modular appearance/equipment reconciliation | Narrative specification through existing hero-stories document scope; implementation only after scope reconciliation |
| S16 Controller/domain role | Schema/receipt/projection contract and integration sequencing | Server-owned unlocks, replay-safe credit, migrations, save preservation and independent acceptance |

The 30% boundary was sent to all four existing sessions. S13's first send failed;
its old terminal turn was checked before one successful retry. No duplicate
worker or new worktree was created.

Human/Elf/Orc/Dwarf appearance remains cosmetic; Wizard uses Human appearance.
S17 bodies, proportions, modular clothes/hair/ears/tusks and gear must share
reviewed slot/attachment contracts with S15 rigs/motion and S14 previews.
Legacy ancestry bonuses must not be silently changed.

## First playable contract and acceptance sequence

1. Keep the current connected-world/GUI/combat/NPC acceptance backlog active.
2. Specify one optional Rowan story keyed to the owned instance, using committed
   participation evidence and dialogue/cosmetic recognition. No combat-power
   reward, compulsory Bond grind, rank gate or new class unlock in this first story.
3. Before runtime writes, define bounded versioned state, defaults/migration,
   event provenance, replay/idempotency rules, duplicate-template behavior,
   removal/recovery and preservation of unknown save data. Exercise real legacy
   fixtures and same-name distinct heroes.
4. Reconcile one bounded Bond runtime ownership task. Existing hero-stories is
   documents-only. No existing task spans the necessary schema/private receipts/
   recruitment/projection; SettlementService and HeroPresentation currently lack
   explicit file ownership. Use controller-registry and the established fresh
   shared-ledger migration procedure after writers stop; do not borrow unrelated
   tasks or create a competing persistence service.
5. Bind S14 to committed state; test unavailable/loading/pending/replay states,
   EN/TH, keyboard and narrow layouts. S15 cues obey all existing orders.
6. Separately propose one Shadow Dancer discovery trail around the current
   requirements, with actual reachable anchors, missing-requirement feedback and
   server validation. Do not silently replace its existing admission rules.
7. Verify one real story loop and one discovery loop before expanding content.
   Fifteen biographies, 12 archetypes, five stages, four Prestige narratives,
   Rift Weaver and 30–60 heroes remain proposed targets, not completed features.

Local tests, Studio, multiplayer, physical devices and human story/art acceptance
remain separate. A plan or source audit passes none of those runtime gates.
