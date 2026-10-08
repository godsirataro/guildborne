# Guild island visits — local implementation, 2026-10-03

Private, Friends and Public access is saved with the existing Schema7 land state. Older Schema7 records without accessMode default to Private. Policy changes use the normal lease/revision/save path and return existing visitors home only after the committed view updates the world. Paid products remain disabled.

Both central-city and guild portals offer an R / gamepad Y island directory alongside the existing E travel action. The directory lists ready owners in the current server, hides other players' private islands and searches names/user IDs. Friends-only entries check friendship on entry; listing does not imply permission. Every bridge also has a visit prompt. City portal identity uses TravelDestination, because road signs share the visible portal name.

Visits require a ready visitor profile, living character, no combat/tower, proximity to a portal or bridge, a safe landing, permission and capacity. The server caps friendship lookups at four and checks readiness and policy again after the yielding lookup. Single-use tickets expire after five seconds and recheck current policy, capacity and landing. Eight visitors per island is a provisional capacity. The server corrects unapproved physical entry every half second.

The owner sees only their own guest roster and can remove a visitor. KickIslandVisitor accepts a visitor ID; the owner is always the authenticated sender. Removal returns the guest home and blocks reentry to that island for the owner's current server session. Other islands remain accessible. Owner departure, unavailable profile or a policy change revokes visits. Arrival uses the normal travel lifecycle, updates CurrentZone to Guild, resets companion movement and keeps respawn on the visitor's own island.

## Evidence

- 372 domain tests pass, including policy/ticket/capacity/race/replay checks, access-setting persistence failures and owner-spoofing protocol rejection. The 5,000-order soak reported zero invariant violations.
- The disposable Studio visit fixture passes 25 checks with one actual offline character and one synthetic owner. This includes private listing, roster isolation/copying, owner-only removal, home return, failed friendship lookup, policy/readiness changes during lookup and physical intrusion correction. Zero real friendship calls and zero profile writes.
- Actual pointer input in the offline city directory returned to the own-island spawn through TravelZone; console confirmed revision1. Regression was caused by duplicate visible names on road signs and the real portal.
- Actual E travel to City followed by an own-island bridge visit set CurrentZone to Guild and PersonalGuildSpawn correctly. Debug repositioning was used between portals, so this is not a walking/navigation acceptance test.
- Actual directory empty roster text fits the compact viewport. Access-cycle Private → Friends → Public → Private was previously exercised through real UI and saved three revisions.

## Still required for release

Two or more real clients, real friendship API acceptance, imported assets, physical touch/controller use, reconnect/lease-loss behavior with live persistence, full performance and human UAT remain pending. Cross-server discovery/routing is not implemented; the present directory is explicitly current-server only. Owner roster refresh is manual through Refresh islands. No offline-owner visits, co-building, purchases, cloud uploads or public release have been enabled. Other launch cities still need their portal integration.
