# Animation and effects production map

The generated VFX sheet is a five-row, four-stage storyboard on an opaque background. Do not assign it to a ParticleEmitter or play the whole sheet as one animation. No new uploaded animation or sound ID was created.

Existing runtime: ActionPose produces original R6/R15 cosmetic joint transforms. Windup is 0–0.10s; release interpolation 0.10–0.24s; recovery starts at 0.26s and ends at 0.62s. Root visuals do not move authoritative positions. HeroAnimator and PlayerCombatController apply the poses; SkillEffects renders bounded local geometry/trails and built-in particles from confirmed actions.

Storyboard mapping: Knight taunt shield/ring; Warrior power-strike crescent; Archer piercing-arrow line; Mage fireball charge/travel/impact; Priest healing bloom. Branch/master art icon candidates are mapped in assets/uat01/manifest.json. The atlas covers one branch family per class; other existing branch arts still need their own art or an explicitly shared family icon.

Preserve source/target positions, actual radius/range and server result timing. Low quality must retain enemy telegraphs. The existing budgets are 48 desktop / 30 touch detail parts, 16 primary and 16 telegraph parts per renderer; details cull at configured distances. Those are implementation limits, not measured device performance or raid-capacity claims.

Remaining work: production crops/static particle textures, individual all-ability timing captures, sound palette, interrupted-cast visual review, simultaneous five-companion readability, target mobile profiling. Studio continues to report an existing inaccessible animation ID 114302219876492; ownership and fallback remain unresolved.
