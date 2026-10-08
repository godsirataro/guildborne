# District guild portals — 2026-10-06

Central City now has guild-island access in the Guild, Market and Tower districts, in addition to the arrival gate. These are districts of the existing city, not six finished launch cities. Each portal also opens the existing island directory with its usual ownership/access checks.

The server remembers the last city guild portal used during this session. Returning from the guild lands beside that fixed stop. Clients cannot submit a stop or coordinates. Each landing is checked for ground and body clearance; obstructed district candidates fall back to normal City spawn candidates. If every candidate is blocked, travel is rejected without moving the character. Removing the player clears the remembered stop; reconnect defaults to the original City arrival. Combat/downed/tower restrictions and the two-second cooldown remain enforced. Earned Hall-upgrade guidance now points to the nearest city guild portal.

Native final-geometry evidence: four stops/eight landings/eight no-jump gate paths; twelve road corridors sampled at837points with no blockage. The first layout placed Guild/Market pillars at a junction; both gates were moved20studs into their district lanes before final verification.

Actual ordinary-input offline Memory round trips passed for Market(300,-1068), Guild(-300,-1068) and Tower(0,-1502), using normal-speed navigation and E prompts. No profile grants. An attempted obstruction-input test started before travel cooldown elapsed and is excluded. A separate native dummy-character fixture verifies all-landings-blocked rejection, default fallback, replacement of remembered stops and removal cleanup; this is not multiplayer or actual-player safety acceptance.

[Native evidence](validation-district-portals-native.json). Full633-domain regression and strict checks passed after later narrative presentation work. Real visitors/multiplayer, reconnect and physical devices remain release gates.
