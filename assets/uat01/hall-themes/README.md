# Guild Hall theme library

Six original cosmetic variants across two Hall model levels: Human Hearth, Elven Canopy, Dwarven Forge, Orc Welcome, Mage Observatory and Crosshaven Commons. These share the current Hall structure and collision. They are native low-poly prototypes, not six completed cities or finalized architecture.

[Gallery](preview.png), [editable Blender scene](Guildborne_Hall_Themes.blend), [source geometry](kit.json), [export report](export-report.json) and [round-trip report](roundtrip-report.json). Twelve FBX, twelve GLB and twelve transparent icons.634visible parts /7,512triangles across all twelve variants; the native fixture includes twelve additional invisible sign anchors.

Source: server ArtKit plus shared HallAppearance, exported by [Studio exporter](../../../tests/studio_export_hall_themes.luau). Numeric indexed tables returned by MCP are normalized to JSON arrays when assembling kit.json. Blender uses `tools/blender_item_kit.py -- --kit assets/uat01/hall-themes --name Guildborne_Hall_Themes --max-triangles 1200 --large-assets --front-view`; verify with `tools/verify_blender_kit.py -- --kit assets/uat01/hall-themes`.

All24mesh exports preserve origin, bounds and triangles through Blender reimport. The Studio fixture passed5,287checks, including unchanged collision, noncolliding decorative bounds, idempotent appearance,48no-jump doorway paths, theme/level replacement, preserved movement and station location, and the actual level9label.

Runtime: Base → Building themes can select Guild Hall or an owned utility building. Human is free; Orc requires the claimed Borga quest and saved theme unlock. Paid themes remain unavailable with ProductId0. Theme changes retain Hall level and position and do not charge materials. Real offline UI claimed the Borga quest at revision4, unlocked Orc at5, and applied it to Hall at6; the native Hall remained at(0,1,-24).

Roblox mesh upload/import, final art approval, physical-device budgets, complete furniture themes and real purchase fulfillment remain pending. No cloud upload or live sale occurred.
