# Tall roster readability and portrait input clearance

Integrated S14 `df3627c` as `439d9dc`, then `ddaed22` as `145d1f2`, after independent source review. Names on tall cards are 15px in a 36px two-line lane, with HP still separate. Portrait noncompact combat pads start at Y116, leaving 8px below Map's Y60..108. Actual PlayerCombatController consumes shared padTop. Controller updated WaypointBeacon's reserved pad rectangle to that same value, resolving the integration test failure openly reported by S14.

Controller full GUI runner: **46 simulated cases passed** (12 base, 15 gameplay, 13 waypoint, 4 tracker, 2 menu). Scoped Roblox LSP passed for WaypointBeacon, PlayerCombatController, CombatHudLayout, CombatChrome and IronveilPromptReview, with the existing watched-files-registration warning only. No full baseline rerun claimed.

Actual Studio native fixture used exact integrated Chrome/Layout/Theme/Art sources with isolated require paths. Its identity/health data and surrounding HUD reservations are explicitly synthetic. Native tool clicks switched each preset/language. All 36 name observations at logical 390x844, 320x760 and 1366x768 across EN/TH fit at automatic display scaling. The same 36 name observations also fit after explicitly setting UIScale=1; 320px English names used 30px text height inside36px. HP fits and name/HP separation passed in the scaled observations. Native map-to-pad clearance measured approximately8 logical pixels for both portrait presets and160 for desktop. Actual returns retained in `party-readability-native-20261018.json`.

Tool screenshot `portrait_pad_15px_native_scaled` visibly shows separated map/attack regions, six cards, order and health reservations at63% display scale. It is a synthetic canvas screenshot, not a device capture or all-controls actual-gameplay acceptance. The wrapper modules and fixture GUI were destroyed; both absences verified. No server state was modified by this UI fixture.

Known remaining issue: compact/collapsed short layouts retain their pre-existing Map/Attack overlap. They were deliberately unchanged in this noncompact-portrait fix, and require a separately reviewed geometry/input pass. No all-viewport claim. Full live five-hero integration, native actual-control visibility during regional combat, physical mobile/touch/performance and final art acceptance remain open.

Latest quota observation:91% used /9% remaining. S13 original gate identity wave is still active; no delivery acceptance for that wave yet.
