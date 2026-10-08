# Status allocation — offline first playable

Implements the supplied five-stat AP budget without changing the existing XP/Hall/class progression rules. Novice level1–10 and the full v2 progression migration remain separate unfinished work. Enabled only alongside the memory-only PlaceId0/GameId0 Studio slice; other worlds reject allocation/reset commands.

Each owned actor has an optional `statusAllocations` map. Missing maps preserve legacy statistics. AP is derived as3×(level−1), never incremented by a reward or respec. A stat accepts0–150 integer points; total spending cannot exceed the actor's own budget. Effective points use the supplied40/80soft caps. Server validation rejects unknown keys, nonfinite values, overspending and foreign actors.

Initial coefficients, not final balance:

| Allocation | Effect per effective point |
| --- | --- |
| STR | +0.25Attack for Warrior/Knight |
| DEX | +0.25Attack for Archer; +0.015movement speed for every class |
| INT | +0.25Attack for Mage/Priest |
| VIT | +2maximum HP and +0.1Defense |
| WIS | +0.5flat healing and0.1percentage-point stronger Guard damage reduction |

Health/Attack/Defense/healing bonuses round down after aggregation; speed rounds to two decimals. WIS modifies existing Heal/Guard effects, without inventing mana, critical chance or accuracy. Shared projection and combat calculations use the same bonus function. Current baseline Guard multiplier0.55 is reduced by at most0.1; this point budget reaches0.085. Buffs retain the caster's strength for their existing duration.

`AllocateStatus` adds1–100points per request after authoritative budget validation. The UI offers1/5/10steps and previews derived changes. `ResetBuildPoints` clears that actor's SP purchases, selected art and AP allocation for free in this offline build. It preserves class/path, level, XP, gear, currencies and combat cooldowns. Successful class advancement also clears spent points once; duplicate/invalid advancement cannot refund an already-refilled build. Legacy paid `ResetSkills` is rejected while this offline feature is enabled; the old behavior remains in other worlds.

Changes require proximity within24studs of the owner's Hall station, a living player and no active combat. Domain checks also reject expeditions, Tower runs and unavailable/dispatched heroes. Existing persistence owns revision checks, disposable mutation copies, uncertain-save recovery and idempotent receipts. Optional maps require no destructive migration or XP rewrite.

Validation:450domain tests including eight status cases passed. This includes separate actor budgets, replay, before/after-write failures, rejoin, schema corruption, actual healing/Guard expiry and advancement refunds. Native fixture passed eight spatial cases and real CombatService resync preserved7HP, cooldown42, nextAbility50 and nextAttack51 while changing derived HP/healing. The fixture uses its own enabled configuration because MCP's module cache does not share Bootstrap's frozen Content object. The actual client snapshot separately confirmed both offline flags enabled. Physical devices, balance and human acceptance remain open.

Actual UI: city/out-of-range request rejected without spending. Rowan earned level2/50XP through Trail Watch and Timber Escort, then spent3VIT near the owner Hall at revisions10–12; projected HP33→39 and all further spending buttons disabled. Learned Vitality at13, confirmed combined reset14; HP33,availableAP3,skills empty,Gold70 and XP50 unchanged. Thai page reviewed at15. The raw native diagnostic initially hit the MCP configuration-cache difference; that tool assertion was corrected with a fixture-owned gate and is not a runtime exception.
