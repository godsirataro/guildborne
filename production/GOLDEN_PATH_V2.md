# Human and HUD integration acceptance route

This is a runnable work specification, not completed art. Start from the actual
`tools/blender_character_kit.py`, `assets/uat01/character-kit`, existing hero rigs,
`src/client/UI` and class/effect services; reuse approved work before replacing it.

## Author and inspect

1. Generate the normalized contract with character_contract.py. Choose Human
   Standard and Heavy. Verify15 core mesh names and distinct selectable objects.
2. Create/fit models in Blender. Body modesty remains; tunic/trousers/hair are
   removable objects. Do not replace legs with a robe cone or fuse weapon to hand.
3. Run blender_job.py on the saved source. Inspect shoulder/elbow/hip/knee/ankle,
   UVs, actual bone weights and rig axes manually; geometry PASS does not prove fit.
4. Export using the existing approved profile; retain editable sources. Do not
   claim shape keys automatically become Roblox runtime body sliders.
5. Import in the explicitly identified Studio test place only when its asset
   permissions allow it. Keep real IDs null until returned by the platform.

## Bind and play

Reuse actor IDs and existing appearance/equipment state; map cosmetic race/body
separately from legacy combat ancestry. Verify the head alias, ownership, slots,
fit family, modesty and idempotent accessory rebuild. A larger visual body must
not receive larger melee range, different rewards or a changed combat proxy.

Run idle/walk/run/jump, attacks and one class skill on Standard and Heavy. Show
front/side/back plus bent-joint closeups; remove and re-equip garments repeatedly.
Verify weapon grip, foot contact, attachments and no duplicated accessory objects.

Bind player HP, five companion portraits, selected actor, cooldown and authoritative
hit/heal events. Test EN/TH, desktop and phone landscape/portrait; keep touch controls
clear. Capture the whole action, not only a bright impact screenshot. Check no
subscriptions/tweens/effects survive respawn or window destruction.

## Evidence matrix

| Evidence | Must be observed | Current state in this continuation |
| --- | --- | --- |
| Source and catalog | Hashes, canonical IDs,15 parts, no claimed import | Tool/contract checks only |
| Blender | Actual version, source, geometry, deform/fit, exports | PENDING_EXTERNAL_TOOL |
| Studio | Studio ID, place/build, imports, animation/equipment, Output | PENDING_EXTERNAL_TOOL |
| Gameplay | New route, legacy save, respawn/rejoin, per-actor isolation | New regression in CI; visual route pending |
| Multiplayer |2/4 clients,20 followers and ownership | PENDING_NEW_ACCEPTANCE |
| Hardware | Actual device input/performance | PENDING |
| Art approval | Readability, identity, natural motion | HUMAN_REVIEW_PENDING |

Do not mark any pending row PASS using the existing historic reports or a fixture
subprocess. Expand to the other11 body presets only after the two-human route passes.
