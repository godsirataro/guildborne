# Regional supply requests

Six one-time NPC quests extend existing friendly-Orc professions across all six regional gathering nodes. They are enabled only with the owned offline regional feature flag. Normal worlds reject acceptance and hide their offers. Existing prerequisite quests, reward transactions, NPC proximity and gathering cooldowns remain authoritative.

| Quest ID | NPC | Exact node | Prerequisite |
| --- | --- | --- | --- |
| borga_greenwood_timber | Borga | greenwood_wood | borga_hearth |
| mogra_greenwood_herbs | Mogra | greenwood_herbs | mogra_gathering |
| rukk_ironveil_stone | Rukk | ironveil_stone | rukk_practice |
| rukk_ironveil_ore | Rukk | ironveil_ore | rukk_ironveil_stone |
| mogra_ashen_herbs | Mogra | ashen_herbs | mogra_greenwood_herbs |
| borga_ashen_stone | Borga | ashen_stone | borga_greenwood_timber |

Each asks for two successful gathers after acceptance, awards 8 Gold and 6 XP under the existing journal participant rules, and leaves collected materials in inventory. These rewards are an initial offline balance choice. Prior collection, guild-node collection, cooldown rejection and replay do not advance these regional counters. Existing generic gathering quests still count the established regional aliases. Names and descriptions are localized in English and Thai. The game now has 31 journal quests plus 3 timed expeditions; the 240-card story draft remains unimplemented.

453 full domain tests pass. Twelve node/recovery cases cover all six quests with before-write and after-write uncertainty, claim replay, rejoin, exact progression, retained materials and one reward. Offline-disabled offers are also checked. Actual keyboard/UI journey completed Mogra's original lesson and both Greenwood/Ashen follow-ups at revision22, 24 Gold, 20 character XP and 12 herbs, with no direct state grants. Movement-only debug approaches shortened walking. One initial Ashen interaction did not register; the locked claim correctly showed 1/2, and a further genuine gather completed it. The other four new quests still need full live journeys, alongside physical-device and human UAT.

Evidence: validation-regional-supplies-domain.txt and validation-regional-supplies-live.json.
