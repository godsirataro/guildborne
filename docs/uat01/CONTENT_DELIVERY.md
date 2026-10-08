# UAT content delivery — 2026-10-01

Catalog version: `uat01-content-1`. Existing save schema and IDs are preserved. Total: **30 items, 10 deterministic recipes, 18 quests** (3 timed expeditions + 15 Journal quests). Dispatch routes are excluded from the quest count. The three playable adventure regions are still pending.

## Equipment

All fourteen additions are account-bound. The market still accepts exactly five original materials. New items are bought with earned Gold; seven also have material crafting routes. Hall gates apply to both purchase and crafting. Existing gear is preserved.

| ID | Name | Class | HP / attack / defense | Gold | Hall |
|---|---|---|---|---|---|
| watchblade | Watchblade | Warrior | 0 / 5 / 1 | 90 | 3 |
| oathblade | Oathblade | Knight | 0 / 3 / 2 | 85 | 3 |
| yew_longbow | Yew Longbow | Archer | 2 / 5 / 0 | 90 | 3 |
| tide_staff | Tide Staff | Mage | 0 / 5 / 1 | 95 | 3 |
| dawn_crozier | Dawn Crozier | Priest | 5 / 4 / 0 | 95 | 3 |
| scout_coat | Scout Coat | Warrior, Archer | 6 / 0 / 2 | 60 | 2 |
| runewoven_mantle | Runewoven Mantle | Mage, Priest | 10 / 0 / 2 | 72 | 3 |
| harbor_mail | Harbor Mail | Any | 4 / 0 / 3 | 50 | 2 |
| vanguard_harness | Vanguard Harness | Warrior, Knight | 10 / 0 / 2 | 70 | 3 |
| pilgrim_robes | Pilgrim Robes | Any | 12 / 0 / 0 | 50 | 2 |
| sentinel_seal | Sentinel Seal | Any | 0 / 0 / 2 | 45 | 2 |
| hunters_token | Hunter's Token | Warrior, Archer | 2 / 2 / 0 | 55 | 2 |
| focus_prism | Focus Prism | Mage, Priest | 0 / 2 / 1 | 60 | 3 |
| wardstone | Wardstone | Any | 4 / 0 / 1 | 45 | 2 |

Seven new recipes: watchblade, oathblade, yew_longbow, tide_staff, dawn_crozier, scout_coat and runewoven_mantle. Existing iron_ingot, guardian_plate and vitality_charm recipes remain unchanged. RecipeOrder drives the native crafting UI. RecipeValidator verifies ordered IDs, material references, positive quantities, output references and Hall gates at bootstrap.

Crafting consumes materials and creates one bound instance in the same existing disposable command candidate. Capacity failure, insufficient materials or failed persistence do not expose a partial result. Existing replay receipts and inventory sequence protect duplication. New cosmetics in the equipment art are not commercial cosmetic offers.

Native presentation uses existing original sword/bow/staff families plus catalog tint and armor/accessory geometry. The generated atlas is a richer icon source, not evidence that rigs match every illustration detail.

## Added Journal objectives

Existing objectives remain. State objectives recognize already-owned progress when accepted; event objectives start on acceptance. Requirements name earlier quests and require claimed completion. All rewards are once per profile, through the existing save transaction. Total added rewards across eleven quests: 136 Gold and 120 XP per eligible actor; no repeat rewards.

| ID | Objective | Mode | Requires |
|---|---|---|---|
| stonework | Gather stone three times after accepting this quest. | Gather:stone | city_gate |
| ore_supply | Gather iron ore three times after accepting this quest. | Gather:ore | stonework |
| herb_field | Gather herbs three times after accepting this quest. | Gather:herbs | — |
| forge_foundation | Build or own a Blacksmith in your guild. | Forge | stonework |
| first_ingot | Smelt one Iron Ingot after accepting this quest. | Craft:iron_ingot | forge_foundation |
| field_outfit | Craft one weapon, armor or accessory after accepting this quest. | CraftEquipment | first_ingot |
| ready_for_battle | Equip an owned item on your character or a companion after accepting this quest. | Equip | city_gate |
| growing_hall | Reach Guild Hall level 2 or higher. | Hall2 | camp_threat |
| company_reinforcement | Own at least two adventurers. | Roster2 | city_gate |
| first_lesson | Learn at least one skill-tree node on your character or a companion. | LearnedSkill | ready_for_battle |
| spire_entry | Enter a Tower encounter after accepting this quest. Victory is not required. | EnterTower | first_lesson |

## Validation

Equipment milestone: 277 tests plus complete automated checks passed. Quest-chain milestone: 280 tests plus complete checks passed. Final regression validation-content-final.txt passed **282 tests** and all automated checks, including new roster/skill/Tower guidance and legacy active-expedition content-version compatibility checks.

Studio: real saved profile loaded; mouse navigation opened Base with ten recipe cards, all correctly disabled for its missing forge. Isolated ServerStorage fixture exercised five weapon families and nine outfit visuals with tint and noncollision checks; fixture removed. Real Journal rendered ten Main entries and specific translated prerequisite locks. No craft, purchase, quest acceptance/reward, class or save mutation was requested on the real profile. Full fresh-profile progression and mobile/multiplayer UAT are still pending.

Art: assets/uat01/generated/guildborne-equipment-icons-v1.png is a 1254 × 1254 RGBA atlas with fourteen cells and two empty cells; source pixels unchanged. Manifest includes candidate crops and hashes. Empty EquipmentAtlas ID keeps fallback text/native models active. Upload and crop/import review remain separate.

Final source parity: sixteen changed runtime modules match disk. Studio left in Edit mode.
