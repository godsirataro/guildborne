# Native HUD and Borin closeout — 2026-10-20

Source 1f8d0c4a579d0e6c8195e54d2c69e94e05372f9a integrates independently reviewed
S14 276d732 on the previous b6a866f runtime. Built preview SHA256
c718f0845fe31c5f6e58999b531a9c9703cc07999181367033f4abc30f1c177f.
The build hash is not whole-live-place identity. Full baseline run
38ebd847dec247a9b0ea5b566f85808f passed on unchanged source: 968 tests,
391 strict files, 488 links plus build/analyze/compile/boundary checks.
Raw invocation/stdout/stderr are included; nonfatal existing diagnostics remain.
Separate independent GUI review ran 62 simulations including 132 size combinations.

## Environment and recovery

Local Studio, Place/Game 0, Memory, no allowed DataStore universe, no publishing,
upload or provider generation. The first Play used Studio93fd1ca5-0be3-465c-a439-eb9ee254e9c0
at viewport1210x834. All433 normalized UTF8 length/Adler32 source comparisons
matched; these are not cryptographic whole-place checks. Safety readback retained.
Player was synthetically repositioned from Novice start to360,4,-958 for inspection.
This is not earned travel/progression evidence.

HUD capture in that session had a blank3D background; Windows whole-Studio
capture also showed blank/ghosted surfaces. Preserve that failed visual capture.
After Stop, Ctrl+S saved the existing controller checkpoint at
build/toolchain-20261020/Guildborne_Connected.rbxl, 1367090 bytes, SHA256
4a05efc00d62059380b76926ec5eaf232bfca55a2f9fcc870de934e7b632bc92.
The saved-file hash is distinct from the build hash. A hidden readback instance
ac14581e-c038-4c49-99af-a9a3e30b2126 matched433 sources, then was closed by verified
controller-owned process identity. Visible Studio fe0ad064-622d-4adb-9e68-0b233ad44457
opened the same saved file and matched433 sources again (raw included).
MCP 3D captures recovered at viewport2076x935; Windows UI capture still exhibited
ghosted/blank panels. No conclusion about underlying GPU cause is established.

The recovered session used a fresh Memory player synthetically placed at
365,4,-953. Subsequent walk-out/return used character_navigation at speed1.
No rewards/profile grants or source hotpatches were used. Instrumentation was
read-only of world state; one bounded RenderStepped observer kept its private data
in _G, disconnected automatically after42seconds, and the private key was removed
on retrieval. Play was stopped and Edit confirmed afterward.

## HUD result

At1210x834, native tracker x764..1064 and map x1072..1202 leave8px clearance.
The blank-background screenshot proves HUD placement only. Initial map-open
observation was not archived; journal final state was retained.

The recovered2076x935 session provides unchanged native screenshot and raw rects:
tracker x1630..1930, map x1938..2068, both visible,8px gap. Tracker heading and
objective TextFits=true for the English fresh-Novice state. Real mouse clicks
opened CityMap, hid tracker during the map, closed map, then opened the chapter
journal from the tracker; both map-open and journal-open readbacks are archived.
No callback was invoked directly to manufacture those states.

Selecting Central Plaza guidance closed the map and showed the direction arrow,
but NextWaypoint card remained hidden in that route state. This is not a native
pass for the below-tracker card fallback. That fallback has simulated evidence
at900/901/945x640; native900x640/phone/short landscape and TH retests remain open.
No physical-device or final-art approval is claimed.

## Borin result and limits

First probe:2881 frames over48.013610seconds,1669 changes in each named right-arm
joint, no reported forbidden-flash/root changes. Its quietArmChanges=0 lacked a
quiet-frame denominator; it cannot by itself establish a stationary idle period.

Revised probe retained source and raw response:2881 frames over48.000177seconds,
544 Idle/weight0 frames,542 consecutive quiet pairs,zero quiet arm changes,
zero root changes and zero forbidden-flash frames. Each named RightUpperArm,
RightLowerArm and RightHand changed1576 times in Work. These counts are computed
by the executed probe; compressed transition rows do not independently reproduce
every per-frame counter. Rows now include actual Idle/weight0/clock0 observations.
This supports bounded motion-state behavior, not human animation/contact approval.

During an observed Social/Idle/weight0 state at distance7.68studs, ordinary E input
opened FriendlyDialogue_smith_borin.78 quarter-second samples over19.9827seconds
kept dialogue visible, modeInteract, weight0 and flashfalse while routine changed
between Work and Social. Server interactor matched local player11732987790.
Actual close-button input returned to HUD. No quest turn-in/reward acceptance.

Ordinary assisted walk-out reached camera distance125.505studs:Idle,weight0,clock0,
flashfalse. The bounded return observer recorded2521frames/42.017493seconds,
first near100 at1.830672s, Recover at7.964628s, Work at8.564633s with clock0,
and no forbidden-flash frames. It sampled transitions plus quarter-second rows.
Returning during Social correctly stayed Idle until a later Work interval.
No frame-time/performance, sound playback, reduced-motion, respawn, allNPCs,
multiplayer, full-city population or human art acceptance follows from this check.

## Remaining tool state

Visible Studio fe0ad064-622d-4adb-9e68-0b233ad44457 is stopped in Edit.
Rojo server PID22824 still listens on127.0.0.1:34872, but after restart the plugin
readback is NotConnectedPage and no established connection was observed.
Reconnect is pending; serving a port or matching saved source is not live sync.
Blender scene was not touched in this closeout. ForgeGUI remains deferred per user.

Console contains existing FoundationProvider warnings; the restart also reported
AssetExport preinit ferry failure and asset203785492 type mismatch. These are
preserved observations, not a clean-console claim. One guarded read probe found
Is3dRenderingEnabled unavailable; no rendering property was changed.
