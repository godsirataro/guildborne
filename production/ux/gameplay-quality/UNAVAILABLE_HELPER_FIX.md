# Narrow unavailable helper

Controller's native component fixture for 9337ae2 found English FinalDestination="Follow the quest instructions" did not fit the 110x20 helper at 390x844. Thai fit. Controller also reported shown EN/TH text fit at 796x674 and 796x400, and compact destination/authored copy fit at 390x844. These are native component fixture observations, not physical-device or full traversal acceptance. 320x280 remains explicitly unsupported for the card (LayoutUnavailable=true).

This followup uses "See quest" / "ดูภารกิจ" for the unavailable helper when viewport width is below600. Wide copy and all route logic remain unchanged. A focused simulation checks both languages, unavailable state after an active destination compass, absence of compass/world marker, and restoration of wide helper copy.

Validation: 36 GUI simulation cases (12 foundation,12 gameplay,12 waypoint); scoped Roblox definitions analysis and diff checks pass. Source review found no blockers. Raw outputs: checks/helper-gui.log and checks/helper-analysis.log. The new concise text still needs controller-owned native TextFits confirmation; simulation does not measure glyph layout.

Coordination: plan-only0c8229c adopted as7e5dec2; claimed gameplay-ui-quality only on four-session-v4.sqlite3. No Studio or server/profile changes.
