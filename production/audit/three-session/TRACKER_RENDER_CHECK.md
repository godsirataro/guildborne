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

## 14px source revision observed in native Studio

In isolated instance a7b4b3ce-3996-4a25-9480-912e61bffc22, instantiated the actual
PlayerScripts.Client.UI.QuestTrackerView from the later candidate in a disposable
ScreenGui. At796x616, tracker position254,10 size306x44, objective font14.
Thai กิลด์ของคุณเอง 0/1 returned TextFits=true and was visually readable in
tracker14-th inline capture. English Help the city supply crew deliver their
crate returned TextFits=true, bounds265x14 inside294x36 objective area, visually
confirmed in tracker14-en. A late-created opaque sibling HUD was behind tracker.
Fixture ScreenGui was removed afterward. This deliberately isolated widget
rendering above the Title; it is not ordinary quest state/menu suppression,
physical-device or final visual-reference approval. No screenshot disk path is
asserted for these inline captures. The original earned session was unchanged.
