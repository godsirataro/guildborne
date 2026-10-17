# Destination compass containment

Controller observed ordinary earned-client navigation in WoodlandDebt: destination distance changed with movement and text fit, but the separate compass at y216 was obscured by the combat action pad. This is an observed overlap, not acceptance of the full quest traversal.

The destination compass now uses three native Frame bars inside NextWaypoint. The existing camera-relative Waypoint.heading result is passed into the component unchanged; the legacy quest arrow is hidden. Destination hints never enable the world beacon. Text reserves a right lane only while the compass is visible; narrow hints use the localized two-line "Bearing only / Use paths" equivalent. Missing/nonfinite heading clears the compass.

Placement excludes CombatHudLayout's action pad, roster, health and capped-width orders plus the map button. It tries the previous location, a center lane and a below-roster lane. 796x674, 796x400 and 600x400 have card/compass space in local geometry checks. 500x600 uses the center lane.

320x280 has no free card-sized region and is explicitly unsupported for the navigation card in this layout. LayoutUnavailable=true hides that card to preserve controls; an authored world beacon can remain visible, but destination-only compass guidance is not available at this size. The map remains available. This state is NOT a functional-navigation pass or proof that all small displays are supported.

Local validation: baseline 897 regression cases with Rojo/analysis/compilation/repository checks passed before the final placement/text refinement. Final scoped Roblox analysis and compilation pass; final GUI harness has 35 cases (12 foundation, 12 gameplay, 11 waypoint), including 12 viewport geometry inputs, 146-degree heading transfer, EN/TH hint keys, stale-state cleanup, text-lane reservation and unsupported-layout detection. Raw outputs are compass-baseline.log, compass-gui-final.log, compass-analysis-final.log and compass-compile-final.log in checks/. Independent source review found no remaining scoped blockers. Geometry and string assertions do not establish TextFits, legibility or native input acceptance.

Controller retains Studio ownership. Recheck the actual earned client at 796x674 and short landscape, then EN/TH authored/unavailable/destination states at 390x844. At 320x280 verify unsupported-layout behavior rather than marking navigation accepted. No server/profile, upload or commerce changes.

Read-only asset warning investigation at controller integration: exact 203785492 searches found historical console evidence in production/ux/gui-foundation and production/design/integration/p1-city/world-connectivity, but no reference in tracked runtime source. Runtime origin is unresolved; no replacement ID was guessed. A controller-owned Studio instance/property inspection is needed to attribute the request.
