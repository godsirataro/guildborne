# Friendly Orc townspeople — 2026-10-03

Four original friendly NPCs are integrated into the offline city: Borga (innkeeper), Mogra (herbalist), Rukk (apprentice smith), Ghar (veteran mercenary). Race is Orc; no combat class or recruitment grant is implied. Each has a server-distance-checked Talk prompt, English/Thai conversation, native idle/greeting motion and distinct profession props.

## Assets

- [Generated concept sheet](../../assets/uat01/friendly-orcs/concept.png), [imagegen prompt](../../assets/uat01/friendly-orcs/concept-prompt.txt).
- [Actual geometric model preview](../../assets/uat01/friendly-orcs/preview.png). These editable block models are simpler than the concept sheet; visual polish remains.
- [Kit manifest](../../assets/uat01/friendly-orcs/kit.json): 4 actors, 158 geometric parts, 1,896 triangles, 16 bones each, 16 total Idle/Walk/Greet/Work clips.
- Blender sources, rest FBX/GLB and animation FBX files are in the same asset directory. All 24 exports passed the existing round-trip rig verifier.

## Observed runtime evidence

Owned Studio offline memory place, 2026-10-03: all 4 models spawned, 15 Motor6D joints and 1 Talk prompt each; native parts include 16 invisible bone carriers. Actual E input opened Borga, Mogra, Rukk and Ghar conversations. Actual pointer input closed the conversation after scrolling it into view at the small 750×362 viewport. Console showed normal memory session initialization without script errors during this check.

Build/analyze/compile/repository verification passed at155 runtime Luau files after prompt-name/reduced-idle refinements and land integration. Complete domain suite:365 tests passed;5,000-order conservation soak passed. Actual title-screen language switching followed by E interaction displayed Borga's Thai dialogue with both labels reporting TextFits=true at750×362. These domain results are not multiplayer or final visual acceptance of these NPCs.

Remaining: all-NPC Thai layout and controller/mobile physical acceptance; final silhouette/hair/face polish; imported mesh/animation ownership and uploaded IDs; further occupation-specific services and story quests. Work animations exist as exported clips but are not yet used by live NPC behavior. No marketplace products or live assets were published.

## Profession quests and portraits

Four optional NPC tasks are live: Borga timber delivery, Mogra gathering lesson, Rukk ingot delivery after forge foundation, and Ghar Goblin protection after the city introduction. Total runtime quest count is now19Journal+3timed=22. NPC accept/claim commands require proximity, including a fail-closed response if a configured NPC station is missing. City waypoint targets include all four Orcs.

Borga actual offline UI journey: accepted → gathered4Timber → claim from own guild rejected with VisitStation → claim near Borga consumed4Timber and granted8Gold once → Claimed4/4, claim button removed. Debug positioning was used between stations; this is not a traversal playtest. Details: [UI evidence](validation-friendly-orc-ui.json).

Dialogue portraits reuse sanitized static ActorPortrait models (no scripts, prompts or motors). At750×362, Borga rendered36visible parts in a64×64portrait fully within the scroll clip after a compact-layout fix. Final mesh polish and all-NPC/device visual acceptance remain.
