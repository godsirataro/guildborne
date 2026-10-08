# Spire of Echoes — Phase 2.6

A personal ten-floor challenge uses the player and selected AI party. Open Guild → Tower or the portal near the training yard. Start at floor 1; after clearing floor 5, later attempts may start at floor 6. Enter Floor begins combat and transfers the party to the bounded Spire arena. The same arena is rebuilt for each floor, with floor-dependent colors and encounters, rather than ten simultaneously simulated maps.

Odd floors use melee echoes; even floors add ranged formations. Floors 5 and 10 contain a larger Warden with two guards. Wardens telegraph a windup before their attack. Stats scale by floor. Echoes reuse the existing prototype enemy rig; this is an encounter-system slice, not ten unique art sets.

## Completion and rewards

All enemies must be defeated while the player survives. Only the private server completion path commits a clear; no public remote accepts a victory, reward amount or kill count. A run ID, current floor and Fighting state must match the committed profile. Duplicate callbacks and uncertain saves cannot grant rewards twice.

First clear of floor n grants 15+3n Gold, 40+10n XP to the player and selected heroes, 4 Stone and 2 Iron Ore. Repeats grant 4+n Gold, 8+2n XP, 1 Stone and 2 Iron Ore. Individual tower enemies do not additionally grant camp rewards. Floor-5 progress unlocks Class 3 and the checkpoint; floor 10 helps unlock Secret/Legendary advancement. Base resource nodes remain available outside the tower.

Between clears, the next floor is Ready and the player returns to the guild to rest and adjust equipment/skills. Party membership stays locked for the attempt; ordinary timed expeditions cannot overlap it. Clearing floor 10 ends the run. Highest clear and checkpoint persist.

## Failure, leaving and rejoin

Player downed ends the floor attempt as Failed; after normal recovery, leave and begin again from an available entry floor. Leave Tower abandons the current fight without awarding a clear and preserves previously cleared floors. If disconnected during Fighting, rejoin reconstructs that floor with fresh enemies; no partial kills or unearned rewards carry over. A server crash before the clear commits requires replaying the floor. Committed clears survive rejoin.

Transient HP, threat and cooldowns remain session state. Rest recovery follows existing rules and benefits from Hero Quarters. Solo Studio evidence does not certify published multiplayer, physical-device performance or long-term balance.
