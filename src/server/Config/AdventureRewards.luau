--!strict
-- Provisional earned rewards. Only trusted encounter code can select an entry.
-- Travel and map visibility never grant these rewards.
return {
    greenwood_scout={Gold=3,XP=3,Items={},Event="GreenwoodScout"},
    greenwood_archer={Gold=4,XP=3,Items={},Event="GreenwoodArcher"},
    greenwood_boar={Gold=4,XP=4,Items={{Id="herb",Quantity=1}},Event="GreenwoodBoar"},
    forest_captain={Gold=12,XP=10,Items={{Id="timber",Quantity=2}},Event="ForestCaptain"},
    quarry_raider={Gold=5,XP=5,Items={},Event="QuarryRaider"},
    stone_guard={Gold=6,XP=5,Items={{Id="stone",Quantity=1}},Event="StoneGuard"},
    crystal_shaman={Gold=6,XP=6,Items={},Event="CrystalShaman"},
    quarry_guardian={Gold=18,XP=15,Items={{Id="iron_ore",Quantity=2}},Event="QuarryGuardian"},
    arcane_sentinel={Gold=7,XP=7,Items={},Event="ArcaneSentinel"},
    rune_caster={Gold=8,XP=7,Items={},Event="RuneCaster"},
    rune_hound={Gold=8,XP=8,Items={},Event="RuneHound"},
    arcane_warden={Gold=24,XP=20,Items={{Id="herb",Quantity=3}},Event="ArcaneWarden"},
}
