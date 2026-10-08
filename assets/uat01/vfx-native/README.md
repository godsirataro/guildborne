# Original shockwave flipbook

`guildborne-shockwave-4x4-v1.png` is a 2048×2048 transparent RGBA atlas rendered directly from original Blender geometry. Sixteen 512×512 frames read left-to-right, top-to-bottom. The editable source is `Guildborne_Shockwave_Flipbook.blend`; rebuild with `tools/blender_vfx_flipbook.py` and inspect pixels with `tools/audit_vfx_flipbook.py`.

`layout.json` defines exact cells and authoring values. `alpha-report.json` records the unchanged PNG hash and each frame's alpha bounds. All 16 cells are nonempty and have at least40 pixels of fully transparent padding; the last frame has lower opacity than the first. This deterministic grid is separate from the AI-generated single-sprite candidates.

Suggested imported-emitter setup: `FlipbookLayout=Grid4x4`, `FlipbookMode=OneShot`, `FlipbookStartRandom=false`, `FlipbookBlendFrames=true`, `Lifetime=.45`, `Rate=0`, `Speed=0`, with one explicit `Emit(1)` per local impact. Start at Size4, LightEmission0.7 and LightInfluence0, then adjust under actual world lighting. OneShot spreads the animation over particle lifetime; its timing does not use FlipbookFramerate. See the official [ParticleEmitter reference](https://create.roblox.com/docs/reference/engine/classes/ParticleEmitter) and [particle guide](https://create.roblox.com/docs/effects/particle-emitters).

Use it as cosmetic impact feedback. Server-owned geometry remains the warning/hit boundary. A billboard particle should not communicate a ground hazard's exact footprint. Roblox import, downsampling/compression, texture permissions and physical-device acceptance remain pending; no image was uploaded and no asset ID was invented. The game continues to use its existing native impact geometry.
