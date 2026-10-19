# Inventory polish native review, 2026-10-19

Source worker8f4abfe, integrated9ac4dbf. Candidate SHA256
fffc4e9644f82690e2e2a25975fcd1dc8e424ebf1a461f2ea63de09cf02382d1.
Actual Studio4cdfbab5-4ec5-4871-bd09-987cf0ab07e1, unsaved PlaceId/GameId0.
One enabled isolated InventoryReview LocalScript, no gameplay server/remotes.
An initial count using IsA('Script') before IsA('LocalScript') reported1/0;
the subsequent exact ClassName/path/source inspection showed the fixture
LocalScript. That initial classification is not evidence of a server script.
Play was stopped for inspection before restarting the actual fixture.

Mouse-driven 18 combinations: EN/TH x320/796/1366 nominal canvas x0/1/6 actors.
All cases reported zero non-fitting pane text, including offscreen descendants.
These are actual engine GUI canvas layouts within a796px Studio view, not
physical device or full1366px screen visibility evidence. Medium actor viewport
measured233x180; actual local avatar visible in captured medium Thai actor1.
Capture inventory_polish_medium_th_actor1 was inspected via MCP (no local PNG).

Phone Thai picker expanded five full-word choices, all272x48 and TextFits true.
Scrolling allowed choosing Material; picker collapsed to translated label.
Sixth actor was reached by scrolling roster and clicking; Loadout showed
Companion5, correct58/16/3 stats and explicit unavailable-model fallback.
Expanded screenshot inventory_polish_phone_th_expanded exposed a missing-glyph
square for the Unicode chevron. S14 owns a bounded native-geometry replacement;
visual acceptance remains pending that fix and fresh screenshot.

Medium spareSword sale first click showed translated confirmation with0 intents;
second recorded exactly1 SellEquipment intent with instanceId=spareSword.
No server receipt, currency or inventory mutation is claimed by this fixture.
Busy phone picker Active=false/Selectable=false; clicking did not expand it or
add another intent. Raw matrix/actions files retain actual tool results.

Native resize/destruction with picker open, corrected chevron, normal fresh-game
integration, gamepad, physical touch/performance and human reference-art approval
remain pending. Existing local tests and old captures do not satisfy these gates.
