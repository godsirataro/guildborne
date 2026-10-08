# Phase 2.3 — Inventory & Equipment

Completed locally and Studio-verified on 2026-09-28; not published. The user's continuation after Phase 2.2 authorized this delivery.

The player and five heroes now share an account inventory with separate weapon/armor/accessory assignments. Moving an item updates both actors atomically. A Gold shop and confirmed sale flow make new gear available and allow capacity recovery. Filters, comparison deltas, ownership labels and Thai/English UI expose these rules. Five new armor/accessory definitions bring the catalog to fifteen.

`Equipment` centralizes compatibility, loadouts and stat bonuses. `EquipmentService` runs assign/unequip/buy/sell inside the existing saved-command boundary. `InventoryView` renders the management controls. Progression, combat and hero presentation consume the same loadout model, and HeroRig renders prototype armor/accessories. Schema v3 migrates v1/v2 without changing legacy ownership, progression or active expedition snapshots. See [rules and prices](INVENTORY.md).

## Validation

- 89 automated tests: the previous 75 plus 14 inventory/migration/atomicity/fault cases. Rojo build, strict Roblox-aware analysis, compilation, repository checks and whitespace checks passed.
- Actual DataStore v2→v3 migration preserved every legacy data field after removing only the two new fields for comparison.
- Native shop and two-click sale, three-slot player↔hero transfers, derived stats/visuals, equipped combat and HP clamp/no-refill passed.
- Thai portrait and English landscape device simulation inspected; exact saved schema/data/revision matched across Stop/Play.

See [Studio report](PHASE2_3_STUDIO_TEST.md) and [automated output](evidence/phase23-validation.txt). Runtime has 50 Luau files. QA used an isolated store; normal staging configuration was restored after testing. Physical-device, published-client and multiplayer checks remain unrun for this phase.

## Next

Phase 2.4 — Gathering & Build Mode MVP: server-owned wood/stone/ore/herb gathering, a bounded private grid, preview/rotate/place/move/dismantle, building costs and exact base restoration. Skill trees/Class 2 remain Phase 2.5; tower Phase 2.6; Class 3/special classes/races Phase 2.7. See [roadmap](ROADMAP.md).
