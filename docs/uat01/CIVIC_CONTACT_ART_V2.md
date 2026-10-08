> Updated checkpoint: all six local NPC activity studies and twelve native city service buildings now exist; see CIVIC_CONTACT_SIX.md and CIVIC_SERVICE_ARCHITECTURE.md. Historical pending counts below describe their original checkpoint. Final likeness, main-world NPC replacement and human approval remain pending.

# Civic contact art: Borin v2 and Vaela v1 — 2026-10-06

Two local art slices now have editable16bone sources, sampled motion, GLB and FBX candidates. They remain reference interpretations with stylized faces and rigid skinning, pending final likeness, cloth/hand polish, Roblox import/binding and human acceptance.

## Borin

[Blender](../../assets/uat01/borin-forge-v2/Guildborne_Borin_Forge.blend), [GLB](../../assets/uat01/borin-forge-v2/Borin_Forge.glb), [FBX](../../assets/uat01/borin-forge-v2/Borin_Forge.fbx), [motion GIF](../../assets/uat01/borin-forge-v2/motion.gif).

Updated materials use explicit sRGB conversion. Swept hair locks, sideburns and a smaller nose replace the first study's broad shapes. The two-second strike loop now holds its wind-up, accelerates into contact, rebounds and recovers with a20degree wrist arc. The six-second source repeats three contacts at1/3/5seconds and reuses the original forge cue audio in borin-forge-v1. The silent GIF renders one two-second cycle at15fps.

Hand orientation retains bind-pose roll: direction-only tracking became singular at the vertical hand and flipped the hammer behind the character. The corrected exported rig passes all three actual mesh-surface contacts, stable foot/root and loop seam checks in clean GLB and FBX reimports. Total asset geometry including station/effects:14304triangles in either format; LOD/device checks remain pending.

## Vaela

[Blender](../../assets/uat01/vaela-garden-v1/Guildborne_Vaela_Garden.blend), [GLB](../../assets/uat01/vaela-garden-v1/Vaela_Garden.glb), [FBX](../../assets/uat01/vaela-garden-v1/Vaela_Garden.fbx), [watering image](../../assets/uat01/vaela-garden-v1/watering.png).

Standing elf gardener interpretation: tapered ears, pale braided hair, green apron, seed pouch, gloves and a watering can. Both arms have matching segment lengths. The bench has an open-rim pot with exposed soil and a sapling. During frames60–120 at30fps the droplet chain follows the posed spout and ends inside the soil surface; it disappears outside that interval. This is a cosmetic water study, not a fluid simulation.

Clean GLB/FBX checks sample seven active water poses, four inactive poses, symmetric arm lengths, fixed support hand/root/feet, loop seam and skin weights. Max measured spout separation is below0.000002study units; soil endpoint error is zero in sampled frames. Geometry:9728triangles in either format including station/effects. Original water audio has48kHz mono16bit single-pour and six-second review files; waveform timing/peak checks pass, listening remains pending.

FBX exports disable animation simplification to preserve independently baked hand and water curves. Reimport checks use authored30fps. Counts now exclude the80triangle Icosphere created by Blender's GLB importer as an armature control shape; earlier counts included that editor helper. These are not approved device budgets.

## Binding and scope

These files do not replace the current in-game civic rigs yet. Static station geometry and skeletal character animation need separate Roblox import/binding; object-animated cosmetic particles need runtime equivalents. The existing672gameplay tests and eight game builds were not rerun for these standalone art changes. Other four reference-faithful character slices, full city architecture, map polish, professional acting and live audio/platform acceptance remain.
