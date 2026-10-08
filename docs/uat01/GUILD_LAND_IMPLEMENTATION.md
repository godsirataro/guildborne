# Guild land implementation — 2026-10-03

User resumed implementation and revoked the previous15%quota stop. All agreed major systems remain first-release scope. This checkpoint adds a foundation, not a completed island release.

## Implemented

- Schema7 adds only empty `guildLand` state to validv6profiles. Legacy input is copied, not mutated; collisions fail instead of replacing data. Existing earlier migration fixtures now explicitly remove the newer field when simulating old saves.
- Separate quest milestone, verified purchase entitlement, delivered materials and opened state. A trusted already-paid entitlement can be retained while quest eligibility is temporarily unavailable. Client commands cannot grant payment ownership.
- Unlock/material/open commands use existing server revision, replay, lease, audit and uncertain-save recovery. Contributions debit only required materials and remove zero stacks; replay/rejoin tests verify no duplicate debit. Spatial authorization requires the owner's safe guild area.
- Three provisional zone catalogs use existing expedition milestones: Grove, Quarry, Summit. Names, quantities and final dedicated quest chains are balancing candidates. All product IDs remain0. There is no real purchase verifier or sale activation yet.
- Server projection hides payment references. Base → Guild land shows requirements, current inventory, state and valid actions. EN/TH copy is present. Actual offline Studio UI opened all three locked zone cards successfully from a fresh profile.
- `IslandPlacement` bounds the grid at128×128 and validates unlocked footprints, rotation, overlap, reserved access and four-neighbor connectivity. The `LandBuildingPlacement` adapter now uses a2-stud grid with1-cell clearance for expanded land, retaining legacy8-stud saved building coordinates and existing starter placements. It checks the new-area route to the core access strip, not the complete city-to-island route.
- Opened flags now create three64×48-stud ground regions and short bridges. Locked regions have non-solid boundary markers only. Island spacing is280studs to preserve at least78studs between neighboring full bounds. These are provisional prototype dimensions.
- Builder cycles only between starter land and projected Buildable plots. Server placement and schema validation use the same adapter; existing building identity/level/material balances survive moving between old and new land. Hall relocation and fine manual positioning are not implemented yet.

## Evidence and limits

372 tests passed in the complete suite, including new land placement, projection agreement, rejoin, replay and uncertain-save movement cases. The5,000-order soak reported zero invariant violations. Strict analysis, compilation and repository checks passed at159 runtime files. Offline Studio: localPlaceId0/GameId0, memory-only, empty cloud allowlist.114 geometry/path checks passed in a disposable fixture, including radius2/height5 no-jump paths to three building entrances. Actual pointer input cycled to Grove, rotated and emitted correct PlaceBuilding coordinates in a Thai UI fixture; that fixture captured the command without making a purchase or writing a paid entitlement. Borga's Thai dialogue also fit the small viewport. Owned Play stopped. Ordinary Staging was not opened or migrated.

Hall relocation, fine placement, decoration storage, theme application/ownership, payment verification, cross-server discovery and final multiplayer/mobile/controller acceptance remain required work. Expanded terrain/building placement is a local implementation, not a completed paid-land customer journey. Paid IDs must stay disabled until permissions, fulfillment and full acceptance are complete.

Roblox payment references researched2026-10-03: [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService), [Developer products](https://create.roblox.com/docs/production/monetization/developer-products). An in-game quest gate controls our purchase offer; external/platform purchase paths must not cause paid ownership to be discarded. Payment event notifications alone are not client authority to grant land.
