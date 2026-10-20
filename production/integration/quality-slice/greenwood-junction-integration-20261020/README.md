# Greenwood junction integration

Source base: `612bf11`. This integration uses the reviewed `buildGreenwoodEastJunction()` handle only when the trusted server walking policy has `FullConnectedWorld == true`. Default construction without a walking policy remains unchanged; ordinary two-route walking does not build the junction or the third road.

WorldService clones the Greenwood–Ironveil route descriptor and replaces only its readiness callback. Identity, zones, geometry, volumes, entries, recovery points and destroy callback retain their original references. Admission requires both the original corridor readiness and the original junction being within the world and ready. This predicate is checked before registration and later by the existing TravelService readiness path. No route bounds, release gate, transit, rewards or hero ownership logic changes.

All builders remain within the existing protected startup block. Any builder/readiness failure destroys the quality handle and throws before walking is registered. At runtime, missing, damaged or destroyed junction support makes Greenwood–Ironveil unavailable; existing TravelService handles unavailable routes. Exceptions are rejected by actual `TravelRules.walkingCall`. Other routes retain their own independent readiness. The integration introduces no new teardown operation; deliberate world teardown must still stop traversal before destroying geometry.

## Local checks

Run `python -B production/integration/quality-slice/greenwood-junction-integration-20261020/check.py` under the integration lease. It writes its extracted harness, exact raw streams and a source/hash receipt into this directory. The harness contains the current complete walking initializer, the actual TravelService `routeReady` function, and requires the real TravelRules module. Only geometry/build callbacks are mocked.

Observed: **120 assertions across 21 scenarios passed**, covering no walking/default, exact opt-in versus false/string/number, unchanged two-route mode, complete three-route mode, constructor failures, initial route/junction false readiness, wrong parent, exceptions, partial cleanup, late false/truthy/throwing readiness, junction removal, restored readiness, and quality destruction. The cloned descriptor does not mutate the original route. WorldService compiled successfully with `luau-compile --null`.

`attempt-01-fixture-id` retains the first failed harness and raw streams: its first-road mock used `city_greenwood` instead of the real `city_greenwood_west`, so the actual TravelRules correctly rejected that unrelated route. The fixture identity was corrected; no runtime logic was relaxed. Its nested receipt refers to the original run paths as recorded, with retained file bytes beside it.

Full game baseline and independent review are controller gates. Native ground rays, direct arrival-to-road traversal in both directions with five followers, settling, engine pathfinding, screenshots, physical-device performance and human art approval remain pending for a new candidate. Earlier R5 evidence used the old geometry and cannot certify this junction. No Studio mutation, publication or paid action was performed by this integration worker.

## Coordination incident

The WorldService source edit and initial checker creation followed successful checks of coordinator lease `bc68431dd62849128ea4e1411f1e2d70`. A later batched tool call returned `Missing, expired or stale lease`, but the already-composed batch continued before its result was inspected. It updated only this directory's README/checker dependency receipt and regenerated the harness/raw streams. These writes occurred without a valid lease; they are not retroactively authorized. The worker immediately reported the gap and stopped writing. The controller confirmed all writers/native sessions were stopped, explicitly released the old token, and claimed replacement `5232b64f16df4af6a0e0268435cc08a5`. Subsequent writes check that lease in a separate completed call and inspect success first.

The controller then explicitly expanded ownership to the existing `production/integration/quality-slice/check_walking_initializer.py` mock. Its existing assertions remain unchanged; a separate junction-handle mock now supports the full-connected initializer without counting approach support as a fourth route. Fresh output from that existing checker is retained separately under `prior-checker-run-01`, rather than silently superseding it or overwriting earlier failure evidence.
