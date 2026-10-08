# Phase 2.2 — Player Character & Class Foundation

Status: **implemented and Studio-verified on 2026-09-28; not published**. Scope explicitly authorized on 2026-09-28 after the three source chats were consolidated in [project status](PROJECT_STATUS.md). No publishing is part of this change.

## Delivered

- Confirm one of five starter classes: Warrior, Knight, Archer, Mage, Priest. Human/Class 1, separate player XP/level and derived stats. The player does not occupy any of the five companion slots.
- F/click basic attack, Q starter ability, touch-sized buttons, separate player HP/cooldown and TH/EN feedback. Target selection, range, class, damage, cooldown and awards are server-owned.
- Training weapon attached to the player's R6/R15 avatar, short procedural action poses and shared combat VFX. These are starter presentation, not a completed bespoke animation/audio library.
- Downed movement/action lock, ten-second recovery to the guild at half HP. Avatar reset preserves session HP/cooldowns/downed timer. Fresh sessions reset transient combat state.
- Actual damage/taunt/combat healing determines player XP eligibility; idle observation grants none. One enemy death awards Gold once, alongside eligible player and companion XP. The existing receipt/lease/uncertain-write pipeline remains authoritative.
- Rest all heroes for solo combat after choosing a class. Expeditions still require a hero party, and their saved snapshot remains independent of player combat.
- Additive schema v1→v2 migration, definition version/path/race/skill references, exact rejoin and corrupt/future-data protection. See [data model](DATA_MODEL.md) for rollback implications.

## Implementation map

[PlayerCharacter](../src/server/Systems/PlayerCharacter.luau) handles the saved choice. [PlayerCombatInput](../src/server/Systems/PlayerCombatInput.luau) bounds exact combat intents. [PlayerParticipation](../src/server/Systems/PlayerParticipation.luau) controls player XP eligibility, including expired-taunt rejection. [CombatService](../src/server/Services/CombatService.luau) adds a separate manually controlled actor to existing combat. [PlayerCombatController](../src/client/Controllers/PlayerCombatController.luau) supplies controls, HUD and poses.

Content/ProfileSchema/Commands/Protocol/ViewProjection and bootstrap wiring implement the persisted character. NetworkService adds the separate CombatIntent channel; WorldService/HeroService route it. HeroRig supports the player hand attachment. CombatRewards accepts player plus five heroes atomically. SliceUI/Localization add class confirmation and character stats. Domain types and documentation describe the current contract.

## Validation

75 automated tests pass: the original 59 plus 16 character/migration/security/participation tests. Strict Roblox-aware Luau analysis, all source/test compilation, Rojo build/sourcemap, repository validation and diff whitespace checks pass. The final gate covers 24 required documents and 47 runtime source files; [validation log](evidence/phase22-validation.txt). Studio source parity is 47/47 with normal staging configuration and default viewport restored. [New tests](../tests/player_character.luau) cover migration with populated heroes/gear/active quest/receipts/audit, load-time migration, corrupt preservation, all class references, repeated selection, uncertain saves, independent XP/level, six recipients, passive XP rejection, caps, solo party rules, rate limiting and expired taunt participation.

[Studio evidence](PHASE2_2_STUDIO_TEST.md) records native five-class combat, actual migration/rejoin, downed/reset, keyboard/button activation and mobile inspection. [The QA client helper](../tests/studio_player_probe.luau) is outside the Rojo runtime map; its positioning assistance tests casts/rewards, not ordinary navigation.

## Boundaries and next work

Class choice is currently permanent and explicitly confirmed in UI. Only Human/Class 1 is playable; level cap stays 10. No full skill tree, higher class tier, inventory armor/accessory system, gathering, building, tower, special race or monetization is added. Existing NPC recruitment still permits one owned hero per class.

Next: **Phase 2.3 Inventory & Equipment** — shared account storage, exclusive per-instance assignment across player/five heroes, player equipment slots and kit replacement, weapon/armor/accessory compatibility, comparison/filter UI, atomic reassignment and migration/save-failure/rejoin tests. Building/gathering follows in 2.4; skill trees/Class 2 in 2.5; the ten-floor tower in 2.6.
