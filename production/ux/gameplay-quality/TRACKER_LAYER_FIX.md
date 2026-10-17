# Tracker visibility fix — 2026-10-17

Observed coordinator Studio issue: at 796x617, the active quest tracker had Visible=true and real objective text, but its root shared ZIndex 1 with the HUD and its decorated subtree. No new screenshot or Studio acceptance is claimed by this worker.

Native sibling roots now explicitly order HUD 1, tracker 5, management 10, existing Title 20 and notices 30. Tracker decoration, progress and text have explicit internal layers; the native text sits above image decoration. Existing blocking-menu visibility remains authoritative.

Compact tracker bounds reserve eight pixels between the actual currency label and menu button. The former scale-only bounds overlapped those controls at 320px width; the new bounds preserve a 44px minimum target and retain the 796x617 placement. Desktop remains 300x96 at x=right-8,y=70 for viewports at least 900x560.

Meaningful simulation tests cover the observed 796x617 hierarchy, a late-created HUD subtree, live text, activation, and eight viewport boundary cases against real currency/menu bounds. They do not implement a Roblox renderer and cannot prove pixel visibility. Local full validation and GUI harness outputs accompany this report; coordinator must verify actual layered rendering and EN/TH readability in Studio.

This source fix is separate from custom raster art. No image file was altered, generated, uploaded or assigned an invented runtime ID.
