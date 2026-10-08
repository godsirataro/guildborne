# Travel system

`Shared.Config.City` defines public map geometry and two allowed travel keys: `City` (CentralCitySpawn, 0/5/-720) and `Guild` (PersonalGuildSpawn, own plot origin + 0/5/23). Alternate positions are 0/5/-750 and own origin + 0/5/14. Clients send the existing exact `TravelZone {zone=...}` intent, never a transform or another player's identity.

`WorldService` delegates admission and movement to `TravelService`. Admission checks live character, downed/combat/tower restrictions, distance within 16 studs of the origin portal, supported/unobstructed destination and a per-player two-second throttle. Existing network throttling and profile revision validation remain in force. Travel uses the existing committed settlement command and does not copy a profile, grant currency or change party ownership. Existing journal milestones retain their original semantics.

On accepted movement, the server pivots the character, clears velocity, updates the session-only zone and respawn location, and calls `HeroService.Travel`. Only selected Following heroes move; path generations and trail history reset. Each follower is grounded near its owner. City trail spacing is reduced to 2.5 studs. Existing path and stuck recovery remain in use. Heroes away on an existing timed quest/dispatch retain their existing away behavior.

Spawn candidates require a ground ray hit at the expected floor height and clearance for a 4 × 5 × 4 stud box. An obstructed primary uses the fallback; if both fail, admission returns a localized unavailable message. Respawn waits for the engine's initial character placement before applying the remembered zone. Falling below Y=-15 attempts the same recovery every half second. If both recovery candidates have been destroyed or obstructed, recovery cannot invent a safe floor: fixing the geometry is required.

Zone memory and throttle buckets are removed on disconnect. Rejoining starts at the player's personal guild; city respawn is not a permanent save change. Existing checkpoint/lease handling preserves committed progression during disconnect. A save-pending command does not move the player; after save recovery, request travel again at the portal. No external teleport service, place migration or new persistent schema is introduced.

New destinations must extend server validation, supported floor/clearance rules, localized labels and tests. Future TowerGate is intentionally not an accepted destination. Do not allow arbitrary client coordinates or use a client-provided owner to resolve a guild plot.
