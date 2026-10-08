# Guildborne original weapon kit

Five original Hall3 weapon silhouettes: Watchblade, Oathblade, Yew Longbow, Tide Staff and Dawn Crozier. The shared `kit.json` authors54 parts in studs, Y-up, grip-centered. Native `WeaponVisuals.luau` uses the same geometry immediately; inventory IDs and stats are unchanged.

Blender exports total632 triangles across five meshes. `Guildborne_Weapon_Kit.blend` includes a lit display scene; each individual FBX/GLB contains only its weapon mesh, with the hand grip at origin. Rebuild using `tools/build_weapon_kit.py`, then Blender `tools/blender_weapon_kit.py`. Run `tools/verify_weapon_kit.py` in Blender with `--python-exit-code 1` to verify all10exports for bounds, triangles, materials and grip origin. Results and hashes are in `roundtrip-report.json`.

Native runtime equips at scale0.65 and welds each noncolliding/massless part to the right arm/hand. `tests/studio_weapon_grip_probe.luau` passed22equip cases across11weapon IDs and both R6/R15 hand conventions,170welded parts, rotated-hand alignment, replacement and unequip cleanup. Actor portraits now invalidate their cached snapshot when WeaponId changes.

FBX/GLB Roblox mesh import and physical-avatar clipping review remain pending. No mesh IDs were uploaded or invented. Native geometry is already installed in the local Staging source; this does not publish the place.

![Original weapon preview](preview.png)
