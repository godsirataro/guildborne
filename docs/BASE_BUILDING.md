# Gathering and private base — Phase 2.4

> Current update — 2026-09-28: Current housing extension: one Quarters prefab, levels 1–9; capacity min(50, Hall×5, 5+Quarters×5). No Quarters means capacity 5. Hall 1–10 caps player/hero levels at Hall×5. Owner-only plots connect through the public Guild Zone promenade. See [costs and restrictions](CITY_GUILD_DISPATCH.md).

Four personal nodes provide Timber, Stone, Iron Ore and Herb. Gather at a nearby world prompt; the server checks ownership, live character, distance, cooldown and storage before committing two resources. Cooldowns persist through rejoin. Gathered materials share the existing inventory; previous quest supplies are retained.

## Build Mode

Open Guild → Base → Preview building. A translucent footprint and outline follow the grid controls. Arrows choose a cell, Rotate changes orientation, Place submits the intent, Cancel returns without cost. The client preview is advisory; the server independently validates every placement. Move preserves materials and building identity. Dismantle requires UI confirmation and returns floor(original material cost / 2), atomically with removal.

The private extension uses 8-stud cells, bounded x=6..11 and z=-4..4. Two-by-two prefabs must fit completely, may not overlap, and may not cover the permanent middle access lane. One of each building is allowed; the domain also caps total placements at eight. The original Hall remains the anchor. Decorative floor/wall construction is outside this prefab MVP.

| Building | Cost | Current benefit |
| --- | --- | --- |
| Warehouse | 8 Timber, 4 Stone | Raises gathering ceiling from 100 to 200 per resource |
| Hero Quarters | 8 Timber, 6 Stone, 2 Herb | Rest recovery +50%; prerequisite for prestige classes |
| Blacksmith | 6 Timber, 8 Stone, 4 Iron Ore | Enables three recipes |

The gathering ceiling controls new node harvesting, not deletion of existing or quest-earned stacks. Original stack caps remain authoritative for other rewards. Quarters do not increase the five-companion party limit.

## Facility crafting — Phase 2.7

At an owned Blacksmith: 3 Iron Ore + 1 Stone → Iron Ingot; 2 Iron Ingots + 2 Timber → Guardian Plate; 5 Herbs + 3 Stone → Vitality Charm. Recipe inputs, output capacity and instance sequencing commit together. Equipment outputs remain account-bound. This is a bounded crafting slice, not a production queue or automated offline economy.

## Persistence and limits

Schema v4 stores `expansion.buildings`, `nextBuilding`, `gatherReady` and discovered resource flags. The scene is reconstructed from committed data. No client price, item quantity or world Instance enters the saved record. Save failures expose no partial material deduction or placement. Construction and class changes require returning to the guild outside combat. No publishing or multiplayer isolation evidence is implied by solo Studio testing.
