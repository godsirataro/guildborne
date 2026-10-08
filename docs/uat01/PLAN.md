# Persistent implementation plan

| Milestone | State | Exit evidence |
|---|---|---|
| M0 Baseline and ownership audit | Partial | 271 tests and baseline build passed; staging place identity verified; content audit remains |
| M1 Native UI foundations and title | In progress | Title, palette, company preview, router, settings and bestiary implemented; full accessibility and device acceptance remain |
| M2 Commander HUD and skills | In progress | Three avatar slots implemented; unlock/cast tests pass for five classes; companion command HUD and device/VFX acceptance pending |
| M3 Adventures and economy content | In progress | 18 quests / 30 items / 10 recipes integrated; new regions, enemy behaviors/bosses and full route acceptance pending |
| M4 Recruitment and cosmetic shop | Pending | Stable rotation, replay-safe earned tickets, cosmetics and isolated simulation |
| M5 Player Guild and cooperative PvE | Pending | Canonical membership, crash/race recovery, filtering and reward deduplication |
| M6 Integrated UAT | Pending | Disk reconstruction, normal route, regression, two/four clients, EN/TH/mobile and measured performance |
| M7 Scrimmage | Deferred | Only after all core gates pass |

Latest: eleven-image original art pack, owned-company native preview, interactive skill graph, corrected tier copy, optional image wiring and decorative island scenery implemented. Full final automated validation passed. See ASSET_MANIFEST.md, UX_FLOW.md and VALIDATION_ART_UI.md.

Next: finish responsive/device acceptance and selected-companion HUD; review atlas crops and only upload/register assets after separate approval; convert concept map/characters into playable regions and rigs through M2â€“M5. Continue auditing actual content IDs before new transactions. The current 154-part scenery is not three playable regions. Respect USAGE_STOP.md between substantial batches.

Latest continuation: read HANDOFF.md for Bestiary, three authoritative skill slots and inventory sorting. No new playable region or enemy archetype was added.

Content continuation: see CONTENT_DELIVERY.md and validation-content-final.txt. Twelve local images now include an expansion equipment atlas. Next gameplay priority: compact playable regions/enemy behaviors; finish remaining M1/M2 acceptance before claiming UAT readiness.
