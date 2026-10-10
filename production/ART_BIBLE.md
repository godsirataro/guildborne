# Guildborne visual and feel contract

Original stylized fantasy, not a reskin of a competitor. Natural feel comes from believable weight, timing, anatomy, contact and consistent response, not excessive polygons, effects or photorealism.

## Visual language

Navy/Obsidian backgrounds, restrained brass/gold frames, ivory text, burgundy fabric and subtle cyan arcane accents. Strong silhouettes and readable materials. Human, Elf, Orc and Dwarf share one art direction with multiple adult silhouettes and tintable skin; all jobs remain available to every race. Wizard is a Human visual bundle. Avoid a robe fused into legs or hair fused into head/body. Maintain non-exposing coverage when outfits are removed.

## Interface

Reuse semantic tokens and native Roblox components. Design title/menu, HUD, cards, inventory, skill tree, quest journal, stats, shop, exchange, map and guild screens as one family. No baked prices/counts/player names/localized text in raster art. A frame uses valid 9-slice metadata; an icon needs actual small-size review; an atlas needs alpha and padding. Do not copy the reference screenshot's exact layout or fake winner/discount feeds. Skill tree desktop graph needs a mobile list alternative.

## Motion and sound

Anticipation -> action -> impact -> recovery. Clear foot plants, weapon grips, weight transfer, role identity and transitions. Animation/VFX/SFX share semantic markers; authoritative gameplay is not controlled by particles or local animation callbacks. Do not freeze the world to make a local hit feel strong. Optional camera effects respect reduced motion and must never shake other players globally for ordinary attacks.

## VFX

Distinct tank/physical/ranged/magic/heal cues with shape as well as color. Telegraphs remain visible even in low quality. Five companions and multiple players must not bury the enemy beneath friendly effects. Bound bursts, trails, lights, text labels and pooled object lifetimes; verify instance/memory trends after repeated casts. Procedural starter textures are previews, not final illustrated skill artwork.

## World

Cities feel populated through purposeful landmarks, routes, small ambient scenes and narrative objects, not thousands of redundant props. Personal guild zone is home; central city is shared; adventure regions provide different encounters. Layout/travel/safe zones/ownership first, decoration second. Optimize visible cost and streaming, not just total part count.

## Initial project budgets, not platform limits

Core body: use the existing kit's agreed target and inspect actual geometry; review exceptions. UI icons 256/512 source depending importance, readable at gameplay size. Texture budget is per scene plus reuse, not an entitlement for every object to use 2K. Default primitive flipbook prototype uses a 4x4 grid with16 sequential frames and alpha. All actual Roblox import requirements must be checked against current official docs.

## Acceptance

Review in the gameplay camera, daylight/interior light, multiple outfits, meaningful animation frames, low-quality mode and phone layout. Export existence is not rig/fit acceptance. Human visual approval and actual device performance are separate from automated geometry/schema tests.
