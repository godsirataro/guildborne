# Native header v10 local visual review

These PNGs execute ResourceHeader, GuildborneButton, RegalOrnament and CombatHudLayout source through the existing Luau GUI simulation, then approximate their properties in Pillow. JSON stores captured source properties and rectangles; hashes identify inputs. No screenshot or game-world pixels are fabricated.

Tahoma substitutes GothamMedium; text fitting/wrapping, rotation, strokes, gradients and stacking are approximate. HUD reserved rectangles are labelled wireframes, not actual roster/map/tracker rendering. Six views include 1210/1920 desktop, 390/320 portrait and 844 landscape, EN/TH, Guild/Explore and unabridged 16-digit fixture values. Gold, captions and menu labels come through actual Localization.translate, with numeric 9007199254740991 and Hall20 stress fixtures. These values are presentation-only, not earned profile claims. Native text/overlap/input/device acceptance remains pending controller tests.

Before reference: `C:/Work/MySelf/Guildborne-controller/production/integration/quality-slice/native-earned-journey-20261020/earnedCampFinalCapture.png` (unchanged actual Studio screenshot). After source approximation is deliberately kept separate from that screenshot.

Reproduce: `python production/ux/gameplay-quality/header_visual_preview.py`.
