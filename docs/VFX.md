# Guildborne VFX — P0 director pass

> Final Phase 2 polish and latest test scope: [closure](PHASE2_CLOSURE.md).

Updated 2026-09-29. Implemented and tested in Guildborne Staging through Studio MCP; not published. User reference images guide color and silhouette, not imported sprite sheets. This is a native geometry/particle pass, not a visual match to the painted references.

## Effects and stable IDs

| ID | Direction and layers |
|---|---|
| Knight.Taunt | Muted steel blue shield, gold emblem, expanding ground pulse |
| Warrior.PowerStrike | Physical orange slash, sweeping arc, weapon trail and impact |
| Archer.PiercingShot | Green directional bolt, projectile trail and impact |
| Mage.Fireball | Amber projectile, burst flame, comet trail, impact fire, brown smoke and debris |
| Priest.Heal | Warm gold/ivory rings and rising healing light; compact source-to-target beam |
| Enemy.Telegraph | Reserved ground circle and cross; retained at Low quality |

The existing ActionPose procedural anticipation/release/recovery remains in use. This pass adds no uploaded animation or sound asset. The renderer responds to server-confirmed combat attributes; it never decides damage, healing, cooldowns or rewards.

## Implementation

- [VFXConfig](../src/shared/Config/VFXConfig.luau): stable IDs, class palettes, built-in texture paths, distances and budgets.
- [SkillEffects](../src/client/Controllers/SkillEffects.luau): client-only Parts, burst ParticleEmitters, Beams, Trails and Attachments. Colored geometry uses SmoothPlastic; bright cores use limited Neon.
- [Native probe](../tests/studio_vfx_director_probe.luau): QA-only, excluded from the runtime mapping.

All effect Parts are anchored, non-collidable, non-touchable, non-queryable and shadowless. Emitters use Rate=0 and Emit bursts. Tween/Debris and bounded delayed cleanup remove the parent and its children; counters release after the lifetime. No new permanent frame callback is used. Built-in fire_main.dds, smoke_main.dds and sparkles_main.dds were verified in the installed Roblox content directory; no paid VFX pack is required.

## Quality and limits

Client workspace attribute GuildborneVFXQuality accepts Auto, High or Low. Full detail is admitted within 55 studs, compact source/target feedback extends to 100, and ordinary effects beyond that are culled. Critical telegraphs extend to 150 studs. High does not bypass the touch budget.

Each renderer has 48 desktop or 30 touch detail Parts, 16 compact primary Parts and 16 reserved telegraph Parts. One full skill phrase is admitted per 0.75 seconds; simultaneous teammates use compact feedback. Repeated same-caster requests coalesce within 0.1 seconds. The current eight-Part telegraph reserve supports two concurrent telegraphs; overflow beyond this is bounded and is not a large-raid guarantee. These are per-renderer limits, not a global multiplayer performance guarantee.

## Native verification

[Recorded MCP results](evidence/vfx-director-results.json) include desktop, iPhone 17 Pro landscape emulation (750 x 362 viewport), server battle counters and console output.

| Peak observed Parts | Desktop | Touch |
|---|---:|---:|
| Warrior solo detail | 40 | 30 |
| Archer solo detail | 15 | 11 |
| Mage solo detail | 27 | 23 |
| Knight solo detail | 18 | 16 |
| Priest solo detail | 30 | 22 |
| Five simultaneous Low primary | 12 | 12 |
| Five simultaneous High detail + primary | 40 + 10 | 30 + 10 |
| Saturation detail + primary + telegraph | 27 + 16 + 8 | 23 + 16 + 8 |

Final probes exercised all five IDs, repeated and simultaneous casting, Low, far compact, distance culling and a sixteen-caster saturation fixture. Telegraph remained visible during saturation. All probes returned cleaned=true with no residual effect Parts or cast Trails after the cleanup window. Mage peaked at four burst emitters and two trails. Counts are observations, not FPS or MicroProfiler measurements.

A separate genuine five-hero camp battle used normal recruitment/party commands and normal server AI. Its 45-second observation recorded ability counts Warrior 3, Archer 7, Knight 4, Priest 7 and Mage 6; Priest healed 96. This battle preceded the last cosmetic flame/smoke refinement; the final client probes above include that refinement. Final-session console also records seven server combat rewards and no script errors. QA used a temporary Memory profile with 500 Gold and assisted player positioning, never live saved player data. Normal Studio DataStore configuration and bootstrap were restored after Stop.

## Visual evidence and remaining work

[Mobile Fireball release screenshot](evidence/vfx-director-mobile-fire.jpg) shows the orange projectile and procedural casting pose in the native viewport. The capture is a release frame, not proof of the complete impact sequence. The projectile still appears simpler than the painted reference; timing captures and isolated visual review of every phrase remain needed before calling this production art quality.

Physical mobile hardware, multiplayer load, MicroProfiler/GPU measurements and published-client verification are not covered. No claim of zero memory growth is made from short cleanup probes. Custom painted flipbooks/meshes, stronger authored silhouettes and sound remain art follow-up work. P1 generic hits/goblin polish and P2 downed/recovery/target/combat-start presentation are not newly delivered by this P0 pass.
