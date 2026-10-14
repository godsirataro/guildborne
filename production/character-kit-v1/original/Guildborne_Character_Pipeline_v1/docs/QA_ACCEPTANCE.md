# Guildborne Character System — Acceptance & UAT

## Gate 0 — Contract/manifest

- [ ] Existing Roblox character, hero, clothing/equipment and save systems inspected before editing.
- [ ] Existing asset IDs cross-referenced; no duplicates or name conflicts.
- [ ] Registry validator passes and every asset has stable ID, target path, tech and fit-profile.
- [ ] Local-only source/export placeholders NOT reported as actual 3D deliverables.

## Gate 1 — Golden path: Human Standard + contrast body

- [ ] Human Standard actually has 15 separate MeshPart body parts in Studio.
- [ ] Human Heavy or Slim also exists with visibly different proportions (if P0 alternate is delivered).
- [ ] R15 rig connections, Humanoid and RootPart present, no exploded joints.
- [ ] Base body always has opaque modesty covering when clothes removed.
- [ ] At least 3 skin tone selections visibly tint all correct anatomical parts incl. hands/neck/face.
- [ ] Shirt and trousers are removable; one tested layered clothing item follows shoulders/hips while animated.
- [ ] Hair/helmet, weapon/gear are separate removable rigid accessories.
- [ ] Character Appearance UI previews without committing until Apply; Cancel restores correct look.
- [ ] Level/class/stats/equipment ownership unchanged on skin/body change.
- [ ] Save/rejoin preserves entire appearance deterministically.

## Gate 2 — Race expansion and wardrobe QA

- [ ] Human, Elf, Orc, Dwarf visually distinct but use coherent Guildborne art style.
- [ ] Elf ears removable; Orc tusks removable; Dwarf beard removable.
- [ ] Wizard = Human outfit bundle, not race or special class.
- [ ] Body presets visually distinct; no gameplay advantage from visual size.
- [ ] Apparel fitting verified for every allowed body/preset in fit matrix; none labelled universal before evidence.
- [ ] Additional head/hair options visible and removable; no fused helmet/robe.
- [ ] NPC heroes and playable character share catalog/schema but retain separate owners.

## Motion & visual proof (required)

Actual Studio MCP run, inspect Output and screenshot:
- [ ] Idle, walk, run, jump, climb, fall, dodge, cast/fireball, shield raise, priest heal, sword swing, weapon draw, respawn.
- [ ] Full rig stress test: elbows bent 90°, arms raised, knees bent, seated, hip turn, capes with movement.
- [ ] No giant gaps at neck, wrists, waist, ankles; no obvious garment clipping in normal gameplay.
- [ ] Five heroes follow and teleport; doors/stairs, dwarf and orc camera and navigation tested.
- [ ] Two clients isolate looks/inventory; four clients + five heroes each when practical.
- [ ] PC and simulated mobile layouts; physical Android/iOS explicitly pending unless tested.
- [ ] Low-quality graphics/performance observation documented; true production capacity not claimed from Studio heartbeat alone.

## Security/progression/economy proof

- [ ] Forged ID and arbitrary external asset ID rejected.
- [ ] Unsupported outfit/race pairing and non-owned cosmetics rejected.
- [ ] Remote spam rate-limited; disconnect during Apply resumes known valid state.
- [ ] Appearance changes do not grant Gold, XP, SP, AP, inventory or market entitlements.
- [ ] Class unlock at 10/35/70, Hall level-cap and hero level rules unchanged.
- [ ] Market Phase 4.5 disabled / release gates unchanged.
- [ ] Existing tests and migrations all pass.

## Delivery reporting

List which parts are `PLANNED`, `EXPORTED`, `IMPORTED`, `TESTED`, `ACCEPTED`. Link actual files, Roblox Studio objects/IDs, screenshot names, and tests. If missing Blender or Studio functionality, label blocker and remain honest. No publishing or spending money without new approval.
