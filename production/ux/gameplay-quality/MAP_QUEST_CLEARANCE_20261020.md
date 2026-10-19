# Map / tracked-quest clearance — 2026-10-20

Base b6a866f. Controller native evidence inspected:
C:/Work/MySelf/Guildborne-controller/build/native-post-20261020/coast-quarry-reverse.png
At1210x834 the City Map/location column covers the right side of the tracked
quest. These are different ScreenGuis; raising tracker ZIndex would not resolve
the competing layout and would merely obscure the map instead.

## Bounded fix

CombatHudLayout now supplies trackerRect and trackerWide alongside existing map,
party and combat rectangles. QuestTrackerView consumes that rectangle. At wide
sizes (width>=900,height>=560), the300x96 tracked quest sits8px left of mapRect.
At width1210 the safe-area x interval is764..1064, map1072..1202. Its y remains70.
CityNavigation's location/bearing share the map's right-side column and are also
clear. CityNavigation source and map interaction/position are unchanged.

Compact tracker retains the original50px top-bar lane between gold and menu;
existing text, click behavior and responsive typography remain. WaypointBeacon
reserves trackerRect too and tries a fallback below the tracker, so placement
cannot introduce an overlap with the relocated quest. This can move or fold the
waypoint card where no candidate fits; it does not change routing or quest state.
Conservative reservation remains even if no tracker is currently visible.

## Verification

- GUI runner62 simulation cases PASS (previous60 plus two regressions).
- Actual tracker resize regression covers132 width/height combinations, including
  899/900/901,559/560,1210x834,phone and short landscape. Asserts exact shared rect,
  bounds, map8px clearance, location/bearing and roster/combat/orders separation.
- Beacon regression checks ten resize states for no tracked-quest intersection
  whenever its availability policy makes the card visible. At900/901/945x640
  the free lower lane must retain a visible card. Independent review caught the
  initial unnecessary fold; adding the below-tracker candidate resolved it.
- Scoped Roblox LSP and compile of all three production modules PASS.
- Rojo isolated gameplay UI gallery build PASS:one LocalScript,zero server
  Scripts/remotes. It uses synthetic profile data and does not prove real map
  integration. Full baseline was not rerun for this bounded presentation repair.
- Independent review result and immutable local receipt accompany handoff.

## Controller native retest (pending)

In the current normal Memory preview, capture the same quarry/coast return with
a tracked quest at1210x834. Compare actual safe GUI rects, not raw screen coords
without inset correction. Confirm both quest text and City Map/location column
are fully visible and independently clickable; opening map and quest journal
must retain menu blocking/close behavior.

Resize through width899/900/901 at height560+, then796x617,390x844 and short
landscape. EN/TH quest text remains live; wide card stays300x96, compact card stays
in the top bar. With quest guidance selected, confirm beacon moves to a clear
existing candidate or folds when no lane exists; no stale route state. Capture
fresh post-integration images. No worker Studio access, device acceptance,
publishing, Forge call or human visual approval claimed.
