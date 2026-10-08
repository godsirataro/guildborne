# Novice journey UI foundation — 2026-10-03

The optional Novice profile now has a dedicated Guild-page route: current chapter, ordered objective checklist, earned XP claim, solo-trial prerequisite, two-step first-class confirmation and one free level-10 companion choice. Changing the hero clears founding confirmation. Busy/capacity states disable actions and focus. Thai and English labels are supplied for every Chapter 00 objective and action.

The view only emits typed chapter/class/founding intents. It cannot create objective or trial receipts. The ordinary main runtime still uses legacy profiles and does not show this route. The optional projected chapter catalog must be supplied with the future Novice bootstrap. Founding completes the Novice tutorial rather than starting the old recruitment tutorial. Hall-upgrade cap labels now use the profile's ruleset through a server-projected next cap.

Native isolated UI verification: 36 states at widths 240/640 in English/Thai; 252 text-bounds checks and 12 captured actions; no real profile writes or network requests. Class and guild confirmation, changing the chosen hero, unavailable/active/ready/trial/class/full-inventory/founding/busy/complete states passed. Evidence: `validation-novice-journey-native.json`. Full domain suite remains 476 passed in `validation-novice-journey-domain.txt`.

Still open: actual-input Novice flow, route hints to real story stations, class trial selection/world binding, physical device/controller acceptance and onboarding balance. Fixtures do not establish a playable Novice journey.
