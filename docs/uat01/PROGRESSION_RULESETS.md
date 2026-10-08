# Versioned progression foundation — 2026-10-03

Implemented, isolated and verified; Novice onboarding is not enabled in the main game.

- Ordinary profiles still use schema 7 and the original Hall × 5 level cap.
- An explicit schema 8 factory creates Novice profiles at level 1, XP 0, Hall 0. Hall 0 caps level at 10; Hall 1 at 20; later Halls add five levels up to 100.
- Migrating schema 7 to the opt-in schema 8 marks the profile as legacy. Existing XP, levels, inventory, currency, buildings and heroes are preserved. Migration does not uplift heroes or grant rewards.
- Every existing XP producer and the projected cap use the profile's ruleset. Classless Novice XP is valid; selecting a class below level 10 is invalid. Main bootstrap continues to use schema 7.

Verification: 469 domain tests passed, including five ruleset/migration/reward/save-recovery tests and the existing 5,000-order market simulation with zero invariant violations. Native Roblox JSON round trips covered 21 Novice Hall states, 20 legacy Hall states and 20 migrated profiles (61 round trips), with zero real profile writes. Strict analysis, compile, main/offline builds and the 196-runtime-file repository check passed. Fresh main-runtime readback remains revision 0, Hall 1, level 1, XP 0, cap 5.

Evidence: `validation-progression-rulesets-domain.txt`, `validation-progression-rulesets-native.json`, `tests/progression_rulesets.luau`, `tests/studio_progression_rulesets_probe.luau`.

Still required before enabling Novice: authoritative Chapter 00 objectives, solo class trials, class-selection gating, free Hall 1 and guaranteed level-10 hero grant, recruitment/guild gating, UI and world bindings, persistent reconnect and full actual-input journey. The draft 35-class/240-quest design is not implemented by this foundation.
