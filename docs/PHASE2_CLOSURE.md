# Phase 2 closure

2026-09-29 — closed per the user's selected scope: finish the animation/VFX polish item and update progression. This is an implementation milestone, not a claim of release acceptance or published deployment. Earlier documents below their current-decision banners remain historical.

## Current progression

| Rule | Value |
|---|---|
| Class 2 eligibility | Level 30; existing quest and branch requirements remain |
| Class 3 eligibility | Level 70; existing tower/path requirements remain |
| Class 4 | Not available |
| Character and hero maximum | Level 100 |
| Guild Hall maximum | Level 20 |
| Cap per Hall level | Hall level x 5 |

Hall 6 opens the level range for Class 2, Hall 14 for Class 3, Hall 20 for level 100. Advancement remains a player choice, not an automatic class switch. Special Tier 3 paths also require level 70 plus their existing milestones. Hall upgrade costs extend the existing resource curve through 19 -> 20. Quarters and the roster retain their existing 50-hero limit; raising the actor level cap does not double housing.

Previously earned low-level Class 2/3 builds remain valid on load. The schema preserves historical minimums 3/6 for saved builds; all new AdvanceClass commands enforce 30/70. No player is silently demoted, granted XP or assigned another path. No profile field migration is needed.

## Final polish

ActionPose adds a brief release recoil, stronger casting torso motion and a deeper Warrior wind-up without moving the server-owned root. Compact Warrior effects now use a directional slash rather than a generic bolt. Archer compact shots are longer and clearer; Mage compact shots use a larger spherical silhouette. Full Fireball has a larger brighter amber core, Knight shield has stronger opacity, and Priest rising light is thicker. All retain the prior bounded native VFX architecture, client-only presentation and five stable class IDs described in [VFX](VFX.md).

## Verification and evidence

- 123 automated tests passed, including new 29/30 and 69/70 promotion boundaries, no further promotion from Class 3, level 100/101 and Hall 20/21 validation. Rojo build, strict analysis and repository checks passed.
- Final definitions were read and asserted in the connected Staging server through MCP.
- [Final native VFX probes](evidence/phase2-close-vfx.json) passed desktop and iPhone 17 Pro landscape emulation: five Low effects peak at 12 primary Parts; full-detail peaks remain 40 desktop / 30 touch; telegraph reserve survives saturation; cleanup passes.
- Studio was stopped, temporary preview rigs removed, default device restored and normal persistence source restored. Nothing published.

This pass does not claim full visual parity with the painted references. New screenshot attempts returned an empty viewport and are not visual evidence; use the earlier [VFX evidence](VFX.md) only for its explicitly documented version. Native object/cleanup probes pass, but they do not substitute for a full visual review. Two-player acceptance, physical-mobile verification, sustained profiling and the complete live rejoin walkthrough remain release checks, deferred from this user-selected closure scope.

## Phase 3 — large shared city hub

The city should be the social center: a broad arrival plaza and landmark, guild/quest district, tavern recruitment district, crafting/market district, tower gate and a clearly signed Guild Zone portal. Use wide main routes, short connections and visible destination landmarks so a larger map remains navigable.

Guild Zone continues to show only islands owned by players in the same server, connected by walkways; visitors cannot edit another owner's base. A large player population across servers does not mean all players are visible in one scene. City server population targets must be chosen after multiplayer/mobile profiling; no unsupported promise of hundreds of simultaneous visible players is made. Cross-server travel and social discovery are future implementation decisions.

Next work: build a larger city blockout, route all existing NPC/portal interactions into its districts, then test navigation and streaming with multiple players before detailed decoration. The expanded city is recorded here as planned, not built by this Phase 2 closure.
