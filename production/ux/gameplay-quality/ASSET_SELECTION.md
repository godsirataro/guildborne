# Gameplay UI asset selection — 2026-10-17

Status: SOURCE_SELECTED_NOT_RUNTIME_IMPORTED. Four exact original PNG archive members, visually inspected plus alpha-channel inspection. No font, sample screenshot, vector re-render, external upload or invented Roblox ID is included. Shared root lease checked before writes.

| QualityAssetKey | Source member | Dimensions | SliceCenter | Use |
|---|---|---|---|---|
| panelBorder | Fantasy UI Borders / PNG/Double/Border/panel-border-002.png |96×96|28,28,68,68|White transparent mask, tint #DCB76B; suggested SliceScale0.5 for14px corner region. Gold double-line corner flourishes over navy.|
| parchment | RPG expansion / PNG/panel_beigeLight.png |100×100|16,16,84,84|Original ivory fill and subtle chipped rim; white ImageColor3, dark runtime text.|
| questIcon | Game Icons / PNG/White/2x/exclamation.png |100×100|none|Transparent exclamation silhouette; Gold/Ivory tint.|
| partyIcon | Game Icons / PNG/White/2x/multiplayer.png |100×100|none|Two-person silhouette; label explicitly as human party where applicable.|

`assets/production/ui-slice/manifest.json` supplies original archive/member hashes, exported PNG hashes, dimensions, alpha bounds, license paths and null runtime IDs. Every PNG is byte-identical to its archive member. Source archives in the original Catalog are read-only. Included license text explicitly grants CC0 commercial/personal reuse. No fonts are redistributed; Fantasy UI Borders mentions a sample font, but neither sample nor font is included.

The chosen border's center alpha is0. The similarly named Transparent center archive variant has alpha127 fill and was rejected. The flourish occupies the first24 pixels; a28px slice boundary leaves a4px straight-edge margin. The parchment uses a16px inset to preserve its chipped corner/rim detail. These are image-derived slice settings, not claimed native Studio acceptance.

Icon art has built-in transparent margins: quest alpha bounds42,24,58,84; party16,28,86,76. To avoid a tiny exclamation, controller may use ImageRectOffset=(42,24), ImageRectSize=(16,60), ScaleType.Fit in a16×28 icon holder; party may use offset(16,28),size(70,48) in a32×24 holder. This samples original pixels without modifying the file. Do not distort icons to fill square holders. Inset content away from border ornaments.

No suitable book glyph was found in the inspected CC0 packs. Game Icons scrollVertical is a scrolling arrow pair, not a parchment scroll, and was rejected. A journal can use the quest marker plus a native localized label; do not relabel navigation arrows as a book.

Local controller may bind ImageLabel.ImageContent from EditableImage pixels using the exact QualityAssetKey. This is a local Studio review binding, not a published asset or persistent import. Missing runtime IDs must retain native fallback. Human visual approval and native slicing/input acceptance remain pending. The restrained masks help match the reference hierarchy but do not claim parity with painted metal frames or illustrated scenery.
