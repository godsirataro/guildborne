# Native tracker rendering — 2026-10-17

Source 021174c QuestTrackerView patched exactly into isolated Memory Studio
04084a7d-b461-47ee-bc6a-9592dd718ff3 before Play; equality verified in Edit.
Actual native module rendered into a disposable ScreenGui with Sibling ordering.
A later-created opaque HUD root ZIndex=1 and opaque child ZIndex=3 reproduced
the overlap condition, with tracker root ZIndex=5 above them.

At actual 796x617 viewport, tracker position=(254,10), size=(306,44).
Captured and inspected tracker-layer-en.jpg and tracker-layer-th.jpg. English
`A Guild of Your Own 0/1` and Thai `กิลด์ของคุณเอง 0/1` both rendered above the
HUD. Thai TextFits=true, but 12px text is visually small; S14 received the image
and a legibility improvement request. Fixture removed after capture.

This fixture deliberately displayed above the title screen to isolate rendering.
It does not certify ordinary Journal acceptance/tracking, menu suppression,
every screen size, physical touch devices, or final art quality. GUI simulation
runner `python tests/gui/run.py` separately passed 24 cases after integration.
