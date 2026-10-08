# Production asset evidence ledger

Local original art libraries. Counts include alternate formats and reused geometry; do not interpret their sum as unique production-ready game assets. No cloud imports or human UAT approvals are claimed.

| Library | Blender | FBX | GLB | PNG | Native source | Remaining |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| [City room furnishings](../../assets/uat01/city-interior-kit/README.md) | 1 | 5 | 5 | 6 | [source](../../src/server/Services/CityInteriorKit.luau) | Native five-building integration complete; mesh imports, physical traversal and device acceptance pending |
| [Environment props](../../assets/uat01/adventure-kit/README.md) | 1 | 10 | 10 | 1 | [source](../../src/server/Services/AdventurePropKit.luau) | Roblox mesh import; dressing and environment acceptance |
| [Equipment weapons](../../assets/uat01/weapon-kit/README.md) | 1 | 5 | 5 | 1 | [source](../../src/server/Services/WeaponVisuals.luau) | Roblox mesh import; device readability |
| [Inventory display models](../../assets/uat01/item-kit/README.md) | 1 | 30 | 30 | 31 | [source](../../src/shared/Data/ItemVisuals.luau) | Roblox image/mesh import; arbitrary avatar fitting |
| [Sentinel custom rig](../../assets/uat01/character-kit/README.md) | 1 | 10 | 1 | 1 | None | Roblox rig import and retargeting |
| [Regional enemy rigs](../../assets/uat01/enemy-kit/README.md) | 13 | 60 | 12 | 13 | [source](../../src/server/Services/AdventureEnemyKit.luau) | Live regional AI, attacks, damage, quest events and rewards |
| [Traversable regional blockouts](../../assets/uat01/region-kit/README.md) | 3 | 3 | 3 | 3 | [source](../../src/server/Services/AdventureMapKit.luau) | Final dressing/boundaries, travel/checkpoints, encounters and rewards |
| [Companion visual templates](../../assets/uat01/hero-kit/README.md) | 16 | 75 | 15 | 16 | [source](../../src/server/Services/HeroVisualKit.luau) | Current companion appearances integrated; new recruitment catalog/ownership/rotation and custom-rig imports remain |
| [Cosmetic art prototypes](../../assets/uat01/cosmetic-kit/README.md) | 2 | 9 | 8 | 9 | [source](../../src/server/Services/CosmeticVisualKit.luau) | Entitlements/equip, shop delivery, cloak skinning and dynamic VFX |

Hash and size of each artifact: [production-libraries.json](intake/production-libraries.json). Registry now distinguishes30native inventory previews,15visual hero templates and8cosmetic art slots from their unfinished import/gameplay/ownership bindings. All239asset rows and65screen rows preserve `uatApproved=false`.
