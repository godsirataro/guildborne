# Crosshaven / Chapter05 foundation — 2026-10-06

Implemented behind the explicit memory-only Crosshaven preview flag; other previews and staging keep it disabled. Chapter00–04 fresh gameplay evidence remains revision217 / Hall11. Chapter05 still needs an ordinary-input journey and release acceptance.

## Story and progression

`src/server/Config/ChapterFive.luau` adapts the supplied Chapter05 draft into six quests and nineteen objectives, from level70/Hall11 to level85/Hall14. Three choices produce eight routes; all preserve the main route and equal power rewards. Five root classes across these eight routes pass forty synthetic progression cases. Guaranteed quest materials cover the three Hall upgrades; no Robux, market purchase, random recruit or forced permanent advancement is required.

The cast reuses Sela (harbor/charter), Roka (refuge and reconciliation), Nyra (testimony/archive), and Borin (supplies and mechanical interlocks). Elian and Vaela are temporary visual stand-ins for the former rival and survivors. Final narrative identities and dialogue polish remain pending.

`BorrowedPathSession` and `BorrowedPathFactory` now support an explicit temporary mastery mode. It requires the Chapter04 checkpoint, Crosshaven mentor evidence, level70 and Hall11, and rejects active expeditions. All fourteen existing Class3 paths complete simulations with their actual abilities, two dodges and victory. The saved class and build remain unchanged. The default Class2 mode retains its existing admission rules. This does not implement the proposed thirty-five-class redesign.

## Visual and geometry evidence

Six original scenes in `assets/uat01/crosshaven-story-kit`: rift refuge, hearing square, refugee camp, forger passage, name registry and invitation gallery. The generated `CrosshavenStoryKit.luau` contains 241 visible parts and 52 markers. Native geometry probes pass 52 no-jump paths and 104 body/floor checks. Blender exports contain 2,892 triangles total; twelve FBX/GLB round trips pass bounds, origin and triangle checks. These are local blockouts; no actual player walk, animation upload or live asset import is claimed.

`assets/uat01/generated/guildborne-crosshaven-chapter05-v1.png` is an original atmosphere concept, not a screenshot of implemented terrain. Its prompt is saved in `assets/uat01/CROSSHAVEN_CHAPTER05_PROMPT.md`. The generated-image manifest now contains 32 PNGs.

## Hall progression correction

Campaign Hall upgrades now fail closed if the enabled story catalog does not contain the next Hall permit. Previously the last enabled chapter could fall through to the legacy QuarryPatrol gate. The service rejects the future upgrade before spending materials or Gold; the UI disables it with EN/TH explanation. A funded isolated native view was clicked in both languages and captured no action. Legacy non-campaign behavior is unchanged.

## Evidence and remaining work

- `validation-crosshaven-domain.txt`: full domain regression, including progression and temporary mastery simulations.
- Full regression passed 612 tests; 274 runtime Luau files passed strict analysis/compile and repository boundaries. Main, offline and four existing chapter previews build successfully.
- `validation-mastery-construction-native.json`: all fourteen Class3 arenas construct with EN/TH ability, health and goal labels (28 fixtures). The arena receives the borrowed ability explicitly instead of relying on Bootstrap's shared-config augmentation.
- `validation-mastery-archmage-input.json`: standalone Archmage won through ordinary Q/F input and speed1 navigation, two dodges, 73/227 HP, one captured completion receipt, no profile awards. Actual Leave trial click removed the arena and returned the avatar; owned Play stopped. This is not a full Chapter05 journey.
- `validation-crosshaven-story-native.json`: isolated scene geometry checks.
- `validation-future-hall-ui-native.json`: actual clicks on disabled future-Hall fixture, EN/TH.
- `assets/uat01/crosshaven-story-kit/export-report.json` and `roundtrip-report.json`: local exports.

## Preview world binding

`CrosshavenWorld.luau` now connects the nineteen objectives through 44 prompts, using session epoch/token checks, server-measured proximity, retryable private receipts and cleanup. It includes both neighborhoods' evidence, both speakers, camp supply checks, temporary support defense, two physical escorts, clue-gated passage, ordered interlocks, equal-reward choices and final preparation. Entry is in the central city near the guild portal at (18,2.15,-700); exit returns to City. Temporary mastery follows the saved path's Class3 descendant, or a matching root-class default.

`validation-crosshaven-world-native.json` records isolated fake-session checks: fifteen non-combat receipts, duplicate/foreign/distant/busy/low-level/stale-session rejection, checkpoint rebuild, puzzles and choices. `validation-crosshaven-escort-native.json` records two physical NPC routes with synthetic owner following, each delivering once. `validation-crosshaven-court-native.json` records all 52 paths from the common entrance and separated private slots. These do not constitute real-player completion.

`tools/build_crosshaven_project.py` creates `build/Guildborne_CrosshavenPreview.rbxlx`, explicitly enabling Chapter00–05 with memory persistence and an empty cloud allowlist. Bootstrap requires all prior preview flags and a local Studio place before enabling Crosshaven. All other preview flags remain off for Crosshaven.

Camp defense uses three ward pillars and guaranteed temporary shield/restore tools, with EN/TH labels. `validation-crosshaven-wards-native.json` covers the original support lessons and ward variant (six completions, eighteen cues, ownership/distance rejection and stale cleanup). `validation-crosshaven-wards-input.json` records an isolated actual-input camp run: 3/3 successes, zero mistakes, all wards 100/100, one completion. No actual profile reward was granted. A subsequent visual-only change smooths the support-floor surfaces.

The court now projects read-only destination text/position for the nearest unfinished station, its city entrance, Hall-upgrade exit or claim reminder. `CampaignDirections` hides for menus, lessons and foreign owners. `validation-campaign-directions-native.json` passes twelve EN/TH target/no-target layouts at widths240/360/750, heading and cleanup checks. A native no-jump city path from (0,3,-720) to (18,3,-700) succeeds with eight waypoints. Full-route guidance still needs ordinary-input acceptance.

Remaining: real-input full Chapter05 and fresh Chapter00–05 journey, remaining mastery paths through native input, narrative/visual stand-in replacement, quest navigation polish, persistence/reconnect, mobile/gamepad/multiplayer and human UAT. No cloud publication or production approval.
