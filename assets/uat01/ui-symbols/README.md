# Guildborne UI symbols

58 original outline symbols: five classes, thirteen combat states/actions, twelve map markers, twelve guild emblem components, eight empty states, three brand symbols and five status attributes. Sources use a normalized 32-unit canvas and export as 64px SVG. No uploaded image IDs, fonts or external icon library are required.

STR, DEX, INT, VIT and WIS bind to StatusPointView allocation buttons, retaining the text labels. Native geometry verification passes all 58 symbols at 18/24/48px (1,533 primitive bounds checks). This is synthetic rendering verification; device and human review remain pending.

Rebuild with `python tools/build_ui_symbols.py`. `symbols.json` is the editable geometry source representation; the generator is authoritative. Generated `src/shared/Data/UISymbols.luau` uses typed numeric points. `src/client/UI/SymbolIcon.luau` renders native noninteractive Frames, with fractional scale coordinates to avoid Roblox integer-offset truncation at small sizes.

Five class marks bind to roster/player/skill headers, and six district marks bind to CityNavigation. Focus, Regroup and Retreat are bound to the existing command buttons. Three brand symbols are bound to TitleView. Six empty-state variants also appear in Inventory, Party, Market and Journal views. The remaining 30 symbols are candidates awaiting UI bindings and human/device acceptance. Guild emblem art does not implement guild ownership or emblem customization.

Studio synthetic verification: 53 symbols at 18/24/48px, 1,323 primitive checks, no clipping, unknown IDs rejected, noninteractive children. See `docs/uat01/validation-ui-symbols-runtime.json` and `docs/uat01/ui-symbols.png` (original42-symbol contact sheet); eight state samples appear in `docs/uat01/empty-states-thai.png`. Gallery labels are review identifiers, not localized gameplay copy.

Open `gallery.html` for the complete SVG contact sheet. Roblox runtime primitives remain usable without an upload. SVG import or conversion acceptance is separate.
