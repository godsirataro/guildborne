--!strict
-- Local encounter assembly contract. Runtime travel, AI and rewards are not enabled by this catalog.
return {
    RuntimeEnabled=false,
    Regions={
        Greenwood={Map="Greenwood",Arrival="Arrival",Encounters={
            {Marker="ScoutCamp",Asset="greenwood_scout",Role="Melee"},
            {Marker="ArcherCamp",Asset="greenwood_archer",Role="Ranged"},
            {Marker="BoarTrail",Asset="greenwood_boar",Role="Charge"},
            {Marker="ForestCaptain",Asset="forest_captain",Role="Boss"},
        }},
        Ironveil={Map="Ironveil",Arrival="Arrival",Encounters={
            {Marker="RaiderCamp",Asset="quarry_raider",Role="Melee"},
            {Marker="StoneGuard",Asset="stone_guard",Role="Guard"},
            {Marker="ShamanCamp",Asset="crystal_shaman",Role="Support"},
            {Marker="QuarryGuardian",Asset="quarry_guardian",Role="Boss"},
        }},
        Ashen={Map="Ashen",Arrival="Arrival",Encounters={
            {Marker="SentinelCourt",Asset="arcane_sentinel",Role="Melee"},
            {Marker="CasterCourt",Asset="rune_caster",Role="Spell"},
            {Marker="HoundApproach",Asset="rune_hound",Role="Charge"},
            {Marker="ArcaneWarden",Asset="arcane_warden",Role="Boss"},
        }},
    },
}
