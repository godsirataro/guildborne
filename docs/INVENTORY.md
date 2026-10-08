# Inventory and equipment — Phase 2.3

> Current update — 2026-09-28: Current roster supports duplicate classes with unique h:N hero IDs and separate equipment. Actor selectors show rank and ID. Heroes on remote jobs cannot change gear or receive transferred gear; dead heroes retain possessions. See [city and dispatch](CITY_GUILD_DISPATCH.md).

Implemented locally and verified in Studio on 2026-09-28. See [delivery](PHASE2_3_IMPLEMENTATION.md) and [native evidence](PHASE2_3_STUDIO_TEST.md).

## Ownership and assignment

One account inventory holds at most 50 equipment instances plus material stacks. Equipped items still count toward capacity. The player and each of five owned heroes have independent `weapon`, `armor`, and `accessory` slots. An instance may belong to only one actor at a time. Assigning it to another actor removes its previous assignment in the same persisted command; a displaced destination item remains in inventory. All equipment is account-bound.

Weapons retain their class restrictions. Leather Vest, Bronze Ring and Vitality Charm fit every class; Guardian Plate fits Warrior/Knight; Woven Robes fits Mage/Priest. The player's empty weapon slot uses the class training kit, which is not an inventory item and cannot be sold or transferred. Heroes with an empty weapon slot have no weapon bonus. A player must select a class before equipping.

## Acquisition and removal

The equipment shop accepts earned Gold. Prices come from server content; clients send only a definition ID. Purchases allocate monotonically numbered `shop:N:1` instance IDs. Gold, capacity, item creation and sequence increments commit together. Selling requires an unassigned instance and a two-click UI confirmation; it destroys the item and credits floor(purchase price / 2) Gold atomically. This provides a way to free capacity. Materials cannot be bought or sold here.

| New item | Gold | Bonuses | Classes |
| --- | ---: | --- | --- |
| Leather Vest | 18 | HP +4, Defense +2 | Any |
| Guardian Plate | 30 | HP +6, Defense +4 | Warrior, Knight |
| Woven Robes | 24 | HP +8, Defense +1 | Mage, Priest |
| Bronze Ring | 15 | Attack +1 | Any |
| Vitality Charm | 20 | HP +8 | Any |

Training weapons cost 12 Gold; Iron Sword costs 28. Existing quest/recruitment awards are unchanged. Fifteen item definitions now include four materials, six weapons, three armor items and two accessories.

## Stats, presentation and UI

Shared equipment calculation drives projected and combat HP/Attack/Defense. Only weapon attack contributes to the existing expedition weapon-duration bonus. An expedition keeps its starting snapshot when gear is moved. Live combat updates equipment stats and visuals, clamps current HP to the new maximum and preserves cooldown/downed state; equipping extra maximum HP does not heal.

Inventory supports player/hero selection, type and compatibility filters, ownership labels, stat deltas, unequip, transfer, buy and confirmed sell. English/Thai strings and scrolling 52-pixel buttons support compact viewports. Armor plates and accessory attachments are prototype visuals for the existing rigs, not a complete cosmetic wardrobe.

## Storage and security

Schema v3 adds `character.equipmentSlots` and `inventory.nextEquipmentSequence`. The v2→v3 migration validates legacy records and adds only these fields. v1 chains through v2. Unexpected pre-existing migration fields, corrupt records and future versions fail closed. Retain a v3-capable reader for rollback; do not downgrade/reset player data.

Commands validate exact payload shape, owned actor/instance, class and slot compatibility, revision and request ID. Existing serialized candidate commits, session fencing, receipts and uncertain-save reconciliation protect all equipment mutations. Schema validation independently rejects duplicate cross-actor assignments. No trading, crafting, enhancements, random rolls or monetization are included.
