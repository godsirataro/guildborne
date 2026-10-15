# Hero tactics contract
Status: FIRST LOCAL SLICE AUTHORIZED; check integration report for actual evidence.

Current Focus/Regroup/Retreat already run through PlayerCombatInput, CombatService and HeroService. Extend those modules; there is no separate combat authority.

First slice: Balanced preserves current policy. Defensive prioritizes valid threats near the owning leader and bounds pursuit. Hold captures the selected owned hero's position on the server. Regroup uses stable role-aware nearby offsets with existing floor/path validation and fallback. Manual commands override autonomous movement; hazard evasion and leash recovery outrank an unsafe anchor. Healing still requires effective targets, range and cooldown.

Orders and presets are transient in this slice. Persistent per-hero presets, skill-priority editor, aggressive mode and strategy-table saving remain planned additive schema work. Changing an order must not heal, reset cooldown, grant a skill, change inventory or award XP. Player cannot command another owner's hero; Party leadership adds no ownership rights. Mentor-controlled heroes remain under the existing exclusive controller.

Native controls and behavior reason expose what the selected hero is doing. Preserve original input actions; no client damage/target coordinates. Clear stale Hold state after region changes, death/removal or invalid formation anchors. Test all five classes, no target, invalid actor, cooldown, reachability, travel, regeneration boundary and boss evasion. Real full-party performance and human feel remain separate acceptance gates.
