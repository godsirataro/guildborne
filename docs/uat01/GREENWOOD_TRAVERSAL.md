# Greenwood traversal checkpoint — 2026-10-03

Greenwood now connects to the Central City through a server-validated portal on the avenue near the north gate. A return portal leads to the existing city arrival point. This is an exploration connection to the authored blockout; region combat, encounter rewards and story integration are not enabled yet.

The region uses the existing 220 × 200-stud island and arrival dock at world origin (0, 0, 1400). Player arrival is (0, 7, 1505), with a separate fallback at (0, 7, 1495). Server raycast and clearance checks choose a safe landing; both obstructed candidates reject travel. The same alive/downed/combat/tower/distance and rate gates apply. Clients still submit only an allowlisted destination, never coordinates or another player's identity.

Respawn stays in Greenwood during the current session. Falling below the world or leaving the region bounds returns to its arrival point. Returning to town or visiting an island changes respawn normally. Region presence is ephemeral; it does not introduce a new saved location or migrate profiles. Companion world-following now recognizes Greenwood, and actual UI recruitment/party-save followed by Greenwood entry confirmed Rowan following about5studs behind. Five-companion and multiplayer acceptance remain.

## Evidence

- `validation-greenwood-travel-domain.txt`: 415 domain tests, including unchanged profile/party/resources on regional travel, bounded coordinates and rejected unimplemented destinations.
- `studio_greenwood_travel_probe.luau`: 147 native checks, four no-jump paths from arrival to encounter markers, return portal, supported/clear landing points. Read-only against the owned offline world.
- Actual offline UI: Continue, approach city portal (debug positioning), E enters Greenwood at revision1; E returns to City at revision2. Entry again at revision3, death/respawn retained Greenwood; fall recovery returned to its arrival without a progression write.
- With a temporary owned test obstacle over the primary landing, actual E travel used the fallback at Z1495. With both landings blocked, the player stayed in City and no additional revision was saved. All temporary obstacles were removed.
- Build, strict analysis, compilation, repository and memory-only place checks passed at172 runtime modules.

The screenshot inspected in Studio shows the native woodland blockout and Greenwood safe-zone label. It is not final environment art or a release-ready region. Remaining work: full five-companion traversal acceptance, real multiplayer and devices, regional map guidance, encounter/combat/reward/quest integration, density/art polish and checkpoints for the other regions.

Follow-up: actual UI selected Warrior, recruited free Rowan, added/saved party, then entered Greenwood. Rowan was in Follow state about5studs from the player. A blocked-landing failure now displays a six-second world action notice while the management panel is closed; the temporary blocker was removed.


## Regional gathering

Greenwood has shared visible timber/herb nodes with per-profile12-second cooldowns and2materials per successful gather. Server checks alive/downed state, current region and12-stud range; the existing100/200 warehouse ceilings still apply. Regional discovery uses separate IDs and cannot satisfy the four original resource discoveries for secret-class gates.

Actual offline E-hold gathered2Timber at revision2 and rejected an immediate repeat with the world-visible regrowth message. Herb gathering also granted2Herb at revision3. The geometry/authority fixture passed12checks for both nodes, wrong region/distance, downed/dead rejection, with no real profile writes. Full domain suite422PASS verifies cooldown, identity, rejoin, capacity and uncertainty atomicity. Nodes remain available to each player's independent collection state; multi-client/device acceptance is pending.


## Actual regional quest loop

Mogra's existing herb lesson now accepts both home and Greenwood herbs. Regional node IDs remain separate for cooldown/discovery while a server-authored quest event counts the matching resource type. Failed/cooldown/replayed requests do not advance progress. No new quest IDs or rewards were added.

Actual offline UI completed: Talk to Mogra → accept lesson (revision1) → city portal to Greenwood (revision2) → E-hold gather (revision3, Journal1/2) → regrow/gather (revision4, Journal2/2 ready) → return portal (revision5) → talk to Mogra and claim (revision6,8Gold). Debug positioning shortened travel between interactions; all quest, travel and gather commands used ordinary visible controls. Native12gather/147travel checks reran successfully against final sources. Full domain suite423PASS: validation-greenwood-quest-domain.txt.
