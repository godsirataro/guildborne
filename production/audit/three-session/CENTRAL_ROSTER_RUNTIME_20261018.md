# Central court and six-actor roster integration

Integrated S13 `ba1aaa1` as `014adb2` and S14 `b9d0029` as `9ab3aa3` after separate read-only reviews. The sole cherry-pick conflict was generated arrival-clearance metadata; rerunning its checker against the integrated source resolved it with PASS, rather than retaining the old source hash. All 116 placements and 413 collider records remain unchanged. Only two forest surface meshes changed; 35 others are unchanged.

Controller checks: arrival checker PASS, central checker PASS, GUI runner PASS, scoped Luau-LSP PASS (existing watched-files registration warning), disposable roster build PASS, combined Memory preview build PASS, git diff whitespace check PASS. The GUI runner actually reports 12 + 14 + 13 + 4 + 2 = **45** simulated cases; worker prose's count of 44 was an arithmetic error. The historical 902-test baseline predates these changes and is not represented as a fresh combined baseline.

## Native roster observations

Studio `ff7a40bb-42b8-4c63-b908-f5c7869ea77e`, Client. Created an isolated copy of the delivered fixture/modules; only require paths and a module return were adapted. Art/Theme/Chrome/Layout source was copied from the integrated checkout. No profile or server reward changes.

Actual Roblox glyph rendering was inspected in fixed-size canvases 390x844, 360x800, 320x760, 900x640 and 1366x768, with six delivered English and six Thai names at each size. All 60 name observations and all HP observations reported TextFits=true; name and HP rectangles stayed separate. Several English names wrapped to 26px height at 320px width. This was not device emulation or physical-device evidence: the actual viewport was 796x674, so some canvas extents were outside it.

Tool capture `party_roster_th_native_390` showed six decorated cards, distinct low/zero-health bars and Thai names. Portraits were explicitly dummy colored heads. Initial screen-coordinate clicks did not select the expected cards; native absolute positions differed after tool interactions. Retesting with exact instance paths and a 150ms event wait selected each of the six cards independently, with exactly one selected rail each time. The initial failed assertions are not counted as passes. All fixture GUI and module objects were destroyed and absence verified.

This is fixture interaction evidence, not a live player-plus-five-earned-heroes result. Full-HUD overlap, mobile touch/performance and final reference-art acceptance remain open. The small glyphs still warrant a readability pass.

## Actual combined world import

Built candidate SHA256 `4161584e6cb5f5881fd623911aaa8bdb34f4875a31cbe1d1597d690074f930d9`, copied to `build/Guildborne_CentralRosterReview.rbxlx`. New Studio `f0806b7e-820e-4851-95b8-31a8d226533f` confirmed PlaceId/GameId zero, Memory, isolated preview, Novice/Ironveil enabled and later journey flags disabled before Play.

Actual Client Dataset1: READY_LOCAL_ONLY, 116 placements, 44,967 unique triangles, LoadSeconds 5.332193500005815. Art and collision source hash both `011091586afb5416cb2c205b2a3db3e6ca36e4e82a79abe5489b24e6385e825d`; collision ready true and enemy binding READY_LOCAL_ONLY. Total Stats memory observed 2995.53515625 MB; this is total engine/client memory, not incremental art cost, mobile memory or FPS evidence.

Actual tool screenshots: `central_116_runtime_arch` at (40,22,1435) looking at (0,7,1380), and `central_116_runtime_overview` at (105,94,1545) looking at (0,4,1410). Eleven ScreenGui states were saved, hidden, then restored; capture state folder removed. Screenshots were inspected through tool output, not claimed as separately archived local PNGs.

The irregular shoulders and worn forecourt visibly connect the arch approach better. Roblox daylight still reveals strong triangle color facets, flat sparse ground, a generic arch silhouette and an obvious isolated platform edge. This is incremental visual progress, not completed world art. Ordinary traversal/hero behavior at the revised boundary and combat telegraph contrast remain unverified in this wave.

Usage after this wave: 90% used / 10% remaining. Goal remains ACTIVE and full-game acceptance remains incomplete.

## Additional actual server geometry checks

Eight downward raycasts at street/shoulder/arrival samples hit the native island or expected collision parts with upward normals, at Y2 or street Y2.08. Four real PathfindingService computations (AgentRadius2, AgentHeight5, jumping enabled) succeeded: street through gate 22 waypoints, west shoulder to street 8, east shoulder to street 8, arrival to forecourt 25. None required a jump. Path objects were destroyed. These are actual server geometry/path computations, not avatar walking, hero locomotion or combat-clearance acceptance.

## Next bounded worker wave

Controller released world and GUI scopes before dispatching the next tasks through the connected thread tool. S13 is assigned an original woodland-gate identity pass within existing placement/collision boundaries, with Blender before/after evidence. S14 is assigned improved tall-card glyph readability and surrounding-HUD fixture coverage. Both must claim the shared v4 ledger, review independently, commit locally and release; Studio remains controller-owned. Both received the current 10% remaining usage observation and 5% stop threshold. No completion of these new assignments is claimed here.
